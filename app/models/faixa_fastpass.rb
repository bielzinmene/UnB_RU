class FaixaFastpass < ApplicationRecord
  self.table_name = "faixas_fastpass"

  belongs_to :turno_fastpass
  has_many :inscricoes_fastpass, class_name: "InscricaoFastpass", dependent: :restrict_with_exception

  validates :inicio, :fim, presence: true
  validate :duracao_positiva
  validate :dentro_do_horario_do_turno
  validate :sem_sobreposicao_no_turno

  def inicio_minutos
    converter_para_minutos(inicio)
  end

  def fim_minutos
    converter_para_minutos(fim)
  end

  private

  def duracao_positiva
    return if inicio.blank? || fim.blank?

    errors.add(:base, "Faixa com horário inválido") if fim_minutos <= inicio_minutos
  end

  def dentro_do_horario_do_turno
    return unless turno_fastpass && inicio.present? && fim.present?
    return if fim_minutos <= inicio_minutos

    if inicio_minutos < turno_fastpass.inicio_minutos || fim_minutos > turno_fastpass.fim_minutos
      errors.add(:base, "Faixa fora do horário do turno")
    end
  end

  def sem_sobreposicao_no_turno
    return unless turno_fastpass && inicio.present? && fim.present?
    return if fim_minutos <= inicio_minutos

    conflito = turno_fastpass.faixas_fastpass.where.not(id: id).any? do |outra|
      inicio_minutos < outra.fim_minutos && fim_minutos > outra.inicio_minutos
    end

    errors.add(:base, "Faixa recusada por sobreposição") if conflito
  end

  def converter_para_minutos(horario)
    horas, minutos = horario.to_s.split(":").map(&:to_i)
    (horas * 60) + minutos
  end
end
