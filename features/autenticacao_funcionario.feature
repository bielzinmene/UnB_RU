# language: pt
# issue 4

Funcionalidade: Autenticação de Funcionário
  Como funcionário do restaurante
  Quero fazer login na aplicação de controle
  Para autenticar minha sessão e operar o sistema de forma segura


  Contexto:
    Dado que a funcionária "Aline" está cadastrada no sistema

    # caminho feliz

  Cenário: Se autenticar para entrar no sistema do RU
    Dado que cadastrei um funcionário com a matrícula SIAPE "241020788"
    Quando preencho os campos com a Matrícula SIAPE "241020788" e a Senha de Acesso "Teste@1234"
    Então o login da conta que pertence a matrícula "241020788" é efetuada com êxito.

  Cenário: Encerrar a sessão do funcionário
    Dado que estou autenticado no sistema do RU
    Quando solicito o encerramento da sessão
    Então minha sessão deve ser encerrada
    E não devo mais acessar funcionalidades protegidas sem realizar novo login

  Cenário: Autenticar com usuário SIGAA cadastrado
    Dado que a funcionária "Aline" possui o usuário SIGAA "aline.ru" e a senha "Teste@1234"
    Quando informo o usuário SIGAA "aline.ru" e a senha "Teste@1234"
    Então a sessão da funcionária "Aline" deve ser autenticada
    E devo poder acessar as funcionalidades protegidas

  Cenário: Impedir acesso a funcionalidades protegidas antes do login
    Dado que não estou autenticado no sistema do RU
    Quando tento acessar uma funcionalidade protegida
    Então o acesso deve ser negado

  Cenário: Recusar identificador de funcionário não cadastrado
    Dado que não existe funcionário com a matrícula SIAPE "9999999"
    Quando informo a matrícula SIAPE "9999999" e a senha "Teste@1234"
    Então o login deve ser recusado
    E não devo acessar funcionalidades protegidas

  Cenário: Recusar acesso com a matrícula de outro funcionário
    Dado que "Aline" está cadastrada com a matrícula SIAPE "241020788" e senha "Teste@1234"
    E que "Bruno" está cadastrado com a matrícula SIAPE "241020789" e senha "Outra@1234"
    Quando informo a matrícula SIAPE "241020788" e a senha "Outra@1234"
    Então o login deve ser recusado
    E não devo acessar a conta de "Aline"
    # caminhos tristes

  Esquema do Cenário: Recusar autenticação com senha inválida
    Dado que há um funcionário cadastrado com a matrícula "<matricula>" e a senha "<senha_cadastrada>"
    Quando preencho os campos com a Matrícula SIAPE "<matricula>" e a Senha de Acesso "<senha_fornecida>"
    Então o login deve ser recusado
    E devo ser informado de que a Matrícula e/ou a Senha de Acesso estão incorretos.

    Exemplos:
      | matricula | senha_cadastrada | senha_fornecida |
      | 241020788 | Teste@1234      | teste1234       |
      | 241020788 | Teste@1234      | TESTE@123       |
      | 241020788 | Teste@1234      | test12345       |

  Cenário: Recusar a autenticação do aluno no sistema
    Quando preencho os campos de login com a matrícula estudantil e com a senha de acesso
    Então o cadastro deve ser recusado
    E devo ser informado que não há nenhuma conta com esses dados registrados no sistema
    E informar que o acesso de autentiação de funcionário para aluno é proibida.

  Esquema do Cenário: Recusar autenticação com campos obrigatórios vazios
    Dado que estou na tela de login do sistema do RU
    Quando preencho a matrícula SIAPE/SIGAA com "<matricula>" e a senha de acesso com "<senha>"
    E solicito a autenticação
    Então o sistema deve impedir o login
    E deve informar que os campos obrigatórios precisam ser preenchidos

    Exemplos:
      | matricula | senha      |
      |           | Teste@1234 |
      | 241020788 |            |
      |           |            |
