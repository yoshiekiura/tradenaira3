Rails.application.eager_load! if Rails.env.development?

class ActionDispatch::Routing::Mapper
  def draw(routes_name)
    instance_eval(File.read(Rails.root.join("config/routes/#{routes_name}.rb")))
  end
end

Peatio::Application.routes.draw do

  #kicksmart
   namespace :api, defaults: { format: :json } do
  #   resources :users, only: [:create]
      #resource :session, only: [:create, :destroy]
  #   #post 'session', to: "auths#create"
  #   resources :projects, except: [:new]
  #   resources :likes, only: [:create, :destroy]
  #   resources :rewards, only: [:index, :create, :show, :delete, :edit, :update]
  #   resources :pledges, only: [:create]
  #   resources :searches, only: [:index]
  #   resources :categories, only: [:index, :show] do
  #     resources :project, only: [:index]
  #   end
   end


 namespace :api, module: "api_kicksmart", defaults: { format: :json } do
  resources :users, only: [:create]
  resource :session, only: [:create, :destroy]
  resources :projects, except: [:new]
  resources :likes, only: [:create, :destroy]
  resources :rewards, only: [:index, :create, :show, :delete, :edit, :update]
  resources :pledges, only: [:create]
  resources :searches, only: [:index]
  resources :categories, only: [:index, :show] do
  resources :project, only: [:index]
  end
 end



   mount ActionCable.server => '/cable'
   

  

  use_doorkeeper

  root 'welcome#index'

  patch "money/send", to: "money#send_money"
  patch "money/request", to: "money#request_money"
  get "money/accept_decline_money" => 'money#accept_decline_money'

  get "money/req" => 'money#req'
  get "money/send" => 'money#sendm', as: "send_money"
  get "money/req_success" => 'money#req_success'
  get "money/commission" => 'money#commission'

  patch "money/process/:id/:status", to: "money#processm", as: "process_request"
  get "money/two_factor/:id/:status", to: "money#two_factor", as: "two_factor_money"

  get '/unsubscribe/:email', to: 'pages#unsubscribe', as: :unsubscribe

  post "/blog/admin/images", to: "blogo/admin/images#create", as: "blogo_admin_images"

  Blogo::Routes.mount_to(self, at: '/news')

  scope(path: "news", module: 'blogo', as: 'blogo') do
    namespace :admin do
      resources :banners, except: %w(show) do 
        collection do
          get 'list/:category', to: "banners#index", as: 'list'
        end
      end
    end
  end

  



  resources :feeds do
    member do
     resources :entries, only: [:index, :show]
    end
  end

  get "sliders/edit"
  get "errors/error_404"
  get "errors/error_500"
  #get '/404', to: 'errors#not_found'
  #get '/500', to: 'errors#server_error'

  post "pages/alerts", to: "pages#srnoti"

  get "pages/amlpolicy" => 'pages#amlpolicy'
  get "pages/about" => 'pages#about'
  get "pages/cookie" => 'pages#cookie'
  get "pages/fee" => 'pages#fee'
  get "pages/privacy" => 'pages#privacy'
  get "pages/termsofuse" => 'pages#termsofuse'
  get "pages/riskwarning" => 'pages#riskwarning'
  get "pages/news" => 'pages#news'
  get "pages/learn" => 'pages#learn'
  get "pages/tradeservices" => 'pages#tradeservices'
  get "pages/contactus" => 'pages#contactus'
  get "pages/support" => 'pages#support'
  get "pages/send-money-to-nigeria" => 'pages#sendmoney'
  get "pages/request-money" => 'pages#requestmoney'
  get "pages/faq" => 'pages#faq'
  get "newproj" => 'newproj#abcd'
  get "pages/riskwarning" => 'pages#riskwarning'
  get "pages/marketplace" => 'pages#marketplace'

  get "pages/projectfunding" => 'static_pages#root'
  
  post "pages/subscribe" => 'pages#subscribe'
  get "/pages/liveprice/:market", to: 'pages#liveprice'



 



  if Rails.env.development?
    #mount MailsViewer::Engine => '/mails'
  end

  get '/signin' => 'sessions#new', :as => :signin
  get '/signup' => 'identities#new', :as => :signup
  get '/signout' => 'sessions#destroy', :as => :signout
  get '/auth/failure' => 'sessions#failure', :as => :failure
  get '/invitation/accept/signup' => 'identities#new'
  match '/auth/:provider/callback' => 'sessions#create', via: [:get, :post]
  #match '/news/' => 'news#new', via: [:get, :post]  
  match '/invitation/new' => 'news#new', via: [:get, :post] 

  resource :member, :only => [:edit, :update]
  resource :identity, :only => [:edit, :update]
  resource :news, :only => [:new, :create]

  namespace :verify do
    resource :sms_auth,    only: [:show, :update]
    resource :google_auth, only: [:show, :update, :edit, :destroy]
  end

  namespace :authentications do
    resources :emails, only: [:new, :create]
    resources :identities, only: [:new, :create]
    resource :weibo_accounts, only: [:destroy]
  end

  scope :constraints => { id: /[a-zA-Z0-9]{32}/ } do
    resources :reset_passwords
    resources :activations, only: [:new, :edit, :update]
  end

  get '/documents/api_v2'
  get '/documents/websocket_api'
  get '/documents/oauth'
  resources :documents, only: [:show]

  patch '/two_factors/validatetrans', to: "two_factors#validatetrans"
  post '/two_factors/validatetrans', to: "two_factors#validatetrans"
  resources :two_factors, only: [:show, :index, :update, :validatetrans]


  scope module: :private do
    resource  :id_document, only: [:edit, :update]

    resources :settings, only: [:index]
    resources :api_tokens do
      member do
        delete :unbind
      end
    end

    resources :fund_sources, only: [:create, :update, :destroy]

    resources :funds, only: [:index] do
      collection do
        post :gen_address
      end
    end
    
    namespace :deposits do
      Deposit.descendants.each do |d|
        resources d.resource_name do
          collection do
            post :gen_address
          end
        end
      end
    end

    namespace :withdraws do
      Withdraw.descendants.each do |w|
        resources w.resource_name
      end
    end

    resources :account_versions, :only => :index

    resources :exchange_assets, :controller => 'assets' do
      member do
        get :partial_tree
      end
    end

    get '/history/orders' => 'history#orders', as: :order_history
    get '/history/trades' => 'history#trades', as: :trade_history
    get '/history/account' => 'history#account', as: :account_history

    resources :markets, :only => :show, :constraints => MarketConstraint do
      resources :orders, :only => [:index, :destroy] do
        collection do
          post :clear
        end
      end
      resources :order_bids, :only => [:create] do
        collection do
          post :clear
        end
      end
      resources :order_asks, :only => [:create] do
        collection do
          post :clear
        end
      end
    end

    post '/pusher/auth', to: 'pusher#auth'

    resources :tickets, only: [:index, :new, :create, :show] do
      member do
        patch :close
      end
      resources :comments, only: [:create]
    end
  end
   
   # post 'blog', to: 'blogo/posts#index' 

   
    post "posts/search", to: "blogo/posts#search", as: "blogo_search"
    post "welcome/contact", to: "welcome#contact"
    get "welcome/contact", to: "welcome#contact"
    get "/advertise", to: "welcome#advertise"  

  
  
  draw :admin

  mount APIv2::Mount => APIv2::Mount::PREFIX


  

end
