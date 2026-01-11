module TudlaHubstaff
  module UI
    class PaginationComponent < TudlaHubstaff::BaseComponent
      def initialize(current_page:, total_pages:, total_count:, per_page: 20, path_helper:, path_params: {})
        @current_page = current_page
        @total_pages = total_pages
        @total_count = total_count
        @per_page = per_page
        @path_helper = path_helper
        @path_params = path_params
      end

      attr_reader :current_page, :total_pages, :total_count, :per_page, :path_helper, :path_params

      def render?
        total_pages > 1
      end

      def start_item
        (current_page - 1) * per_page + 1
      end

      def end_item
        [ current_page * per_page, total_count ].min
      end

      def previous_page_path
        send(path_helper, path_params.merge(page: current_page - 1))
      end

      def next_page_path
        send(path_helper, path_params.merge(page: current_page + 1))
      end

      def show_previous?
        current_page > 1
      end

      def show_next?
        current_page < total_pages
      end
    end
  end
end
