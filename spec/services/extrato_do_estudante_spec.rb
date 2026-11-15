require "rails_helper"

RSpec.describe ExtratoDoEstudante do
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

  def criar_recarga(usuario, valor, horario)
    usuario.recargas.create!(
      valor: valor,
      forma_pagamento: "cartao",
      situacao: "confirmada",
      confirmada_em: horario
    )
  end

  def criar_consumo(usuario, horario, referencia)
    usuario.consumos.create!(
      restaurante: "RU Central",
      valor_debitado: "2.50",
      ocorrido_em: horario,
      referencia: referencia
    )
  end

  it "apresenta exatamente os registros do mais recente ao mais antigo" do
    recarga_antiga = criar_recarga(
      estudante, 20, Time.zone.local(2026, 10, 14, 9)
    )

    recarga_recente = criar_recarga(
      estudante, 50, Time.zone.local(2026, 10, 15, 9)
    )

    consumo_antigo = criar_consumo(
      estudante, Time.zone.local(2026, 10, 14, 12), "acesso-antigo"
    )

    consumo_recente = criar_consumo(
      estudante, Time.zone.local(2026, 10, 15, 12), "acesso-recente"
    )

    extrato = described_class.new(estudante)

    expect(extrato.recargas).to eq([
      recarga_recente,
      recarga_antiga
    ])

    expect(extrato.consumos).to eq([
      consumo_recente,
      consumo_antigo
    ])

    expect(extrato).not_to be_vazio
  end

  it "não inclui registros de outro estudante" do
    outro_estudante = User.create!(
      nome: "Ana",
      matricula: "241020803",
      role: "estudante",
      password: "Teste@1234",
      password_confirmation: "Teste@1234",
      grupo_pagamento: "2"
    )

    minha_recarga = criar_recarga(
      estudante, 20, Time.zone.local(2026, 10, 14, 9)
    )

    meu_consumo = criar_consumo(
      estudante, Time.zone.local(2026, 10, 14, 12), "meu-acesso"
    )

    criar_recarga(
      outro_estudante, 50, Time.zone.local(2026, 10, 15, 9)
    )

    criar_consumo(
      outro_estudante, Time.zone.local(2026, 10, 15, 12), "outro-acesso"
    )

    extrato = described_class.new(estudante)

    expect(extrato.recargas).to eq([ minha_recarga ])
    expect(extrato.consumos).to eq([ meu_consumo ])
  end

  it "identifica quando não existem recargas nem refeições" do
    extrato = described_class.new(estudante)

    expect(extrato.recargas).to be_empty
    expect(extrato.consumos).to be_empty
    expect(extrato).to be_vazio
  end
end
