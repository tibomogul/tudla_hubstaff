module TudlaHubstaff
  module UI
    class MapButtonComponent < TudlaHubstaff::BaseComponent
      def initialize(
        item_id:,
        item_name:,
        map_url:,
        stimulus_controller:,
        button_text: "Map"
      )
        @item_id = item_id
        @item_name = item_name
        @map_url = map_url
        @stimulus_controller = stimulus_controller
        @button_text = button_text
      end

      attr_reader :item_id, :item_name, :map_url, :stimulus_controller, :button_text
    end
  end
end
