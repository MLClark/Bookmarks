---- Finding Direct View Dependencies on a Table
/*
performs a join among the catalog tables that contain the dependency information, and qualify the query to return only view dependencies.
*/

SELECT v.oid::regclass AS view
  ,d.refobjid::regclass AS ref_object    -- name of table
  ,d.refobjid::regproc AS ref_object_function  -- name of function
FROM pg_depend AS d      -- objects that depend on a table
  JOIN pg_rewrite AS r  -- rules depending on a table
     ON r.oid = d.objid
  JOIN pg_class AS v    -- views for the rules
     ON v.oid = r.ev_class
WHERE v.relkind in ('m','v')        -- filter mv and views only
  -- dependency must be a rule depending on a relation
  AND d.classid = 'pg_rewrite'::regclass 
  AND d.deptype = 'n'         -- normal dependency
  -- qualify object
  AND d.refclassid = 'pg_class'::regclass   -- dependent table
  AND d.refobjid = 'cognos_pspaypayroll_persontaxelectionsbyyear_mv'::regclass
  -- AND d.refclassid = 'pg_proc'::regclass -- dependent function
  -- AND d.refobjid = 'f'::regproc
;
---- Finding Direct Dependencies on a Table Column
/*
The query uses the table column information in the pg_attribute catalog table.

This query finds the views that depend on the column id of table 
*/

SELECT v.oid::regclass AS view
  ,d.refobjid::regclass AS ref_object -- name of table
  ,a.attname AS col_name               -- column name
  ,a.attrelid 
FROM pg_attribute AS a   -- columns for a table
  JOIN pg_depend AS d    -- objects that depend on a column
    ON d.refobjsubid = a.attnum AND d.refobjid = a.attrelid
  JOIN pg_rewrite AS r   -- rules depending on the column
    ON r.oid = d.objid
  JOIN pg_class AS v     -- views for the rules
    ON v.oid = r.ev_class
WHERE v.relkind in ('m','v')        -- filter mv and views only
  -- dependency must be a rule depending on a relation
  AND d.classid = 'pg_rewrite'::regclass
  AND d.refclassid = 'pg_class'::regclass 
  AND d.deptype = 'n'    -- normal dependency
  --AND a.attrelid = 'taxid'::regclass
  AND a.attname = 'id'
;
----- Listing View Schemas
/*
list views, each view's schema, and the table referenced by the view. The query retrieves the schema from the catalog table pg_namespace and excludes 
the system schemas pg_catalog, information_schema, and gp_toolkit. Also, the query does not list a view if the view refers to itself.
*/

SELECT v.oid::regclass AS view,
  ns.nspname AS schema,       -- view schema,
  d.refobjid::regclass AS ref_object -- name of table
FROM pg_depend AS d            -- objects that depend on a table
  JOIN pg_rewrite AS r        -- rules depending on a table
    ON r.oid = d.objid
  JOIN pg_class AS v          -- views for the rules
    ON v.oid = r.ev_class
  JOIN pg_namespace AS ns     -- schema information
    ON ns.oid = v.relnamespace
WHERE v.relkind in ('m','v')        -- filter mv and views only
  -- dependency must be a rule depending on a relation
  AND d.classid = 'pg_rewrite'::regclass 
  AND d.refclassid = 'pg_class'::regclass  -- referenced objects in pg_class (tables and views)
  AND d.deptype = 'n'         -- normal dependency
  -- qualify object
  AND ns.nspname NOT IN ('pg_catalog', 'information_schema', 'gp_toolkit') -- system schemas
  AND NOT (v.oid = d.refobjid) -- not self-referencing dependency
;
----- Listing View Definitions
/*
This query lists the views that depend on d.refobjid, the column referenced, and the view definition. 
The CREATE VIEW command is created by adding the appropriate text to the view definition.
*/


SELECT v.relname AS view,  
  d.refobjid::regclass as ref_object,
  d.refobjsubid as ref_col, 
  'CREATE VIEW ' || v.relname || ' AS ' || pg_get_viewdef(v.oid) AS view_def
FROM pg_depend AS d
  JOIN pg_rewrite AS r
    ON r.oid = d.objid
  JOIN pg_class AS v
    ON v.oid = r.ev_class
WHERE NOT (v.oid = d.refobjid) 
  AND d.refobjid = 'cognos_pspaypayroll_persontaxelectionsbyyear_mv'::regclass
  ORDER BY d.refobjsubid
;

----- Listing Nested Views
/*
The WITH clause in this CTE query selects all the views in the user schemas. The main SELECT statement finds all views that reference another view.
*/

WITH views AS ( SELECT v.relname AS view,
  d.refobjid AS ref_object,
  v.oid AS view_oid,
  ns.nspname AS namespace
FROM pg_depend AS d
  JOIN pg_rewrite AS r
    ON r.oid = d.objid
  JOIN pg_class AS v
    ON v.oid = r.ev_class
  JOIN pg_namespace AS ns
    ON ns.oid = v.relnamespace
WHERE v.relkind in ('m','v')        -- filter mv and views only
  AND ns.nspname NOT IN ('pg_catalog', 'information_schema', 'gp_toolkit') -- exclude system schemas
  AND d.deptype = 'n'    -- normal dependency
  AND NOT (v.oid = d.refobjid) -- not a self-referencing dependency
 )
SELECT views.view, views.namespace AS schema,
  views.ref_object::regclass AS ref_view,
  ref_nspace.nspname AS ref_schema
FROM views 
  JOIN pg_depend as dep
    ON dep.refobjid = views.view_oid 
  JOIN pg_class AS class
    ON views.ref_object = class.oid
  JOIN  pg_namespace AS ref_nspace
      ON class.relnamespace = ref_nspace.oid
  WHERE class.relkind in ('m','v')        -- filter mv and views only
    AND dep.deptype = 'n'    
; 