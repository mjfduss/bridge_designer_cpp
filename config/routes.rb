Wpbdc::Application.routes.draw do

  get "get_leader_emails/edit"

  get "get_leader_emails/update"

  namespace :admin do
    resource :frame, :only => [ :new ]
    resource :initial, :only => [ :new ]
    resource :main_menu, :only => [ :edit, :update ]
    resource :main, :only => [ :edit, :update ]
    resource :server_status, :only => [ :edit, :update ]
    resource :password_change, :only => [ :edit, :update ]
    resource :standings_review, :only => [ :edit, :update ]
    resource :teams_review, :only => [ :edit, :update ]
    resource :get_any_team, :only => [ :edit, :update ]
    resource :get_local_contest_team, :only => [:edit, :update ]
    resource :retrieve_design, :only => [:edit, :update]
    resource :session, :only => [ :new, :create, :destroy ]
    resource :group, :only => [ :edit, :update ]
    resource :local_contest, :only => [ :edit, :update ]
  end
  resources :teams, :except => [ :show ]
  resources :members, :except => [ :show, :destroy ]
  resources :certifications, :only => [ :edit, :update ]
  resources :captain_completions, :only => [ :edit, :update ]
  resources :member_completions, :only => [ :edit, :update ]
  resources :team_completions, :only => [ :edit, :update ]
  resources :verifications, :only => [ :edit, :update ]
  resources :homes, :only => [ :edit, :update ]
  resources :standings, :only => [ :show ]
  resource :session, :only => [ :new, :create, :destroy ]

  root :to => 'sessions#new'

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
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
