SELECT distinct
-- QB record type 2 Family members
 pi.personid
,pdrD.dependentid
--- columns 22 thru 39 populated on T2
,pbe.benefitsubclass
,pbe.benefitplanid
,rtrim(bpd.benefitplandesc,' ') as sponsor_plans_022_038


FROM person_identity pi
JOIN identity_types it 
  ON pi.identitytype = it.identitytype 
 AND current_timestamp between pi.createts AND pi.endts
LEFT JOIN person_identity piE 
  ON pi.personid = piE.personid 
 AND piE.identitytype = 'EmpNo' 
 AND current_timestamp between piE.createts AND piE.endts
 
left JOIN edi.etl_employment_term_data etd 
  ON etd.personid = pi.personid
left JOIN edi.etl_employment_data ed 
  ON ed.personid = pi.personid AND ed.EMPLSTATUS in ( 'T', 'L') 
  

left JOIN person_bene_election pbe 
 on pbe.personid = pi.personid 
and benefitelection = 'T' 
and selectedoption = 'Y' 
AND current_date between pbe.effectivedate AND pbe.enddate 
AND current_timestamp between pbe.createts AND pbe.endts

left join 
   (select benefitplandesc, benefitsubclass, benefitplanid from benefit_plan_desc bpd
    where benefitsubclass in ('10','11','14','60','61')
      and current_date between effectivedate and enddate
      and current_timestamp between createts and endts) bpd
 on bpd.benefitplanid = pbe.benefitplanid


JOIN comp_plan_benefit_plan cpbp 
 on cpbp.compplanid = pbe.compplanid 
and pbe.benefitsubclass = cpbp.benefitsubclass 
AND current_date between cpbp.effectivedate AND cpbp.enddate 
AND current_timestamp between cpbp.createts AND cpbp.endts


---- Dependents Data

left JOIN person_dependent_relationship pdrD
 on pdrD.personid = pi.personid 
AND current_date between pdrD.effectivedate AND pdrD.enddate 
AND current_timestamp between pdrD.createts AND pdrD.endts 
AND pdrD.dependentrelationship in ('SP', 'C', 'D', 'S')



LEFT JOIN person_identity piD
  ON piD.personid = pdrD.dependentid 
 AND piD.identitytype = 'SSN'::bpchar 
 AND current_timestamp between piD.createts AND piD.endts

 
LEFT JOIN edi.edi_last_update lu on lu.feedid = 'AOL_COBRASimple_COBRA_Employee'


WHERE pi.identitytype = 'SSN' 
  and cpbp.cobraplan = 'Y'

and pi.personid in ('1917', '1928','1966', '1982','1926')

order by 1,2


-- 476

