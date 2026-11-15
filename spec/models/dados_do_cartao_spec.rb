require "rails_helper"

RSpec.describe DadosDoCartao do
  let(:dados_validos) do
    {
      numero: "4111111111111111",
      cpf: "52998224725",
      nome: "Bruno Teste",
      validade: 2.years.from_now.strftime("%m/%y"),
      cvv: "123"
    }
  end

  it "aceita dados de cartão válidos para a demonstração" do
    cartao = described_class.new(dados_validos)

    expect(cartao).to be_valid
  end

  exemplos_invalidos = [
    [ :numero, "null", "Insira um número válido." ],
    [ :cpf, "126.032.894-7", "Insira um CPF válido." ],
    [ :cvv, "0", "CVV inválido." ],
    [ :validade, "28/19", "Insira uma data válida (mm/aa)." ]
  ]

  exemplos_invalidos.each do |campo, valor, mensagem|
    it "recusa #{campo} com o valor #{valor.inspect}" do
      cartao = described_class.new(
        dados_validos.merge(campo => valor)
      )

      expect(cartao).not_to be_valid
      expect(cartao.errors.full_messages).to include(mensagem)
    end
  end

  [ :numero, :cpf, :nome, :validade, :cvv ].each do |campo|
    it "recusa o campo obrigatório #{campo} vazio" do
      cartao = described_class.new(
        dados_validos.merge(campo => "")
      )

      expect(cartao).not_to be_valid
      expect(cartao.errors).not_to be_empty
    end
  end
end
