select
 pi.personid
,pbe.effectivedate
,to_char(current_timestamp,'HHMISS')::char(6) as createTime
,'ACTIVE EE' ::varchar(50) as qsource 
,'4A1032' :: char(6) as employer_code
,'EN' ::char(2) as record_type
,pi.identity :: char(9) as emp_ssn
,case when pbe.benefitsubclass = '60' then 'FSA Healthcare' 
      when pbe.benefitsubclass = '61' then 'FSA Dependent Care'
 	  end :: char(35) as plan_name     
,to_char(pbe.effectivedate,'MMDDYYYY') ::char(8) as enroll_effective_date
,to_char(pbe.coverageamount,'99999D99')::char(9)as part_election_amt
,case when pe.emplclass = 'P' then to_char(pbe.effectivedate,'MMDDYYYY') else ' ' end ::char(8) as enroll_term_date
,null::char(10) as employer_contrib_lvl
,'0.00' :: char(8) as employer_contrib_amt 
,'Debit Card' ::char(30) as primary_reimb
,null ::char(30) as alt_reimb
,null :: char(1) as enrolled_claims_exchng
,'PlanYear' :: char(20) as elec_amt_ind --
,null :: char(6) as HDHP_cov_level
,null :: char(8) as plan_yr_start_date
,null :: char(1) as termsand_condi_accepted
,null :: char(8) as date_term_condi_accepted
,null :: char(6) as time_termscondi_accepted
,null :: char(8) as change_date
,null :: char(1) as spend_down
,'2' as sort_seq

from person_identity pi

left join public.person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts 

left join (select pbe.personid,pbe.benefitsubclass,pbe.benefitelection,pbe.selectedoption,pbe.eventdate,pbe.benefitplanid,pbe.benefitcoverageid,pbe.compplanid,pbe.coverageamount,
max(pbe.effectivedate) as effectivedate,max(pbe.enddate) as enddate,max(pbe.createts) as createts,
rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
from person_bene_election pbe
left join comp_plan_plan_year cppy 
  on cppy.compplanid = pbe.compplanid
 and cppy.compplanplanyeartype = 'Bene'
 and ?::date between cppy.planyearstart and cppy.planyearend
 where effectivedate < enddate 
 and current_timestamp between pbe.createts and pbe.endts
 and pbe.benefitsubclass in ('60','61')
 and pbe.coverageamount <> 0
 and pbe.selectedoption = 'Y'
 and pbe.effectivedate between cppy.planyearstart and cppy.planyearend
 group by 1,2,3,4,5,6,7,8,9) pbe on pbe.personid = pe.personid and pbe.rank = 1

left join benefit_plan_desc bpd
  on bpd.benefitsubclass = pbe.benefitsubclass
 and current_date between bpd.effectivedate and bpd.enddate
 and current_timestamp between bpd.createts and bpd.endts


where pi.identitytype = 'SSN'
   and current_timestamp between pi.createts and pi.endts
   and pe.emplstatus = 'A'
   and pbe.benefitelection in ('E') 
   and pe.emplstatus not in ('T','R')

union ---------------------------------------------------------------------------------------------------------------

--termed ee
select
 pi.personid
,pbe.effectivedate
,to_char(current_timestamp,'HHMISS')::char(6) as createTime
,'TERMED EE' ::varchar(50) as qsource 
,'4A1032' :: char(6) as employer_code
,'EN' ::char(2) as record_type
,pi.identity :: char(9) as emp_ssn
,case when pbe.benefitsubclass = '60' then 'FSA Healthcare' 
      when pbe.benefitsubclass = '61' then 'FSA Dependent Care'
 	  end :: char(35) as plan_name 
,to_char(pbeterm.effectivedate,'MMDDYYYY') ::char(8) as enroll_effective_date
,to_char(pbe.coverageamount,'99999D99')::char(8)as part_election_amt
,null ::char(8) as enroll_term_date
,null::char(10) as employer_contrib_lvl
,'0.00' :: char(8) as employer_contrib_amt 
,'Debit Card' ::char(30) as primary_reimb
,null ::char(30) as alt_reimb
,null :: char(1) as enrolled_claims_exchng
,'PlanYear' :: char(20) as elec_amt_ind --
,null :: char(6) as HDHP_cov_level
,null :: char(8) as plan_yr_start_date
,null :: char(1) as termsand_condi_accepted
,null :: char(8) as date_term_condi_accepted
,null :: char(6) as time_termscondi_accepted
,null :: char(8) as change_date
,null :: char(1) as spend_down
,'2' as sort_seq

from person_identity pi

left join person_bene_election pbe
  on pbe.personid = pi.personid
 and pbe.benefitsubclass in ('60','61')
 and pbe.selectedoption = 'Y' 
 and pbe.benefitelection = 'T'
 and pbe.coverageamount <> 0
 and current_date between pbe.effectivedate and pbe.enddate
 and current_timestamp between pbe.createts and pbe.endts
 and pbe.personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts 
                         and benefitsubclass in ('60','61') and benefitelection = 'E' and selectedoption = 'Y' and effectivedate < enddate) 

left join comp_plan_plan_year cppy 
  on cppy.compplanid = pbe.compplanid
 and cppy.compplanplanyeartype = 'Bene'
 and ?::date between cppy.planyearstart and cppy.planyearend
                 
left join (select personid, effectivedate, enddate from person_bene_election pbe1 where current_timestamp between pbe1.createts and pbe1.endts 
                         and pbe1.benefitsubclass in ('60','61') and pbe1.benefitelection = 'E' and pbe1.selectedoption = 'Y'
                          and pbe1.enddate >=  pbe1.effectivedate
      ) as pbeterm on pbeterm.personid = pi.personid  and pbeterm.effectivedate between cppy.planyearstart and cppy.planyearend
  

LEFT JOIN personbenoptioncostl poc 
  ON poc.personid              = pbe.personid
 AND poc.personbeneelectionpid = pbe.personbeneelectionpid
 AND poc.costsby = 'P'
 AND poc.employeerate > 0

left join public.person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts 

left join benefit_plan_desc bpd
  on bpd.benefitsubclass = pbe.benefitsubclass
 and current_date between bpd.effectivedate and bpd.enddate
 and current_timestamp between bpd.createts and bpd.endts

where pi.identitytype = 'SSN'
   and current_timestamp between pi.createts and pi.endts
   and pbe.effectivedate between cppy.planyearstart and cppy.planyearend
   and pe.emplstatus in ('T','R')

order by 1