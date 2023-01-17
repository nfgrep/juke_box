Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  #
  root to: "jukebox#index"
  post "/", to: "jukebox#play"
  # These are just here because rails cant see actions that arent in a route I guess?
  post "/stop", to: "jukebox#stop"
  post "/vol_up", to: "jukebox#vol_up"
  post "/vol_down", to: "jukebox#vol_down"
end
