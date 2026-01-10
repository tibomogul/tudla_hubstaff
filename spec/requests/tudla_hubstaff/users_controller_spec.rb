require "rails_helper"

RSpec.describe "TudlaHubstaff::UsersController", type: :request do
  include TudlaHubstaff::Engine.routes.url_helpers

  let(:default_url_options) { { host: "localhost" } }

  before do
    stub_const("TudlaContracts::Integration::HostInterface", Class.new do
      def initialize; end
      def available_users_for_user(_user); []; end
    end)
  end

  describe "GET /users/unmapped" do
    it "returns a successful response" do
      get unmapped_users_path
      expect(response).to have_http_status(:success)
    end

    it "displays unmapped users" do
      unmapped_user = create(:user, tudla_user_id: nil)
      mapped_user = create(:user, tudla_user_id: 123)

      get unmapped_users_path

      expect(response.body).to include(unmapped_user.name)
      expect(response.body).not_to include(mapped_user.name)
    end

    context "with pagination" do
      before do
        25.times { |i| create(:user, tudla_user_id: nil, name: "User #{i.to_s.rjust(2, '0')}") }
      end

      it "paginates results with 20 per page" do
        get unmapped_users_path

        expect(response.body).to include("User 00")
        expect(response.body).to include("User 19")
        expect(response.body).not_to include("User 20")
      end

      it "shows second page when requested" do
        get unmapped_users_path(page: 2)

        expect(response.body).not_to include("User 00")
        expect(response.body).to include("User 20")
      end
    end
  end

  describe "GET /users/available_tudla_users" do
    let(:tudla_users) do
      15.times.map { |i| Struct.new(:id, :name, :email).new(i + 1, "Tudla User #{i}", "user#{i}@example.com") }
    end

    before do
      mock_interface = Class.new do
        define_method(:initialize) { }
        define_method(:available_users_for_user) { |_user| @users }
        attr_accessor :users
      end
      instance = mock_interface.new
      instance.users = tudla_users
      stub_const("TudlaContracts::Integration::HostInterface", Class.new do
        define_method(:initialize) { }
        define_method(:available_users_for_user) { |_user| instance.users }
      end)
    end

    it "returns JSON with paginated users" do
      get available_tudla_users_users_path, as: :json

      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)
      expect(json["users"].length).to eq(10)
      expect(json["current_page"]).to eq(1)
      expect(json["total_pages"]).to eq(2)
      expect(json["total_count"]).to eq(15)
    end

    it "returns second page of users" do
      get available_tudla_users_users_path(page: 2), as: :json

      json = JSON.parse(response.body)
      expect(json["users"].length).to eq(5)
      expect(json["current_page"]).to eq(2)
    end

    it "filters users by name" do
      get available_tudla_users_users_path(name: "User 1"), as: :json

      json = JSON.parse(response.body)
      expect(json["users"].all? { |u| u["name"].downcase.include?("user 1") }).to be true
    end
  end

  describe "PATCH /users/:id/map_tudla_user" do
    let!(:user) { create(:user, tudla_user_id: nil) }

    it "updates the user with tudla_user_id" do
      patch map_tudla_user_user_path(user), params: { tudla_user_id: 456 }

      expect(response).to redirect_to(unmapped_users_path)
      expect(user.reload.tudla_user_id).to eq(456)
    end

    it "removes user from unmapped list via turbo_stream" do
      patch map_tudla_user_user_path(user), params: { tudla_user_id: 456 }, as: :turbo_stream

      expect(response).to have_http_status(:success)
      expect(response.body).to include("turbo-stream")
      expect(response.body).to include("remove")
    end
  end
end
