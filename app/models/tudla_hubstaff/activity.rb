module TudlaHubstaff
  class Activity < ApplicationRecord
    validates :activity_id, presence: true, uniqueness: true
    validates :date, :user_id, presence: true
  end
end
