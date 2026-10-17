# language: pt
# issue 5

Funcionalidade: Configuração de ponto de acesso
  Como administrador do RU
  Quero configurar pontos de acesso ao RU
  Para controlar e organizar a entrada dos usuários nos restaurantes

  Contexto:
    Dado que o Restaurante Universitário n°5 está cadastrado no sistema

    # caminho feliz

  Cenário: Cadastrar ponto de acesso com dados válidos
    Dado que o administrador "Alex" está autenticado e autorizado a configurar pontos de acesso
    E que não existe um ponto de acesso com o número RU05
    Quando preencho a configuração com identificador "RU05", nome "Restaurante Universitário número 5", campus "UnB Darcy Ribeiro" e status "Ativo"
    E solicito o cadastro do ponto de acesso
    Então o ponto de acesso "RU05" deve ser cadastrado

  Cenário: Desativar ponto de acesso existente

    Dado que o administrador "Alex" está autenticado e autorizado a configurar pontos de acesso
    E que existe um ponto de acesso com identificador "RU05" e status "Ativo"
    Quando altero seu status para "Inativo"
    E solicito salvar as alterações
    Então o ponto de acesso "RU05" deve possuir status "Inativo"
    E não deve autorizar novas entradas no RU

    # caminhos tristes

  Esquema do Cenário: Recusar configuração com campo obrigatório vazio

    Dado que o administrador "Alex" está autenticado e autorizado a configurar pontos de acesso
    E que não existe um ponto de acesso com identificador "RU05"
    Quando preencho a configuração com identificador "<identificador>", nome "<nome>", campus "<campus>" e status "<status>"
    E solicito o cadastro do ponto de acesso
    Então a configuração deve ser recusada
    E devo ser informado de que há um campo obrigatório não preenchido
    E nenhum ponto de acesso deve ser criado

    Exemplos:
      |identificador  |          nome                 | campus         |    status   |
      |               | Restaurante Universitário n°5 | Darcy Ribeiro  |   Ativo     |
      | RU05          |                               | Darcy Ribeiro  |   Ativo     |
      | RU05          | Restaurante Universitário n°5 |                |   Ativo     |
      | RU05          | Restaurante Universitário n°5 | Darcy Ribeiro  |             |

  Cenário: Recusar configuração para um campus inválido

    Dado que o administrador "Alex" está autenticado e autorizado a configurar pontos de acesso
    E que não existe campus chamado "FTA (Faculdade de Taguatinga)"
    Quando preencho a configuração com identificador "RU05", nome "Restaurante Universitário n°5", campus "FTA" e status "Ativo"
    E solicito o cadastro do ponto de acesso
    Então a configuração deve ser recusada
    E devo ser informado de que o campus informado não existe
    E nenhum ponto de acesso deve ser criado

  Cenário: Impedir entrada por ponto de acesso inativo

    Dado que existe um ponto de acesso com identificador "RU05" e status "Inativo"
    Quando um estudante tenta acessar o RU utilizando o ponto de acesso "RU05"
    Então o acesso deve ser negado
    E nenhuma entrada deve ser autorizada por esse ponto de acesso

  Cenário: Recusar configuração sem administrador autorizado
    Dado que não estou autenticado como administrador autorizado
    Quando tento cadastrar um ponto de acesso no RU
    Então a configuração deve ser recusada
    E nenhum ponto de acesso deve ser criado

  Cenário: Recusar identificador já cadastrado
    Dado que o administrador "Alex" está autenticado e autorizado a configurar pontos de acesso
    E que existe um ponto de acesso com identificador "RU05"
    Quando preencho a configuração com identificador "RU05", nome "Entrada norte", campus "UnB Darcy Ribeiro" e status "Ativo"
    E solicito o cadastro do ponto de acesso
    Então a configuração deve ser recusada
    E nenhum outro ponto de acesso com identificador "RU05" deve ser criado

  Esquema do Cenário: Recusar status diferente de ativo ou inativo
    Dado que o administrador "Alex" está autenticado e autorizado a configurar pontos de acesso
    Quando preencho a configuração com identificador "RU06", nome "Entrada norte", campus "UnB Darcy Ribeiro" e status "<status>"
    E solicito o cadastro do ponto de acesso
    Então a configuração deve ser recusada
    E nenhum ponto de acesso deve ser criado

    Exemplos:
      | status      |
      | Em manutenção |
      | Pendente    |

  Cenário: Recusar ponto de acesso associado a restaurante inexistente
    Dado que o administrador "Alex" está autenticado e autorizado a configurar pontos de acesso
    E que não existe um restaurante "RU Inexistente" cadastrado
    Quando tento cadastrar o ponto de acesso "RU06" no restaurante "RU Inexistente"
    Então a configuração deve ser recusada
    E nenhum ponto de acesso deve ser criado

  Cenário: Impedir uso do ponto de acesso fora de um RU da UnB
    Dado que o ponto de acesso "RU05" está cadastrado para o "RU Central" da UnB
    Quando tentam usá-lo fora de um Restaurante Universitário da UnB
    Então o acesso deve ser negado
    E nenhuma entrada deve ser autorizada por esse ponto de acesso
