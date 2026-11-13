def criar_funcionario(nome, siape, senha, sigaa = nil)
  User.find_or_create_by!(siape: siape) do |user|
    user.nome = nome
    user.sigaa = sigaa
    user.role = "funcionario"
    user.password = senha
  end
end

def enviar_login(identificador, senha)
  visit login_funcionario_path
  fill_in "Matrícula SIAPE ou usuário SIGAA", with: identificador
  fill_in "Senha de Acesso", with: senha
  click_button "Entrar"
end

Dado("que a funcionária {string} está cadastrada no sistema") do |nome|
  criar_funcionario(nome, "123456-7", "Teste@1234", "aline.ru")
end

Dado("que cadastrei um funcionário com a matrícula SIAPE {string}") do |siape|
  criar_funcionario("Aline", siape, "Teste@1234", "aline.ru")
end

Quando("preencho os campos com a Matrícula SIAPE {string} e a Senha de Acesso {string}") do |siape, senha|
  enviar_login(siape, senha)
end

Então("o login da conta que pertence a matrícula {string} é efetuada com êxito.") do |siape|
  expect(page).to have_current_path(area_funcionario_path)
  expect(page).to have_content(User.find_by!(siape: siape).nome)
end

Dado("que estou autenticado no sistema do RU") do
  enviar_login("123456-7", "Teste@1234")
  expect(page).to have_current_path(area_funcionario_path)
end

Quando("solicito o encerramento da sessão") do
  click_button "Encerrar sessão"
end

Então("minha sessão deve ser encerrada") do
  expect(page).to have_current_path(login_funcionario_path)
end

Então("não devo mais acessar funcionalidades protegidas sem realizar novo login") do
  visit area_funcionario_path
  expect(page).to have_current_path(login_funcionario_path)
end

Dado("que a funcionária {string} possui o usuário SIGAA {string} e a senha {string}") do |nome, sigaa, senha|
  funcionario = User.find_by!(nome: nome)
  funcionario.update!(sigaa: sigaa, password: senha)
end

Quando("informo o usuário SIGAA {string} e a senha {string}") do |sigaa, senha|
  enviar_login(sigaa, senha)
end

Então("a sessão da funcionária {string} deve ser autenticada") do |nome|
  expect(page).to have_current_path(area_funcionario_path)
  expect(page).to have_content(nome)
end

Então("devo poder acessar as funcionalidades protegidas") do
  visit area_funcionario_path
  expect(page).to have_current_path(area_funcionario_path)
end

Dado("que não estou autenticado no sistema do RU") do
  visit login_funcionario_path
end

Quando("tento acessar uma funcionalidade protegida") do
  visit area_funcionario_path
end

Então("o acesso deve ser negado") do
  if defined?(@acesso_operacional) && @acesso_operacional
    expect(@acesso_operacional).not_to be_liberado
  else
    expect(page).to have_current_path(login_funcionario_path)
  end
end

Dado("que não existe funcionário com a matrícula SIAPE {string}") do |siape|
  expect(User.exists?(siape: siape)).to be(false)
end

Quando("informo a matrícula SIAPE {string} e a senha {string}") do |siape, senha|
  enviar_login(siape, senha)
end

Então("o login deve ser recusado") do
  expect(page).to have_current_path(login_funcionario_path)
  expect(page).to have_content("incorretos")
end

Então("não devo acessar funcionalidades protegidas") do
  visit area_funcionario_path
  expect(page).to have_current_path(login_funcionario_path)
end

Dado("que {string} está cadastrada com a matrícula SIAPE {string} e senha {string}") do |nome, siape, senha|
  criar_funcionario(nome, siape, senha)
end

Dado("que {string} está cadastrado com a matrícula SIAPE {string} e senha {string}") do |nome, siape, senha|
  criar_funcionario(nome, siape, senha)
end

Então("não devo acessar a conta de {string}") do |nome|
  visit area_funcionario_path
  expect(page).to have_current_path(login_funcionario_path)
  expect(page).not_to have_content("Olá, #{nome}")
end

Dado("que há um funcionário cadastrado com a matrícula {string} e a senha {string}") do |siape, senha|
  criar_funcionario("Aline", siape, senha)
end

Então(/^devo ser informado de que a Matrícula e\/ou a Senha de Acesso estão incorretos\.$/) do
  expect(page).to have_content("Matrícula e/ou Senha de Acesso incorretos")
end

Quando("preencho os campos de login com a matrícula estudantil e com a senha de acesso") do
  User.create!(nome: "Estudante", matricula: "241020803", role: "estudante",
    password: "Teste@1234", password_confirmation: "Teste@1234")
  enviar_login("241020803", "Teste@1234")
end

Então("devo ser informado que não há nenhuma conta com esses dados registrados no sistema") do
  expect(page).to have_content("Não há nenhuma conta com esses dados registrados no sistema")
end

Então("informar que o acesso de autentiação de funcionário para aluno é proibida.") do
  expect(page).to have_content("acesso de autenticação de funcionário para aluno é proibido")
end

Dado("que estou na tela de login do sistema do RU") do
  visit login_funcionario_path
end

Quando(/^preencho a matrícula SIAPE\/SIGAA com "([^"]*)" e a senha de acesso com "([^"]*)"$/) do |identificador, senha|
  fill_in "Matrícula SIAPE ou usuário SIGAA", with: identificador
  fill_in "Senha de Acesso", with: senha
end

Quando("solicito a autenticação") do
  click_button "Entrar"
end

Então("o sistema deve impedir o login") do
  expect(page).to have_current_path(login_funcionario_path)
end

Então("deve informar que os campos obrigatórios precisam ser preenchidos") do
  expect(page).to have_content("são obrigatórias")
end
