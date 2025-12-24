module TudlaHubstaff
  class ApiClient
    attr_reader :organization_id, :connection

    def initialize(organization_id, connection)
      @organization_id = organization_id
      @connection = connection
    end

    def daily_activities_by_date(start_time, stop_time, options = {})
      activities = connection.get("v2/organizations/#{organization_id}/activities/daily") do |req|
        req.params["date[start]"] = start_time
        req.params["date[stop]"] = stop_time
        req.params["page_start_id"] = options[:page_start_id] unless options[:page_start_id].nil?
        req.params["page_limit"] = options[:page_limit] unless options[:page_limit].nil?
      end
      activities.body
    end

    def daily_activities_by_updated(start_time, stop_time, options = {})
      activities = connection.get("v2/organizations/#{organization_id}/activities/daily/updates") do |req|
        req.params["updated[start]"] = start_time
        req.params["updated[stop]"] = stop_time
        req.params["page_start_id"] = options[:page_start_id] unless options[:page_start_id].nil?
        req.params["page_limit"] = options[:page_limit] unless options[:page_limit].nil?
      end
      activities.body
    end

    def members
      members = connection.get("v2/organizations/#{organization_id}/members") do |req|
        req.params["include"] = [ "users" ]
      end
      members.body
    end

    def tasks(options = {})
      tasks = connection.get("v2/organizations/#{organization_id}/tasks") do |req|
        req.params["page_start_id"] = options[:page_start_id] unless options[:page_start_id].nil?
        req.params["page_limit"] = options[:page_limit] unless options[:page_limit].nil?
        req.params["status"] = options[:status] unless options[:status].nil?
        req.params["project_ids"] = options[:project_ids].join(",") unless options[:project_ids].nil?
      end
      tasks.body
    end
  end
end
