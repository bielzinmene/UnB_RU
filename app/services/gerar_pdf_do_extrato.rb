class GerarPdfDoExtrato
  class SemRegistros < StandardError; end

  def self.executar(extrato:)
    if extrato.vazio?
      raise SemRegistros, "Não há recargas nem refeições para exportar."
    end

    documento = Prawn::Document.new(
      page_size: "A4",
      margin: 40
    )

    documento.font_families.update(
      "DejaVu" => {
        normal: Rails.root.join(
          "app/assets/fonts/DejaVuSans.ttf"
        ).to_s,
        bold: Rails.root.join(
          "app/assets/fonts/DejaVuSans-Bold.ttf"
        ).to_s
      }
    )

    documento.font "DejaVu"

    documento.fill_color "073B80"
    documento.text "UnB RU", size: 22, style: :bold
    documento.text "Extrato e histórico do estudante", size: 16

    documento.fill_color "172336"
    documento.move_down 20

    documento.text "Estudante: #{extrato.estudante.nome}"
    documento.text "Matrícula: #{extrato.estudante.matricula}"
    documento.text "Emitido em: #{Time.current.strftime('%d/%m/%Y %H:%M')}"

    documento.move_down 20
    documento.text "Recargas", size: 15, style: :bold
    documento.move_down 10

    if extrato.recargas.empty?
      documento.text "Nenhuma recarga encontrada"
    else
      extrato.recargas.each do |recarga|
        data = recarga.confirmada_em.strftime("%d/%m/%Y %H:%M")
        valor = formatar_valor(recarga.valor)

        documento.text "#{data} | #{valor}"
        documento.move_down 6
      end
    end

    documento.move_down 20
    documento.text "Refeições", size: 15, style: :bold
    documento.move_down 10

    if extrato.consumos.empty?
      documento.text "Nenhum histórico de refeições encontrado"
    else
      extrato.consumos.each do |consumo|
        data = consumo.ocorrido_em.strftime("%d/%m/%Y %H:%M")
        valor = formatar_valor(consumo.valor_debitado)

        documento.text "#{data} | #{consumo.restaurante} | #{valor}"
        documento.move_down 6
      end
    end

    documento.number_pages(
      "Página <page> de <total>",
      at: [ 0, 0 ],
      align: :right,
      size: 9
    )

    documento.render
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
