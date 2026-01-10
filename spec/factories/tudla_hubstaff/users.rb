FactoryBot.define do
  factory :user, class: "TudlaHubstaff::User" do
    sequence(:name) { |n| "User #{n}" }
    sequence(:first_name) { |n| "First#{n}" }
    sequence(:last_name) { |n| "Last#{n}" }
    sequence(:email) { |n| "user#{n}@example.com" }
    time_zone { "UTC" }
    ip_address { "127.0.0.1" }
    status { "active" }
    sequence(:user_id) { |n| n }
  end
end
