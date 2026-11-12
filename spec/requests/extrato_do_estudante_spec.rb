require "rails_helper"

RSpec.describe "Página do extrato do estudante", type: :request do
  let(:estudante) do
    User.create!(
      nome: "Cleiton",
      matricula: "251024222",
      role: "estudante",
      password: "Teste@1234",
      password_confirmation: "Teste@1234",
      grupo_pagamento: "2"
    )
  end

  def entrar_como(usuario)
    post login_estudante_path, params: {
      matricula: usuario.matricula,
      senha: "Teste@1234"
    }

    expect(response).to redirect_to(root_path)
  end

  it "recusa a consulta sem autenticação" do
    get extrato_path

    expect(response).to redirect_to(login_estudante_path)

    follow_redirect!

    expect(response.body).to include(
      "Você precisa se autenticar como estudante para continuar."
    )

    expect(response.body).not_to include(
      'id="extrato-recargas"',
      'id="historico-refeicoes"'
    )
  end

  it "mostra as mensagens quando não existem registros" do
    entrar_como(estudante)

    get extrato_path

    expect(response).to have_http_status(:ok)

    expect(response.body).to include(
      "Nenhuma recarga encontrada",
      "Nenhum histórico de refeições encontrado"
    )
  end

  it "mostra exatamente os registros pessoais na ordem correta" do
    estudante.recargas.create!(
      valor: 20,
      forma_pagamento: "cartao",
      situacao: "confirmada",
      confirmada_em: Time.zone.local(2026, 10, 14, 9)
    )

    estudante.recargas.create!(
      valor: 50,
      forma_pagamento: "cartao",
      situacao: "confirmada",
      confirmada_em: Time.zone.local(2026, 10, 15, 9)
    )

    estudante.consumos.create!(
      restaurante: "RU Central",
      valor_debitado: "2.50",
      ocorrido_em: Time.zone.local(2026, 10, 14, 12),
      referencia: "acesso-dia-14"
    )

    estudante.consumos.create!(
      restaurante: "RU Central",
      valor_debitado: "2.50",
      ocorrido_em: Time.zone.local(2026, 10, 15, 12),
      referencia: "acesso-dia-15"
    )

    outro_estudante = User.create!(
      nome: "Ana",
      matricula: "241020803",
      role: "estudante",
      password: "Teste@1234",
      password_confirmation: "Teste@1234",
      grupo_pagamento: "2"
    )

    outro_estudante.recargas.create!(
      valor: 99,
      forma_pagamento: "cartao",
      situacao: "confirmada",
      confirmada_em: Time.zone.local(2026, 10, 16, 9)
    )

    outro_estudante.consumos.create!(
      restaurante: "Restaurante de outra pessoa",
      valor_debitado: 6,
      ocorrido_em: Time.zone.local(2026, 10, 16, 12),
      referencia: "acesso-de-outra-pessoa"
    )

    entrar_como(estudante)

    get extrato_path

    expect(response).to have_http_status(:ok)

    pagina = Nokogiri::HTML(response.body)

    recargas = pagina.css("#extrato-recargas tbody tr").map do |linha|
      linha.css("td").map { |celula| celula.text.strip }
    end

    refeicoes = pagina.css("#historico-refeicoes tbody tr").map do |linha|
      linha.css("td").map { |celula| celula.text.strip }
    end

    expect(recargas).to eq([
      [ "15/10/2026 09:00", "R$ 50,00" ],
      [ "14/10/2026 09:00", "R$ 20,00" ]
    ])

    expect(refeicoes).to eq([
      [ "15/10/2026 12:00", "RU Central", "R$ 2,50" ],
      [ "14/10/2026 12:00", "RU Central", "R$ 2,50" ]
    ])
  end
end
