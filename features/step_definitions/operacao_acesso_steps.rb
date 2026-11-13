require "pdf/reader"
require "stringio"
require "ostruct"

module ApoioOperacaoAcesso
  def restaurante_operacional(nome: "Restaurante Universitário n°5",
    campus: "UnB Darcy Ribeiro")
    Restaurante.find_or_create_by!(nome: nome, campus: campus)
  end

  def ponto_operacional(identificador: "RU05", id: nil,
    status: "Ativo", campus: "UnB Darcy Ribeiro")
    restaurante = restaurante_operacional(campus: campus)
    ponto = PontoAcesso.find_or_initialize_by(identificador: identificador)
    ponto.id = id if id && ponto.new_record?
    ponto.assign_attributes(
      nome: "Restaurante Universitário número 5",
      campus: campus,
      status: status,
      restaurante: restaurante
    )
    ponto.save!
    ponto
  end

  def estudante_operacional(nome: "Cleiton", matricula: "251024222",
    saldo: 15)
    User.find_or_initialize_by(matricula: matricula).tap do |estudante|
      estudante.assign_attributes(
        nome: nome,
        role: "estudante",
        saldo: saldo,
        password: "Teste@1234",
        password_confirmation: "Teste@1234"
      )
      estudante.save!
    end
  end

  def autenticar_operador(nome:, role:)
    usuario = User.create!(
      nome: nome,
      role: role,
      siape: role == "administrador" ? "108392-1" : "294810-2",
      password: "Teste@1234"
    )
    enviar_login(usuario.siape, "Teste@1234")
    usuario
  end

  def texto_pdf_operacao
    expect(page.response_headers["content-type"]).to include("application/pdf")
    PDF::Reader.new(StringIO.new(page.body)).pages.map(&:text).join("\n")
  end
end

World(ApoioOperacaoAcesso)

Dado(/^que a data atual é "(\d{2})\/(\d{2})\/(\d{4})"$/) do |dia, mes, ano|
  travel_to Time.zone.local(ano.to_i, mes.to_i, dia.to_i, 12, 0)
end

Dado(/^que o Restaurante Universitário n°5 está cadastrado no sistema$/) do
  @restaurante = restaurante_operacional
end

Dado("que o administrador {string} está autenticado e autorizado a configurar pontos de acesso") do |nome|
  @administrador = autenticar_operador(nome: nome, role: "administrador")
end

Dado("que não existe um ponto de acesso com o número RU05") do
  PontoAcesso.where(identificador: "RU05").delete_all
end

Dado("que não existe um ponto de acesso com identificador {string}") do |identificador|
  PontoAcesso.where(identificador: identificador).delete_all
end

Quando("preencho a configuração com identificador {string}, nome {string}, campus {string} e status {string}") do |identificador, nome, campus, status|
  @dados_ponto = {
    identificador: identificador,
    nome: nome,
    campus: campus,
    status: status,
    restaurante: @restaurante || restaurante_operacional
  }
end

Quando("solicito o cadastro do ponto de acesso") do
  @ponto_tentado = PontoAcesso.new(@dados_ponto)
  @configuracao_aceita = @ponto_tentado.save
end

Então("o ponto de acesso {string} deve ser cadastrado") do |identificador|
  expect(PontoAcesso.exists?(identificador: identificador)).to be(true)
end

Dado("que existe um ponto de acesso com identificador {string} e status {string}") do |identificador, status|
  @ponto = ponto_operacional(identificador: identificador, status: status)
end

Quando("altero seu status para {string}") do |status|
  @ponto.status = status
end

Quando("solicito salvar as alterações") do
  @configuracao_aceita = @ponto.save
end

Então("o ponto de acesso {string} deve possuir status {string}") do |identificador, status|
  expect(PontoAcesso.find_by!(identificador: identificador).status).to eq(status)
end

Então("não deve autorizar novas entradas no RU") do
  expect(@ponto.reload.autoriza_entrada?).to be(false)
end

Então("a configuração deve ser recusada") do
  expect(@configuracao_aceita).to be(false)
end

Então("devo ser informado de que há um campo obrigatório não preenchido") do
  expect(@ponto_tentado.errors).not_to be_empty
end

Então("nenhum ponto de acesso deve ser criado") do
  expect(PontoAcesso.count).to eq(0)
end

Dado("que não existe campus chamado {string}") do |campus|
  expect(Restaurante::CAMPI).not_to include(campus)
end

