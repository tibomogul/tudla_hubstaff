TudlaHubstaff::Engine.routes.draw do
  resources :users, only: [] do
    collection do
      get :unmapped
      get :available_tudla_users
    end
    member do
      patch :map_tudla_user
    end
  end

  resources :tasks, only: [] do
    collection do
      get :unmapped
      get :available_tudla_tasks
    end
    member do
      patch :map_tudla_task
    end
  end
end
