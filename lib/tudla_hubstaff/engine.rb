module TudlaHubstaff
  class Engine < ::Rails::Engine
    isolate_namespace TudlaHubstaff

    # Configure Zeitwerk to use UI instead of Ui for the ui directory
    initializer "tudla_hubstaff.zeitwerk_inflections", before: :set_autoload_paths do
      Rails.autoloaders.each do |autoloader|
        autoloader.inflector.inflect("ui" => "UI")
      end
    end

    config.generators do |g|
      g.test_framework :rspec
      g.fixture_replacement :factory_bot
      g.factory_bot dir: "spec/factories"
    end

    # Advanced FactoryBot Configuration
    # We hook into the initializer to append the path relative to the Engine's root.
    initializer "tudla_hubstaff.factories", after: "factory_bot.set_factory_paths" do
      if defined?(FactoryBot)
        FactoryBot.definition_file_paths << File.expand_path("../../../spec/factories", __FILE__)
      end
    end

    # Define an initializer that runs when the app boots
    initializer "tudla_hubstaff.register_integration",
      after:  "app.load_config_initializers" do
        config.to_prepare do
          # Register this gem's classes
          Rails.logger.info "Registering Hubstaff integration"
          TudlaContracts::Integrations::Registry.register(
            "hubstaff",
            type: "time_sheet",
            provider_class: "TudlaHubstaff::Provider",
            config_class: "TudlaHubstaff::Config"
          )
          TudlaContracts::Integrations::Registry.register_view_for_slot(
            "task_show_tab",
            TudlaContracts::Integrations::ViewDefinitions::ShowTabDefinition.new(
              id: :tudla_hubstaff_task_show_tab,
              label: "Hubstaff Activities",
              component_class: TudlaHubstaff::TaskActivitiesComponent,
              priority: 10,
              if: ->(task) { true }
            )
          )
        end
      end

    initializer "tudla_hubstaff.importmap", before: "importmap" do |app|
      if app.config.respond_to?(:importmap)
        app.config.importmap.paths << Engine.root.join("config/importmap.rb")
        app.config.importmap.cache_sweepers << Engine.root.join("app/javascript")
      end
    end

    initializer "tudla_hubstaff.assets" do |app|
      if app.config.respond_to?(:assets)
        app.config.assets.paths << Engine.root.join("app/javascript")
      end
    end

    initializer "tudla_hubstaff.view_component" do |app|
      # ViewComponent automatically picks up components from app/components
      # No additional configuration needed when using autoload_paths
    end

    # Configurable layout - allows host app to specify which layout to use
    config.tudla_hubstaff = ActiveSupport::OrderedOptions.new
    config.tudla_hubstaff.layout = "tudla_hubstaff/application"
  end
end
