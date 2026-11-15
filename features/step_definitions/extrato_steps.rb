Dado(/^que [oa] estudante "([^"]*)" possui a matrícula "([^"]*)"$/) do |nome, matricula|
  criar_estudante_saldo(nome, matricula)
end

Dado(/^que estou autenticad[oa] como [oa] estudante "([^"]*)"$/) do |nome|
  entrar_estudante_saldo(nome)
end

Dado("que possuo as seguintes recargas:") do |tabela|
  tabela.hashes.each do |linha|
    @estudante.recargas.create!(
      valor: ValorDaRecarga.converter(linha.fetch("valor")),
      forma_pagamento: "cartao",
      situacao: "confirmada",
      confirmada_em: Time.zone.strptime(
        linha.fetch("data e hora"),
        "%d/%m/%Y %H:%M"
      )
    )
  end
end

Dado("que possuo as seguintes refeições:") do |tabela|
  tabela.hashes.each do |linha|
    @estudante.consumos.create!(
      restaurante: linha.fetch("restaurante"),
      valor_debitado: ValorDaRecarga.converter(
        linha.fetch("valor debitado")
      ),
      ocorrido_em: Time.zone.strptime(
        linha.fetch("data e hora"),
        "%d/%m/%Y %H:%M"
      ),
      referencia: SecureRandom.uuid
    )
  end
end

Quando("acesso a tela de extrato e histórico de consumo") do
  visit extrato_path
end

Então("o extrato deve apresentar exatamente estas recargas, nesta ordem:") do |tabela|
  linhas = page.all("#extrato-recargas tbody tr").map do |linha|
    linha.all("td").map { |celula| celula.text.strip }
  end

  esperadas = tabela.hashes.map do |linha|
    [
      linha.fetch("data e hora"),
      linha.fetch("valor")
    ]
  end

  expect(linhas).to eq(esperadas)
end

Então("o histórico deve apresentar exatamente estas refeições, nesta ordem:") do |tabela|
  linhas = page.all("#historico-refeicoes tbody tr").map do |linha|
    linha.all("td").map { |celula| celula.text.strip }
  end

  esperadas = tabela.hashes.map do |linha|
    [
      linha.fetch("data e hora"),
      linha.fetch("restaurante"),
      linha.fetch("valor debitado")
    ]
  end

  expect(linhas).to eq(esperadas)
end

Dado("que não possuo recargas nem refeições registradas") do
  expect(@estudante.recargas).to be_empty
  expect(@estudante.consumos).to be_empty
end

Então("o extrato deve apresentar {string}") do |mensagem|
  expect(page).to have_css(
    "#extrato-recargas",
    text: mensagem
  )
end

Então("o histórico deve apresentar {string}") do |mensagem|
  expect(page).to have_css(
    "#historico-refeicoes",
    text: mensagem
  )
end

Quando("tento acessar a tela de extrato e histórico de consumo") do
  visit extrato_path
end

Então("nenhum dado de recargas ou refeições deve ser exibido") do
  expect(page).not_to have_css("#extrato-recargas")
  expect(page).not_to have_css("#historico-refeicoes")
end
