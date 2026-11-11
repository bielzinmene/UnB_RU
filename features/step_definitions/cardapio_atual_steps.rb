Dado("que existe um cardápio para a refeição atual") do
  Refeicao.create!(data: Date.current, tipo: "almoco", inicio: "11:00", fim: "14:00",
    opcao_padrao: "Frango assado", opcao_ovolactovegetariana: "Quiche de legumes",
    opcao_vegetariana_estrita: "Lentilha")
end

Dado("que os dados do cardápio do dia estão indisponíveis") do
  Refeicao.where(data: Date.current).delete_all
  ENV["CARDAPIO_FILE"] = Rails.root.join("cardapio-inexistente.json").to_s
end

After do
  ENV.delete("CARDAPIO_FILE")
end

Dado("que o horário atual é {string}") do |hora|
  travel_to Time.zone.parse("#{Date.current} #{hora}")
end

Quando("acesso o cardápio") do
  visit cardapio_path
end

Então("devo visualizar a opção padrão") do
  expect(page).to have_content("Frango assado")
end

Então("devo visualizar a opção ovolactovegetariana") do
  expect(page).to have_content("Quiche de legumes")
end

Então("devo visualizar a opção vegetariana estrita") do
  expect(page).to have_content("Lentilha")
end

Então("devo visualizar café da manhã, almoço e jantar") do
  expect(page).to have_content("Café da manhã")
  expect(page).to have_content("Almoço")
  expect(page).to have_content("Jantar")
end

Então("devo visualizar as opções das três refeições") do
  expect(page).to have_css("section.meal-card", count: 3)
  within("section", text: "Jantar") do
    expect(page).to have_content("Opção padrão")
    expect(page).to have_content("Opção ovolactovegetariana")
    expect(page).to have_content("Opção vegetariana estrita")
  end
end

Então("devo ser informado que o cardápio está temporariamente indisponível") do
  expect(page).to have_content("Cardápio temporariamente indisponível")
end
