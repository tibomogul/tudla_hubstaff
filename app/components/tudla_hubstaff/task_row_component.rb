module TudlaHubstaff
  class TaskRowComponent < TudlaHubstaff::BaseComponent
    def initialize(task:)
      @task = task
    end

    attr_reader :task

    def dom_id
      "tudla_hubstaff_task_#{task.id}"
    end

    def truncated_details
      task.details.to_s.truncate(50)
    end
  end
end
