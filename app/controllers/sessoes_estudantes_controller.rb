class SessoesEstudantesController < ApplicationController
  def new; end

  def create
    matricula = params[:matricula].to_s.strip
    senha = params[:senha].to_s

    if matricula.blank? || senha.blank?
      flash.now[:alert] = "Matrícula e senha são obrigatórias."
      render :new, status: :unprocessable_entity
      return
    end

    estudante = User.find_by(role: "estudante", matricula: matricula)
    if estudante&.authenticate(senha)
      reset_session
      session[:user_id] = estudante.id
      redirect_to root_path, notice: "Login realizado com sucesso."
    else
      flash.now[:alert] = "Matrícula ou senha incorreta."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    reset_session
    redirect_to login_estudante_path, notice: "Sessão encerrada."
  end
end
