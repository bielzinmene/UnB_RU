# UnB RU

Aplicação Rails para o Restaurante Universitário da UnB. Esta parte da Sprint 2 implementa cadastro e login de estudante, autenticação de funcionário e consulta ao cardápio do dia. Os demais cenários estão em `features/` e serão implementados pelas outras frentes do grupo.

## Rodar localmente

Requer Ruby 3.4 e SQLite. Na raiz do repositório:

```bash
bundle install
bin/rails db:prepare
bin/rails db:seed
bin/rails server
```

Acesse `http://localhost:3000`. O seed carrega as opções do `cardapio.json` para os próximos 30 dias; depois disso, a página continua a usar a programação semanal do mesmo arquivo. O cadastro de estudante fica em `/cadastro`; o login de funcionário, em `/funcionario/login`; e o cardápio do dia, em `/cardapio`, mostra café, almoço e jantar mesmo fora dos horários de serviço. A mensagem de indisponibilidade aparece apenas se não houver registros para o dia e o arquivo semanal não puder ser lido.

Para criar um funcionário de teste, abra `bin/rails console` e execute:

```ruby
User.create!(nome: "Funcionário de teste", role: "funcionario", siape: "123456-7", sigaa: "teste.ru", password: "Teste@1234")
```

## Testes do grupo 1

```bash
bundle exec rspec
bundle exec cucumber features/cadastro_estudante.feature features/autenticacao_funcionario.feature features/cardapio-refeicao-atual.feature --publish-quiet
bin/rubocop
```

As senhas são armazenadas com `has_secure_password` e bcrypt. A área do funcionário exige sessão e aceita apenas usuários com papel de funcionário ou administrador.

## Pendente para as próximas funcionalidades do estudante

Após o cadastro, o estudante já inicia uma sessão. Ele também pode entrar novamente em `/estudante/login` e encerrar a sessão pelo portal. Em uma etapa futura, revisar a decisão de autenticar automaticamente após a criação da conta.
