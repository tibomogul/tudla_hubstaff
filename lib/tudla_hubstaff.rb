# Requires are necessary for the Engine to load these gems' tasks and classes
require "solid_queue"
require "solid_cache"
require "solid_cable"
require "tailwindcss-rails"
require "importmap-rails"
require "faraday"
require "httpx/adapters/faraday"
require "openid_connect"
require "tudla_contracts"
require "turbo-rails"
require "view_component"

require "tudla_hubstaff/version"
require "tudla_hubstaff/provider"
require "tudla_hubstaff/engine"


module TudlaHubstaff
  class << self
    # Configuration for the host interface class
    # Host apps should set this to their own class that inherits from
    # TudlaContracts::Integration::HostInterface
    attr_writer :host_interface_class

    def host_interface_class
      @host_interface_class || raise(<<~ERROR)
        TudlaHubstaff.host_interface_class is not configured.

        Please configure it in an initializer:

          # config/initializers/tudla_hubstaff.rb
          TudlaHubstaff.host_interface_class = "::HostInterface"

        Your class should inherit from TudlaContracts::Integration::HostInterface
        and implement the required methods like `available_users_for_user`.
      ERROR
    end

    def host_interface
      @host_interface ||= host_interface_class.constantize.new
    end

    def reset_host_interface!
      @host_interface = nil
    end
  end
end
