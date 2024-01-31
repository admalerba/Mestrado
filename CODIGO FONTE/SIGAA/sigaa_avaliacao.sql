select
--dados pessoais
  --P.ID_PESSOA,
  COALESCE(P.CPF_CNPJ, 0) as doc,
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
  d.status in (1,8,9)
  /*  Status do Discente
    -1	"DESCONHECIDO"
    1	"ATIVO"
    2	"CADASTRADO"
    3	"CONCLUÍDO"
    5	"TRANCADO"
    6	"CANCELADO"
    10	"NÃO CADASTRADO"
    8	"ATIVO - FORMANDO"
    9	"ATIVO - GRADUANDO"
    11	"EM HOMOLOGAÇÃO"
    12	"DEFENDIDO"
    13	"PENDENTE DE CADASTRO"
    14	"ATIVO - DEPENDÊNCIA"
  */
  and d.ano_ingresso >= 2013
  and d.nivel = 'G'
  --and C.nome = 'ENGENHARIA DE CONTROLE E AUTOMAÇÃO'
  and d.ano_ingresso is not null
  and DATE_PART('year',p.data_nascimento) > 1900
  and c.id_modalidade_educacao=1
  and d.periodo_atual is not null
  and (select avg(valor) as media_IECH from ensino.indice_academico_discente_historico where id_indice_academico = 4 and id_discente = d.id_discente) is not null
order by d.ano_ingresso, d.matricula