require "rails_helper"

RSpec.describe "Terminal FastPass", type: :request do
  include ActiveSupport::Testing::TimeHelpers

  it "usa a modalidade do ponto para validar o resultado do sorteio" do
    travel_to Time.zone.local(2026, 10, 20, 11, 15) do
      restaurante = Restaurante.create!(nome: "RU Central", campus: "UnB Darcy Ribeiro")
      ponto = PontoAcesso.create!(restaurante: restaurante, identificador: "FP-1",
        nome: "Entrada FastPass", campus: restaurante.campus,
        status: "Ativo", modalidade: "FastPass")
      turno = TurnoFastpass.create!(data: Date.current, tipo_refeicao: "Almoço",
        inicio: "11:00", fim: "14:00")
      faixa = turno.faixas_fastpass.create!(inicio: "11:00", fim: "11:30")
      estudante = User.create!(nome: "Ana", role: "estudante", matricula: "241020803",
        saldo: 10, password: "Teste@1234", password_confirmation: "Teste@1234")
      InscricaoFastpass.create!(user: estudante, turno_fastpass: turno,
        faixa_fastpass: faixa, sorteado: true)
      turno.update!(sorteio_concluido_em: Time.current)
      funcionario = User.create!(nome: "Operador", role: "funcionario",
        siape: "123456-7", password: "Teste@1234")

      post login_funcionario_path, params: {
        identificador: funcionario.siape, senha: "Teste@1234"
      }
      post iniciar_operacao_path(ponto)
      post terminal_validacao_path, params: { matricula: estudante.matricula }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("ACESSO LIBERADO", "FastPass")
      expect(estudante.reload.saldo).to eq(BigDecimal("7.50"))
    end
  end
end
