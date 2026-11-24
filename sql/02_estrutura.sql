-- ETAPA 2: Conecte-se ao banco nutrivida no pgAdmin e execute este arquivo inteiro.
-- Cria tabelas e insere os dados demonstrativos. Pode ser reexecutado sem duplicar itens.
-- Nao execute este arquivo no banco postgres: selecione nutrivida no Query Tool.

-- Execute conectado ao banco 'nutrivida'. Pode ser reexecutado sem apagar os dados.
BEGIN;
CREATE TABLE IF NOT EXISTS usuarios (
  id BIGSERIAL PRIMARY KEY,
  nome VARCHAR(40) NOT NULL,
  senha_hash TEXT NOT NULL,
  criado_em TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE UNIQUE INDEX IF NOT EXISTS uq_usuarios_nome_ci ON usuarios (lower(nome));
CREATE TABLE IF NOT EXISTS alimentos (
  id BIGSERIAL PRIMARY KEY,
  nome VARCHAR(100) NOT NULL,
  categoria VARCHAR(25) NOT NULL CHECK (categoria IN ('refeicoes','lanches','vitaminas')),
  calorias INTEGER NOT NULL CHECK (calorias >= 0),
  tempo_preparo INTEGER NOT NULL CHECK (tempo_preparo >= 0),
  proteinas NUMERIC(8,2) NOT NULL DEFAULT 0,
  carboidratos NUMERIC(8,2) NOT NULL DEFAULT 0,
  gorduras NUMERIC(8,2) NOT NULL DEFAULT 0,
  emoji VARCHAR(16),
  descricao TEXT
);
CREATE TABLE IF NOT EXISTS plano_alimentar (
  id BIGSERIAL PRIMARY KEY,
  usuario_id BIGINT NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
  alimento_id BIGINT NOT NULL REFERENCES alimentos(id),
  refeicao VARCHAR(30) NOT NULL CHECK (refeicao IN ('Café da manhã','Almoço','Lanche','Jantar')),
  quantidade INTEGER NOT NULL CHECK (quantidade BETWEEN 1 AND 20),
  criado_em TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS ix_plano_usuario ON plano_alimentar(usuario_id);
CREATE TABLE IF NOT EXISTS favoritos (
  usuario_id BIGINT NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
  alimento_id BIGINT NOT NULL REFERENCES alimentos(id) ON DELETE CASCADE,
  PRIMARY KEY (usuario_id,alimento_id)
);
CREATE TABLE IF NOT EXISTS avaliacoes (
  id BIGSERIAL PRIMARY KEY,
  usuario_id BIGINT NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
  alimento_id BIGINT NOT NULL REFERENCES alimentos(id) ON DELETE CASCADE,
  nota INTEGER NOT NULL CHECK (nota BETWEEN 1 AND 5),
  comentario VARCHAR(500) NOT NULL CHECK(length(trim(comentario)) >= 3),
  criado_em TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS ix_avaliacoes_alimento ON avaliacoes(alimento_id,criado_em DESC);
CREATE TABLE IF NOT EXISTS sessoes (
  token_hash CHAR(64) PRIMARY KEY,
  usuario_id BIGINT NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
  expira_em TIMESTAMPTZ NOT NULL
);
CREATE INDEX IF NOT EXISTS ix_sessoes_usuario ON sessoes(usuario_id);
COMMIT;


-- 18 alimentos demonstrativos e conta demo para login.
BEGIN;
INSERT INTO alimentos (id, nome, categoria, calorias, tempo_preparo, emoji, proteinas, carboidratos, gorduras, descricao) VALUES
(1, 'Salada Proteica', 'refeicoes', 420, 10, '🥗', 38, 25, 18, 'Frango grelhado, folhas frescas, tomate e grãos.'),
(2, 'Frango com Legumes', 'refeicoes', 430, 15, '🍗', 42, 24, 18, 'Filé de frango com legumes salteados.'),
(3, 'Arroz Integral com Peixe', 'refeicoes', 510, 25, '🐟', 36, 55, 16, 'Peixe assado, arroz integral e vegetais.'),
(4, 'Omelete de Vegetais', 'refeicoes', 310, 12, '🍳', 22, 10, 20, 'Omelete com espinafre e tomate.'),
(5, 'Quinoa com Legumes', 'refeicoes', 390, 20, '🥙', 14, 54, 13, 'Bowl de quinoa e legumes variados.'),
(6, 'Macarrão Integral', 'refeicoes', 460, 20, '🍝', 19, 70, 12, 'Massa integral com molho de tomate.'),
(7, 'Bowl de Frutas', 'lanches', 280, 5, '🍎', 4, 62, 2, 'Frutas frescas da estação.'),
(8, 'Mix de Castanhas', 'lanches', 210, 2, '🥜', 6, 8, 18, 'Porção de castanhas e amêndoas.'),
(9, 'Iogurte com Granola', 'lanches', 370, 4, '🥣', 15, 52, 11, 'Iogurte natural, granola e morango.'),
(10, 'Sanduíche Natural', 'lanches', 340, 7, '🥪', 18, 40, 12, 'Pão integral com vegetais e frango.'),
(11, 'Torradas com Abacate', 'lanches', 290, 8, '🥑', 8, 32, 15, 'Pão integral e pasta de abacate.'),
(12, 'Iogurte com Chia', 'lanches', 220, 5, '🍓', 10, 28, 8, 'Iogurte com sementes de chia e frutas.'),
(13, 'Smoothie Verde', 'vitaminas', 190, 7, '🥤', 5, 39, 2, 'Banana, kiwi e folhas verdes.'),
(14, 'Vitamina de Banana', 'vitaminas', 260, 6, '🍌', 9, 47, 5, 'Banana batida com leite e aveia.'),
(15, 'Suco de Abacaxi com Hortelã', 'vitaminas', 140, 5, '🍍', 1, 34, 0, 'Suco fresco de abacaxi e hortelã.'),
(16, 'Vitamina de Morango', 'vitaminas', 230, 6, '🍓', 8, 42, 4, 'Morango, leite e aveia.'),
(17, 'Suco de Laranja', 'vitaminas', 120, 4, '🍊', 2, 27, 0, 'Suco de laranja natural.'),
(18, 'Smoothie de Manga', 'vitaminas', 210, 6, '🥭', 5, 44, 2, 'Manga batida com iogurte.')
ON CONFLICT (id) DO NOTHING;

SELECT setval(pg_get_serial_sequence('alimentos','id'), GREATEST(COALESCE((SELECT MAX(id) FROM alimentos), 0), 1), true);
INSERT INTO usuarios (nome, senha_hash)
SELECT 'demo', '2c6fbba23140a1ced0276d0ad2f9572c:0a5396b69c317b243edc0cf3ff4482157411d2080aed5facd804bf1f8221f74c82a022fd354bf1f3622d4812dab52485615329d22a50c9a887a65f9c50f0036c'
WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE lower(nome) = lower('demo'));
COMMIT;
