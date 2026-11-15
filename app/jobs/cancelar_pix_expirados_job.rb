class CancelarPixExpiradosJob < ActiveJob::Base
  queue_as :default

  def perform
    CancelarPixExpirados.executar
  end
end
