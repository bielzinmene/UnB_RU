class AreaEstudanteController < ApplicationController
  before_action :exigir_estudante

  def index
  end

  private

  def exigir_estudante
    unless usuario_atual&.estudante?
      redirect_to login_estudante_path,
        alert: "Você precisa se autenticar como estudante para continuar."
    end
  end
end
