class CancelarPixExpirados
  def self.executar
    Recarga
      .where(forma_pagamento: "pix", situacao: "pendente")
      .where("expira_em <= ?", Time.current)
      .update_all(
        situacao: "cancelada",
        updated_at: Time.current
      )
  end
end
