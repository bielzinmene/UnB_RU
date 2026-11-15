class NotificarResultadosFastpass
  def self.executar(agora: Time.current, turno: nil)
    turnos = turno ? TurnoFastpass.where(id: turno.id) : TurnoFastpass.where.not(sorteio_concluido_em: nil)
    turnos.find_each do |item|
      next if agora < item.inicio_em - 1.hour

      item.inscricoes_fastpass.includes(:faixa_fastpass).find_each do |inscricao|
        next if inscricao.sorteado.nil?

        mensagem = if inscricao.sorteado?
          "Você ganhou o FastPass para #{item.tipo_refeicao} de #{item.data.strftime('%d/%m/%Y')}, " \
            "das #{inscricao.faixa_fastpass.inicio} às #{inscricao.faixa_fastpass.fim}."
        else
          "Você não ganhou o FastPass para #{item.tipo_refeicao} de #{item.data.strftime('%d/%m/%Y')}."
        end

        NotificacaoFastpass.find_or_create_by!(inscricao_fastpass_id: inscricao.id) do |notificacao|
          notificacao.mensagem = mensagem
          notificacao.enviada_em = agora
        end
      rescue ActiveRecord::RecordNotUnique
        next if NotificacaoFastpass.exists?(inscricao_fastpass_id: inscricao.id)

        raise
      end
    end
  end
end
