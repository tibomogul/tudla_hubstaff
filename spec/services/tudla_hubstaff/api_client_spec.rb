require "rails_helper"

module TudlaHubstaff
  RSpec.describe ApiClient do
    let(:organization_id) { 12345 }
    let(:connection) { instance_double(Faraday::Connection) }
    let(:api_client) { described_class.new(organization_id, connection) }
    let(:response) { instance_double(Faraday::Response, body: { "tasks" => [] }) }
    let(:params_hash) { {} }
    let(:request) { instance_double(Faraday::Request, params: params_hash) }

    describe "#tasks" do
      before do
        allow(connection).to receive(:get).and_yield(request).and_return(response)
      end

      context "when no status option is provided" do
        it "defaults status to 'active'" do
          api_client.tasks
          expect(params_hash["status"]).to eq("active")
        end
      end

      context "when status option is explicitly provided" do
        it "uses the provided status value" do
          api_client.tasks(status: "archived")
          expect(params_hash["status"]).to eq("archived")
        end

        it "allows status to be 'completed'" do
          api_client.tasks(status: "completed")
          expect(params_hash["status"]).to eq("completed")
        end

        it "allows status to be 'active'" do
          api_client.tasks(status: "active")
          expect(params_hash["status"]).to eq("active")
        end

        it "excludes status parameter when explicitly set to nil" do
          api_client.tasks(status: nil)
          expect(params_hash).not_to have_key("status")
        end
      end

      context "when page_start_id option is provided" do
        it "includes page_start_id in request params" do
          api_client.tasks(page_start_id: 12345)
          expect(params_hash["page_start_id"]).to eq(12345)
        end

        it "includes both page_start_id and default status" do
          api_client.tasks(page_start_id: 12345)
          expect(params_hash["page_start_id"]).to eq(12345)
          expect(params_hash["status"]).to eq("active")
        end
      end

      context "when page_limit option is provided" do
        it "includes page_limit in request params" do
          api_client.tasks(page_limit: 50)
          expect(params_hash["page_limit"]).to eq(50)
        end
      end

      context "when project_ids option is provided" do
        it "includes project_ids as comma-separated string in request params" do
          api_client.tasks(project_ids: [ 100, 200, 300 ])
          expect(params_hash["project_ids"]).to eq("100,200,300")
        end

        it "includes single project_id" do
          api_client.tasks(project_ids: [ 999 ])
          expect(params_hash["project_ids"]).to eq("999")
        end
      end

      context "when multiple options are provided" do
        it "includes all provided options plus default status" do
          api_client.tasks(
            page_start_id: 100,
            page_limit: 25,
            project_ids: [ 1, 2, 3 ]
          )

          expect(params_hash["page_start_id"]).to eq(100)
          expect(params_hash["page_limit"]).to eq(25)
          expect(params_hash["project_ids"]).to eq("1,2,3")
          expect(params_hash["status"]).to eq("active")
        end

        it "overrides default status when explicitly provided with other options" do
          api_client.tasks(
            page_start_id: 100,
            status: "archived",
            project_ids: [ 1, 2 ]
          )

          expect(params_hash["status"]).to eq("archived")
        end

        it "excludes status when nil with other options" do
          api_client.tasks(
            page_start_id: 200,
            status: nil,
            page_limit: 50
          )

          expect(params_hash["page_start_id"]).to eq(200)
          expect(params_hash["page_limit"]).to eq(50)
          expect(params_hash).not_to have_key("status")
        end
      end

      it "calls the correct API endpoint" do
        api_client.tasks
        expect(connection).to have_received(:get).with("v2/organizations/#{organization_id}/tasks")
      end

      it "returns the response body" do
        expect(api_client.tasks).to eq({ "tasks" => [] })
      end
    end
  end
end
