require "rails_helper"

RSpec.describe GerenciarRestauranteCatraca, type: :model do
  it "valida IDs no intervalo permitido de 1 a 6" do
    expect {
      described_class.cadastrar_restaurante(id: 0)
    }.to raise_error(GerenciarRestauranteCatraca::ErroValidacao, /ID é inválido/)

    expect {
      described_class.cadastrar_restaurante(id: 7)
    }.to raise_error(GerenciarRestauranteCatraca::ErroValidacao, /ID é inválido/)

    restaurante = described_class.cadastrar_restaurante(id: 1)
    expect(restaurante).to be_persisted
  end

  it "impede duplicidade de ID de restaurante e catraca" do
    r1 = described_class.cadastrar_restaurante(id: 1)
    expect {
      described_class.cadastrar_restaurante(id: 1)
    }.to raise_error(GerenciarRestauranteCatraca::ErroValidacao, /restaurante já existe/)

    described_class.cadastrar_catraca(id: 1, restaurante: r1)
    expect {
      described_class.cadastrar_catraca(id: 1, restaurante: r1)
    }.to raise_error(GerenciarRestauranteCatraca::ErroValidacao, /catraca já existe/)
  end

  it "impede associar uma catraca já vinculada a outro restaurante" do
    r1 = described_class.cadastrar_restaurante(id: 1)
    r2 = described_class.cadastrar_restaurante(id: 2)
    catraca = described_class.cadastrar_catraca(id: 1, restaurante: r1)

    expect {
      described_class.associar_catraca!(catraca_id: catraca.id, restaurante: r2)
    }.to raise_error(GerenciarRestauranteCatraca::ErroValidacao, /já está sendo utilizada/)
  end
end
