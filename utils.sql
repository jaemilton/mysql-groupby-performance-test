select count(*) from test.tb_execucao


select
	*
from test.tb_execucao
WHERE 
	cod_ctpt = 1 AND
	cod_plat = 1  AND
	cod_fami = 1  AND
	cod_tipo_mov = 1  AND
	cod_estr is null  AND
	cod_ativ_base = 'BTC'  AND	 
	cod_ativ_cota = 'BTC'  
	

select DISTINCT 
		cod_ctpt,
		cod_plat,
		cod_fami,
		cod_tipo_mov,
		cod_estr,
		cod_ativ_base,
		cod_ativ_cota
	from test.tb_execucao 
  

select  
	cod_ctpt,
	cod_plat,
	cod_fami,
	cod_tipo_mov,
	cod_estr,
	cod_ativ_base,
	cod_ativ_cota,
	(	
		select
			count(1) as qtde
		from test.tb_execucao
		WHERE 
			cod_ctpt = tb.cod_ctpt AND
			cod_plat = tb.cod_plat  AND
			cod_fami = tb.cod_fami  AND
			cod_tipo_mov = tb.cod_tipo_mov  AND
			cod_estr = tb.cod_estr  AND
			cod_ativ_base = tb.cod_ativ_base  AND	 
			cod_ativ_cota = tb.cod_ativ_cota  
	) as qtde
from (
	select DISTINCT 
		cod_ctpt,
		cod_plat,
		cod_fami,
		cod_tipo_mov,
		cod_estr,
		cod_ativ_base,
		cod_ativ_cota
	from test.tb_execucao 
) tb
  

select * from tb_execucao_agg


EXPLAIN FORMAT=JSON
	select
		cod_ctpt,
		cod_plat,
		cod_fami,
		cod_tipo_mov,
		cod_estr,
		cod_ativ_base,
		cod_ativ_cota,
		count(1) as qtde,
		sum(num_qtde) as num_qtde,
		avg(vlr_unit) as vlr_unit,
		GROUP_CONCAT(cod_exec) 
	from test.tb_execucao 
	group by 
		cod_ctpt,
		cod_plat,
		cod_fami,
		cod_tipo_mov,
		cod_estr,
		cod_ativ_base,
		cod_ativ_cota
		
	
	
	ANALYZE TABLE tb_execucao;
	
select
	cod_ctpt,
	cod_plat,
	cod_fami,
	cod_tipo_mov,
	cod_estr,
	cod_ativ_base,
	cod_ativ_cota,
	count(1) as qtde,
	sum(num_qtde) as num_qtde,
	avg(vlr_unit) as vlr_unit,
	GROUP_CONCAT(cod_exec) 
from test.tb_execucao
WHERE 
	cod_ctpt = 1 AND
	cod_plat = 1  AND
	cod_fami = 1  AND
	cod_tipo_mov = 1  AND
	cod_estr is null  AND
	cod_ativ_base = 'BTC'  AND	 
	cod_ativ_cota = 'BTC'  
group by 
	cod_ctpt,
	cod_plat,
	cod_fami,
	cod_tipo_mov,
	cod_estr,
	cod_ativ_base,
	cod_ativ_cota

