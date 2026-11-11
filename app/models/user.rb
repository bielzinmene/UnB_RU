class User < ApplicationRecord
  has_secure_password

  ROLES = %w[estudante funcionario administrador].freeze

  validates :nome, presence: { message: "nome completo é obrigatório" }
  validates :role, inclusion: { in: ROLES }
  validates :matricula, presence: { message: "matrícula é obrigatória" }, if: :estudante?
  validates :matricula, uniqueness: { message: "Matricula já existente" }, allow_blank: true
  validates :password_confirmation, presence: { message: "confirmação de senha é obrigatória" }, if: -> { estudante? && new_record? }
  validates :siape, uniqueness: true, allow_blank: true
  validates :siape, format: { with: /\A\d{6}-\d\z/, message: "deve ter o formato 123456-7" }, allow_blank: true
  validates :sigaa, uniqueness: true, allow_blank: true
  validate :identificadores_nao_pertencem_a_outra_conta
  validate :validar_matricula_estudantil, if: :estudante?
  validate :validar_senha_estudantil, if: -> { estudante? && (new_record? || password.present?) }

  def estudante? = role == "estudante"
  def funcionario? = role == "funcionario"
  def operador? = funcionario? || role == "administrador"

  def self.autenticar_funcionario(identificador, senha)
    return nil if identificador.blank? || senha.blank?

    candidatos = where(role: %w[funcionario administrador])
      .where("siape = :identificador OR sigaa = :identificador", identificador: identificador)
      .to_a
    return nil unless candidatos.one?

    candidatos.first.authenticate(senha) || nil
  end

  private

  def identificadores_nao_pertencem_a_outra_conta
    outras_contas = User.where.not(id: id)
    if siape.present? && outras_contas.exists?(sigaa: siape)
      errors.add(:siape, "já está cadastrado como usuário SIGAA em outra conta")
    end
    if sigaa.present? && outras_contas.exists?(siape: sigaa)
      errors.add(:sigaa, "já está cadastrado como matrícula SIAPE em outra conta")
    end
  end

  def validar_matricula_estudantil
    return if matricula.blank?

    unless matricula.match?(/\A\d+\z/)
      errors.add(:matricula, "deve conter apenas dígitos numéricos")
      return
    end
    unless matricula.length == 9
      errors.add(:matricula, "deve ter exatamente 9 dígitos")
      return
    end
    errors.add(:matricula, "deve indicar o semestre 1 ou 2") unless %w[1 2].include?(matricula[2])
    ano = matricula[0, 2].to_i
    ano_atual = Date.current.year % 100
    errors.add(:matricula, "não pode indicar um ano futuro") if ano > ano_atual
  end

  def validar_senha_estudantil
    if password.blank?
      errors.add(:password, "senha é obrigatória")
      return
    end

    regras = {
      "deve ter pelo menos 8 caracteres" => password.length >= 8,
      "deve conter uma letra maiúscula" => password.match?(/[A-Z]/),
      "deve conter uma letra minúscula" => password.match?(/[a-z]/),
      "deve conter um dígito numérico" => password.match?(/\d/),
      "deve conter um caractere especial" => password.match?(/[^[:alnum:]]/)
    }
    regras.each { |mensagem, valido| errors.add(:password, mensagem) unless valido }
  end
end
