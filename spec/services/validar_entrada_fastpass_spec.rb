require "rails_helper"

RSpec.describe "Validação FastPass" do
  let(:restaurante) { Restaurante.create!(nome: "RU Central", campus: "UnB Darcy Ribeiro") }
  let(:catraca_fastpass) do
    PontoAcesso.create!(restaurante: restaurante, identificador: "FP-1", nome: "FastPass",
      campus: restaurante.campus, status: "Ativo", modalidade: "FastPass")
  end
  let(:catraca_comum) do
    PontoAcesso.create!(restaurante: restaurante, identificador: "COM-1", nome: "Comum",
      campus: restaurante.campus, status: "Ativo", modalidade: "Comum")
  end
  let(:ana) do
    User.create!(nome: "Ana", matricula: "241020803", role: "estudante", saldo: 10,
      password: "Teste@1234", password_confirmation: "Teste@1234")
  end
  let(:bruno) do
    User.create!(nome: "Bruno", matricula: "231010204", role: "estudante", saldo: 10,
      password: "Teste@1234", password_confirmation: "Teste@1234")
  end
  let(:turno) do
    TurnoFastpass.create!(data: Date.new(2026, 10, 20), tipo_refeicao: "Almoço",
      inicio: "11:00", fim: "14:00")
  end
  let(:faixa) { turno.faixas_fastpass.create!(inicio: "11:00", fim: "11:30") }

  def validar(estudante, ponto, hora)
    ValidarEntrada.executar(matricula: estudante.matricula, ponto_acesso: ponto,
      ocorrido_em: Time.zone.local(2026, 10, 20, *hora.split(":").map(&:to_i)),
      refeicao: "Almoço", valor_refeicao: BigDecimal("6.00"))
  end

  before do
    inscricao_ana = InscricaoFastpass.create!(user: ana, turno_fastpass: turno,
      faixa_fastpass: faixa)
    InscricaoFastpass.create!(user: bruno, turno_fastpass: turno, faixa_fastpass: faixa)
    ConfirmarResultadoFastpass.executar(turno: turno, ids_sorteados: [ inscricao_ana.id ])
  end

  it "libera a sorteada dentro da faixa e cobra uma vez" do
    acesso = validar(ana, catraca_fastpass, "11:00")

    expect(acesso).to be_liberado
    expect(acesso.valor_debitado).to eq(BigDecimal("6.00"))
    expect(ana.reload.saldo).to eq(BigDecimal("4.00"))
    expect(ana.consumos.count).to eq(1)
  end

  it "aceita saldo exatamente igual ao preço" do
    ana.update!(saldo: 6)

    expect(validar(ana, catraca_fastpass, "11:15")).to be_liberado
    expect(ana.reload.saldo).to be_zero
  end

  it "bloqueia antes e depois da faixa, sem cobrar" do
    expect(validar(ana, catraca_fastpass, "10:59")).not_to be_liberado
    expect(validar(ana, catraca_fastpass, "11:30")).not_to be_liberado
    expect(ana.reload.saldo).to eq(BigDecimal("10.00"))
    expect(ana.consumos.count).to eq(0)
  end

  it "bloqueia não sorteado na FastPass, mas permite entrada comum" do
    negado = validar(bruno, catraca_fastpass, "11:15")
    expect(negado).not_to be_liberado
    expect(negado.motivo).to include("não sorteado")

    expect(validar(bruno, catraca_comum, "11:15")).to be_liberado
    expect(bruno.reload.saldo).to eq(BigDecimal("4.00"))
  end

  it "bloqueia saldo insuficiente sem criar consumo" do
    ana.update!(saldo: 5)

    expect(validar(ana, catraca_fastpass, "11:15")).not_to be_liberado
    expect(ana.reload.saldo).to eq(BigDecimal("5.00"))
    expect(ana.consumos.count).to eq(0)
  end

  it "impede segunda entrada pelo FastPass ou pela catraca comum" do
    expect(validar(ana, catraca_fastpass, "11:15")).to be_liberado
    expect(validar(ana, catraca_comum, "11:20")).not_to be_liberado
    expect(validar(ana, catraca_fastpass, "11:20")).not_to be_liberado
    expect(ana.reload.saldo).to eq(BigDecimal("4.00"))
    expect(ana.consumos.count).to eq(1)
    expect(Acesso.where(user: ana, resultado: "Liberado").count).to eq(1)
  end
end
