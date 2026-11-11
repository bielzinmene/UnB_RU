require "json"

class CardapioSemanal
  DIAS = %w[domingo segunda-feira terca-feira quarta-feira quinta-feira sexta-feira sabado].freeze
  HORARIOS = {
    "cafe_da_manha" => [ "07:00", "09:30" ],
    "almoco" => [ "11:00", "14:30" ],
    "jantar" => [ "17:00", "19:30" ]
  }.freeze

  def self.para(data, arquivo: ENV.fetch("CARDAPIO_FILE", Rails.root.join("cardapio.json").to_s))
    dados = JSON.parse(File.read(arquivo))
    dia = dados.fetch(DIAS.fetch(data.wday))

    HORARIOS.map do |tipo, (inicio, fim)|
      menu = dia.fetch(tipo)
      prefixo = tipo == "cafe_da_manha" ? "complemento" : "prato_principal"
      Refeicao.new(
        data: data, tipo: tipo, inicio: inicio, fim: fim,
        opcao_padrao: menu.fetch("#{prefixo}_padrao"),
        opcao_ovolactovegetariana: menu.fetch("#{prefixo}_ovolactovegetariano"),
        opcao_vegetariana_estrita: menu.fetch("#{prefixo}_vegetariano_estrito")
      )
    end
  rescue Errno::ENOENT, JSON::ParserError, KeyError
    []
  end
end
