# UnB RU

Aplicação web em Rails para o Restaurante Universitário da UnB. O projeto reúne consulta ao cardápio, cadastro e acesso do estudante, gestão de saldo e recargas, operação de catracas, administração do restaurante e FastPass.

## Funcionalidades

- **Estudante:** cadastro, login e saída; consulta do cardápio diário; saldo, recarga, extrato e exportação em PDF.
- **Operação:** autenticação de funcionários, abertura do ponto de acesso, validação de entrada, histórico local e relatório de operação.
- **Administração:** gestão de restaurantes, catracas, turnos e faixas do FastPass; relatório global de acessos.
- **FastPass:** inscrição gratuita e única por dia e turno, confirmação dos ganhadores por um administrador, notificação do resultado e validação na catraca. A entrada comum continua disponível a quem não ganhou. A inscrição não cobra saldo; a entrada liberada usa a mesma tarifa da catraca comum.

As regras e decisões de cada história devem ser registradas na [Wiki do projeto](https://github.com/bielzinmene/UnB_RU/wiki). A história #13 está fora do escopo desta implementação; a escolha dos ganhadores é registrada manualmente pelo administrador.

## Executar localmente

Requer Ruby 3.4 e SQLite. Na raiz do repositório:

```bash
bundle install
bin/rails db:prepare
bin/rails db:seed
bin/rails server
```

A aplicação estará em `http://localhost:3000`. Em outro terminal, inicie o processamento das notificações agendadas:

```bash
bin/jobs
```

O Solid Queue guarda os trabalhos em um banco SQLite separado, inclusive após reiniciar o Rails. Para que as notificações sejam entregues, `bin/jobs` precisa estar ativo. Em produção, prepare os bancos com `RAILS_ENV=production bin/rails db:prepare` e execute também o processo `bin/jobs` com `RAILS_ENV=production`.

O seed cria cardápios para os próximos 30 dias a partir de `cardapio.json`. Depois desse período, a página usa a programação semanal do mesmo arquivo.

## Acessar as áreas

| Área | Endereço |
| --- | --- |
| Portal e cardápio | `/` e `/cardapio` |
| Cadastro e login do estudante | `/cadastro` e `/estudante/login` |
| Área do estudante e inscrições FastPass | `/estudante` e `/estudante/fastpass/inscricoes` |
| Login do funcionário | `/funcionario/login` |
| Pontos de acesso e terminal | `/pontos-de-acesso` e `/operacao/terminal` |
| Administração de restaurantes e FastPass | `/admin/restaurantes` e `/admin/turnos_fastpass` |

Para experimentar o acesso de funcionário no ambiente local, crie uma conta no console Rails:

```ruby
User.create!(nome: "Funcionário de teste", role: "funcionario", siape: "123456-7", sigaa: "teste.ru", password: "Teste@1234")
```

O cadastro de estudante inicia uma sessão automaticamente. O estudante também pode entrar novamente por `/estudante/login` e sair pelo portal. Essa decisão de iniciar a sessão após o cadastro ainda deve ser revista pelo grupo em uma etapa futura.

## Testes e qualidade

```bash
bin/rails db:test:prepare
bundle exec rspec
bundle exec cucumber features/*.feature --publish-quiet
bin/rubocop
bundle exec brakeman --no-pager
```

O GitHub Actions executa os cenários Cucumber, os testes RSpec, RuboCop e verificações de segurança nos pull requests. As senhas usam `has_secure_password` com bcrypt; o acesso a cada área depende do papel do usuário.
