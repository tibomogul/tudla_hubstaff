FactoryBot.define do
  factory :task do
    integration_id { 1 }
    status { "MyString" }
    project_id { 1 }
    project_type { "MyString" }
    summary { "MyString" }
    details { "MyText" }
    remote_id { "MyString" }
    remote_alternate_id { "MyString" }
    lock_version { 1 }
    metadata { "" }
    completed_at { "2025-12-31 08:25:24" }
    due_at { "2025-12-31 08:25:24" }
  end
end
