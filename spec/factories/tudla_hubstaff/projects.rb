FactoryBot.define do
  factory :project do
    name { "MyString" }
    description { "MyText" }
    status { "MyString" }
    type { "" }
    client_id { 1 }
    metadata { "" }
  end
end
