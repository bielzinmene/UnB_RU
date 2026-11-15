class RestaurantesController < ApplicationController
  before_action :exigir_administrador

  def index
    @restaurantes = Restaurante.includes(:pontos_acesso).order(:id)
    @catracas = PontoAcesso.includes(:restaurante).order(:id)
  end

  def create
    ActiveRecord::Base.transaction do
      restaurante = GerenciarRestauranteCatraca.cadastrar_restaurante(
        id: params[:codigo],
        nome: params[:nome],
        campus: params[:campus].presence || "UnB Darcy Ribeiro"
      )

      if params[:catraca_codigo].present?
        catraca = PontoAcesso.find_by(id: params[:catraca_codigo].to_s.strip.to_i)
        if catraca
          GerenciarRestauranteCatraca.associar_catraca!(catraca_id: catraca.id, restaurante: restaurante)
        else
          GerenciarRestauranteCatraca.cadastrar_catraca(
            id: params[:catraca_codigo],
            restaurante: restaurante
          )
        end
      end

      GerenciarRestauranteCatraca.validar_restaurante_com_catraca!(restaurante)
    end

    redirect_to restaurantes_path, notice: "Restaurante cadastrado com sucesso!"
  rescue GerenciarRestauranteCatraca::ErroValidacao => erro
    redirect_to restaurantes_path, alert: erro.message
  end

  def associar_catraca
    restaurante = Restaurante.find(params[:id])
    GerenciarRestauranteCatraca.associar_catraca!(
      catraca_id: params[:catraca_codigo],
      restaurante: restaurante
    )
    redirect_to restaurantes_path, notice: "Catraca associada com sucesso!"
  rescue GerenciarRestauranteCatraca::ErroValidacao => erro
    redirect_to restaurantes_path, alert: erro.message
  end

  def destroy
    Restaurante.find(params[:id]).destroy
    redirect_to restaurantes_path, notice: "Restaurante removido."
  end
end
