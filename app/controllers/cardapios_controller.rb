class CardapiosController < ApplicationController
  def show
    persistidas = Refeicao.na_data(Date.current).index_by(&:tipo)
    semanais = CardapioSemanal.para(Date.current)
    @refeicoes = (semanais.map { |refeicao| persistidas.delete(refeicao.tipo) || refeicao } + persistidas.values).sort_by(&:inicio)
  end
end
