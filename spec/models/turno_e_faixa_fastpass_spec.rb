require "rails_helper"

RSpec.describe "Turnos e Faixas FastPass", type: :model do
  let(:turno) { TurnoFastpass.create!(data: Date.new(2026, 10, 20), tipo_refeicao: "Almoço", inicio: "11:00", fim: "14:00") }

  it "recusa turno com duração zero ou negativa" do
    invalido = TurnoFastpass.new(data: Date.new(2026, 10, 20), tipo_refeicao: "Jantar", inicio: "14:00", fim: "11:00")
    expect(invalido).not_to be_valid
  end

  it "aceita faixas válidas com intervalos livres entre elas" do
    f1 = turno.faixas_fastpass.create(inicio: "11:00", fim: "11:30")
    f2 = turno.faixas_fastpass.create(inicio: "12:00", fim: "12:30")
    expect(f1).to be_persisted
    expect(f2).to be_persisted
  end

  it "recusa faixas sobrepostas ou fora do horário do turno" do
    turno.faixas_fastpass.create!(inicio: "11:00", fim: "11:30")

    sobreposta = turno.faixas_fastpass.new(inicio: "11:15", fim: "11:45")
    expect(sobreposta).not_to be_valid

    fora_horario = turno.faixas_fastpass.new(inicio: "13:45", fim: "14:15")
    expect(fora_horario).not_to be_valid
  end
end
