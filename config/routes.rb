Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  #
  root to: "jukebox#index"
  post "/play", to: "jukebox#play"
  # These are just here because rails cant see actions that arent in a route I guess?
  post "/stop", to: "jukebox#stop"
  post "/enqueue", to: "jukebox#enqueue"
  post "/set_vol", to: "jukebox#set_vol"
  post "/set_quality", to: "jukebox#set_quality"
end
