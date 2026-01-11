require "rails_helper"
require_relative "../../../app/components/tudla_hubstaff/base_component"
require_relative "../../../app/components/tudla_hubstaff/task_activities_component"

RSpec.describe TudlaHubstaff::TaskActivitiesComponent, type: :component do
  let(:tudla_task_id) { 123 }
  let(:hubstaff_task_id) { 456 }

  before do
    # Create a task mapped to the tudla_task_id
    TudlaHubstaff::Task.create!(
      task_id: hubstaff_task_id,
      tudla_task_id: tudla_task_id,
      project_id: 1,
      project_type: "development",
      summary: "Test Task",
      status: "active"
    )
  end

  describe "#render?" do
    it "returns true when tudla_task_id is present" do
      component = described_class.new(tudla_task_id: tudla_task_id)
      expect(component.render?).to be true
    end

    it "returns false when tudla_task_id is nil" do
      component = described_class.new(tudla_task_id: nil)
      expect(component.render?).to be false
    end

    it "returns false when tudla_task_id is blank" do
      component = described_class.new(tudla_task_id: "")
      expect(component.render?).to be false
    end
  end

  describe "#activities" do
    it "returns activities for tasks mapped to the tudla_task_id" do
      activity = TudlaHubstaff::Activity.create!(
        activity_id: 1,
        date: "2024-01-15",
        user_id: 100,
        task_id: hubstaff_task_id,
        tracked: 3600,
        overall: 85,
        last_updated_at: Time.current
      )

      component = described_class.new(tudla_task_id: tudla_task_id)
      expect(component.activities).to include(activity)
    end

    it "does not return activities for other tasks" do
      other_activity = TudlaHubstaff::Activity.create!(
        activity_id: 2,
        date: "2024-01-15",
        user_id: 100,
        task_id: 999,
        tracked: 1800,
        overall: 50,
        last_updated_at: Time.current
      )

      component = described_class.new(tudla_task_id: tudla_task_id)
      expect(component.activities).not_to include(other_activity)
    end

    it "orders activities by last_updated_at descending" do
      older_activity = TudlaHubstaff::Activity.create!(
        activity_id: 1,
        date: "2024-01-14",
        user_id: 100,
        task_id: hubstaff_task_id,
        last_updated_at: 2.days.ago
      )

      newer_activity = TudlaHubstaff::Activity.create!(
        activity_id: 2,
        date: "2024-01-15",
        user_id: 100,
        task_id: hubstaff_task_id,
        last_updated_at: 1.day.ago
      )

      component = described_class.new(tudla_task_id: tudla_task_id)
      expect(component.activities.first).to eq(newer_activity)
      expect(component.activities.last).to eq(older_activity)
    end
  end

  describe "pagination" do
    before do
      25.times do |i|
        TudlaHubstaff::Activity.create!(
          activity_id: i + 1,
          date: "2024-01-15",
          user_id: 100,
          task_id: hubstaff_task_id,
          last_updated_at: i.hours.ago
        )
      end
    end

    it "returns correct total_count" do
      component = described_class.new(tudla_task_id: tudla_task_id)
      expect(component.total_count).to eq(25)
    end

    it "returns correct total_pages with default per_page" do
      component = described_class.new(tudla_task_id: tudla_task_id)
      expect(component.total_pages).to eq(2)
    end

    it "limits activities to per_page" do
      component = described_class.new(tudla_task_id: tudla_task_id, per_page: 10)
      expect(component.activities.count).to eq(10)
    end

    it "returns correct page of activities" do
      component = described_class.new(tudla_task_id: tudla_task_id, current_page: 2, per_page: 10)
      expect(component.activities.count).to eq(10)
    end

    it "shows previous link on page 2" do
      component = described_class.new(tudla_task_id: tudla_task_id, current_page: 2)
      expect(component.show_previous?).to be true
    end

    it "hides previous link on page 1" do
      component = described_class.new(tudla_task_id: tudla_task_id, current_page: 1)
      expect(component.show_previous?).to be false
    end

    it "shows next link when not on last page" do
      component = described_class.new(tudla_task_id: tudla_task_id, current_page: 1)
      expect(component.show_next?).to be true
    end

    it "hides next link on last page" do
      component = described_class.new(tudla_task_id: tudla_task_id, current_page: 2)
      expect(component.show_next?).to be false
    end
  end

  describe "#format_duration" do
    let(:component) { described_class.new(tudla_task_id: tudla_task_id) }

    it "formats seconds as hours and minutes" do
      expect(component.format_duration(3661)).to eq("1h 1m")
    end

    it "formats seconds as minutes only when less than an hour" do
      expect(component.format_duration(1800)).to eq("30m")
    end

    it "returns 0m for zero seconds" do
      expect(component.format_duration(0)).to eq("0m")
    end

    it "returns 0m for nil" do
      expect(component.format_duration(nil)).to eq("0m")
    end
  end

  describe "#format_date" do
    let(:component) { described_class.new(tudla_task_id: tudla_task_id) }

    it "formats date string" do
      expect(component.format_date("2024-01-15")).to eq("Jan 15, 2024")
    end

    it "returns empty string for blank date" do
      expect(component.format_date("")).to eq("")
    end

    it "returns original string for invalid date" do
      expect(component.format_date("invalid")).to eq("invalid")
    end
  end

  describe "rendering" do
    it "renders activities table when activities exist" do
      TudlaHubstaff::Activity.create!(
        activity_id: 1,
        date: "2024-01-15",
        user_id: 100,
        task_id: hubstaff_task_id,
        tracked: 3600,
        overall: 85,
        last_updated_at: Time.current
      )

      render_inline(described_class.new(tudla_task_id: tudla_task_id))

      expect(page).to have_css(".tudla_hubstaff-task-activities")
      expect(page).to have_css(".tudla_hubstaff-activity-row")
      expect(page).to have_text("Jan 15, 2024")
      expect(page).to have_text("1h 0m")
    end

    it "renders empty state when no activities" do
      render_inline(described_class.new(tudla_task_id: tudla_task_id))

      expect(page).to have_text("No activities found for this task.")
    end

    it "does not render when tudla_task_id is nil" do
      render_inline(described_class.new(tudla_task_id: nil))

      expect(page).not_to have_css(".tudla_hubstaff-task-activities")
    end
  end
end
