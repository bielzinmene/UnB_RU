# language: pt
# História de usuário: https://github.com/neatzzy/UnB_RU/issues/15

Funcionalidade: Notificação do resultado do sorteio do FastPass
  Como estudante
  Quero saber se ganhei ou não o FastPass uma hora antes do turno
  Para planejar meu horário de ida ao RU

  Contexto:
    Dado que o almoço de 20/10/2026 começa às "11:00"
    E que a estudante "Ana" está inscrita na faixa das "11:00" às "11:30" desse almoço
    E que o estudante "Bruno" está inscrito na faixa das "12:00" às "12:30" desse almoço
    E que a estudante "Carla" não está inscrita nesse almoço

  Cenário: Notificar a estudante sorteada uma hora antes do turno
    Dado que o sorteio do almoço de 20/10/2026 selecionou a estudante "Ana"
    Quando chega 20/10/2026 às "10:00"
    E o sistema processa as notificações do sorteio
    Então "Ana" deve receber uma notificação no sistema informando que ganhou o FastPass
    E a notificação deve indicar o almoço de 20/10/2026 e a faixa das "11:00" às "11:30"
    E "Ana" deve ter exatamente uma notificação desse resultado

  Cenário: Notificar o estudante não sorteado uma hora antes do turno
    Dado que o sorteio do almoço de 20/10/2026 não selecionou o estudante "Bruno"
    Quando chega 20/10/2026 às "10:00"
    E o sistema processa as notificações do sorteio
    Então "Bruno" deve receber uma notificação no sistema informando que não ganhou o FastPass
    E a notificação deve indicar o almoço de 20/10/2026
    E "Bruno" deve ter exatamente uma notificação desse resultado

  Cenário: Notificar no horário correspondente a outro turno
    Dado que o jantar de 20/10/2026 começa às "18:00"
    E que o estudante "Daniel" está inscrito na faixa das "18:00" às "18:15" desse jantar
    E que o sorteio do jantar de 20/10/2026 selecionou "Daniel"
    Quando chega 20/10/2026 às "17:00"
    E o sistema processa as notificações do sorteio
    Então "Daniel" deve receber uma notificação no sistema informando que ganhou o FastPass
    E a notificação deve indicar o jantar de 20/10/2026 e a faixa das "18:00" às "18:15"
    E "Daniel" deve ter exatamente uma notificação desse resultado

  Cenário: Não notificar antes de uma hora do turno
    Dado que o sorteio do almoço de 20/10/2026 selecionou a estudante "Ana"
    Quando chega 20/10/2026 às "09:59"
    E o sistema processa as notificações do sorteio
    Então "Ana" não deve receber a notificação do resultado desse almoço

  Cenário: Não duplicar notificação de uma inscrição
    Dado que o sorteio do almoço de 20/10/2026 selecionou a estudante "Ana"
    E que "Ana" já recebeu a notificação desse resultado às "10:00"
    Quando o sistema tenta enviar novamente os resultados do mesmo sorteio
    Então "Ana" deve continuar com exatamente uma notificação desse resultado

  Cenário: Não notificar quem não se inscreveu no sorteio
    Dado que o sorteio do almoço de 20/10/2026 foi concluído
    Quando chega 20/10/2026 às "10:00"
    E o sistema processa as notificações do sorteio
    Então "Carla" não deve receber notificação desse sorteio
