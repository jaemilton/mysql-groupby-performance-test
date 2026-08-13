-- Script para popular tb_chave_natural e tb_execucao_dtl_v3 a partir de tb_execucao_dtl_v2
-- Executar apos insert_1m_execucao.sql

SET FOREIGN_KEY_CHECKS = 0;
SET AUTOCOMMIT = 0;

-- Limpa os dados anteriores para permitir reexecucao
TRUNCATE TABLE tb_chave_natural;
TRUNCATE TABLE tb_execucao_dtl_v3;

-- Popula tb_chave_natural com as combinacoes unicas de tb_execucao_dtl_v2
INSERT INTO tb_chave_natural (
    cod_chave,
    cod_tipo_mov,
    dt_mov,
    cod_ctpt,
    cod_plat,
    cod_fami,
    cod_estr,
    cod_ativ_base,
    cod_ativ_cota
)
SELECT
    ROW_NUMBER() OVER (
        ORDER BY
            cod_tipo_mov, dt_mov, cod_ctpt, cod_plat, cod_fami,
            cod_estr, cod_ativ_base, cod_ativ_cota
    ) AS cod_chave,
    cod_tipo_mov,
    dt_mov,
    cod_ctpt,
    cod_plat,
    cod_fami,
    cod_estr,
    cod_ativ_base,
    cod_ativ_cota
FROM (
    SELECT DISTINCT
        cod_tipo_mov,
        dt_mov,
        cod_ctpt,
        cod_plat,
        cod_fami,
        cod_estr,
        cod_ativ_base,
        cod_ativ_cota
    FROM tb_execucao_dtl_v2
) t;

-- Popula tb_execucao_dtl_v3 ligando cada cod_exec a sua chave natural
INSERT INTO tb_execucao_dtl_v3 (
    cod_exec,
    cod_chave,
    num_qtde,
    vlr_unit
)
SELECT
    v2.cod_exec,
    cn.cod_chave,
    v2.num_qtde,
    v2.vlr_unit
FROM tb_execucao_dtl_v2 v2
INNER JOIN tb_chave_natural cn
    ON cn.cod_tipo_mov = v2.cod_tipo_mov
   AND cn.dt_mov = v2.dt_mov
   AND cn.cod_ctpt = v2.cod_ctpt
   AND cn.cod_plat = v2.cod_plat
   AND cn.cod_fami = v2.cod_fami
   AND IFNULL(cn.cod_estr, -1) = IFNULL(v2.cod_estr, -1)
   AND cn.cod_ativ_base = v2.cod_ativ_base
   AND cn.cod_ativ_cota = v2.cod_ativ_cota;

COMMIT;
SET FOREIGN_KEY_CHECKS = 1;
