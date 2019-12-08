Rails.application.routes.draw do
  resource :authorize
  resource :token
  resource :check
  match 'docs/:doc', to: 'home#index', via: :get, as: :docs
  root 'home#index'
  match '*a', :to => 'errors#routing', via: :get
end
