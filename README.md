The **abbrev-BR** set of abbreviations is **a complement for ISO 3166-2:BR**, a proposal for city name abbreviations.

## Dataset

The proposed set of abbreviations, at [judisdiction_abbrev](judisdiction_abbrev.csv),  is provided as [CSV file](https://en.wikipedia.org/wiki/Comma-separated_values), with contextualization, metadata and qualifiers. The tipical data processing and validation occure in a SQL database.
Column `abbvrev` and other adopted conventions:

CSV column | SQL type | Semantic and description
-------|----------|-------------------
`country_num`|integer NN PK1 | [ISO&#160;3166-1 numeric](https://en.wikipedia.org/wiki/ISO_3166-1_numeric), three-digit country code defined by the International Organization for Standardization (ISO).
`subdivision_code`|text NN PK2| [ISO&#160;3166-2:BR](https://en.wikipedia.org/wiki/ISO_3166-2:BR),  the entry for Brazil in ISO 3166-2, part of the ISO 3166 standard, which defines codes for the names of the principal subdivisions of a country.
`local_num` | integer NN PK3 | Local (sovereign) city (or second level subdivisions) identifier, in this case the [standard IBGE numeric code](https://www.ibge.gov.br/explica/codigos-dos-municipios.php).
`abbrev`|text | Abbreviation of the name associated to `local_num`.
`name`|text NN| Name in the country's official language, name associated to `local_num`.
`lexlabel`|text NN| `name` with reduced syntax, using local rules of the [Lex URN](https://en.wikipedia.org/wiki/Lex_(URN)).
`abbrev_source` | integer | ID of the "Abbreviation sources" section below.
`kx_abbrev_score`|integer| Cache for 0-9 elected score, filtered by `str_abbrev_minscore()` function. Good= 7 to 9; Regular= 4 to 6, Weak= 0 to 3.
`kx_abbrev_rule`| text | Cache for detected "abbreviation process rule".

The *SQL type* column describes the PostgreSQL datatype and NN for "Not Null", PK1 for "Primary Key, first key", PK2 for "Primary Key, second key", etc. Raw CSV example:

```csv
country_num,subdivision_code,local_num,abbrev,name,lexlabel,abbrev_source,kx_abbrev_score,kx_abbrev_rule
76,AC,1200013,ACL,Acrelândia,acrelandia,1,8,r03-var
76,AC,1200054,ABL,Assis Brasil,assis.brasil,3,5,r03
```

Note: official `local_num` and `name` cames from [ibge.gov.br/explica/codigos-dos-municipios](https://web.archive.org/web/20210204064331/https://www.ibge.gov.br/explica/codigos-dos-municipios.php).

## Abbreviation sources
Conventions for column `abbrev_source`.

1. OSM.codes process (default).
2. DER-SP and other.
3. Anatel, códigos de 3 letras para todos os ~5500 municípios.  
4. abreviações de municípios no [RegistroBR](https://registro.br/dominio/categorias/)
5. CDHU-SP [cdhu.sp.gov.br/nomenclatura-municipios.pdf](https://www.cdhu.sp.gov.br/documents/20143/37009/nomenclatura-municipios.pdf/debef88d-1ab8-931d-ece9-46ff390e90ae)

## known algorithms and rules

1. Good [algorithm suggestion in a 2018 discussion](https://pt.stackoverflow.com/q/309628/4186).
2. ISO 3166-3,  please check at standards and show here.
3. IATA, please check at standards and show here.
