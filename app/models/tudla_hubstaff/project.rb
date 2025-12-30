module TudlaHubstaff
  class Project < ApplicationRecord
    validates :name, :project_type, presence: true
    validates :project_id, presence: true, uniqueness: true

    enum :project_type, {
      project: "project",
      work_order: "work_order",
      work_break: "work_break"
    }

    # Rails 8 automatic identification of JSON columns
  end
end
