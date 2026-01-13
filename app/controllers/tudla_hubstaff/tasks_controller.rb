module TudlaHubstaff
  class TasksController < ApplicationController
    skip_forgery_protection only: :map_tudla_task

    PER_PAGE = 20
    TUDLA_TASKS_PER_PAGE = 10

    def unmapped
      page = [ params[:page].to_i, 1 ].max
      offset = (page - 1) * PER_PAGE

      @tasks = Task.where(tudla_task_id: nil).order(:summary).offset(offset).limit(PER_PAGE)
      @total_count = Task.where(tudla_task_id: nil).count
      @current_page = page
      @total_pages = (@total_count.to_f / PER_PAGE).ceil
    end

    def available_tudla_tasks
      page = [ params[:page].to_i, 1 ].max
      name_filter = params[:name].to_s.strip.downcase

      all_tasks = host_interface.available_tasks_for_user(current_user)

      filtered_tasks = if name_filter.present?
        all_tasks.select { |t| t.name.downcase.include?(name_filter) }
      else
        all_tasks
      end

      total_count = filtered_tasks.size
      offset = (page - 1) * TUDLA_TASKS_PER_PAGE
      paginated_tasks = filtered_tasks.slice(offset, TUDLA_TASKS_PER_PAGE) || []

      render json: {
        tasks: paginated_tasks.map { |t| { id: t.id, name: t.name, project_name: t.project_name } },
        current_page: page,
        total_pages: (total_count.to_f / TUDLA_TASKS_PER_PAGE).ceil,
        total_count: total_count
      }
    end

    def map_tudla_task
      @task = Task.find(params[:id])
      tudla_task_id = params[:tudla_task_id]

      if tudla_task_id.present? && @task.update(tudla_task_id: tudla_task_id)
        respond_to do |format|
          format.html do
            if request.xhr?
              head :ok
            else
              redirect_to unmapped_tasks_path, notice: "Task mapped successfully."
            end
          end
          format.turbo_stream
        end
      else
        respond_to do |format|
          format.html do
            if request.xhr?
              head :unprocessable_entity
            else
              redirect_to unmapped_tasks_path, alert: "Failed to map task."
            end
          end
          format.turbo_stream { render turbo_stream: turbo_stream.replace("flash", partial: "shared/flash", locals: { alert: "Failed to map task." }) }
        end
      end
    end

    private

    def host_interface
      TudlaHubstaff.host_interface
    end
  end
end
