class AddHubstaffIdsToModels < ActiveRecord::Migration[8.1]
  def change
    add_column :tudla_hubstaff_users, :user_id, :bigint
    add_index :tudla_hubstaff_users, :user_id

    add_column :tudla_hubstaff_projects, :project_id, :bigint
    add_index :tudla_hubstaff_projects, :project_id

    add_column :tudla_hubstaff_tasks, :task_id, :bigint
    add_index :tudla_hubstaff_tasks, :task_id
  end
end
