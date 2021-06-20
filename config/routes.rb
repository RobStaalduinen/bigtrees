Rails.application.routes.draw do

	# default_url_options :host => "https://thatsabigtree.ca"

  root 'main#show', page: "home"

  get "/main/:page" => "main#show", as: :pages
  get 'health' => 'main#health'

  get '/admin/admin_panel', to: redirect('/estimates')
  # get '/arborists/:id', to: redirect { |params, request| "/admin/users/#{request.params[:id]}" }

  resources :estimates do
    resources :quotes, only: [ :index ] do
      get '/receipt', to: 'quotes#receipt'
      get '/pdf', to: 'quotes#pdf', on: :collection
    end
    resources :image_requests, only: [ :new, :create ]
    resources :quote_mailouts, only: [ :new, :create ]
    resources :sites, only: [ :create, :edit, :update ]
    resources :costs, only: [ :new, :create ] do
      get '/edit', to: 'costs#edit', on: :collection, as: :edit
      post '/create_single', to: 'costs#create_single', on: :collection
      post '/update', to: 'costs#update', on: :collection, as: :update
    end
    resources :invoice_mailouts, only: [ :create ]
    resources :invoice_receipts, only: [ :create ]
    resources :followups, only: [ :create ]

    post '/cancel', to: 'estimates#cancel', on: :member
  end

  resources :sessions, only: [ :new, :create, :destroy ]
  get '/login', to: 'sessions#new', as: :login
  get '/logout', to: 'sessions#destroy', as: :logout
  get '/authenticate', to: 'sessions#authenticate'

  resources :trackers, only: [ :new, :index ]
  resources :arborists do
    resources :documents
  end
  resources :customers
  resources :requests
  resources :trees do
    post '/bulk_create', to: 'trees#bulk_create', on: :collection
  end
  resources :tree_images, only: [ :new, :create, :update ] do
    post '/create_from_urls', to: 'tree_images#create_from_urls', on: :collection
  end
  resources :extra_costs, only: [ :create, :destroy ]
  resources :work_records do
    get 'report', to: 'work_records#report', on: :collection, as: :report
    get 'summaries', to: 'work_records#summaries', on: :collection
    get '/for_arborist', to: 'work_records#for_arborist', on: :collection
  end
  resources :invoices do
    post '/pay', to: 'invoices#pay', as: :pay
    get '/pdf', to: 'invoices#pdf'
  end

  match '/receipts/xlsx', to: 'receipts#xlsx', via: :get, as: :receipts_xlsx
  match '/cheques/xlsx', to: 'receipts#cheque_xlsx', via: :get, as: :cheques_xlsx
  resources :receipts do
    post '/approve', to: 'receipts#approve', as: :approve, param: :id
    post '/approve_all', to: 'receipts#approve_all', on: :collection
    get '/summaries', to: 'receipts#summaries', on: :collection
  end
  resources :vehicles
  resources :expirations
  resources :payouts

  resources :hours, only: [ :index ]

  resources :equipment_requests do
    post '/resolve', to: 'equipment_requests#resolve', as: :resolve
    post '/send_mailout', to: 'equipment_requests#send_mailout'
  end

  resources :files, only: [ :new ]

  resources :vue_test, only: [ :new ]

  get '/admin/*path', to: 'admin#index'

  get ':controller/:action'

  put ':controller/:action'

  post ':controller/:action'

  patch ':controller/:action'

  match '*path' => 'main#not_found', via: :all
end
