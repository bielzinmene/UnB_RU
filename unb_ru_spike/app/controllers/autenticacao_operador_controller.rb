class AutenticacaoOperadorController < ApplicationController
  def index
  end

  def create
    credenciais = params.expect(operador: [ :identificacao, :password ])
    identificacao = credenciais[:identificacao].to_s.strip
    senha = credenciais[:password].to_s

    if identificacao.blank? || senha.blank?
      flash.now[:alert] = "Informe a identificação e a senha."
      render :index, status: :unprocessable_content
    elsif Operador.authenticate_by(identificacao: identificacao, password: senha)
      redirect_to autenticacao_operador_path, notice: "Autenticação realizada com sucesso."
    else
      flash.now[:alert] = "Identificação ou senha inválida."
      render :index, status: :unprocessable_content
    end
  end
end