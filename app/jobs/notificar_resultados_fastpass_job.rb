class NotificarResultadosFastpassJob < ApplicationJob
  def perform(turno_id)
    turno = TurnoFastpass.find_by(id: turno_id)
    NotificarResultadosFastpass.executar(turno: turno) if turno
  end
end
