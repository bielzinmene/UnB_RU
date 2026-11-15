class ExtratoDoEstudante
  attr_reader :estudante, :recargas, :consumos

  def initialize(estudante)
    @estudante = estudante

    @recargas = estudante.recargas
      .where(situacao: "confirmada")
      .order(confirmada_em: :desc, id: :desc)
      .to_a

    @consumos = estudante.consumos
      .mais_recentes
      .to_a
  end

  def vazio?
    recargas.empty? && consumos.empty?
  end
end
