module TudlaHubstaff
  class Provider < TudlaContracts::TimeSheet::Base
    def initialize(config)
      @config = config
    end

    def daily_activities
      # Implement the logic to fetch the time sheet from the provider
      [] # NOOP for now
    end
  end
end
