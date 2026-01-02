module TudlaHubstaff
  class FetchUpdatedActivitiesJob < ApplicationJob
    queue_as :default

    def perform
      current_time = Time.current

      OrganizationUpdate.find_each do |organization_update|
        process_organization_update(organization_update, current_time)
      end
    end

    private

    def process_organization_update(organization_update, current_time)
      return if organization_update.last_updated_at.nil?

      config = Config.find_by(organization_id: organization_update.organization_id)
      return unless config

      ApplicationRecord.transaction do
        api_client = build_api_client(config)
        start_time = organization_update.last_updated_at.iso8601
        stop_time = current_time.iso8601

        FetchUpdatedActivitiesService.new(api_client, start_time, stop_time).call

        organization_update.update!(last_updated_at: current_time)
      end
    rescue StandardError => e
      Rails.logger.error("Failed to fetch updated activities for organization #{organization_update.organization_id}: #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))
    end

    def build_api_client(config)
      connection = ApiConnection.new(config.personal_access_token).connection
      ApiClient.new(config.organization_id, connection)
    end
  end
end
