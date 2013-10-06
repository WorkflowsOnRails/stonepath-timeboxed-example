class IssuesController < ApplicationController
  before_action :authenticate_user!

  def index
    require_role 'reporter' or return
    @issues = Issue.open
  end

  def list_unscheduled
    require_role 'deployer' or return
    @issues = Issue.unscheduled
    render 'index'
  end

  def list_assigned
    require_role 'developer' or return
    @issues = Issue.assigned_to_developer(current_user)
    render 'index'
  end

  def list_pending
    require_role 'developer' or return
    @issues = Issue.pending
    render 'index'
  end

  def new
    require_role 'reporter' or return
    @issue = Issue.new
  end

  def create
    require_role 'reporter' or return
    @issue = Issue.new(issue_params)
    @issue.owner = current_user

    if @issue.save
      redirect_to @issue
    else
      render 'new'
    end
  end

  def show
    @issue = find_issue
  end

  def claim
    require_role 'developer' or return
    @issue = find_issue
    @issue.developer = current_user
    @issue.claim! # _attempt_ to close the issue
    redirect_to @issue
  end

  def sign_off
    require_role 'developer' or return
    @issue = find_issue
    @issue.signed_off = true
    @issue.close!
    redirect_to @issue
  end

  def schedule_deployment
    require_role 'deployer' or return
    @issue = find_issue
    @issue.assign_attributes(deployment_schedule_params)

    if @issue.valid?
      @issue.save!
      @issue.close!
      redirect_to @issue
    else
      render 'show'
    end
  end

  private

  def find_issue
    Issue.find(params[:id])
  end

  def issue_params
    params.require(:issue).permit(:title, :description)
  end

  def deployment_schedule_params
    params.require(:issue).permit(:deployment_date)
  end
end
