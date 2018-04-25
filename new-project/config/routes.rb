Rails.application.routes.draw do

  root   'static_pages#home'
  get    'help'    => 'static_pages#help'
  get    'about'   => 'static_pages#about'
  get    'contact' => 'static_pages#contact'
  get    'signup'  => 'users#new'

  get    'login'   => 'sessions#new'     #вход в сессию, получаем дани
  post   'login'   => 'sessions#create'  #вход в нова
  delete 'logout'  => 'sessions#destroy' #удалить сессию
  resources :users do
    member do
      get :following, :followers
    end
  end

  resources :account_activations, only: [:edit]
  resources :microposts,          only: [:create, :destroy]
  resources :relationships,       only: [:create, :destroy]

end
