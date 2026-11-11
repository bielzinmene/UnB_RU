class CadastrosController < ApplicationController
  def new
    @user = User.new(role: "estudante")
  end

  def create
    @user = User.new(cadastro_params.merge(role: "estudante"))
    if @user.save
      reset_session
      session[:user_id] = @user.id
      redirect_to root_path, notice: "Conta criada com sucesso."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def cadastro_params
    params.require(:user).permit(:nome, :matricula, :password, :password_confirmation)
  end
end
