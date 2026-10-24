Rails.application.routes.draw do
  get "autenticacao_operador", to: "autenticacao_operador#index"

  post "autenticacao_operador", to: "autenticacao_operador#create"

  # Verifica se a aplicação está funcionando
  get "up" => "rails/health#show", as: :rails_health_check

  # Define a rota principal da aplicação
  # root "posts#index"
end