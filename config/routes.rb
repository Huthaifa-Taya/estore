Rails.application.routes.draw do
  mount ActionCable.server => '/cable'
  # Root path
  root to: "products#index"
  # Resources paths for stores, products, and categories.
  resources :stores do
    get ':id/page/:page', as: 'paged', to: 'stores#show'
    delete '/', as: 'delete', to: 'stores#destroy'
  end
  resources :products do
    get '/page/:page', as: '', to: 'products#index', on: :collection, defaults: { page: 1 }
    # get '/', as: 'show', to: 'products#show'
    # get '/edit', as: 'edit', to: 'products#edit'
    # get '/new', as: 'new', to: 'products#create'
    post '/filtered', as: 'filter', to: "products#filter"
    # post '/', as: 'create', to: 'products#create'
    # get '/filtered/page/:page', as: 'filtered', to: 'products#filtered', on: :collection
    # delete '/', as: 'delete', to: 'products#destroy'
  end
  resources :categories do
    get '/page/:page', as: 'categories', to: 'categories#index', on: :collection
    get '/:id', as: 'category', to: 'categories#show'
    delete '/', as: 'delete', to: 'categories#destroy'
  end

  scope :cart do
    get '/', as: 'cart', to: 'cart#show'
    post '/', as: 'add_to_cart', to: 'cart#update'
    delete '/:id', as: 'item_remove', to: 'cart#destroy'
    patch '/:id/:method', as: 'edit_quantity', to: 'cart#edit_quantity'
    put '/', as: 'checkout', to: 'cart#checkout'

  end

  # Devise generated paths for user controllers.
  devise_for :user, controllers: { sessions: 'users/sessions' }, skip: [:registrations]

  # Custom named path for user registrations path
  devise_scope :user do
    get '/sign_up', to: "users/registrations#new", as: 'new_customer_registration'
    get '/owner_sign_up', to: "users/registrations#new", as: 'new_owner_registration'
    post 'sign_up', to: "users/registrations#create", as: "user_registration"
  end
  namespace :owners do
    get 'dashboard', as: 'dashboard', to: 'dashboard#index'
  end

  # resources :users do
  #   get 'store_owners/page/:page', as: 'store_owners', to: 'users/users#index', on: :collection
  #   get 'customers/page/:page', as: 'customers', to: "customers/customers#index", on: :collection
  #   get '/page/:page', as: 'users', to: 'users/users#index', on: :collection
  #   # get '/create', as: 'new' ,to: 'users/users#new'
  # end

  resources :admins do
    get 'dashboard', as: 'dashboard', to: "admins/dashboard#index"
    get '/users', to: 'admins/userss#index'
    get '/users/new', to: "admins/userss#new"
    post '/users', as: 'create_user', to: 'admins/userss#create'
    get '/users/:id', as: 'user_edit', to: 'admins/userss#edit'
    patch '/users/:id', as: 'edit_user', to: 'admins/userss#update'
    delete '/:id', as: 'delete_user', to: 'admins/userss#destroy'
    get 'import_products', as: 'import_products', to: 'admins/dashboard#import_products_view'
    put 'import_products', as: 'import', to: 'admins/dashboard#import_products'
  end
end
