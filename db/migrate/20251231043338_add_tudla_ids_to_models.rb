class AddTudlaIdsToModels < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    add_column :tudla_hubstaff_users, :tudla_user_id, :bigint
    add_index :tudla_hubstaff_users, :tudla_user_id, algorithm: :concurrently

    add_column :tudla_hubstaff_projects, :tudla_project_id, :bigint
    add_index :tudla_hubstaff_projects, :tudla_project_id, algorithm: :concurrently

    add_column :tudla_hubstaff_tasks, :tudla_task_id, :bigint
    add_index :tudla_hubstaff_tasks, :tudla_task_id, algorithm: :concurrently
  end
end
