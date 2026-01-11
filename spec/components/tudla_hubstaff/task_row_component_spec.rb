require "rails_helper"
require_relative "../../../app/components/tudla_hubstaff/ui"
require_relative "../../../app/components/tudla_hubstaff/base_component"
require_relative "../../../app/components/tudla_hubstaff/ui/status_badge_component"
require_relative "../../../app/components/tudla_hubstaff/task_row_component"

RSpec.describe TudlaHubstaff::TaskRowComponent, type: :component do
  let(:task) do
    double(
      "Task",
      id: 456,
      summary: "Complete project setup",
      details: "This is a detailed description of the task that should be truncated",
      project_type: "development",
      status: "active"
    )
  end

  it "renders the task row" do
    render_inline(described_class.new(task: task))

    expect(page).to have_css("tr#tudla_hubstaff_task_456")
    expect(page).to have_text("Complete project setup")
    expect(page).to have_text("development")
  end

  it "truncates long details" do
    render_inline(described_class.new(task: task))

    expect(page).to have_text("This is a detailed description of the task that...")
  end

  it "renders the status badge component" do
    render_inline(described_class.new(task: task))

    expect(page).to have_css(".tudla_hubstaff-status-badge")
    expect(page).to have_text("active")
  end

  it "renders the map button with correct data attributes" do
    render_inline(described_class.new(task: task))

    expect(page).to have_button("Map to Tudla Task")
    expect(page).to have_css("[data-task-id='456']")
    expect(page).to have_css("[data-task-name='Complete project setup']")
  end

  it "has the component CSS class" do
    render_inline(described_class.new(task: task))

    expect(page).to have_css("tr.tudla_hubstaff-task-row")
  end
end
