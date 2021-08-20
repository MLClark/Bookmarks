-- AJG-Flores-Cobra-Feed
SELECT distinct
 pi.personid
,'INSURED' ::VARCHAR(30) AS QSOURCE
,'0' ::char(2) AS rownumber
,pi.identity
,pi.identity ::char(9)AS DepSSN

,case when pbe.benefitsubclass = '10' and bpd.benefitplancode = 'BCBS HDHP' and boc.benefitcoverageid = '1' then '3010'
      when pbe.benefitsubclass = '10' and bpd.benefitplancode = 'BCBS HDHP' and boc.benefitcoverageid = '2' then '3011'
      when pbe.benefitsubclass = '10' and bpd.benefitplancode = 'BCBS HDHP' and boc.benefitcoverageid in ('3','16','17') then '3012'
      when pbe.benefitsubclass = '10' and bpd.benefitplancode = 'BCBS HDHP' and boc.benefitcoverageid = '5' then '3013'
      when pbe.benefitsubclass = '10' and bpd.benefitplancode = 'PPO-4GYN' and boc.benefitcoverageid = '1' then '4020'
      when pbe.benefitsubclass = '10' and bpd.benefitplancode = 'PPO-4GYN' and boc.benefitcoverageid = '2' then '4021'
      when pbe.benefitsubclass = '10' and bpd.benefitplancode = 'PPO-4GYN' and boc.benefitcoverageid in ('3','16','17') then '4022'
      when pbe.benefitsubclass = '10' and bpd.benefitplancode = 'PPO-4GYN' and boc.benefitcoverageid = '5' then '4023'	
      when pbe.benefitsubclass = '10' and bpd.benefitplancode = 'MedicalHMO' and boc.benefitcoverageid = '1' then '5030'
      when pbe.benefitsubclass = '10' and bpd.benefitplancode = 'MedicalHMO' and boc.benefitcoverageid in ('2','3','16') then '5031'
      when pbe.benefitsubclass = '10' and bpd.benefitplancode = 'MedicalHMO' and boc.benefitcoverageid in ('17') then '5032'
      when pbe.benefitsubclass = '10' and bpd.benefitplancode = 'MedicalPOS' and boc.benefitcoverageid = '1' then '6040'
      when pbe.benefitsubclass = '10' and bpd.benefitplancode = 'MedicalPOS' and boc.benefitcoverageid in ('3','16','17') then '6041'
      when pbe.benefitsubclass = '10' and bpd.benefitplancode = 'MedicalPOS' and boc.benefitcoverageid = '5' then '6042'
      when pbe.benefitsubclass = '10' and bpd.benefitplancode = 'PDX HDHP' and boc.benefitcoverageid = '1' then '6040'	
      when pbe.benefitsubclass = '10' and bpd.benefitplancode = 'PDX HDHP' and boc.benefitcoverageid = '2' then '6040'
      when pbe.benefitsubclass = '10' and bpd.benefitplancode = 'PDX HDHP' and boc.benefitcoverageid in ('3','16','17') then '6041'
      when pbe.benefitsubclass = '10' and bpd.benefitplancode = 'PDX HDHP' and boc.benefitcoverageid = '5' then '6042'	         
      
      when pbe.benefitsubclass = '11' and bpd.benefitplancode = 'DentalBASIC' and boc.benefitcoverageid = '1' then '7050'
      when pbe.benefitsubclass = '11' and bpd.benefitplancode = 'DentalBASIC' and boc.benefitcoverageid = '2' then '7051'
      when pbe.benefitsubclass = '11' and bpd.benefitplancode = 'DentalBASIC' and boc.benefitcoverageid = '3' then '7052'
      when pbe.benefitsubclass = '11' and bpd.benefitplancode = 'DentalBASIC' and boc.benefitcoverageid = '5' then '7053'
      when pbe.benefitsubclass = '11' and bpd.benefitplancode = 'DentalHIGH' and boc.benefitcoverageid = '1' then '8060'
      when pbe.benefitsubclass = '11' and bpd.benefitplancode = 'DentalHIGH' and boc.benefitcoverageid = '2' then '8061'
      when pbe.benefitsubclass = '11' and bpd.benefitplancode = 'DentalHIGH' and boc.benefitcoverageid = '3' then '8062'
      when pbe.benefitsubclass = '11' and bpd.benefitplancode = 'DentalHIGH' and boc.benefitcoverageid = '5' then '8063'      
            
      when pbe.benefitsubclass = '14' and bpd.benefitplancode = 'Vision' and boc.benefitcoverageid = '1' then '9070'
      when pbe.benefitsubclass = '14' and bpd.benefitplancode = 'Vision' and boc.benefitcoverageid in ('2','3','16') then '9071'
      when pbe.benefitsubclass = '14' and bpd.benefitplancode = 'Vision' and boc.benefitcoverageid in ('5','17') then '9073'
      
      when pbe.benefitsubclass = '60' and bpd.benefitplancode = 'MedFSA' and boc.benefitcoverageid = '1' then '10080'
      else null end ::char(4) as plancode
      
      
,pbe.benefitsubclass ::char(2)
,boc.benefitcoverageid ::char(2)
,bpd.benefitplancode 
,bpd.edtcode ::char(6)

FROM person_identity pi

JOIN edi.edi_last_update elu on elu.feedID = 'AJG_Flores_Cobra_Qualifying_Event'

LEFT JOIN person_employment pe 
  ON pe.personid = pi.personid 
 AND current_date between pe.effectivedate AND pe.enddate 
 AND current_timestamp between pe.createts AND pe.endts

JOIN person_bene_election pbe 
  on pbe.personid = pi.personid 
 and pbe.selectedoption = 'Y' 
 and pbe.benefitelection in ('T','E')
 and pbe.benefitsubclass in ('10','11','14','20','60')
 AND current_date between pbe.effectivedate AND pbe.enddate 
 AND current_timestamp between pbe.createts AND pbe.endts
  -- to be qualified for cobra the emp must have participated in employer's health care plan  
 and pbe.personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts 
                         and benefitsubclass in ('10','11','14','20','60') and benefitelection = 'E' and selectedoption = 'Y' and effectivedate < enddate) 


JOIN benefit_option_coverage boc 
  on boc.benefitoptionid = pbe.benefitoptionid 
 AND CURRENT_DATE between boc.effectivedate and boc.enddate 
 AND current_timestamp BETWEEN boc.createts AND boc.endts 

LEFT JOIN benefit_plan_desc bpd
  on bpd.benefitsubclass in ('10','11','14','20','60')
 AND bpd.benefitplanid = pbe.benefitplanid
 AND CURRENT_DATE BETWEEN bpd.effectivedate AND bpd.enddate 
 AND current_timestamp BETWEEN bpd.createts AND bpd.endts

WHERE pi.identitytype = 'SSN' 
  and current_timestamp between pi.createts and pi.endts
  and pe.emplstatus in ('R','T')
  and (pe.effectivedate >= elu.lastupdatets::DATE 
   or (pe.createts > elu.lastupdatets and pe.effectivedate < coalesce(elu.lastupdatets, '2017-01-01')) ) 

ORDER BY 1