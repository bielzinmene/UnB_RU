class RegistrarConsumo
  class Erro < StandardError; end

  def self.executar(
    usuario:,
    restaurante:,
    valor:,
    referencia:,
    ocorrido_em: Time.current
  )
    texto = valor.to_s

    unless texto.match?(/\A\d+(?:\.\d{1,2})?\z/)
      raise Erro, "Informe um valor de consumo válido."
    end

    quantia = BigDecimal(texto)

    if referencia.to_s.strip.empty?
      raise Erro, "Informe a referência da passagem."
    end

    usuario.with_lock do
      unless usuario.estudante?
        raise Erro, "O consumo deve pertencer a um estudante."
      end

      if usuario.isento? && !quantia.zero?
        raise Erro, "Estudantes do grupo 1 devem ter consumo sem cobrança."
      end

      consumo_existente = Consumo.find_by(referencia: referencia)

      if consumo_existente
        mesmos_dados =
          consumo_existente.user_id == usuario.id &&
          consumo_existente.restaurante == restaurante &&
          consumo_existente.valor_debitado == quantia

        unless mesmos_dados
          raise Erro, "Referência de passagem já utilizada."
        end

        next consumo_existente
      end

      if usuario.saldo < quantia
        raise Erro, "Saldo insuficiente"
      end

      consumo = usuario.consumos.create!(
        restaurante: restaurante,
        valor_debitado: quantia,
        ocorrido_em: ocorrido_em,
        referencia: referencia
      )

      usuario.update!(
        saldo: usuario.saldo - quantia
      )

      consumo
    end
  end
end
