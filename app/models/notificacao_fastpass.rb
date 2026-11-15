class NotificacaoFastpass < ApplicationRecord
  self.table_name = "notificacoes_fastpass"

  belongs_to :inscricao_fastpass

  validates :mensagem, :enviada_em, presence: true
  validates :inscricao_fastpass_id, uniqueness: true
end
