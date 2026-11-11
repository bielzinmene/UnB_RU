require "rails_helper"

RSpec.describe "Identidade", type: :request do
  it "permite ao estudante entrar novamente e sair da conta" do
    estudante = User.create!(nome: "Joaquim", matricula: "241020803", role: "estudante", password: "12345Aa@", password_confirmation: "12345Aa@")

    get login_estudante_path
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Login do estudante")

    post login_estudante_path, params: { matricula: " 241020803 ", senha: "12345Aa@" }
    expect(response).to redirect_to(root_path)
    expect(session[:user_id]).to eq(estudante.id)
    get root_path
    expect(response.body).to include("Sair da conta")

    delete logout_estudante_path
    expect(response).to redirect_to(login_estudante_path)
    expect(session[:user_id]).to be_nil
    get root_path
    expect(response.body).to include("Entrar como estudante")
  end

  it "recusa senha errada e credenciais de funcionário no login do estudante" do
    User.create!(nome: "Joaquim", matricula: "241020803", role: "estudante", password: "12345Aa@", password_confirmation: "12345Aa@")
    funcionario = User.create!(nome: "Aline", role: "funcionario", siape: "123456-7", password: "Teste@1234")

    post login_estudante_path, params: { matricula: "241020803", senha: "errada" }
    expect(response).to have_http_status(:unprocessable_entity)
    expect(session[:user_id]).to be_nil

    post login_estudante_path, params: { matricula: funcionario.siape, senha: "Teste@1234" }
    expect(response).to have_http_status(:unprocessable_entity)
    expect(session[:user_id]).to be_nil
  end

  it "cria estudante pelo formulário e impede senha divergente" do
    post cadastro_path, params: { user: { nome: "Joaquim", matricula: "241020803", password: "12345Aa@", password_confirmation: "12345Aa@" } }
    expect(response).to redirect_to(root_path)
    estudante = User.find_by(matricula: "241020803")
    expect(estudante).to be_present
    expect(session[:user_id]).to eq(estudante.id)

    post cadastro_path, params: { user: { nome: "Ana", matricula: "241020804", password: "12345Aa@", password_confirmation: "Outra@123" } }
    expect(response).to have_http_status(:unprocessable_entity)
    expect(User.find_by(matricula: "241020804")).to be_nil
    expect(session[:user_id]).to eq(estudante.id)
  end

  it "mostra o número da matrícula ao recusar cadastro duplicado" do
    User.create!(nome: "Joaquim", matricula: "241020803", role: "estudante", password: "12345Aa@", password_confirmation: "12345Aa@")
    post cadastro_path, params: { user: { nome: "Ana", matricula: "241020803", password: "12345Aa@", password_confirmation: "12345Aa@" } }

    expect(response).to have_http_status(:unprocessable_entity)
    expect(response.body).to include("Matrícula 241020803 já está cadastrada.")
    expect(response.body).not_to include("matrícula Matricula já existente")
  end

  it "substitui uma sessão anterior ao cadastrar um estudante" do
    funcionario = User.create!(nome: "Aline", role: "funcionario", siape: "123456-7", password: "Teste@1234")
    post login_funcionario_path, params: { identificador: funcionario.siape, senha: "Teste@1234" }
    expect(session[:user_id]).to eq(funcionario.id)

    post cadastro_path, params: { user: { nome: "Joaquim", matricula: "241020803", password: "12345Aa@", password_confirmation: "12345Aa@" } }
    expect(session[:user_id]).to eq(User.find_by!(matricula: "241020803").id)
    get area_funcionario_path
    expect(response).to redirect_to(login_funcionario_path)
  end

  it "protege a área, autentica funcionário e encerra a sessão" do
    funcionario = User.create!(nome: "Aline", role: "funcionario", siape: "123456-7", password: "Teste@1234")
    get area_funcionario_path
    expect(response).to redirect_to(login_funcionario_path)

    post login_funcionario_path, params: { identificador: funcionario.siape, senha: "Teste@1234" }
    expect(response).to redirect_to(area_funcionario_path)
    get area_funcionario_path
    expect(response).to have_http_status(:ok)

    delete logout_funcionario_path
    get area_funcionario_path
    expect(response).to redirect_to(login_funcionario_path)
  end

  it "não aceita a senha de outra pessoa" do
    User.create!(nome: "Aline", role: "funcionario", siape: "123456-7", password: "Teste@1234")
    User.create!(nome: "Bruno", role: "funcionario", siape: "123456-8", password: "Outra@1234")
    post login_funcionario_path, params: { identificador: "123456-7", senha: "Outra@1234" }
    expect(response).to have_http_status(:unprocessable_entity)
    get area_funcionario_path
    expect(response).to redirect_to(login_funcionario_path)
  end
end
