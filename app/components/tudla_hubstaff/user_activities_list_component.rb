module TudlaHubstaff
  class UserActivitiesListComponent < TudlaHubstaff::BaseComponent
    PER_PAGE = 10

    def initialize(user_id:, current_page: 1, per_page: PER_PAGE, unmapped_only: false)
      @user_id = user_id
      @current_page = current_page.to_i
      @per_page = per_page.to_i
      @unmapped_only = unmapped_only
    end

    attr_reader :user_id, :current_page, :per_page, :unmapped_only

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
      user_id.present?
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

    def turbo_frame_id
      "user_#{user_id}_activities"
    end

    def pagination_path(page:)
      user_activities_activities_path(user_id: user_id, page: page, unmapped_only: unmapped_only)
    end

    def filter_path(unmapped:)
      user_activities_activities_path(user_id: user_id, page: 1, unmapped_only: unmapped)
    end

    private

    def fetch_activities
      activities_scope
        .order(updated_at: :desc)
        .offset((current_page - 1) * per_page)
        .limit(per_page)
    end

    def activities_scope
      @activities_scope ||= begin
        scope = TudlaHubstaff::Activity.where(user_id: user_id)
        if unmapped_only
          unmapped_task_ids = TudlaHubstaff::Task.where(tudla_task_id: nil).pluck(:task_id)
          scope = scope.where(task_id: unmapped_task_ids)
        end
        scope
      end
    end
  end
end
