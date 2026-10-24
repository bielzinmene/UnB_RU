require "test_helper"

class AutenticacaoOperadorControllerTest < ActionDispatch::IntegrationTest
  setup do
    Operador.create!(identificacao: "1984201", password: "senha-segura-123")
  end

  test "should get index" do
    get autenticacao_operador_url
    assert_response :success
  end

  test "credenciais válidas exibem mensagem de sucesso" do
    post autenticacao_operador_url,
         params: { operador: { identificacao: "1984201", password: "senha-segura-123" } }

    assert_redirected_to autenticacao_operador_url
    follow_redirect!
    assert_select ".ru-alert--success"
  end

  test "credenciais inválidas exibem mensagem de erro" do
    post autenticacao_operador_url,
         params: { operador: { identificacao: "1984201", password: "errada" } }

    assert_response :unprocessable_content
    assert_select ".ru-alert--error"
  end

  test "campos vazios exibem mensagem de erro" do
    post autenticacao_operador_url, params: { operador: { identificacao: "", password: "" } }

    assert_response :unprocessable_content
    assert_select ".ru-alert--error"
  end
end