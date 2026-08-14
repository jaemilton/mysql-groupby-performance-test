-- Script otimizado para inserir 1.000.000 de registros
SET FOREIGN_KEY_CHECKS = 0;
SET UNIQUE_CHECKS = 0;
SET AUTOCOMMIT = 0;

-- 1. Guardar os counts em variáveis para evitar 1 milhão de subqueries
SET @total_tipo_mov = (SELECT COUNT(*) FROM tb_tipo_mov);
SET @total_ctpt     = (SELECT COUNT(*) FROM tb_ctpt);
SET @total_plat     = (SELECT COUNT(*) FROM tb_plat);
SET @hoje           = CURDATE();

-- 2. Criar a tabela temporária de números (Gerador de Linhas)
DROP TEMPORARY TABLE IF EXISTS tmp_numbers;
CREATE TEMPORARY TABLE tmp_numbers (n INT NOT NULL PRIMARY KEY);

INSERT INTO tmp_numbers (n)
SELECT a.n + b.n * 10 + c.n * 100 + d.n * 1000 + e.n * 10000 + f.n * 100000 + 1 AS n
FROM
    (SELECT 0 AS n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) a,
    (SELECT 0 AS n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) b,
    (SELECT 0 AS n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) c,
    (SELECT 0 AS n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) d,
    (SELECT 0 AS n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) e,
    (SELECT 0 AS n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) f;
COMMIT; -- Salva a tabela temporária primeiro

-- 3. Inserir na tb_execucao (Otimizado sem MD5 complexo)
INSERT INTO tb_execucao (cod_exec, cod_cttc, cod_tipo_mov, cod_oper_orig, dt_mov)
SELECT
    9999999 + n,
    IF(RAND() < 0.2, NULL, 1 + FLOOR(RAND() * 4)),
    1 + FLOOR(RAND() * @total_tipo_mov),
    CONCAT('OP-', (9999999 + n)), -- Alternativa ultra rápida ao MD5(RAND())
    @hoje
FROM tmp_numbers;
COMMIT; -- Libera memória e travas antes do próximo insert

-- 4. Inserir na tb_execucao_dtl (Usando variáveis e CASE rápido)
INSERT INTO tb_execucao_dtl (cod_exec, cod_ctpt, cod_plat, cod_fami, cod_estr, cod_ativ_base, cod_ativ_cota, num_qtde, vlr_unit)
SELECT
    9999999 + n,
    1 + FLOOR(RAND() * @total_ctpt),
    1 + FLOOR(RAND() * @total_plat),
    1,
    NULL,
    CASE FLOOR(RAND() * 4) WHEN 0 THEN 'BTC' WHEN 1 THEN 'ETH' WHEN 2 THEN 'USDC' ELSE 'USDT' END, -- CASE é mais rápido que ELT
    NULL,
    CAST(RAND() * 1000000 AS DECIMAL(28,18)), -- Evita a função ROUND redundante
    CAST(RAND() * 1000000 AS DECIMAL(28,18))
FROM tmp_numbers;
COMMIT;

-- Limpeza
DROP TEMPORARY TABLE tmp_numbers;

-- 5. Carga final na tb_execucao_dtl_v2 (Otimizada)
-- IMPORTANTE: Mude para READ COMMITTED temporariamente para evitar locks de leitura
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;

INSERT INTO tb_execucao_dtl_v2
    (cod_exec, cod_tipo_mov, dt_mov, cod_ctpt, cod_plat, cod_fami, cod_estr, cod_ativ_base, cod_ativ_cota, num_qtde, vlr_unit)
SELECT
    d.cod_exec,
    e.cod_tipo_mov,
    e.dt_mov,
    d.cod_ctpt,
    d.cod_plat,
    d.cod_fami,
    d.cod_estr,
    d.cod_ativ_base,
    d.cod_ativ_cota,
    d.num_qtde,
    d.vlr_unit
FROM tb_execucao_dtl d
INNER JOIN tb_execucao e ON e.cod_exec = d.cod_exec
WHERE d.cod_exec > 9999999; -- Filtro crucial para usar o índice da Primary Key!

COMMIT;

-- Restaurar configurações padrão
SET FOREIGN_KEY_CHECKS = 1;
SET UNIQUE_CHECKS = 1;
SET AUTOCOMMIT = 1;
