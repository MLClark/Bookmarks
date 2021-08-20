 SELECT DISTINCT date_part('year'::text, rpgd.periodpaydate) AS tlayear,
    taxrank.ttype_tax_code,
    taxrank.etvid_lookups,
    pte.taxid,
    pte.personid,
    taxrank.taxrank
   FROM runpayrollgetdates rpgd
     JOIN person_tax_elections pte ON ("overlaps"(rpgd.periodstartdate::timestamp with time zone, rpgd.periodenddate::timestamp with time zone, pte.effectivedate::timestamp with time zone, pte.enddate::timestamp with time zone) OR pte.effectivedate = rpgd.periodenddate) AND now() >= pte.createts AND now() <= pte.endts AND pte.effectivedate < pte.enddate
     JOIN( SELECT ta.ttype_tax_code,
            ta.etvid_lookups,
            ta.taxid,
            pte_1.personid,
            MAX(pte_1.effectivedate) AS effectivedate,
            MAX(pte_1.createts) AS createts,
            CASE WHEN ta.etvid_lookups = '{"T02"}' THEN RANK() OVER (PARTITION BY pte_1.personid, ta.ttype_tax_code ORDER BY (max(pte_1.effectivedate)) ASC)--- added case statement because in ajg we found 1 employee that had 3 forms in 2021 - 1 type 1 and 2 type 2 personid = '13609' paymentheaderid = '
                 ELSE RANK() OVER (PARTITION BY pte_1.personid, ta.ttype_tax_code, ta.taxid ORDER BY (max(pte_1.effectivedate)) DESC) end AS taxrank
           FROM tax_lookup_aggregators ta
           JOIN person_tax_elections pte_1 ON pte_1.taxid = ta.taxid
          WHERE pte_1.effectivedate < pte_1.enddate AND now() >= pte_1.createts AND now() <= pte_1.endts  
          GROUP BY ta.ttype_tax_code, ta.etvid_lookups, ta.taxid, pte_1.personid)  taxrank ON taxrank.taxrank = 1 AND taxrank.personid = pte.personid AND taxrank.taxid = pte.taxid AND pte.effectivedate = taxrank.effectivedate
/* notes - T02 requires 2 ranks depending on how many instances of the taxid exists for the current year.
IE on AJG personid 