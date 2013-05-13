Wpbdc::Application.routes.draw do

  get "standings_local/show"

  namespace :admin do
    resource :frame, :only => [ :new ]
    resource :initial, :only => [ :new ]
    resource :main_menu, :only => [ :edit, :update ]
    resource :main, :only => [ :edit, :update ]
    resource :server_status, :only => [ :edit, :update ]
    resource :password_change, :only => [ :edit, :update ]
    resource :standings_review, :only => [ :edit, :update ]
    resource :teams_review, :only => [ :edit, :update ]
    resource :any_team, :only => [ :edit, :update ]
    resource :local_contest_team, :only => [:edit, :update ]
    resource :leader_emails, :only => [:edit, :update]
    resource :session, :only => [ :new, :create, :destroy ]
    resource :group, :only => [ :edit, :update ]
    resource :local_contest, :only => [ :edit, :update ]
    resources :designs, :only => [:show]
  end
  resource :team, :only => [ :new, :create, :edit, :update ]
  resource :member, :only => [ :new, :create, :edit, :update ]
  resource :certification, :only => [ :edit, :update ]
  resource :captain_completion, :only => [ :edit, :update ]
  resource :member_completion, :only => [ :edit, :update ]
  resource :team_completion, :only => [ :edit, :update ]
  resource :verification, :only => [ :edit, :update ]
  resource :home, :only => [ :edit, :update ]
  resources :standings, :only => [ :show ]
  # Can's use a standard resource path here because both local contest
  # code and page (for pagination) must be in path for cache to work.
  match 'standings/local/:code(/:page)' => 'standings_local#show'

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
