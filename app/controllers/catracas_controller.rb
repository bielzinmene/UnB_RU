class CatracasController < ApplicationController
  before_action :exigir_administrador

  def create
    restaurante = Restaurante.find(params[:restaurante_id])
    GerenciarRestauranteCatraca.cadastrar_catraca(
      id: params[:codigo],
      nome: params[:nome],
      restaurante: restaurante
    )
    redirect_to restaurantes_path, notice: "Catraca cadastrada com sucesso!"
  rescue GerenciarRestauranteCatraca::ErroValidacao => erro
    redirect_to restaurantes_path, alert: erro.message
  end

  def destroy
    PontoAcesso.find(params[:id]).destroy
    redirect_to restaurantes_path, notice: "Catraca removida."
  end
end
