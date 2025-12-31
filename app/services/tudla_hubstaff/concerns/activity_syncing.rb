module TudlaHubstaff
  module Concerns
    module ActivitySyncing
      private

      def sync_activity(activity_data)
        api_updated_at = Time.parse(activity_data["updated_at"]) if activity_data["updated_at"]

        activity = Activity.find_or_initialize_by(activity_id: activity_data["id"])

        return if activity.last_updated_at && api_updated_at && api_updated_at <= activity.last_updated_at

        activity_attributes = {
          activity_id: activity_data["id"],
          date: activity_data["date"],
          user_id: activity_data["user_id"],
          project_id: activity_data["project_id"],
          task_id: activity_data["task_id"],
          keyboard: activity_data["keyboard"] || 0,
          mouse: activity_data["mouse"] || 0,
          overall: activity_data["overall"] || 0,
          tracked: activity_data["tracked"] || 0,
          input_tracked: activity_data["input_tracked"] || 0,
          manual: activity_data["manual"] || 0,
          idle: activity_data["idle"] || 0,
          resumed: activity_data["resumed"] || 0,
          billable: activity_data["billable"] || 0,
          work_break: activity_data["work_break"] || 0,
          last_updated_at: api_updated_at
        }

        activity.update!(activity_attributes)
      end

      def process_activities_response(response)
        activities_data = response["daily_activities"] || []

        activities_data.each do |activity_data|
          sync_activity(activity_data)
        end

        activities_data.size
      end
    end
  end
end
