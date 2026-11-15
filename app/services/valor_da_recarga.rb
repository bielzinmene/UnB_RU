class ValorDaRecarga
  class ValorInvalido < StandardError; end

  def self.converter(texto)
    valor = texto.to_s.strip.sub(/\AR\$\s*/, "")

    if valor.empty?
      raise ValorInvalido, "Selecione um valor"
    end

    if valor.match?(/\A-?\d+[,.]\d\z/)
      raise ValorInvalido, "Complete as casas decimais"
    end

    unless valor.match?(/\A-?\d+(?:[,.]\d{2})?\z/)
      raise ValorInvalido, "Informe um valor válido"
    end

    quantia = BigDecimal(valor.tr(",", "."))

    if quantia.zero?
      raise ValorInvalido, "Selecione um valor"
    end

    if quantia.negative?
      raise ValorInvalido, "Selecione um valor positivo"
    end

    quantia
  end
end
