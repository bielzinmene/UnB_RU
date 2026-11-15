module ApoioRecargaBdd
  def criar_estudante_saldo(nome, matricula = nil)
    User.find_by(nome: nome, role: "estudante") ||
      User.create!(
        nome: nome,
        matricula: matricula || "261#{format('%06d', User.count + 1)}",
        role: "estudante",
        password: "Teste@1234",
        password_confirmation: "Teste@1234",
        grupo_pagamento: "2"
      )
  end

  def entrar_estudante_saldo(nome)
    @estudante = criar_estudante_saldo(nome)

    visit login_estudante_path
    fill_in "Matrícula", with: @estudante.matricula
    fill_in "Senha de Acesso", with: "Teste@1234"
    click_button "Entrar"

    expect(page).to have_current_path(root_path)
  end

  def preencher_cartao_saldo
    unless page.has_field?("Número do cartão", visible: true)
      find("summary", text: "Dados do cartão de crédito").click
    end

    fill_in "Número do cartão", with: "4111111111111111"
    fill_in "CPF do titular", with: "52998224725"
    fill_in "Nome no cartão", with: "Bruno Teste"
    fill_in "Data de validade", with: 2.years.from_now.strftime("%m/%y")
    fill_in "Código de segurança", with: "123"
  end

  def preparar_cartao_saldo(valor)
    visit new_recarga_path
    fill_in "Valor da recarga", with: valor
    choose "Cartão de crédito"
    preencher_cartao_saldo
  end
end

World(ApoioRecargaBdd)

Before do |cenario|
  if cenario.location.to_s.include?("recarga_de_saldo.feature")
    @adaptador_anterior_recarga = ActiveJob::Base.queue_adapter
    ActiveJob::Base.queue_adapter = :test
  end
end

After do
  if @adaptador_anterior_recarga
    ActiveJob::Base.queue_adapter = @adaptador_anterior_recarga
  end
end

Dado(/^que estou autenticado como o estudante "([^"]*)" com saldo de R\$(\d+,\d{2})$/) do |nome, saldo|
  usuario = criar_estudante_saldo(nome)
  usuario.update!(saldo: BigDecimal(saldo.tr(",", ".")))

  entrar_estudante_saldo(nome)
end

Dado("que estou na página de créditos") do
  visit new_recarga_path
end

Quando(/^(?:eu )?preencho o valor da recarga com "([^"]*)"$/) do |valor|
  fill_in "Valor da recarga", with: valor
end

Quando("seleciono a opção de pagamento {string}") do |forma|
  choose forma
end

Quando("confirmo a solicitação de recarga") do
  click_button "Confirmar recarga"
end

Então("um código PIX deve ser gerado") do
  expect(page).to have_field(
    "Código PIX de demonstração",
    with: /DEMONSTRACAO-/
  )

  expect(@estudante.recargas.last.situacao).to eq("pendente")
end

Quando("o pagamento do PIX for confirmado pelo sistema") do
  click_button "Simular confirmação do PIX"
end

Então("o meu saldo atual deverá ser atualizado para {string}") do |valor|
  esperado = ValorDaRecarga.converter(valor)

  expect(@estudante.reload.saldo).to eq(esperado)

  formatado = ActiveSupport::NumberHelper.number_to_currency(
    esperado,
    unit: "R$ ",
    separator: ",",
    delimiter: "."
  )

  expect(page).to have_content(formatado)
end

Quando("preencho os dados válidos do cartão de crédito") do
  preencher_cartao_saldo
end

Quando("possuo limite disponível no cartão de crédito") do
  # O ambiente de teste utiliza aprovação fictícia.
  # Não há consulta de limite bancário nesta implementação.
  expect(Rails.env.test?).to be(true)
end

Então("a transação deve ser aprovada") do
  expect(@estudante.recargas.last.situacao).to eq("confirmada")
end

Então("o sistema deve impedir a operação") do
  expect(page.status_code).to eq(422)
  expect(@estudante.recargas.count).to eq(0)
end

