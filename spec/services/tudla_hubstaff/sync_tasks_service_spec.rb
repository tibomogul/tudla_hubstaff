require "rails_helper"

module TudlaHubstaff
  RSpec.describe SyncTasksService do
    let(:api_client) { instance_double(ApiClient) }
    let(:service) { described_class.new(api_client) }

    describe "#call" do
      context "when API returns tasks without pagination" do
        let(:api_response) do
          JSON.parse(File.read(Rails.root.join("../../spec/fixtures/api_responses/api_client_tasks.json")))
        end

        before do
          allow(api_client).to receive(:tasks).with(page_start_id: nil).and_return(api_response)
        end

        it "creates new tasks from the API response" do
          expect { service.call }.to change { Task.count }.by(15)
        end

        it "returns success with total synced count" do
          result = service.call
          expect(result[:success]).to be true
          expect(result[:total_synced]).to eq(15)
        end

        it "stores the correct task_id from the API id field" do
          service.call
          task = Task.find_by(task_id: 81064122)
          expect(task).to be_present
          expect(task.summary).to eq("Implement retry mechanism for timeout errors")
        end

        it "stores all task attributes correctly" do
          service.call
          task = Task.find_by(task_id: 81064167)
          expect(task.task_id).to eq(81064167)
          expect(task.integration_id).to eq(124819)
          expect(task.status).to eq("active")
          expect(task.project_id).to eq(934642)
          expect(task.project_type).to eq("project")
          expect(task.summary).to eq("Handle extension table fields correctly")
          expect(task.details).to include("The mobile app currently assumes")
          expect(task.remote_id).to eq("23878")
          expect(task.remote_alternate_id).to eq("TASK-769")
          expect(task.metadata).to eq({})
        end

        it "handles nil details" do
          service.call
          task = Task.find_by(task_id: 81064265)
          expect(task.details).to be_present
        end

        it "handles empty assignee_ids array" do
          service.call
          task = Task.find_by(task_id: 81064222)
          expect(task).to be_present
        end
      end

      context "when API returns paginated results" do
        let(:first_page_response) do
          {
            "tasks" => [
              {
                "id" => 1,
                "integration_id" => 100,
                "status" => "active",
                "project_id" => 500,
                "project_type" => "project",
                "summary" => "Test Task One",
                "details" => "Details for task one",
                "remote_id" => "R1",
                "remote_alternate_id" => "ALT-1",
                "metadata" => {}
              }
            ],
            "pagination" => {
              "next_page_start_id" => 300
            }
          }
        end

        let(:second_page_response) do
          {
            "tasks" => [
              {
                "id" => 2,
                "integration_id" => 100,
                "status" => "active",
                "project_id" => 500,
                "project_type" => "project",
                "summary" => "Test Task Two",
                "details" => "Details for task two",
                "remote_id" => "R2",
                "remote_alternate_id" => "ALT-2",
                "metadata" => {}
              }
            ]
          }
        end

        before do
          allow(api_client).to receive(:tasks).with(page_start_id: nil).and_return(first_page_response)
          allow(api_client).to receive(:tasks).with(page_start_id: 300).and_return(second_page_response)
        end

        it "fetches all pages until no next_page_start_id" do
          expect(api_client).to receive(:tasks).with(page_start_id: nil).once
          expect(api_client).to receive(:tasks).with(page_start_id: 300).once
          service.call
        end

        it "creates tasks from all pages" do
          expect { service.call }.to change { Task.count }.by(2)
        end

        it "returns total synced count from all pages" do
          result = service.call
          expect(result[:total_synced]).to eq(2)
        end
      end

      context "when updating existing tasks" do
        let!(:existing_task) do
          Task.create!(
            task_id: 81064122,
            project_id: 934642,
            project_type: "project",
            summary: "Old Summary"
          )
        end

        let(:api_response) do
          {
            "tasks" => [
              {
                "id" => 81064122,
                "integration_id" => 124819,
                "status" => "completed",
                "project_id" => 934642,
                "project_type" => "work_order",
                "summary" => "Updated Summary",
                "details" => "Updated details content",
                "remote_id" => "24164",
                "remote_alternate_id" => "TASK-857",
                "metadata" => { "updated" => true }
              }
            ]
          }
        end

        before do
          allow(api_client).to receive(:tasks).with(page_start_id: nil).and_return(api_response)
        end

        it "updates existing task without creating a new one" do
          expect { service.call }.not_to change { Task.count }
        end

        it "updates the task attributes" do
          service.call
          existing_task.reload
          expect(existing_task.summary).to eq("Updated Summary")
          expect(existing_task.status).to eq("completed")
          expect(existing_task.project_type).to eq("work_order")
          expect(existing_task.details).to eq("Updated details content")
          expect(existing_task.integration_id).to eq(124819)
          expect(existing_task.remote_id).to eq("24164")
          expect(existing_task.remote_alternate_id).to eq("TASK-857")
          expect(existing_task.metadata).to eq({ "updated" => true })
        end
      end

      context "when metadata is nil in API response" do
        let(:api_response) do
          {
            "tasks" => [
              {
                "id" => 999,
                "project_id" => 100,
                "project_type" => "project",
                "summary" => "Test Task",
                "metadata" => nil
              }
            ]
          }
        end

        before do
          allow(api_client).to receive(:tasks).with(page_start_id: nil).and_return(api_response)
        end

        it "handles nil metadata by setting it to empty hash" do
          service.call
          task = Task.find_by(task_id: 999)
          expect(task.metadata).to eq({})
        end
      end

      context "when details is nil in API response" do
        let(:api_response) do
          {
            "tasks" => [
              {
                "id" => 888,
                "project_id" => 100,
                "project_type" => "project",
                "summary" => "Task Without Details",
                "details" => nil,
                "metadata" => {}
              }
            ]
          }
        end

        before do
          allow(api_client).to receive(:tasks).with(page_start_id: nil).and_return(api_response)
        end

        it "handles nil details" do
          service.call
          task = Task.find_by(task_id: 888)
          expect(task.details).to be_nil
        end
      end

      context "when handling last_updated_at for optimistic updates" do
        let!(:existing_task) do
          Task.create!(
            task_id: 777,
            project_id: 100,
            project_type: "project",
            summary: "Test Task",
            last_updated_at: Time.parse("2023-01-15T10:00:00Z")
          )
        end

        context "when API updated_at is newer than record last_updated_at" do
          let(:api_response) do
            {
              "tasks" => [
                {
                  "id" => 777,
                  "project_id" => 100,
                  "project_type" => "work_order",
                  "summary" => "Updated Task Summary",
                  "status" => "completed",
                  "updated_at" => "2023-01-20T10:00:00Z"
                }
              ]
            }
          end

          before do
            allow(api_client).to receive(:tasks).with(page_start_id: nil).and_return(api_response)
          end

          it "updates the record" do
            service.call
            existing_task.reload
            expect(existing_task.summary).to eq("Updated Task Summary")
            expect(existing_task.status).to eq("completed")
            expect(existing_task.project_type).to eq("work_order")
          end

          it "updates last_updated_at to API value" do
            service.call
            existing_task.reload
            expect(existing_task.last_updated_at).to eq(Time.parse("2023-01-20T10:00:00Z"))
          end
        end

        context "when API updated_at is older than record last_updated_at" do
          let(:api_response) do
            {
              "tasks" => [
                {
                  "id" => 777,
                  "project_id" => 100,
                  "project_type" => "milestone",
                  "summary" => "Stale Task Summary",
                  "status" => "inactive",
                  "updated_at" => "2023-01-10T10:00:00Z"
                }
              ]
            }
          end

          before do
            allow(api_client).to receive(:tasks).with(page_start_id: nil).and_return(api_response)
          end

          it "does not update the record" do
            service.call
            existing_task.reload
            expect(existing_task.summary).to eq("Test Task")
            expect(existing_task.project_type).to eq("project")
          end

          it "does not change last_updated_at" do
            service.call
            existing_task.reload
            expect(existing_task.last_updated_at).to eq(Time.parse("2023-01-15T10:00:00Z"))
          end
        end

        context "when API updated_at is equal to record last_updated_at" do
          let(:api_response) do
            {
              "tasks" => [
                {
                  "id" => 777,
                  "project_id" => 100,
                  "project_type" => "milestone",
                  "summary" => "Same Time Task",
                  "status" => "completed",
                  "updated_at" => "2023-01-15T10:00:00Z"
                }
              ]
            }
          end

          before do
            allow(api_client).to receive(:tasks).with(page_start_id: nil).and_return(api_response)
          end

          it "does not update the record" do
            service.call
            existing_task.reload
            expect(existing_task.summary).to eq("Test Task")
            expect(existing_task.project_type).to eq("project")
          end
        end

        context "when record has no last_updated_at" do
          let!(:task_without_timestamp) do
            Task.create!(
              task_id: 666,
              project_id: 100,
              project_type: "project",
              summary: "No Timestamp Task",
              last_updated_at: nil
            )
          end

          let(:api_response) do
            {
              "tasks" => [
                {
                  "id" => 666,
                  "project_id" => 100,
                  "project_type" => "work_order",
                  "summary" => "Updated No Timestamp",
                  "status" => "completed",
                  "updated_at" => "2023-01-20T10:00:00Z"
                }
              ]
            }
          end

          before do
            allow(api_client).to receive(:tasks).with(page_start_id: nil).and_return(api_response)
          end

          it "updates the record" do
            service.call
            task_without_timestamp.reload
            expect(task_without_timestamp.summary).to eq("Updated No Timestamp")
            expect(task_without_timestamp.status).to eq("completed")
          end
        end
      end
    end
  end
end
