
  class FaixasFastpassController < ApplicationController
    before_action :exigir_administrador

    def create
      turno = TurnoFastpass.find(params[:turnos_fastpass_id])
      faixa = turno.faixas_fastpass.build(inicio: params[:inicio], fim: params[:fim])

      if faixa.save
        redirect_to turnos_fastpass_index_path, notice: "Faixa adicionada com sucesso!"
      else
        redirect_to turnos_fastpass_index_path, alert: faixa.errors.full_messages.join(", ")
      end
    end
  end
