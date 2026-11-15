require "rails_helper"

RSpec.describe "Confirmação do resultado FastPass", type: :request do
  let(:turno) do
    TurnoFastpass.create!(data: Date.new(2026, 10, 20), tipo_refeicao: "Almoço",
      inicio: "11:00", fim: "14:00")
  end
  let(:estudante) do
    User.create!(nome: "Ana", role: "estudante", matricula: "241020803",
      password: "Teste@1234", password_confirmation: "Teste@1234")
  end
  let(:inscricao) do
    faixa = turno.faixas_fastpass.create!(inicio: "11:00", fim: "11:30")
    InscricaoFastpass.create!(user: estudante, turno_fastpass: turno,
      faixa_fastpass: faixa)
  end

  it "exige administrador para confirmar o resultado" do
    post resultado_turno_fastpass_path(turno), params: { ganhadores: [ inscricao.id ] }

    expect(response).to redirect_to(login_funcionario_path)
    expect(inscricao.reload.sorteado).to be_nil
  end

  it "permite ao administrador marcar ganhadores pela tela" do
    admin = User.create!(nome: "Admin", role: "administrador", siape: "123456-7",
      password: "Teste@1234")
    post login_funcionario_path, params: { identificador: admin.siape, senha: "Teste@1234" }

    inscricao
    get turnos_fastpass_index_path
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Confirmar resultado", "Ana")

    post resultado_turno_fastpass_path(turno), params: { ganhadores: [ inscricao.id ] }

    expect(response).to redirect_to(turnos_fastpass_index_path)
    expect(inscricao.reload).to be_sorteado
  end
end
