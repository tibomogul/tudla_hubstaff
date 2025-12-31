module TudlaHubstaff
  class OrganizationUpdate < ApplicationRecord
    validates :organization_id, presence: true
  end
end
