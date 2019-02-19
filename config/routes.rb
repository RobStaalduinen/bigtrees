Rails.application.routes.draw do

	# default_url_options :host => "https://thatsabigtree.ca"

  root 'main#show', page: "home"

	get "/main/:page" => "main#show", as: :pages

	match '/estimate/submit_new_estimate' => 'estimate#submit_new_estimate', :as => :submit_estimate, via: :all
	match '/estimate/submit_job_questions' => 'estimate#submit_job_questions', :as => :submit_questions, via: :all
	match '/estimate/submit_tree_images' => 'estimate#submit_tree_images', :as => :submit_images, via: :all
	match '/estimate/display_estimate' => 'estimate#display_estimate', :as => :display_estimate, via: :all
  match '/estimate/estimate_tooltips' => 'estimate#estimate_tooltips', :as => :estimate_tooltips, via: :all
  
  match '/admin/view_estimate', :as => :admin_estimates, via: :get
  match '/estimates/:id', to: 'estimate#update', via: :patch
  resources :estimates do
    resources :quotes, only: [ :index ]
    resources :quote_mailouts, only: [ :new, :create ]
    get '/assign_arborist', to: 'estimate#assign_arborist', on: :member
    get '/finalize_payment', to: 'estimate#finalize_payment', on: :member
    get '/update_contact_details', to: 'estimate#update_contact_details', on: :member
    get '/update_address', to: 'estimate#update_address', on: :member
    post '/cancel', to: 'estimate#cancel', on: :member
  end

  resources :trackers, only: [ :new, :index ]
  resources :arborists
  resources :requests
  
  match '/receipts/xlsx', to: 'receipts#xlsx', via: :get, as: :receipts_xlsx
  match '/cheques/xlsx', to: 'receipts#cheque_xlsx', via: :get, as: :cheques_xlsx
  resources :receipts
  resources :vehicles

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
