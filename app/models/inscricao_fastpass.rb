class InscricaoFastpass < ApplicationRecord
  self.table_name = "inscricoes_fastpass"

  belongs_to :user
  belongs_to :turno_fastpass
  belongs_to :faixa_fastpass
  has_one :notificacao_fastpass, dependent: :destroy

  validates :user_id, uniqueness: { scope: :turno_fastpass_id,
    message: "já possui inscrição para este dia e turno" }
  validate :estudante_e_faixa_do_turno
  validate :sorteio_ainda_aberto, on: :create

  private

  def estudante_e_faixa_do_turno
    errors.add(:user, "deve ser estudante") if user && !user.estudante?
    return unless faixa_fastpass && turno_fastpass

    if faixa_fastpass.turno_fastpass_id != turno_fastpass_id
      errors.add(:faixa_fastpass, "não pertence ao turno escolhido")
    end
  end

  def sorteio_ainda_aberto
    return unless turno_fastpass&.sorteio_concluido_em?

    errors.add(:turno_fastpass, "já possui resultado confirmado")
  end
end
