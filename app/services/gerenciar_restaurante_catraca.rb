class GerenciarRestauranteCatraca
  ErroValidacao = Class.new(StandardError)

  def self.validar_id!(id)
    id_int = id.to_i
    raise ErroValidacao, "ID é inválido" unless (1..6).cover?(id_int)
    id_int
  end

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
      identificador: "CAT-#{id_int}",
      nome: nome.presence || "Catraca #{id_int}",
      campus: campus,
      status: "Ativo",
      restaurante: restaurante
    )
  end

  def self.associar_catraca!(catraca_id:, restaurante:)
    catraca = PontoAcesso.find(catraca_id.to_i)
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
end