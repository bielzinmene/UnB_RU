class GerenciarRestauranteCatraca
  class ErroValidacao < StandardError; end

  IDS_VALIDOS = (1..6).freeze

  def self.cadastrar_restaurante(id:, nome: nil, campus: "UnB Darcy Ribeiro")
    id_int = validar_id!(id)
    raise ErroValidacao, "O restaurante já existe" if Restaurante.exists?(id: id_int)

    Restaurante.create!(
      id: id_int,
      nome: nome.presence || "RU #{id_int}",
      campus: campus
    )
  end

  def self.cadastrar_catraca(id:, restaurante:, nome: nil, campus: "UnB Darcy Ribeiro")
    id_int = validar_id!(id)
    raise ErroValidacao, "A catraca já existe" if PontoAcesso.exists?(id: id_int)

    PontoAcesso.create!(
      id: id_int,
      restaurante: restaurante,
      identificador: "CAT-#{id_int}",
      nome: nome.presence || "Catraca #{id_int}",
      campus: restaurante.campus.presence || campus,
      status: "Ativo"
    )
  end

  def self.associar_catraca!(catraca_id:, restaurante:)
    id_int = validar_id!(catraca_id)
    catraca = PontoAcesso.find_by(id: id_int)
    raise ErroValidacao, "A catraca informada não existe" unless catraca

    if catraca.restaurante_id.present? && catraca.restaurante_id != restaurante.id
      raise ErroValidacao, "A catraca já está sendo utilizada"
    end

    catraca.update!(restaurante: restaurante)
    catraca
  end

  def self.validar_restaurante_com_catraca!(restaurante)
    if restaurante.pontos_acesso.reload.empty?
      restaurante.destroy
      raise ErroValidacao, "O restaurante precisa de uma catraca"
    end
  end

  def self.validar_id!(id)
    texto = id.to_s.strip
    raise ErroValidacao, "O ID é inválido" unless texto.match?(/\A\d+\z/)

    numero = texto.to_i
    raise ErroValidacao, "O ID é inválido" unless IDS_VALIDOS.include?(numero)

    numero
  end
end
