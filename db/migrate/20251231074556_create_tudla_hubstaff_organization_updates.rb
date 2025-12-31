class CreateTudlaHubstaffOrganizationUpdates < ActiveRecord::Migration[8.1]
  def change
    create_table :tudla_hubstaff_organization_updates do |t|
      t.bigint :organization_id, null: false
      t.datetime :last_updated_at

      t.timestamps
    end

    add_index :tudla_hubstaff_organization_updates, :organization_id
  end
end
