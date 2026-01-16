module TudlaHubstaff
  class BaseComponent < ViewComponent::Base
    include TudlaHubstaff::Engine.routes.url_helpers
    include Turbo::FramesHelper

    def default_url_options
      { only_path: true }
    end
  end
end
