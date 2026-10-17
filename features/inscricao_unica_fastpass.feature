# language: pt
# História de usuário: https://github.com/neatzzy/UnB_RU/issues/14

Funcionalidade: Inscrição única no sorteio gratuito do FastPass
  Como estudante
  Quero escolher uma faixa de horário por dia e turno de refeição
  Para tentar conseguir acesso ao RU sem filas

  Contexto:
    Dado que a estudante "Ana" possui a matrícula "241020803" e saldo de R$ 10,00
    E que o estudante "Bruno" possui a matrícula "231010204"
    E que existem as seguintes faixas de horário do FastPass:
      | data       | turno  | início | fim   |
      | 20/10/2026 | Almoço | 11:00  | 11:30 |
      | 20/10/2026 | Almoço | 12:00  | 12:30 |
      | 20/10/2026 | Jantar | 18:00  | 18:30 |
      | 21/10/2026 | Almoço | 11:00  | 11:30 |

  Cenário: Inscrever-me gratuitamente em uma faixa disponível
    Dado que estou autenticada como a estudante "Ana"
    E que não possuo inscrição para o almoço de 20/10/2026
    Quando escolho a faixa das "11:00" às "11:30" para o almoço de 20/10/2026
    E solicito minha inscrição no sorteio do FastPass
    Então minha inscrição deve ser registrada nessa faixa
    E meu saldo deve permanecer em R$ 10,00

  Cenário: Inscrever-me em outro turno no mesmo dia
    Dado que estou autenticada como a estudante "Ana"
    E que já estou inscrita na faixa das "11:00" às "11:30" para o almoço de 20/10/2026
    Quando escolho a faixa das "18:00" às "18:30" para o jantar de 20/10/2026
    E solicito minha inscrição no sorteio do FastPass
    Então minha inscrição para o jantar deve ser registrada
    E minha inscrição para o almoço deve permanecer registrada

  Cenário: Inscrever-me no mesmo turno em outro dia
    Dado que estou autenticada como a estudante "Ana"
    E que já estou inscrita na faixa das "11:00" às "11:30" para o almoço de 20/10/2026
    Quando escolho a faixa das "11:00" às "11:30" para o almoço de 21/10/2026
    E solicito minha inscrição no sorteio do FastPass
    Então minha inscrição para o almoço de 21/10/2026 deve ser registrada
    E minha inscrição para o almoço de 20/10/2026 deve permanecer registrada

  Esquema do Cenário: Recusar segunda inscrição no mesmo dia e turno
    Dado que estou autenticada como a estudante "Ana"
    E que já estou inscrita na faixa das "11:00" às "11:30" para o almoço de 20/10/2026
    Quando escolho a faixa das "<inicio>" às "<fim>" para o almoço de 20/10/2026
    E solicito minha inscrição no sorteio do FastPass
    Então a segunda inscrição deve ser recusada
    E minha inscrição original deve permanecer na faixa das "11:00" às "11:30"
    E não deve existir outra inscrição minha para o almoço de 20/10/2026

    Exemplos:
      | inicio | fim   |
      | 11:00  | 11:30 |
      | 12:00  | 12:30 |

  Cenário: Recusar inscrição em faixa inexistente
    Dado que estou autenticada como a estudante "Ana"
    Quando escolho a faixa das "13:00" às "13:30" para o almoço de 20/10/2026
    E solicito minha inscrição no sorteio do FastPass
    Então a inscrição deve ser recusada porque a faixa não existe
    E nenhuma inscrição minha deve ser criada para o almoço de 20/10/2026

  Cenário: Recusar faixa de outro turno
    Dado que estou autenticada como a estudante "Ana"
    Quando escolho a faixa das "18:00" às "18:30" para o almoço de 20/10/2026
    E solicito minha inscrição no sorteio do FastPass
    Então a inscrição deve ser recusada porque a faixa pertence ao jantar
    E nenhuma inscrição minha deve ser criada para o almoço de 20/10/2026

  Cenário: Recusar inscrição sem autenticação
    Dado que não estou autenticado no sistema
    Quando escolho a faixa das "11:00" às "11:30" para o almoço de 20/10/2026
    E solicito minha inscrição no sorteio do FastPass
    Então a inscrição deve ser recusada
    E devo ser informado de que preciso me autenticar como estudante
    E nenhuma inscrição deve ser criada
