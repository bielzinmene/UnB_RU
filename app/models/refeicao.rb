class Refeicao < ApplicationRecord
  self.table_name = "refeicoes"
  validates :data, :tipo, :inicio, :fim, :opcao_padrao,
            :opcao_ovolactovegetariana, :opcao_vegetariana_estrita, presence: true
  validates :tipo, uniqueness: { scope: :data }
  validate :fim_depois_do_inicio

  scope :na_data, ->(data) { where(data: data) }

  def self.atual(agora = Time.current)
    na_data(agora.to_date).find { |refeicao| refeicao.em_andamento?(agora) }
  end

  def em_andamento?(agora)
    hora = agora.strftime("%H:%M:%S")
    hora >= inicio.strftime("%H:%M:%S") && hora < fim.strftime("%H:%M:%S")
  end

  private

  def fim_depois_do_inicio
    return if inicio.blank? || fim.blank?

    errors.add(:fim, "deve ser posterior ao início") if fim <= inicio
  end
end
