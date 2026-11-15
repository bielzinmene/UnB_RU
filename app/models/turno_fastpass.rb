class TurnoFastpass < ApplicationRecord
  self.table_name = "turnos_fastpass"

  has_many :faixas_fastpass, class_name: "FaixaFastpass", dependent: :destroy
  has_many :inscricoes_fastpass, class_name: "InscricaoFastpass", dependent: :restrict_with_exception

  validates :data, presence: true
  validates :tipo_refeicao, presence: true, uniqueness: { scope: :data, message: "já configurado para esta data" }
  validates :inicio, :fim, presence: true
  validate :duracao_positiva

  def inicio_minutos
    converter_para_minutos(inicio)
  end

  def fim_minutos
    converter_para_minutos(fim)
  end

  def inicio_em
    horas, minutos = inicio.split(":").map(&:to_i)
    Time.zone.local(data.year, data.month, data.day, horas, minutos)
  end

  private

  def duracao_positiva
    return if inicio.blank? || fim.blank?

    errors.add(:base, "Turno com horário inválido") if fim_minutos <= inicio_minutos
  end

  def converter_para_minutos(horario)
    horas, minutos = horario.to_s.split(":").map(&:to_i)
    (horas * 60) + minutos
  end
end
