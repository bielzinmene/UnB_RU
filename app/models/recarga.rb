class Recarga < ApplicationRecord
  belongs_to :user

  after_create_commit :agendar_cancelamento_pix

  validates :valor, numericality: {
    greater_than: 0,
    less_than_or_equal_to: 500
  }

  validates :forma_pagamento, inclusion: {
    in: %w[pix cartao]
  }

  validates :situacao, inclusion: {
    in: %w[pendente confirmada cancelada]
  }

  validates :codigo_pix, :expira_em,
    presence: true,
    if: :pix?

  validates :confirmada_em,
    presence: true,
    if: :confirmada?

  def pix?
    forma_pagamento == "pix"
  end

  def confirmada?
    situacao == "confirmada"
  end

  def expirada?
    pix? && expira_em.present? && Time.current >= expira_em
  end

  private

  def agendar_cancelamento_pix
    if pix? && situacao == "pendente"
      CancelarPixExpiradosJob
        .set(wait_until: expira_em)
        .perform_later
    end
  end
end
