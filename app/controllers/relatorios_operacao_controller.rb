class RelatoriosOperacaoController < ApplicationController
  before_action :exigir_administrador

  def show
    @data = data_param
    @turno = params[:turno].presence || "Todos"
    @campus = params[:campus].presence || "Campus Darcy Ribeiro"
    @relatorio = RelatorioOperacao.new(
      data: @data,
      turno: @turno,
      campus: @campus
    )

    respond_to do |formato|
      formato.html
      formato.pdf do
        arquivo = GerarPdfRelatorioOperacao.executar(
          relatorio: @relatorio
        )
        send_data arquivo,
          filename: "relatorio-operacao-#{@data.iso8601}.pdf",
          type: "application/pdf",
          disposition: "attachment"
      end
    end
  rescue GerarPdfRelatorioOperacao::SemOperacao => erro
    redirect_to relatorio_operacao_path(
      data: @data,
      turno: @turno,
      campus: @campus
    ), alert: erro.message
  end

  private

  def data_param
    Date.strptime(params[:data], "%Y-%m-%d")
  rescue Date::Error, TypeError
    Date.current
  end
end
