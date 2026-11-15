class PontoAcesso < ApplicationRecord
  self.table_name = "pontos_acessos"

  STATUS = %w[Ativo Inativo].freeze

  belongs_to :restaurante
  has_many :acessos, dependent: :restrict_with_exception

  validates :identificador, :nome, :campus, :status, presence: true
  validates :identificador, uniqueness: true
  validates :status, inclusion: { in: STATUS }
  validates :campus, inclusion: { in: Restaurante::CAMPI }
  validate :campus_deve_corresponder_ao_restaurante

  scope :ativos, -> { where(status: "Ativo") }

  def ativo?
    status == "Ativo"
  end

  def autoriza_entrada?(restaurante_informado = restaurante)
    ativo? && restaurante_informado == restaurante && restaurante.ativo?
  end

  private

  def campus_deve_corresponder_ao_restaurante
    return if restaurante.blank? || campus.blank?
    return if Restaurante::CAMPI.include?(campus) &&
      Restaurante::CAMPI.include?(restaurante.campus)

    errors.add(:campus, "deve corresponder ao restaurante selecionado")
  end
end
