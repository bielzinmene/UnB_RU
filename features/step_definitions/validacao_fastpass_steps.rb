module ApoioValidacaoFastpass
  def estudante_da_validacao(nome)
    criar_estudante_saldo(nome)
  end

  def ponto_da_validacao(modalidade)
    @restaurante_fastpass ||= Restaurante.create!(nome: "RU Central", campus: "UnB Darcy Ribeiro")
    identificador = modalidade == "FastPass" ? "RU-FP" : "RU-COM"
    PontoAcesso.find_or_create_by!(identificador: identificador) do |ponto|
      ponto.restaurante = @restaurante_fastpass
      ponto.nome = "Catraca #{modalidade}"
      ponto.campus = @restaurante_fastpass.campus
      ponto.status = "Ativo"
      ponto.modalidade = modalidade
    end
  end

  def acesso_liberado_do(nome, refeicao)
    Acesso.where(user: estudante_da_validacao(nome), resultado: "Liberado",
      refeicao: refeicao, ocorrido_em: Date.new(2026, 10, 20).all_day)
  end

  def registrar_acesso_anterior(nome, refeicao)
    ponto_da_validacao("FastPass").acessos.create!(
      user: estudante_da_validacao(nome),
      matricula: estudante_da_validacao(nome).matricula,
      ocorrido_em: Time.zone.local(2026, 10, 20, refeicao == "Jantar" ? 18 : 11, 10),
      refeicao: refeicao, resultado: "Liberado", valor_debitado: 6
    )
  end

  def validar_na_catraca(nome, modalidade, hora, data)
    @refeicao_validada = hora.to_i >= 16 ? "Jantar" : "Almoço"
    @acesso_fastpass = ValidarEntrada.executar(
      matricula: estudante_da_validacao(nome).matricula,
      ponto_acesso: ponto_da_validacao(modalidade),
      ocorrido_em: Time.zone.strptime("#{data} #{hora}", "%d/%m/%Y %H:%M"),
      refeicao: @refeicao_validada,
      valor_refeicao: @valor_refeicao_fastpass
    )
  end
end

World(ApoioValidacaoFastpass)

Dado(/^que o almoço de (\d{2}\/\d{2}\/\d{4}) ocorre das "([^"]*)" às "([^"]*)"$/) do |data, inicio, fim|
  @turno_validacao = TurnoFastpass.create!(data: Date.strptime(data, "%d/%m/%Y"),
    tipo_refeicao: "Almoço", inicio: inicio, fim: fim)
end

Dado(/^que a faixa FastPass de "([^"]*)" nesse almoço vai das "([^"]*)" às "([^"]*)"$/) do |nome, inicio, fim|
  faixa = @turno_validacao.faixas_fastpass.create!(inicio: inicio, fim: fim)
  @inscricao_validacao = InscricaoFastpass.create!(user: estudante_da_validacao(nome),
    turno_fastpass: @turno_validacao, faixa_fastpass: faixa)
end

Dado(/^que "([^"]*)" foi sorteada para essa faixa$/) do |nome|
  expect(@inscricao_validacao.user.nome).to eq(nome)
  @inscricao_validacao.update!(sorteado: true)
end

Dado(/^que "([^"]*)" participou do sorteio desse almoço e não foi sorteado$/) do |nome|
  faixa = @turno_validacao.faixas_fastpass.first
  InscricaoFastpass.create!(user: estudante_da_validacao(nome),
    turno_fastpass: @turno_validacao, faixa_fastpass: faixa, sorteado: false)
  @turno_validacao.update!(sorteio_concluido_em: Time.current)
end

Dado(/^que o valor da refeição é de R\$ ([\d,.]+)$/) do |valor|
  @valor_refeicao_fastpass = BigDecimal(valor.tr(".", "").tr(",", "."))
end

Dado(/^que "([^"]*)" possui saldo de R\$ ([\d,.]+)(?: antes do jantar)?$/) do |nome, valor|
  estudante_da_validacao(nome).update!(saldo: BigDecimal(valor.tr(".", "").tr(",", ".")))
end

Dado(/^que "([^"]*)" ainda não acessou o RU no almoço de (\d{2}\/\d{2}\/\d{4})$/) do |nome, _data|
  expect(acesso_liberado_do(nome, "Almoço")).to be_empty
end

Dado(/^que "([^"]*)" ainda não acessou o RU nesse jantar$/) do |nome|
  expect(acesso_liberado_do(nome, "Jantar")).to be_empty
end

Dado(/^que "([^"]*)" já acessou o RU no almoço de (\d{2}\/\d{2}\/\d{4})(?: pela catraca FastPass)?$/) do |nome, _data|
  registrar_acesso_anterior(nome, "Almoço")
end

