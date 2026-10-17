# language: pt
# issue 5

Funcionalidade: Configuração de ponto de acesso
  Como administrador do RU
  Quero configurar pontos de acesso ao RU
  Para controlar e organizar a entrada dos usuários nos restaurantes

  Regras:
  - Apenas adminstradores autenticados e autorizados podem configurar pontos de acesso.
  - Todos os campos são obrigatórios: identificador, nome, campus e status.
  - Não é permitido cadastrar dois pontos de acesso com o mesmo identificador
  - O status do ponto de acesso deve ser "ativo" ou "inativo"
  - O ponto de acesso só pode ser usado dentro do Restaurante Universitário da UnB
  - Um ponto de acesso com status "inativo" não pode autorizar entradas no RU.
  - Não é permitido configurar pontos de acesso associados a restaurantes inexistentes.


  Contexto:
    Dado que tem o Restaurante Universitário n°5 cadastrada no sistema
    E que o administrador "Alex" está autenticado
    E possui permissão para configurar pontos de acesso

    # caminho feliz

  Cenário: Cadastrar ponto de acesso com dados válidos
    Dado que não existe um ponto de acesso com o número RU05
    Quando preencho a configuração com identificador "RU05", nome "Restaurante Universitário número 5", campus "UnB Darcy Ribeiro" e status "Ativo"
    E solicito o cadastro do ponto de acesso
    Então o ponto de acesso "RU05" deve ser cadastrado

  Cenário: Desativar ponto de acesso existente

    Dado que existe um ponto de acesso com identificador "RU05" e status "Ativo"
    Quando altero seu status para "Inativo"
    E solicito salvar as alterações
    Então o ponto de acesso "RU05" deve possuir status "Inativo"
    E não deve autorizar novas entradas no RU

    # caminhos tristes

  Esquema do Cenário: Recusar configuração com campo obrigatório vazio

    Dado que não existe um ponto de acesso com identificador "RU05"
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

    Dado que não campus chamado "FTA (Faculdade de Taguatinga)"
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
