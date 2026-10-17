# language: pt
# issue 4

Funcionalidade: Autenticação de Funcionário
  Como funcionário do restaurante
  Quero fazer login na aplicação de controle
  Para autenticar minha sessão e operar o sistema de forma segura

  Regras:
  - O funcionário do restaurante obrigatoriamente ter sido cadastrado no sistema.
  - O funcionário do restaurante deve informar a sua identificação (matrícula SIAPE ou Usuário SIGAA) e senha cadastrados no sistema.
  - Uma matrícula SIAPE é exclusiva para cada funcionário, ou seja, um funcionário não poderá acessar o sistema com dados de outro empregado.
  - O sistema deverá permitir o acesso somente quando o identificador informado corresponder a um funcionário cadastrado e a senha for válida.
  - Somente após uma autenticação bem-sucedida o funcionário poderá acessar as funcionalidades protegidas do sistema.
  - Estudantes estão proibidos de acessar a Autenticação de Funcionário.
  - O funcionário deverá poder encerrar sua sessão por meio da funcionalidade de logout.
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
