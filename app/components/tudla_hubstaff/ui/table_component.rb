module TudlaHubstaff
  module UI
    class TableComponent < TudlaHubstaff::BaseComponent
      renders_one :header
      renders_many :rows

      def initialize(id: nil, empty_message: "No items found.")
        @id = id
        @empty_message = empty_message
      end

      attr_reader :id, :empty_message
    end
  end
end
