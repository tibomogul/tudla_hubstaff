class CreateTudlaHubstaffUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :tudla_hubstaff_users do |t|
      t.string :name, null: false
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :email
      t.string :time_zone, null: false, default: "UTC"
      t.string :ip_address
      t.string :status, null: false, default: "active"

      t.timestamps
    end
    add_index :tudla_hubstaff_users, :email, unique: true
  end
end
