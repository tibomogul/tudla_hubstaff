module TudlaHubstaff
  class User < ApplicationRecord
    normalizes :email, with: ->(email) { email.strip.downcase }

    validates :name, :first_name, :last_name, presence: true
    validates :time_zone, presence: true
    validates :status, presence: true
    validates :user_id, presence: true, uniqueness: true

    enum :status, {
      active: "active",
      inactive: "inactive",
      pending: "pending"
    }, default: :active
  end
end
