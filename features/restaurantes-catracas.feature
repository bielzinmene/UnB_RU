# language pt
# issue 8



Funcionalidade: Gestão de Restaurantes e Catracas
Como administrador, eu quero cadastrar, editar e remover diferentes restaurantes e suas respectivas catracas físicas no sistema, para que os funcionários possam selecioná-las na Aplicação de Controle.


Contexto:
  Dado que a data atual é 16/10/2026

# caminho feliz

Cenário: Cadastrar restaurante e catraca

  Dado que estou autenticado como administrador
  E não existe restaurante com ID "1"
  E não existe catraca com ID "1"
  Quando cadastro o restaurante de ID "1"
  E cadastro a catraca de ID "1"
  E associo a catraca ao restaurante
  Então o restaurante deve ser cadastrado com sucesso



# caminhos tristes

Cenário: Recusar restaurante já cadastrado

  Dado que existe um restaurante com ID "1"
  Quando tento cadastrar o restaurante de ID "1"
  Então o cadastro deve ser recusado
  E devo ser informado que o restaurante já existe

Cenário: Recusar catraca já cadastrada

  Dado que existe uma catraca com ID "1"
  Quando tento cadastrar a catraca de ID "1"
  Então o cadastro deve ser recusado
  E devo ser informado que a catraca já existe


Esquema do Cenário: Recusar ID fora do intervalo

  Dado que estou autenticado como administrador
  Quando tento cadastrar o restaurante com ID "<id_restaurante>"
  E tento cadastrar a catraca com ID "<id_catraca>"
  Então o cadastro deve ser recusado
  E devo ser informado que o ID é inválido

  Exemplos:
    | id_restaurante | id_catraca |
    | 0              | 1          |
    | 7              | 1          |
    | 1              | 0          |
    | 1              | 7          |


Cenário: Recusar catraca já associada

  Dado que a catraca de ID "1" já está associada a um restaurante
  Quando tento associar a catraca de ID "1" a outro restaurante
  Então a associação deve ser recusada
  E devo ser informado que a catraca já está sendo utilizada


Cenário: Recusar restaurante sem catraca

  Dado que estou autenticado como administrador
  Quando cadastro o restaurante de ID "1"
  E não associo uma catraca
  Então o cadastro deve ser recusado
  E devo ser informado que o restaurante precisa de uma catraca
