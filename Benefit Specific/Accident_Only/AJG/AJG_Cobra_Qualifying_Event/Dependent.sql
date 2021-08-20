SELECT distinct

  pi.personid
, pi.identity::char(9)
, pid.identity::char(9) AS DepSSN
, substr(pnd.fname, 1, 15) AS FirstName
, substr(pnd.lname, 1, 20) AS LastName
, case pdr.dependentrelationship 
	when 'SP' then 'S'    
	when 'C' THEN 'C'    
	else 'O' 
	 end ::char(1)  AS Relationship
, to_char(pvd.birthdate,'yyyymmdd')::char(8) as dob
, pvd.gendercode ::char(1) as gender

FROM person_identity pi

JOIN person_employment pe ON pe.personid = pi.personid 
 AND now() >= pe.effectivedate 
 AND now() <= pe.enddate 
 AND now() >= pe.createts AND now() <= pe.endts


JOIN person_bene_election pbeT on pbeT.personid = pi.personid 
 and pbeT.benefitelection = 'T' 
 and pbeT.selectedoption = 'Y'
 and now() >= pbeT.effectivedate and now() <= pbeT.enddate 
 and now() >= pbeT.createts and now() <= pbeT.endts
--and  pbe.benefitsubclass in ('1W', '13')

JOIN person_bene_election pbeE ON pbeE.personid = pi.personid 
 AND pbeE.effectivedate <= pbeE.enddate 
 AND pbeE.benefitplanid IS NOT NULL 
 AND pbeE.benefitelection = 'E'::bpchar 
 AND now() >= pbeE.effectivedate AND now() >= pbeE.createts 
 AND now() <= pbeE.endts 
 AND pbeE.benefitplanid = pbeT.benefitplanid

JOIN (select compplanid, benefitsubclass,effectivedate,cobraplan 
        from comp_plan_benefit_plan where cobraplan = 'Y' and benefitsubclass in 
           (select benefitsubclass from comp_plan_benefit_plan 
            WHERE cobraplan = 'Y' group by 1) 
              AND CURRENT_DATE BETWEEN effectivedate AND enddate
              AND CURRENT_DATE BETWEEN createts AND endts
              AND compplanid = 1) bsubclass on bsubclass.benefitsubclass = pbeE.benefitsubclass

LEFT JOIN person_dependent_relationship pdr on pdr.personid = pi.personid 
	  AND CURRENT_DATE BETWEEN pdr.effectivedate AND pdr.enddate
	  AND CURRENT_DATE BETWEEN pdr.createts AND pdr.endts

JOIN person_names pnd ON pnd.personid = pdr.dependentid
 AND CURRENT_DATE BETWEEN pnd.effectivedate AND pnd.enddate
 AND CURRENT_DATE BETWEEN pnd.createts AND pnd.endts
 AND nametype = 'Legal'

LEFT JOIN person_identity pid ON pid.personid = pnd.personid
      AND pid.identitytype = 'SSN'
      AND CURRENT_DATE BETWEEN pid.createts AND pid.endts

LEFT JOIN person_vitals pvd ON pvd.personid = pnd.personid
      AND CURRENT_DATE BETWEEN pvd.effectivedate AND pvd.enddate
      AND CURRENT_DATE BETWEEN pvd.createts AND pvd.endts

LEFT JOIN person_bene_election pbed on pbed.personid = pnd.personid
      AND CURRENT_DATE BETWEEN pbed.createts AND pbed.endts

LEFT JOIN comp_plan_benefit_plan cpbpd on cpbpd.benefitsubclass = pbed.benefitsubclass 
      AND cpbpd.cobraplan = 'Y' 

JOIN edi.etl_employment_data ed ON ed.personid = pbeT.personid AND ed.EMPLSTATUS in ( 'T', 'L')
JOIN edi.edi_last_update lu on lu.feedID = 'AJG_Flores_Cobra_Qualifying_Event'

WHERE pi.identitytype = 'SSN'
  AND CURRENT_DATE >= lu.lastupdatets
  AND pdr.dependentrelationship not in ('SI', 'B', 'M', 'O')

ORDER BY 2, 1