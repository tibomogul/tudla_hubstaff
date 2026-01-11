require "rails_helper"
require_relative "../../../../app/components/tudla_hubstaff/ui"
require_relative "../../../../app/components/tudla_hubstaff/base_component"
require_relative "../../../../app/components/tudla_hubstaff/ui/modal_component"

RSpec.describe TudlaHubstaff::UI::ModalComponent, type: :component do
  it "renders with required id" do
    render_inline(described_class.new(id: "test-modal"))

    expect(page).to have_css("#test-modal")
    expect(page).to have_css(".tudla_hubstaff-modal")
  end

  it "renders with title" do
    render_inline(described_class.new(id: "test-modal", title: "Test Title"))

    expect(page).to have_text("Test Title")
  end

  it "renders with stimulus controller data attributes" do
    render_inline(described_class.new(id: "test-modal", stimulus_controller: "user-mapping-modal"))

    # Check that the modal has the stimulus target attribute
    expect(page).to have_css("#test-modal[data-user-mapping-modal-target]")
  end

  it "renders header slot when provided" do
    render_inline(described_class.new(id: "test-modal")) do |component|
      component.with_header { "Custom Header" }
    end

    expect(page).to have_text("Custom Header")
  end

  it "renders body slot when provided" do
    render_inline(described_class.new(id: "test-modal")) do |component|
      component.with_body { "Custom Body Content" }
    end

    expect(page).to have_text("Custom Body Content")
  end

  it "renders footer slot when provided" do
    render_inline(described_class.new(id: "test-modal")) do |component|
      component.with_footer { "Custom Footer" }
    end

    expect(page).to have_text("Custom Footer")
  end
end
