module TudlaHubstaff
  class ActivitiesController < ApplicationController
    skip_forgery_protection only: :map_activity_task

    TUDLA_TASKS_PER_PAGE = 10

    def user_activities
      user_id = params[:user_id]
      page = params[:page] || 1
      unmapped_only = ActiveModel::Type::Boolean.new.cast(params[:unmapped_only])

      render TudlaHubstaff::UserActivitiesListComponent.new(
        user_id: user_id,
        current_page: page,
        unmapped_only: unmapped_only
      )
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

    def map_activity_task
      @activity = Activity.find(params[:id])
      hubstaff_task = Task.find_by(task_id: @activity.task_id)
      tudla_task_id = params[:tudla_task_id]

      if hubstaff_task.nil?
        respond_with_error("Hubstaff task not found for this activity.")
        return
      end

      if tudla_task_id.present? && hubstaff_task.update(tudla_task_id: tudla_task_id)
        respond_to do |format|
          format.html do
            if request.xhr?
              head :ok
            else
              redirect_back fallback_location: root_path, notice: "Task mapped successfully."
            end
          end
          format.turbo_stream
        end
      else
        respond_with_error("Failed to map task.")
      end
    end

    private

    def host_interface
      TudlaHubstaff.host_interface
    end

    def respond_with_error(message)
      respond_to do |format|
        format.html do
          if request.xhr?
            head :unprocessable_entity
          else
            redirect_back fallback_location: root_path, alert: message
          end
        end
        format.turbo_stream { render turbo_stream: turbo_stream.replace("flash", partial: "shared/flash", locals: { alert: message }) }
      end
    end
  end
end
