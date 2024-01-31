select
--dados pessoais
  --P.ID_PESSOA,
  --COALESCE(P.CPF_CNPJ, 0) as doc,
  lpad( '' || p.cpf_cnpj, 11, '0') as doc,
  -- D.ID_DISCENTE,
  -- p.nome, 
  -- COALESCE(p.email, '') as Email,
  -- P.NOME_MAE,
  -- P.NOME_PAI,
  case when p.sexo = 'F' then 2 else 1 end as sexo,
  -- p.cidade,
  -- p.uf,
  -- p.cep,
  p.id_raca as raca,
  p.id_estado_civil as Estado_civil,
  -- p.id_tipo_necessidade_especial,
  -- p.escola_publica,
  (make_date(d.ano_ingresso,6*(d.periodo_ingresso-1)+1,1) - p.data_nascimento)/365 as idade,
  -- p.data_nascimento,
-- dados Discente
  -- d.matricula,
  d.ano_ingresso,
  d.periodo_ingresso,
  d.prazo_conclusao,
  -- d.data_colacao_grau,
  d.periodo_atual,
  --FI.descricao as Forma_Ingresso,
  d.id_forma_ingresso,
  -- d.formando,
  --case when cam.nome is not null then 1 else 2 end as id_campus,
  c.id_campus,
  -- c.nome As curso,
  d.id_curso,
  -- mend.nome as Cidade_Naturalidade,
  -- uf.sigla as Estado_Naturalidade,
  (select avg(valor) as media_IEA from ensino.indice_academico_discente_historico where id_indice_academico = 6 and id_discente = d.id_discente),
  (select avg(valor) as media_IRA from ensino.indice_academico_discente_historico where id_indice_academico = 2 and id_discente = d.id_discente),
  (select avg(valor) as media_IEPL from ensino.indice_academico_discente_historico where id_indice_academico = 5 and id_discente = d.id_discente),
  (select avg(valor) as media_IECH from ensino.indice_academico_discente_historico where id_indice_academico = 4 and id_discente = d.id_discente),
  --(select avg(valor) as media_CR from ensino.indice_academico_discente_historico where id_indice_academico = 8 and id_discente = d.id_discente),

-- soma da ch de disciplinas aprovadas
   COALESCE(
        (SELECT round((sum(cd.ch_total)), 2 )  
           FROM ensino.matricula_componente mc
                    join ensino.componente_curricular cc on (cc.id_disciplina = mc.id_componente_curricular)
                    join ensino.componente_curricular_detalhes cd on (cd.id_componente_detalhes = mc.id_componente_detalhes)  
           WHERE mc.id_discente = d.id_discente
                 AND mc.id_componente_curricular = cc.id_disciplina                  
                 AND mc.id_situacao_matricula IN ( 4 )  -- APROVADO   
                 AND mc.id_componente_detalhes = cd.id_componente_detalhes    
                 --and mc.ano = 2019 and mc.periodo = 2 
                 and cc.id_tipo_componente = 2 -- DISCIPLINA
            ),0.0) as ch_disciplinas_aprovadas,
-- soma de qtde disciplinas aprovadas
   COALESCE(
        (SELECT (count(mc.id_matricula_componente))  
           FROM ensino.matricula_componente mc
                    join ensino.componente_curricular cc on (cc.id_disciplina = mc.id_componente_curricular)
                    join ensino.componente_curricular_detalhes cd on (cd.id_componente_detalhes = mc.id_componente_detalhes)  
           WHERE mc.id_discente = d.id_discente
                 AND mc.id_componente_curricular = cc.id_disciplina                  
                 AND mc.id_situacao_matricula IN ( 4 )  -- APROVADO   
                 AND mc.id_componente_detalhes = cd.id_componente_detalhes    
                 --and mc.ano = 2019 and mc.periodo = 2 
                 and cc.id_tipo_componente = 2 -- DISCIPLINA
            ),0) as qtde_disciplinas_Aprovadas,
			
