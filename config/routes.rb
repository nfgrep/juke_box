Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  #
  root to: redirect("open")
  get "open", to: "main#open_url_page"
  post "open", to: "main#open_url_action"
  post "close", to: "main#close"
end
