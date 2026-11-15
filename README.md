# UnB RU

Aplicação Rails para o Restaurante Universitário da UnB. A integração da Sprint 2 reúne cadastro e login, cardápio diário, saldo e recargas do estudante, extrato e PDF, operação e validação de entrada na catraca, além de administração de restaurantes, catracas, turnos e relatório de acessos. As histórias de inscrição, sorteio, notificação e validação FastPass continuam pendentes.

## Rodar localmente

Requer Ruby 3.4 e SQLite. Na raiz do repositório:

```bash
bundle install
bin/rails db:prepare
bin/rails db:seed
bin/rails server
```

Acesse `http://localhost:3000`. O seed carrega as opções do `cardapio.json` para os próximos 30 dias; depois disso, a página continua a usar a programação semanal do mesmo arquivo. O cadastro de estudante fica em `/cadastro`; o login de funcionário, em `/funcionario/login`; e o cardápio do dia, em `/cardapio`, mostra café, almoço e jantar mesmo fora dos horários de serviço. A área do estudante fica em `/estudante`, a operação da catraca em `/pontos-de-acesso` e a administração de restaurantes em `/admin/restaurantes`. A mensagem de indisponibilidade do cardápio aparece apenas se não houver registros para o dia e o arquivo semanal não puder ser lido.

Para criar um funcionário de teste, abra `bin/rails console` e execute:

```ruby
User.create!(nome: "Funcionário de teste", role: "funcionario", siape: "123456-7", sigaa: "teste.ru", password: "Teste@1234")
```

## Testes das funcionalidades integradas

```bash
bundle exec rspec
bundle exec cucumber features/autenticacao_funcionario.feature features/cadastro_estudante.feature features/cardapio-refeicao-atual.feature features/configuracao_ponto_acesso.feature features/exportacao_pdf.feature features/exportacao_pdf_historico_estudante.feature features/extrato-e-historico.feature features/gestao_turnos_timeframes_fastpass.feature features/historico-local-catraca.feature features/recarga_de_saldo.feature features/relatorio_global_acessos.feature features/restaurantes-catracas.feature features/validacao_de_entrada.feature --publish-quiet
bin/rubocop
```

As senhas são armazenadas com `has_secure_password` e bcrypt. A área do funcionário exige sessão e aceita apenas usuários com papel de funcionário ou administrador.

## Pendente para as próximas funcionalidades do estudante

Após o cadastro, o estudante já inicia uma sessão. Ele também pode entrar novamente em `/estudante/login` e encerrar a sessão pelo portal. Em uma etapa futura, revisar a decisão de autenticar automaticamente após a criação da conta.
