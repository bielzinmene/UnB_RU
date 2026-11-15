Dado("não existe restaurante com ID {string}") do |id|
  Restaurante.where(id: id.to_i).destroy_all
end

Dado("não existe catraca com ID {string}") do |id|
  PontoAcesso.where(id: id.to_i).destroy_all
end

Dado("que existe um restaurante com ID {string}") do |id|
  Restaurante.find_or_create_by!(id: id.to_i) { |r| r.nome = "RU #{id}"; r.campus = "UnB Darcy Ribeiro" }
end

Dado("que existe uma catraca com ID {string}") do |id|
  r_padrao = Restaurante.find_or_create_by!(nome: "RU Base", campus: "UnB Darcy Ribeiro")
  PontoAcesso.find_or_create_by!(id: id.to_i) do |c|
    c.identificador = "CAT-#{id}"
    c.nome = "Catraca #{id}"
    c.campus = "UnB Darcy Ribeiro"
    c.status = "Ativo"
    c.restaurante = r_padrao
  end
end

Dado("que a catraca de ID {string} já está associada a um restaurante") do |id|
  r1 = Restaurante.find_or_create_by!(id: 1) { |r| r.nome = "RU 1"; r.campus = "UnB Darcy Ribeiro" }
  Restaurante.find_or_create_by!(id: 2) { |r| r.nome = "RU 2"; r.campus = "UnB Darcy Ribeiro" }
  PontoAcesso.find_or_create_by!(id: id.to_i) do |c|
    c.identificador = "CAT-#{id}"
    c.nome = "Catraca #{id}"
    c.campus = "UnB Darcy Ribeiro"
    c.status = "Ativo"
    c.restaurante = r1
  end
end

Quando("cadastro o restaurante de ID {string}") do |id|
  @restaurante_pendente_id = id.to_i
  @erro_operacao = nil
end

Quando("cadastro a catraca de ID {string}") do |id|
  @catraca_pendente_id = id.to_i
  @restaurante_atual = GerenciarRestauranteCatraca.cadastrar_restaurante(id: @restaurante_pendente_id)
  @catraca_atual = GerenciarRestauranteCatraca.cadastrar_catraca(id: @catraca_pendente_id, restaurante: @restaurante_atual)
rescue GerenciarRestauranteCatraca::ErroValidacao => e
  @erro_operacao = e.message
end

Quando("associo a catraca ao restaurante") do
  next if @erro_operacao.present?
  GerenciarRestauranteCatraca.associar_catraca!(catraca_id: @catraca_atual.id, restaurante: @restaurante_atual)
  GerenciarRestauranteCatraca.validar_restaurante_com_catraca!(@restaurante_atual)
rescue GerenciarRestauranteCatraca::ErroValidacao => e
  @erro_operacao = e.message
end

Quando("não associo uma catraca") do
  @restaurante_atual = GerenciarRestauranteCatraca.cadastrar_restaurante(id: @restaurante_pendente_id)
  GerenciarRestauranteCatraca.validar_restaurante_com_catraca!(@restaurante_atual)
rescue GerenciarRestauranteCatraca::ErroValidacao => e
  @erro_operacao = e.message
end

Quando("tento cadastrar o restaurante de ID {string}") do |id|
  GerenciarRestauranteCatraca.cadastrar_restaurante(id: id)
rescue GerenciarRestauranteCatraca::ErroValidacao => e
  @erro_operacao = e.message
end

Quando("tento cadastrar a catraca de ID {string}") do |id|
  r_padrao = Restaurante.first || Restaurante.create!(nome: "RU Temp", campus: "UnB Darcy Ribeiro")
  GerenciarRestauranteCatraca.cadastrar_catraca(id: id, restaurante: r_padrao)
rescue GerenciarRestauranteCatraca::ErroValidacao => e
  @erro_operacao = e.message
end

Quando("tento cadastrar o restaurante com ID {string}") do |id|
  GerenciarRestauranteCatraca.cadastrar_restaurante(id: id)
rescue GerenciarRestauranteCatraca::ErroValidacao => e
  @erro_operacao = e.message
end

Quando("tento cadastrar a catraca com ID {string}") do |id|
  next if @erro_operacao.present?
  r_padrao = Restaurante.first || Restaurante.create!(nome: "RU Temp", campus: "UnB Darcy Ribeiro")
  GerenciarRestauranteCatraca.cadastrar_catraca(id: id, restaurante: r_padrao)
rescue GerenciarRestauranteCatraca::ErroValidacao => e
  @erro_operacao = e.message
end

Quando("tento associar a catraca de ID {string} a outro restaurante") do |id|
  r2 = Restaurante.find(2)
  GerenciarRestauranteCatraca.associar_catraca!(catraca_id: id, restaurante: r2)
rescue GerenciarRestauranteCatraca::ErroValidacao => e
  @erro_operacao = e.message
end

Então("o restaurante deve ser cadastrado com sucesso") do
  expect(@erro_operacao).to be_nil
  expect(Restaurante.exists?(id: @restaurante_pendente_id)).to be(true)
end

Então("a associação deve ser recusada") { expect(@erro_operacao).not_to be_nil }
Então("devo ser informado que o restaurante já existe") { expect(@erro_operacao).to include("O restaurante já existe") }
Então("devo ser informado que a catraca já existe") { expect(@erro_operacao).to include("A catraca já existe") }
Então("devo ser informado que o ID é inválido") { expect(@erro_operacao).to include("ID é inválido") }
Então("devo ser informado que a catraca já está sendo utilizada") { expect(@erro_operacao).to include("A catraca já está sendo utilizada") }
Então("devo ser informado que o restaurante precisa de uma catraca") { expect(@erro_operacao).to include("O restaurante precisa de uma catraca") }
Então("o cadastro do restaurante ou catraca deve ser recusado") do
  expect(@erro_operacao).not_to be_nil
end
