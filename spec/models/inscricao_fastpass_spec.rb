require "rails_helper"

RSpec.describe InscricaoFastpass, type: :model do
  let(:estudante) do
    User.create!(nome: "Ana", role: "estudante", matricula: "241020803",
      password: "Teste@1234", password_confirmation: "Teste@1234")
  end
  let(:turno) do
    TurnoFastpass.create!(data: Date.new(2026, 10, 20), tipo_refeicao: "Almoço",
      inicio: "11:00", fim: "14:00")
  end
  let(:faixa) { turno.faixas_fastpass.create!(inicio: "11:00", fim: "11:30") }

  it "aceita apenas uma inscrição por estudante, dia e turno" do
    described_class.create!(user: estudante, turno_fastpass: turno, faixa_fastpass: faixa)
    segunda_faixa = turno.faixas_fastpass.create!(inicio: "12:00", fim: "12:30")

    segunda = described_class.new(user: estudante, turno_fastpass: turno,
      faixa_fastpass: segunda_faixa)

    expect(segunda).not_to be_valid
    expect(described_class.count).to eq(1)
  end

  it "recusa uma faixa de outro turno" do
    jantar = TurnoFastpass.create!(data: turno.data, tipo_refeicao: "Jantar",
      inicio: "18:00", fim: "20:00")
    faixa_jantar = jantar.faixas_fastpass.create!(inicio: "18:00", fim: "18:30")

    inscricao = described_class.new(user: estudante, turno_fastpass: turno,
      faixa_fastpass: faixa_jantar)

    expect(inscricao).not_to be_valid
    expect(inscricao.errors[:faixa_fastpass]).to be_present
  end

  it "recusa inscrições de funcionários" do
    funcionario = User.create!(nome: "Operador", role: "funcionario",
      siape: "123456-7", password: "Teste@1234")

    inscricao = described_class.new(user: funcionario, turno_fastpass: turno,
      faixa_fastpass: faixa)

    expect(inscricao).not_to be_valid
  end

  it "permite inscrição em outro turno e em outro dia" do
    described_class.create!(user: estudante, turno_fastpass: turno, faixa_fastpass: faixa)
    jantar = TurnoFastpass.create!(data: turno.data, tipo_refeicao: "Jantar",
      inicio: "18:00", fim: "20:00")
    almoco_amanha = TurnoFastpass.create!(data: turno.data + 1, tipo_refeicao: "Almoço",
      inicio: "11:00", fim: "14:00")

    expect {
      described_class.create!(user: estudante, turno_fastpass: jantar,
        faixa_fastpass: jantar.faixas_fastpass.create!(inicio: "18:00", fim: "18:30"))
      described_class.create!(user: estudante, turno_fastpass: almoco_amanha,
        faixa_fastpass: almoco_amanha.faixas_fastpass.create!(inicio: "11:00", fim: "11:30"))
    }.to change(described_class, :count).by(2)
  end
end
