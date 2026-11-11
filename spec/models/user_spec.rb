require "rails_helper"

RSpec.describe User, type: :model do
  let(:dados) do
    { nome: "Joaquim Silva", matricula: "241020803", role: "estudante",
      password: "12345Aa@", password_confirmation: "12345Aa@" }
  end

  it "cria estudante com matrícula e senha válidas" do
    expect(User.new(dados)).to be_valid
  end

  it "recusa matrícula de semestre inválido" do
    user = User.new(dados.merge(matricula: "243020803"))
    expect(user).not_to be_valid
    expect(user.errors.full_messages.join).to include("semestre 1 ou 2")
  end

  it "recusa ano futuro" do
    user = User.new(dados.merge(matricula: "281020803"))
    expect(user).not_to be_valid
    expect(user.errors.full_messages.join).to include("ano futuro")
  end

  it "recusa matrícula repetida" do
    User.create!(dados)
    expect(User.new(dados)).not_to be_valid
  end

  it "recusa senha sem uma classe obrigatória" do
    user = User.new(dados.merge(password: "Senha123", password_confirmation: "Senha123"))
    expect(user).not_to be_valid
    expect(user.errors.full_messages.join).to include("caractere especial")
  end

  it "não autentica estudante como funcionário" do
    User.create!(dados)
    expect(User.autenticar_funcionario("241020803", "12345Aa@")).to be_nil
  end

  it "autentica funcionário por SIAPE ou SIGAA com sua própria senha" do
    funcionario = User.create!(nome: "Aline", role: "funcionario", siape: "123456-7", sigaa: "aline.ru", password: "Teste@1234")
    expect(User.autenticar_funcionario("123456-7", "Teste@1234")).to eq(funcionario)
    expect(User.autenticar_funcionario("aline.ru", "Teste@1234")).to eq(funcionario)
    expect(User.autenticar_funcionario("123456-7", "errada")).to be_nil
  end

  it "impede que SIAPE e SIGAA de contas diferentes tenham o mesmo identificador" do
    User.create!(nome: "Aline", role: "funcionario", siape: "123456-7", password: "Teste@1234")
    outro = User.new(nome: "Bruno", role: "funcionario", sigaa: "123456-7", password: "Outra@1234")
    expect(outro).not_to be_valid
    expect(outro.errors.full_messages.join).to include("outra conta")

    User.create!(nome: "Carla", role: "funcionario", sigaa: "654321-0", password: "Teste@1234")
    outro.siape = "654321-0"
    outro.sigaa = nil
    expect(outro).not_to be_valid
    expect(outro.errors.full_messages.join).to include("outra conta")
  end

  it "recusa autenticação ambígua de dados antigos mesmo com uma senha válida" do
    aline = User.create!(nome: "Aline", role: "funcionario", siape: "123456-7", password: "Teste@1234")
    bruno = User.create!(nome: "Bruno", role: "funcionario", sigaa: "bruno.ru", password: "Outra@1234")
    bruno.update_column(:sigaa, aline.siape)

    expect(User.autenticar_funcionario("123456-7", "Teste@1234")).to be_nil
    expect(User.autenticar_funcionario("123456-7", "Outra@1234")).to be_nil
  end

  it "exige o formato SIAPE com seis dígitos, hífen e dígito final" do
    funcionario = User.new(nome: "Aline", role: "funcionario", siape: "241020788", password: "Teste@1234")
    expect(funcionario).not_to be_valid
    expect(funcionario.errors.full_messages.join).to include("123456-7")
    funcionario.siape = "123456-7"
    expect(funcionario).to be_valid
  end
end
