# O arquivo original fornece as opções por dia da semana. Cada execução atualiza
# os próximos 30 dias, inclusive a data de hoje.
(Date.current..Date.current + 30.days).each do |data|
  refeicoes = CardapioSemanal.para(data)
  raise "Dados do cardápio semanal indisponíveis" if refeicoes.empty?

  refeicoes.each do |programada|
    refeicao = Refeicao.find_or_initialize_by(data: data, tipo: programada.tipo)
    refeicao.assign_attributes(programada.attributes.except("id", "created_at", "updated_at"))
    refeicao.save!
  end
end
