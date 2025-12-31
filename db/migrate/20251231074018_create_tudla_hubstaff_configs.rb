class CreateTudlaHubstaffConfigs < ActiveRecord::Migration[8.1]
  def change
    create_table :tudla_hubstaff_configs do |t|
      t.string :tudla_organization_type
      t.bigint :tudla_organization_id
      t.string :personal_access_token
      t.bigint :organization_id

      t.timestamps
    end

    add_index :tudla_hubstaff_configs, [ :tudla_organization_type, :tudla_organization_id ], name: "index_configs_on_tudla_organization"
    add_index :tudla_hubstaff_configs, :organization_id
  end
end
