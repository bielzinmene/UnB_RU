# language: pt
# issue 12

Funcionalidade: Exportação em PDF do relatório de operação
  Como administrador geral do RU
  Quero exportar o relatório global de operação em PDF
  Para consultar a operação do período filtrado

    # caminho feliz

  Cenário: Exportar o PDF do período filtrado
    Dado que estou autenticado como administrador geral
    E que há operação em 24/10/2025 no Campus Darcy Ribeiro
    Quando filtro o relatório por data "24/10/2025", turno "Todos" e campus "Campus Darcy Ribeiro"
    E solicito a exportação do PDF
    Então o PDF deve ser gerado para 24/10/2025, todos os turnos e o Campus Darcy Ribeiro

  Esquema do Cenário: Exportar o PDF de um único turno
    Dado que estou autenticado como administrador geral
    E que há operação em 24/10/2025 no Campus Darcy Ribeiro
    Quando filtro o relatório por data "24/10/2025", turno "<turno>" e campus "Campus Darcy Ribeiro"
    E solicito a exportação do PDF
    Então o PDF deve conter apenas o turno "<turno>" de "24/10/2025" no "Campus Darcy Ribeiro"

    Exemplos:
      | turno  |
      | Café   |
      | Almoço |
      | Jantar |

    # caminhos tristes

  Cenário: Recusar exportação sem sessão de administrador
    Dado que não estou autenticado como administrador geral
    Quando solicito a exportação do PDF
    Então a exportação deve ser recusada
    E nenhum PDF deve ser gerado

  Cenário: Recusar exportação sem operação no período
    Dado que estou autenticado como administrador geral
    E que não há operação em 01/01/2025 no Campus Darcy Ribeiro
    Quando filtro o relatório por data "01/01/2025", turno "Todos" e campus "Campus Darcy Ribeiro"
    E solicito a exportação do PDF
    Então a exportação deve ser recusada
    E devo ser informado de que não há operação no período
    E nenhum PDF deve ser gerado
