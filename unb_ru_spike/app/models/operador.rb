class Operador < ApplicationRecord
  has_secure_password

  validates :identificacao, presence: true
end