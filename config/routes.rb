Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  #
  root to: "jukebox#index"
  post "/play", to: "jukebox#play"
  # These are just here because rails cant see actions that arent in a route I guess?
  post "/kill", to: "jukebox#kill"
  post "/enqueue", to: "jukebox#enqueue"
  post "/set_vol", to: "jukebox#set_vol"
end
