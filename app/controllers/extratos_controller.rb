class ExtratosController < AreaEstudanteController
  def show
    if params[:matricula].present? &&
        params[:matricula] != usuario_atual.matricula
      render plain: "Você não pode exportar dados de outro estudante.",
        status: :forbidden
      return
    end

    @extrato = ExtratoDoEstudante.new(usuario_atual)

    respond_to do |formato|
      formato.html

      formato.pdf do
        arquivo = GerarPdfDoExtrato.executar(extrato: @extrato)

        send_data arquivo,
          filename: "extrato-#{usuario_atual.matricula}.pdf",
          type: "application/pdf",
          disposition: "attachment"
      end
    end
  rescue GerarPdfDoExtrato::SemRegistros => erro
    redirect_to extrato_path, alert: erro.message
  end
end
