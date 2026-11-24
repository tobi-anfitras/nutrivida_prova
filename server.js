const express = require("express");
const path = require("path");
const pool = require("./config.js");

const app = express();
app.use(express.json())
app.use(express.static(__dirname));

const pastaFront = path.join(__dirname, "telas");



app.use(express.static(pastaFront));

app.get("/", (req, res) => {
  res.sendFile(path.join(pastaFront, "index.html"));
});

app.post("/login", async (req, res) => {
  const { nome, senha_hash } = req.body;

  if (!nome || !senha_hash) {
    return res.status(400).json({ mensagem: "Preencha nome e senha." });
  }

  try {
    // Ajuste "id", "nome" e "senha" se alguma coluna da tabela "usuario" tiver outro nome
    const resultado = await pool.query(
      "SELECT id, nome, senha_hash FROM usuarios WHERE nome = $1",
      [nome]
    );

    const usuarios = resultado.rows[0];

    if (!usuarios || usuarios.senha_hash !== senha_hash) {
      return res.status(401).json({ mensagem: "Nome ou senha inválidos." });
    }

    return res.status(200).json({
      mensagem: "Login realizado com sucesso!",
      usuarios: {
        id: usuarios.id,
        nome: usuarios.nome,
      },
    });
  } catch (erro) {
    console.error("Erro no login:", erro);
    return res.status(500).json({ mensagem: "Erro interno no servidor." });
  }
});

const PORT = process.env.PORT || 3001;
app.listen(PORT, () => {
  console.log(`API rodando em http://localhost:${PORT}`);
});