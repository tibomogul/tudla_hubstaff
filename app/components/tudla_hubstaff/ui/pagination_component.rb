module TudlaHubstaff
  module UI
    class PaginationComponent < TudlaHubstaff::BaseComponent
      def initialize(pagy:, path_helper:, path_params: {})
        @pagy = pagy
        @path_helper = path_helper
        @path_params = path_params
      end

      attr_reader :pagy, :path_helper, :path_params

      delegate :last, :count, :from, :to, :previous, :next, to: :pagy

      def render?
        last > 1
      end

      def start_item
        from
      end

      def end_item
        to
      end

      def total_count
        count
      end

      def previous_page_path
        send(path_helper, path_params.merge(page: previous))
      end

      def next_page_path
        send(path_helper, path_params.merge(page: self.next))
      end

      def show_previous?
        previous.present?
      end

      def show_next?
        self.next.present?
      end
    end
  end
end
