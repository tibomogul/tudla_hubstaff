require "rails_helper"

module TudlaHubstaff
  RSpec.describe SyncActivitiesService do
    let(:api_client) { instance_double(ApiClient) }
    let(:start_time) { "2025-12-22" }
    let(:stop_time) { "2025-12-22" }
    let(:service) { described_class.new(api_client, start_time, stop_time) }

    describe "#call" do
      context "when API returns activities without pagination" do
        let(:api_response) do
          {
            "daily_activities" => [
              {
                "id" => 16741610615,
                "date" => "2025-12-22",
                "user_id" => 800171,
                "project_id" => 934649,
                "task_id" => nil,
                "keyboard" => 0,
                "mouse" => 0,
                "overall" => 0,
                "tracked" => 2481,
                "input_tracked" => 0,
                "manual" => 0,
                "idle" => 996,
                "resumed" => 0,
                "billable" => 0,
                "work_break" => 0,
                "created_at" => "2025-12-21T23:07:58.640657Z",
                "updated_at" => "2025-12-21T23:35:05.481463Z"
              },
              {
                "id" => 16741633069,
                "date" => "2025-12-22",
                "user_id" => 3315941,
                "project_id" => 934608,
                "task_id" => 153043446,
                "keyboard" => 100,
                "mouse" => 200,
                "overall" => 250,
                "tracked" => 2489,
                "input_tracked" => 300,
                "manual" => 50,
                "idle" => 0,
                "resumed" => 0,
                "billable" => 2489,
                "work_break" => 0,
                "created_at" => "2025-12-21T23:15:36.675005Z",
                "updated_at" => "2025-12-22T19:46:29.589531Z"
              }
            ]
          }
        end

        before do
          allow(api_client).to receive(:daily_activities_by_date)
            .with(start_time, stop_time, page_start_id: nil)
            .and_return(api_response)
        end

        it "creates new activities from the API response" do
          expect { service.call }.to change { Activity.count }.by(2)
        end

        it "returns success with total synced count" do
          result = service.call
          expect(result[:success]).to be true
          expect(result[:total_synced]).to eq(2)
        end

        it "stores the correct activity_id from the API id field" do
          service.call
          activity = Activity.find_by(activity_id: 16741610615)
          expect(activity).to be_present
          expect(activity.date).to eq("2025-12-22")
          expect(activity.user_id).to eq(800171)
        end

        it "stores all activity attributes correctly" do
          service.call
          activity = Activity.find_by(activity_id: 16741633069)
          expect(activity.activity_id).to eq(16741633069)
          expect(activity.date).to eq("2025-12-22")
          expect(activity.user_id).to eq(3315941)
          expect(activity.project_id).to eq(934608)
          expect(activity.task_id).to eq(153043446)
          expect(activity.keyboard).to eq(100)
          expect(activity.mouse).to eq(200)
          expect(activity.overall).to eq(250)
          expect(activity.tracked).to eq(2489)
          expect(activity.input_tracked).to eq(300)
          expect(activity.manual).to eq(50)
          expect(activity.idle).to eq(0)
          expect(activity.resumed).to eq(0)
          expect(activity.billable).to eq(2489)
          expect(activity.work_break).to eq(0)
        end

        it "handles nil task_id" do
          service.call
          activity = Activity.find_by(activity_id: 16741610615)
          expect(activity.task_id).to be_nil
        end

        it "stores last_updated_at from API updated_at" do
          service.call
          activity = Activity.find_by(activity_id: 16741633069)
          expect(activity.last_updated_at).to eq(Time.parse("2025-12-22T19:46:29.589531Z"))
        end
      end

      context "when API returns paginated results" do
        let(:first_page_response) do
          {
            "daily_activities" => [
              {
                "id" => 1,
                "date" => "2025-12-22",
                "user_id" => 100,
                "project_id" => 200,
                "keyboard" => 0,
                "mouse" => 0,
                "overall" => 0,
                "tracked" => 1000,
                "input_tracked" => 0,
                "manual" => 0,
                "idle" => 0,
                "resumed" => 0,
                "billable" => 0,
                "work_break" => 0,
                "updated_at" => "2025-12-22T10:00:00Z"
              }
            ],
            "pagination" => {
              "next_page_start_id" => 500
            }
          }
        end

        let(:second_page_response) do
          {
            "daily_activities" => [
              {
                "id" => 2,
                "date" => "2025-12-22",
                "user_id" => 100,
                "project_id" => 200,
                "keyboard" => 0,
                "mouse" => 0,
                "overall" => 0,
                "tracked" => 2000,
                "input_tracked" => 0,
                "manual" => 0,
                "idle" => 0,
                "resumed" => 0,
                "billable" => 0,
                "work_break" => 0,
                "updated_at" => "2025-12-22T11:00:00Z"
              }
            ]
          }
        end

        before do
          allow(api_client).to receive(:daily_activities_by_date)
            .with(start_time, stop_time, page_start_id: nil)
            .and_return(first_page_response)
          allow(api_client).to receive(:daily_activities_by_date)
            .with(start_time, stop_time, page_start_id: 500)
            .and_return(second_page_response)
        end

        it "fetches all pages until no next_page_start_id" do
          expect(api_client).to receive(:daily_activities_by_date)
            .with(start_time, stop_time, page_start_id: nil).once
          expect(api_client).to receive(:daily_activities_by_date)
            .with(start_time, stop_time, page_start_id: 500).once
          service.call
        end

        it "creates activities from all pages" do
          expect { service.call }.to change { Activity.count }.by(2)
        end

        it "returns total synced count from all pages" do
          result = service.call
          expect(result[:total_synced]).to eq(2)
        end
      end

      context "when updating existing activities" do
        let!(:existing_activity) do
          Activity.create!(
            activity_id: 16741610615,
            date: "2025-12-22",
            user_id: 800171,
            project_id: 934649,
            tracked: 1000,
            billable: 500
          )
        end

        let(:api_response) do
          {
            "daily_activities" => [
              {
                "id" => 16741610615,
                "date" => "2025-12-22",
                "user_id" => 800171,
                "project_id" => 934649,
                "task_id" => 12345,
                "keyboard" => 500,
                "mouse" => 600,
                "overall" => 800,
                "tracked" => 3000,
                "input_tracked" => 700,
                "manual" => 100,
                "idle" => 500,
                "resumed" => 50,
                "billable" => 2500,
                "work_break" => 200,
                "updated_at" => "2025-12-22T20:00:00Z"
              }
            ]
          }
        end

        before do
          allow(api_client).to receive(:daily_activities_by_date)
            .with(start_time, stop_time, page_start_id: nil)
            .and_return(api_response)
        end

        it "updates existing activity without creating a new one" do
          expect { service.call }.not_to change { Activity.count }
        end

        it "updates the activity attributes" do
          service.call
          existing_activity.reload
          expect(existing_activity.tracked).to eq(3000)
          expect(existing_activity.billable).to eq(2500)
          expect(existing_activity.keyboard).to eq(500)
          expect(existing_activity.mouse).to eq(600)
          expect(existing_activity.overall).to eq(800)
          expect(existing_activity.input_tracked).to eq(700)
          expect(existing_activity.manual).to eq(100)
          expect(existing_activity.idle).to eq(500)
          expect(existing_activity.resumed).to eq(50)
          expect(existing_activity.work_break).to eq(200)
          expect(existing_activity.task_id).to eq(12345)
        end
      end

      context "when handling last_updated_at for optimistic updates" do
        let!(:existing_activity) do
          Activity.create!(
            activity_id: 999,
            date: "2025-12-22",
            user_id: 100,
            tracked: 1000,
            last_updated_at: Time.parse("2023-01-15T10:00:00Z")
          )
        end

        context "when API updated_at is newer than record last_updated_at" do
          let(:api_response) do
            {
              "daily_activities" => [
                {
                  "id" => 999,
                  "date" => "2025-12-22",
                  "user_id" => 100,
                  "tracked" => 2000,
                  "billable" => 1500,
                  "updated_at" => "2023-01-20T10:00:00Z"
                }
              ]
            }
          end

          before do
            allow(api_client).to receive(:daily_activities_by_date)
              .with(start_time, stop_time, page_start_id: nil)
              .and_return(api_response)
          end

          it "updates the record" do
            service.call
            existing_activity.reload
            expect(existing_activity.tracked).to eq(2000)
            expect(existing_activity.billable).to eq(1500)
          end

          it "updates last_updated_at to API value" do
            service.call
            existing_activity.reload
            expect(existing_activity.last_updated_at).to eq(Time.parse("2023-01-20T10:00:00Z"))
          end
        end

        context "when API updated_at is older than record last_updated_at" do
          let(:api_response) do
            {
              "daily_activities" => [
                {
                  "id" => 999,
                  "date" => "2025-12-22",
                  "user_id" => 100,
                  "tracked" => 500,
                  "billable" => 200,
                  "updated_at" => "2023-01-10T10:00:00Z"
                }
              ]
            }
          end

          before do
            allow(api_client).to receive(:daily_activities_by_date)
              .with(start_time, stop_time, page_start_id: nil)
              .and_return(api_response)
          end

          it "does not update the record" do
            service.call
            existing_activity.reload
            expect(existing_activity.tracked).to eq(1000)
          end

          it "does not change last_updated_at" do
            service.call
            existing_activity.reload
            expect(existing_activity.last_updated_at).to eq(Time.parse("2023-01-15T10:00:00Z"))
          end
        end

        context "when API updated_at is equal to record last_updated_at" do
          let(:api_response) do
            {
              "daily_activities" => [
                {
                  "id" => 999,
                  "date" => "2025-12-22",
                  "user_id" => 100,
                  "tracked" => 3000,
                  "updated_at" => "2023-01-15T10:00:00Z"
                }
              ]
            }
          end

          before do
            allow(api_client).to receive(:daily_activities_by_date)
              .with(start_time, stop_time, page_start_id: nil)
              .and_return(api_response)
          end

          it "does not update the record" do
            service.call
            existing_activity.reload
            expect(existing_activity.tracked).to eq(1000)
          end
        end

        context "when record has no last_updated_at" do
          let!(:activity_without_timestamp) do
            Activity.create!(
              activity_id: 888,
              date: "2025-12-22",
              user_id: 100,
              tracked: 1000,
              last_updated_at: nil
            )
          end

          let(:api_response) do
            {
              "daily_activities" => [
                {
                  "id" => 888,
                  "date" => "2025-12-22",
                  "user_id" => 100,
                  "tracked" => 2000,
                  "billable" => 1500,
                  "updated_at" => "2023-01-20T10:00:00Z"
                }
              ]
            }
          end

          before do
            allow(api_client).to receive(:daily_activities_by_date)
              .with(start_time, stop_time, page_start_id: nil)
              .and_return(api_response)
          end

          it "updates the record" do
            service.call
            activity_without_timestamp.reload
            expect(activity_without_timestamp.tracked).to eq(2000)
            expect(activity_without_timestamp.billable).to eq(1500)
          end
        end
      end

      context "when handling nil values" do
        let(:api_response) do
          {
            "daily_activities" => [
              {
                "id" => 777,
                "date" => "2025-12-22",
                "user_id" => 100,
                "project_id" => nil,
                "task_id" => nil,
                "keyboard" => nil,
                "mouse" => nil,
                "overall" => nil,
                "tracked" => 1000,
                "input_tracked" => nil,
                "manual" => nil,
                "idle" => nil,
                "resumed" => nil,
                "billable" => nil,
                "work_break" => nil,
                "updated_at" => "2025-12-22T10:00:00Z"
              }
            ]
          }
        end

        before do
          allow(api_client).to receive(:daily_activities_by_date)
            .with(start_time, stop_time, page_start_id: nil)
            .and_return(api_response)
        end

        it "handles nil values by setting them to 0" do
          service.call
          activity = Activity.find_by(activity_id: 777)
          expect(activity.project_id).to be_nil
          expect(activity.task_id).to be_nil
          expect(activity.keyboard).to eq(0)
          expect(activity.mouse).to eq(0)
          expect(activity.overall).to eq(0)
          expect(activity.input_tracked).to eq(0)
          expect(activity.manual).to eq(0)
          expect(activity.idle).to eq(0)
          expect(activity.resumed).to eq(0)
          expect(activity.billable).to eq(0)
          expect(activity.work_break).to eq(0)
        end
      end
    end
  end
end
