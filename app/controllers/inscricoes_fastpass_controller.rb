class InscricoesFastpassController < ApplicationController
  before_action :exigir_estudante

  def index
    @turnos = TurnoFastpass.includes(:faixas_fastpass).order(:data, :inicio)
    @inscricoes = usuario_atual.inscricoes_fastpass.includes(:turno_fastpass, :faixa_fastpass, :notificacao_fastpass)
      .order(created_at: :desc)
  end

  def create
    faixa = FaixaFastpass.find_by(id: params[:faixa_fastpass_id])
    return recusar("A faixa escolhida não existe.") unless faixa

    turno = faixa.turno_fastpass
    if params[:turno_fastpass_id].present? && params[:turno_fastpass_id].to_s != turno.id.to_s
      return recusar("A faixa não pertence ao turno escolhido.")
    end

    inscricao = usuario_atual.inscricoes_fastpass.build(
      turno_fastpass: turno,
      faixa_fastpass: faixa
    )

    if inscricao.save
      redirect_to inscricoes_fastpass_path, notice: "Inscrição no FastPass registrada."
    else
      recusar(inscricao.errors.full_messages.to_sentence)
    end
  rescue ActiveRecord::RecordNotUnique
    recusar("Você já possui inscrição para este dia e turno.")
  end

  private

  def exigir_estudante
    return if usuario_atual&.estudante?

    redirect_to login_estudante_path,
      alert: "Você precisa se autenticar como estudante para continuar."
  end

  def recusar(mensagem)
    redirect_to inscricoes_fastpass_path, alert: mensagem
  end
end
