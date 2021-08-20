select distinct on (pc.personid)
pi2.identity as employeeid,
pc.personid,
pu.companyid,
pu.payunitdesc as paygroup,
pc.effectivedate as startdate,
pc.enddate,
'Base' as ratecode,
pc.createts,
case  when pc.frequencycode <> 'H' then
		((pc.compamount * fc.annualfactor) / unitfc.annualfactor)
	else pc.compamount end as rate,
case when pc.frequencycode = 'A' then 'S'
	else pc.frequencycode end as frequencycode
	
	
from person_compensation pc
JOIN frequency_codes fc ON fc.frequencycode=pc.frequencycode
JOIN person_payroll pp 
  ON pp.personid=pc.personid
	and current_date between pp.effectivedate and pp.enddate
	and current_timestamp between pp.createts and pp.endts
	and pp.payunitrelationship = 'M'
JOIN pay_unit pu ON pu.payunitid=pp.payunitid
JOIN frequency_codes unitfc 
  ON unitfc.frequencycode=pu.frequencycode

left outer join person_identity pi2
        on (pc.personid = pi2.personid
       and pi2.identitytype = 'EmpNo' and pi2.endts > NOW())
     
left outer join companystafflist csl
	     on (pc.personid = csl.personid)
	     
where (pc.earningscode like '%Reg%' or pc.earningscode like 'Exc%')
  and pc.enddate > now()
  and pc.effectivedate <= pc.enddate
  and current_timestamp between pc.createts and pc.endts
  and pc.personid = '899'