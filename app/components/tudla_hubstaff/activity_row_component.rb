module TudlaHubstaff
  class ActivityRowComponent < TudlaHubstaff::BaseComponent
    def initialize(activity:)
      @activity = activity
    end

    attr_reader :activity

    def dom_id
      "activity_#{activity.id}"
    end

    def hubstaff_task
      @hubstaff_task ||= TudlaHubstaff::Task.find_by(task_id: activity.task_id) if activity.task_id.present?
    end

    def tudla_task_id
      hubstaff_task&.tudla_task_id
    end

    def mapped?
      tudla_task_id.present?
    end

    def task_name
      if mapped?
        tudla_task&.name || "Task ##{tudla_task_id}"
      elsif hubstaff_task.present?
        hubstaff_task.summary
      else
        "No task"
      end
    end

    def tudla_task
      @tudla_task ||= TudlaHubstaff.host_interface.find_task(tudla_task_id) if tudla_task_id.present?
    end

    def show_map_button?
      hubstaff_task.present? && !mapped?
    end

    def map_url
      map_activity_task_activity_path(activity) if hubstaff_task.present?
    end

    def format_duration(seconds)
      return "0m" if seconds.nil? || seconds.zero?

      hours = seconds / 3600
      minutes = (seconds % 3600) / 60

      if hours > 0
        "#{hours}h #{minutes}m"
      else
        "#{minutes}m"
      end
    end

    def format_date(date_string)
      return "" if date_string.blank?
      Date.parse(date_string).strftime("%b %d, %Y")
    rescue ArgumentError
      date_string
    end
  end
end
