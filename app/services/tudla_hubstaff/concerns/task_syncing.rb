module TudlaHubstaff
  module Concerns
    module TaskSyncing
      private

      def sync_task(task_data)
        api_updated_at = Time.parse(task_data["updated_at"]) if task_data["updated_at"]

        task = Task.find_or_initialize_by(task_id: task_data["id"])

        return task if task.last_updated_at && api_updated_at && api_updated_at <= task.last_updated_at

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
        task
      end
    end
  end
end
