require "rails_helper"

module TudlaHubstaff
  RSpec.describe FetchUpdatedActivitiesJob, type: :job do
    describe "#perform" do
      let(:current_time) { Time.zone.parse("2025-12-22T10:00:00Z") }
      let(:organization_id) { 12345 }
      let(:personal_access_token) { "test_token" }

      let!(:organization_update) do
        OrganizationUpdate.create!(
          organization_id: organization_id,
          last_updated_at: Time.zone.parse("2025-12-22T08:00:00Z")
        )
      end

      let(:config) do
        double("Config", organization_id: organization_id, personal_access_token: personal_access_token)
      end

      let(:connection) { instance_double(Faraday::Connection) }
      let(:api_connection) { instance_double(ApiConnection, connection: connection) }
      let(:api_client) { instance_double(ApiClient) }
      let(:service) { instance_double(FetchUpdatedActivitiesService) }

      before do
        allow(Time).to receive(:current).and_return(current_time)
        without_partial_double_verification do
          allow(Config).to receive(:find_by).with(organization_id: organization_id).and_return(config)
        end
        allow(ApiConnection).to receive(:new).with(personal_access_token).and_return(api_connection)
        allow(ApiClient).to receive(:new).with(organization_id, connection).and_return(api_client)
        allow(FetchUpdatedActivitiesService).to receive(:new).and_return(service)
        allow(service).to receive(:call).and_return({ success: true, total_synced: 5 })
      end

      it "calls FetchUpdatedActivitiesService with correct start_time and stop_time" do
        expect(FetchUpdatedActivitiesService).to receive(:new).with(
          api_client,
          "2025-12-22T08:00:00Z",
          "2025-12-22T10:00:00Z"
        ).and_return(service)

        described_class.new.perform
      end

      it "updates the organization_update last_updated_at to current time" do
        described_class.new.perform

        organization_update.reload
        expect(organization_update.last_updated_at).to eq(current_time)
      end

      it "builds the api_client using the config's personal_access_token" do
        expect(ApiConnection).to receive(:new).with(personal_access_token).and_return(api_connection)
        expect(ApiClient).to receive(:new).with(organization_id, connection).and_return(api_client)

        described_class.new.perform
      end

      context "when organization_update has no last_updated_at" do
        let!(:organization_update_without_timestamp) do
          OrganizationUpdate.create!(
            organization_id: 99999,
            last_updated_at: nil
          )
        end

        it "skips the organization_update and does not update its last_updated_at" do
          described_class.new.perform

          organization_update_without_timestamp.reload
          expect(organization_update_without_timestamp.last_updated_at).to be_nil
        end
      end

      context "when no config exists for the organization" do
        let!(:orphan_organization_update) do
          OrganizationUpdate.create!(
            organization_id: 88888,
            last_updated_at: Time.zone.parse("2025-12-22T08:00:00Z")
          )
        end

        before do
          without_partial_double_verification do
            allow(Config).to receive(:find_by).with(organization_id: 88888).and_return(nil)
          end
        end

        it "skips the organization_update without a config and does not update its last_updated_at" do
          described_class.new.perform

          orphan_organization_update.reload
          expect(orphan_organization_update.last_updated_at).to eq(Time.zone.parse("2025-12-22T08:00:00Z"))
        end
      end

      context "with multiple organization_updates" do
        let(:organization_id_2) { 67890 }

        let!(:organization_update_2) do
          OrganizationUpdate.create!(
            organization_id: organization_id_2,
            last_updated_at: Time.zone.parse("2025-12-22T06:00:00Z")
          )
        end

        let(:config_2) do
          double("Config", organization_id: organization_id_2, personal_access_token: "token_2")
        end

        let(:api_connection_2) { instance_double(ApiConnection, connection: connection) }
        let(:api_client_2) { instance_double(ApiClient) }

        before do
          without_partial_double_verification do
            allow(Config).to receive(:find_by).with(organization_id: organization_id_2).and_return(config_2)
          end
          allow(ApiConnection).to receive(:new).with("token_2").and_return(api_connection_2)
          allow(ApiClient).to receive(:new).with(organization_id_2, connection).and_return(api_client_2)
        end

        it "processes all organization_updates" do
          expect(FetchUpdatedActivitiesService).to receive(:new).with(
            api_client,
            "2025-12-22T08:00:00Z",
            "2025-12-22T10:00:00Z"
          ).and_return(service)

          expect(FetchUpdatedActivitiesService).to receive(:new).with(
            api_client_2,
            "2025-12-22T06:00:00Z",
            "2025-12-22T10:00:00Z"
          ).and_return(service)

          described_class.new.perform
        end

        it "updates last_updated_at for all organization_updates" do
          described_class.new.perform

          organization_update.reload
          organization_update_2.reload

          expect(organization_update.last_updated_at).to eq(current_time)
          expect(organization_update_2.last_updated_at).to eq(current_time)
        end
      end

      context "when service raises an error" do
        let(:failing_service) { instance_double(FetchUpdatedActivitiesService) }

        before do
          allow(FetchUpdatedActivitiesService).to receive(:new).and_return(failing_service)
          allow(failing_service).to receive(:call).and_raise(StandardError.new("API connection failed"))
          allow(Rails.logger).to receive(:error)
        end

        it "logs the error and does not update last_updated_at" do
          expect(Rails.logger).to receive(:error).with(/Failed to fetch updated activities for organization #{organization_id}/)
          expect(Rails.logger).to receive(:error).with(kind_of(String))

          described_class.new.perform

          organization_update.reload
          expect(organization_update.last_updated_at).to eq(Time.zone.parse("2025-12-22T08:00:00Z"))
        end

        it "continues processing other organization_updates after an error" do
          organization_id_2 = 55555
          organization_update_2 = OrganizationUpdate.create!(
            organization_id: organization_id_2,
            last_updated_at: Time.zone.parse("2025-12-22T07:00:00Z")
          )
          config_2 = double("Config", organization_id: organization_id_2, personal_access_token: "token_2")
          successful_service = instance_double(FetchUpdatedActivitiesService)

          without_partial_double_verification do
            allow(Config).to receive(:find_by).with(organization_id: organization_id_2).and_return(config_2)
          end
          allow(ApiConnection).to receive(:new).with("token_2").and_return(api_connection)
          allow(ApiClient).to receive(:new).with(organization_id_2, connection).and_return(api_client)

          call_count = 0
          allow(FetchUpdatedActivitiesService).to receive(:new) do
            call_count += 1
            if call_count == 1
              failing_service
            else
              successful_service
            end
          end
          allow(successful_service).to receive(:call).and_return({ success: true, total_synced: 3 })

          described_class.new.perform

          organization_update_2.reload
          expect(organization_update_2.last_updated_at).to eq(current_time)
        end
      end
    end
  end
end
