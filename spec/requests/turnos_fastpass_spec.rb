require "rails_helper"

RSpec.describe "Gestão de turnos FastPass", type: :request do
  let(:administrador) do
    User.create!(nome: "Admin", role: "administrador", siape: "123456-7",
      password: "Teste@1234")
  end

  def entrar
    post login_funcionario_path, params: {
      identificador: administrador.siape, senha: "Teste@1234"
    }
  end

  it "exibe os turnos e permite cadastrar uma faixa pela rota da tela" do
    entrar
    turno = TurnoFastpass.create!(data: Date.new(2026, 10, 20),
      tipo_refeicao: "Almoço", inicio: "11:00", fim: "14:00")

    get turnos_fastpass_index_path
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("20/10/2026")

    post turnos_fastpass_faixas_fastpass_index_path(turno), params: {
      inicio: "11:00", fim: "11:30"
    }

    expect(response).to redirect_to(turnos_fastpass_index_path)
    expect(turno.faixas_fastpass.count).to eq(1)
  end
end