Então("devo ser informado de que o campus informado não existe") do
  expect(@ponto_tentado.errors[:campus]).not_to be_empty
end

Quando("um estudante tenta acessar o RU utilizando o ponto de acesso {string}") do |identificador|
  estudante = estudante_operacional
  @acesso_operacional = ValidarEntrada.executar(
    matricula: estudante.matricula,
    ponto_acesso: PontoAcesso.find_by!(identificador: identificador)
  )
end

Então("nenhuma entrada deve ser autorizada por esse ponto de acesso") do
  expect(@acesso_operacional).not_to be_liberado
end

Dado("que não estou autenticado como administrador autorizado") do
  visit login_funcionario_path
end

Quando("tento cadastrar um ponto de acesso no RU") do
  visit pontos_acesso_path
  @configuracao_aceita = page.current_path == pontos_acesso_path
end

Dado("que existe um ponto de acesso com identificador {string}") do |identificador|
  @ponto = ponto_operacional(identificador: identificador)
end

Então("nenhum outro ponto de acesso com identificador {string} deve ser criado") do |identificador|
  expect(PontoAcesso.where(identificador: identificador).count).to eq(1)
end

Dado("que não existe um restaurante {string} cadastrado") do |nome|
  Restaurante.where(nome: nome).delete_all
end

Quando("tento cadastrar o ponto de acesso {string} no restaurante {string}") do |identificador, nome|
  @ponto_tentado = PontoAcesso.new(
    identificador: identificador,
    nome: "Entrada norte",
    campus: "UnB Darcy Ribeiro",
    status: "Ativo",
    restaurante: Restaurante.find_by(nome: nome)
  )
  @configuracao_aceita = @ponto_tentado.save
end

Dado("que o ponto de acesso {string} está cadastrado para o {string} da UnB") do |identificador, restaurante|
  @ponto = ponto_operacional(identificador: identificador)
  @ponto.restaurante.update!(nome: restaurante)
end

Quando("tentam usá-lo fora de um Restaurante Universitário da UnB") do
  restaurante_externo = Restaurante.new(
    nome: "Restaurante externo",
    campus: "UnB Darcy Ribeiro"
  )
  @autorizado_fora_da_unb = @ponto.autoriza_entrada?(restaurante_externo)
  @acesso_operacional = OpenStruct.new(liberado?: @autorizado_fora_da_unb)
end

Dado("que o valor da refeição do RU é de R$ 2,50") do
  expect(ValidarEntrada::VALOR_REFEICAO).to eq(BigDecimal("2.50"))
end

Dado(/^que o estudante "([^"]*)" possui a matrícula "([^"]*)" e um saldo de R\$ ([\d,.]+)$/) do |nome, matricula, saldo|
  @estudante_operacional = estudante_operacional(
    nome: nome,
    matricula: matricula,
    saldo: saldo.tr(".", "").tr(",", ".")
  )
  @saldo_inicial = @estudante_operacional.saldo
  @ponto = ponto_operacional
end

Quando("o sistema lê a identificação da matrícula {string}") do |matricula|
  @acesso_operacional = ValidarEntrada.executar(
    matricula: matricula,
    ponto_acesso: @ponto || ponto_operacional
  )
end

Então("o sistema envia o comando de liberação para a catraca") do
  expect(@acesso_operacional).to be_liberado
end

Então(/^o saldo da conta do estudante "([^"]*)" deve ser atualizado para R\$ ([\d,.]+)$/) do |nome, saldo|
  esperado = BigDecimal(saldo.tr(".", "").tr(",", "."))
  expect(User.find_by!(nome: nome).saldo).to eq(esperado)
end

Então("a catraca deve ser liberada") do
  expect(@acesso_operacional).to be_liberado
end

Então("a catraca deve permanecer bloqueada") do
  expect(@acesso_operacional).not_to be_liberado
end

Então("o sistema deve exibir a mensagem {string}") do |mensagem|
  expect(@acesso_operacional.motivo).to eq(mensagem)
end

Então("nenhum valor deve ser debitado da conta") do
  expect(@estudante_operacional.reload.saldo).to eq(@saldo_inicial)
  expect(@estudante_operacional.consumos).to be_empty
end

Dado("que não existe conta cadastrada com a matrícula {string}") do |matricula|
  User.where(matricula: matricula).delete_all
  @ponto = ponto_operacional
end

Então("nenhum valor deve ser debitado") do
  expect(@acesso_operacional.valor_debitado).to be_zero
  expect(Consumo.count).to eq(0)
end

