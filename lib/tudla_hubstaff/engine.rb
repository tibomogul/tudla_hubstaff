module TudlaHubstaff
  class Engine < ::Rails::Engine
    isolate_namespace TudlaHubstaff

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
    initializer "tudla_hubstaff.register_integration" do
      # Register this gem's classes
      TudlaContracts::Integrations::Registry.register(
        "hubstaff",
        type: "time_sheet",
        provider_class: "TudlaHubstaff::Provider",
        config_class: "TudlaHubstaff::Config"
      )
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
  end
end
