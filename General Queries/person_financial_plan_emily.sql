---- This is the query that pulls data from pfpe into payroll

----::::::::::::::::::::::::::::::::::::::::::401k:::::::::::::::::::::::::::
select * from person_financial_plan_election;
select  pfe.personid
, pi.identity as trankey
, 'PERSON_FINANCIAL_PLAN_ELECTION_' || pfe.benefitsubclass as tablename
--, $LOGID as logid
, pfe.effectivedate

, pfe.effectivedate as benefiteffdate
, coalesce(pmO.benefiteffdatecode, pmS.benefiteffdatecode) as benefiteffdatecode

, round((case when pfe.financialelectionaft <> 0
         then ((pfe.financialelectionaft * fcfpe.annualfactor) / fcpay.annualfactor)
      else ((pfe.financialelectionamount * fcfpe.annualfactor) / fcpay.annualfactor) end)::numeric, 2) as eeperpayamt
, coalesce(pmO.eeperpayamtcode, pmS.eeperpayamtcode) as eeperpayamtcode
, coalesce(pmO.eeperpayamtlen, pmS.eeperpayamtlen) as eeperpayamtlen

, round((case when pfe.financialelectionaftrate <> 0
         then pfe.financialelectionaftrate
      else pfe.financialelectionrate end)::numeric, 2) as fpelectionpct
, coalesce(pmO.fpelectionpctcode, pmS.fpelectionpctcode) as fpelectionpctcode
, coalesce(pmO.fpelectionpctlen, pmS.fpelectionpctlen) as fpelectionpctlen

from person_financial_plan_election pfe
join person_identity pi on pfe.personid = pi.personid
   and pi.identitytype = 'PSPID'
   and current_timestamp between pi.createts and pi.endts
join person_payroll ppay on pfe.personid = ppay.personid
   and pfe.effectivedate between ppay.effectivedate and ppay.enddate
   and current_timestamp between ppay.createts and ppay.endts
join pay_unit pu on ppay.payunitid = pu.payunitid
join frequency_codes fcpay on pu.frequencycode = fcpay.frequencycode
join frequency_codes fcfpe on fcfpe.frequencycode =
 (case when pfe.investmentamountfrequency = 'P' then pu.frequencycode else pfe.investmentamountfrequency end)

left join pspay_benefit_mapping pmS on pfe.benefitsubclass = pmS.benefitsubclass
   and pmS.benefitplanid is null
left join pspay_benefit_mapping pmO on pfe.benefitsubclass = pmO.benefitsubclass
   and pfe.benefitplanid = pmO.benefitplanid

where current_timestamp between pfe.createts and pfe.endts
--and pfe.effectivedate <= pfe.enddate
--and current_date < pfe.enddate

--and coalesce(pmS.benefitmappingid, pmO.benefitmappingid, -1) > 0

--and pfe.createts = CURRENT_TIMESTAMP
--and pfe.personid = $PERSONID
;
select * from person_names where personid = '5981';

---::::::::::::::::::::::::::::::::::::::::::BENEFITS:::::::::::::::::::::::::::

select * from benefitplanmappinglist;

select  pbe.personid
, pi.identity as trankey
, 'PERSON_BENE_ELECTION_' || pbe.benefitsubclass as tablename
--, $LOGID as logid
, pbe.effectivedate

, pbe.effectivedate as benefiteffdate
, coalesce(pmO.benefiteffdatecode, pmS.benefiteffdatecode) as benefiteffdatecode

, pbe.coverageamount as coverageamt
, coalesce(pmO.coverageamtcode, pmS.coverageamtcode) as coverageamtcode
, coalesce(pmO.coverageamtlen, pmS.coverageamtlen) as coverageamtlen

, round(poc.employeerate::numeric, 2) as eeperpayamt
, coalesce(pmO.eeperpayamtcode, pmS.eeperpayamtcode) as eeperpayamtcode
, coalesce(pmO.eeperpayamtlen, pmS.eeperpayamtlen) as eeperpayamtlen

, round(poc.employercost::numeric, 2) as erperpayamt
, coalesce(pmO.erperpayamtcode, pmS.erperpayamtcode) as erperpayamtcode
, coalesce(pmO.erperpayamtlen, pmS.erperpayamtlen) as erperpayamtlen

from person_bene_election pbe
join person_identity pi on pbe.personid = pi.personid
   and pi.identitytype = 'PSPID'
   and current_timestamp between pi.createts and pi.endts
left join personbenoptioncostl poc on pbe.personid = poc.personid
   and pbe.personbeneelectionpid = poc.personbeneelectionpid
   and poc.costsby = 'P'
left join pspay_benefit_mapping pmS on pbe.benefitsubclass = pmS.benefitsubclass
   and pmS.benefitplanid is null
   and (pbe.taxable = pmS.taxable
      or pmS.taxable is null)
left join pspay_benefit_mapping pmO on pbe.benefitsubclass = pmO.benefitsubclass
   and pbe.benefitplanid = pmO.benefitplanid

where current_timestamp between pbe.createts and pbe.endts
and pi.identity = 'AYV25011114760'
--and pbe.benefitelection in ('E', 'T', 'W')
--and pbe.effectivedate <= pbe.enddate
--and current_date < pbe.enddate
--and coalesce(pmS.benefitmappingid, pmO.benefitmappingid, -1) > 0

--and pbe.createts = CURRENT_TIMESTAMP
--and pbe.personid = $PERSONID
select * from 


