class ValidarEntrada
  VALOR_REFEICAO = BigDecimal("2.50")

  def self.executar(matricula:, ponto_acesso:, ocorrido_em: Time.current,
    refeicao: refeicao_atual(ocorrido_em))
    new(
      matricula: matricula,
      ponto_acesso: ponto_acesso,
      ocorrido_em: ocorrido_em,
      refeicao: refeicao
    ).executar
  end

  def self.refeicao_atual(horario)
    case horario.hour
    when 0...10 then "Café"
    when 10...16 then "Almoço"
    else "Jantar"
    end
  end

  def initialize(matricula:, ponto_acesso:, ocorrido_em:, refeicao:)
    @matricula = matricula.to_s.strip
    @ponto_acesso = ponto_acesso
    @ocorrido_em = ocorrido_em
    @refeicao = refeicao
  end

  def executar
    return bloquear("Ponto de acesso inativo") unless ponto_acesso.ativo?

    estudante = User.find_by(role: "estudante", matricula: matricula)
    return bloquear("Matrícula não encontrada") unless estudante

    estudante.with_lock do
      return bloquear("Saldo insuficiente", estudante) if
        estudante.saldo < VALOR_REFEICAO

      estudante.update!(saldo: estudante.saldo - VALOR_REFEICAO)
      acesso = registrar("Liberado", estudante, VALOR_REFEICAO)
      estudante.consumos.create!(
        restaurante: ponto_acesso.restaurante.nome,
        valor_debitado: VALOR_REFEICAO,
        ocorrido_em: ocorrido_em,
        referencia: "acesso-#{acesso.id}"
      )
      acesso
    end
  end

  private

  attr_reader :matricula, :ponto_acesso, :ocorrido_em, :refeicao

  def bloquear(motivo, estudante = nil)
    registrar("Bloqueado", estudante, 0, motivo)
  end

  def registrar(resultado, estudante, valor, motivo = nil)
    ponto_acesso.acessos.create!(
      user: estudante,
      matricula: matricula,
      ocorrido_em: ocorrido_em,
      refeicao: refeicao,
      resultado: resultado,
      motivo: motivo,
      valor_debitado: valor
    )
  end
end
