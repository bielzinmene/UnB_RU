class OperacoesController < ApplicationController
  before_action :exigir_funcionario

  def iniciar
    ponto = PontoAcesso.find(params[:id])
    unless ponto.ativo?
      redirect_to area_funcionario_path,
        alert: "O ponto de acesso está inativo."
      return
    end

    session[:ponto_acesso_id] = ponto.id
    redirect_to terminal_validacao_path,
      notice: "Operação iniciada em #{ponto.identificador}."
  end
end
