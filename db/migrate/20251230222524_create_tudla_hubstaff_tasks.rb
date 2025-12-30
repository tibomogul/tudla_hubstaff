class CreateTudlaHubstaffTasks < ActiveRecord::Migration[8.1]
  def change
    create_table :tudla_hubstaff_tasks do |t|
      t.integer :integration_id
      t.string :status
      t.integer :project_id, null: false
      t.string :project_type, null: false
      t.string :summary, null: false
      t.text :details
      t.string :remote_id
      t.string :remote_alternate_id
      t.integer :lock_version
      t.json :metadata, null: false, default: {}
      t.datetime :completed_at
      t.datetime :due_at

      t.timestamps
    end
    add_index :tudla_hubstaff_tasks, :remote_id
  end
end
