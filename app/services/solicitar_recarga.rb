class SolicitarRecarga
  class Erro < StandardError; end

  def self.executar(usuario:, valor:, forma_pagamento:, dados_cartao: {})
    unless Rails.env.development? || Rails.env.test?
      raise Erro, "O pagamento de demonstração não está disponível neste ambiente."
    end

    quantia = ValorDaRecarga.converter(valor)

    unless %w[pix cartao].include?(forma_pagamento)
      raise Erro, "Selecione uma forma de pagamento"
    end

    if forma_pagamento == "cartao"
      cartao = DadosDoCartao.new(dados_cartao)

      unless cartao.valid?
        raise Erro, cartao.errors.full_messages.join(" ")
      end
    end

    usuario.with_lock do
      unless usuario.estudante?
        raise Erro, "Acesso permitido apenas a estudantes."
      end

      if usuario.isento?
        raise Erro, "Estudantes do grupo 1 são isentos e não podem realizar recargas."
      end

      usuario.recargas
        .where(forma_pagamento: "pix", situacao: "pendente")
        .where("expira_em <= ?", Time.current)
        .update_all(situacao: "cancelada", updated_at: Time.current)

      valor_pendente = usuario.recargas
        .where(situacao: "pendente")
        .sum(:valor)

      if usuario.saldo + valor_pendente + quantia > 500
        raise Erro, "O valor final do seu saldo não pode exceder R$500,00"
      end

      atributos = {
        valor: quantia,
        forma_pagamento: forma_pagamento,
        situacao: "pendente"
      }

      if forma_pagamento == "pix"
        atributos[:codigo_pix] = "DEMONSTRACAO-#{SecureRandom.hex(16)}"
        atributos[:expira_em] = 10.minutes.from_now
      else
        # Aprovação fictícia, somente para a demonstração.
        atributos[:situacao] = "confirmada"
        atributos[:confirmada_em] = Time.current

        usuario.update!(saldo: usuario.saldo + quantia)
      end

      usuario.recargas.create!(atributos)
    end
  rescue ValorDaRecarga::ValorInvalido => erro
    raise Erro, erro.message
  end
end
