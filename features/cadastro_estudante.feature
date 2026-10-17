# language: pt
# História de usuário: https://github.com/neatzzy/UnB_RU/issues/1

Funcionalidade: Cadastro de estudante
  Como estudante
  Quero me cadastrar usando minha matrícula
  Para criar minha conta de acesso ao RU

  Contexto:
    Dado que a data atual é 15/10/2026

  Cenário: Criar conta com dados válidos
    Dado que não existe conta com a matrícula "241020803"
    Quando preencho o cadastro com nome "Joaquim Silva", matrícula "241020803", senha "12345Aa@" e confirmação "12345Aa@"
    E solicito a criação da conta
    Então a conta do estudante "Joaquim Silva" deve ser criada com a matrícula "241020803"

  Esquema do Cenário: Recusar cadastro com campo obrigatório vazio
    Dado que não existe conta com a matrícula "241020803"
    Quando preencho o cadastro com nome "<nome>", matrícula "<matricula>", senha "<senha>" e confirmação "<confirmacao>"
    E solicito a criação da conta
    Então o cadastro deve ser recusado
    E devo ser informado de que o campo "<campo>" é obrigatório
    E nenhuma conta deve ser criada

    Exemplos:
      | campo                | nome     | matricula | senha     | confirmacao |
      | nome completo        |          | 241020803 | 12345Aa@  | 12345Aa@    |
      | matrícula            | Ana Braz |           | 12345Aa@  | 12345Aa@    |
      | senha                | Ana Braz | 241020803 |           | 12345Aa@    |
      | confirmação de senha | Ana Braz | 241020803 | 12345Aa@  |             |

  Esquema do Cenário: Recusar matrícula estudantil inválida
    Dado que não existe conta com a matrícula "<matricula>"
    Quando preencho o cadastro com nome "Ana Silva", matrícula "<matricula>", senha "12345Aa@" e confirmação "12345Aa@"
    E solicito a criação da conta
    Então o cadastro deve ser recusado
    E devo ser informado de que a matrícula "<motivo>"
    E nenhuma conta deve ser criada

    Exemplos:
      | matricula | motivo                                  |
      | 24102080  | deve ter exatamente 9 dígitos          |
      | 24102080A | deve conter apenas dígitos numéricos   |
      | 243020803 | deve indicar o semestre 1 ou 2         |
      | 281020803 | não pode indicar um ano futuro         |

  Esquema do Cenário: Recusar senha que não atende aos requisitos
    Dado que não existe conta com a matrícula "241020803"
    Quando preencho o cadastro com nome "Ana Braz", matrícula "241020803", senha "<senha>" e confirmação "<senha>"
    E solicito a criação da conta
    Então o cadastro deve ser recusado
    E devo ser informado de que a senha "<motivo>"
    E nenhuma conta deve ser criada

    Exemplos:
      | senha     | motivo                               |
      | Ab@123    | deve ter pelo menos 8 caracteres     |
      | senha@123 | deve conter uma letra maiúscula      |
      | SENHA@123 | deve conter uma letra minúscula      |
      | Senha@abc | deve conter um dígito numérico       |
      | Senha123  | deve conter um caractere especial    |

  Cenário: Recusar confirmação de senha diferente
    Dado que não existe conta com a matrícula "241020803"
    Quando preencho o cadastro com nome "Ana Braz", matrícula "241020803", senha "Umas@123" e confirmação "Duas@123"
    E solicito a criação da conta
    Então o cadastro deve ser recusado
    E devo ser informado de que a confirmação de senha é diferente
    E nenhuma conta deve ser criada

  Cenário: Recusar matrícula já cadastrada
    Dado que já existe uma conta com a matrícula "241020803"
    Quando preencho o cadastro com nome "Ana Braz", matrícula "241020803", senha "Certa@123" e confirmação "Certa@123"
    E solicito a criação da conta
    Então o cadastro deve ser recusado
    E devo ver a mensagem "Matricula já existente"
    E nenhuma outra conta deve ser criada com a matrícula "241020803"
