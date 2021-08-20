SELECT distinct
-- QB record type 2 Family members
 pi.personid
,pdrD.dependentid
,pe.effectivedate
,pe.emplstatus
,pi.identity AS e_ssn_001
,null as filler_002
--- I need to have at least 1 space for this stupid layout that is why I'm coalescing spaces.
--- The single space will generate the " ", when data isn't pulled
--- I also need to trim these fields since we can't sent "JOHN            ","DOE              ",
,rtrim(ltrim(pnD.lname)) AS D_lname_003
,rtrim(ltrim(pnD.fname)) AS D_fname_004
,rtrim(ltrim(upper(substring(pnD.mname from 1for 1)))) AS D_mname_005
,null as clientkey_006
,null as deptkey_007
,rtrim(ltrim(pvD.gendercode)) as D_sex_008
,null as e_title_009
,case when pdrD.dependentrelationship = 'SP' then 'SPOUSE'
      when pdrD.dependentrelationship in ('C','S','D') then 'CHILD' else '' end as D_relation_010
,coalesce(replace(piD.identity,'-',''),' ') as D_ssn_011
,case when pvD.birthdate is null then ' ' else to_char(pvD.birthdate, 'MM/dd/YYYY') end as d_dob_012
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
 

  
LEFT JOIN person_names pne 
  ON pne.personid = pi.personid 
 AND pne.nametype = 'Legal'::bpchar 
 AND current_date between pne.effectivedate AND pne.enddate 
 AND current_timestamp between pne.createts AND pne.endts
LEFT JOIN person_address pae 
  ON pae.personid = pi.personid 
 AND pae.addresstype = 'Res'::bpchar 
 AND current_date between pae.effectivedate AND pae.enddate 
 AND current_timestamp between pae.createts AND pae.endts

LEFT JOIN person_phone_contacts ppch 
  ON ppch.personid = pi.personid
 AND current_date between ppch.effectivedate and ppch.enddate
 AND current_timestamp between ppch.createts and ppch.endts 
 AND ppch.phonecontacttype = 'Home'
LEFT JOIN person_phone_contacts ppcw 
  ON ppcw.personid = pi.personid
 AND current_date between ppcw.effectivedate and ppcw.enddate
 AND current_timestamp between ppcw.createts and ppcw.endts 
 AND ppcw.phonecontacttype = 'Work'   
LEFT JOIN person_phone_contacts ppcb 
  ON ppcb.personid = pi.personid
 AND current_date between ppcb.effectivedate and ppcb.enddate
 AND current_timestamp between ppcb.createts and ppcb.endts 
 AND ppcb.phonecontacttype = 'BUSN'      
LEFT JOIN person_phone_contacts ppcm 
  ON ppcm.personid = pi.personid
 AND current_date between ppcm.effectivedate and ppcm.enddate
 AND current_timestamp between ppcm.createts and ppcm.endts 
 AND ppcm.phonecontacttype = 'Mobile'  
 
LEFT JOIN person_vitals pvE 
  ON pvE.personid = pi.personid 
 AND current_date between pvE.effectivedate AND pvE.enddate 
 AND current_timestamp between pvE.createts AND pvE.endts

JOIN person_bene_election pbe 
  on pbe.personid = pi.personid 
 and benefitelection = 'T' 
 and selectedoption = 'Y' 
 AND current_date between pbe.effectivedate AND pbe.enddate 
 AND current_timestamp between pbe.createts AND pbe.endts

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

---- Dependents Data

left JOIN person_dependent_relationship pdrD
  on pdrD.personid = pi.personid 
 AND current_date between pdrD.effectivedate AND pdrD.enddate 
 AND current_timestamp between pdrD.createts AND pdrD.endts 
 AND pdrD.dependentrelationship in ('SP', 'C', 'D', 'S')

LEFT JOIN person_names pnD
  ON pnD.personid = pdrD.dependentid 
 AND current_date between pnD.effectivedate AND pnD.enddate 
 AND current_timestamp between pnD.createts AND pnD.endts

LEFT JOIN person_identity piD
  ON piD.personid = pdrD.dependentid 
 AND piD.identitytype = 'SSN'::bpchar 
 AND current_timestamp between piD.createts AND piD.endts

LEFT JOIN person_vitals pvD
  ON pvD.personid = pdrD.dependentid 
 AND current_date between pvD.effectivedate AND pvD.enddate 
 AND current_timestamp between pvD.createts AND pvD.endts

LEFT JOIN dependent_enrollment dpD 
  on dpD.dependentid = pdrD.dependentid 
 AND current_date between dpD.effectivedate AND dpD.enddate 
 AND current_timestamp between dpD.createts AND dpD.endts

LEFT JOIN person_address paD
  ON paD.personid = pdrD.dependentid 
 AND paD.addresstype = 'Res'::bpchar 
 AND current_date between paD.effectivedate AND paD.enddate 
 AND current_timestamp between paD.createts AND paD.endts 



WHERE pi.identitytype = 'SSN' 
  and cpbp.cobraplan = 'Y'
  and pdrD.dependentid is not null

--and pi.personid in ('1917', '1928','1966', '1982','1926')

order by 1,2
;

