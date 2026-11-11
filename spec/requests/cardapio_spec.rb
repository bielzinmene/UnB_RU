require "rails_helper"

RSpec.describe "Cardápio do dia", type: :request do
  include ActiveSupport::Testing::TimeHelpers
  around { |example| travel_to(Time.zone.local(2026, 10, 16, 12, 0)) { example.run } }
  after { ENV.delete("CARDAPIO_FILE") }

  it "mostra as três opções durante a refeição" do
    Refeicao.create!(data: Date.current, tipo: "almoco", inicio: "11:00", fim: "14:00",
      opcao_padrao: "Frango", opcao_ovolactovegetariana: "Quiche", opcao_vegetariana_estrita: "Lentilha")
    get cardapio_path
    expect(response.body).to include("Frango", "Quiche", "Lentilha")
    expect(response.body).to include("Refeição sendo servida agora")
  end

  it "mostra café, almoço e jantar às 16h, sem marcar refeição atual" do
    travel_to(Time.zone.local(2026, 10, 16, 16, 0))
    get cardapio_path
    expect(Nokogiri::HTML(response.body).css("section.meal-card").size).to eq(3)
    expect(response.body).to include("Café da manhã", "Almoço", "Jantar")
    expect(response.body).not_to include("Refeição sendo servida agora")
  end

  it "consulta a programação semanal após o período de 30 dias do seed" do
    travel_to(Time.zone.local(2027, 1, 15, 16, 0))
    get cardapio_path
    expect(Nokogiri::HTML(response.body).css("section.meal-card").size).to eq(3)
  end

  it "informa indisponibilidade somente quando não há registros nem arquivo semanal" do
    ENV["CARDAPIO_FILE"] = Rails.root.join("cardapio-inexistente.json").to_s
    get cardapio_path
    expect(response.body).to include("Cardápio temporariamente indisponível")
  end
end
