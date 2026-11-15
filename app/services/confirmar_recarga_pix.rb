class ConfirmarRecargaPix
  class Erro < StandardError; end

  def self.executar(recarga:)
    unless Rails.env.development? || Rails.env.test?
      raise Erro, "A confirmação de demonstração não está disponível neste ambiente."
    end

    usuario = recarga.user

    resultado = usuario.with_lock do
      recarga.reload

      unless recarga.pix?
        raise Erro, "Esta recarga não é PIX."
      end

      if recarga.confirmada?
        next :ja_confirmada
      end

      if recarga.situacao == "cancelada" || recarga.expirada?
        recarga.update!(situacao: "cancelada")
        next :cancelada
      end

      unless usuario.estudante? && !usuario.isento?
        raise Erro, "Este usuário não pode receber recargas."
      end

      if usuario.saldo + recarga.valor > 500
        raise Erro, "O valor final do seu saldo não pode exceder R$500,00"
      end

      usuario.update!(
        saldo: usuario.saldo + recarga.valor
      )

      recarga.update!(
        situacao: "confirmada",
        confirmada_em: Time.current
      )

      :confirmada
    end

    if resultado == :cancelada
      raise Erro, "Recarga PIX cancelada: prazo de dez minutos encerrado."
    end

    recarga
  end
end
