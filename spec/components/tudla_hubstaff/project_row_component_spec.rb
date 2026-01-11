require "rails_helper"
require_relative "../../../app/components/tudla_hubstaff/ui"
require_relative "../../../app/components/tudla_hubstaff/base_component"
require_relative "../../../app/components/tudla_hubstaff/ui/status_badge_component"
require_relative "../../../app/components/tudla_hubstaff/project_row_component"

RSpec.describe TudlaHubstaff::ProjectRowComponent, type: :component do
  let(:project) do
    double(
      "Project",
      id: 789,
      name: "Website Redesign",
      description: "A comprehensive redesign of the company website with modern UI",
      project_type: "web_development",
      status: "active"
    )
  end

  it "renders the project row" do
    render_inline(described_class.new(project: project))

    expect(page).to have_css("tr#tudla_hubstaff_project_789")
    expect(page).to have_text("Website Redesign")
  end

  it "truncates long descriptions" do
    render_inline(described_class.new(project: project))

    expect(page).to have_text("A comprehensive redesign of the company website...")
  end

  it "formats project type with titleize" do
    render_inline(described_class.new(project: project))

    expect(page).to have_text("Web Development")
  end

  it "renders the status badge component" do
    render_inline(described_class.new(project: project))

    expect(page).to have_css(".tudla_hubstaff-status-badge")
    expect(page).to have_text("active")
  end

  it "renders the map button with correct data attributes" do
    render_inline(described_class.new(project: project))

    expect(page).to have_button("Map to Tudla Project")
    expect(page).to have_css("[data-project-id='789']")
    expect(page).to have_css("[data-project-name='Website Redesign']")
  end

  it "has the component CSS class" do
    render_inline(described_class.new(project: project))

    expect(page).to have_css("tr.tudla_hubstaff-project-row")
  end
end
