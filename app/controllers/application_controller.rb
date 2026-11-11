class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  helper_method :usuario_atual

  private

  def usuario_atual
    @usuario_atual ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def exigir_funcionario
    redirect_to login_funcionario_path, alert: "Faça login como funcionário para continuar." unless usuario_atual&.operador?
  end
end
