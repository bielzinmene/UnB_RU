module ApoioNotificacaoFastpass
  def turno_notificacao(tipo, data, inicio)
    TurnoFastpass.find_or_create_by!(tipo_refeicao: tipo, data: data) do |turno|
      turno.inicio = inicio
      turno.fim = tipo == "Jantar" ? "20:00" : "14:00"
    end
  end

  def inscrever_para_notificacao(nome, tipo, inicio, fim)
    turno = tipo == "Jantar" ? @turno_jantar_notificacao : @turno_almoco_notificacao
    estudante = criar_estudante_saldo(nome)
    faixa = turno.faixas_fastpass.find_or_create_by!(inicio: inicio, fim: fim)
    InscricaoFastpass.find_or_create_by!(user: estudante, turno_fastpass: turno,
      faixa_fastpass: faixa)
  end

  def concluir_para_notificacao(turno, nomes_sorteados)
    turno.inscricoes_fastpass.includes(:user).find_each do |inscricao|
      inscricao.update!(sorteado: nomes_sorteados.include?(inscricao.user.nome))
    end
    turno.update!(sorteio_concluido_em: Time.current)
  end
end

World(ApoioNotificacaoFastpass)

Dado(/^que o almoço de (\d{2}\/\d{2}\/\d{4}) começa às "([^"]*)"$/) do |data, inicio|
  @turno_almoco_notificacao = turno_notificacao("Almoço",
    Date.strptime(data, "%d/%m/%Y"), inicio)
end

Dado(/^que o jantar de (\d{2}\/\d{2}\/\d{4}) começa às "([^"]*)"$/) do |data, inicio|
  @turno_jantar_notificacao = turno_notificacao("Jantar",
    Date.strptime(data, "%d/%m/%Y"), inicio)
end

Dado(/^que [oa] estudante "([^"]*)" está inscrit[oa] na faixa das "([^"]*)" às "([^"]*)" desse almoço$/) do |nome, inicio, fim|
  inscrever_para_notificacao(nome, "Almoço", inicio, fim)
end

Dado(/^que [oa] estudante "([^"]*)" está inscrit[oa] na faixa das "([^"]*)" às "([^"]*)" desse jantar$/) do |nome, inicio, fim|
  inscrever_para_notificacao(nome, "Jantar", inicio, fim)
end

Dado(/^que [oa] estudante "([^"]*)" não está inscrit[oa] nesse almoço$/) do |nome|
  estudante = criar_estudante_saldo(nome)
  expect(estudante.inscricoes_fastpass).to be_empty
end

Dado(/^que o sorteio do almoço de (\d{2}\/\d{2}\/\d{4}) selecionou a estudante "([^"]*)"$/) do |_data, nome|
  concluir_para_notificacao(@turno_almoco_notificacao, [ nome ])
end

Dado(/^que o sorteio do almoço de (\d{2}\/\d{2}\/\d{4}) não selecionou o estudante "([^"]*)"$/) do |_data, _nome|
  concluir_para_notificacao(@turno_almoco_notificacao, [])
end

Dado(/^que o sorteio do jantar de (\d{2}\/\d{2}\/\d{4}) selecionou "([^"]*)"$/) do |_data, nome|
  concluir_para_notificacao(@turno_jantar_notificacao, [ nome ])
end

Dado(/^que "([^"]*)" já recebeu a notificação desse resultado às "([^"]*)"$/) do |nome, hora|
  horario = Time.zone.parse("2026-10-20 #{hora}")
  NotificarResultadosFastpass.executar(agora: horario)
  expect(User.find_by!(nome: nome).inscricoes_fastpass.sole.notificacao_fastpass).to be_present
end

Dado(/^que o sorteio do almoço de (\d{2}\/\d{2}\/\d{4}) foi concluído$/) do |_data|
  concluir_para_notificacao(@turno_almoco_notificacao, [])
end

Quando(/^chega (\d{2}\/\d{2}\/\d{4}) às "([^"]*)"$/) do |data, hora|
  travel_to Time.zone.strptime("#{data} #{hora}", "%d/%m/%Y %H:%M")
end

Quando("o sistema processa as notificações do sorteio") do
  NotificarResultadosFastpass.executar
end

Quando("o sistema tenta enviar novamente os resultados do mesmo sorteio") do
  NotificarResultadosFastpass.executar(agora: Time.zone.parse("2026-10-20 10:00"))
end

Então(/^"([^"]*)" deve receber uma notificação no sistema informando que (não ganhou|ganhou) o FastPass$/) do |nome, resultado|
  @notificacao_verificada = User.find_by!(nome: nome).inscricoes_fastpass.sole.notificacao_fastpass
  expect(@notificacao_verificada.mensagem).to include(resultado)
end

Então(/^a notificação deve indicar o (almoço|jantar) de (\d{2}\/\d{2}\/\d{4}) e a faixa das "([^"]*)" às "([^"]*)"$/) do |tipo, data, inicio, fim|
  expect(@notificacao_verificada.mensagem).to include(tipo.capitalize, data, "#{inicio} às #{fim}")
end

Então(/^a notificação deve indicar o almoço de (\d{2}\/\d{2}\/\d{4})$/) do |data|
  expect(@notificacao_verificada.mensagem).to include("Almoço", data)
end

Então(/^"([^"]*)" deve (continuar com exatamente|ter exatamente) uma notificação desse resultado$/) do |nome, _verbo|
  inscricao = User.find_by!(nome: nome).inscricoes_fastpass.sole
  expect(NotificacaoFastpass.where(inscricao_fastpass: inscricao).count).to eq(1)
end

Então(/^"([^"]*)" não deve receber a notificação do resultado desse almoço$/) do |nome|
  expect(User.find_by!(nome: nome).inscricoes_fastpass.sole.notificacao_fastpass).to be_nil
end

Então(/^"([^"]*)" não deve receber notificação desse sorteio$/) do |nome|
  estudante = User.find_by!(nome: nome)
  expect(NotificacaoFastpass.joins(:inscricao_fastpass)
    .where(inscricoes_fastpass: { user_id: estudante.id })).to be_empty
end
