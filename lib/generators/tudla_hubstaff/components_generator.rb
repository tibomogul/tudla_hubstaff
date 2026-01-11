require "rails/generators/base"

module TudlaHubstaff
  module Generators
    class ComponentsGenerator < Rails::Generators::Base
      source_root File.expand_path("../../../app/components", __dir__)

      desc "Copies TudlaHubstaff ViewComponents to the host application for customization."

      argument :scope, required: false, default: nil,
               desc: "The scope to copy (e.g., ui, or a specific component like ui/modal)"

      class_option :force, type: :boolean, default: false,
                   desc: "Overwrite existing files"

      class_option :templates_only, type: :boolean, default: false,
                   desc: "Copy only the template files (.html.erb), not the Ruby classes"

      def copy_components
        if scope.present?
          copy_scoped_components
        else
          copy_all_components
        end
      end

      private

      def copy_scoped_components
        source_path = "tudla_hubstaff/#{scope}"
        target_path = "app/components/tudla_hubstaff/#{scope}"

        if options[:templates_only]
          copy_templates_only(source_path, target_path)
        else
          if File.directory?(File.join(self.class.source_root, source_path))
            directory source_path, target_path
            say_status :success, "Copied #{scope} components to #{target_path}", :green
          else
            say_status :error, "No components found for scope '#{scope}'", :red
          end
        end
      end

      def copy_all_components
        if options[:templates_only]
          copy_templates_only("tudla_hubstaff", "app/components/tudla_hubstaff")
        else
          directory "tudla_hubstaff", "app/components/tudla_hubstaff"
          say_status :success, "Copied all TudlaHubstaff components to app/components/tudla_hubstaff", :green
        end
      end

      def copy_templates_only(source_path, target_path)
        full_source = File.join(self.class.source_root, source_path)

        Dir.glob(File.join(full_source, "**/*.html.erb")).each do |template_file|
          relative_path = template_file.sub("#{self.class.source_root}/", "")
          destination = relative_path.sub("tudla_hubstaff/", "app/components/tudla_hubstaff/")

          copy_file relative_path, destination
        end

        say_status :success, "Copied component templates to #{target_path}", :green
      end
    end
  end
end
