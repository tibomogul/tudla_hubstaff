module TudlaHubstaff
  class ApplicationController < ::ApplicationController
    include Pagy::Method

    layout -> { TudlaHubstaff::Engine.config.tudla_hubstaff.layout }
  end

  protected

  # we explicitly need the host to provide a current_user method
  def current_user
    super
  end
end
