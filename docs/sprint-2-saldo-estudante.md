# Sprint 2 — Saldo do estudante

## O que foi feito

- Área do estudante com saldo e acesso aos serviços.
- Recarga por PIX e cartão em modo de demonstração.
- Extrato de recargas e histórico de refeições.
- Exportação dos registros em PDF.

É necessário entrar como estudante para acessar essas páginas. Cada pessoa vê apenas seus próprios dados.

## Grupos de pagamento

- **Grupo 1:** isento.
- **Grupo 2:** estudante pagante.
- **Grupo 3:** visitante.

O grupo 1 está definido nos BDDs. Os grupos 2 e 3 foram definidos durante a implementação.

Novas contas começam no grupo 2. Ainda falta definir como será atribuída a classificação oficial de cada pessoa. O cadastro e o acesso de visitantes não fazem parte desta implementação.

## Recargas

O valor da recarga deve ser positivo e o saldo final não pode passar de R$500,00. PIX pendentes também entram nessa verificação, mas só aumentam o saldo depois da confirmação.

Estudantes isentos não podem fazer recargas.

No cartão, são verificados número, CPF, nome, validade e CVV. Esses dados não são salvos no banco e ficam ocultos nos logs.

### Simulação dos pagamentos

Não há cobrança real nem integração com banco.

O PIX gera um código fictício. Para confirmar o pagamento, usamos o botão de simulação. No cartão, dados válidos recebem uma aprovação simulada, sem consulta de limite ou titularidade.

A simulação funciona apenas em desenvolvimento e teste.

### Vencimento do PIX

O PIX vence em dez minutos. Depois disso, a confirmação é recusada e nenhum crédito é adicionado. Confirmar duas vezes a mesma recarga também não duplica o saldo.

O cancelamento é agendado pelo `CancelarPixExpiradosJob`, que chama o serviço `CancelarPixExpirados`.

Em desenvolvimento, a fila funciona em memória. Se o processo Rails for encerrado, os agendamentos são perdidos. Abrir uma recarga ou solicitar outra também verifica os vencimentos. Para manter os agendamentos após reinícios, será necessário configurar uma fila persistente.

## Extrato, histórico e PDF

O extrato mostra as recargas confirmadas. O histórico mostra as refeições consumidas. As duas listas aparecem do registro mais recente para o mais antigo.

O PDF usa os mesmos dados da tela e inclui nome e matrícula do estudante. Ele pode ser gerado com apenas recargas ou apenas refeições. Se não houver nenhum registro, o sistema informa isso e não gera o arquivo.

A exportação exige login e não permite consultar os dados de outra matrícula.

A fonte usada no PDF e sua licença estão em `app/assets/fonts`.

## Integração com a catraca

A parte 3 usa `RegistrarConsumo` para registrar a refeição e descontar o saldo:

```ruby
RegistrarConsumo.executar(
  usuario: estudante,
  restaurante: "RU Central",
  valor: "2.50",
  referencia: "acesso-123",
  ocorrido_em: Time.current
)
```

O serviço faz o registro e o desconto na mesma transação. Não deve haver outro desconto fora dele.

A referência identifica a passagem. Se a operação for repetida, deve usar a mesma referência para evitar outra cobrança. Para isentos, o valor deve ser `"0.00"`.

Depois do registro, a refeição aparece no histórico e no PDF do estudante. As regras de entrada, turno e FastPass são verificadas pela operação da catraca.

O modelo `Refeicao` guarda o cardápio. O modelo `Consumo` guarda as refeições realizadas pelos estudantes.

## Como rodar

```bash
bundle install
bin/rails db:prepare
bin/rails db:seed
bin/rails server
```

Abra `http://localhost:3000`.

- Área do estudante: `/estudante`
- Recarga: `/recargas/new`
- Extrato e histórico: `/extrato`
- PDF: `/extrato.pdf`

## Testes

Prepare o banco de teste e execute o RSpec:

```bash
RAILS_ENV=test bin/rails db:prepare
bundle exec rspec
```

Para rodar os BDDs da parte 2:

```bash
bundle exec cucumber features/recarga_de_saldo.feature features/extrato-e-historico.feature features/exportacao_pdf_historico_estudante.feature --publish-quiet
```

São 30 casos, contando os exemplos das tabelas: 20 de recarga, 3 de extrato e histórico e 7 de PDF.

Os testes usam um banco separado do desenvolvimento.

## Uso de IA

Utilizei o ChatGPT/Codex para esclarecer dúvidas sobre os BDDs e auxiliar na escrita e revisão do código, dos testes e da documentação.

O desenvolvimento foi feito por etapas no VS Code, acompanhando as explicações e verificando os resultados no console, no navegador, no RSpec e no Cucumber.