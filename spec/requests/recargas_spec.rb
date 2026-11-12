require "rails_helper"

RSpec.describe "Acesso às recargas", type: :request do
  let(:estudante) do
    User.create!(
      nome: "Bruno",
      matricula: "251099004",
      role: "estudante",
      password: "Teste@1234",
      password_confirmation: "Teste@1234",
      saldo: 10,
      grupo_pagamento: "2"
    )
  end

  def entrar_como(usuario)
    post login_estudante_path, params: {
      matricula: usuario.matricula,
      senha: "Teste@1234"
    }

    expect(response).to redirect_to(root_path)
  end

  around do |exemplo|
    adaptador_anterior = ActiveJob::Base.queue_adapter
    ActiveJob::Base.queue_adapter = :test

    begin
      exemplo.run
    ensure
      ActiveJob::Base.queue_adapter = adaptador_anterior
    end
  end

  it "recusa acesso sem cadastro de estudante" do
    expect(User.where(role: "estudante")).to be_empty

    get new_recarga_path

    expect(response).to redirect_to(login_estudante_path)
  end

  it "recusa acesso de estudante cadastrado que não fez login" do
    estudante

    get new_recarga_path

    expect(response).to redirect_to(login_estudante_path)
  end

  it "recusa envio de recarga sem autenticação" do
    post recargas_path, params: {
      recarga: {
        valor: "R$15,00",
        forma_pagamento: "pix"
      }
    }

    expect(response).to redirect_to(login_estudante_path)
    expect(Recarga.count).to eq(0)
  end

  it "bloqueia a página e o envio de recarga para o grupo 1" do
    estudante.update!(grupo_pagamento: "1")
    entrar_como(estudante)

    get new_recarga_path

    expect(response).to redirect_to(root_path)

    post recargas_path, params: {
      recarga: {
        valor: "R$15,00",
        forma_pagamento: "pix"
      }
    }

    expect(response).to redirect_to(root_path)
    expect(estudante.recargas.count).to eq(0)
    expect(estudante.reload.saldo).to eq(BigDecimal("10"))
  end

  it "cria o PIX para o usuário conectado sem aceitar situação forjada" do
    entrar_como(estudante)

    post recargas_path, params: {
      recarga: {
        valor: "R$15,00",
        forma_pagamento: "pix",
        situacao: "confirmada",
        user_id: 999999
      }
    }

    recarga = estudante.recargas.last

    expect(recarga).to be_present
    expect(response).to redirect_to(recarga_path(recarga))
    expect(recarga.situacao).to eq("pendente")
    expect(estudante.reload.saldo).to eq(BigDecimal("10"))
  end

  it "mostra o erro de valor zero sem criar recarga" do
    entrar_como(estudante)

    post recargas_path, params: {
      recarga: {
        valor: "R$0,00",
        forma_pagamento: "pix"
      }
    }

    expect(response).to have_http_status(:unprocessable_content)
    expect(response.body).to include("Selecione um valor")
    expect(estudante.recargas.count).to eq(0)
    expect(estudante.reload.saldo).to eq(BigDecimal("10"))
  end

  it "impede consultar ou confirmar a recarga de outro estudante" do
    outro = User.create!(
      nome: "Ana",
      matricula: "241020803",
      role: "estudante",
      password: "Teste@1234",
      password_confirmation: "Teste@1234",
      grupo_pagamento: "2"
    )

    recarga = SolicitarRecarga.executar(
      usuario: outro,
      valor: "R$15,00",
      forma_pagamento: "pix"
    )

    entrar_como(estudante)

    get recarga_path(recarga)

    expect(response).to have_http_status(:not_found)

    post confirmar_pix_recarga_path(recarga)

    expect(response).to have_http_status(:not_found)
    expect(recarga.reload.situacao).to eq("pendente")
    expect(outro.reload.saldo).to eq(BigDecimal("0"))
  end
end
