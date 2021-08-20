select distinct
 pi.personid
,pn.name
,'EN' ::char(2) as record_type
,pi.identity ::char(9) as emp_ssn
,to_char(current_date,'MMDDYYYY') ::char(8) as create_date
,to_char(current_timestamp,'HHMMSS')::char(6) as create_time
,case when pbe.benefitsubclass = '60' then 'Health Care FSA' 
      when pbe.benefitsubclass = '61' then 'Dependent Care FSA' end ::varchar(35) as plan_name 
,to_char(pbe.effectivedate,'MMDDYYYY') ::char(8) as enroll_effective_date
,to_char(pbe.coverageamount,'9990D99') ::char(8) as part_election_amt --- 3/21 should be the annual amount not by pay period
--,to_char(poc.employeerate,'9999D99')   ::char(8) as part_election_amt
,case when pbe.benefitelection = 'T' then to_char(pbe.effectivedate,'MMDDYYYY') else ' ' end ::char(8) as enroll_term_date
,' ' ::char(1) as employer_contrib_lvl
,case when poc.employercost > 0 then to_char(poc.employercost ,'9999D99') end ::char(8) as employer_contrib_amt
,' ' ::char(1) as primary_reimb
,' ' ::char(1) as alt_reimb
,' ' ::char(1) as enrolled_claims_exchng
,' ' ::char(1) as elec_amt_ind
,' ' ::char(1) as HDHP_cov_level
,' ' ::char(1) as plan_yr_start_date
,' ' ::char(1) as termsand_condi_accepted
,' ' ::char(1) as date_term_condi_accepted
,' ' ::char(1) as time_termscondi_accepted
,' ' ::char(1) as change_date
,' ' ::char(1) as spend_down
,'2' ::char(1) as sort_seq

from person_identity pi

left join edi.edi_last_update elu on elu.feedid = 'ASP_Optum_FSA_Export'

left join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts 
 
left join person_names pn 
  ON pn.personid = pi.personid 
 AND pn.nametype = 'Legal'::bpchar 
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts 

join person_bene_election pbe
  on pbe.personid = pi.personid
 and pbe.benefitsubclass in ('60','61')
 and pbe.selectedoption = 'Y'
 and pbe.benefitelection <> 'W'
 and current_date between pbe.effectivedate and pbe.enddate
 and current_timestamp between pbe.createts and pbe.endts
  and pbe.personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts and current_date between effectivedate and enddate
                          and benefitsubclass in ('60','61') and benefitelection = 'E' and selectedoption = 'Y' and effectivedate < enddate) 

join personbenoptioncostl poc 
  on poc.personid = pbe.personid
 and poc.personbeneelectionpid = pbe.personbeneelectionpid
 and poc.costsby = 'P'


where pi.identitytype = 'SSN'
   and current_timestamp between pi.createts and pi.endts
   and pbe.coverageamount <> 0
   and (pbe.effectivedate >= elu.lastupdatets::DATE 
    or (pbe.createts > elu.lastupdatets and pbe.effectivedate < coalesce(elu.lastupdatets, '2017-01-01')) ) 
    --and pe.personid = '4547'
   order by 1
   