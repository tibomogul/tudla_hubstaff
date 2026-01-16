class UsersController < ApplicationController
  layout -> { TudlaHubstaff::Engine.config.tudla_hubstaff.layout }

  def show
    # stubbing
    user = TudlaHubstaff::User.find(params[:id])
    @user_id = user.tudla_user_id
  end
end
