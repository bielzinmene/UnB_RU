class RelatorioAcessosController < ApplicationController
  before_action :exigir_administrador

  def show
    @consulta = ConsultarRelatorioGlobalAcessos.new(
      restaurante: params[:restaurante],
      catraca: params[:catraca],
      agrupar_por: params[:agrupar_por]
    )
    @registros = @consulta.registros
    @grupos = @consulta.agrupado
  end
end
