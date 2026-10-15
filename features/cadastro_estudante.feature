# language: pt
# issue 1

Funcionalidade: Cadastro de estudante
  Como estudante
  Quero me cadastrar usando minha matrícula
  Para criar minha conta de acesso ao RU

  Regras:
  - Todos os campos do formulário são obrigatórios: nome completo, matrícula,
  senha e confirmação de senha.
  - A matrícula do estudante contém exatamente 9 dígitos numéricos. Os dois
  primeiros indicam o ano de ingresso como 24 que deriva de 20'24', que não pode ser futuro
  comparado ao ano atual, como 20'27' estando em 20'26'.
  O terceiro dígito indica o semestre de ingresso e deve ser 1 ou 2.
  - Uma matrícula que respeita esse formato é considerada válida a um
  estudante.
  - A senha contém pelo menos 8 caracteres, incluindo ao menos um número,
  uma letra maiúscula, uma letra minúscula e um caractere especial.
  - A confirmação de senha deve ser igual à senha.
  - Uma matrícula já cadastrada não pode ser usada para criar outra conta.
  - O cadastro de servidores por SIAPE fica fora do escopo desta funcionalidade por enquanto.

  Contexto:
    Dado que a data atual é 15/10/2026

    # caminho felis

  Cenário: Criar conta com dados válidos
    Dado que não existe conta com a matrícula "241020803"
    Quando preencho o cadastro com nome "Joaquim Silva", matrícula "241020803", senha "12345Aa@" e confirmação "12345Aa@"
    E solicito a criação da conta
    Então a conta do estudante "Joaquim Silva" deve ser criada com a matrícula "241020803"

    # caminhos tristes

  Esquema do Cenário: Recusar cadastro com campo obrigatório vazio
    Dado que não existe conta com a matrícula "241020803"
    Quando preencho o cadastro com nome "<nome>", matrícula "<matricula>", senha "<senha>" e confirmação "<confirmacao>"
    E solicito a criação da conta
    Então o cadastro deve ser recusado
    E devo ser informado de que há um campo obrigatório não preenchido
    E nenhuma conta deve ser criada

    Exemplos:
      | nome       | matricula | senha     | confirmacao |
      |            | 241020803 | 12345Aa@  |   12345Aa@  |
      | Ana Braz   |           | 12345Aa@  |   12345Aa@  |
      | Ana Braz   | 241020803 |           |   123456Aa@ |
      | Ana Braz   | 241020803 | Senha123# |             |

  Esquema do Cenário: Recusar matrícula estudantil inválida
    Quando preencho o cadastro com nome "Ana Silva", matrícula "<matricula>", senha "12345Aa@" e confirmação "12345Aa@"
    E solicito a criação da conta
    Então o cadastro deve ser recusado
    E devo ser informad que a matrícula é inválida
    E nenhuma conta deve ser criada

    Exemplos:
      | matricula |
      | 24102080  |
      | 24102080A |
      | 243020803 |
      | 281020803 |

  Esquema do Cenário: Recusar senha que não atende aos requisitos
    Dado que não existe conta com a matrícula "241020803"
    Quando preencho o cadastro com nome "Ana Braz", matrícula "241020803", senha "<senha>" e confirmação "<senha>"
    E solicito a criação da conta
    Então o cadastro deve ser recusado
    E devo ser informado de que a senha não atende aos requisitos
    E nenhuma conta deve ser criada

    Exemplos:
      | senha     |
      | Ab@123    |
      | 123456a@  |
      | 12345678  |
      | 123456A@  |
      | minhasenha|
      | !@#$%¨&*  |
      | 1234567@  |

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
