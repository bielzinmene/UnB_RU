module ApoioInscricaoFastpass
  def estudante_fastpass(nome, matricula, saldo = 0)
    User.find_or_create_by!(matricula: matricula) do |usuario|
      usuario.nome = nome
      usuario.role = "estudante"
      usuario.saldo = saldo
      usuario.password = "Teste@1234"
      usuario.password_confirmation = "Teste@1234"
    end
  end

  def turno_fastpass(tipo, data)
    TurnoFastpass.find_by!(tipo_refeicao: tipo,
      data: Date.strptime(data, "%d/%m/%Y"))
  end

  def faixa_fastpass(tipo, data, inicio, fim)
    turno_fastpass(tipo, data).faixas_fastpass.find_by!(inicio: inicio, fim: fim)
  end
end

World(ApoioInscricaoFastpass)

Dado(/^que a estudante "([^"]*)" possui a matrícula "([^"]*)" e saldo de R\$ ([\d,.]+)$/) do |nome, matricula, saldo|
  @ana_fastpass = estudante_fastpass(nome, matricula,
    saldo.tr(".", "").tr(",", "."))
end

Dado("que existem as seguintes faixas de horário do FastPass:") do |tabela|
  tabela.hashes.each do |linha|
    tipo = linha["turno"]
    data = Date.strptime(linha["data"], "%d/%m/%Y")
    turno = TurnoFastpass.find_or_create_by!(tipo_refeicao: tipo, data: data) do |novo|
      novo.inicio = tipo == "Jantar" ? "18:00" : "11:00"
      novo.fim = tipo == "Jantar" ? "20:00" : "14:00"
    end
    turno.faixas_fastpass.create!(inicio: linha["início"], fim: linha["fim"])
  end
end

Dado(/^que não possuo inscrição para o (.+) de (\d{2}\/\d{2}\/\d{4})$/) do |tipo, data|
  expect(@ana_fastpass.inscricoes_fastpass.where(
    turno_fastpass: turno_fastpass(tipo.capitalize, data)
  )).to be_empty
end

Dado(/^que já estou inscrita na faixa das "([^"]*)" às "([^"]*)" para o (.+) de (\d{2}\/\d{2}\/\d{4})$/) do |inicio, fim, tipo, data|
  faixa = faixa_fastpass(tipo.capitalize, data, inicio, fim)
  @ana_fastpass.inscricoes_fastpass.create!(turno_fastpass: faixa.turno_fastpass,
    faixa_fastpass: faixa)
end

Quando(/^escolho a faixa das "([^"]*)" às "([^"]*)" para o (.+) de (\d{2}\/\d{2}\/\d{4})$/) do |inicio, fim, tipo, data|
  @turno_escolhido = turno_fastpass(tipo.capitalize, data)
  @faixa_escolhida = @turno_escolhido.faixas_fastpass.find_by(inicio: inicio, fim: fim)
  @faixa_escolhida ||= FaixaFastpass.find_by(inicio: inicio, fim: fim)
end

Quando("solicito minha inscrição no sorteio do FastPass") do
  @inscricoes_antes = InscricaoFastpass.count
  page.driver.post(inscricoes_fastpass_path, {
    turno_fastpass_id: @turno_escolhido.id,
    faixa_fastpass_id: @faixa_escolhida&.id || "99999999"
  })
end

Então("minha inscrição deve ser registrada nessa faixa") do
  expect(@ana_fastpass.inscricoes_fastpass.find_by!(faixa_fastpass: @faixa_escolhida)).to be_present
end

Então(/^meu saldo deve permanecer em R\$ ([\d,.]+)$/) do |saldo|
  expect(@ana_fastpass.reload.saldo).to eq(BigDecimal(saldo.tr(".", "").tr(",", ".")))
end

Então(/^minha inscrição para o (jantar|almoço) deve ser registrada$/) do |_tipo|
  expect(@ana_fastpass.inscricoes_fastpass.exists?(turno_fastpass: @turno_escolhido)).to be(true)
end

Então(/^minha inscrição para o (jantar|almoço) deve permanecer registrada$/) do |tipo|
  outro_turno = TurnoFastpass.find_by!(tipo_refeicao: tipo.capitalize)
  expect(@ana_fastpass.inscricoes_fastpass.exists?(turno_fastpass: outro_turno)).to be(true)
end

Então(/^minha inscrição para o (.+) de (\d{2}\/\d{2}\/\d{4}) deve ser registrada$/) do |tipo, data|
  expect(@ana_fastpass.inscricoes_fastpass.exists?(
    turno_fastpass: turno_fastpass(tipo.capitalize, data)
  )).to be(true)
end

Então(/^minha inscrição para o (.+) de (\d{2}\/\d{2}\/\d{4}) deve permanecer registrada$/) do |tipo, data|
  expect(@ana_fastpass.inscricoes_fastpass.exists?(
    turno_fastpass: turno_fastpass(tipo.capitalize, data)
  )).to be(true)
end

Então("a segunda inscrição deve ser recusada") do
  expect(InscricaoFastpass.count).to eq(@inscricoes_antes)
end

Então("minha inscrição original deve permanecer na faixa das {string} às {string}") do |inicio, fim|
  expect(@ana_fastpass.inscricoes_fastpass.find_by!(turno_fastpass: @turno_escolhido)
    .faixa_fastpass).to have_attributes(inicio: inicio, fim: fim)
end

Então(/^não deve existir outra inscrição minha para o (.+) de (\d{2}\/\d{2}\/\d{4})$/) do |tipo, data|
  expect(@ana_fastpass.inscricoes_fastpass.where(
    turno_fastpass: turno_fastpass(tipo.capitalize, data)
  ).count).to eq(1)
end

Então("a inscrição deve ser recusada porque a faixa não existe") do
  expect(InscricaoFastpass.count).to eq(@inscricoes_antes)
end

Então("a inscrição deve ser recusada porque a faixa pertence ao jantar") do
  expect(InscricaoFastpass.count).to eq(@inscricoes_antes)
end

Então(/^nenhuma inscrição minha deve ser criada para o (.+) de (\d{2}\/\d{2}\/\d{4})$/) do |tipo, data|
  expect(@ana_fastpass.inscricoes_fastpass.exists?(
    turno_fastpass: turno_fastpass(tipo.capitalize, data)
  )).to be(false)
end

Então("a inscrição deve ser recusada") do
  expect(InscricaoFastpass.count).to eq(@inscricoes_antes)
end

Então("devo ser informado de que preciso me autenticar como estudante") do
  expect(page.driver.response.location).to include(login_estudante_path)
end

Então("nenhuma inscrição deve ser criada") do
  expect(InscricaoFastpass.count).to eq(0)
end
