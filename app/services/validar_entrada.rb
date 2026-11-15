class ValidarEntrada
  VALOR_REFEICAO = BigDecimal("2.50")

  def self.executar(matricula:, ponto_acesso:, ocorrido_em: Time.current,
    refeicao: refeicao_atual(ocorrido_em), valor_refeicao: VALOR_REFEICAO)
    new(
      matricula: matricula,
      ponto_acesso: ponto_acesso,
      ocorrido_em: ocorrido_em,
      refeicao: refeicao,
      valor_refeicao: valor_refeicao
    ).executar
  end

  def self.refeicao_atual(horario)
    case horario.hour
    when 0...10 then "Café"
    when 10...16 then "Almoço"
    else "Jantar"
    end
  end

  def initialize(matricula:, ponto_acesso:, ocorrido_em:, refeicao:, valor_refeicao:)
    @matricula = matricula.to_s.strip
    @ponto_acesso = ponto_acesso
    @ocorrido_em = ocorrido_em
    @refeicao = refeicao
    @valor_refeicao = BigDecimal(valor_refeicao.to_s)
  end

  def executar
    return bloquear("Ponto de acesso inativo") unless ponto_acesso.ativo?

    estudante = User.find_by(role: "estudante", matricula: matricula)
    return bloquear("Matrícula não encontrada") unless estudante

    estudante.with_lock do
      return bloquear("Entrada já registrada para este turno", estudante) if
        entrada_anterior?(estudante)

      if ponto_acesso.fastpass?
        motivo = impedimento_fastpass(estudante)
        return bloquear(motivo, estudante) if motivo
      end

      valor = estudante.isento? ? BigDecimal("0") : valor_refeicao

      return bloquear("Saldo insuficiente", estudante) if
        estudante.saldo < valor

      acesso = registrar("Liberado", estudante, valor)
      RegistrarConsumo.executar(
        usuario: estudante,
        restaurante: ponto_acesso.restaurante.nome,
        valor: valor.to_s("F"),
        ocorrido_em: ocorrido_em,
        referencia: "acesso-#{acesso.id}"
      )
      acesso
    end
  end

  private

  attr_reader :matricula, :ponto_acesso, :ocorrido_em, :refeicao, :valor_refeicao

  def entrada_anterior?(estudante)
    Acesso.where(user: estudante, resultado: "Liberado", refeicao: refeicao,
      ocorrido_em: ocorrido_em.all_day).exists?
  end

  def impedimento_fastpass(estudante)
    tipo_turno = refeicao == "Café" ? "Café da Manhã" : refeicao
    turno = TurnoFastpass.find_by(data: ocorrido_em.to_date, tipo_refeicao: tipo_turno)
    return "Resultado do FastPass indisponível" unless turno&.sorteio_concluido_em?

    inscricao = estudante.inscricoes_fastpass.find_by(turno_fastpass: turno) if turno
    return "Estudante não sorteado para o FastPass" unless inscricao&.sorteado?

    minutos = (ocorrido_em.hour * 60) + ocorrido_em.min
    faixa = inscricao.faixa_fastpass
    return if (faixa.inicio_minutos...faixa.fim_minutos).cover?(minutos)

    "Fora da faixa FastPass sorteada"
  end

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
