class AddIssueToComments < ActiveRecord::Migration
  def change
    add_reference :comments, :issue, index: true
  end
end
