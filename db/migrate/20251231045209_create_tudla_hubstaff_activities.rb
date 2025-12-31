class CreateTudlaHubstaffActivities < ActiveRecord::Migration[8.1]
  def change
    create_table :tudla_hubstaff_activities do |t|
      t.bigint :activity_id, null: false
      t.string :date, null: false
      t.bigint :user_id, null: false
      t.bigint :project_id
      t.bigint :task_id
      t.integer :keyboard, default: 0
      t.integer :mouse, default: 0
      t.integer :overall, default: 0
      t.integer :tracked, default: 0
      t.integer :input_tracked, default: 0
      t.integer :manual, default: 0
      t.integer :idle, default: 0
      t.integer :resumed, default: 0
      t.integer :billable, default: 0
      t.integer :work_break, default: 0
      t.datetime :last_updated_at

      t.timestamps
    end

    add_index :tudla_hubstaff_activities, :activity_id, unique: true
    add_index :tudla_hubstaff_activities, :date
    add_index :tudla_hubstaff_activities, :user_id
    add_index :tudla_hubstaff_activities, :project_id
    add_index :tudla_hubstaff_activities, :task_id
  end
end