Dado(/^que o jantar de (\d{2}\/\d{2}\/\d{4}) ocorre das "([^"]*)" às "([^"]*)"$/) do |data, inicio, fim|
  @turno_jantar_validacao = TurnoFastpass.create!(data: Date.strptime(data, "%d/%m/%Y"),
    tipo_refeicao: "Jantar", inicio: inicio, fim: fim)
end

Dado(/^que "([^"]*)" foi sorteada para a faixa do jantar de (\d{2}\/\d{2}\/\d{4}) das "([^"]*)" às "([^"]*)"$/) do |nome, _data, inicio, fim|
  faixa = @turno_jantar_validacao.faixas_fastpass.create!(inicio: inicio, fim: fim)
  InscricaoFastpass.create!(user: estudante_da_validacao(nome),
    turno_fastpass: @turno_jantar_validacao, faixa_fastpass: faixa, sorteado: true)
  @turno_jantar_validacao.update!(sorteio_concluido_em: Time.current)
end

Dado(/^que o saldo de "([^"]*)" após esse acesso é de R\$ ([\d,.]+)$/) do |nome, valor|
  estudante_da_validacao(nome).update!(saldo: BigDecimal(valor.tr(".", "").tr(",", ".")))
end

Quando(/^"([^"]*)" se identifica na catraca (FastPass|comum) às "([^"]*)" em (\d{2}\/\d{2}\/\d{4})$/) do |nome, modalidade, hora, data|
  validar_na_catraca(nome, modalidade == "comum" ? "Comum" : modalidade, hora, data)
end

Quando(/^"([^"]*)" tenta entrar novamente pela "catraca (FastPass|comum)" às "([^"]*)" em (\d{2}\/\d{2}\/\d{4})$/) do |nome, modalidade, hora, data|
  validar_na_catraca(nome, modalidade == "comum" ? "Comum" : modalidade, hora, data)
end

Então(/^a catraca (FastPass|comum) deve ser liberada para "([^"]*)"$/) do |modalidade, nome|
  expect(@acesso_fastpass).to be_liberado
  expect(@acesso_fastpass.user.nome).to eq(nome)
  expect(@acesso_fastpass.ponto_acesso.modalidade).to eq(modalidade == "comum" ? "Comum" : modalidade)
end

Então(/^a catraca (FastPass|comum) deve permanecer bloqueada$/) do |modalidade|
  expect(@acesso_fastpass).not_to be_liberado
  expect(@acesso_fastpass.ponto_acesso.modalidade).to eq(modalidade == "comum" ? "Comum" : modalidade)
end

Então(/^a "catraca (FastPass|comum)" deve permanecer bloqueada$/) do |modalidade|
  expect(@acesso_fastpass).not_to be_liberado
  expect(@acesso_fastpass.ponto_acesso.modalidade).to eq(modalidade == "comum" ? "Comum" : modalidade)
end

Então(/^o saldo de "([^"]*)" deve (passar a|permanecer em) R\$ ([\d,.]+)$/) do |nome, _verbo, valor|
  expect(estudante_da_validacao(nome).reload.saldo).to eq(BigDecimal(valor.tr(".", "").tr(",", ".")))
end

Então(/^deve ser registrado um acesso de "([^"]*)" nesse (almoço|jantar)$/) do |nome, refeicao|
  expect(acesso_liberado_do(nome, refeicao.capitalize).count).to eq(1)
end

Então(/^nenhum acesso de "([^"]*)" deve ser registrado nesse almoço$/) do |nome|
  expect(acesso_liberado_do(nome, "Almoço")).to be_empty
end

Então(/^o acesso de "([^"]*)" no almoço deve permanecer registrado$/) do |nome|
  expect(acesso_liberado_do(nome, "Almoço").count).to eq(1)
end

Então(/^"([^"]*)" deve ser informad[oa] de que não foi sorteado$/) do |_nome|
  expect(@acesso_fastpass.motivo).to include("não sorteado")
end

Então(/^"([^"]*)" deve ser informad[oa] de que o saldo é insuficiente$/) do |_nome|
  expect(@acesso_fastpass.motivo).to eq("Saldo insuficiente")
end

Então(/^"([^"]*)" deve ser informad[oa] de que já acessou o RU nesse almoço$/) do |_nome|
  expect(@acesso_fastpass.motivo).to include("já registrada")
end

Então("o resultado do sorteio não deve impedir sua entrada comum") do
  expect(@acesso_fastpass).to be_liberado
end

Então("a catraca comum deve ser liberada conforme as regras normais de acesso") do
  expect(@acesso_fastpass).to be_liberado
end

Então(/^deve continuar existindo apenas um acesso de "([^"]*)" nesse almoço$/) do |nome|
  expect(acesso_liberado_do(nome, "Almoço").count).to eq(1)
end
