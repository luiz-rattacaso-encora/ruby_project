Rails.application.routes.draw do
  # Defines the root path route ("/")
  # root "posts#index"
  # get '/', controller: 'home', action: 'index'
  root "home#index"
  get "/login", to: "login#index"

  resources :employees, only: [ :index, :new, :create, :show, :edit, :update, :destroy ]

  # get '/employees', controller: 'employees', action: 'index'
  # get '/employees/new', controller: 'employees', action: 'new' --> form before create
  # get '/employees/:id', controller: 'employees', action: 'show' --> form to show the employee
  # get '/employee/:id/edit', controller: 'employees', action: 'edit' --> form before edit

  # post '/employees', controller: 'employees', action: 'create'
  # put '/employees/:id', controller: 'employees', action: 'update'
  # patch '/employees:id', controller: 'employees', action: 'update'
  # delete '/employees/:id', controller: 'employees', action: 'destroy'
end
