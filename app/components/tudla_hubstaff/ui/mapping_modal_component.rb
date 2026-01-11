module TudlaHubstaff
  module UI
    class MappingModalComponent < TudlaHubstaff::BaseComponent
      renders_one :search_input
      renders_one :items_list
      renders_one :pagination

      def initialize(
        id:,
        title:,
        stimulus_controller:,
        available_items_url:,
        search_placeholder: "Filter by name...",
        loading_text: "Loading...",
        cancel_text: "Cancel"
      )
        @id = id
        @title = title
        @stimulus_controller = stimulus_controller
        @available_items_url = available_items_url
        @search_placeholder = search_placeholder
        @loading_text = loading_text
        @cancel_text = cancel_text
      end

      attr_reader :id, :title, :stimulus_controller, :available_items_url,
                  :search_placeholder, :loading_text, :cancel_text

      def target_prefix
        stimulus_controller.gsub("-", "_").camelize(:lower)
      end
    end
  end
end
