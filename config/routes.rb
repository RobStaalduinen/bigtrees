Rails.application.routes.draw do

	# default_url_options :host => "https://thatsabigtree.ca"

  root 'sessions#new'

  get '/admin/admin_panel', to: redirect('/estimates')
  # get '/arborists/:id', to: redirect { |params, request| "/admin/users/#{request.params[:id]}" }

  resources :estimates do
    resources :quotes, only: [ :index ] do
      get '/receipt', to: 'quotes#receipt'
      get '/pdf', to: 'quotes#pdf', on: :collection
    end
    resources :quote_mailouts, only: [ :create ]
    resources :sites, only: [ :create, :edit, :update ]
    resources :costs, only: [ :new, :create ] do
      get '/edit', to: 'costs#edit', on: :collection, as: :edit
      post '/create_single', to: 'costs#create_single', on: :collection
      post '/update', to: 'costs#update', on: :collection, as: :update
    end
    resources :invoice_mailouts, only: [ :create ]
    resources :invoice_receipts, only: [ :create ]
    resources :followups, only: [ :create ]
    resources :equipment_assignments, only: [ ] do
      post '/bulk_update', to: 'equipment_assignments#bulk_update', on: :collection
    end
    resources :notes, only: [ :create ]
    resources :jobs, only: [ :create ] do
      put '/', to: 'jobs#update', on: :collection
    end

    get '/stats', to: 'estimates#stats', on: :collection
    post '/cancel', to: 'estimates#cancel', on: :member

    resources :duplications, module: :estimates, only: [:create]
  end

  resources :sessions, only: [ :new, :create, :destroy ]
  get '/login', to: 'sessions#new', as: :login
  get '/logout', to: 'sessions#destroy', as: :logout
  get '/authenticate', to: 'sessions#authenticate'

  resources :trackers, only: [ :new, :index ]
  resources :arborists do
    put '/update_password', to: 'arborists#update_password'
    resources :documents
  end
  resources :customers
  resources :customer_details, only: [ :update ]
  resources :trees do
    post '/admin_create', to: 'trees#admin_create', on: :collection, as: 'admin_create'
    post '/bulk_create', to: 'trees#bulk_create', on: :collection
  end
  resources :tree_images, only: [ :new, :show, :create, :update, :destroy ] do
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
    get '/tracker', to: 'equipment_requests#tracker', on: :collection
    post '/resolve', to: 'equipment_requests#resolve', as: :resolve
    post '/send_mailout', to: 'equipment_requests#send_mailout'
    post '/assign', to: 'equipment_requests#assign'
  end

  resources :files, only: [ :new ]
  resources :organizations, only: [ :index, :show, :update ] do
    get 'public/:short_name', to: 'organizations#public', on: :collection

    resources :quick_costs, only: [ :index, :create, :update, :destroy ]
    resources :tags, only: [ :index, :create, :update, :destroy ]
    resources :taggings, only: [ :create ] do 
      delete '/', to: 'taggings#destroy', on: :collection
    end


    resources :configurations, only: [ :index, :update ]
  end
  scope 'organizations/:organization_shortname', as: 'organization_shortname' do
    resources :requests, only: [:new], to: 'customer_requests#org_scoped'
  end

  resources :customer_requests, only: [ :new, :create ]
  resources :email_templates, only: [ :index, :show, :update ]
  resources :commercial_requests, only: [ :create ]

  resources :vue_test, only: [ :new ]

  resources :nylas_accounts, only: [ :new, :show, :destroy ] do
    get '/receive_grant', to: 'nylas_accounts#receive_grant', on: :collection
  end

  devise_for :users, class_name: 'Arborist'

  get '/p/:customer_name', to: 'property_management#show'
  post '/p/:customer_name', to: 'property_management#create'

  get '/admin/*path', to: 'admin#index'

  get ':controller/:action'

  put ':controller/:action'

  post ':controller/:action'

  patch ':controller/:action'
end
