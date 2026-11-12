# Sprint 2 — Saldo do estudante

Responsável: Fernanda — preencher nome completo e matrícula.

## Funcionalidades implementadas

- Recarga por PIX e cartão de crédito em modo de demonstração.
- Área do estudante com saldo e acesso às funcionalidades.
- Extrato de recargas confirmadas.
- Histórico de refeições consumidas.
- Exportação do extrato e histórico em PDF.

## Regras de acesso

As páginas financeiras exigem login como estudante.

Cada estudante consulta somente seus próprios registros.

O grupo de pagamento é diferente do papel do usuário:

- Grupo 1: isento.
- Grupo 2: estudante pagante.
- Grupo 3: visitante.

O grupo 1 é especificado nos BDDs. A classificação dos grupos 2 e 3
foi uma decisão de implementação do projeto.

Novas contas recebem grupo 2 por padrão. A classificação oficial
deverá ser atribuída por uma fonte autorizada.

Cadastro e acesso de visitantes não foram implementados nesta parte.
Ter grupo 3 não concede acesso à área do estudante.

## Recargas

O valor deve ser positivo. O saldo não pode ultrapassar R$500,00.

PIX pendentes também são considerados na verificação do limite,
mas não aumentam o saldo disponível até serem confirmados.

Estudantes do grupo 1 não podem realizar recargas.

O cartão verifica número, CPF, nome, validade e CVV.
Os dados não são persistidos e o grupo de parâmetros `cartao`
é filtrado dos logs.

### Pagamentos de demonstração

Não existe integração bancária ou cobrança real.

O código PIX é fictício e não pode ser pago em um banco.
O botão de simulação representa a confirmação do pagamento.

Cartões com dados aceitos pelas validações recebem aprovação
fictícia. Não são consultados limite bancário, existência do
cartão ou titularidade.

A simulação funciona somente em desenvolvimento e teste.

### Expiração do PIX

O prazo normal é de dez minutos.

Após salvar uma recarga PIX, o modelo agenda
`CancelarPixExpiradosJob` para o vencimento.

O serviço `CancelarPixExpirados` cancela os PIX pendentes vencidos
sem alterar o saldo.

A confirmação também verifica o prazo, impedindo crédito atrasado.
Confirmar novamente uma recarga já confirmada não duplica o crédito.

Em desenvolvimento, a fila AsyncAdapter executa dentro do processo
Rails. Reiniciar ou parar esse processo perde os agendamentos
em memória.

A abertura de uma recarga e a solicitação de nova recarga também
verificam vencimentos. Para uma implantação com persistência dos
agendamentos, será necessário configurar uma fila persistente
e seu processador.

## Extrato e histórico

O extrato mostra apenas recargas confirmadas, pela data de confirmação.

O histórico mostra os consumos pela data da passagem.

Ambos são ordenados do mais recente para o mais antigo.

As consultas usam as associações do usuário autenticado.
Não há uma segunda tabela copiando os dados do extrato.

O modelo `Refeicao`, da parte 1, representa o cardápio.
O modelo `Consumo` representa uma refeição consumida pelo estudante.

## PDF

O documento contém identificação do estudante, recargas e refeições.

É permitido gerar PDF com somente recargas ou somente refeições.
Se ambas as listas estiverem vazias, a exportação é recusada.

Sem autenticação ou ao solicitar outra matrícula, nenhum PDF é enviado.

A fonte DejaVu é incorporada ao documento.
Os arquivos e sua licença ficam em `app/assets/fonts`.

## Integração com a parte 3 — catraca

Após validar as regras de entrada, a parte 3 deverá registrar
o consumo pelo serviço abaixo:

```ruby
estudante = User.find_by!(
  matricula: "251099001",
  role: "estudante"
)

RegistrarConsumo.executar(
  usuario: estudante,
  restaurante: "RU Central",
  valor: "2.50",
  referencia: "acesso-123",
  ocorrido_em: Time.current
)
```

O serviço registra o consumo e desconta o saldo na mesma transação.
Não se deve criar o consumo e atualizar o saldo em comandos separados.

A referência deve identificar a passagem de forma única e estável.
Em uma repetição da operação, deve ser enviada a mesma referência.

Repetir a referência com os mesmos dados não gera outro desconto.
Reutilizá-la com outro usuário, restaurante ou valor é recusado.

Para o grupo 1, o valor deve ser zero. Cobranças positivas são recusadas.

O serviço verifica saldo suficiente, mas não libera catracas
nem valida turno, FastPass ou autorização de entrada.
Essas regras pertencem à operação da catraca.

O restaurante é registrado como nome histórico. A parte 3 poderá
vincular o consumo aos seus registros de acesso e restaurante.

SQLite pode apresentar erro de bloqueio em escritas concorrentes.
Uma tentativa repetida deve conservar a mesma referência da passagem.

## Executar a aplicação

```bash
bundle install
bin/rails db:prepare
bin/rails db:seed
bin/rails server
```

A área do estudante fica em `/estudante`.
A recarga fica em `/recargas/new`.
O extrato fica em `/extrato`.
O PDF é solicitado por `/extrato.pdf`.

## Testes

```bash
RAILS_ENV=test bin/rails db:prepare
bundle exec rspec
```

BDD da parte 2:

```bash
bundle exec cucumber features/recarga_de_saldo.feature features/extrato-e-historico.feature features/exportacao_pdf_historico_estudante.feature --publish-quiet
```

São 30 casos BDD, contando as linhas das tabelas de exemplos:

- Recarga: 20.
- Extrato e histórico: 3.
- PDF: 7.

Os testes usam banco separado do ambiente de desenvolvimento.

## Uso de IA

Ferramenta utilizada: ChatGPT/Codex.

Apoio na interpretação dos BDDs, implementação de migrations,
modelos, serviços, controllers, telas, testes e documentação.

Estratégia: desenvolvimento incremental, com explicação de cada
arquivo, testes manuais no console e navegador, testes RSpec
e execução dos cenários Cucumber.