
  class TurnosFastpassController < ApplicationController
    before_action :exigir_administrador

    def index
      @turnos = TurnoFastpass.includes(:faixas_fastpass).order(data: :desc, inicio: :asc)
    end

    def create
      turno = TurnoFastpass.new(
        data: params[:data],
        tipo_refeicao: params[:tipo_refeicao],
        inicio: params[:inicio],
        fim: params[:fim]
      )

      if turno.save
        redirect_to turnos_fastpass_index_path, notice: "Turno configurado com sucesso!"
      else
        redirect_to turnos_fastpass_index_path, alert: turno.errors.full_messages.join(", ")
      end
    end
  end
