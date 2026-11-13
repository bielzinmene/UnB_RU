class ValidacoesController < ApplicationController
  before_action :exigir_funcionario
  before_action :carregar_ponto

  def show
    @ultimos_acessos = @ponto_acesso.acessos
      .includes(:user)
      .mais_recentes
      .limit(8)
  end

  def create
    @ultimo_acesso = ValidarEntrada.executar(
      matricula: params[:matricula],
      ponto_acesso: @ponto_acesso
    )
    @ultimos_acessos = @ponto_acesso.acessos
      .includes(:user)
      .mais_recentes
      .limit(8)
    render :show,
      status: (@ultimo_acesso.liberado? ? :ok : :unprocessable_content)
  end

  private

  def carregar_ponto
    @ponto_acesso = PontoAcesso.find_by(id: session[:ponto_acesso_id])
    return if @ponto_acesso

    redirect_to area_funcionario_path,
      alert: "Selecione um ponto de acesso antes de iniciar a validação."
  end
end
