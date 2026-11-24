const abrirLogin = document.getElementById("abrirLogin");
const fecharLogin = document.getElementById("fecharLogin");
const modalLogin = document.getElementById("modalLogin");
const formLogin = document.getElementById("formLogin");
const erroLogin = document.getElementById("erroLogin");
const btnEntrar = document.getElementById("btnEntrar");
const visitanteEl = document.querySelector(".visitor");

function abrirModal() {
  if (!modalLogin) return;
  modalLogin.classList.add("ativo");
  modalLogin.setAttribute("aria-hidden", "false");
}

function fecharModal() {
  if (!modalLogin) return;
  modalLogin.classList.remove("ativo");
  modalLogin.setAttribute("aria-hidden", "true");
  if (erroLogin) erroLogin.textContent = "";
}

function atualizarUsuarioNaTela(usuarios) {
  if (!visitanteEl || !usuarios) return;
  visitanteEl.textContent = `👤 Olá, ${usuarios.nome || usuarios.email}`;
}

abrirLogin?.addEventListener("click", (evento) => {
  evento.preventDefault();
  abrirModal();
});

fecharLogin?.addEventListener("click", fecharModal);

modalLogin?.addEventListener("click", (evento) => {
  if (evento.target === modalLogin) fecharModal();
});

document.addEventListener("keydown", (evento) => {
  if (evento.key === "Escape" && modalLogin?.classList.contains("ativo")) {
    fecharModal();
  }
});

formLogin?.addEventListener("submit", async (evento) => {
  evento.preventDefault();

  const nome = document.getElementById("nome")?.value.trim() || "";
  const senha_hash = document.getElementById("senha")?.value || "";

  if (erroLogin) erroLogin.textContent = "";

  if (!nome || !senha_hash) {
    if (erroLogin) erroLogin.textContent = "Preencha nome e senha.";
    return;
  }

  if (btnEntrar) {
    btnEntrar.disabled = true;
    btnEntrar.textContent = "Entrando...";
  }

  try {
    const resposta = await fetch("/login", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ nome, senha_hash }),
    });

    const dados = await resposta.json().catch(() => ({}));

    if (!resposta.ok) {
      throw new Error(dados.mensagem || "Nome ou senha inválidos.");
    }

    if (dados.usuarios) {
      localStorage.setItem("nutrivida_usuario", JSON.stringify(dados.usuarios));
      atualizarUsuarioNaTela(dados.usuarios);
    }

    formLogin.reset();
    fecharModal();
  } catch (erro) {
    if (erroLogin) {
      erroLogin.textContent =
        erro.name === "TypeError"
          ? "Não foi possível conectar ao servidor."
          : erro.message;
    }
  } finally {
    if (btnEntrar) {
      btnEntrar.disabled = false;
      btnEntrar.textContent = "Entrar";
    }
  }
});