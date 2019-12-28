Rails.application.routes.draw do

	# default_url_options :host => "https://thatsabigtree.ca"

  root 'main#show', page: "home"

  get "/main/:page" => "main#show", as: :pages
  get 'health' => 'main#health'

  get '/admin/admin_panel', to: redirect('/estimates')

  resources :estimates do
    resources :quotes, only: [ :index ] do
      get '/receipt', to: 'quotes#receipt'
    end
    resources :image_requests, only: [ :new, :create ]
    resources :quote_mailouts, only: [ :new, :create ]
    resources :sites, only: [ :create ]
    resources :costs, only: [ :new, :create ] do
      get '/edit', to: 'costs#edit', on: :collection, as: :edit
      patch '', to: 'costs#update', on: :collection, as: :update
    end

    post '/cancel', to: 'estimates#cancel', on: :member
  end

  resources :trackers, only: [ :new, :index ]
  resources :arborists
  resources :customers
  resources :requests
  resources :trees
  resources :tree_images, only: [ :create ]
  resources :extra_costs, only: [ :create, :destroy ]
  resources :invoices do
    post '/pay', to: 'invoices#pay', as: :pay
  end

  match '/receipts/xlsx', to: 'receipts#xlsx', via: :get, as: :receipts_xlsx
  match '/cheques/xlsx', to: 'receipts#cheque_xlsx', via: :get, as: :cheques_xlsx
  resources :receipts
  resources :vehicles

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
