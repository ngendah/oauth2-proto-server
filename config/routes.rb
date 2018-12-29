Rails.application.routes.draw do
  root to: 'home#index'
  resource :authorize
  resource :token
  resource :check
end
