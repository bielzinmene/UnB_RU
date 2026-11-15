class Consumo < ApplicationRecord
  belongs_to :user

  validates :restaurante, :ocorrido_em, :referencia,
    presence: true

  validates :referencia, uniqueness: true

  validates :valor_debitado, numericality: {
    greater_than_or_equal_to: 0
  }

  scope :mais_recentes, -> {
    order(ocorrido_em: :desc, id: :desc)
  }
end