Então("devo visualizar a mensagem de erro {string}") do |mensagem|
  expect(page).to have_content(mensagem)
end

Quando("eu preencho o dado {string} do cartão de crédito com {string}") do |dado, valor|
  preparar_cartao_saldo("R$30,00")

  campos = {
    "nº do cartão" => "Número do cartão",
    "CPF do titular" => "CPF do titular",
    "Código de segurança" => "Código de segurança",
    "validade" => "Data de validade"
  }

  fill_in campos.fetch(dado), with: valor
end

Quando("confirmo o cadastro do cartão") do
  click_button "Confirmar recarga"
end

Quando("solicito uma recarga de {string} por cartão de crédito") do |valor|
  preparar_cartao_saldo(valor)
end

Quando("deixo vazio o campo {string} do cartão") do |campo|
  campos = {
    "número do cartão" => "Número do cartão",
    "CPF do titular" => "CPF do titular",
    "nome no cartão" => "Nome no cartão",
    "data de validade" => "Data de validade",
    "código de segurança" => "Código de segurança"
  }

  fill_in campos.fetch(campo), with: ""
end

Então("a operação deve ser recusada") do
  if page.status_code == 403
    expect(page).to have_content(
      "Você não pode acessar o histórico de outra catraca."
    )
  else
    expect(page.status_code).to eq(422)
    expect(@estudante.recargas.count).to eq(0)
  end
end

Então(/^meu saldo deve permanecer em R\$(\d+,\d{2})$/) do |valor|
  expect(@estudante.reload.saldo).to eq(
    BigDecimal(valor.tr(",", "."))
  )
end

Dado("que não possuo cadastro de estudante") do
  expect(User.where(role: "estudante")).to be_empty
  visit login_estudante_path
end

Dado("que não estou autenticado no sistema") do
  visit login_estudante_path
end

Quando("tento acessar a página de recarga") do
  visit new_recarga_path
end

Então("o acesso deve ser recusado") do
  destino = if @estudante&.isento?
    root_path
  else
    login_estudante_path
  end

  expect(page).to have_current_path(destino)
end

Dado("que sou um estudante do grupo 1, isento do pagamento") do
  usuario = criar_estudante_saldo("Estudante Isento")
  usuario.update!(grupo_pagamento: "1")

  entrar_estudante_saldo(usuario.nome)
end

Então("nenhuma recarga deve ser criada") do
  expect(Recarga.count).to eq(0)
end

Quando("solicito uma recarga de {string} por cartão de crédito com dados válidos") do |valor|
  preparar_cartao_saldo(valor)
  click_button "Confirmar recarga"
end

Quando("o pagamento é aprovado") do
  expect(@estudante.recargas.last.situacao).to eq("confirmada")
end

Então(/^meu saldo deve ser atualizado para R\$(\d+,\d{2})$/) do |valor|
  expect(@estudante.reload.saldo).to eq(
    BigDecimal(valor.tr(",", "."))
  )
end

Quando("solicito uma recarga de {string} por PIX") do |valor|
  hoje = Date.current
  travel_to Time.zone.local(hoje.year, hoje.month, hoje.day, 10, 0)

  visit new_recarga_path
  fill_in "Valor da recarga", with: valor
  choose "PIX"
  click_button "Confirmar recarga"

  @pix_expiracao = @estudante.recargas.order(:id).last
end

Quando("o código PIX é gerado às 10:00") do
  expect(@pix_expiracao.created_at.strftime("%H:%M")).to eq("10:00")
  expect(@pix_expiracao.expira_em.strftime("%H:%M")).to eq("10:10")
end

Quando("o pagamento não é confirmado até as 10:10") do
  travel_to(@pix_expiracao.expira_em, with_usec: true)

  CancelarPixExpiradosJob.perform_now

  @situacao_apos_tarefa = @pix_expiracao.reload.situacao

  visit recarga_path(@pix_expiracao)
end

Então("a recarga deve ser cancelada") do
  expect(@situacao_apos_tarefa).to eq("cancelada")
  expect(@pix_expiracao.reload.situacao).to eq("cancelada")
end
