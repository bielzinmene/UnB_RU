# language: pt

# issue 3

Funcionalidade: Visualizar extrato de recargas e histórico de refeições
Como estudante
Quero visualizar meu extrato de recargas e histórico de refeições
Para ter controle sobre meus gastos

Regras:
- O estudante deve estar autenticado no sistema.
- O extrato de recargas deve exibir a data, hora, valor de cada recarga realizada na conta.
- O histórico de refeições deve exibir a data, hora, RU e o valor debitado de cada acesso efetuado na catraca.
- As transações devem ser ordenadas da mais recente para a mais antiga por padrão.
- Se o estudante não possuir registros em nenhum dos históricos, uma mensagem informativa correspondente deve ser exibida.

Contexto:
  Dado que a data atual é 16/10/2026
  E que o estudante "Cleiton" possui a matrícula "251024222" e está autenticado no sistema

# caminho feliz

Cenário: Visualizar extrato de recargas e histórico de refeições com sucesso
  Dado que o estudante possui recargas registradas no sistema
  E que o estudante possui acessos/refeições registradas na catraca
  Quando acesso a tela de extrato e histórico de consumo
  Então devo visualizar a listagem das minhas recargas com data, valor e status
  E devo visualizar a listagem do meu histórico de refeições com data, hora e valor debitado
  E os registros devem estar ordenados do mais recente para o mais antigo

# caminho triste

Cenário: Visualizar histórico vazio quando não houver transações
  Dado que a conta do estudante "Cleiton" recém-criada não possui recargas nem refeições registradas
  Quando acesso a tela de extrato e histórico de consumo
  Então o sistema deve exibir a mensagem "Nenhuma recarga encontrada" no extrato
  E o sistema deve exibir a mensagem "Nenhum histórico de refeições encontrado" nas utilizações
  E nenhum dado financeiro ou de acesso incorreto deve ser exibido