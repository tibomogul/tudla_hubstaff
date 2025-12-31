require "rails_helper"

module TudlaHubstaff
  RSpec.describe SyncProjectsService do
    let(:api_client) { instance_double(ApiClient) }
    let(:service) { described_class.new(api_client) }

    describe "#call" do
      context "when API returns projects without pagination" do
        let(:api_response) do
          JSON.parse(File.read(Rails.root.join("../../spec/fixtures/api_responses/api_client_projects.json")))
        end

        before do
          allow(api_client).to receive(:projects).with(page_start_id: nil).and_return(api_response)
        end

        it "creates new projects from the API response" do
          expect { service.call }.to change { Project.count }.by(18)
        end

        it "returns success with total synced count" do
          result = service.call
          expect(result[:success]).to be true
          expect(result[:total_synced]).to eq(18)
        end

        it "stores the correct project_id from the API id field" do
          service.call
          project = Project.find_by(project_id: 934607)
          expect(project).to be_present
          expect(project.name).to eq("Project Alpha")
        end

        it "stores all project attributes correctly" do
          service.call
          project = Project.find_by(project_id: 2618526)
          expect(project.name).to eq("General & Admin")
          expect(project.status).to eq("active")
          expect(project.project_type).to eq("project")
          expect(project.client_id).to eq(335346)
          expect(project.metadata).to eq({})
        end

        it "handles nil client_id" do
          service.call
          project = Project.find_by(project_id: 934607)
          expect(project.client_id).to be_nil
        end

        it "stores billable and non-billable projects" do
          service.call
          billable_project = Project.find_by(project_id: 934607)
          non_billable_project = Project.find_by(project_id: 934649)

          expect(billable_project).to be_present
          expect(non_billable_project).to be_present
        end
      end

      context "when API returns paginated results" do
        let(:first_page_response) do
          {
            "projects" => [
              {
                "id" => 1,
                "name" => "Test Project One",
                "created_at" => "2020-01-01T00:00:00Z",
                "updated_at" => "2020-01-01T00:00:00Z",
                "status" => "active",
                "type" => "project",
                "billable" => true,
                "metadata" => {}
              }
            ],
            "pagination" => {
              "next_page_start_id" => 200
            }
          }
        end

        let(:second_page_response) do
          {
            "projects" => [
              {
                "id" => 2,
                "name" => "Test Project Two",
                "created_at" => "2020-01-02T00:00:00Z",
                "updated_at" => "2020-01-02T00:00:00Z",
                "status" => "active",
                "type" => "project",
                "billable" => false,
                "metadata" => {}
              }
            ]
          }
        end

        before do
          allow(api_client).to receive(:projects).with(page_start_id: nil).and_return(first_page_response)
          allow(api_client).to receive(:projects).with(page_start_id: 200).and_return(second_page_response)
        end

        it "fetches all pages until no next_page_start_id" do
          expect(api_client).to receive(:projects).with(page_start_id: nil).once
          expect(api_client).to receive(:projects).with(page_start_id: 200).once
          service.call
        end

        it "creates projects from all pages" do
          expect { service.call }.to change { Project.count }.by(2)
        end

        it "returns total synced count from all pages" do
          result = service.call
          expect(result[:total_synced]).to eq(2)
        end
      end

      context "when updating existing projects" do
        let!(:existing_project) do
          Project.create!(
            project_id: 934607,
            name: "Old Project Name",
            status: "active",
            project_type: "project"
          )
        end

        let(:api_response) do
          {
            "projects" => [
              {
                "id" => 934607,
                "name" => "Project Alpha Updated",
                "created_at" => "2020-03-13T01:30:29.615323Z",
                "updated_at" => "2025-12-31T03:00:49.993897Z",
                "status" => "archived",
                "type" => "work_order",
                "client_id" => 12345,
                "billable" => true,
                "metadata" => { "key" => "value" }
              }
            ]
          }
        end

        before do
          allow(api_client).to receive(:projects).with(page_start_id: nil).and_return(api_response)
        end

        it "updates existing project without creating a new one" do
          expect { service.call }.not_to change { Project.count }
        end

        it "updates the project attributes" do
          service.call
          existing_project.reload
          expect(existing_project.name).to eq("Project Alpha Updated")
          expect(existing_project.status).to eq("archived")
          expect(existing_project.project_type).to eq("work_order")
          expect(existing_project.client_id).to eq(12345)
          expect(existing_project.metadata).to eq({ "key" => "value" })
        end
      end

      context "when metadata is nil in API response" do
        let(:api_response) do
          {
            "projects" => [
              {
                "id" => 999,
                "name" => "Test Project",
                "status" => "active",
                "type" => "project",
                "metadata" => nil
              }
            ]
          }
        end

        before do
          allow(api_client).to receive(:projects).with(page_start_id: nil).and_return(api_response)
        end

        it "handles nil metadata by setting it to empty hash" do
          service.call
          project = Project.find_by(project_id: 999)
          expect(project.metadata).to eq({})
        end
      end

      context "when handling last_updated_at for optimistic updates" do
        let!(:existing_project) do
          Project.create!(
            project_id: 888,
            name: "Test Project",
            status: "active",
            project_type: "project",
            last_updated_at: Time.parse("2023-01-15T10:00:00Z")
          )
        end

        context "when API updated_at is newer than record last_updated_at" do
          let(:api_response) do
            {
              "projects" => [
                {
                  "id" => 888,
                  "name" => "Updated Project Name",
                  "status" => "archived",
                  "type" => "work_order",
                  "updated_at" => "2023-01-20T10:00:00Z"
                }
              ]
            }
          end

          before do
            allow(api_client).to receive(:projects).with(page_start_id: nil).and_return(api_response)
          end

          it "updates the record" do
            service.call
            existing_project.reload
            expect(existing_project.name).to eq("Updated Project Name")
            expect(existing_project.status).to eq("archived")
            expect(existing_project.project_type).to eq("work_order")
          end

          it "updates last_updated_at to API value" do
            service.call
            existing_project.reload
            expect(existing_project.last_updated_at).to eq(Time.parse("2023-01-20T10:00:00Z"))
          end
        end

        context "when API updated_at is older than record last_updated_at" do
          let(:api_response) do
            {
              "projects" => [
                {
                  "id" => 888,
                  "name" => "Stale Project Name",
                  "status" => "inactive",
                  "type" => "milestone",
                  "updated_at" => "2023-01-10T10:00:00Z"
                }
              ]
            }
          end

          before do
            allow(api_client).to receive(:projects).with(page_start_id: nil).and_return(api_response)
          end

          it "does not update the record" do
            service.call
            existing_project.reload
            expect(existing_project.name).to eq("Test Project")
            expect(existing_project.status).to eq("active")
            expect(existing_project.project_type).to eq("project")
          end

          it "does not change last_updated_at" do
            service.call
            existing_project.reload
            expect(existing_project.last_updated_at).to eq(Time.parse("2023-01-15T10:00:00Z"))
          end
        end

        context "when API updated_at is equal to record last_updated_at" do
          let(:api_response) do
            {
              "projects" => [
                {
                  "id" => 888,
                  "name" => "Same Time Name",
                  "status" => "archived",
                  "type" => "milestone",
                  "updated_at" => "2023-01-15T10:00:00Z"
                }
              ]
            }
          end

          before do
            allow(api_client).to receive(:projects).with(page_start_id: nil).and_return(api_response)
          end

          it "does not update the record" do
            service.call
            existing_project.reload
            expect(existing_project.name).to eq("Test Project")
            expect(existing_project.status).to eq("active")
          end
        end

        context "when record has no last_updated_at" do
          let!(:project_without_timestamp) do
            Project.create!(
              project_id: 777,
              name: "No Timestamp Project",
              status: "active",
              project_type: "project",
              last_updated_at: nil
            )
          end

          let(:api_response) do
            {
              "projects" => [
                {
                  "id" => 777,
                  "name" => "Updated No Timestamp",
                  "status" => "archived",
                  "type" => "work_order",
                  "updated_at" => "2023-01-20T10:00:00Z"
                }
              ]
            }
          end

          before do
            allow(api_client).to receive(:projects).with(page_start_id: nil).and_return(api_response)
          end

          it "updates the record" do
            service.call
            project_without_timestamp.reload
            expect(project_without_timestamp.name).to eq("Updated No Timestamp")
            expect(project_without_timestamp.status).to eq("archived")
          end
        end
      end
    end
  end
end
