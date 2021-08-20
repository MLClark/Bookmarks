CREATE MATERIALIZED VIEW public.cognos_pspaypayroll_persontaxelectionsbyyear_mv AS

select distinct date_part('year',periodpaydate) as tlayear, taxrank.ttype_tax_code, taxrank.etvid_lookups, pte.taxid, pte.personid , taxrank.taxrank
    from runpayrollgetdates rpgd
    join person_tax_elections pte on ((rpgd.periodstartdate,rpgd.periodenddate) overlaps (pte.effectivedate, pte.enddate) or pte.effectivedate = rpgd.periodenddate)
           AND current_timestamp between pte.createts and pte.endts
           AND pte.effectivedate < pte.enddate
    join ( SELECT ta.ttype_tax_code, ta.etvid_lookups, ta.taxid, pte.personid, max(pte.effectivedate) as effectivedate, max(pte.createts) as createts,  rank() over (partition by personid, ta.ttype_tax_code, ta.taxid order by max(effectivedate) desc) as taxrank
                                                FROM tax_lookup_aggregators ta            JOIN person_tax_elections pte ON pte.taxid = ta.taxid WHERE pte.effectivedate < pte.enddate AND now() >= pte.createts AND now() <= pte.endts
                                                   group by ta.ttype_tax_code, ta.etvid_lookups, ta.taxid, pte.personid  ) taxrank  on taxrank.taxrank = 1 and taxrank.personid = pte.personid and taxrank.taxid = pte.taxid AND pte.effectivedate = taxrank.effectivedate
WITH NO DATA
;   