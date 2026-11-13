class PontosAcessoController < ApplicationController
  before_action :exigir_administrador
  before_action :buscar_ponto, only: [ :edit, :update ]

  def index
    @ponto_acesso = PontoAcesso.new(status: "Ativo")
    carregar_dados
  end

  def create
    @ponto_acesso = PontoAcesso.new(ponto_params)
    if @ponto_acesso.save
      redirect_to pontos_acesso_path,
        notice: "Ponto de acesso cadastrado com sucesso."
    else
      carregar_dados
      render :index, status: :unprocessable_content
    end
  end

  def edit
    carregar_dados
  end

  def update
    if @ponto_acesso.update(ponto_params)
      redirect_to pontos_acesso_path,
        notice: "Ponto de acesso atualizado com sucesso."
    else
      carregar_dados
      render :edit, status: :unprocessable_content
    end
  end

  private

  def buscar_ponto
    @ponto_acesso = PontoAcesso.find(params[:id])
  end

  def carregar_dados
    @restaurantes = Restaurante.order(:nome)
    @pontos_acesso = PontoAcesso.includes(:restaurante)
      .order(:identificador)
  end

  def ponto_params
    params.require(:ponto_acesso).permit(
      :identificador,
      :nome,
      :campus,
      :status,
      :restaurante_id
    )
  end
end
