require "rails_helper"
require_relative "../../../app/components/tudla_hubstaff/ui"
require_relative "../../../app/components/tudla_hubstaff/base_component"
require_relative "../../../app/components/tudla_hubstaff/ui/status_badge_component"
require_relative "../../../app/components/tudla_hubstaff/user_row_component"

RSpec.describe TudlaHubstaff::UserRowComponent, type: :component do
  let(:user) do
    double(
      "User",
      id: 123,
      name: "John Doe",
      first_name: "John",
      last_name: "Doe",
      email: "john@example.com",
      status: "active"
    )
  end

  it "renders the user row" do
    render_inline(described_class.new(user: user))

    expect(page).to have_css("tr#tudla_hubstaff_user_123")
    expect(page).to have_text("John Doe")
    expect(page).to have_text("john@example.com")
  end

  it "renders the status badge component" do
    render_inline(described_class.new(user: user))

    expect(page).to have_css(".tudla_hubstaff-status-badge")
    expect(page).to have_text("active")
  end

  it "renders the map button with correct data attributes" do
    render_inline(described_class.new(user: user))

    expect(page).to have_button("Map to Tudla User")
    expect(page).to have_css("[data-user-id='123']")
    expect(page).to have_css("[data-user-name='John Doe']")
  end

  it "has the component CSS class" do
    render_inline(described_class.new(user: user))

    expect(page).to have_css("tr.tudla_hubstaff-user-row")
  end
end
