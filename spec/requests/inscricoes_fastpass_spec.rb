require "rails_helper"

RSpec.describe "Inscrições FastPass", type: :request do
  let(:estudante) do
    User.create!(nome: "Ana", role: "estudante", matricula: "241020803", saldo: 10,
      password: "Teste@1234", password_confirmation: "Teste@1234")
  end
  let(:turno) do
    TurnoFastpass.create!(data: Date.new(2026, 10, 20), tipo_refeicao: "Almoço",
      inicio: "11:00", fim: "14:00")
  end
  let(:faixa) { turno.faixas_fastpass.create!(inicio: "11:00", fim: "11:30") }

  it "exige login de estudante" do
    post inscricoes_fastpass_path, params: { faixa_fastpass_id: faixa.id }

    expect(response).to redirect_to(login_estudante_path)
    expect(InscricaoFastpass.count).to eq(0)
  end

  it "registra inscrição gratuita e mostra a faixa escolhida" do
    post login_estudante_path, params: { matricula: estudante.matricula, senha: "Teste@1234" }

    expect {
      post inscricoes_fastpass_path, params: {
        turno_fastpass_id: turno.id, faixa_fastpass_id: faixa.id
      }
    }.to change(InscricaoFastpass, :count).by(1)

    expect(estudante.reload.saldo).to eq(BigDecimal("10.00"))
    get inscricoes_fastpass_path
    expect(response.body).to include("11:00 às 11:30")
  end

  it "recusa segunda inscrição no mesmo turno" do
    post login_estudante_path, params: { matricula: estudante.matricula, senha: "Teste@1234" }
    post inscricoes_fastpass_path, params: { faixa_fastpass_id: faixa.id }
    outra_faixa = turno.faixas_fastpass.create!(inicio: "12:00", fim: "12:30")

    expect {
      post inscricoes_fastpass_path, params: { faixa_fastpass_id: outra_faixa.id }
    }.not_to change(InscricaoFastpass, :count)

    expect(estudante.inscricoes_fastpass.sole.faixa_fastpass).to eq(faixa)
  end

  it "recusa faixa inexistente e faixa de outro turno" do
    post login_estudante_path, params: { matricula: estudante.matricula, senha: "Teste@1234" }
    jantar = TurnoFastpass.create!(data: turno.data, tipo_refeicao: "Jantar",
      inicio: "18:00", fim: "20:00")
    faixa_jantar = jantar.faixas_fastpass.create!(inicio: "18:00", fim: "18:30")

    post inscricoes_fastpass_path, params: { faixa_fastpass_id: "99999999" }
    post inscricoes_fastpass_path, params: {
      turno_fastpass_id: turno.id, faixa_fastpass_id: faixa_jantar.id
    }

    expect(InscricaoFastpass.count).to eq(0)
  end
end
