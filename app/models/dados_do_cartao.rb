class DadosDoCartao
  include ActiveModel::Model

  attr_accessor :numero, :cpf, :nome, :validade, :cvv

  validate :validar_numero
  validate :validar_cpf
  validate :validar_nome
  validate :validar_validade
  validate :validar_cvv

  private

  def validar_numero
    digitos = numero.to_s.delete(" -")

    formato_valido = digitos.match?(/\A\d{13,19}\z/)
    todos_iguais = digitos.chars.uniq.length <= 1

    unless formato_valido && !todos_iguais
      errors.add(:base, "Insira um número válido.")
      return
    end

    soma = digitos.reverse.chars.map(&:to_i).each_with_index.sum do |digito, indice|
      valor = indice.odd? ? digito * 2 : digito
      valor > 9 ? valor - 9 : valor
    end

    unless (soma % 10).zero?
      errors.add(:base, "Insira um número válido.")
    end
  end

  def validar_cpf
    formato_valido = cpf.to_s.match?(
      /\A(?:\d{11}|\d{3}\.\d{3}\.\d{3}-\d{2})\z/
    )

    unless formato_valido
      errors.add(:base, "Insira um CPF válido.")
      return
    end

    digitos = cpf.to_s.delete(".-").chars.map(&:to_i)

    if digitos.uniq.length == 1
      errors.add(:base, "Insira um CPF válido.")
      return
    end

    verificadores_validos = [ 9, 10 ].all? do |tamanho|
      soma = digitos.first(tamanho).each_with_index.sum do |digito, indice|
        digito * (tamanho + 1 - indice)
      end

      resultado = (soma * 10) % 11
      resultado = 0 if resultado == 10

      digitos[tamanho] == resultado
    end

    unless verificadores_validos
      errors.add(:base, "Insira um CPF válido.")
    end
  end

  def validar_nome
    if nome.to_s.strip.empty?
      errors.add(:base, "Informe o nome no cartão.")
    end
  end

  def validar_validade
    unless validade.to_s.match?(/\A(0[1-9]|1[0-2])\/\d{2}\z/)
      errors.add(:base, "Insira uma data válida (mm/aa).")
      return
    end

    mes, ano = validade.split("/").map(&:to_i)
    vencimento = Date.new(2000 + ano, mes, 1).end_of_month

    if vencimento < Date.current
      errors.add(:base, "Insira uma data válida (mm/aa).")
    end
  end

  def validar_cvv
    unless cvv.to_s.match?(/\A\d{3,4}\z/)
      errors.add(:base, "CVV inválido.")
    end
  end
end
