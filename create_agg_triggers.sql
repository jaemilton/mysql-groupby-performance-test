-- Tabela agregada para manter totais por grupo
DROP TABLE IF EXISTS tb_execucao_agg;

CREATE TABLE tb_execucao_agg (
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    cod_ctpt INT NOT NULL,
    cod_plat INT NOT NULL,
    cod_fami INT NOT NULL,
    cod_estr INT NULL,
    cod_ativ_base VARCHAR(10) NOT NULL,
    cod_ativ_cota VARCHAR(10) NOT NULL,
    qtde BIGINT NOT NULL DEFAULT 0,
    num_qtde DECIMAL(38,18) NOT NULL DEFAULT 0,
    vlr_unit_sum DECIMAL(38,18) NOT NULL DEFAULT 0,
    vlr_unit_count BIGINT NOT NULL DEFAULT 0,
    vlr_unit DECIMAL(38,18) AS (vlr_unit_sum / vlr_unit_count) VIRTUAL,
    codigos LONGTEXT,
    UNIQUE KEY uk_execucao_agg (
        cod_ctpt, cod_plat, cod_fami, cod_estr,
        cod_ativ_base, cod_ativ_cota
    )
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TRIGGER IF EXISTS trg_execucao_dtl_insert;
DROP TRIGGER IF EXISTS trg_execucao_dtl_delete;
DROP TRIGGER IF EXISTS trg_execucao_dtl_update;

DELIMITER $$

CREATE TRIGGER trg_execucao_dtl_insert
AFTER INSERT ON tb_execucao_dtl
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1 FROM tb_execucao_agg
        WHERE cod_ctpt = NEW.cod_ctpt
          AND cod_plat = NEW.cod_plat
          AND cod_fami = NEW.cod_fami
          AND IFNULL(cod_estr, -1) = IFNULL(NEW.cod_estr, -1)
          AND cod_ativ_base = NEW.cod_ativ_base
          AND cod_ativ_cota = NEW.cod_ativ_cota
    ) THEN
        UPDATE tb_execucao_agg
        SET
            qtde = qtde + 1,
            num_qtde = num_qtde + NEW.num_qtde,
            vlr_unit_sum = vlr_unit_sum + NEW.vlr_unit,
            vlr_unit_count = vlr_unit_count + 1,
            codigos = CONCAT(codigos, ',', CAST(NEW.cod_exec AS CHAR))
        WHERE
            cod_ctpt = NEW.cod_ctpt
            AND cod_plat = NEW.cod_plat
            AND cod_fami = NEW.cod_fami
            AND IFNULL(cod_estr, -1) = IFNULL(NEW.cod_estr, -1)
            AND cod_ativ_base = NEW.cod_ativ_base
            AND cod_ativ_cota = NEW.cod_ativ_cota;
    ELSE
        INSERT INTO tb_execucao_agg (
            cod_ctpt, cod_plat, cod_fami, cod_estr,
            cod_ativ_base, cod_ativ_cota, qtde, num_qtde,
            vlr_unit_sum, vlr_unit_count, codigos
        )
        VALUES (
            NEW.cod_ctpt, NEW.cod_plat, NEW.cod_fami, NEW.cod_estr,
            NEW.cod_ativ_base, NEW.cod_ativ_cota,
            1, NEW.num_qtde, NEW.vlr_unit, 1,
            CAST(NEW.cod_exec AS CHAR)
        );
    END IF;
END$$

CREATE TRIGGER trg_execucao_dtl_delete
AFTER DELETE ON tb_execucao_dtl
FOR EACH ROW
BEGIN
    DECLARE v_codigos LONGTEXT;

    UPDATE tb_execucao_agg
    SET
        qtde = qtde - 1,
        num_qtde = num_qtde - OLD.num_qtde,
        vlr_unit_sum = vlr_unit_sum - OLD.vlr_unit,
        vlr_unit_count = vlr_unit_count - 1
    WHERE
        cod_ctpt = OLD.cod_ctpt
        AND cod_plat = OLD.cod_plat
        AND cod_fami = OLD.cod_fami
        AND IFNULL(cod_estr, -1) = IFNULL(OLD.cod_estr, -1)
        AND cod_ativ_base = OLD.cod_ativ_base
        AND cod_ativ_cota = OLD.cod_ativ_cota;

    SELECT GROUP_CONCAT(cod_exec) INTO v_codigos
    FROM tb_execucao_dtl
    WHERE
        cod_ctpt = OLD.cod_ctpt
        AND cod_plat = OLD.cod_plat
        AND cod_fami = OLD.cod_fami
        AND IFNULL(cod_estr, -1) = IFNULL(OLD.cod_estr, -1)
        AND cod_ativ_base = OLD.cod_ativ_base
        AND cod_ativ_cota = OLD.cod_ativ_cota;

    UPDATE tb_execucao_agg
    SET codigos = v_codigos
    WHERE
        cod_ctpt = OLD.cod_ctpt
        AND cod_plat = OLD.cod_plat
        AND cod_fami = OLD.cod_fami
        AND IFNULL(cod_estr, -1) = IFNULL(OLD.cod_estr, -1)
        AND cod_ativ_base = OLD.cod_ativ_base
        AND cod_ativ_cota = OLD.cod_ativ_cota;

    DELETE FROM tb_execucao_agg
    WHERE
        cod_ctpt = OLD.cod_ctpt
        AND cod_plat = OLD.cod_plat
        AND cod_fami = OLD.cod_fami
        AND IFNULL(cod_estr, -1) = IFNULL(OLD.cod_estr, -1)
        AND cod_ativ_base = OLD.cod_ativ_base
        AND cod_ativ_cota = OLD.cod_ativ_cota
        AND qtde = 0;
