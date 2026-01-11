module TudlaHubstaff
  class ApplicationController < ActionController::Base
    layout -> { TudlaHubstaff::Engine.config.tudla_hubstaff.layout }
  end
end
