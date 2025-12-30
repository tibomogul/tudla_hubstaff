module TudlaHubstaff
  class Task < ApplicationRecord
    validates :project_id, :project_type, :summary, presence: true
    validates :task_id, presence: true, uniqueness: true

    # Rails 8 automatic identification of JSON columns
    # No explicit serialize needed if using json/jsonb type
  end
end
