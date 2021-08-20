SELECT  distinct
 pi.personid

,'[QBPLANINITIAL]' :: varchar(35) as recordtype
,bpd.benefitplandesc

/*
1-3-19

Plan Name changes
Flexible Spending Account
Kaiser DHMO 8790
MES Vision
UHC Dental High Plan
UHC Dental Low Plan
UHC Select Plus Plan AKKS
UHC Select Plus Plan AKLA
*/
,case when bpd.benefitplandesc = 'Principal Financial Dental High' then '"UHC Dental High Plan"'
      when bpd.benefitplandesc = 'Principal Financial Dental Low' then '"UHC Dental Low Plan"'
      when bpd.benefitplandesc = 'United Healthcare Select Plus AKLA - Base GT25' then '"UHC Select Plus Plan AKLA"'
      when bpd.benefitplandesc = 'United Healthcare Select Plus AKLA - Base LT25' then '"UHC Select Plus Plan AKLA"'
      when bpd.benefitplandesc = 'Kaiser' then '"Kaiser DHMO 8790"'
      when bpd.benefitplandesc = 'Medical Eye Services - Vision' then '"MES Vision"'
      when bpd.benefitplandesc = 'United Healthcare Select Plus AKKS - Buy Up' then '"UHC Select Plus Plan AKKS"'
      when bpd.benefitplandesc = 'Basic Pacific - Medical FSA' then '"Flexible Spending Account"'
      ELSE bpd.benefitplandesc end  ::varchar(50) as plan_name      

,case when bcd.benefitcoveragedesc in ('Employee Only') then 'EE'
      when bcd.benefitcoveragedesc in ('Employee + Spouse') then ('EE+SPOUSE')
      when bcd.benefitcoveragedesc in ('Employee + Children','EE & 1 Dep') then ('EE+CHILDREN')
      when bcd.benefitcoveragedesc in ('EE&Child(ren) + DP Adult&DP Ch') then ('EE+FAMILY')
      when bcd.benefitcoveragedesc in ('Family') then ('EE+FAMILY')
      else null end :: varchar(15) as coverage_level

,' ' ::char(1) as numberofunits
,'3A' ::char(10) as sort_seq


,'0' as dependentid
FROM person_identity pi

LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'AVS_BasicPacific_COBRA_QB_Export'

JOIN person_employment pe 
  ON pe.personid = pi.personid 
 AND current_date between pe.effectivedate AND pe.enddate 
 AND current_timestamp between pe.createts AND pe.endts

join (select personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid,max(effectivedate) as effectivedate, max(enddate) as enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
       from person_bene_election where benefitsubclass in ('10','11','14','60') and benefitelection = 'E' and selectedoption = 'Y' and effectivedate < enddate and current_timestamp between createts and endts             
      group by personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid) pbe on pbe.personid = pe.personid and pbe.rank = 1

JOIN benefit_plan_desc bpd  
  on bpd.benefitsubclass = pbe.benefitsubclass
 and bpd.benefitplanid = pbe.benefitplanid
 AND current_date between bpd.effectivedate and bpd.enddate
 AND current_timestamp between bpd.createts and bpd.endts 

left JOIN benefit_coverage_desc bcd 
  on bcd.benefitcoverageid = pbe.benefitcoverageid 
 and current_date between bcd.effectivedate and bcd.enddate
 and current_timestamp between bcd.createts and bcd.endts 

WHERE pi.identitytype = 'SSN' 
  and current_timestamp between pi.createts and pi.endts
  and pe.effectivedate >= elu.lastupdatets::DATE 
  and pe.emplstatus = 'T'
  --and pi.personid = '862'

order by pi.personid 