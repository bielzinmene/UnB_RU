class ConfirmarResultadoFastpass
  class Erro < StandardError; end

  def self.executar(turno:, ids_sorteados:)
    ids = Array(ids_sorteados).map { |id| Integer(id.to_s, 10) }.uniq

    turno.with_lock do
      raise Erro, "O resultado deste turno já foi confirmado." if turno.sorteio_concluido_em?

      inscricoes = turno.inscricoes_fastpass.to_a
      ids_validos = inscricoes.map(&:id)
      raise Erro, "Inscrição de outro turno ou inexistente." unless (ids - ids_validos).empty?

      inscricoes.each { |inscricao| inscricao.update!(sorteado: ids.include?(inscricao.id)) }
      turno.update!(sorteio_concluido_em: Time.current)
    end

    NotificarResultadosFastpassJob.set(wait_until: turno.inicio_em - 1.hour).perform_later(turno.id)
    turno
  rescue ArgumentError, TypeError
    raise Erro, "Informe inscrições válidas para o sorteio."
  end
end
