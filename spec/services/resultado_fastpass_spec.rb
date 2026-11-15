require "rails_helper"

RSpec.describe "Resultado e notificações FastPass" do
  let(:turno) do
    TurnoFastpass.create!(data: Date.new(2026, 10, 20), tipo_refeicao: "Almoço",
      inicio: "11:00", fim: "14:00")
  end
  let(:faixa) { turno.faixas_fastpass.create!(inicio: "11:00", fim: "11:30") }

  def inscrever(nome, matricula)
    estudante = User.create!(nome: nome, matricula: matricula, role: "estudante",
      password: "Teste@1234", password_confirmation: "Teste@1234")
    InscricaoFastpass.create!(user: estudante, turno_fastpass: turno,
      faixa_fastpass: faixa)
  end

  it "registra vencedores e perdedores, sem cobrar pela inscrição ou pelo resultado" do
    ana = inscrever("Ana", "241020803")
    bruno = inscrever("Bruno", "231010204")

    ConfirmarResultadoFastpass.executar(turno: turno, ids_sorteados: [ ana.id ])

    expect(ana.reload).to be_sorteado
    expect(bruno.reload.sorteado).to be(false)
    expect(turno.reload.sorteio_concluido_em).to be_present
    expect { ConfirmarResultadoFastpass.executar(turno: turno,
      ids_sorteados: []) }.to raise_error(ConfirmarResultadoFastpass::Erro)
  end

  it "recusa inscrição de outro turno entre os ganhadores" do
    ana = inscrever("Ana", "241020803")
    jantar = TurnoFastpass.create!(data: turno.data, tipo_refeicao: "Jantar",
      inicio: "18:00", fim: "20:00")
    faixa_jantar = jantar.faixas_fastpass.create!(inicio: "18:00", fim: "18:30")
    outra = InscricaoFastpass.create!(user: ana.user, turno_fastpass: jantar,
      faixa_fastpass: faixa_jantar)

    expect { ConfirmarResultadoFastpass.executar(turno: turno,
      ids_sorteados: [ outra.id ]) }.to raise_error(ConfirmarResultadoFastpass::Erro)
    expect(ana.reload.sorteado).to be_nil
    expect(turno.reload.sorteio_concluido_em).to be_nil
  end

  it "impede novas inscrições após a confirmação do resultado" do
    ana = inscrever("Ana", "241020803")
    ConfirmarResultadoFastpass.executar(turno: turno, ids_sorteados: [ ana.id ])
    novo_estudante = User.create!(nome: "Carla", matricula: "251010205", role: "estudante",
      password: "Teste@1234", password_confirmation: "Teste@1234")

    nova = InscricaoFastpass.new(user: novo_estudante, turno_fastpass: turno,
      faixa_fastpass: faixa)

    expect(nova).not_to be_valid
    expect(nova.errors[:turno_fastpass]).to be_present
  end

  it "notifica uma hora antes e não duplica ao processar novamente" do
    ana = inscrever("Ana", "241020803")
    bruno = inscrever("Bruno", "231010204")
    ConfirmarResultadoFastpass.executar(turno: turno, ids_sorteados: [ ana.id ])

    NotificarResultadosFastpass.executar(agora: Time.zone.local(2026, 10, 20, 9, 59))
    expect(NotificacaoFastpass.count).to eq(0)

    horario = Time.zone.local(2026, 10, 20, 10, 0)
    NotificarResultadosFastpass.executar(agora: horario)
    NotificarResultadosFastpass.executar(agora: horario)

    expect(NotificacaoFastpass.count).to eq(2)
    expect(ana.reload.notificacao_fastpass.mensagem).to include("ganhou", "Almoço", "11:00 às 11:30")
    expect(bruno.reload.notificacao_fastpass.mensagem).to include("não ganhou", "Almoço")
  end
end
