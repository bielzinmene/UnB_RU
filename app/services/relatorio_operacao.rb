class RelatorioOperacao
  TURNOS = [ "Todos", "Café", "Almoço", "Jantar" ].freeze

  attr_reader :data, :turno, :campus, :acessos

  def initialize(data:, turno:, campus:)
    @data = data
    @turno = TURNOS.include?(turno) ? turno : "Todos"
    @campus = campus
    @acessos = Acesso.na_data(data)
      .do_turno(@turno)
      .do_campus(campus)
      .includes(:ponto_acesso, :user)
      .mais_recentes
  end

  def vazio?
    acessos.empty?
  end

  def liberados
    acessos.select(&:liberado?)
  end

  def bloqueados
    acessos.reject(&:liberado?)
  end

  def total_arrecadado
    liberados.sum(&:valor_debitado)
  end

  def restaurantes
    acessos.group_by { |acesso| acesso.ponto_acesso.restaurante.nome }
  end
end
