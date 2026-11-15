require "rails_helper"

RSpec.describe ConfirmarRecargaPix do
  include ActiveSupport::Testing::TimeHelpers

  let(:estudante) do
    User.create!(
      nome: "Bruno",
      matricula: "251099003",
      role: "estudante",
      password: "Teste@1234",
      password_confirmation: "Teste@1234",
      saldo: 10,
      grupo_pagamento: "2"
    )
  end

  let(:recarga) do
    SolicitarRecarga.executar(
      usuario: estudante,
      valor: "R$15,00",
      forma_pagamento: "pix"
    )
  end

  around do |exemplo|
    adaptador_anterior = ActiveJob::Base.queue_adapter
    ActiveJob::Base.queue_adapter = :test

    begin
      exemplo.run
    ensure
      ActiveJob::Base.queue_adapter = adaptador_anterior
    end
  end

  it "confirma o PIX e atualiza o saldo para R$25" do
    described_class.executar(recarga: recarga)

    expect(recarga.reload.situacao).to eq("confirmada")
    expect(recarga.confirmada_em).to be_present
    expect(estudante.reload.saldo).to eq(BigDecimal("25"))
  end

  it "não adiciona créditos novamente ao repetir a confirmação" do
    described_class.executar(recarga: recarga)
    described_class.executar(recarga: recarga)

    expect(estudante.reload.saldo).to eq(BigDecimal("25"))
    expect(estudante.recargas.count).to eq(1)
  end

  it "permite confirmar um segundo antes do vencimento" do
    pix = recarga

    travel_to(pix.expira_em - 1.second, with_usec: true) do
      described_class.executar(recarga: pix)
    end

    expect(pix.reload.situacao).to eq("confirmada")
    expect(estudante.reload.saldo).to eq(BigDecimal("25"))
  end

  it "recusa a confirmação no instante do vencimento" do
    pix = recarga

    travel_to(pix.expira_em, with_usec: true) do
      expect {
        described_class.executar(recarga: pix)
      }.to raise_error(
        ConfirmarRecargaPix::Erro,
        "Recarga PIX cancelada: prazo de dez minutos encerrado."
      )
    end

    expect(pix.reload.situacao).to eq("cancelada")
    expect(estudante.reload.saldo).to eq(BigDecimal("10"))
  end

  it "cancela o PIX vencido quando a tarefa agendada executa" do
    pix = recarga

    tarefa = ActiveJob::Base.queue_adapter.enqueued_jobs.find do |item|
      item[:job] == CancelarPixExpiradosJob
    end

    expect(tarefa).to be_present
    expect(tarefa[:at]).to be_within(0.01).of(pix.expira_em.to_f)

    travel_to(pix.expira_em, with_usec: true) do
      CancelarPixExpiradosJob.perform_now
    end

    expect(pix.reload.situacao).to eq("cancelada")
    expect(estudante.reload.saldo).to eq(BigDecimal("10"))
  end
end
