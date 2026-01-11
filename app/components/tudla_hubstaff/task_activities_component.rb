module TudlaHubstaff
  class TaskActivitiesComponent < TudlaHubstaff::BaseComponent
    PER_PAGE = 20

    def initialize(tudla_task_id:, current_page: 1, per_page: PER_PAGE)
      @tudla_task_id = tudla_task_id
      @current_page = current_page.to_i
      @per_page = per_page.to_i
    end

    attr_reader :tudla_task_id, :current_page, :per_page

    def activities
      @activities ||= fetch_activities
    end

    def total_count
      @total_count ||= activities_scope.count
    end

    def total_pages
      (total_count.to_f / per_page).ceil
    end

    def render?
      tudla_task_id.present?
    end

    def start_item
      return 0 if total_count.zero?
      ((current_page - 1) * per_page) + 1
    end

    def end_item
      [ current_page * per_page, total_count ].min
    end

    def show_previous?
      current_page > 1
    end

    def show_next?
      current_page < total_pages
    end

    def previous_page
      current_page - 1
    end

    def next_page
      current_page + 1
    end

    def format_duration(seconds)
      return "0m" if seconds.nil? || seconds.zero?

      hours = seconds / 3600
      minutes = (seconds % 3600) / 60

      if hours > 0
        "#{hours}h #{minutes}m"
      else
        "#{minutes}m"
      end
    end

    def format_date(date_string)
      return "" if date_string.blank?
      Date.parse(date_string).strftime("%b %d, %Y")
    rescue ArgumentError
      date_string
    end

    private

    def fetch_activities
      activities_scope
        .order(last_updated_at: :desc)
        .offset((current_page - 1) * per_page)
        .limit(per_page)
    end

    def activities_scope
      @activities_scope ||= begin
        hubstaff_task_ids = TudlaHubstaff::Task
          .where(tudla_task_id: tudla_task_id)
          .pluck(:task_id)

        TudlaHubstaff::Activity.where(task_id: hubstaff_task_ids)
      end
    end
  end
end
