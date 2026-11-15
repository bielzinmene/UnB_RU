
  class RestaurantesController < ApplicationController
    before_action :exigir_administrador

    def index
      @restaurantes = Restaurante.includes(:catracas).order(:codigo)
      @catracas = Catraca.includes(:restaurante).order(:codigo)
    end

    def create
      restaurante = GerenciarRestauranteCatraca.cadastrar_restaurante(
        codigo: params[:codigo],
        nome: params[:nome]
      )
      if params[:catraca_codigo].present?
        catraca = Catraca.find_by(codigo: params[:catraca_codigo].to_i) ||
                  GerenciarRestauranteCatraca.cadastrar_catraca(codigo: params[:catraca_codigo])
        GerenciarRestauranteCatraca.associar_catraca!(catraca_codigo: catraca.codigo, restaurante_codigo: restaurante.codigo)
      end
      GerenciarRestauranteCatraca.validar_restaurante_com_catraca!(restaurante)
      redirect_to restaurantes_path, notice: "Restaurante cadastrado com sucesso!"
    rescue GerenciarRestauranteCatraca::ErroValidacao => erro
      redirect_to restaurantes_path, alert: erro.message
    end

    def associar_catraca
      GerenciarRestauranteCatraca.associar_catraca!(
        catraca_codigo: params[:catraca_codigo],
        restaurante_codigo: params[:id]
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
