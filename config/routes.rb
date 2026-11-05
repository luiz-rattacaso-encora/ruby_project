Rails.application.routes.draw do
  resources :teams
  resource :session
  resources :passwords, param: :token

  root "home#index"
  get "/employees/all", controller: "employees", action: "all"
  get "/employees/:id/hierarchy", controller: "employees", action: "hierarchy"
  resources :employees
  resources :memberships, only: [ :index, :new, :create, :update, :edit, :destroy ]

  # get '/employees', controller: 'employees', action: 'index'
  # get '/employees/new', controller: 'employees', action: 'new' --> form before create
  # get '/employees/:id', controller: 'employees', action: 'show' --> form to show the employee
  # get '/employee/:id/edit', controller: 'employees', action: 'edit' --> form before edit

  # post '/employees', controller: 'employees', action: 'create'
  # put '/employees/:id', controller: 'employees', action: 'update'
  # patch '/employees:id', controller: 'employees', action: 'update'
  # delete '/employees/:id', controller: 'employees', action: 'destroy'
end
