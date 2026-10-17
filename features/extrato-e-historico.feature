# language: pt
# issue 3

Funcionalidade: Visualizar extrato de recargas e histórico de refeições
  Como estudante
  Quero visualizar meu extrato de recargas e histórico de refeições
  Para ter controle sobre meus gastos

  Contexto:
    Dado que o estudante "Cleiton" possui a matrícula "251024222"

  Cenário: Visualizar meus registros completos em ordem da mais recente para a mais antiga
    Dado que estou autenticado como o estudante "Cleiton"
    E que possuo as seguintes recargas:
      | data e hora      | valor    |
      | 15/10/2026 09:00 | R$ 50,00 |
      | 14/10/2026 09:00 | R$ 20,00 |
    E que possuo as seguintes refeições:
      | data e hora      | restaurante | valor debitado |
      | 15/10/2026 12:00 | RU Central  | R$ 2,50        |
      | 14/10/2026 12:00 | RU Central  | R$ 2,50        |
    Quando acesso a tela de extrato e histórico de consumo
    Então o extrato deve apresentar exatamente estas recargas, nesta ordem:
      | data e hora      | valor    |
      | 15/10/2026 09:00 | R$ 50,00 |
      | 14/10/2026 09:00 | R$ 20,00 |
    E o histórico deve apresentar exatamente estas refeições, nesta ordem:
      | data e hora      | restaurante | valor debitado |
      | 15/10/2026 12:00 | RU Central  | R$ 2,50        |
      | 14/10/2026 12:00 | RU Central  | R$ 2,50        |

  Cenário: Informar ausência de recargas e refeições
    Dado que estou autenticado como o estudante "Cleiton"
    E que não possuo recargas nem refeições registradas
    Quando acesso a tela de extrato e histórico de consumo
    Então o extrato deve apresentar "Nenhuma recarga encontrada"
    E o histórico deve apresentar "Nenhum histórico de refeições encontrado"

  Cenário: Recusar consulta sem autenticação
    Dado que não estou autenticado no sistema
    Quando tento acessar a tela de extrato e histórico de consumo
    Então o acesso deve ser recusado
    E nenhum dado de recargas ou refeições deve ser exibido
