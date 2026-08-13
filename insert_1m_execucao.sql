-- Script para inserir 1.000.000 de registros aleatórios em tb_execucao e tb_execucao_dtl
-- Executar apos create_tables.sql

SET FOREIGN_KEY_CHECKS = 0;
SET AUTOCOMMIT = 0;

-- Utiliza os dominios ja populados em create_tables.sql
DROP TEMPORARY TABLE IF EXISTS tmp_numbers;

CREATE TEMPORARY TABLE tmp_numbers (
    n INT NOT NULL PRIMARY KEY
);

INSERT INTO tmp_numbers (n)
SELECT a.n + b.n * 10 + c.n * 100 + d.n * 1000 + e.n * 10000 + f.n * 100000 + 1 AS n
FROM
    (SELECT 0 AS n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) a,
    (SELECT 0 AS n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) b,
    (SELECT 0 AS n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) c,
    (SELECT 0 AS n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) d,
    (SELECT 0 AS n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) e,
    (SELECT 0 AS n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) f
WHERE a.n + b.n * 10 + c.n * 100 + d.n * 1000 + e.n * 10000 + f.n * 100000 + 1 <= 1000000;

INSERT INTO tb_execucao (cod_exec, cod_cttc, cod_tipo_mov, cod_oper_orig, dt_mov)
SELECT
    9999999 + n,
    IF(RAND() < 0.2, NULL, 1 + FLOOR(RAND() * 4)),
    1 + FLOOR(RAND() * (SELECT COUNT(*) FROM tb_tipo_mov)),
    SUBSTRING(MD5(RAND()), 1, 20),
    CURDATE()
FROM tmp_numbers;

INSERT INTO tb_execucao_dtl
    (cod_exec, cod_ctpt, cod_plat, cod_fami, cod_estr, cod_ativ_base, cod_ativ_cota, num_qtde, vlr_unit)
SELECT
    9999999 + n,
    1 + FLOOR(RAND() * (SELECT COUNT(*) FROM tb_ctpt)),
    1 + FLOOR(RAND() * (SELECT COUNT(*) FROM tb_plat)),
    1 + FLOOR(RAND() * (SELECT COUNT(*) FROM tb_fami)),
    IF(RAND() < 0.25, NULL, ELT(1 + FLOOR(RAND() * 3), 3325, 5548, 2254)),
    ELT(1 + FLOOR(RAND() * 4), 'BTC', 'ETH', 'USDC', 'USDT'),
    ELT(1 + FLOOR(RAND() * 4), 'BTC', 'ETH', 'USDC', 'USDT'),
    CAST(ROUND(RAND() * 1000000, 18) AS DECIMAL(28,18)),
    CAST(ROUND(RAND() * 1000000, 18) AS DECIMAL(28,18))
FROM tmp_numbers;

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
INNER JOIN tb_execucao e ON e.cod_exec = d.cod_exec;

DROP TEMPORARY TABLE tmp_numbers;

COMMIT;
SET FOREIGN_KEY_CHECKS = 1;
