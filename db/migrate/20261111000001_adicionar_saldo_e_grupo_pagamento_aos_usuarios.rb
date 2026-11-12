class AdicionarSaldoEGrupoPagamentoAosUsuarios < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :saldo, :decimal,
      precision: 10,
      scale: 2,
      default: 0,
      null: false

    # 1 = isento
    # 2 = estudante pagante
    # 3 = visitante
    add_column :users, :grupo_pagamento, :string,
      default: "2",
      null: false

    add_check_constraint :users,
      "saldo >= 0 AND saldo <= 500",
      name: "saldo_dentro_do_limite"

    add_check_constraint :users,
      "grupo_pagamento IN ('1', '2', '3')",
      name: "grupo_pagamento_valido"
  end
end
