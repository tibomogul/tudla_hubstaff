module Hubstaff
  class ApiConnection
    AUTH_URL = "https://account.hubstaff.com"
    BASE_URL = "https://api.hubstaff.com/"

    def initialize(personal_access_token)
      @personal_access_token = personal_access_token
    end

    def connection
      @connection ||= Faraday.new do |req|
        req.url_prefix = BASE_URL
        req.adapter :httpx
        req.request :authorization, "Bearer", access_token
        req.request :json
        req.response :json
      end
    end

  private

    def token_endpoint
      @token_endpoint ||= Rails.cache.fetch("hubstaff_token_endpoint", expires_in: 1.weeks) do
        OpenIDConnect::Discovery::Provider::Config.discover!(AUTH_URL).token_endpoint
      end
    end

    def refresh_token
      @refresh_token = Rails.cache.fetch("hubstaff_refresh_token") do
        @personal_access_token
      end
    end

    def access_token
      access_token = Rails.cache.read("hubstaff_access_token")
      access_token ||= begin
        now = Time.current
        auth_conn = Faraday.new(url: token_endpoint) do |req|
          req.request :url_encoded
          req.adapter :httpx
        end
        response = auth_conn.post do |req|
          req.body = { grant_type: "refresh_token", refresh_token: refresh_token }
        end
        body = JSON.parse(response.body)
        Rails.cache.write("hubstaff_refresh_token", body["refresh_token"])
        Rails.cache.write("hubstaff_access_token", body["access_token"], expires_at: now + body["expires_in"])
        body["access_token"]
      end
    end
  end
end
