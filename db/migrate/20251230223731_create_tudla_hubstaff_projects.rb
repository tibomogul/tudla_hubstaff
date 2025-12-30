class CreateTudlaHubstaffProjects < ActiveRecord::Migration[8.1]
  def change
    create_table :tudla_hubstaff_projects do |t|
      t.string :name, null: false
      t.text :description
      t.string :status
      t.string :project_type, null: false
      t.integer :client_id
      t.json :metadata, null: false, default: {}

      t.timestamps
    end
    add_index :tudla_hubstaff_projects, :client_id
  end
end
