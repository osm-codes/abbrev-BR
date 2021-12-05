COPY (
  select  jurisd_local_id, parent_abbrev, abbrev, name, lexlabel
  from optim.jurisdiction where jurisd_base_id=76
) TO '/tmp/jurisdSummary-BR.csv' CSV HEADER;
-- COPY 5598

-- LOAD
CREATE TABLE jurabbrev_aux (
 jurisd_local_id bigint, parent_abbrev text, abbrev text, name text, lexlabel text
);
COPY jurabbrev_aux
FROM '/tmp/jurisdSummary-BR.csv' CSV HEADER
;

CREATE TABLE jurabbrev (
  ibge_id bigint,name text,abbrev text,tinha text,tinha_score text,regra text
);
SELECT copy_from_csvfolder('jurabbrev', '/tmp/jurisdAbbrev-BR')
;

-- ANALYSIS:
SELECT COUNT(*) FROM jurabbrev
;
SELECT COUNT(*)
FROM jurabbrev j INNER JOIN  jurabbrev_aux a
     ON a.jurisd_local_id=j.ibge_id
;
DROP VIEW IF EXISTS vw_jurabbrev
;
CREATE VIEW vw_jurabbrev AS
 SELECT a.*, iif(a.abbrev=j.abbrev,'',j.abbrev) as abbrev_new,
        j.tinha_score,
        j.regra,
        iif(j.abbrev>'',j.abbrev,a.abbrev) as abbrevx
 FROM jurabbrev j INNER JOIN  jurabbrev_aux a ON a.jurisd_local_id=j.ibge_id
;

DROP VIEW IF EXISTS vw_judisdiction_abbrev
;
CREATE VIEW vw_judisdiction_abbrev AS
 SELECT -- 76 as country_num,
        parent_abbrev AS subdivision_code,
        jurisd_local_id as local_num,
        name,
        abbrevx AS abbrev,
        abbrev_source,
        lexlabel as kx_lexlabel,
        str_abbrev_minscore(abbrevx,name,lexlabel,tinha_score) AS kx_abbrev_score,
        regra AS kx_abbrev_rule
 FROM (
    SELECT a.*,
        CASE WHEN a.parent_abbrev='SP' THEN 2 WHEN a.abbrev=j.abbrev THEN 3 ELSE 1 END AS abbrev_source,
        iif(a.abbrev=j.abbrev,'',j.abbrev) as abbrev_new,
        j.tinha_score,
        j.regra,
        iif(j.abbrev>'',j.abbrev,a.abbrev) as abbrevx
    FROM jurabbrev j RIGHT JOIN  jurabbrev_aux a ON a.jurisd_local_id=j.ibge_id
 ) t
 ORDER BY 1
;-- COPY (select * from vw_judisdiction_abbrev order by 1,2) to '/tmp/judisdiction_abbrev.csv' CSV HEADER

-- Relatórios de falhas:
--

-- Duplicados:
SELECT parent_abbrev, abbrevx, array_agg(name) as duplicados
FROM vw_jurabbrev WHERE abbrevx>'' GROUP BY 1,2 HAVING COUNT(*)>1 ORDER BY 1,2
;

-- Etc
-- SELECT abbrevx, name, str_abbrev_minscore(abbrevx,name,lexlabel) as score FROM vw_jurabbrev;
-- SELECT parent_abbrev, abbrev, name, str_abbrev_minscore(abbrev,name,lexlabel) as score FROM jurabbrev_aux order by 4 desc, 1,2;
-- copy (select * from vw_jurabbrev2) to '/tmp/jurabbrev2.csv' CSV header;

-- Letras geral:
select p, count(*) FROM (
  select  regexp_split_to_table(translate(lexlabel,'.',''),'') p
  from jurabbrev_aux
) t group by 1 having count(*) > 1 order by 2 desc, 1
;
-- Letras por estado:
select parent_abbrev, p, count(*) FROM (
  select parent_abbrev, regexp_split_to_table(translate(lexlabel,'.',''),'') p
  from jurabbrev_aux
) t group by 1,2 having count(*) > 1 order by 1,3 desc, 2
;
-- Palavras geral:
select p, count(*) FROM (
  select  regexp_split_to_table(lexlabel,'\.') palavra
  from jurabbrev_aux
) t group by 1 having count(*) > 1 order by 2 desc, 1;
-- Palavras por estado e restringindo a limite:
select parent_abbrev, p, count(*) FROM (
  select parent_abbrev, regexp_split_to_table(lexlabel,'\.') palavra
  from jurabbrev_aux
) t group by 1,2 having count(*) > 1 order by 1,3 desc, 2
;
