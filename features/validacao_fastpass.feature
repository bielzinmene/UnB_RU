# language: pt
# História de usuário: https://github.com/neatzzy/UnB_RU/issues/16

Funcionalidade: Validação de entrada com FastPass
  Como aplicação de controle
  Quero conferir o resultado do sorteio e a faixa de horário na catraca FastPass
  Para liberar e cobrar apenas o acesso permitido

  Contexto:
    Dado que o almoço de 20/10/2026 ocorre das "11:00" às "14:00"
    E que a faixa FastPass de "Ana" nesse almoço vai das "11:00" às "11:30"
    E que "Ana" foi sorteada para essa faixa
    E que "Bruno" participou do sorteio desse almoço e não foi sorteado
    E que o valor da refeição é de R$ 6,00

  Esquema do Cenário: Liberar estudante sorteada dentro da faixa
    Dado que "Ana" possui saldo de R$ 10,00
    E que "Ana" ainda não acessou o RU no almoço de 20/10/2026
    Quando "Ana" se identifica na catraca FastPass às "<hora>" em 20/10/2026
    Então a catraca FastPass deve ser liberada para "Ana"
    E o saldo de "Ana" deve passar a R$ 4,00
    E deve ser registrado um acesso de "Ana" nesse almoço

    Exemplos:
      | hora  |
      | 11:00 |
      | 11:29 |

  Cenário: Liberar acesso com saldo exatamente igual ao valor da refeição
    Dado que "Ana" possui saldo de R$ 6,00
    E que "Ana" ainda não acessou o RU no almoço de 20/10/2026
    Quando "Ana" se identifica na catraca FastPass às "11:15" em 20/10/2026
    Então a catraca FastPass deve ser liberada para "Ana"
    E o saldo de "Ana" deve passar a R$ 0,00
    E deve ser registrado um acesso de "Ana" nesse almoço

  Cenário: Permitir uma nova entrada em outro turno
    Dado que "Ana" já acessou o RU no almoço de 20/10/2026
    E que o jantar de 20/10/2026 ocorre das "18:00" às "20:00"
    E que "Ana" foi sorteada para a faixa do jantar de 20/10/2026 das "18:00" às "18:30"
    E que "Ana" possui saldo de R$ 10,00 antes do jantar
    E que "Ana" ainda não acessou o RU nesse jantar
    Quando "Ana" se identifica na catraca FastPass às "18:00" em 20/10/2026
    Então a catraca FastPass deve ser liberada para "Ana"
    E o saldo de "Ana" deve passar a R$ 4,00
    E deve ser registrado um acesso de "Ana" nesse jantar
    E o acesso de "Ana" no almoço deve permanecer registrado

  Esquema do Cenário: Recusar acesso fora da faixa sorteada
    Dado que "Ana" possui saldo de R$ 10,00
    E que "Ana" ainda não acessou o RU no almoço de 20/10/2026
    Quando "Ana" se identifica na catraca FastPass às "<hora>" em 20/10/2026
    Então a catraca FastPass deve permanecer bloqueada
    E o saldo de "Ana" deve permanecer em R$ 10,00
    E nenhum acesso de "Ana" deve ser registrado nesse almoço

    Exemplos:
      | hora  |
      | 10:59 |
      | 11:30 |

  Cenário: Recusar acesso FastPass de estudante não sorteado
    Dado que "Bruno" possui saldo de R$ 10,00
    E que "Bruno" ainda não acessou o RU no almoço de 20/10/2026
    Quando "Bruno" se identifica na catraca FastPass às "11:15" em 20/10/2026
    Então a catraca FastPass deve permanecer bloqueada
    E "Bruno" deve ser informado de que não foi sorteado
    E o saldo de "Bruno" deve permanecer em R$ 10,00
    E nenhum acesso de "Bruno" deve ser registrado nesse almoço

  Cenário: Permitir ao não sorteado usar a entrada comum
    Dado que "Bruno" possui saldo de R$ 10,00
    E que "Bruno" ainda não acessou o RU no almoço de 20/10/2026
    Quando "Bruno" se identifica na catraca comum às "11:15" em 20/10/2026
    Então o resultado do sorteio não deve impedir sua entrada comum
    E a catraca comum deve ser liberada conforme as regras normais de acesso
    E o saldo de "Bruno" deve passar a R$ 4,00
    E deve ser registrado um acesso de "Bruno" nesse almoço

  Cenário: Recusar acesso FastPass por saldo insuficiente
    Dado que "Ana" possui saldo de R$ 5,00
    E que "Ana" ainda não acessou o RU no almoço de 20/10/2026
    Quando "Ana" se identifica na catraca FastPass às "11:15" em 20/10/2026
    Então a catraca FastPass deve permanecer bloqueada
    E "Ana" deve ser informada de que o saldo é insuficiente
    E o saldo de "Ana" deve permanecer em R$ 5,00
    E nenhum acesso de "Ana" deve ser registrado nesse almoço

  Esquema do Cenário: Recusar segunda entrada no mesmo almoço em qualquer catraca
    Dado que "Ana" já acessou o RU no almoço de 20/10/2026 pela catraca FastPass
    E que o saldo de "Ana" após esse acesso é de R$ 14,00
    Quando "Ana" tenta entrar novamente pela "<catraca>" às "11:20" em 20/10/2026
    Então a "<catraca>" deve permanecer bloqueada
    E "Ana" deve ser informada de que já acessou o RU nesse almoço
    E o saldo de "Ana" deve permanecer em R$ 14,00
    E deve continuar existindo apenas um acesso de "Ana" nesse almoço

    Exemplos:
      | catraca          |
      | catraca FastPass |
      | catraca comum    |
