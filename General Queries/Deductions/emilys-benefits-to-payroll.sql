insert into person_deduction_setup (personid, etvid, persondedsetuppid, dedamount
, dedpercentage, dedlimit, initialbalance, arrearsbalance, paybackfactor
, effectivedate, enddate, createts, endts, updatets, dederamount,personbeneelectionpid)
select x.personid
, x.etvid
, nextval('person_deduction_setup_seq')
, x.dedamount
, null as dedpercentage
, x.dedlimit
, 0 as initialbalance
, 0 as arrearsbalance
, null as paybackfactor
, x.effectivedate
, x.enddate
, x.createts
, x.endts
, null as updatets
, x.dederamount
, personbeneelectionpid
from(
select distinct pbe.personid
, 'V'|| right(coalesce(pmO.eeperpayamtcode, pmS.eeperpayamtcode), 2) as etvid
, round(poc.employeerate::numeric, 2) as dedamount
, null as dedpercentage
, case when bc.freeformcoverage = 'Y' then pbe.coverageamount
   else 0 end as dedlimit
, coalesce(pbe.deductionstartdate, pbe.effectivedate) as effectivedate
, pbe.enddate as enddate
, pbe.createts
, pbe.endts
, round(poc.employercost::numeric, 2) as dederamount
, pbe.personbeneelectionpid
from person_bene_election pbe
join benefit_subclass bs on pbe.benefitsubclass = bs.benefitsubclass
join benefit_class bc on bs.benefitclass = bc.benefitclass
   and bc.benefitaffiliationtype = 1
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
and pbe.benefitelection = 'E'
and pbe.effectivedate <= pbe.enddate
and current_date < pbe.enddate
and coalesce(pmS.benefitmappingid, pmO.benefitmappingid, -1) > 0
and pbe.createts = $CREATETS
and pbe.personid = $PERSONID
)x
where not exists (select 1 from person_deduction_setup ps2 where ps2.personid = x.personid
         and ps2.etvid = x.etvid
         and x.effectivedate between ps2.effectivedate and ps2.enddate
         and current_Timestamp between ps2.createts and ps2.endts)
