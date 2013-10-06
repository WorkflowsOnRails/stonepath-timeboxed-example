class Task < ActiveRecord::Base
  include StonePath::SPTask

  state_machine do
    state :active, initial: true, after_enter: :notify_created
    state :completed, enter: :timestamp_complete, after_enter: :notify_closed

    state :expired, after_enter: :notify_closed
    state :cancelled, after_enter: :notify_closed

    event :complete do
      transitions from: :active, to: :completed
    end

    event :cancel do
      transitions from: [:active, :completed], to: :cancelled
    end

    event :expire do
      transitions from: :active, to: :expired
    end
  end

  scope :unassigned, -> { where('workbench_id IS NULL') }
  scope :assigned, -> { where('workbench_id IS NOT NULL') }
  scope :active, -> { where('aasm_state in (?)', ['active']) }
  scope :completed, -> { where('aasm_state in (?)', ['completed']) }
  scope :expired, -> { where('aasm_state in (?)', ['expired']) }
  scope :cancelled, -> { where('aasm_state in (?)', ['cancelled']) }
  scope :overdue, -> { where('aasm_state in (?) AND due_at < ?', ['active'], Time.now) }

  def overdue?
    (Time.now > due_at) && self.active?
  end

  def self.find_assignment(workbench: nil, workitem: nil)
    Task.where(
      workbench_id: workbench.id,
      workbench_type: workbench.class.name,
      workitem_id: workitem.id,
      workitem_type: workitem.class.name,
    ).take
  end

  private

  def timestamp_complete
    self.completed_at = Time.now
  end
end
