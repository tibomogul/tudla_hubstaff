require "rails_helper"
require_relative "../../../../app/components/tudla_hubstaff/ui"
require_relative "../../../../app/components/tudla_hubstaff/base_component"
require_relative "../../../../app/components/tudla_hubstaff/ui/pagination_component"

RSpec.describe TudlaHubstaff::UI::PaginationComponent, type: :component do
  let(:default_params) do
    {
      current_page: 2,
      total_pages: 5,
      total_count: 100,
      per_page: 20,
      path_helper: :unmapped_users_path,
      path_params: {}
    }
  end

  it "renders pagination when total_pages > 1" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css(".tudla_hubstaff-pagination")
  end

  it "does not render when total_pages is 1" do
    params = default_params.merge(total_pages: 1)
    render_inline(described_class.new(**params))

    expect(page).not_to have_css(".tudla_hubstaff-pagination")
  end

  it "shows correct item range" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_text("Showing")
    expect(page).to have_text("21")
    expect(page).to have_text("40")
    expect(page).to have_text("100")
  end

  it "shows Previous link when not on first page" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_link("Previous")
  end

  it "shows Next link when not on last page" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_link("Next")
  end

  it "hides Previous link on first page" do
    params = default_params.merge(current_page: 1)
    render_inline(described_class.new(**params))

    expect(page).not_to have_link("Previous")
  end

  it "hides Next link on last page" do
    params = default_params.merge(current_page: 5)
    render_inline(described_class.new(**params))

    expect(page).not_to have_link("Next")
  end
end
