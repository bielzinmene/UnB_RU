# language: pt
# issue 2

Funcionalidade: Recarga de saldo
  Como estudante
  Eu quero adicionar créditos a minha conta via PIX ou cartão de crédito
  Para que eu tenha saldo suficiente para acessar os restaurantes Universitários

    #feliz

  Cenário: Adicionar créditos via PIX
    Dado que estou autenticado como o estudante "Bruno" com saldo de R$10,00
    E que estou na página de créditos
    Quando preencho o valor da recarga com "R$15,00"
    E seleciono a opção de pagamento "PIX"
    E confirmo a solicitação de recarga
    Então um código PIX deve ser gerado
    Quando o pagamento do PIX for confirmado pelo sistema
    Então o meu saldo atual deverá ser atualizado para "R$25,00"
    E devo ver a mensagem "Créditos adicionados com sucesso!"

  Cenário: Adicionar créditos via cartão de crédito
    Dado que estou autenticado como o estudante "Bruno" com saldo de R$10,00
    E que estou na página de créditos
    Quando preencho o valor da recarga com "R$30,00"
    E seleciono a opção de pagamento "Cartão de crédito"
    E preencho os dados válidos do cartão de crédito
    E possuo limite disponível no cartão de crédito
    E confirmo a solicitação de recarga
    Então a transação deve ser aprovada
    E o meu saldo atual deverá ser atualizado para "R$40,00"
    E devo ver a mensagem "Créditos adicionados com sucesso!"

    #triste

  Esquema do Cenário: Recusar recarga com valor inválido
    Dado que estou autenticado como o estudante "Bruno" com saldo de R$10,00
    E que estou na página de créditos
    Quando eu preencho o valor da recarga com "<valor>"
    E confirmo a solicitação de recarga
    Então o sistema deve impedir a operação
    E devo visualizar a mensagem de erro "<mensagem>"

    Exemplos:
      | valor    | mensagem                                              |
      | R$0,00   | Selecione um valor                                    |
      | R$-1,50  | Selecione um valor positivo                           |
      | R$700,00 | O valor final do seu saldo não pode exceder R$500,00 |
      | R$2,4    | Complete as casas decimais                            |

  Esquema do Cenário: Preencher dados inválidos do cartão de crédito
    Dado que estou autenticado como o estudante "Bruno" com saldo de R$10,00
    E que estou na página de créditos
    Quando eu preencho o dado "<dado>" do cartão de crédito com "<valor>"
    E confirmo o cadastro do cartão
    Então o sistema deve impedir a operação
    E devo visualizar a mensagem de erro "<mensagem>"

    Exemplos:
      | dado                | valor         | mensagem                        |
      | nº do cartão        | null          | Insira um número válido.        |
      | CPF do titular      | 126.032.894-7 | Insira um CPF válido.           |
      | Código de segurança | 0             | CVV inválido.                   |
      | validade            | 28/19         | Insira uma data válida (mm/aa). |

  Esquema do Cenário: Recusar cartão com campo obrigatório vazio
    Dado que estou autenticado como o estudante "Bruno" com saldo de R$10,00
    E que estou na página de créditos
    Quando solicito uma recarga de "R$30,00" por cartão de crédito
    E deixo vazio o campo "<campo>" do cartão
    E confirmo a solicitação de recarga
    Então a operação deve ser recusada
    E meu saldo deve permanecer em R$10,00

    Exemplos:
      | campo               |
      | número do cartão    |
      | CPF do titular      |
      | nome no cartão      |
      | data de validade    |
      | código de segurança |

  Cenário: Recusar acesso à recarga sem cadastro
    Dado que não possuo cadastro de estudante
    Quando tento acessar a página de recarga
    Então o acesso deve ser recusado

  Cenário: Recusar acesso à recarga sem autenticação
    Dado que não estou autenticado no sistema
    Quando tento acessar a página de recarga
    Então o acesso deve ser recusado

  Cenário: Recusar recarga de estudante isento do grupo 1
    Dado que sou um estudante do grupo 1, isento do pagamento
    Quando tento acessar a página de recarga
    Então o acesso deve ser recusado
    E nenhuma recarga deve ser criada

  Cenário: Aceitar recarga que atinge exatamente o limite de saldo
    Dado que estou autenticado como o estudante "Bruno" com saldo de R$490,00
    Quando solicito uma recarga de "R$10,00" por cartão de crédito com dados válidos
    E o pagamento é aprovado
    Então meu saldo deve ser atualizado para R$500,00

  Cenário: Cancelar recarga PIX sem confirmação em dez minutos
    Dado que estou autenticado como o estudante "Bruno" com saldo de R$10,00
    Quando solicito uma recarga de "R$15,00" por PIX
    E o código PIX é gerado às 10:00
    E o pagamento não é confirmado até as 10:10
    Então a recarga deve ser cancelada
    E meu saldo deve permanecer em R$10,00
