require "rails_helper"
require "pdf/reader"
require "stringio"

RSpec.describe ValidarEntrada do
  let(:restaurante) do
    Restaurante.create!(
      nome: "RU Central",
      campus: "UnB Darcy Ribeiro"
    )
  end

  let(:ponto_acesso) do
    PontoAcesso.create!(
      restaurante: restaurante,
      identificador: "RU-CENTRAL-1",
      nome: "Entrada principal",
      campus: "UnB Darcy Ribeiro",
      status: "Ativo"
    )
  end

  def criar_estudante(matricula:, saldo:, grupo_pagamento: "2")
    User.create!(
      nome: "Estudante #{matricula}",
      matricula: matricula,
      role: "estudante",
      saldo: saldo,
      grupo_pagamento: grupo_pagamento,
      password: "Teste@1234",
      password_confirmation: "Teste@1234"
    )
  end

  def validar(estudante, ocorrido_em: Time.zone.local(2026, 11, 15, 12))
    described_class.executar(
      matricula: estudante.matricula,
      ponto_acesso: ponto_acesso,
      ocorrido_em: ocorrido_em
    )
  end

  def texto_do_pdf(estudante)
    pdf = GerarPdfDoExtrato.executar(
      extrato: ExtratoDoEstudante.new(estudante)
    )

    PDF::Reader.new(StringIO.new(pdf)).pages.map(&:text).join("\n")
  end

  it "libera o pagante, debita uma vez e registra a refeicao no extrato e PDF" do
    estudante = criar_estudante(matricula: "251024222", saldo: "10.00")

    acesso = validar(estudante)

    expect(acesso).to be_liberado
    expect(acesso.valor_debitado).to eq(BigDecimal("2.50"))
    expect(estudante.reload.saldo).to eq(BigDecimal("7.50"))
    expect(estudante.consumos.count).to eq(1)

    consumo = ExtratoDoEstudante.new(estudante).consumos.sole
    expect(consumo).to have_attributes(
      restaurante: "RU Central",
      valor_debitado: BigDecimal("2.50"),
      referencia: "acesso-#{acesso.id}"
    )
    expect(texto_do_pdf(estudante)).to include(
      "RU Central", "R$ 2,50"
    )
  end

  it "bloqueia o pagante sem saldo sem criar consumo ou debitar" do
    estudante = criar_estudante(matricula: "251024223", saldo: "2.00")

    acesso = validar(estudante)

    expect(acesso).not_to be_liberado
    expect(acesso.motivo).to eq("Saldo insuficiente")
    expect(acesso.valor_debitado).to be_zero
    expect(estudante.reload.saldo).to eq(BigDecimal("2.00"))
    expect(estudante.consumos).to be_empty
  end

  it "libera o isento sem saldo e registra consumo zero no extrato e PDF" do
    estudante = criar_estudante(
      matricula: "251024224",
      saldo: "0.00",
      grupo_pagamento: "1"
    )

    acesso = validar(estudante)

    expect(acesso).to be_liberado
    expect(acesso.valor_debitado).to be_zero
    expect(estudante.reload.saldo).to be_zero
    expect(estudante.consumos.count).to eq(1)

    consumo = ExtratoDoEstudante.new(estudante).consumos.sole
    expect(consumo.valor_debitado).to be_zero
    expect(consumo.referencia).to eq("acesso-#{acesso.id}")
    expect(texto_do_pdf(estudante)).to include(
      "RU Central", "R$ 0,00"
    )
  end

  it "desfaz o acesso liberado se o registro do consumo falhar" do
    estudante = criar_estudante(matricula: "251024225", saldo: "10.00")
    allow(RegistrarConsumo).to receive(:executar).and_raise(
      RegistrarConsumo::Erro, "falha ao registrar consumo"
    )

    expect { validar(estudante) }.to raise_error(
      RegistrarConsumo::Erro, "falha ao registrar consumo"
    )

    expect(Acesso.where(user: estudante)).to be_empty
    expect(estudante.reload.saldo).to eq(BigDecimal("10.00"))
    expect(estudante.consumos).to be_empty
  end
end
