Dado("que existem os seguintes acessos realizados:") do |tabela|
  tabela.hashes.each_with_index do |linha, idx|
    restaurante = Restaurante.find_or_create_by!(nome: linha["restaurante"], campus: "UnB Darcy Ribeiro")
    catraca = PontoAcesso.find_or_create_by!(nome: linha["catraca"], restaurante: restaurante) do |c|
      c.identificador = "CAT-REL-#{idx + 1}-#{linha['catraca'].delete(' ')}"
      c.campus = "UnB Darcy Ribeiro"
      c.status = "Ativo"
    end

    Acesso.create!(
      ponto_acesso: catraca,
      matricula: linha["matrícula"],
      ocorrido_em: Time.zone.strptime(linha["data e hora"], "%d/%m/%Y %H:%M"),
      refeicao: "Almoço",
      resultado: "Liberado",
      valor_debitado: 6.10
    )
  end
end

Dado("que existe a catraca {string} no restaurante {string} e ela não possui acessos realizados") do |catraca_nome, restaurante_nome|
  restaurante = Restaurante.find_or_create_by!(nome: restaurante_nome, campus: "UnB Darcy Ribeiro")
  PontoAcesso.find_or_create_by!(nome: catraca_nome, restaurante: restaurante) do |c|
    c.identificador = "CAT-VAZIA-#{catraca_nome.delete(' ')}"
    c.campus = "UnB Darcy Ribeiro"
    c.status = "Ativo"
  end
end

Quando("consulto o relatório global de acessos sem aplicar filtros") do
  visit relatorio_acessos_path
end

Quando("filtro o relatório pelo restaurante {string}") do |restaurante|
  visit relatorio_acessos_path(restaurante: restaurante)
end

Quando("filtro o relatório pela catraca {string} do restaurante {string}") do |catraca, restaurante|
  visit relatorio_acessos_path(restaurante: restaurante, catraca: catraca)
end

Quando("agrupo o relatório por restaurante") do
  visit relatorio_acessos_path(agrupar_por: "restaurante")
end

Quando("agrupo o relatório por catraca") do
  visit relatorio_acessos_path(agrupar_por: "catraca")
end

Então("o relatório deve apresentar exatamente os seguintes acessos:") do |tabela|
  tabela.hashes.each do |linha|
    expect(page).to have_content(linha["data e hora"])
    expect(page).to have_content(linha["matrícula"])
    expect(page).to have_content(linha["restaurante"])
    expect(page).to have_content(linha["catraca"])
  end
end

Então("devo ver somente os acessos de {string}, {string} e {string}") do |h1, h2, h3|
  expect(page).to have_content(h1)
  expect(page).to have_content(h2)
  expect(page).to have_content(h3)
end

Então("devo ver somente os acessos de {string} e {string}") do |h1, h2|
  expect(page).to have_content(h1)
  expect(page).to have_content(h2)
end

Então("não devo ver o acesso de {string}") do |horario|
  expect(page).not_to have_content(horario)
end

Então("não devo ver os acessos das outras catracas") do
  expect(page).not_to have_content("Catraca 2")
  expect(page).not_to have_content("Catraca 3")
end

Então("devo ver o grupo {string} com os acessos de {string}, {string} e {string}") do |grupo, h1, h2, h3|
  expect(page).to have_content(grupo)
  expect(page).to have_content(h1)
  expect(page).to have_content(h2)
  expect(page).to have_content(h3)
end

Então("devo ver o grupo {string} com o acesso de {string}") do |grupo, h1|
  expect(page).to have_content(grupo)
  expect(page).to have_content(h1)
end

Então("devo ver o grupo {string} do restaurante {string} com os acessos de {string} e {string}") do |catraca, restaurante, h1, h2|
  expect(page).to have_content("#{restaurante} - #{catraca}")
  expect(page).to have_content(h1)
  expect(page).to have_content(h2)
end

Então("devo ver o grupo {string} do restaurante {string} com o acesso de {string}") do |catraca, restaurante, h1|
  expect(page).to have_content("#{restaurante} - #{catraca}")
  expect(page).to have_content(h1)
end

Então("não devo ver nenhum acesso") do
  expect(page).not_to have_selector("tbody tr")
end
