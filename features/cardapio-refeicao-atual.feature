# language pt
# issue 10

Funcionalidade: Cardápio da Refeição Atual

Como estudante, eu quero poder ver o cardápio da refeição que esteja sendo servida agora. Incluindo as opções padrão, ovolactovegetariano e vegetariano estrito.


Contexto:
  Dado que a data atual é 16/10/2026

# caminho feliz

Cenário: Visualizar cardápio da refeição atual

  Dado que existe um cardápio para a refeição atual
  Quando acesso o cardápio
  Então devo visualizar a opção padrão
  E devo visualizar a opção ovolactovegetariana
  E devo visualizar a opção vegetariana estrita

# caminhos tristes

Cenário: Informar ausência de cardápio

  Dado que não existe cardápio para a refeição atual
  Quando acesso o cardápio
  Então devo ser informado que não há cardápio disponível
