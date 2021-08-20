
SELECT
    pte.personid,
    pte.taxid,
    pte.effectivedate,
    pte.enddate,
    pte.updatets,
    pte.createts,
    pte.endts,
    t.taxiddesc,
    pte.taxfilingstatus,
    ---tfs.taxfilingstatusdesc,
    case when (pte.taxid = 2 and tfs.taxfilingstatus = 1) then 'Single or Married filing separately ' --(was known as single)
         when (pte.taxid = 2 and tfs.taxfilingstatus = 2 ) then 'Married filing jointly (or Qualifying widow(er))' --(was known as married)
         else tfs.taxfilingstatusdesc end as taxfilingstatusdesc,
    pte.exempt,
    pte.exemptions,
    pte.additionalallowances,
    pte.additionalwithholdamount,
    pte.additionalwithholdpercent,
    pte.exemptioncredits,
    pte.overrideamount,
    pte.secondaryallowances,
    pte.nonresidentcert,

    t.taxentity,
    t.taxcode,
    t.entryallowed,
    t.exemptionsallowed,
    t.exemptionsname,
    t.taxtype,
    pte.ssnnamedifferent,
    ptp.taxelectionparameterpid,
    p.taxelectionparametername,
    p.taxelectionparamvaluemask,
    COALESCE(en.description, (ptp.taxelectionparametervalue)::text) AS taxelectionparametervalue,
    pte.dependentsamount  --- new for additional allowances claiming depend.
FROM
    (((((person_tax_elections pte
JOIN 
    tax t  --- determine if federal 
ON
    ((
            pte.taxid = t.taxid))) --taxid = 2
LEFT JOIN
    tax_filing_status tfs  --- this determines description -2 indicates 2020 W4 tax form
ON
    ((
            pte.taxfilingstatus = tfs.taxfilingstatus)))
LEFT JOIN
    tax_election_parameter p
ON
    (((
                pte.taxid = p.taxid)
        AND ((
                    'now'::text)::DATE < p.enddate))))
LEFT JOIN
    person_tax_election_param ptp
ON
    (((
                pte.personid = ptp.personid)
        AND (
                ptp.taxid = pte.taxid)
        AND (
                ptp.persontaxelectionpid = pte.persontaxelectionpid)
        AND (
                ptp.taxelectionparameterpid = p.taxelectionparameterpid))))
LEFT JOIN
    taxelectionenum en
ON
    ((((
                    ptp.taxelectionparametervalue)::text = en.code)
        AND ((
                    p.taxelectionparamvaluemask)::text !~~ '%]+'::text))))
WHERE
    ((((
                    'now'::text)::DATE >= pte.effectivedate)
        AND ((
                    'now'::text)::DATE <= pte.enddate))
    AND ((
                now() >= pte.createts)
        AND (
                now() <= pte.endts)))

ORDER BY
    pte.personid,
    pte.taxid,
    ptp.taxelectionparameterpid;