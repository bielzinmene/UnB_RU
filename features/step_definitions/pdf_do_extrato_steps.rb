require "pdf/reader"
require "stringio"

module ApoioPdfExtratoBdd
  def registrar_recarga_pdf(usuario, data, valor)
    usuario.recargas.create!(
      valor: ValorDaRecarga.converter(valor),
      forma_pagamento: "cartao",
      situacao: "confirmada",
      confirmada_em: Time.zone.strptime(data, "%d/%m/%Y %H:%M")
    )
  end

  def registrar_refeicao_pdf(usuario, data, restaurante, valor)
    usuario.consumos.create!(
      restaurante: restaurante,
      valor_debitado: ValorDaRecarga.converter(valor),
      ocorrido_em: Time.zone.strptime(data, "%d/%m/%Y %H:%M"),
      referencia: SecureRandom.uuid
    )
  end

  def texto_pdf_bdd
    expect(page.response_headers["content-type"]).to include(
      "application/pdf"
    )

    leitor = PDF::Reader.new(StringIO.new(page.body))
    leitor.pages.map(&:text).join("\n")
  end

  def secao_pdf_bdd(nome)
    texto = texto_pdf_bdd

    if nome == "Recargas"
      texto.split("Recargas", 2).last.split("Refeições", 2).first
    else
      texto.split("Refeições", 2).last
    end
  end

  def linhas_pdf_bdd(nome)
    secao_pdf_bdd(nome).lines
      .map { |linha| linha.strip.gsub(/\s+/, " ") }
      .select { |linha| linha.match?(/\A\d{2}\/\d{2}\/\d{4}/) }
  end
end

World(ApoioPdfExtratoBdd)

Dado("que existem as seguintes recargas:") do |tabela|
  tabela.hashes.each do |linha|
    usuario = User.find_by!(matricula: linha.fetch("matrícula"))

    registrar_recarga_pdf(
      usuario,
      linha.fetch("data e hora"),
      linha.fetch("valor")
    )
  end
end

Dado("que existem as seguintes refeições:") do |tabela|
  tabela.hashes.each do |linha|
    usuario = User.find_by!(matricula: linha.fetch("matrícula"))

    registrar_refeicao_pdf(
      usuario,
      linha.fetch("data e hora"),
      linha.fetch("restaurante"),
      linha.fetch("valor debitado")
    )
  end
end

Quando("solicito a exportação em PDF do meu extrato e histórico de refeições") do
  visit extrato_path(format: :pdf)
end

Então("o PDF deve ser gerado") do
  expect(page.body).to start_with("%PDF-")

  expect(texto_pdf_bdd).to include(
    @estudante.nome,
    @estudante.matricula
  )
end

Então("a seção de recargas deve apresentar exatamente:") do |tabela|
  esperadas = tabela.hashes.map do |linha|
    "#{linha.fetch('data e hora')} | #{linha.fetch('valor')}"
  end

  expect(linhas_pdf_bdd("Recargas")).to eq(esperadas)
end

Então("a seção de refeições deve apresentar exatamente:") do |tabela|
  esperadas = tabela.hashes.map do |linha|
    [
      linha.fetch("data e hora"),
      linha.fetch("restaurante"),
      linha.fetch("valor debitado")
    ].join(" | ")
  end

  expect(linhas_pdf_bdd("Refeições")).to eq(esperadas)
end

Então(/^o PDF não deve conter recargas ou refeições d[oa] estudante "([^"]*)"$/) do |nome|
  outro = User.find_by!(nome: nome, role: "estudante")

  expect(texto_pdf_bdd).not_to include(outro.nome, outro.matricula)
end

Dado("que possuo uma recarga em {string} no valor de {string}") do |data, valor|
  registrar_recarga_pdf(@estudante, data, valor)
end

Dado("que não possuo refeições registradas") do
  expect(@estudante.consumos).to be_empty
end

Dado("que não possuo recargas registradas") do
  expect(@estudante.recargas).to be_empty
end

Dado("que possuo uma refeição em {string} no {string} com débito de {string}") do |data, restaurante, valor|
  registrar_refeicao_pdf(@estudante, data, restaurante, valor)
end

Então("a seção de recargas deve apresentar a recarga de {string} no valor de {string}") do |data, valor|
  expect(linhas_pdf_bdd("Recargas")).to eq([
    "#{data} | #{valor}"
  ])
end

Então("a seção de refeições deve apresentar a refeição de {string} no {string} com débito de {string}") do |data, restaurante, valor|
  expect(linhas_pdf_bdd("Refeições")).to eq([
    "#{data} | #{restaurante} | #{valor}"
  ])
end

Então("a seção de refeições deve apresentar {string}") do |mensagem|
  expect(secao_pdf_bdd("Refeições")).to include(mensagem)
  expect(linhas_pdf_bdd("Refeições")).to be_empty
end

Então("a seção de recargas deve apresentar {string}") do |mensagem|
  expect(secao_pdf_bdd("Recargas")).to include(mensagem)
  expect(linhas_pdf_bdd("Recargas")).to be_empty
end

Então("o PDF não deve conter dados de outros estudantes") do
  outros = User.where(role: "estudante").where.not(id: @estudante.id)

  outros.find_each do |outro|
    expect(texto_pdf_bdd).not_to include(outro.nome, outro.matricula)
  end
end

Então("a exportação deve ser recusada") do
  expect(page.response_headers["content-type"].to_s).not_to include(
    "application/pdf"
  )
end

Então("devo ser informada de que não há recargas nem refeições para exportar") do
  expect(page).to have_content(
    "Não há recargas nem refeições para exportar."
  )
end

Então("nenhum PDF deve ser gerado") do
  expect(page.body).not_to start_with("%PDF-")
end

Quando("solicito a exportação em PDF de extrato e histórico de refeições") do
  visit extrato_path(format: :pdf)
end

Então("devo ser informado de que preciso me autenticar") do
  expect(page).to have_current_path(login_estudante_path)

  expect(page).to have_content(
    "Você precisa se autenticar como estudante para continuar."
  )
end

Quando("solicito a exportação em PDF do extrato e histórico da matrícula {string}") do |matricula|
  visit extrato_path(format: :pdf, matricula: matricula)
end

Então("devo ser informada de que não posso exportar dados de outro estudante") do
  expect(page.status_code).to eq(403)

  expect(page).to have_content(
    "Você não pode exportar dados de outro estudante."
  )
end
