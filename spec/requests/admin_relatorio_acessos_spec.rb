require "rails_helper"

RSpec.describe "Admin::RelatorioAcessos", type: :request do
  let(:headers) do
    {
      "HTTP_USER_AGENT" => "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36",
      "ACCEPT" => "text/html"
    }
  end
  let!(:admin) { User.create!(nome: "Admin", siape: "888888-8", role: "administrador", password: "Teste@1234") }
  let!(:restaurante) { Restaurante.create!(nome: "RU Central", campus: "UnB Darcy Ribeiro") }
  let!(:ponto_acesso) do
    PontoAcesso.create!(
      restaurante: restaurante,
      identificador: "CAT-SPEC-1",
      nome: "Catraca 1",
      campus: "UnB Darcy Ribeiro",
      status: "Ativo"
    )
  end

  before do
    Acesso.create!(
      ponto_acesso: ponto_acesso,
      matricula: "241020803",
      ocorrido_em: Time.zone.parse("2026-10-15 11:05"),
      refeicao: "Almoço",
      resultado: "Liberado",
      valor_debitado: 6.10
    )
    post login_funcionario_path, params: { identificador: admin.siape, senha: "Teste@1234" }, headers: headers
  end

  it "exibe o relatório global e filtra por restaurante" do
    get relatorio_acessos_path, params: { restaurante: "RU Central" }, headers: headers

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("241020803")
    expect(response.body).to include("RU Central")
  end
end
