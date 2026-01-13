# Mock implementation of TudlaContracts::Integration::HostInterface for the dummy app
# In a real host app, this would be a class that inherits from the base interface
# and provides actual user data
require "tudla_contracts"

class DummyHostInterface < TudlaContracts::Integrations::HostInterface
  def available_users_for_user(_current_user)
    [
      Struct.new(:id, :name, :email).new(1, "Alice Johnson", "alice@example.com"),
      Struct.new(:id, :name, :email).new(2, "Bob Smith", "bob@example.com"),
      Struct.new(:id, :name, :email).new(3, "Carol Williams", "carol@example.com"),
      Struct.new(:id, :name, :email).new(4, "David Brown", "david@example.com"),
      Struct.new(:id, :name, :email).new(5, "Eve Davis", "eve@example.com"),
      Struct.new(:id, :name, :email).new(6, "Frank Miller", "frank@example.com"),
      Struct.new(:id, :name, :email).new(7, "Grace Wilson", "grace@example.com"),
      Struct.new(:id, :name, :email).new(8, "Henry Moore", "henry@example.com"),
      Struct.new(:id, :name, :email).new(9, "Ivy Taylor", "ivy@example.com"),
      Struct.new(:id, :name, :email).new(10, "Jack Anderson", "jack@example.com"),
      Struct.new(:id, :name, :email).new(11, "Kate Thomas", "kate@example.com"),
      Struct.new(:id, :name, :email).new(12, "Leo Jackson", "leo@example.com"),
      Struct.new(:id, :name, :email).new(13, "Mia White", "mia@example.com"),
      Struct.new(:id, :name, :email).new(14, "Noah Harris", "noah@example.com"),
      Struct.new(:id, :name, :email).new(15, "Olivia Martin", "olivia@example.com")
    ]
  end

  def available_tasks_for_user(_current_user)
    [
      Struct.new(:id, :name, :project_name).new(1, "Setup Development Environment", "Project Alpha"),
      Struct.new(:id, :name, :project_name).new(2, "Implement User Authentication", "Project Alpha"),
      Struct.new(:id, :name, :project_name).new(3, "Design Database Schema", "Project Alpha"),
      Struct.new(:id, :name, :project_name).new(4, "Create API Endpoints", "Project Beta"),
      Struct.new(:id, :name, :project_name).new(5, "Write Unit Tests", "Project Beta"),
      Struct.new(:id, :name, :project_name).new(6, "Setup CI/CD Pipeline", "Project Beta"),
      Struct.new(:id, :name, :project_name).new(7, "Code Review", "Project Gamma"),
      Struct.new(:id, :name, :project_name).new(8, "Bug Fixes", "Project Gamma"),
      Struct.new(:id, :name, :project_name).new(9, "Performance Optimization", "Project Gamma"),
      Struct.new(:id, :name, :project_name).new(10, "Documentation", "Project Delta"),
      Struct.new(:id, :name, :project_name).new(11, "User Interface Design", "Project Delta"),
      Struct.new(:id, :name, :project_name).new(12, "Integration Testing", "Project Delta"),
      Struct.new(:id, :name, :project_name).new(13, "Security Audit", "Project Epsilon"),
      Struct.new(:id, :name, :project_name).new(14, "Deployment Planning", "Project Epsilon"),
      Struct.new(:id, :name, :project_name).new(15, "Client Meeting Preparation", "Project Epsilon")
    ]
  end

  def available_projects_for_user(_current_user)
    [
      Struct.new(:id, :name).new(1, "Website Redesign"),
      Struct.new(:id, :name).new(2, "Mobile App Development"),
      Struct.new(:id, :name).new(3, "API Integration"),
      Struct.new(:id, :name).new(4, "Database Migration"),
      Struct.new(:id, :name).new(5, "Cloud Infrastructure"),
      Struct.new(:id, :name).new(6, "Security Audit"),
      Struct.new(:id, :name).new(7, "E-commerce Platform"),
      Struct.new(:id, :name).new(8, "Inventory System"),
      Struct.new(:id, :name).new(9, "CRM Implementation"),
      Struct.new(:id, :name).new(10, "Analytics Dashboard"),
      Struct.new(:id, :name).new(11, "HR Portal"),
      Struct.new(:id, :name).new(12, "Payroll System"),
      Struct.new(:id, :name).new(13, "Marketing Automation"),
      Struct.new(:id, :name).new(14, "Content Management"),
      Struct.new(:id, :name).new(15, "Customer Support Portal")
    ]
  end
end

# Configure TudlaHubstaff to use the dummy host interface
TudlaHubstaff.host_interface_class = "::DummyHostInterface"
