require "rails_helper"

RSpec.describe ValorDaRecarga do
  describe ".converter" do
    it "converte um valor válido em reais" do
      resultado = described_class.converter("R$15,00")

      expect(resultado).to eq(BigDecimal("15"))
    end

    exemplos_invalidos = {
      "R$0,00" => "Selecione um valor",
      "R$-1,50" => "Selecione um valor positivo",
      "R$2,4" => "Complete as casas decimais",
      "" => "Selecione um valor"
    }

    exemplos_invalidos.each do |valor, mensagem|
      it "recusa #{valor.inspect} com a mensagem correta" do
        expect {
          described_class.converter(valor)
        }.to raise_error(
          ValorDaRecarga::ValorInvalido,
          mensagem
        )
      end
    end
  end
end
