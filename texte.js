const pool = require("./config");

async function testarConexao() {
  try {
    const result = await pool.query("SELECT NOW()");
    console.log("Base de dados conectada!");
    console.log(result.rows[0]);
  } catch (error) {
    console.error("Erro na conexão:", error);
  } finally {
    await pool.end();
  }
}

testarConexao();

//isso testa a conexão com o banco de dados, se estiver tudo certo ele vai retornar a data e hora atual do banco de dados, caso contrário vai retornar um erro.