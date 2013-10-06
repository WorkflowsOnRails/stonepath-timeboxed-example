class CommentsController < ApplicationController
  before_action :authenticate_user!

  def create
    @issue = Issue.find(params[:issue_id])
    @comment = @issue.comments.new(comment_params)
    @comment.user = current_user
    @comment.save!
    redirect_to @issue
  end

  private

  def comment_params
    params.require(:comment).permit(:comment)
  end
end
