-- NutriVida: executar no psql conectado ao banco nutrivida.
-- Antes, execute 02_estrutura.sql. Inicie o psql na pasta arquivos_CSV.
-- CSVs UTF-8 com cabeçalho; importação sem duplicar chaves já existentes.
BEGIN;
CREATE TEMP TABLE importar_usuarios (LIKE public.usuarios INCLUDING DEFAULTS) ON COMMIT DROP;
\copy importar_usuarios (id, nome, senha_hash, criado_em) FROM 'usuarios.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8')
INSERT INTO public.usuarios (id, nome, senha_hash, criado_em) SELECT id, nome, senha_hash, criado_em FROM importar_usuarios ON CONFLICT (id) DO NOTHING;
CREATE TEMP TABLE importar_alimentos (LIKE public.alimentos INCLUDING DEFAULTS) ON COMMIT DROP;
\copy importar_alimentos (id, nome, categoria, calorias, tempo_preparo, proteinas, carboidratos, gorduras, emoji, descricao) FROM 'alimentos.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8')
INSERT INTO public.alimentos (id, nome, categoria, calorias, tempo_preparo, proteinas, carboidratos, gorduras, emoji, descricao) SELECT id, nome, categoria, calorias, tempo_preparo, proteinas, carboidratos, gorduras, emoji, descricao FROM importar_alimentos ON CONFLICT (id) DO NOTHING;
CREATE TEMP TABLE importar_plano_alimentar (LIKE public.plano_alimentar INCLUDING DEFAULTS) ON COMMIT DROP;
\copy importar_plano_alimentar (id, usuario_id, alimento_id, refeicao, quantidade, criado_em) FROM 'plano_alimentar.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8')
INSERT INTO public.plano_alimentar (id, usuario_id, alimento_id, refeicao, quantidade, criado_em) SELECT id, usuario_id, alimento_id, refeicao, quantidade, criado_em FROM importar_plano_alimentar ON CONFLICT (id) DO NOTHING;
CREATE TEMP TABLE importar_favoritos (LIKE public.favoritos INCLUDING DEFAULTS) ON COMMIT DROP;
\copy importar_favoritos (usuario_id, alimento_id) FROM 'favoritos.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8')
INSERT INTO public.favoritos (usuario_id, alimento_id) SELECT usuario_id, alimento_id FROM importar_favoritos ON CONFLICT (usuario_id, alimento_id) DO NOTHING;
CREATE TEMP TABLE importar_avaliacoes (LIKE public.avaliacoes INCLUDING DEFAULTS) ON COMMIT DROP;
\copy importar_avaliacoes (id, usuario_id, alimento_id, nota, comentario, criado_em) FROM 'avaliacoes.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8')
INSERT INTO public.avaliacoes (id, usuario_id, alimento_id, nota, comentario, criado_em) SELECT id, usuario_id, alimento_id, nota, comentario, criado_em FROM importar_avaliacoes ON CONFLICT (id) DO NOTHING;
CREATE TEMP TABLE importar_sessoes (LIKE public.sessoes INCLUDING DEFAULTS) ON COMMIT DROP;
\copy importar_sessoes (token_hash, usuario_id, expira_em) FROM 'sessoes.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8')
INSERT INTO public.sessoes (token_hash, usuario_id, expira_em) SELECT token_hash, usuario_id, expira_em FROM importar_sessoes ON CONFLICT (token_hash) DO NOTHING;
SELECT setval(pg_get_serial_sequence('public.usuarios', 'id'), GREATEST(COALESCE((SELECT MAX(id) FROM public.usuarios), 0), 1), EXISTS(SELECT 1 FROM public.usuarios));
SELECT setval(pg_get_serial_sequence('public.alimentos', 'id'), GREATEST(COALESCE((SELECT MAX(id) FROM public.alimentos), 0), 1), EXISTS(SELECT 1 FROM public.alimentos));
SELECT setval(pg_get_serial_sequence('public.plano_alimentar', 'id'), GREATEST(COALESCE((SELECT MAX(id) FROM public.plano_alimentar), 0), 1), EXISTS(SELECT 1 FROM public.plano_alimentar));
SELECT setval(pg_get_serial_sequence('public.avaliacoes', 'id'), GREATEST(COALESCE((SELECT MAX(id) FROM public.avaliacoes), 0), 1), EXISTS(SELECT 1 FROM public.avaliacoes));
COMMIT;
