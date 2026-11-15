Dado("que não existe configuração de {string} para {string}") do |tipo, data_str|
  TurnoFastpass.where(tipo_refeicao: tipo, data: Date.parse(data_str)).destroy_all
end

Dado(/^que não existe configuração de "([^"]*)" para (\d{2}\/\d{2}\/\d{4})$/) do |tipo, data_str|
  TurnoFastpass.where(tipo_refeicao: tipo, data: Date.strptime(data_str, "%d/%m/%Y")).destroy_all
end

Dado(/^que o turno "([^"]*)" de (\d{2}\/\d{2}\/\d{4}) funciona das "([^"]*)" às "([^"]*)"$/) do |tipo, data_str, inicio, fim|
  @turno_atual = TurnoFastpass.find_or_create_by!(
    tipo_refeicao: tipo,
    data: Date.strptime(data_str, "%d/%m/%Y")
  ) do |t|
    t.inicio = inicio
    t.fim = fim
  end
end

Dado(/^que já existe a faixa das "([^"]*)" às "([^"]*)" nesse turno$/) do |inicio, fim|
  @turno_atual.faixas_fastpass.create!(inicio: inicio, fim: fim)
end

Dado(/^que o turno "([^"]*)" de (\d{2}\/\d{2}\/\d{4}) já possui a faixa das "([^"]*)" às "([^"]*)"$/) do |tipo, data_str, inicio, fim|
  turno = TurnoFastpass.find_or_create_by!(
    tipo_refeicao: tipo,
    data: Date.strptime(data_str, "%d/%m/%Y"),
    inicio: "11:00",
    fim: "14:00"
  )
  turno.faixas_fastpass.create!(inicio: inicio, fim: fim)
end

Quando(/^defino o turno "([^"]*)" de (\d{2}\/\d{2}\/\d{4}) das "([^"]*)" às "([^"]*)"$/) do |tipo, data_str, inicio, fim|
  @turno_atual = TurnoFastpass.create!(
    tipo_refeicao: tipo,
    data: Date.strptime(data_str, "%d/%m/%Y"),
    inicio: inicio,
    fim: fim
  )
end

Quando("configuro as seguintes faixas para esse turno:") do |tabela|
  @faixas_esperadas = tabela.hashes
  @faixas_esperadas.each do |linha|
    @turno_atual.faixas_fastpass.create!(inicio: linha["início"], fim: linha["fim"])
  end
end

Quando("configuro a faixa das {string} às {string}") do |inicio, fim|
  @turno_atual.faixas_fastpass.create!(inicio: inicio, fim: fim)
end

Quando("tento configurar outra faixa das {string} às {string} nesse turno") do |inicio, fim|
  @faixa_tentativa = @turno_atual.faixas_fastpass.create(inicio: inicio, fim: fim)
end

Quando("tento configurar uma faixa das {string} às {string} nesse turno") do |inicio, fim|
  @faixa_tentativa = @turno_atual.faixas_fastpass.create(inicio: inicio, fim: fim)
end

Quando(/^tento definir o turno "([^"]*)" de (\d{2}\/\d{2}\/\d{4}) das "([^"]*)" às "([^"]*)"$/) do |tipo, data_str, inicio, fim|
  unless @usuario_atual&.administrador?
    @mensagem_erro = "Acesso restrito a administradores"
    @configuracao_aceita = false
    next
  end

  @turno_tentado = TurnoFastpass.new(
    tipo_refeicao: tipo,
    data: Date.strptime(data_str, "%d/%m/%Y"),
    inicio: inicio,
    fim: fim
  )
  unless @turno_tentado.save
    @mensagem_erro = @turno_tentado.errors.full_messages.join(", ")
    @configuracao_aceita = false
  end
end

Então(/^o turno "([^"]*)" de (\d{2}\/\d{2}\/\d{4}) deve funcionar das "([^"]*)" às "([^"]*)"$/) do |tipo, data_str, inicio, fim|
  turno = TurnoFastpass.find_by!(tipo_refeicao: tipo, data: Date.strptime(data_str, "%d/%m/%Y"))
  expect(turno.inicio).to eq(inicio)
  expect(turno.fim).to eq(fim)
end

Então("deve oferecer exatamente as faixas configuradas") do
  faixas = @turno_atual.faixas_fastpass.order(:inicio).map { |f| { "início" => f.inicio, "fim" => f.fim } }
  expect(faixas).to eq(@faixas_esperadas)
end

Então(/^as duas faixas devem ser aceitas para o turno "([^"]*)" de (\d{2}\/\d{2}\/\d{4})$/) do |tipo, data_str|
  turno = TurnoFastpass.find_by!(tipo_refeicao: tipo, data: Date.strptime(data_str, "%d/%m/%Y"))
  expect(turno.faixas_fastpass.count).to eq(2)
end

Então("o intervalo das {string} às {string} deve permanecer sem FastPass") do |inicio, fim|
  expect(@turno_atual.faixas_fastpass.exists?(inicio: inicio, fim: fim)).to be(false)
end

Então(/^o turno "([^"]*)" de (\d{2}\/\d{2}\/\d{4}) deve oferecer exatamente essas duas faixas$/) do |tipo, data_str|
  turno = TurnoFastpass.find_by!(tipo_refeicao: tipo, data: Date.strptime(data_str, "%d/%m/%Y"))
  expect(turno.faixas_fastpass.count).to eq(2)
end

Então("a faixa do turno {string} deve permanecer cadastrada") do |tipo|
  turno = TurnoFastpass.find_by!(tipo_refeicao: tipo)
  expect(turno.faixas_fastpass.count).to eq(1)
end

Então("a nova faixa deve ser recusada por sobreposição") do
  expect(@faixa_tentativa).not_to be_persisted
  expect(@faixa_tentativa.errors.full_messages.join).to include("sobreposição")
end

Então("a nova faixa deve ser recusada por estar fora do horário do turno") do
  expect(@faixa_tentativa).not_to be_persisted
  expect(@faixa_tentativa.errors.full_messages.join).to include("fora do horário do turno")
end

Então("a nova faixa deve ser recusada por ter horário inválido") do
  expect(@faixa_tentativa).not_to be_persisted
  expect(@faixa_tentativa.errors.full_messages.join).to include("horário inválido")
end

Então("a faixa das {string} às {string} deve permanecer cadastrada") do |inicio, fim|
  expect(@turno_atual.faixas_fastpass.exists?(inicio: inicio, fim: fim)).to be(true)
end

Então("nenhuma faixa das {string} às {string} deve ser cadastrada") do |inicio, fim|
  expect(@turno_atual.faixas_fastpass.exists?(inicio: inicio, fim: fim)).to be(false)
end

Então("o turno deve ser recusado por ter horário inválido") do
  expect(@turno_tentado&.persisted?).to be_falsy
  expect(@mensagem_erro).to be_present
end

Então(/^o turno "([^"]*)" de (\d{2}\/\d{2}\/\d{4}) não deve ser criado$/) do |tipo, data_str|
  expect(TurnoFastpass.exists?(tipo_refeicao: tipo, data: Date.strptime(data_str, "%d/%m/%Y"))).to be(false)
end
