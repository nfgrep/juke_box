Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  #
  root to: "jukebox#index"
  post "/", to: "jukebox#play"
  post "/stop", to: "jukebox#stop"
end
