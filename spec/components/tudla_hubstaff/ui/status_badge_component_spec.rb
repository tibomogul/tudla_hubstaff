require "rails_helper"
require_relative "../../../../app/components/tudla_hubstaff/ui"
require_relative "../../../../app/components/tudla_hubstaff/base_component"
require_relative "../../../../app/components/tudla_hubstaff/ui/status_badge_component"

RSpec.describe TudlaHubstaff::UI::StatusBadgeComponent, type: :component do
  it "renders active status with green styling" do
    render_inline(described_class.new(status: "active"))

    expect(page).to have_css(".tudla_hubstaff-status-badge")
    expect(page).to have_css(".bg-green-100")
    expect(page).to have_text("active")
  end

  it "renders pending status with gray styling" do
    render_inline(described_class.new(status: "pending"))

    expect(page).to have_css(".bg-gray-100")
    expect(page).to have_text("pending")
  end

  it "renders default styling for unknown status" do
    render_inline(described_class.new(status: "unknown"))

    expect(page).to have_css(".bg-gray-100")
    expect(page).to have_text("unknown")
  end

  it "handles nil status gracefully" do
    render_inline(described_class.new(status: nil))

    expect(page).to have_text("pending")
  end
end
