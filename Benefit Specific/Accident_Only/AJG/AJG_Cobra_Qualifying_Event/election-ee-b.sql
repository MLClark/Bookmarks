-- AJG-Flores-Cobra-Feed
SELECT distinct

pi.personid,
'INSURED' ::VARCHAR(30) AS QSOURCE,
'0' ::char(2) AS rownumber,
pi.identity,
pi.identity ::char(9)AS DepSSN,
'????' ::char(4) as plancode, 
pbeE.monthlyamount as monthlyPremium,
pbeE.personid,
pbeE.effectivedate,
boc.benefitcoverageid ::char(2),
pbeE.benefitsubclass ::char(2),
bpd.benefitplancode,
bpd.edtcode ::char(6)

FROM person_identity pi

JOIN person_employment pe ON pe.personid = pi.personid AND now() >= pe.effectivedate AND now() <= pe.enddate AND now() >= pe.createts AND now() <= pe.endts

LEFT JOIN person_bene_election pbeT on pbeT.personid = pi.personid 
 	   AND pbeT.benefitelection = 'T' and pbeT.selectedoption = 'Y' 
 	   AND CURRENT_DATE BETWEEN pbeT.effectivedate AND pbeT.enddate 
 	   AND CURRENT_DATE BETWEEN pbeT.createts AND pbeT.endts

JOIN person_bene_election pbeE ON pbeE.personid = pi.personid 
 	   AND pbeE.effectivedate <= pbeE.enddate 
 	   AND pbeE.benefitplanid IS NOT NULL AND pbeE.benefitelection = 'E'::bpchar 
 	   AND CURRENT_DATE >= pbeE.effectivedate
 	   AND CURRENT_DATE BETWEEN pbeE.createts AND pbeE.endts 
 	   AND pbeE.benefitplanid = pbeT.benefitplanid

JOIN benefit_option_coverage boc on boc.benefitoptionid = pbeE.benefitoptionid 
      AND CURRENT_DATE >= boc.effectivedate 
      AND CURRENT_DATE BETWEEN boc.createts AND boc.endts 
      AND now() <= boc.enddate 

JOIN (select compplanid, benefitsubclass,effectivedate,cobraplan 
       from comp_plan_benefit_plan where cobraplan = 'Y' and benefitsubclass in 
         (select benefitsubclass from comp_plan_benefit_plan where cobraplan = 'Y' group by 1) 
          and enddate >= now() and compplanid = 1) bsubclass on bsubclass.benefitsubclass = pbeE.benefitsubclass          

JOIN edi.etl_employment_term_data etd ON etd.personid = pbeT.personid
JOIN edi.edi_last_update lu on lu.feedID = 'AJG_Flores_Cobra_Qualifying_Event'

LEFT JOIN benefit_plan_desc bpd on bpd.benefitsubclass = pbeE.benefitsubclass
      AND bpd.benefitplanid = pbeT.benefitplanid
      AND CURRENT_DATE BETWEEN bpd.effectivedate AND bpd.enddate 
      AND CURRENT_DATE BETWEEN bpd.createts AND bpd.endts

WHERE pi.identitytype = 'SSN'
 AND (pe.createts between lu.lastupdatets AND now()
      OR pe.effectivedate > lu.lastupdatets)
 and extract( year from current_date) = extract(year from pbeE.effectivedate)

ORDER BY pi.identity