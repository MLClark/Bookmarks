WITH RECURSIVE dep_recursive AS (
SELECT
0 AS "level",
object_name AS "dep_name",
'' AS "dep_table",
'' AS "dep_type",
'' AS "ref_name",
'' AS "ref_type"
from (with srcdata as (
select c.oid::regclass::text as object_name, c.relkind as object_kind, ns.nspname as object_schema
from pg_class c
join pg_namespace ns on c.relnamespace=ns.oid
where relkind in ('v','m','r','f') ----views, matvies, regular tables, foreign tables
)
select object_name from srcdata where object_schema like 'payroll%' and object_name like 'payroll.cognos%'
) src0
UNION ALL
SELECT 
level + 1 AS "level",
depedencies.dep_name,
depedencies.dep_table,
depedencies.dep_type,
depedencies.ref_name,
depedencies.ref_type
FROM (
WITH classType AS (
SELECT
oid,
CASE relkind
WHEN 'r' THEN 'TABLE'::text
WHEN 'i' THEN 'INDEX'::text
WHEN 'S' THEN 'SEQUENCE'::text
WHEN 'v' THEN 'VIEW'::text
WHEN 'c' THEN 'TYPE'::text
WHEN 't' THEN 'TABLE'::text
when 'm' then 'MATERIALIZED VIEW'::text
END AS "type"
FROM pg_class
)
SELECT DISTINCT
CASE classid
WHEN 'pg_class'::regclass THEN objid::regclass::text
WHEN 'pg_type'::regclass THEN objid::regtype::text
WHEN 'pg_proc'::regclass THEN objid::regprocedure::text
WHEN 'pg_constraint'::regclass THEN (SELECT conname FROM pg_constraint WHERE OID = objid)
WHEN 'pg_attrdef'::regclass THEN 'default'
WHEN 'pg_rewrite'::regclass THEN (SELECT ev_class::regclass::text FROM pg_rewrite WHERE OID = objid)
WHEN 'pg_trigger'::regclass THEN (SELECT tgname FROM pg_trigger WHERE OID = objid)
ELSE objid::text
END AS "dep_name",
CASE classid
WHEN 'pg_constraint'::regclass THEN (SELECT conrelid::regclass::text FROM pg_constraint WHERE OID = objid)
WHEN 'pg_attrdef'::regclass THEN (SELECT adrelid::regclass::text FROM pg_attrdef WHERE OID = objid)
WHEN 'pg_trigger'::regclass THEN (SELECT tgrelid::regclass::text FROM pg_trigger WHERE OID = objid)
ELSE ''
END AS "dep_table",
CASE classid
WHEN 'pg_class'::regclass THEN (SELECT TYPE FROM classType WHERE OID = objid)
WHEN 'pg_type'::regclass THEN 'TYPE'
WHEN 'pg_proc'::regclass THEN 'FUNCTION'
WHEN 'pg_constraint'::regclass THEN 'TABLE CONSTRAINT'
WHEN 'pg_attrdef'::regclass THEN 'TABLE DEFAULT'
WHEN 'pg_rewrite'::regclass THEN (SELECT TYPE FROM classType WHERE OID = (SELECT ev_class FROM pg_rewrite WHERE OID = objid))
WHEN 'pg_trigger'::regclass THEN 'TRIGGER'
ELSE objid::text
END AS "dep_type",
CASE refclassid
WHEN 'pg_class'::regclass THEN refobjid::regclass::text
WHEN 'pg_type'::regclass THEN refobjid::regtype::text
WHEN 'pg_proc'::regclass THEN refobjid::regprocedure::text
ELSE refobjid::text
END AS "ref_name",
CASE refclassid
WHEN 'pg_class'::regclass THEN (SELECT TYPE FROM classType WHERE OID = refobjid)
WHEN 'pg_type'::regclass THEN 'TYPE'
WHEN 'pg_proc'::regclass THEN 'FUNCTION'
ELSE refobjid::text
END AS "ref_type",
CASE deptype
WHEN 'n' THEN 'normal'
WHEN 'a' THEN 'automatic'
WHEN 'i' THEN 'internal'
WHEN 'e' THEN 'extension'
WHEN 'p' THEN 'pinned'
END AS "dependency type"
FROM pg_catalog.pg_depend
WHERE deptype = 'n'
AND refclassid NOT IN (2615, 2612)
) depedencies
JOIN dep_recursive ON (depedencies.ref_name like dep_recursive.dep_name)
WHERE depedencies.ref_name NOT IN(depedencies.dep_name, depedencies.dep_table)
)
SELECT
MAX(level) AS "level",
dep_name,
case when min(dep_type)='VIEW' then
'create or replace '||min(dep_type)||' '||dep_name||' as '||
(select definition from pg_views v where v.schemaname||'.'||v.viewname=dep_name)
when min(dep_type)='MATERIALIZED VIEW' then
'create '||min(dep_type)||' '||dep_name||' as '||
(select definition from pg_matviews v where v.schemaname||'.'||v.matviewname=dep_name)
else null end as dep_source_code,
'DROP '||min(dep_type)||' IF EXISTS '||dep_name||';' as drop_dep_text,
min(ref_name) as ref_name,
min(ref_type) as ref_type
FROM dep_recursive d
WHERE level > 0
GROUP BY dep_name