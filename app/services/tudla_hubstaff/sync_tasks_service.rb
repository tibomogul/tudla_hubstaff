module TudlaHubstaff
  class SyncTasksService
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

    private

    def sync_task(task_data)
      api_updated_at = Time.parse(task_data["updated_at"]) if task_data["updated_at"]

      task = Task.find_or_initialize_by(task_id: task_data["id"])

      return if task.last_updated_at && api_updated_at && api_updated_at <= task.last_updated_at

      task_attributes = {
        task_id: task_data["id"],
        integration_id: task_data["integration_id"],
        status: task_data["status"],
        project_id: task_data["project_id"],
        project_type: task_data["project_type"],
        summary: task_data["summary"],
        details: task_data["details"],
        remote_id: task_data["remote_id"],
        remote_alternate_id: task_data["remote_alternate_id"],
        metadata: task_data["metadata"] || {},
        last_updated_at: api_updated_at
      }

      task.update!(task_attributes)
    end
  end
end
