
SELECT distinct
-- QB record type 2 Family members
 pi.personid
,pe.effectivedate
,pe.emplstatus

,pi.identity AS e_ssn_001
,null as filler_002
--- I need to have at least 1 space for this stupid layout that is why I'm coalescing spaces.
--- The single space will generate the " ", when data isn't pulled
--- I also need to trim these fields since we can't sent "JOHN            ","DOE              ",
,null as e_lname_003
,null as e_fname_004
,null as e_mname_005
,null as clientkey_006
,null as deptkey_007
,null as e_sex_008
,null as e_title_009
,'COVERAGE'    as e_relation_010
,null as D_ssn_011
,null as e_dob_012
,null as first_day_after_LOCdate_013
,null as cobra_event_date_014
,null as qb_event_code_015
,null AS e_addr_016
,null as e_city_017
,null as e_state_018
,null as e_zip_019
,null AS e_phone_020
,null as employeenbr_021


,pbe.benefitsubclass
,pbe.benefitplanid
--,coalesce(rtrim(bpd.benefitplandesc,' '),null) as sponsor_plans_022_038
,case when bpd.benefitplandesc = 'Medical FSA' then '123     FSA2017' else null end  as sponsor_plans_022_038
--,pbe.coverageamount as flex_043
--,null as flex_043


FROM person_identity pi
join edi.edi_last_update elu 
  on elu.feedid = 'AOL_COBRASimple_QB_Export'

LEFT JOIN person_identity piE 
  ON pi.personid = piE.personid 
 AND piE.identitytype = 'EmpNo' 
 AND current_timestamp between piE.createts AND piE.endts
 
JOIN person_bene_election pbe 
  on pbe.personid = pi.personid 
 and benefitelection = 'T' 
 and selectedoption = 'Y' 
 AND current_date between pbe.effectivedate AND pbe.enddate 
 AND current_timestamp between pbe.createts AND pbe.endts
 
left join 
   (select benefitplandesc, benefitsubclass, benefitplanid from benefit_plan_desc bpd
    where benefitsubclass in ('60')
      and current_date between effectivedate and enddate
      and current_timestamp between createts and endts) bpd
  on bpd.benefitplanid = pbe.benefitplanid 

JOIN comp_plan_benefit_plan cpbp 
  on cpbp.compplanid = pbe.compplanid 
 and pbe.benefitsubclass = cpbp.benefitsubclass 
 AND current_date between cpbp.effectivedate AND cpbp.enddate 
 AND current_timestamp between cpbp.createts AND cpbp.endts

JOIN person_employment pe 
  ON pe.personid = pi.personid 
 AND current_date between pe.effectivedate AND pe.enddate 
 AND current_timestamp between pe.createts AND pe.endts
 and pe.effectivedate >= elu.lastupdatets
 and pe.emplstatus in ('T','R')


WHERE pi.identitytype = 'SSN' 
  and cpbp.cobraplan = 'Y'
  and pbe.benefitsubclass in ('60')


order by 1,2,3
;
