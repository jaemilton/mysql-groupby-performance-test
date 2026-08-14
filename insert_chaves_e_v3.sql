-- Script otimizado para extração de chaves naturais e carga v3
SET FOREIGN_KEY_CHECKS = 0;
SET UNIQUE_CHECKS = 0;
SET AUTOCOMMIT = 0;

-- Altera temporariamente para evitar travas de leitura na v2
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;

-- Limpa os dados anteriores
TRUNCATE TABLE tb_chave_natural;
TRUNCATE TABLE tb_execucao_dtl_v3;

-- 1. Popula tb_chave_natural aproveitando o AUTO_INCREMENT (removido ROW_NUMBER)
-- Se cod_chave NÃO for auto_increment, mantenha o ROW_NUMBER mas sem o ORDER BY gigante.
INSERT INTO tb_chave_natural (
    cod_tipo_mov,
    dt_mov,
    cod_ctpt,
    cod_plat,
    cod_fami,
    cod_estr,
    cod_ativ_base,
    cod_ativ_cota
)
SELECT DISTINCT
    cod_tipo_mov,
    dt_mov,
    cod_ctpt,
    cod_plat,
    cod_fami,
    cod_estr,
    cod_ativ_base,
    cod_ativ_cota
FROM tb_execucao_dtl_v2;

COMMIT; -- Garante a gravação física das chaves e índices da tb_chave_natural

-- 2. Popula tb_execucao_dtl_v3 (Otimizado com operador IS NOT DISTINCT FROM / <=> )
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
   AND IFNULL(cn.cod_ativ_cota, -1) = IFNULL(v2.cod_ativ_cota, -1)
WHERE v2.cod_exec > 9999999; -- Filtro crucial para usar o índice da Primary Key!
  
COMMIT;

-- Restaurar configurações
SET FOREIGN_KEY_CHECKS = 1;
SET UNIQUE_CHECKS = 1;
SET AUTOCOMMIT = 1;
