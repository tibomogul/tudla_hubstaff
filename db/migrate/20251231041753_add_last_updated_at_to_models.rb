class AddLastUpdatedAtToModels < ActiveRecord::Migration[8.1]
  def change
    add_column :tudla_hubstaff_users, :last_updated_at, :datetime
    add_column :tudla_hubstaff_projects, :last_updated_at, :datetime
    add_column :tudla_hubstaff_tasks, :last_updated_at, :datetime
  end
end
