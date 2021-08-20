select distinct
pu.payunitdesc as paygroup,
pi2.identity as employeeid,
pbe.personid,
pbe.effectivedate as startdate,
pbe.payfrequencycode as frequency,
pbe.enddate,
case when bpd.benefitcalctype = 'P' or bpd.benefitcalctype = 'PM' then '%'
else '' end as calccode,
bs.benefitsubclassdesc,
CASE
    WHEN pbcst.benefitelection = 'W'::bpchar THEN 0::double precision
    WHEN pbe.source = 'CB'::bpchar THEN pbcst.employeerate + pbcst.employercost::double precision
    ELSE pbcst.employeerate
END AS employeerate,
bpd.edtcode as dcode
from person_bene_election pbe
left outer join benefit_plan_desc bpd
        on(pbe.benefitplanid = bpd.benefitplanid and bpd.enddate > now())
left outer join benefit_subclass bs
        on(bs.benefitsubclass = pbe.benefitsubclass)
left join person_payroll ppay on pbe.personid = ppay.personid
	and current_date between ppay.effectivedate and ppay.enddate
	and current_timestamp between ppay.createts and ppay.endts 
	and ppay.payunitrelationship = 'M'
left join pay_unit pu 
	on (ppay.payunitid = pu.payunitid)
left outer join person_identity pi2
      on (pbe.personid = pi2.personid
             and pi2.identitytype = 'EmpNo' and pi2.endts > NOW())
LEFT JOIN personbenoptioncostl pbcst ON pbe.personid = pbcst.personid 
AND pbe.personbeneelectionpid = pbcst.personbeneelectionpid AND pbcst.costsby = 'P'::text
where bpd.edtcode <> '' and ((pbe.enddate > NOW() and pbe.effectivedate <= pbe.enddate) 
OR (pbe.enddate >= current_date - interval '30 days' and pbe.effectivedate <= pbe.enddate))
	and current_timestamp between pbe.createts and pbe.endts order by pbe.enddate

