# language: pt
# História de usuário: https://github.com/neatzzy/UnB_RU/issues/17

Funcionalidade: Gestão de turnos e faixas de horário do FastPass
  Como administrador
  Quero definir os horários dos turnos e dividi-los em faixas configuráveis
  Para organizar a distribuição do FastPass

  Contexto:
    Dado que a data atual é 16/10/2026

  Cenário: Definir um turno e suas faixas de horário
    Dado que estou autenticado como administrador
    E que não existe configuração de "Almoço" para 20/10/2026
    Quando defino o turno "Almoço" de 20/10/2026 das "11:00" às "14:00"
    E configuro as seguintes faixas para esse turno:
      | início | fim   |
      | 11:00  | 11:30 |
      | 11:30  | 12:00 |
      | 12:00  | 12:30 |
    Então o turno "Almoço" de 20/10/2026 deve funcionar das "11:00" às "14:00"
    E deve oferecer exatamente as faixas configuradas

  Cenário: Permitir intervalos sem FastPass dentro do turno
    Dado que estou autenticado como administrador
    E que o turno "Almoço" de 20/10/2026 funciona das "11:00" às "14:00"
    Quando configuro a faixa das "11:00" às "11:30"
    E configuro a faixa das "12:00" às "12:30"
    Então as duas faixas devem ser aceitas para o turno "Almoço" de 20/10/2026
    E o intervalo das "11:30" às "12:00" deve permanecer sem FastPass

  Cenário: Configurar outro turno com faixas de durações diferentes
    Dado que estou autenticado como administrador
    E que o turno "Almoço" de 20/10/2026 já possui a faixa das "11:00" às "11:30"
    Quando defino o turno "Jantar" de 20/10/2026 das "18:00" às "20:00"
    E configuro as seguintes faixas para esse turno:
      | início | fim   |
      | 18:00  | 18:15 |
      | 18:15  | 19:00 |
    Então o turno "Jantar" de 20/10/2026 deve oferecer exatamente essas duas faixas
    E a faixa do turno "Almoço" deve permanecer cadastrada

  Cenário: Recusar faixas sobrepostas no mesmo turno
    Dado que estou autenticado como administrador
    E que o turno "Almoço" de 20/10/2026 funciona das "11:00" às "14:00"
    E que já existe a faixa das "11:00" às "11:30" nesse turno
    Quando tento configurar outra faixa das "11:15" às "11:45" nesse turno
    Então a nova faixa deve ser recusada por sobreposição
    E a faixa das "11:00" às "11:30" deve permanecer cadastrada

  Esquema do Cenário: Recusar faixa fora do horário do turno
    Dado que estou autenticado como administrador
    E que o turno "Almoço" de 20/10/2026 funciona das "11:00" às "14:00"
    Quando tento configurar uma faixa das "<inicio>" às "<fim>" nesse turno
    Então a nova faixa deve ser recusada por estar fora do horário do turno
    E nenhuma faixa das "<inicio>" às "<fim>" deve ser cadastrada

    Exemplos:
      | inicio | fim   |
      | 10:45  | 11:15 |
      | 13:45  | 14:15 |

  Esquema do Cenário: Recusar faixa sem duração positiva
    Dado que estou autenticado como administrador
    E que o turno "Almoço" de 20/10/2026 funciona das "11:00" às "14:00"
    Quando tento configurar uma faixa das "<inicio>" às "<fim>" nesse turno
    Então a nova faixa deve ser recusada por ter horário inválido
    E nenhuma faixa das "<inicio>" às "<fim>" deve ser cadastrada

    Exemplos:
      | inicio | fim   |
      | 12:00  | 12:00 |
      | 12:30  | 12:00 |

  Esquema do Cenário: Recusar turno sem duração positiva
    Dado que estou autenticado como administrador
    E que não existe configuração de "Almoço" para 20/10/2026
    Quando tento definir o turno "Almoço" de 20/10/2026 das "<inicio>" às "<fim>"
    Então o turno deve ser recusado por ter horário inválido
    E o turno "Almoço" de 20/10/2026 não deve ser criado

    Exemplos:
      | inicio | fim   |
      | 12:00  | 12:00 |
      | 14:00  | 11:00 |

  Cenário: Recusar configuração por quem não é administrador
    Dado que estou autenticado como estudante
    Quando tento definir o turno "Almoço" de 20/10/2026 das "11:00" às "14:00"
    Então a configuração deve ser recusada
    E o turno "Almoço" de 20/10/2026 não deve ser criado
