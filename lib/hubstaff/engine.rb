module Hubstaff
  class Engine < ::Rails::Engine
    isolate_namespace Hubstaff

    config.generators do |g|
      g.test_framework :rspec
      g.fixture_replacement :factory_bot
      g.factory_bot dir: "spec/factories"
    end

    # Advanced FactoryBot Configuration
    # We hook into the initializer to append the path relative to the Engine's root.
    initializer "hubstaff.factories", after: "factory_bot.set_factory_paths" do
      if defined?(FactoryBot)
        FactoryBot.definition_file_paths << File.expand_path("../../../spec/factories", __FILE__)
      end
    end
  end
end
