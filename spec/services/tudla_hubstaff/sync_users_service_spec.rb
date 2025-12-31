require "rails_helper"

module TudlaHubstaff
  RSpec.describe SyncUsersService do
    let(:api_client) { instance_double(ApiClient) }
    let(:service) { described_class.new(api_client) }

    describe "#call" do
      context "when API returns users without pagination" do
        let(:api_response) do
          JSON.parse(File.read(Rails.root.join("../../spec/fixtures/api_responses/api_client_members.json")))
        end

        before do
          allow(api_client).to receive(:members).with(page_start_id: nil).and_return(api_response)
        end

        it "creates new users from the API response" do
          expect { service.call }.to change { User.count }.by(10)
        end

        it "returns success with total synced count" do
          result = service.call
          expect(result[:success]).to be true
          expect(result[:total_synced]).to eq(10)
        end

        it "stores the correct user_id from the API id field" do
          service.call
          user = User.find_by(user_id: 797867)
          expect(user).to be_present
          expect(user.name).to eq("Alice Anderson")
          expect(user.email).to eq("alice.anderson@example.com")
        end

        it "stores all user attributes correctly" do
          service.call
          user = User.find_by(user_id: 3131898)
          expect(user.name).to eq("Henry Harris")
          expect(user.first_name).to eq("Henry")
          expect(user.last_name).to eq("Harris")
          expect(user.email).to eq("henry.harris@example.com")
          expect(user.time_zone).to eq("Australia/Brisbane")
          expect(user.ip_address).to eq("180.181.214.167")
          expect(user.status).to eq("active")
        end

        it "handles nil ip_address" do
          service.call
          user = User.find_by(user_id: 3272471)
          expect(user.ip_address).to be_nil
        end
      end

      context "when API returns paginated results" do
        let(:first_page_response) do
          {
            "users" => [
              {
                "id" => 1,
                "name" => "User One",
                "first_name" => "User",
                "last_name" => "One",
                "email" => "user1@example.com",
                "time_zone" => "UTC",
                "ip_address" => "1.1.1.1",
                "status" => "active"
              }
            ],
            "pagination" => {
              "next_page_start_id" => 100
            }
          }
        end

        let(:second_page_response) do
          {
            "users" => [
              {
                "id" => 2,
                "name" => "User Two",
                "first_name" => "User",
                "last_name" => "Two",
                "email" => "user2@example.com",
                "time_zone" => "UTC",
                "ip_address" => "2.2.2.2",
                "status" => "active"
              }
            ]
          }
        end

        before do
          allow(api_client).to receive(:members).with(page_start_id: nil).and_return(first_page_response)
          allow(api_client).to receive(:members).with(page_start_id: 100).and_return(second_page_response)
        end

        it "fetches all pages until no next_page_start_id" do
          expect(api_client).to receive(:members).with(page_start_id: nil).once
          expect(api_client).to receive(:members).with(page_start_id: 100).once
          service.call
        end

        it "creates users from all pages" do
          expect { service.call }.to change { User.count }.by(2)
        end

        it "returns total synced count from all pages" do
          result = service.call
          expect(result[:total_synced]).to eq(2)
        end
      end

      context "when updating existing users" do
        let!(:existing_user) do
          User.create!(
            user_id: 797867,
            name: "Old Name",
            first_name: "Old",
            last_name: "Name",
            email: "old@example.com",
            time_zone: "UTC",
            status: "active"
          )
        end

        let(:api_response) do
          {
            "users" => [
              {
                "id" => 797867,
                "name" => "Alice Anderson Updated",
                "first_name" => "Alice",
                "last_name" => "Anderson Updated",
                "email" => "alice.updated@example.com",
                "time_zone" => "Australia/Perth",
                "ip_address" => "115.131.137.162",
                "status" => "active"
              }
            ]
          }
        end

        before do
          allow(api_client).to receive(:members).with(page_start_id: nil).and_return(api_response)
        end

        it "updates existing user without creating a new one" do
          expect { service.call }.not_to change { User.count }
        end

        it "updates the user attributes" do
          service.call
          existing_user.reload
          expect(existing_user.name).to eq("Alice Anderson Updated")
          expect(existing_user.email).to eq("alice.updated@example.com")
          expect(existing_user.time_zone).to eq("Australia/Perth")
          expect(existing_user.ip_address).to eq("115.131.137.162")
        end
      end

      context "when handling last_updated_at for optimistic updates" do
        let!(:existing_user) do
          User.create!(
            user_id: 999,
            name: "Test User",
            first_name: "Test",
            last_name: "User",
            email: "test@example.com",
            status: "active",
            last_updated_at: Time.parse("2023-01-15T10:00:00Z")
          )
        end

        context "when API updated_at is newer than record last_updated_at" do
          let(:api_response) do
            {
              "users" => [
                {
                  "id" => 999,
                  "name" => "Updated Name",
                  "first_name" => "Updated",
                  "last_name" => "Name",
                  "email" => "updated@example.com",
                  "time_zone" => "UTC",
                  "status" => "active",
                  "updated_at" => "2023-01-20T10:00:00Z"
                }
              ]
            }
          end

          before do
            allow(api_client).to receive(:members).with(page_start_id: nil).and_return(api_response)
          end

          it "updates the record" do
            service.call
            existing_user.reload
            expect(existing_user.name).to eq("Updated Name")
            expect(existing_user.email).to eq("updated@example.com")
          end

          it "updates last_updated_at to API value" do
            service.call
            existing_user.reload
            expect(existing_user.last_updated_at).to eq(Time.parse("2023-01-20T10:00:00Z"))
          end
        end

        context "when API updated_at is older than record last_updated_at" do
          let(:api_response) do
            {
              "users" => [
                {
                  "id" => 999,
                  "name" => "Stale Name",
                  "first_name" => "Stale",
                  "last_name" => "Name",
                  "email" => "stale@example.com",
                  "time_zone" => "UTC",
                  "status" => "inactive",
                  "updated_at" => "2023-01-10T10:00:00Z"
                }
              ]
            }
          end

          before do
            allow(api_client).to receive(:members).with(page_start_id: nil).and_return(api_response)
          end

          it "does not update the record" do
            service.call
            existing_user.reload
            expect(existing_user.name).to eq("Test User")
            expect(existing_user.email).to eq("test@example.com")
            expect(existing_user.status).to eq("active")
          end

          it "does not change last_updated_at" do
            service.call
            existing_user.reload
            expect(existing_user.last_updated_at).to eq(Time.parse("2023-01-15T10:00:00Z"))
          end
        end

        context "when API updated_at is equal to record last_updated_at" do
          let(:api_response) do
            {
              "users" => [
                {
                  "id" => 999,
                  "name" => "Same Time Name",
                  "first_name" => "Same Time",
                  "last_name" => "Name",
                  "email" => "sametime@example.com",
                  "time_zone" => "UTC",
                  "status" => "inactive",
                  "updated_at" => "2023-01-15T10:00:00Z"
                }
              ]
            }
          end

          before do
            allow(api_client).to receive(:members).with(page_start_id: nil).and_return(api_response)
          end

          it "does not update the record" do
            service.call
            existing_user.reload
            expect(existing_user.name).to eq("Test User")
            expect(existing_user.email).to eq("test@example.com")
          end
        end

        context "when record has no last_updated_at" do
          let!(:user_without_timestamp) do
            User.create!(
              user_id: 888,
              name: "No Timestamp User",
              first_name: "No Timestamp",
              last_name: "User",
              email: "notimestamp@example.com",
              status: "active",
              last_updated_at: nil
            )
          end

          let(:api_response) do
            {
              "users" => [
                {
                  "id" => 888,
                  "name" => "Updated No Timestamp",
                  "first_name" => "Updated No",
                  "last_name" => "Timestamp",
                  "email" => "updated.notimestamp@example.com",
                  "time_zone" => "UTC",
                  "status" => "active",
                  "updated_at" => "2023-01-20T10:00:00Z"
                }
              ]
            }
          end

          before do
            allow(api_client).to receive(:members).with(page_start_id: nil).and_return(api_response)
          end

          it "updates the record" do
            service.call
            user_without_timestamp.reload
            expect(user_without_timestamp.name).to eq("Updated No Timestamp")
            expect(user_without_timestamp.email).to eq("updated.notimestamp@example.com")
          end
        end
      end
    end
  end
end
