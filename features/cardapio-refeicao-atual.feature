# language: pt
# issue 10

Funcionalidade: Cardápio do dia

Como estudante, quero consultar as três refeições do dia a qualquer horário para planejar minha ida ao RU. Cada refeição apresenta as opções padrão, ovolactovegetariana e vegetariana estrita.


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

Cenário: Consultar as três refeições fora do horário de serviço
  Dado que o horário atual é "16:00"
  Quando acesso o cardápio
  Então devo visualizar café da manhã, almoço e jantar
  E devo visualizar as opções das três refeições

Cenário: Informar indisponibilidade dos dados do cardápio

  Dado que os dados do cardápio do dia estão indisponíveis
  Quando acesso o cardápio
  Então devo ser informado que o cardápio está temporariamente indisponível
