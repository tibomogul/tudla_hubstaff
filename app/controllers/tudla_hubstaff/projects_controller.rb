module TudlaHubstaff
  class ProjectsController < ApplicationController
    skip_forgery_protection only: :map_tudla_project

    PER_PAGE = 20
    TUDLA_PROJECTS_PER_PAGE = 10

    def unmapped
      @pagy, @projects = pagy(
        :offset,
        Project.where(tudla_project_id: nil).order(:name),
        limit: PER_PAGE
      )
    end

    def available_tudla_projects
      page = [ params[:page].to_i, 1 ].max
      name_filter = params[:name].to_s.strip.downcase

      all_projects = host_interface.available_projects_for_user(current_user)

      filtered_projects = if name_filter.present?
        all_projects.select { |p| p.name.downcase.include?(name_filter) }
      else
        all_projects
      end

      total_count = filtered_projects.size
      offset = (page - 1) * TUDLA_PROJECTS_PER_PAGE
      paginated_projects = filtered_projects.slice(offset, TUDLA_PROJECTS_PER_PAGE) || []

      render json: {
        projects: paginated_projects.map { |p| { id: p.id, name: p.name } },
        current_page: page,
        total_pages: (total_count.to_f / TUDLA_PROJECTS_PER_PAGE).ceil,
        total_count: total_count
      }
    end

    def map_tudla_project
      @project = Project.find(params[:id])
      tudla_project_id = params[:tudla_project_id]

      if tudla_project_id.present? && @project.update(tudla_project_id: tudla_project_id)
        respond_to do |format|
          format.html do
            if request.xhr?
              head :ok
            else
              redirect_to unmapped_projects_path, notice: "Project mapped successfully."
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
              redirect_to unmapped_projects_path, alert: "Failed to map project."
            end
          end
          format.turbo_stream { render turbo_stream: turbo_stream.replace("flash", partial: "shared/flash", locals: { alert: "Failed to map project." }) }
        end
      end
    end

    private

    def host_interface
      TudlaHubstaff.host_interface
    end
  end
end
