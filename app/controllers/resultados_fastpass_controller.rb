class ResultadosFastpassController < ApplicationController
  before_action :exigir_administrador

  def create
    turno = TurnoFastpass.find(params[:turno_fastpass_id])
    ConfirmarResultadoFastpass.executar(turno: turno, ids_sorteados: params[:ganhadores])
    redirect_to turnos_fastpass_index_path, notice: "Resultado do FastPass confirmado."
  rescue ConfirmarResultadoFastpass::Erro => erro
    redirect_to turnos_fastpass_index_path, alert: erro.message
  end
end