-- soma da ch de disciplinas REP. FALTA
   COALESCE(
        (SELECT round((sum(cd.ch_total)), 2 )  
           FROM ensino.matricula_componente mc
                    join ensino.componente_curricular cc on (cc.id_disciplina = mc.id_componente_curricular)
                    join ensino.componente_curricular_detalhes cd on (cd.id_componente_detalhes = mc.id_componente_detalhes)  
           WHERE mc.id_discente = d.id_discente
                 AND mc.id_componente_curricular = cc.id_disciplina                  
                 AND mc.id_situacao_matricula IN ( 7 )  -- REP. FALTA   
                 AND mc.id_componente_detalhes = cd.id_componente_detalhes    
                 --and mc.ano = 2019 and mc.periodo = 2 
                 and cc.id_tipo_componente = 2 -- DISCIPLINA
            ),0.0) as ch_disciplinas_REPF,
			
-- soma de Qtde disciplinas REP. FALTA	
   COALESCE(
        (SELECT (count(cd.ch_total))
           FROM ensino.matricula_componente mc
                    join ensino.componente_curricular cc on (cc.id_disciplina = mc.id_componente_curricular)
                    join ensino.componente_curricular_detalhes cd on (cd.id_componente_detalhes = mc.id_componente_detalhes)  
           WHERE mc.id_discente = d.id_discente
                 AND mc.id_componente_curricular = cc.id_disciplina                  
                 AND mc.id_situacao_matricula IN ( 7 )  -- REP. FALTA
                 AND mc.id_componente_detalhes = cd.id_componente_detalhes    
                 --and mc.ano = 2019 and mc.periodo = 2 
                 and cc.id_tipo_componente = 2 -- DISCIPLINA
            ),0) as qtde_disciplinas_REPF,

-- soma da ch de disciplinas REP. NOTA
   COALESCE(
        (SELECT round((sum(cd.ch_total)), 2 )  
           FROM ensino.matricula_componente mc
                    join ensino.componente_curricular cc on (cc.id_disciplina = mc.id_componente_curricular)
                    join ensino.componente_curricular_detalhes cd on (cd.id_componente_detalhes = mc.id_componente_detalhes)  
           WHERE mc.id_discente = d.id_discente
                 AND mc.id_componente_curricular = cc.id_disciplina                  
                 AND mc.id_situacao_matricula IN ( 25 )  -- REP. FALTA   
                 AND mc.id_componente_detalhes = cd.id_componente_detalhes    
                 --and mc.ano = 2019 and mc.periodo = 2 
                 and cc.id_tipo_componente = 2 -- DISCIPLINA
            ),0.0) as ch_disciplinas_REPN,
			
-- soma de Qtde disciplinas REP. NOTA	
   COALESCE(
        (SELECT (count(cd.ch_total))
           FROM ensino.matricula_componente mc
                    join ensino.componente_curricular cc on (cc.id_disciplina = mc.id_componente_curricular)
                    join ensino.componente_curricular_detalhes cd on (cd.id_componente_detalhes = mc.id_componente_detalhes)  
           WHERE mc.id_discente = d.id_discente
                 AND mc.id_componente_curricular = cc.id_disciplina                  
                 AND mc.id_situacao_matricula IN ( 25 )  -- REP. FALTA
                 AND mc.id_componente_detalhes = cd.id_componente_detalhes    
                 --and mc.ano = 2019 and mc.periodo = 2 
                 and cc.id_tipo_componente = 2 -- DISCIPLINA
            ),0) as qtde_disciplinas_REPN,

