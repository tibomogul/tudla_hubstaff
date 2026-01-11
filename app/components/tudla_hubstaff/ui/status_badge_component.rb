module TudlaHubstaff
  module UI
    class StatusBadgeComponent < TudlaHubstaff::BaseComponent
      STYLES = {
        active: "bg-green-100 text-green-800",
        pending: "bg-gray-100 text-gray-800",
        inactive: "bg-gray-100 text-gray-800",
        default: "bg-gray-100 text-gray-800"
      }.freeze

      def initialize(status:)
        @status = status.to_s.downcase
      end

      attr_reader :status

      def style_classes
        STYLES[status.to_sym] || STYLES[:default]
      end

      def display_text
        status.presence || "pending"
      end
    end
  end
end
