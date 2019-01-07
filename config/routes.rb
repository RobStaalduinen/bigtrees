Rails.application.routes.draw do

	default_url_options :host => "thatsabigtree.ca"

  root 'main#show', page: "home"

	get "/main/:page" => "main#show", as: :pages

	match '/estimate/submit_new_estimate' => 'estimate#submit_new_estimate', :as => :submit_estimate, via: :all
	match '/estimate/submit_job_questions' => 'estimate#submit_job_questions', :as => :submit_questions, via: :all
	match '/estimate/submit_tree_images' => 'estimate#submit_tree_images', :as => :submit_images, via: :all
	match '/estimate/display_estimate' => 'estimate#display_estimate', :as => :display_estimate, via: :all
  match '/estimate/estimate_tooltips' => 'estimate#estimate_tooltips', :as => :estimate_tooltips, via: :all
  
  match '/admin/view_estimate', :as => :admin_estimates, via: :get
  resources :estimates do
    resources :quotes, only: [ :index ]
  end

  resources :arborists

  match '/estimate/display_estimate' => 'estimate#display_estimate', :as => :display, via: :all

  get ':controller/:action'

  put ':controller/:action'

  post ':controller/:action'

  patch ':controller/:action'
  


  match '*path' => 'main#not_found', via: :all

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
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

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
