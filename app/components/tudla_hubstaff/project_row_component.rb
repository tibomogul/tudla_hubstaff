module TudlaHubstaff
  class ProjectRowComponent < TudlaHubstaff::BaseComponent
    def initialize(project:)
      @project = project
    end

    attr_reader :project

    def dom_id
      "tudla_hubstaff_project_#{project.id}"
    end

    def truncated_description
      project.description.to_s.truncate(50)
    end

    def formatted_project_type
      project.project_type.titleize
    end
  end
end
