class NotificarResultadosFastpassJob < ApplicationJob
  def perform(turno_id = nil)
    if turno_id
      turno = TurnoFastpass.find_by(id: turno_id)
      NotificarResultadosFastpass.executar(turno: turno) if turno
    else
      NotificarResultadosFastpass.executar
    end
  end
end
