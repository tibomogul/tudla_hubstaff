Rails.application.routes.draw do
  mount TudlaHubstaff::Engine => "/tudla_hubstaff"

  get "tasks/:id", to: "tasks#show"
end
