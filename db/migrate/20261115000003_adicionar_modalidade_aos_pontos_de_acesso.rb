class AdicionarModalidadeAosPontosDeAcesso < ActiveRecord::Migration[8.1]
  def change
    add_column :pontos_acessos, :modalidade, :string, default: "Comum", null: false
    add_check_constraint :pontos_acessos,
      "modalidade IN ('Comum', 'FastPass')", name: "modalidade_do_ponto_valida"
  end
end
