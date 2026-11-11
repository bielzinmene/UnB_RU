class SessoesController < ApplicationController
  def new; end

  def create
    identificador = params[:identificador].to_s.strip
    senha = params[:senha].to_s
    if identificador.blank? || senha.blank?
      flash.now[:alert] = "Matrícula SIAPE/SIGAA e senha são obrigatórias."
      render :new, status: :unprocessable_entity
      return
    end

    usuario = User.autenticar_funcionario(identificador, senha)
    if usuario
      reset_session
      session[:user_id] = usuario.id
      redirect_to area_funcionario_path, notice: "Login realizado com sucesso."
    else
      flash.now[:alert] = "Matrícula e/ou Senha de Acesso incorretos. Não há nenhuma conta com esses dados registrados no sistema."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    reset_session
    redirect_to login_funcionario_path, notice: "Sessão encerrada."
  end
end
