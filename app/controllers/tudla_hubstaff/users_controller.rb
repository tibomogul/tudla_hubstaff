module TudlaHubstaff
  class UsersController < ApplicationController
    skip_forgery_protection only: :map_tudla_user

    PER_PAGE = 20
    TUDLA_USERS_PER_PAGE = 10

    def unmapped
      @pagy, @users = pagy(
        :offset,
        User.where(tudla_user_id: nil).order(:name),
        limit: PER_PAGE
      )
    end

    def available_tudla_users
      page = [ params[:page].to_i, 1 ].max
      name_filter = params[:name].to_s.strip.downcase

      all_users = host_interface.available_users_for_user(current_user)

      filtered_users = if name_filter.present?
        all_users.select { |u| u.name.downcase.include?(name_filter) }
      else
        all_users
      end

      total_count = filtered_users.size
      offset = (page - 1) * TUDLA_USERS_PER_PAGE
      paginated_users = filtered_users.slice(offset, TUDLA_USERS_PER_PAGE) || []

      render json: {
        users: paginated_users.map { |u| { id: u.id, name: u.name, email: u.email } },
        current_page: page,
        total_pages: (total_count.to_f / TUDLA_USERS_PER_PAGE).ceil,
        total_count: total_count
      }
    end

    def map_tudla_user
      @user = User.find(params[:id])
      tudla_user_id = params[:tudla_user_id]

      if tudla_user_id.present? && @user.update(tudla_user_id: tudla_user_id)
        respond_to do |format|
          format.html do
            if request.xhr?
              head :ok
            else
              redirect_to unmapped_users_path, notice: "User mapped successfully."
            end
          end
          format.turbo_stream
        end
      else
        respond_to do |format|
          format.html do
            if request.xhr?
              head :unprocessable_entity
            else
              redirect_to unmapped_users_path, alert: "Failed to map user."
            end
          end
          format.turbo_stream { render turbo_stream: turbo_stream.replace("flash", partial: "shared/flash", locals: { alert: "Failed to map user." }) }
        end
      end
    end

    private

    def host_interface
      TudlaHubstaff.host_interface
    end
  end
end
