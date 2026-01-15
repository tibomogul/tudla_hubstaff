class TasksController < ApplicationController
  layout -> { TudlaHubstaff::Engine.config.tudla_hubstaff.layout }

  def show
    # stubbing
    @tudla_task_id = 1
  end
end
