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
        provider_class: TudlaHubstaff::Provider,
        config_class: TudlaHubstaff::Config
      )
    end
  end
end
