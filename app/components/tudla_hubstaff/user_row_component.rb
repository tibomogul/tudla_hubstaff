module TudlaHubstaff
  class UserRowComponent < TudlaHubstaff::BaseComponent
    def initialize(user:)
      @user = user
    end

    attr_reader :user

    def dom_id
      "tudla_hubstaff_user_#{user.id}"
    end
  end
end
