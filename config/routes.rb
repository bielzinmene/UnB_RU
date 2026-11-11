Rails.application.routes.draw do
  root "portal#index"
  get "/cadastro", to: "cadastros#new", as: :cadastro
  post "/cadastro", to: "cadastros#create"
  get "/estudante/login", to: "sessoes_estudantes#new", as: :login_estudante
  post "/estudante/login", to: "sessoes_estudantes#create"
  delete "/estudante/logout", to: "sessoes_estudantes#destroy", as: :logout_estudante
  get "/funcionario/login", to: "sessoes#new", as: :login_funcionario
  post "/funcionario/login", to: "sessoes#create"
  delete "/funcionario/logout", to: "sessoes#destroy", as: :logout_funcionario
  get "/funcionario", to: "funcionarios#index", as: :area_funcionario
  get "/cardapio", to: "cardapios#show", as: :cardapio
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
