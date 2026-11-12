require "rails_helper"
require "pdf/reader"
require "stringio"

RSpec.describe "PDF do extrato", type: :request do
  def criar_estudante(nome, matricula)
    User.create!(
      nome: nome,
      matricula: matricula,
      role: "estudante",
      password: "Teste@1234",
      password_confirmation: "Teste@1234",
      grupo_pagamento: "2"
    )
  end

  def registrar_recarga(usuario, data, valor)
    usuario.recargas.create!(
      valor: valor,
      forma_pagamento: "cartao",
      situacao: "confirmada",
      confirmada_em: Time.zone.strptime(data, "%d/%m/%Y %H:%M")
    )
  end

  def registrar_refeicao(usuario, data, valor, referencia)
    usuario.consumos.create!(
      restaurante: "RU Central",
      valor_debitado: valor,
      ocorrido_em: Time.zone.strptime(data, "%d/%m/%Y %H:%M"),
      referencia: referencia
    )
  end

  def entrar_como(usuario)
    post login_estudante_path, params: {
      matricula: usuario.matricula,
      senha: "Teste@1234"
    }

    expect(response).to redirect_to(root_path)
  end

  def baixar_pdf(usuario)
    entrar_como(usuario)

    get extrato_path(format: :pdf)

    expect(response).to have_http_status(:ok)
    expect(response.media_type).to eq("application/pdf")
    expect(response.body).to start_with("%PDF-")
    expect(response.headers["Content-Disposition"]).to include("attachment")

    leitor = PDF::Reader.new(StringIO.new(response.body))
    @texto_pdf = leitor.pages.map(&:text).join("\n")

    expect(@texto_pdf).to include(usuario.nome, usuario.matricula)
  end

  def linhas_da_secao(nome)
    trecho = if nome == "Recargas"
      @texto_pdf.split("Recargas", 2).last.split("Refeições", 2).first
    else
      @texto_pdf.split("Refeições", 2).last
    end

    trecho.lines
      .map { |linha| linha.strip.gsub(/\s+/, " ") }
      .select { |linha| linha.match?(/\A\d{2}\/\d{2}\/\d{4}/) }
  end

  before do
    @ana = criar_estudante("Ana", "241020803")
    @bruno = criar_estudante("Bruno", "231010204")

    registrar_recarga(@ana, "15/10/2026 09:00", 50)
    registrar_recarga(@ana, "14/10/2026 10:00", 20)
    registrar_recarga(@bruno, "15/10/2026 09:30", 30)

    registrar_refeicao(@ana, "15/10/2026 12:00", 6, "ana-dia-15")
    registrar_refeicao(@ana, "14/10/2026 12:30", 6, "ana-dia-14")
    registrar_refeicao(@bruno, "15/10/2026 12:15", 6, "bruno-dia-15")
  end

  it "exporta exatamente as recargas e refeições de Ana" do
    baixar_pdf(@ana)

    expect(linhas_da_secao("Recargas")).to eq([
      "15/10/2026 09:00 | R$ 50,00",
      "14/10/2026 10:00 | R$ 20,00"
    ])

    expect(linhas_da_secao("Refeições")).to eq([
      "15/10/2026 12:00 | RU Central | R$ 6,00",
      "14/10/2026 12:30 | RU Central | R$ 6,00"
    ])

    expect(@texto_pdf).not_to include(@bruno.nome, @bruno.matricula)
  end

  it "exporta somente os dados de Bruno quando ele está conectado" do
    baixar_pdf(@bruno)

    expect(linhas_da_secao("Recargas")).to eq([
      "15/10/2026 09:30 | R$ 30,00"
    ])

    expect(linhas_da_secao("Refeições")).to eq([
      "15/10/2026 12:15 | RU Central | R$ 6,00"
    ])

    expect(@texto_pdf).not_to include(@ana.nome, @ana.matricula)
  end

  it "exporta quando Daniela tem somente recargas" do
    daniela = criar_estudante("Daniela", "251020306")
    registrar_recarga(daniela, "15/10/2026 09:45", 40)

    baixar_pdf(daniela)

    expect(linhas_da_secao("Recargas")).to eq([
      "15/10/2026 09:45 | R$ 40,00"
    ])

    expect(linhas_da_secao("Refeições")).to be_empty

    expect(@texto_pdf).to include(
      "Nenhum histórico de refeições encontrado"
    )

    expect(@texto_pdf).not_to include(@ana.matricula, @bruno.matricula)
  end

  it "exporta quando Eduardo tem somente refeições" do
    eduardo = criar_estudante("Eduardo", "251020307")

    registrar_refeicao(
      eduardo, "15/10/2026 12:30", 6, "eduardo-dia-15"
    )

    baixar_pdf(eduardo)

    expect(linhas_da_secao("Recargas")).to be_empty

    expect(@texto_pdf).to include("Nenhuma recarga encontrada")

    expect(linhas_da_secao("Refeições")).to eq([
      "15/10/2026 12:30 | RU Central | R$ 6,00"
    ])

    expect(@texto_pdf).not_to include(@ana.matricula, @bruno.matricula)
  end

  it "recusa exportação quando Carla não tem registros" do
    carla = criar_estudante("Carla", "251020305")
    entrar_como(carla)

    get extrato_path(format: :pdf)

    expect(response).to redirect_to(extrato_path)
    expect(response.body).not_to start_with("%PDF-")

    follow_redirect!

    expect(response.body).to include(
      "Não há recargas nem refeições para exportar."
    )
  end

  it "recusa exportação sem autenticação" do
    get extrato_path(format: :pdf)

    expect(response).to redirect_to(login_estudante_path)
    expect(response.body).not_to start_with("%PDF-")

    follow_redirect!

    expect(response.body).to include(
      "Você precisa se autenticar como estudante para continuar."
    )
  end

  it "recusa exportar outra matrícula mesmo estando autenticado" do
    entrar_como(@ana)

    get extrato_path(format: :pdf), params: {
      matricula: @bruno.matricula
    }

    expect(response).to have_http_status(:forbidden)
    expect(response.media_type).not_to eq("application/pdf")
    expect(response.body).not_to start_with("%PDF-")

    expect(response.body).to include(
      "Você não pode exportar dados de outro estudante."
    )
  end
end
