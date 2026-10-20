Rails.application.routes.draw do
  # Defines the root path route ("/")
  # root "posts#index"
  # get '/', controller: 'home', action: 'index'
  root "home#index"
  
  resources :employees, only: [:index]

  # resources :employees, only: [:index, :new, :create, :show, :edit, :update, :destroy]

  # get '/employees', controller: 'employees', action: 'index'
  # get '/employees/new', controller: 'employees', action: 'new'
  # get '/employees/:id', controller: 'employees', action: 'show'
  # get '/employee/:id/edit', controller: 'employees', action: 'edit'

  # post '/employees', controller: 'employees', action: 'create'
  # put '/employees/:id', controller: 'employees', action: 'update'
  # patch '/employees:id', controller: 'employees', action: 'update'
  # delete '/employees/:id', controller: 'employees', action: 'destroy'
end
