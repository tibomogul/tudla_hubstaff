module TudlaHubstaff
  class GetTaskService
    include Concerns::TaskSyncing

    attr_reader :api_client, :task_id

    def initialize(api_client, task_id)
      @api_client = api_client
      @task_id = task_id
    end

    def call
      response = api_client.task(task_id)
      task_data = response["task"]

      return { success: false, error: "Task not found" } unless task_data

      task = sync_task(task_data)
      { success: true, task: task }
    rescue Faraday::Error => e
      { success: false, error: e.message }
    end
  end
end