END$$

CREATE TRIGGER trg_execucao_dtl_update
AFTER UPDATE ON tb_execucao_dtl
FOR EACH ROW
BEGIN
    DECLARE v_codigos LONGTEXT;

    IF (NEW.cod_ctpt <> OLD.cod_ctpt
        OR NEW.cod_plat <> OLD.cod_plat
        OR NEW.cod_fami <> OLD.cod_fami
        OR IFNULL(NEW.cod_estr, -1) <> IFNULL(OLD.cod_estr, -1)
        OR NEW.cod_ativ_base <> OLD.cod_ativ_base
        OR NEW.cod_ativ_cota <> OLD.cod_ativ_cota)
    THEN
        -- Remove do grupo antigo
        UPDATE tb_execucao_agg
        SET
            qtde = qtde - 1,
            num_qtde = num_qtde - OLD.num_qtde,
            vlr_unit_sum = vlr_unit_sum - OLD.vlr_unit,
            vlr_unit_count = vlr_unit_count - 1
        WHERE
            cod_ctpt = OLD.cod_ctpt
            AND cod_plat = OLD.cod_plat
            AND cod_fami = OLD.cod_fami
            AND IFNULL(cod_estr, -1) = IFNULL(OLD.cod_estr, -1)
            AND cod_ativ_base = OLD.cod_ativ_base
            AND cod_ativ_cota = OLD.cod_ativ_cota;

        SELECT GROUP_CONCAT(cod_exec) INTO v_codigos
        FROM tb_execucao_dtl
        WHERE
            cod_ctpt = OLD.cod_ctpt
            AND cod_plat = OLD.cod_plat
            AND cod_fami = OLD.cod_fami
            AND IFNULL(cod_estr, -1) = IFNULL(OLD.cod_estr, -1)
            AND cod_ativ_base = OLD.cod_ativ_base
            AND cod_ativ_cota = OLD.cod_ativ_cota;

        UPDATE tb_execucao_agg
        SET codigos = v_codigos
        WHERE
            cod_ctpt = OLD.cod_ctpt
            AND cod_plat = OLD.cod_plat
            AND cod_fami = OLD.cod_fami
            AND IFNULL(cod_estr, -1) = IFNULL(OLD.cod_estr, -1)
            AND cod_ativ_base = OLD.cod_ativ_base
            AND cod_ativ_cota = OLD.cod_ativ_cota;

        DELETE FROM tb_execucao_agg
        WHERE
            cod_ctpt = OLD.cod_ctpt
            AND cod_plat = OLD.cod_plat
            AND cod_fami = OLD.cod_fami
            AND IFNULL(cod_estr, -1) = IFNULL(OLD.cod_estr, -1)
            AND cod_ativ_base = OLD.cod_ativ_base
            AND cod_ativ_cota = OLD.cod_ativ_cota
            AND qtde = 0;

        IF EXISTS (
            SELECT 1 FROM tb_execucao_agg
            WHERE cod_ctpt = NEW.cod_ctpt
              AND cod_plat = NEW.cod_plat
              AND cod_fami = NEW.cod_fami
              AND IFNULL(cod_estr, -1) = IFNULL(NEW.cod_estr, -1)
              AND cod_ativ_base = NEW.cod_ativ_base
              AND cod_ativ_cota = NEW.cod_ativ_cota
        ) THEN
            UPDATE tb_execucao_agg
            SET
                qtde = qtde + 1,
                num_qtde = num_qtde + NEW.num_qtde,
                vlr_unit_sum = vlr_unit_sum + NEW.vlr_unit,
                vlr_unit_count = vlr_unit_count + 1,
                codigos = CONCAT(codigos, ',', CAST(NEW.cod_exec AS CHAR))
            WHERE
                cod_ctpt = NEW.cod_ctpt
                AND cod_plat = NEW.cod_plat
                AND cod_fami = NEW.cod_fami
                AND IFNULL(cod_estr, -1) = IFNULL(NEW.cod_estr, -1)
                AND cod_ativ_base = NEW.cod_ativ_base
                AND cod_ativ_cota = NEW.cod_ativ_cota;
        ELSE
            INSERT INTO tb_execucao_agg (
                cod_ctpt, cod_plat, cod_fami, cod_estr,
                cod_ativ_base, cod_ativ_cota, qtde, num_qtde,
                vlr_unit_sum, vlr_unit_count, codigos
            )
            VALUES (
                NEW.cod_ctpt, NEW.cod_plat, NEW.cod_fami, NEW.cod_estr,
                NEW.cod_ativ_base, NEW.cod_ativ_cota,
                1, NEW.num_qtde, NEW.vlr_unit, 1,
                CAST(NEW.cod_exec AS CHAR)
            );
        END IF;
    ELSE
        -- Atualiza valores no mesmo grupo
        UPDATE tb_execucao_agg
        SET
            num_qtde = num_qtde - OLD.num_qtde + NEW.num_qtde,
            vlr_unit_sum = vlr_unit_sum - OLD.vlr_unit + NEW.vlr_unit
        WHERE
            cod_ctpt = NEW.cod_ctpt
            AND cod_plat = NEW.cod_plat
            AND cod_fami = NEW.cod_fami
            AND IFNULL(cod_estr, -1) = IFNULL(NEW.cod_estr, -1)
            AND cod_ativ_base = NEW.cod_ativ_base
            AND cod_ativ_cota = NEW.cod_ativ_cota;
    END IF;
END$$

DELIMITER ;
