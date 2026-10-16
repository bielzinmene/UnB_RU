# language: pt
# issue 2

Funcionalidade: Recarga de saldo
  Como estudante
  Eu quero adicionar créditos a minha conta via PIX ou cartão de crédito
  Para que eu tenha saldo suficiente para acessar os restaurantes Universitários 

  Regras:
  - Todos os campos do formulário de dados do cartão são obrigatórios:
  número do cartão, CPF do titular, nome marcado no cartão, data de validade e
  código de segurança.
  - O valor selecionado deve ser valido, ou seja, um número positivo com duas casas decimais.
  - O estudante deve ser cadastrado e deve estar logado para acessar a
  página de recarga de créditos.
  - Estudantes do grupo 1 não podem acessar a página, pois são isentos
  do pagamento devido a vulnerabilidade socioeconômica.
  - Caso o valor de recarga somado ao saldo atual do estudante seja maior que R$500,
  a operação se torna inválida.
  - Caso o pagamento do código PIX não seja confirmado em até 10 minutos após o código
  ser gerado, a operação será cancelada.

  Contexto:
    Dado que estou autenticado como o estudante "Bruno"
    E meu saldo atual é de R$10,00
    E eu estou na página de créditos

    #feliz

  Cenário: Adicionar créditos via PIX
    Quando preencho o valor da recarga com "R$15,00"
    E seleciono a opção de pagamento "PIX"
    E confirmo a solicitação de recarga
    Então um código PIX deve ser gerado
    Quando o pagamento do PIX for confirmado pelo sistema
    Então o meu saldo atual deverá ser atualizado para "R$25,00"
    E devo ver a mensagem "Créditos adicionados com sucesso!"

  Cenário: Adicionar créditos via cartão de crédito
    Quando preencho o valor da recarga com "R$30,00"
    E seleciono a opção de pagamento "Cartão de crédito"
    E preencho os dados válidos do cartão de crédito
    E possuo limite disponível no cartão de crédito
    E confirmo a solicitação de recarga
    Então a transação deve ser aprovada
    E o meu saldo atual deverá ser atualizado para "R$40,00"
    E devo ver a mensagem "Créditos adicionados com sucesso!"

    #triste

  Esquema de Cenário: tentar recarregar com valor inválido
    Quando eu preencho o valor da recarga com "<valor>"
    E confirmo a solicitação de recarga
    Então o sistema deve impedir a operação
    E devo visualizar a mensagem de erro "<mensagem>"

    Exemplos:
      | valor   | mensagem                                               | 
      | R$0,00  | "Selecione um valor"                                   |
      | R$-1,50 | "Selecione um valor positivo"                          |
      | R$700,00| "O valor final do seu saldo não pode exceder R$500,00" |
      | R$2,4   | "Complete as casas decimais"                           |

  Esquema do Cenário: Preencher dados inválidos do cartão de crédito
    Quando eu preencho um <dado> do cartão de crédito
    Com um determinado <valor>
    E confirmo o cadastro do cartão
    Então o sistema deve impedir a operação
    E devo visualizar a mensagem de erro "<mensagem>"

    Exemplos:
      |         dado         |  valor        |  mensagem
      | nº do cartão         | null          | "Insira um número válido."        |
      | CPF do titular       | 126.032.894-7 | "Insira um CPF válido."           |
      | Código de segurança  | 0             | "CVV inválido."                   |
      | validade             | 28/19         | "Insira uma data válida (mm/aa)." |
