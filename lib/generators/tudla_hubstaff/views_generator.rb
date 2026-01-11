require "rails/generators/base"

module TudlaHubstaff
  module Generators
    class ViewsGenerator < Rails::Generators::Base
      source_root File.expand_path("../../../app/views", __dir__)

      desc "Copies TudlaHubstaff views to the host application for customization."

      argument :scope, required: false, default: nil,
               desc: "The scope to copy (e.g., users, tasks, projects, layouts)"

      class_option :force, type: :boolean, default: false,
                   desc: "Overwrite existing files"

      AVAILABLE_SCOPES = %w[users tasks projects layouts shared].freeze

      def copy_views
        if scope.present?
          validate_scope!
          copy_scoped_views
        else
          copy_all_views
        end
      end

      private

      def validate_scope!
        return if AVAILABLE_SCOPES.include?(scope)

        say_status :error, "Invalid scope '#{scope}'. Available scopes: #{AVAILABLE_SCOPES.join(', ')}", :red
        raise Thor::Error, "Invalid scope"
      end

      def copy_scoped_views
        source_path = "tudla_hubstaff/#{scope}"
        target_path = "app/views/tudla_hubstaff/#{scope}"

        if File.directory?(File.join(self.class.source_root, source_path))
          directory source_path, target_path
          say_status :success, "Copied #{scope} views to #{target_path}", :green
        else
          say_status :error, "No views found for scope '#{scope}'", :red
        end
      end

      def copy_all_views
        directory "tudla_hubstaff", "app/views/tudla_hubstaff"
        say_status :success, "Copied all TudlaHubstaff views to app/views/tudla_hubstaff", :green
      end
    end
  end
end
