module TudlaHubstaff
  class Config < ApplicationRecord
    belongs_to :tudla_organization, polymorphic: true

    validates :tudla_organization_type, :tudla_organization_id, :organization_id, presence: true
    validates :personal_access_token, presence: true
  end
end
