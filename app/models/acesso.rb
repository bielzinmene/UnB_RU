class Acesso < ApplicationRecord
  RESULTADOS = %w[Liberado Bloqueado].freeze
  REFEICOES = %w[Café Almoço Jantar].freeze

  belongs_to :ponto_acesso
  belongs_to :user, optional: true

  validates :matricula, :ocorrido_em, :refeicao, :resultado,
    presence: true
  validates :resultado, inclusion: { in: RESULTADOS }
  validates :refeicao, inclusion: { in: REFEICOES }
  validates :valor_debitado, numericality: {
    greater_than_or_equal_to: 0
  }

  scope :mais_recentes, -> { order(ocorrido_em: :desc, id: :desc) }
  scope :na_data, ->(data) { where(ocorrido_em: data.all_day) }
  scope :do_turno, ->(turno) {
    turno == "Todos" ? all : where(refeicao: turno)
  }
  scope :do_campus, ->(campus) {
    joins(:ponto_acesso).where(pontos_acessos: { campus: campus })
  }

  def liberado?
    resultado == "Liberado"
  end
end
