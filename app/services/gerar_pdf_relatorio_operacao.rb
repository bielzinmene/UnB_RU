class GerarPdfRelatorioOperacao
  class SemOperacao < StandardError; end

  def self.executar(relatorio:)
    raise SemOperacao, "Não há operação no período informado." if
      relatorio.vazio?

    documento = Prawn::Document.new(page_size: "A4", margin: 40)
    configurar_fonte(documento)
    cabecalho(documento, relatorio)
    resumo(documento, relatorio)
    tabela(documento, relatorio)
    documento.number_pages(
      "Página <page> de <total>",
      at: [ 0, 0 ],
      align: :right,
      size: 9
    )
    documento.render
  end

  def self.configurar_fonte(documento)
    documento.font_families.update(
      "DejaVu" => {
        normal: Rails.root.join("app/assets/fonts/DejaVuSans.ttf").to_s,
        bold: Rails.root.join("app/assets/fonts/DejaVuSans-Bold.ttf").to_s
      }
    )
    documento.font "DejaVu"
  end

  def self.cabecalho(documento, relatorio)
    documento.fill_color "073B80"
    documento.text "RU UnB", size: 22, style: :bold
    documento.text "Relatório Global de Operação", size: 17, style: :bold
    documento.fill_color "172336"
    documento.move_down 14
    documento.text "Data: #{relatorio.data.strftime('%d/%m/%Y')}"
    documento.text "Turno: #{relatorio.turno}"
    documento.text "Campus: #{relatorio.campus}"
    documento.text "Emitido em: #{Time.current.strftime('%d/%m/%Y %H:%M')}"
  end

  def self.resumo(documento, relatorio)
    documento.move_down 18
    documento.text "Resumo operacional", size: 14, style: :bold
    documento.text "Acessos: #{relatorio.acessos.size}"
    documento.text "Liberados: #{relatorio.liberados.size}"
    documento.text "Bloqueados: #{relatorio.bloqueados.size}"
    documento.text "Arrecadação: #{formatar_valor(relatorio.total_arrecadado)}"
  end

  def self.tabela(documento, relatorio)
    documento.move_down 18
    documento.text "Registros", size: 14, style: :bold
    relatorio.acessos.each do |acesso|
      documento.move_down 6
      documento.text [
        acesso.ocorrido_em.strftime("%d/%m/%Y %H:%M"),
        acesso.refeicao,
        acesso.ponto_acesso.identificador,
        acesso.matricula,
        acesso.resultado,
        formatar_valor(acesso.valor_debitado)
      ].join(" | "), size: 9
    end
  end

  def self.formatar_valor(valor)
    ActiveSupport::NumberHelper.number_to_currency(
      valor,
      unit: "R$ ",
      separator: ",",
      delimiter: "."
    )
  end
end
