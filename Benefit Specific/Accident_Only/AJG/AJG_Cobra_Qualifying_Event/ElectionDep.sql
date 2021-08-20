-- AJG-Flores-Cobra-Feed
SELECT distinct

pi.personid,
pdr.persondeprelpid ::char(2) AS rownumber,
pi.identity,
edp.identity ::char(9)AS DepSSN,
'????' ::char(4) as plancode, 
pbeE.monthlyamount as monthlyPremium,
pbeE.personid,
pbeE.effectivedate,
boc.benefitcoverageid ::char(2),
pbeE.benefitsubclass ::char(2),
bpd.benefitplancode,
bpd.edtcode ::char(6)

FROM person_identity pi

JOIN person_employment pe ON pe.personid = pi.personid 
 AND CURRENT_DATE BETWEEN pe.effectivedate AND pe.enddate 
 AND CURRENT_DATE BETWEEN pe.createts AND pe.endts
 	 
JOIN person_bene_election pbeT on pbeT.personid = pi.personid 
 AND pbeT.benefitelection = 'T' and pbeT.selectedoption = 'Y' 
 AND CURRENT_DATE BETWEEN pbeT.effectivedate AND pbeT.enddate 
 AND CURRENT_DATE BETWEEN pbeT.createts AND pbeT.endts
     
JOIN person_bene_election pbeE ON pbeE.personid = pi.personid 
 AND pbeE.effectivedate <= pbeE.enddate 
 AND pbeE.benefitplanid IS NOT NULL 
 AND pbeE.benefitelection = 'E'::bpchar 
 AND CURRENT_DATE >= pbeE.effectivedate 
 AND CURRENT_DATE BETWEEN pbeE.createts AND pbeE.endts 
 AND pbeE.benefitplanid = pbeT.benefitplanid
  
JOIN (select compplanid, benefitsubclass,effectivedate,cobraplan 
        from comp_plan_benefit_plan where cobraplan = 'Y' and benefitsubclass in 
          (select benefitsubclass from comp_plan_benefit_plan where cobraplan = 'Y' group by 1) 
           and enddate >= now() and compplanid = 1) bsubclass on bsubclass.benefitsubclass = pbeE.benefitsubclass
     
JOIN person_dependent_relationship pdr on pi.personid = pdr.personid 
 AND now() >= pdr.effectivedate 
 AND now() <= pdr.enddate 
 AND now() >= pdr.createts 
 AND now() <= pdr.endts

JOIN edi.edidependent EED on eed.employeepersonid = pi.personid
 

JOIN person_bene_election dpbe on dpbe.personid = pdr.dependentid
 AND dpbe.selectedoption = 'Y' 
 AND now() >= dpbe.createts 
 AND now() <= dpbe.endts

LEFT JOIN benefit_option_coverage boc on boc.benefitoptionid = pbeE.benefitoptionid 
 AND CURRENT_DATE >= boc.effectivedate 
 AND CURRENT_DATE BETWEEN boc.createts AND boc.endts 
 AND now() <= boc.enddate 

JOIN comp_plan_benefit_plan dcpbp on dcpbp.benefitsubclass = dpbe.benefitsubclass 
 AND dcpbp.cobraplan = 'Y' 

JOIN edi.etl_employment_term_data etd ON etd.personid = pbeT.personid
JOIN edi.etl_employment_data ed ON ed.personid = pbeT.personid AND ed.EMPLSTATUS in ( 'T', 'L')

JOIN person_identity edp ON edp.personid = pdr.dependentid AND edp.identitytype = 'SSN'::bpchar AND now() >= edp.createts AND now() <= edp.endts
JOIN edi.edi_last_update lu on lu.feedID = 'AJG_Flores_Cobra_Qualifying_Event'

LEFT JOIN benefit_plan_desc bpd on bpd.benefitsubclass = pbeE.benefitsubclass
      AND bpd.benefitplanid = pbeT.benefitplanid
      AND CURRENT_DATE BETWEEN bpd.effectivedate AND bpd.enddate 
      AND CURRENT_DATE BETWEEN bpd.createts AND bpd.endts

WHERE pi.identitytype = 'SSN'
  AND CURRENT_DATE >= lu.lastupdatets
  AND eed.dependentrelationshipid not in ('SI', 'B', 'M', 'O')

ORDER BY pi.identity