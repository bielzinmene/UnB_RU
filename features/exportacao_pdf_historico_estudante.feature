# language: pt
# História de usuário: https://github.com/neatzzy/UnB_RU/issues/11

Funcionalidade: Exportação em PDF do extrato e histórico do estudante
  Como estudante
  Quero exportar meu extrato de recargas e histórico de refeições em PDF
  Para controlar melhor minhas finanças

  Contexto:
    Dado que a estudante "Ana" possui a matrícula "241020803"
    E que o estudante "Bruno" possui a matrícula "231010204"
    E que existem as seguintes recargas:
      | matrícula | data e hora      | valor    |
      | 241020803 | 15/10/2026 09:00 | R$ 50,00 |
      | 241020803 | 14/10/2026 10:00 | R$ 20,00 |
      | 231010204 | 15/10/2026 09:30 | R$ 30,00 |
    E que existem as seguintes refeições:
      | matrícula | data e hora      | restaurante | valor debitado |
      | 241020803 | 15/10/2026 12:00 | RU Central  | R$ 6,00        |
      | 241020803 | 14/10/2026 12:30 | RU Central  | R$ 6,00        |
      | 231010204 | 15/10/2026 12:15 | RU Central  | R$ 6,00        |

  Cenário: Exportar meu extrato e histórico de refeições
    Dado que estou autenticada como a estudante "Ana"
    Quando solicito a exportação em PDF do meu extrato e histórico de refeições
    Então o PDF deve ser gerado
    E a seção de recargas deve apresentar exatamente:
      | data e hora      | valor    |
      | 15/10/2026 09:00 | R$ 50,00 |
      | 14/10/2026 10:00 | R$ 20,00 |
    E a seção de refeições deve apresentar exatamente:
      | data e hora      | restaurante | valor debitado |
      | 15/10/2026 12:00 | RU Central  | R$ 6,00        |
      | 14/10/2026 12:30 | RU Central  | R$ 6,00        |
    E o PDF não deve conter recargas ou refeições do estudante "Bruno"

  Cenário: Exportar somente os dados do estudante autenticado
    Dado que estou autenticado como o estudante "Bruno"
    Quando solicito a exportação em PDF do meu extrato e histórico de refeições
    Então o PDF deve ser gerado
    E a seção de recargas deve apresentar exatamente:
      | data e hora      | valor    |
      | 15/10/2026 09:30 | R$ 30,00 |
    E a seção de refeições deve apresentar exatamente:
      | data e hora      | restaurante | valor debitado |
      | 15/10/2026 12:15 | RU Central  | R$ 6,00        |
    E o PDF não deve conter recargas ou refeições da estudante "Ana"

  Cenário: Exportar quando tenho somente recargas
    Dado que a estudante "Daniela" possui a matrícula "251020306"
    E que estou autenticada como a estudante "Daniela"
    E que possuo uma recarga em "15/10/2026 09:45" no valor de "R$ 40,00"
    E que não possuo refeições registradas
    Quando solicito a exportação em PDF do meu extrato e histórico de refeições
    Então o PDF deve ser gerado
    E a seção de recargas deve apresentar a recarga de "15/10/2026 09:45" no valor de "R$ 40,00"
    E a seção de refeições deve apresentar "Nenhum histórico de refeições encontrado"
    E o PDF não deve conter dados de outros estudantes

  Cenário: Exportar quando tenho somente refeições
    Dado que o estudante "Eduardo" possui a matrícula "251020307"
    E que estou autenticado como o estudante "Eduardo"
    E que não possuo recargas registradas
    E que possuo uma refeição em "15/10/2026 12:30" no "RU Central" com débito de "R$ 6,00"
    Quando solicito a exportação em PDF do meu extrato e histórico de refeições
    Então o PDF deve ser gerado
    E a seção de recargas deve apresentar "Nenhuma recarga encontrada"
    E a seção de refeições deve apresentar a refeição de "15/10/2026 12:30" no "RU Central" com débito de "R$ 6,00"
    E o PDF não deve conter dados de outros estudantes

  Cenário: Recusar exportação quando não tenho recargas nem refeições
    Dado que a estudante "Carla" possui a matrícula "251020305"
    E que estou autenticada como a estudante "Carla"
    E que não possuo recargas nem refeições registradas
    Quando solicito a exportação em PDF do meu extrato e histórico de refeições
    Então a exportação deve ser recusada
    E devo ser informada de que não há recargas nem refeições para exportar
    E nenhum PDF deve ser gerado

  Cenário: Recusar exportação sem autenticação
    Dado que não estou autenticado no sistema
    Quando solicito a exportação em PDF de extrato e histórico de refeições
    Então a exportação deve ser recusada
    E devo ser informado de que preciso me autenticar
    E nenhum PDF deve ser gerado

  Cenário: Recusar exportação de dados de outro estudante
    Dado que estou autenticada como a estudante "Ana"
    Quando solicito a exportação em PDF do extrato e histórico da matrícula "231010204"
    Então a exportação deve ser recusada
    E devo ser informada de que não posso exportar dados de outro estudante
    E nenhum PDF deve ser gerado