-- soma da ch de disciplinas TRANCADA
   COALESCE(
        (SELECT round((sum(cd.ch_total)), 2 )  
           FROM ensino.matricula_componente mc
                    join ensino.componente_curricular cc on (cc.id_disciplina = mc.id_componente_curricular)
                    join ensino.componente_curricular_detalhes cd on (cd.id_componente_detalhes = mc.id_componente_detalhes)  
           WHERE mc.id_discente = d.id_discente
                 AND mc.id_componente_curricular = cc.id_disciplina                  
                 AND mc.id_situacao_matricula IN ( 5 )  -- TRANCADA   
                 AND mc.id_componente_detalhes = cd.id_componente_detalhes    
                 --and mc.ano = 2019 and mc.periodo = 2 
                 and cc.id_tipo_componente = 2 -- DISCIPLINA
            ),0.0) as ch_disciplinas_TRANCADA,
			
   COALESCE(
        (SELECT (count(cd.ch_total))
           FROM ensino.matricula_componente mc
                    join ensino.componente_curricular cc on (cc.id_disciplina = mc.id_componente_curricular)
                    join ensino.componente_curricular_detalhes cd on (cd.id_componente_detalhes = mc.id_componente_detalhes)  
           WHERE mc.id_discente = d.id_discente
                 AND mc.id_componente_curricular = cc.id_disciplina                  
                 AND mc.id_situacao_matricula IN ( 5 )  -- TRANCADA
                 AND mc.id_componente_detalhes = cd.id_componente_detalhes    
                 --and mc.ano = 2019 and mc.periodo = 2 
                 and cc.id_tipo_componente = 2 -- DISCIPLINA
            ),0) as qtde_disciplinas_TRANCADA,
-- soma da ch de disciplinas CANCELADA
   COALESCE(
        (SELECT round((sum(cd.ch_total)), 2 )  
           FROM ensino.matricula_componente mc
                    join ensino.componente_curricular cc on (cc.id_disciplina = mc.id_componente_curricular)
                    join ensino.componente_curricular_detalhes cd on (cd.id_componente_detalhes = mc.id_componente_detalhes)  
           WHERE mc.id_discente = d.id_discente
                 AND mc.id_componente_curricular = cc.id_disciplina                  
                 AND mc.id_situacao_matricula IN ( 3 )  -- CANCELADA   
                 AND mc.id_componente_detalhes = cd.id_componente_detalhes    
                 --and mc.ano = 2019 and mc.periodo = 2 
                 and cc.id_tipo_componente = 2 -- DISCIPLINA
            ),0.0) as ch_disciplinas_CANCELADA,
			
   COALESCE(
        (SELECT (count(cd.ch_total))
           FROM ensino.matricula_componente mc
                    join ensino.componente_curricular cc on (cc.id_disciplina = mc.id_componente_curricular)
                    join ensino.componente_curricular_detalhes cd on (cd.id_componente_detalhes = mc.id_componente_detalhes)  
           WHERE mc.id_discente = d.id_discente
                 AND mc.id_componente_curricular = cc.id_disciplina                  
                 AND mc.id_situacao_matricula IN ( 3 )  -- CANCELADA
                 AND mc.id_componente_detalhes = cd.id_componente_detalhes    
                 --and mc.ano = 2019 and mc.periodo = 2 
                 and cc.id_tipo_componente = 2 -- DISCIPLINA
            ),0) as qtde_disciplinas_CANCELADA,
  case when d.status = 3 then 0 else 1 end as status
  -- sd.descricao as Status
			

from
  comum.pessoa p 
  join discente d using (id_pessoa)
  left join curso c using (id_curso)  
  --left join comum.campus_ies cam using (id_campus)   
  left join ensino.forma_ingresso FI using(id_forma_ingresso)
  left join public.status_discente sd using(status)
  left join comum.unidade_federativa uf on uf.id_unidade_federativa = p.id_uf_naturalidade
  left join comum.municipio mend on mend.id_municipio = p.id_municipio_naturalidade
--  left join ensino.indice_academico_discente_historico iah using(id_discente)
--  inner join ensino.indice_academico ia on (iah.id_indice_academico = ia.id)
Where
  d.status in (3,5,6,12) -- Concluído, Trancado, Cancelado, Defendido
  and d.ano_ingresso >= 2013
  and d.nivel = 'G'
  --and C.nome = 'ENGENHARIA DE CONTROLE E AUTOMA��O'
  and d.ano_ingresso is not null
  and DATE_PART('year',p.data_nascimento) > 1900
  and c.id_modalidade_educacao=1
  and d.periodo_atual is not null
  and (select avg(valor) as media_IECH from ensino.indice_academico_discente_historico where id_indice_academico = 4 and id_discente = d.id_discente) is not null
order by d.ano_ingresso, d.matricula