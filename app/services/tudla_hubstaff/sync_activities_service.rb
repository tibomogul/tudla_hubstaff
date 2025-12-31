module TudlaHubstaff
  class SyncActivitiesService
    include Concerns::ActivitySyncing

    attr_reader :api_client, :start_time, :stop_time

    def initialize(api_client, start_time, stop_time)
      @api_client = api_client
      @start_time = start_time
      @stop_time = stop_time
    end

    def call
      page_start_id = nil
      total_synced = 0

      loop do
        response = api_client.daily_activities_by_date(start_time, stop_time, page_start_id: page_start_id)
        total_synced += process_activities_response(response)

        page_start_id = response.dig("pagination", "next_page_start_id")
        break if page_start_id.nil?
      end

      { success: true, total_synced: total_synced }
    end
  end
end
