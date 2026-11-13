class Restaurante < ApplicationRecord
  CAMPI = [ "UnB Darcy Ribeiro", "Campus Darcy Ribeiro" ].freeze

  has_many :pontos_acesso,
    class_name: "PontoAcesso",
    dependent: :restrict_with_exception

  validates :nome, :campus, presence: true
  validates :nome, uniqueness: { scope: :campus }
  validates :campus, inclusion: { in: CAMPI }
end
