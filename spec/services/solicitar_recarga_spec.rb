require "rails_helper"

RSpec.describe SolicitarRecarga do
  include ActiveSupport::Testing::TimeHelpers

  let(:estudante) do
    User.create!(
      nome: "Bruno",
      matricula: "251099002",
      role: "estudante",
      password: "Teste@1234",
      password_confirmation: "Teste@1234",
      saldo: 10,
      grupo_pagamento: "2"
    )
  end

  let(:dados_cartao) do
    {
      numero: "4111111111111111",
      cpf: "52998224725",
      nome: "Bruno Teste",
      validade: 2.years.from_now.strftime("%m/%y"),
      cvv: "123"
    }
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

  it "cria um PIX pendente sem aumentar o saldo" do
    freeze_time do
      recarga = described_class.executar(
        usuario: estudante,
        valor: "R$15,00",
        forma_pagamento: "pix"
      )

      expect(recarga).to be_persisted
      expect(recarga.user_id).to eq(estudante.id)
      expect(recarga.valor).to eq(BigDecimal("15"))
      expect(recarga.situacao).to eq("pendente")
      expect(recarga.codigo_pix).to start_with("DEMONSTRACAO-")
      expect(recarga.expira_em).to eq(10.minutes.from_now)
      expect(estudante.reload.saldo).to eq(BigDecimal("10"))
    end
  end

  it "confirma o cartão de demonstração e acrescenta os créditos" do
    recarga = described_class.executar(
      usuario: estudante,
      valor: "R$30,00",
      forma_pagamento: "cartao",
      dados_cartao: dados_cartao
    )

    expect(recarga.situacao).to eq("confirmada")
    expect(recarga.confirmada_em).to be_present
    expect(estudante.reload.saldo).to eq(BigDecimal("40"))
  end

  it "recusa uma recarga que ultrapassa o limite de saldo" do
    expect {
      described_class.executar(
        usuario: estudante,
        valor: "R$700,00",
        forma_pagamento: "pix"
      )
    }.to raise_error(
      SolicitarRecarga::Erro,
      "O valor final do seu saldo não pode exceder R$500,00"
    )

    expect(estudante.recargas.count).to eq(0)
    expect(estudante.reload.saldo).to eq(BigDecimal("10"))
  end

  it "aceita uma recarga que chega exatamente a R$500" do
    estudante.update!(saldo: 490)

    described_class.executar(
      usuario: estudante,
      valor: "R$10,00",
      forma_pagamento: "cartao",
      dados_cartao: dados_cartao
    )

    expect(estudante.reload.saldo).to eq(BigDecimal("500"))
  end

  it "recusa recarga de estudante isento do grupo 1" do
    estudante.update!(grupo_pagamento: "1")

    expect {
      described_class.executar(
        usuario: estudante,
        valor: "R$15,00",
        forma_pagamento: "pix"
      )
    }.to raise_error(SolicitarRecarga::Erro, /isentos/)

    expect(estudante.recargas.count).to eq(0)
    expect(estudante.reload.saldo).to eq(BigDecimal("10"))
  end

  it "recusa cartão inválido sem criar recarga nem alterar saldo" do
    expect {
      described_class.executar(
        usuario: estudante,
        valor: "R$30,00",
        forma_pagamento: "cartao",
        dados_cartao: dados_cartao.merge(cvv: "0")
      )
    }.to raise_error(SolicitarRecarga::Erro, "CVV inválido.")

    expect(estudante.recargas.count).to eq(0)
    expect(estudante.reload.saldo).to eq(BigDecimal("10"))
  end

    cartoes_invalidos = [
    [ :numero, "null", "Insira um número válido." ],
    [ :cpf, "126.032.894-7", "Insira um CPF válido." ],
    [ :cvv, "0", "CVV inválido." ],
    [ :validade, "28/19", "Insira uma data válida (mm/aa)." ]
  ]

  cartoes_invalidos.each do |campo, valor, mensagem|
    it "recusa cartão com #{campo} inválido sem alterar os registros" do
      expect {
        described_class.executar(
          usuario: estudante,
          valor: "R$30,00",
          forma_pagamento: "cartao",
          dados_cartao: dados_cartao.merge(campo => valor)
        )
      }.to raise_error(SolicitarRecarga::Erro, mensagem)

      expect(estudante.recargas.count).to eq(0)
      expect(estudante.reload.saldo).to eq(BigDecimal("10"))
    end
  end

  [ :numero, :cpf, :nome, :validade, :cvv ].each do |campo|
    it "recusa cartão sem #{campo} e mantém o saldo" do
      expect {
        described_class.executar(
          usuario: estudante,
          valor: "R$30,00",
          forma_pagamento: "cartao",
          dados_cartao: dados_cartao.merge(campo => "")
        )
      }.to raise_error(SolicitarRecarga::Erro)

      expect(estudante.recargas.count).to eq(0)
      expect(estudante.reload.saldo).to eq(BigDecimal("10"))
    end
  end
end
