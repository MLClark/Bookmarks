SELECT distinct
-- QB record type 3 - Benefit Plan Assignment 
 pip.personid
,piS.identity AS e_ssn_001
,pe.effectivedate
,pe.emplstatus

,null as filler_002
,null AS e_lname_003
,null AS e_fname_004
,null AS e_mname_005

,null as clientkey_006
,null as deptkey_007
,null as e_sex_008
,null as e_title_009
,'COVERAGE'    as e_relation_010
,null as d_ssn_011

,null as e_dob_012
,to_char(date_trunc('month', pe.effectivedate + interval '1 month' ), 'MM/DD/YYYY') ::char(10) as first_day_after_LOCdate_013
,to_char( pe.effectivedate,'MM/DD/YYYY') ::char(10) as cobra_event_date_014
,null as qb_event_code_015

,null AS e_addr_016
,null as e_city_017
,null as e_state_018
,null as e_zip_019

,null AS e_phone_020
,null as employeenbr_021


FROM person_identity pi

join edi.edi_last_update elu 
  on elu.feedid = 'AOL_COBRASimple_QB_Export'

LEFT JOIN person_identity piE 
  ON pi.personid = piE.personid 
 AND piE.identitytype = 'EmpNo' 
 AND current_timestamp between piE.createts AND piE.endts
 
LEFT JOIN person_identity piP
  ON pi.personid = piP.personid 
 AND piP.identitytype = 'PSPID' 
 AND current_timestamp between piP.createts AND piP.endts 
 
LEFT JOIN person_identity piS 
  ON piS.personid = piP.personid 
 AND piS.identitytype = 'SSN' 
 AND current_timestamp between piS.createts AND piS.endts 
 
join person_bene_election pbe
  on pbe.personid = pip.personid
 and current_date between pbe.effectivedate and pbe.enddate 
 and current_timestamp between pbe.createts and pbe.endts
 and pbe.benefitsubclass in ('10','11','14')
 and pbe.benefitelection in ('T')  
 and pbe.selectedoption = 'Y'     
 
JOIN comp_plan_benefit_plan cpbp 
  on cpbp.compplanid = pbe.compplanid 
 and pbe.benefitsubclass = cpbp.benefitsubclass 
 AND current_date between cpbp.effectivedate AND cpbp.enddate 
 AND current_timestamp between cpbp.createts AND cpbp.endts  

JOIN person_employment pe 
  ON pe.personid = pip.personid 
 AND current_date between pe.effectivedate AND pe.enddate 
 AND current_timestamp between pe.createts AND pe.endts
 and pe.effectivedate >= elu.lastupdatets
 and pe.emplstatus in ('T','R')
  
WHERE pi.identitytype = 'SSN' 
  and cpbp.cobraplan = 'Y'


order by 1,2
;

