Dado("que estou autenticado como administrador") do
  admin = User.find_or_create_by!(siape: "999999-9") do |u|
    u.nome = "Admin RU"
    u.role = "administrador"
    u.password = "Teste@1234"
  end
  visit login_funcionario_path
  fill_in "Matrícula SIAPE ou usuário SIGAA", with: admin.siape
  fill_in "Senha de Acesso", with: "Teste@1234"
  click_button "Entrar"
end

Dado("que estou autenticado como estudante") do
  estudante = User.find_or_create_by!(matricula: "241020999") do |u|
    u.nome = "Estudante Teste"
    u.role = "estudante"
    u.password = "Teste@1234"
    u.password_confirmation = "Teste@1234"
  end
  visit login_estudante_path
  fill_in "Matrícula", with: estudante.matricula
  fill_in "Senha", with: "Teste@1234"
  click_button "Entrar"
end
