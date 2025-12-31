module TudlaHubstaff
  class SyncProjectsService
    attr_reader :api_client

    def initialize(api_client)
      @api_client = api_client
    end

    def call
      page_start_id = nil
      total_synced = 0

      loop do
        response = api_client.projects(page_start_id: page_start_id)
        projects_data = response["projects"] || []

        projects_data.each do |project_data|
          sync_project(project_data)
          total_synced += 1
        end

        page_start_id = response.dig("pagination", "next_page_start_id")
        break if page_start_id.nil?
      end

      { success: true, total_synced: total_synced }
    end

    private

    def sync_project(project_data)
      api_updated_at = Time.parse(project_data["updated_at"]) if project_data["updated_at"]

      project = Project.find_or_initialize_by(project_id: project_data["id"])

      return if project.last_updated_at && api_updated_at && api_updated_at <= project.last_updated_at

      project_attributes = {
        project_id: project_data["id"],
        name: project_data["name"],
        status: project_data["status"],
        project_type: project_data["type"],
        client_id: project_data["client_id"],
        metadata: project_data["metadata"] || {},
        last_updated_at: api_updated_at
      }

      project.update!(project_attributes)
    end
  end
end
