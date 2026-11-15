module Admin
  class CatracasController < ApplicationController
    before_action :exigir_administrador

    def create
      GerenciarRestauranteCatraca.cadastrar_catraca(
        codigo: params[:codigo],
        nome: params[:nome],
        restaurante_codigo: params[:restaurante_codigo]
      )
      redirect_to admin_restaurantes_path, notice: "Catraca cadastrada com sucesso!"
    rescue GerenciarRestauranteCatraca::ErroValidacao => erro
      redirect_to admin_restaurantes_path, alert: erro.message
    end

    def destroy
      Catraca.find(params[:id]).destroy
      redirect_to admin_restaurantes_path, notice: "Catraca removida."
    end
  end
end