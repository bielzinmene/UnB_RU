# language: pt
# História de usuário: https://github.com/neatzzy/UnB_RU/issues/9

Funcionalidade: Relatório global de acessos
  Como administrador
  Quero visualizar o histórico completo de acessos do campus
  Para acompanhar os acessos por restaurante e por catraca

  Contexto:
    Dado que estou autenticado como administrador
    E que existem os seguintes acessos realizados:
      | data e hora      | matrícula | restaurante    | catraca   |
      | 15/10/2026 08:00 | 241020803 | RU Central     | Catraca 1 |
      | 15/10/2026 11:05 | 241020803 | RU Central     | Catraca 1 |
      | 15/10/2026 11:10 | 221020305 | RU Central     | Catraca 2 |
      | 14/10/2026 12:00 | 241010406 | RU Planaltina  | Catraca 3 |

  Cenário: Visualizar o histórico completo de acessos
    Quando consulto o relatório global de acessos sem aplicar filtros
    Então o relatório deve apresentar exatamente os seguintes acessos:
      | data e hora      | matrícula | restaurante   | catraca   |
      | 15/10/2026 08:00 | 241020803 | RU Central    | Catraca 1 |
      | 15/10/2026 11:05 | 241020803 | RU Central    | Catraca 1 |
      | 15/10/2026 11:10 | 221020305 | RU Central    | Catraca 2 |
      | 14/10/2026 12:00 | 241010406 | RU Planaltina | Catraca 3 |

  Cenário: Filtrar os acessos por restaurante
    Quando filtro o relatório pelo restaurante "RU Central"
    Então devo ver somente os acessos de "15/10/2026 08:00", "15/10/2026 11:05" e "15/10/2026 11:10"
    E não devo ver o acesso de "14/10/2026 12:00"

  Cenário: Filtrar os acessos por catraca específica
    Quando filtro o relatório pela catraca "Catraca 1" do restaurante "RU Central"
    Então devo ver somente os acessos de "15/10/2026 08:00" e "15/10/2026 11:05"
    E não devo ver os acessos das outras catracas

  Cenário: Agrupar os acessos por restaurante
    Quando agrupo o relatório por restaurante
    Então devo ver o grupo "RU Central" com os acessos de "15/10/2026 08:00", "15/10/2026 11:05" e "15/10/2026 11:10"
    E devo ver o grupo "RU Planaltina" com o acesso de "14/10/2026 12:00"

  Cenário: Agrupar os acessos por catraca
    Quando agrupo o relatório por catraca
    Então devo ver o grupo "Catraca 1" do restaurante "RU Central" com os acessos de "15/10/2026 08:00" e "15/10/2026 11:05"
    E devo ver o grupo "Catraca 2" do restaurante "RU Central" com o acesso de "15/10/2026 11:10"
    E devo ver o grupo "Catraca 3" do restaurante "RU Planaltina" com o acesso de "14/10/2026 12:00"

  Cenário: Consultar uma catraca sem acessos realizados
    Dado que existe a catraca "Catraca 4" no restaurante "RU Central" e ela não possui acessos realizados
    Quando filtro o relatório pela catraca "Catraca 4" do restaurante "RU Central"
    Então não devo ver nenhum acesso
    E devo ver a mensagem "Nenhum acesso até então"
