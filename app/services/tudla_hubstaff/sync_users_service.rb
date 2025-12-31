module TudlaHubstaff
  class SyncUsersService
    attr_reader :api_client

    def initialize(api_client)
      @api_client = api_client
    end

    def call
      page_start_id = nil
      total_synced = 0

      loop do
        response = api_client.members(page_start_id: page_start_id)
        users_data = response["users"] || []

        users_data.each do |user_data|
          sync_user(user_data)
          total_synced += 1
        end

        page_start_id = response.dig("pagination", "next_page_start_id")
        break if page_start_id.nil?
      end

      { success: true, total_synced: total_synced }
    end

    private

    def sync_user(user_data)
      api_updated_at = Time.parse(user_data["updated_at"]) if user_data["updated_at"]

      user = User.find_or_initialize_by(user_id: user_data["id"])

      return if user.last_updated_at && api_updated_at && api_updated_at <= user.last_updated_at

      user_attributes = {
        user_id: user_data["id"],
        name: user_data["name"],
        first_name: user_data["first_name"],
        last_name: user_data["last_name"],
        email: user_data["email"],
        time_zone: user_data["time_zone"],
        ip_address: user_data["ip_address"],
        status: user_data["status"],
        last_updated_at: api_updated_at
      }

      user.update!(user_attributes)
    end
  end
end
