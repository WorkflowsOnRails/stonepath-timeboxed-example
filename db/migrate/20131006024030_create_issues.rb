class CreateIssues < ActiveRecord::Migration
  def self.up
    create_table :issues do |t|
      # These are the attributes of a workitem
      t.string :aasm_state, index: true
      t.integer :owner_id

      # Your attributes should be defined here.
      t.string :title
      t.text :description
      t.references :developer
      t.date :deployment_date
      t.boolean :signed_off
    end
  end

  def self.down
    drop_table :issues
  end
end
