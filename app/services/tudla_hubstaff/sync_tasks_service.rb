module TudlaHubstaff
  class SyncTasksService
    include Concerns::TaskSyncing

    attr_reader :api_client

    def initialize(api_client)
      @api_client = api_client
    end

    def call
      page_start_id = nil
      total_synced = 0

      loop do
        response = api_client.tasks(page_start_id: page_start_id)
        tasks_data = response["tasks"] || []

        tasks_data.each do |task_data|
          sync_task(task_data)
          total_synced += 1
        end

        page_start_id = response.dig("pagination", "next_page_start_id")
        break if page_start_id.nil?
      end

      { success: true, total_synced: total_synced }
    end
  end
end
