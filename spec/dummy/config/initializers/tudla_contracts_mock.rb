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
end

# Configure TudlaHubstaff to use the dummy host interface
TudlaHubstaff.host_interface_class = DummyHostInterface
