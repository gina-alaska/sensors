Amaru::Application.routes.draw do

  resources :organizations do
    get 'add_user', :on => :member
  end

  resources :users do
    resources :organizations do
      post "revoke", :on => :member
    end
  end

  resources :groups do
    post 'add_platform', :on => :member
    get 'remove_platform', :on => :member
    get 'platforms', :on => :member
    get 'data_view', :on => :member
    get 'graph_update', :on => :member

    resources :sensors
    resources :processed_data

    resources :alerts do
      get 'add', :on => :member
      get 'change', :on => :member
      get 'remove', :on => :member
      get 'moveup', :on => :member
      get 'movedown', :on => :member
    end

    resources :graphs do
      get 'image', :on => :member
      get 'thumb', :on => :member
      get 'build', :on => :member
    end

    resources :events do
      get 'add', :on => :member
      get 'change', :on => :member
      get 'remove', :on => :member
      get 'moveup', :on => :member
      get 'movedown', :on => :member
      get 'run_event', :on => :member
    end

    resources :status do
      collection do
        get :group_poll
      end
    end
  end

  resources :platforms do
    get 'graph_update', :on => :member
    resources :raw_data
    resources :sensors
  end

  resources :resques do
    member do
      get :poll
      post :retry
    end
    collection do
      delete :destroy
    end
  end

  match "set_current" => "organizations#set_current"
  match "dashboard" => "dashboard#index"
  match "poll" => "status#poll"

  # import
  match "csv/:slug/:token" => "import#csv"

  # tools
  match "tools" => "tools#index"
  match "by_sensor" => "tools#by_sensor", as: :by_sensor
  match "mass_platform_set" => "tools#mass_platform_set", as: :mass_platform_set

  # user auth
  match "/auth/:provider/callback", to: "sessions#create"
  match '/auth/failure' => 'sessions#failure'
  match '/signin' => 'sessions#new', :as => :signin
  match "/signout" => "sessions#destroy", :as => :signout
  match "user" => "users#show"

  # data REST API's
  match "data/raw/:slug" => "data#raw"
  match "data/processed/:group/:slug" => "data#processed"
  match "data/graph/:group/:slug" => "data#graph"

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => 'dashboard#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
