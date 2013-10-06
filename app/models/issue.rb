class Issue < ActiveRecord::Base
  include StonePath::WorkItem

  validates :title, presence: true, allow_nil: false
  validates :description, presence: true, allow_nil: false

  belongs_to :developer, class_name: 'User'
  owned_by :user
  tasked_through :task

  state_machine do
    state :pending, initial: true,
      after_enter: [:create_claim_task, :create_deploy_task],
      after_exit: :destroy_claim_task
    state :in_progress, after_enter: :create_develop_task,
      after_exit: :destroy_develop_task
    state :closed, after_enter: :destroy_deploy_task

    event :claim do
      transitions from: :pending, to: :in_progress
    end

    event :timeout do
      transitions from: :in_progress, to: :pending
    end

    event :close do
      transitions from: :in_progress, to: :closed, guard: :completed?
    end
  end

  ### scopes ###

  scope :open, -> { where("aasm_state <> 'closed'") }
  scope :pending, -> { where("aasm_state = 'pending'") }
  scope :unscheduled, -> { where(deployment_date: nil) }

  def self.assigned_to_developer(user)
    where(developer: user)
  end

  ### entry / exit actions ###

  def create_claim_task
    Task.create(workbench: Role.developer, workitem: self)
  end

  def destroy_claim_task
    binding.pry
    Task.find_assignment(workbench: Role.developer, workitem: self).destroy
  end

  def create_deploy_task
    Task.create(workbench: Role.deployer, workitem: self)
  end

  def destroy_deploy_task
    Task.find_assignment(workbench: Role.deployer, workitem: self).destroy
  end

  def create_develop_task
    deadline = DateTime.now + 5.minutes
    Task.create(workbench: developer, workitem: self, due_at: deadline)
  end

  def destroy_develop_task
    Task.find_assignment(workbench: developer, workitem: self).destroy
  end

  def completed?
    signed_off and deployment_date.present?
  end
end
