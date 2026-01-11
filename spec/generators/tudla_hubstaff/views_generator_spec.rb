require "rails_helper"
require "rails/generators"
require "rails/generators/testing/behavior"
require "rails/generators/testing/setup_and_teardown"
require "fileutils"
require "generators/tudla_hubstaff/views_generator"

RSpec.describe TudlaHubstaff::Generators::ViewsGenerator, type: :generator do
  include Rails::Generators::Testing::Behavior
  include Rails::Generators::Testing::SetupAndTeardown
  include FileUtils

  tests described_class
  destination File.expand_path("../../tmp", __dir__)

  before do
    prepare_destination
  end

  after do
    FileUtils.rm_rf(destination_root)
  end

  describe "copying all views" do
    it "copies all views to app/views/tudla_hubstaff" do
      run_generator

      expect(File.exist?(File.join(destination_root, "app/views/tudla_hubstaff/users/unmapped.html.erb"))).to be true
      expect(File.exist?(File.join(destination_root, "app/views/tudla_hubstaff/tasks/unmapped.html.erb"))).to be true
      expect(File.exist?(File.join(destination_root, "app/views/tudla_hubstaff/projects/unmapped.html.erb"))).to be true
    end
  end

  describe "copying scoped views" do
    it "copies only users views when scope is users" do
      run_generator %w[users]

      expect(File.exist?(File.join(destination_root, "app/views/tudla_hubstaff/users/unmapped.html.erb"))).to be true
      expect(File.exist?(File.join(destination_root, "app/views/tudla_hubstaff/tasks/unmapped.html.erb"))).to be false
    end

    it "copies only tasks views when scope is tasks" do
      run_generator %w[tasks]

      expect(File.exist?(File.join(destination_root, "app/views/tudla_hubstaff/tasks/unmapped.html.erb"))).to be true
      expect(File.exist?(File.join(destination_root, "app/views/tudla_hubstaff/users/unmapped.html.erb"))).to be false
    end

    it "does not copy files for invalid scope" do
      run_generator %w[invalid_scope]

      expect(File.exist?(File.join(destination_root, "app/views/tudla_hubstaff/users/unmapped.html.erb"))).to be false
      expect(File.exist?(File.join(destination_root, "app/views/tudla_hubstaff/tasks/unmapped.html.erb"))).to be false
    end
  end
end
