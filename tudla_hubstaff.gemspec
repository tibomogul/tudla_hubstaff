require_relative "lib/tudla_hubstaff/version"

Gem::Specification.new do |spec|
  spec.name        = "tudla_hubstaff"
  spec.version     = TudlaHubstaff::VERSION
  spec.authors     = [ "Tibo Mogul" ]
  spec.email       = [ "tibo.mogul@gmail.com" ]
  spec.homepage    = "https://tibomogul.github.io/"
  spec.summary     = "A Solid-integrated Rails 8 Engine."
  spec.description = "Provides core domain logic with RSpec, Solid Queue, and Tailwind integration."
  spec.license     = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the "allowed_push_host"
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/tibomogul/tudla_hubstaff"
  spec.metadata["changelog_uri"] = "https://github.com/tibomogul/tudla_hubstaff/blob/main/CHANGELOG.md"

  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 8.1.1"
  spec.add_dependency "solid_queue", "~> 1.0"
  spec.add_dependency "solid_cache", "~> 1.0"
  spec.add_dependency "solid_cable", "~> 3.0"
  spec.add_dependency "tailwindcss-rails", "~> 4.0"
  spec.add_dependency "importmap-rails", "~> 2.0"
  spec.add_dependency "faraday", "~> 2.0"
  spec.add_dependency "httpx", "~> 1.0"
  spec.add_dependency "openid_connect", "~> 2.0"
  spec.add_dependency "tudla_contracts", "~> 0.1"
  spec.add_dependency "turbo-rails", "~> 2.0"
  spec.add_dependency "stimulus-rails", "~> 1.0"
  spec.add_dependency "view_component", "~> 4.0"
  spec.add_dependency "pagy", "~> 43.0"

  # Development Dependencies
  # These are used only for running the engine's test suite.
  spec.add_development_dependency "sqlite3", "~> 2.0"
  spec.add_development_dependency "pg", "~> 1.0" # Optional, if testing Postgres compat
  spec.add_development_dependency "rspec-rails", "~> 8.0"
  spec.add_development_dependency "factory_bot_rails", "~> 6.0"
  spec.add_development_dependency "simplecov", "~> 0.2"
  spec.add_development_dependency "capybara", "~> 3.0"
  spec.add_development_dependency "selenium-webdriver", "~> 4.0"
  spec.add_development_dependency "debug", "~> 1.0"
end
