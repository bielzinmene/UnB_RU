# language: pt
# issue 4

Funcionalidade: Autenticação de Funcionário
  Como funcionário do restaurante
  Quero fazer login na aplicação de controle
  Para autenticar minha sessão e operar o sistema de forma segura

  Regras:
  - O funcionário do restaurante obrigatoriamente ter sido cadastrado no sistema.
  - O funcionário do restaurante deve informar a sua matrícula SIAPE ou Usuário SIGAA e senha cadastrados no sistema.
  - A senha contém pelo menos 8 caracteres, incluindo ao menos um número,
  uma letra maiúscula, uma letra minúscula e um caractere especial.
  - O funcionário do restaurante
  - Uma matrícula SIAPE é exclusiva para cada funcionário, ou seja, um funcionário não poderá acessar o sistema com dados de outro empregado.
  Contexto:
    Dado que a data atual é 15/10/2026

    # caminho felis

  Cenário: Se autenticar para entrar no sistema do RU
    Dado que cadastrei um funcionário com a matrícula SIAPE "241020788"
    Quando preencho os campos com a Matrícula SIAPE "241020788" e a Senha de Acesso "Teste@1234"
    Então o login da conta que pertence a matrícula "241020788" é efetuada com êxito.

    # caminhos tristes

  Esquema do Cenário: Recusar autenticação com senha inválida
    Dado que há cadastro com a matrícula "241020788"
    Quando preencho os campos com a Matrícula SIAPE "241020788" e a Senha de Acesso "Teste1234"
    Então o login deve ser recusado
    E devo ser informado de que a Matrícula e/ou a Senha de Acesso estão incorretos.

    Exemplos:
    | matricula | senha  cadastrada   | senha fornecida  |
    | 241020788 | Teste@1234          |   teste1234      |
    | 241020788 | Teste@1234          |   TESTE@123      |
    | 241020788 | Teste@1234          |   test12345      |

  Esquema do Cenário: Recusar a autenticação do aluno no sistema
    Quando preencho os campos de login com a matrícula estudantil e com a senha de acesso
    Então o cadastro deve ser recusado
    E devo ser informado que não há nenhuma conta com esses dados registrados no sistema
    E informar que o acesso de autentiação de funcionário para aluno é proibida.
