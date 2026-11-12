class RecargasController < ApplicationController
  before_action :exigir_estudante
  before_action :exigir_estudante_pagante
  before_action :buscar_recarga, only: [ :show, :confirmar_pix ]

  def new
    CancelarPixExpirados.executar
  end

  def create
    dados = params
      .fetch(:recarga, ActionController::Parameters.new)
      .permit(:valor, :forma_pagamento)

    dados_cartao = params
      .fetch(:cartao, ActionController::Parameters.new)
      .permit(:numero, :cpf, :nome, :validade, :cvv)
      .to_h

    recarga = SolicitarRecarga.executar(
      usuario: usuario_atual,
      valor: dados[:valor],
      forma_pagamento: dados[:forma_pagamento],
      dados_cartao: dados_cartao
    )

    mensagem = if recarga.confirmada?
      "Créditos adicionados com sucesso!"
    else
      "Código PIX de demonstração gerado."
    end

    redirect_to recarga_path(recarga), notice: mensagem
  rescue SolicitarRecarga::Erro => erro
    flash.now[:alert] = erro.message
    render :new, status: :unprocessable_content
  end

  def show
    CancelarPixExpirados.executar
    @recarga.reload
  end

  def confirmar_pix
    ConfirmarRecargaPix.executar(recarga: @recarga)

    redirect_to recarga_path(@recarga),
      notice: "Créditos adicionados com sucesso!"
  rescue ConfirmarRecargaPix::Erro => erro
    redirect_to recarga_path(@recarga), alert: erro.message
  end

  private

  def exigir_estudante
    unless usuario_atual&.estudante?
      redirect_to login_estudante_path,
        alert: "Você precisa se autenticar como estudante para continuar."
    end
  end

  def exigir_estudante_pagante
    if usuario_atual.isento?
      redirect_to root_path,
        alert: "Estudantes do grupo 1 são isentos e não podem realizar recargas."
    end
  end

  def buscar_recarga
    @recarga = usuario_atual.recargas.find(params[:id])
  end
end
