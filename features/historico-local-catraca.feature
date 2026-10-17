# language: pt
# issue 7

Funcionalidade: Histórico Local da Catraca

Como funcionário, eu quero visualizar na aplicação de controle o histórico de todos os acessos registrados apenas na catraca que estou gerenciando no momento, para realizar auditorias ou conferências locais de fluxo.

Contexto:
  Dado que a data atual é "16/10/2026"

# caminho feliz

Cenário: Visualizar histórico da catraca

  Dado que estou gerenciando a catraca de ID "1"
  E existem acessos registrados para esta catraca
  Quando acesso o histórico
  Então devo visualizar a lista de acessos
  E devo visualizar a matrícula dos estudantes
  E devo visualizar a data e hora dos acessos
  E devo visualizar a refeição correspondente
  E devo visualizar o resultado de cada acesso

# caminhos tristes

Cenário: Não permitir acesso ao histórico de outra catraca

  Dado que estou gerenciando a catraca de ID "1"
  Quando tento acessar o histórico da catraca de ID "2"
  Então a operação deve ser recusada
  
Cenário: Informar quando não houver acessos

  Dado que estou gerenciando a catraca de ID "1"
  E não existem acessos registrados para esta catraca
  Quando acesso o histórico
  Então devo ser informado que não existem acessos registrados
