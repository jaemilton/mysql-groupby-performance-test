SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS tb_chave_natural;
DROP TABLE IF EXISTS tb_execucao;
DROP TABLE IF EXISTS tb_execucao_dtl;
DROP TABLE IF EXISTS tb_execucao_dtl_v2;
DROP TABLE IF EXISTS tb_execucao_dtl_v3;
DROP TABLE IF EXISTS tb_tipo_mov;
DROP TABLE IF EXISTS tb_fami;
DROP TABLE IF EXISTS tb_plat;
DROP TABLE IF EXISTS tb_ctpt;
DROP TABLE IF EXISTS tb_ativ;

SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE tb_ctpt (
    cod_ctpt INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    nom_ctpt VARCHAR(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE tb_plat (
    cod_plat INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    nom_plat VARCHAR(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE tb_fami (
    cod_fami INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    nom_fami VARCHAR(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE tb_tipo_mov (
    cod_tipo_mov INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    nom_tipo_mov VARCHAR(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE tb_ativ (
    cod_ativ varchar(10) NOT NULL PRIMARY KEY
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE tb_chave_natural (
    cod_chave INT NOT NULL PRIMARY KEY,
    cod_tipo_mov INT NOT NULL,
    dt_mov DATE NOT NULL,
    cod_ctpt INT NOT NULL,
    cod_plat INT NOT NULL,
    cod_fami INT NOT NULL,
    cod_estr INT NULL,
    cod_ativ_base VARCHAR(10) NOT NULL,
    cod_ativ_cota VARCHAR(10) NOT NULL,
    CONSTRAINT fk_chave_natural_tipo_mov FOREIGN KEY (cod_tipo_mov) REFERENCES tb_tipo_mov(cod_tipo_mov),
    CONSTRAINT fk_chave_natural_ctpt FOREIGN KEY (cod_ctpt) REFERENCES tb_ctpt(cod_ctpt),
    CONSTRAINT fk_chave_natural_plat FOREIGN KEY (cod_plat) REFERENCES tb_plat(cod_plat),
    CONSTRAINT fk_chave_natural_fami FOREIGN KEY (cod_fami) REFERENCES tb_fami(cod_fami),
    CONSTRAINT fk_chave_natural_ativ_base FOREIGN KEY (cod_ativ_base) REFERENCES tb_ativ(cod_ativ),
    CONSTRAINT fk_chave_natural_ativ_cota FOREIGN KEY (cod_ativ_cota) REFERENCES tb_ativ(cod_ativ),
    UNIQUE KEY idx_tb_chave_natural_group (
        cod_tipo_mov, dt_mov, cod_ctpt, cod_plat, cod_fami, cod_estr,
        cod_ativ_base, cod_ativ_cota
    )
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;



CREATE TABLE tb_execucao
(
    cod_exec BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    cod_cttc INT NULL,
    cod_tipo_mov INT NOT NULL,
    cod_oper_orig CHAR(20) NOT NULL,
    dt_mov DATE NOT NULL,
    CONSTRAINT fk_execucao_tipo_mov FOREIGN KEY (cod_tipo_mov) REFERENCES tb_tipo_mov(cod_tipo_mov)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE tb_execucao_dtl (
    cod_exec BIGINT NOT NULL PRIMARY KEY,
    cod_ctpt INT NOT NULL,
    cod_plat INT NOT NULL,
    cod_fami INT NOT NULL,
    cod_estr INT NULL,
    cod_ativ_base VARCHAR(10) NOT NULL,
    cod_ativ_cota VARCHAR(10) NOT NULL,
    num_qtde DECIMAL(28,18) NOT NULL,
    vlr_unit DECIMAL(28,18) NOT NULL,
    CONSTRAINT fk_execucao_exec FOREIGN KEY (cod_exec) REFERENCES tb_execucao(cod_exec),
    CONSTRAINT fk_execucao_ctpt FOREIGN KEY (cod_ctpt) REFERENCES tb_ctpt(cod_ctpt),
    CONSTRAINT fk_execucao_plat FOREIGN KEY (cod_plat) REFERENCES tb_plat(cod_plat),
    CONSTRAINT fk_execucao_fami FOREIGN KEY (cod_fami) REFERENCES tb_fami(cod_fami),
    CONSTRAINT fk_execucao_ativ_base FOREIGN KEY (cod_ativ_base) REFERENCES tb_ativ(cod_ativ),
    CONSTRAINT fk_execucao_ativ_cota FOREIGN KEY (cod_ativ_cota) REFERENCES tb_ativ(cod_ativ),
    KEY idx_tb_execucao_group (
        cod_ctpt, cod_plat, cod_fami, cod_estr,
        cod_ativ_base, cod_ativ_cota, num_qtde, vlr_unit
    )
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE tb_execucao_dtl_v2 (
    cod_exec BIGINT NOT NULL PRIMARY KEY,
    -- campos replicados da tabela tb_execucao
    cod_tipo_mov INT NOT NULL,
    dt_mov DATE NOT NULL,
    -- campos da tabela tb_execucao_dtl
    cod_ctpt INT NOT NULL,
    cod_plat INT NOT NULL,
    cod_fami INT NOT NULL,
    cod_estr INT NULL,
    cod_ativ_base VARCHAR(10) NOT NULL,
    cod_ativ_cota VARCHAR(10) NOT NULL,
    num_qtde DECIMAL(28,18) NOT NULL,
    vlr_unit DECIMAL(28,18) NOT NULL,
    CONSTRAINT fk_execucao_v2_tipo_mov FOREIGN KEY (cod_tipo_mov) REFERENCES tb_tipo_mov(cod_tipo_mov),
    CONSTRAINT fk_execucao_v2_exec FOREIGN KEY (cod_exec) REFERENCES tb_execucao(cod_exec),
    CONSTRAINT fk_execucao_v2_ctpt FOREIGN KEY (cod_ctpt) REFERENCES tb_ctpt(cod_ctpt),
    CONSTRAINT fk_execucao_v2_plat FOREIGN KEY (cod_plat) REFERENCES tb_plat(cod_plat),
    CONSTRAINT fk_execucao_v2_fami FOREIGN KEY (cod_fami) REFERENCES tb_fami(cod_fami),
    CONSTRAINT fk_execucao_v2_ativ_base FOREIGN KEY (cod_ativ_base) REFERENCES tb_ativ(cod_ativ),
    CONSTRAINT fk_execucao_v2_ativ_cota FOREIGN KEY (cod_ativ_cota) REFERENCES tb_ativ(cod_ativ),
    KEY idx_tb_execucao_group (
        cod_tipo_mov, dt_mov, cod_ctpt, cod_plat, cod_fami, cod_estr,
        cod_ativ_base, cod_ativ_cota, num_qtde, vlr_unit
    )
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;



CREATE TABLE tb_execucao_dtl_v3 (
    cod_exec BIGINT NOT NULL PRIMARY KEY,
    -- campos replicados da tabela tb_execucao
    cod_chave INT NOT NULL,
    num_qtde DECIMAL(28,18) NOT NULL,
    vlr_unit DECIMAL(28,18) NOT NULL,
    CONSTRAINT fk_execucao_v3_chave FOREIGN KEY (cod_chave) REFERENCES tb_chave_natural(cod_chave),
    CONSTRAINT fk_execucao_v3_exec FOREIGN KEY (cod_exec) REFERENCES tb_execucao(cod_exec),
    KEY idx_tb_execucao_group (
        cod_chave, num_qtde, vlr_unit
    )
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;



INSERT INTO tb_ativ (cod_ativ) VALUES
	 ('BTC'),
	 ('ETH'),
	 ('USDC'),
	 ('USDT');

INSERT INTO tb_ctpt (nom_ctpt) VALUES
	 ('COINBASE'),
	 ('GALAXY'),
	 ('HIDDEN_ROAD'),
	 ('OKX');

INSERT INTO tb_fami (nom_fami) VALUES
	 ('SPOT'),
	 ('FUTUROS_PERPETUOS');


INSERT INTO tb_plat (nom_plat) VALUES
	 ('COINBASE'),
	 ('GALAXY'),
	 ('HIDDEN_ROAD');

INSERT INTO tb_tipo_mov (nom_tipo_mov) VALUES
	 ('Compra'),
	 ('Venda'),
	 ('Trading Fee');


ALTER TABLE tb_execucao AUTO_INCREMENT = 10000000;