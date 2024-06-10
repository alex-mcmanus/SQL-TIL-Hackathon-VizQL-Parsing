-- Inspect the keys in the JSON data to ensure correct path referencing. This is useful when parsing JSON below into the correct formats. 
SELECT
    ARRAY_TO_STRING(OBJECT_KEYS(DATA), ', ') AS keys
FROM logs_raw
LIMIT 100
;


-- create view in submission zone
create or replace view submission_zone.AM_VIZQL_TABLE as (

-- select relevant columns from first level of nest.
SELECT 
    DATA:k::STRING AS k,
    DATA:site::STRING AS site,
    DATA:tid::STRING AS tid,
    TRY_TO_TIMESTAMP(DATA:ts::STRING) AS ts, --useful for autoconverting VizQL timestamp into datetime format for further visualisation. Very useful before loading into Tableau if intended.
    DATA:user::STRING AS user,


-- Extract nested JSON object from other relevant fields, handling different types of content. 
-- These fields were handpicked by reviewing relevant fields. The main important measures were defined as CPU Metrics and Elapsed Time    
    DATA:a:"elapsed"::FLOAT AS Elapsed,
    DATA:a:res:kcpu:"i"::FLOAT AS K_CPU,
    DATA:a:res:ucpu:"i":: FLOAT AS U_CPU,
    DATA:ctx:"wb"::STRING AS workbook,
    DATA:ctx:"vw"::STRING AS view,
    DATA:ctx:"wb-source"::STRING AS wb_source,

    TRY_PARSE_JSON(DATA:v::STRING) AS message -- catch all other string messages
FROM
    tableau_vizql_logs.logs_raw

where k = 'end-bootstrap-session-action.bootstrap-session'

)
;