Dado("que estou gerenciando a catraca de ID {string}") do |id|
  @funcionario_operacional ||= autenticar_operador(
    nome: "Carlos",
    role: "funcionario"
  )
  @ponto = ponto_operacional(
    identificador: "RU#{id.to_i.to_s.rjust(2, '0')}",
    id: id.to_i
  )
  visit area_funcionario_path
  click_button "Iniciar operação em #{@ponto.identificador}"
end

Dado("existem acessos registrados para esta catraca") do
  estudante = estudante_operacional
  ValidarEntrada.executar(
    matricula: estudante.matricula,
    ponto_acesso: @ponto,
    ocorrido_em: Time.zone.local(2026, 10, 16, 12, 30),
    refeicao: "Almoço"
  )
end

Quando("acesso o histórico") do
  visit historico_local_path
end

Então("devo visualizar a lista de acessos") do
  expect(page).to have_css(".operation-table tbody tr")
end

Então("devo visualizar a matrícula dos estudantes") do
  expect(page).to have_content(@estudante_operacional&.matricula || "251024222")
end

Então("devo visualizar a data e hora dos acessos") do
  expect(page).to have_content("16/10/2026 12:30:00")
end

Então("devo visualizar a refeição correspondente") do
  expect(page).to have_content("Almoço")
end

Então("devo visualizar o resultado de cada acesso") do
  expect(page).to have_content("Liberado")
end

Quando("tento acessar o histórico da catraca de ID {string}") do |id|
  ponto_operacional(
    identificador: "RU#{id.to_i.to_s.rjust(2, '0')}",
    id: id.to_i
  )
  visit historico_local_path(ponto_id: id)
end

Dado("não existem acessos registrados para esta catraca") do
  @ponto.acessos.delete_all
end

Então("devo ser informado que não existem acessos registrados") do
  expect(page).to have_content("Não existem acessos registrados para esta catraca")
end

Dado("que estou autenticado como administrador geral") do
  @administrador = autenticar_operador(
    nome: "Prof. Fernando Albuquerque",
    role: "administrador"
  )
end

Dado(/^que há operação em (\d{2}\/\d{2}\/\d{4}) no Campus Darcy Ribeiro$/) do |data|
  ponto = ponto_operacional(campus: "Campus Darcy Ribeiro")
  estudante = estudante_operacional
  dia = Date.strptime(data, "%d/%m/%Y")
  {
    "Café" => 8,
    "Almoço" => 12,
    "Jantar" => 18
  }.each do |refeicao, hora|
    ValidarEntrada.executar(
      matricula: estudante.matricula,
      ponto_acesso: ponto,
      ocorrido_em: Time.zone.local(dia.year, dia.month, dia.day, hora),
      refeicao: refeicao
    )
    estudante.update!(saldo: 15)
  end
end

Quando("filtro o relatório por data {string}, turno {string} e campus {string}") do |data, turno, campus|
  @filtros_relatorio = {
    data: Date.strptime(data, "%d/%m/%Y").iso8601,
    turno: turno,
    campus: campus
  }
end

Quando("solicito a exportação do PDF") do
  visit relatorio_operacao_path(
    **(@filtros_relatorio || {}),
    format: :pdf
  )
end

Então(/^o PDF deve ser gerado para (\d{2}\/\d{2}\/\d{4}), todos os turnos e o Campus Darcy Ribeiro$/) do |data|
  texto = texto_pdf_operacao
  expect(texto).to include(data, "Turno: Todos", "Campus: Campus Darcy Ribeiro")
  expect(texto).to include("Café", "Almoço", "Jantar")
end

Então("o PDF deve conter apenas o turno {string} de {string} no {string}") do |turno, data, campus|
  texto = texto_pdf_operacao
  expect(texto).to include(data, "Turno: #{turno}", "Campus: #{campus}")
  linhas = texto.lines.select { |linha| linha.include?(" | ") }
  expect(linhas).not_to be_empty
  expect(linhas.all? { |linha| linha.include?(" | #{turno} | ") }).to be(true)
end

Dado("que não estou autenticado como administrador geral") do
  visit login_funcionario_path
end

Dado(/^que não há operação em (\d{2}\/\d{2}\/\d{4}) no Campus Darcy Ribeiro$/) do |data|
  dia = Date.strptime(data, "%d/%m/%Y")
  Acesso.where(ocorrido_em: dia.all_day).delete_all
end

Então("devo ser informado de que não há operação no período") do
  expect(page).to have_content("Não há operação no período informado")
end
