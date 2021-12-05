
-- -- -- -- -- -- -- --
-- Casts, str_to_something:

CREATE or replace FUNCTION to_integer(str text) RETURNS int as $f$
  SELECT CASE WHEN s='' THEN NULL::int ELSE s::int END
  FROM (SELECT regexp_replace(str, '[^0-9]', '','g')) t(s)
$f$ LANGUAGE SQL IMMUTABLE;

-- -- -- -- -- -- -- --
-- Array-aggregators:

-- string lib??

CREATE or replace FUNCTION to_hex( p_x bigint[], p_fill_zeros int DEFAULT NULL) RETURNS text[] AS $f$
  SELECT array_agg( CASE WHEN $2>0 THEN lpad(x,p_fill_zeros,'0') ELSE x END )
  FROM (SELECT to_hex(x) x FROM unnest($1) t1(x)) t
$f$ LANGUAGE SQL IMMUTABLE;

CREATE or replace FUNCTION  stragg_prefix(prefix text, s text[], sep text default ',') RETURNS text AS $f$
  SELECT string_agg(x,sep) FROM ( select prefix||(unnest(s)) ) t(x)
$f$ LANGUAGE SQL IMMUTABLE;


----
--- ISO 3166 ABBREVIATION scores.
CREATE or replace FUNCTION str_abbrev_regex(
  abbrev text
) RETURNS text AS $f$
  SELECT string_agg(x||'.*','') FROM regexp_split_to_table(abbrev,'') t(x)
$f$ LANGUAGE SQL IMMUTABLE;

CREATE or replace FUNCTION str_abbrev_minscore(
  abbrev text, name text, lexlabel text DEFAULT '', old_score text DEFAULT ''
) RETURNS text AS $f$
  -- SCORES CONVENCIONADOS: 'B'=bom = 7 a 9, 'R'=regular=4 a 6, 'F'=fraco = 0 a 3
  -- ou mudar?  1 e 2    Fraca (ou Péssima);  3 e 4 Ruim;  5 e 6 Regular,  7 e 8 Boa; 9 e 10 Ótima.
  SELECT CASE WHEN NOT(upper(unaccent(lexlabel)) ~ lixo_abbrev_regex(abbrev)) THEN
     iif( upper(unaccent(name)) ~ lixo_abbrev_regex(abbrev), iif(old_score>'',old_score, 'R'), 'F'::text)
  ELSE COALESCE(old_score,'') END
$f$ LANGUAGE SQL IMMUTABLE;
-- Exemplos:
-- SELECT abbrevx, name, str_abbrev_minscore(abbrevx,name,lexlabel) as score FROM vw_jurabbrev;
-- SELECT parent_abbrev, abbrev, name, str_abbrev_minscore(abbrev,name,lexlabel) as score FROM jurabbrev_aux order by 4 desc, 1,2;
