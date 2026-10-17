# language: pt
# issue 6

Funcionalidade: Controle de acesso à catraca do RU
  Como aplicação de controle
  Quero ler a identificação do estudante, verificar se há saldo, enviar o comando de liberação para a catraca e efetuar o débito da refeição no momento da passagem
  Para garantir que apenas estudantes com saldo positivo acessem o restaurante e tenham o valor descontado corretamente

  Regras:
  - O sistema deve ler a identificação do estudante.
  - O estudante deve estar cadastrado.
  - O saldo atual da conta do estudante deve ser maior ou igual ao valor da refeição.
  - Se o saldo for suficiente, o sistema envia o comando elétrico de liberação para a catraca.
  - Imediatamente após a liberação o valor correspondente deve ser subtraído do saldo do estudante.
  - Se o saldo for insuficiente ou a conta não for encontrada, a catraca deve permanecer bloqueada e uma mensagem de erro apropriada deve aparecer.

  Contexto:
    Dado que o valor da refeição do RU é de R$ 2,50

    # caminho feliz

  Cenário: Liberar catraca com saldo suficiente
    Dado que o estudante "Cleiton" possui a matrícula "251024222" e um saldo de R$ 15,00
    Quando o sistema lê a identificação da matrícula "251024222"
    E o sistema verifica que o saldo é suficiente
    Então o sistema envia o comando de liberação para a catraca
    E o saldo da conta do estudante "Cleiton" deve ser atualizado para R$ 12,50
    E a catraca deve ser liberada

    # caminhos tristes

  Cenário: Recusar acesso por saldo insuficiente
    Dado que o estudante "Cleiton" possui a matrícula "251024222" e um saldo de R$ 2,00
    Quando o sistema lê a identificação da matrícula "251024222"
    E o sistema verifica que o saldo é insuficiente
    Então a catraca deve permanecer bloqueada
    E o sistema deve exibir a mensagem "Saldo insuficiente"
    E nenhum valor deve ser debitado da conta

  Cenário: Recusar acesso de estudante não cadastrado
    Dado que não existe conta cadastrada com a matrícula "251024222"
    Quando o sistema lê a identificação da matrícula "251024222"
    Então a catraca deve permanecer bloqueada
    E o sistema deve exibir a mensagem "Matrícula não encontrada"