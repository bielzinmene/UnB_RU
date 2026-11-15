class ConsultarRelatorioGlobalAcessos
  def initialize(restaurante: nil, catraca: nil, agrupar_por: nil)
    @restaurante = restaurante.presence
    @catraca = catraca.presence
    @agrupar_por = agrupar_por.presence
  end

  def registros
    escopo = Acesso.includes(ponto_acesso: :restaurante).mais_recentes
    if @restaurante
      escopo = escopo.joins(ponto_acesso: :restaurante).where(restaurantes: { nome: @restaurante })
    end
    if @catraca
      escopo = escopo.joins(:ponto_acesso).where(pontos_acessos: { nome: @catraca })
    end
    escopo
  end

  def agrupado
    lista = registros.to_a
    case @agrupar_por
    when "restaurante"
      lista.group_by { |a| a.ponto_acesso.restaurante.nome }
    when "catraca"
      lista.group_by { |a| "#{a.ponto_acesso.restaurante.nome} - #{a.ponto_acesso.nome}" }
    else
      { "Todos" => lista }
    end
  end
end
