class HistoricosLocaisController < ApplicationController
  before_action :exigir_funcionario
  before_action :carregar_ponto

  def show
    if params[:ponto_id].present? &&
        params[:ponto_id].to_i != @ponto_acesso.id
      render plain: "Você não pode acessar o histórico de outra catraca.",
        status: :forbidden
      return
    end

    @acessos = @ponto_acesso.acessos
      .includes(:user)
      .mais_recentes
    @liberados = @acessos.count(&:liberado?)
    @total_debitado = @acessos.sum(&:valor_debitado)
  end

  private

  def carregar_ponto
    @ponto_acesso = PontoAcesso.find_by(id: session[:ponto_acesso_id])
    return if @ponto_acesso

    redirect_to area_funcionario_path,
      alert: "Selecione um ponto de acesso antes de consultar o histórico."
  end
end
