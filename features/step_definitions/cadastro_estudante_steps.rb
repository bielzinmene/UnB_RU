Before do
  @contagem_inicial = User.where(role: "estudante").count
end

Dado(/^que a data atual é (\d+)\/(\d+)\/(\d+)$/) do |dia, mes, ano|
  travel_to Time.zone.local(ano.to_i, mes.to_i, dia.to_i, 12, 0)
end

After do
  travel_back
end

Dado("que não existe conta com a matrícula {string}") do |matricula|
  expect(User.exists?(matricula: matricula)).to be(false)
end

Dado("que já existe uma conta com a matrícula {string}") do |matricula|
  User.create!(nome: "Já cadastrado", matricula: matricula, role: "estudante",
    password: "Certa@123", password_confirmation: "Certa@123")
  @contagem_inicial = User.where(role: "estudante").count
end

Quando("preencho o cadastro com nome {string}, matrícula {string}, senha {string} e confirmação {string}") do |nome, matricula, senha, confirmacao|
  visit cadastro_path
  fill_in "Nome completo", with: nome
  fill_in "Matrícula", with: matricula
  fill_in "Senha", with: senha
  fill_in "Confirmação de senha", with: confirmacao
end

Quando("solicito a criação da conta") do
  click_button "Criar conta"
end

Então("a conta do estudante {string} deve ser criada com a matrícula {string}") do |nome, matricula|
  expect(User.find_by(matricula: matricula, nome: nome, role: "estudante")).to be_present
end

Então("o cadastro deve ser recusado") do
  expect(page).to have_content(/Cadastro recusado|Matrícula e\/ou Senha de Acesso incorretos/)
end

Então("devo ser informado de que o campo {string} é obrigatório") do |campo|
  expect(page).to have_content("#{campo} é obrigatóri")
end

Então("devo ser informado de que a matrícula {string}") do |motivo|
  expect(page).to have_content(motivo)
end

Então("devo ser informado de que a senha {string}") do |motivo|
  expect(page).to have_content(motivo)
end

Então("devo ser informado de que a confirmação de senha é diferente") do
  expect(page).to have_content("confirmação de senha")
end

Então("nenhuma conta deve ser criada") do
  expect(User.where(role: "estudante").count).to eq(@contagem_inicial)
end

Então("devo ver a mensagem {string}") do |mensagem|
  expect(page).to have_content(mensagem)
end

Então("nenhuma outra conta deve ser criada com a matrícula {string}") do |matricula|
  expect(User.where(matricula: matricula).count).to eq(1)
end
