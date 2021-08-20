SELECT distinct  
 pi.personid
,pdr.dependentid
--,pbe.benefitplanid 
,'[QBDEPENDENTPLANINITIAL]' :: varchar(35) as recordtype

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
      when bpd.benefitplandesc = 'Dental Low' then '"UHC Dental Low Plan"'
      when bpd.benefitplandesc = 'United Healthcare Select Plus AKLA - Base GT25' then '"UHC Select Plus Plan AKLA"'
      when bpd.benefitplandesc = 'United Healthcare Select Plus AKLA - Base LT25' then '"UHC Select Plus Plan AKLA"'
      when bpd.benefitplandesc = 'Kaiser' then '"Kaiser DHMO 8790"'
      when bpd.benefitplandesc = 'Medical Eye Services - Vision' then '"MES Vision"'
      when bpd.benefitplandesc = 'United Healthcare Select Plus AKKS - Buy Up' then '"UHC Select Plus Plan AKKS"'
      ELSE bpd.benefitplandesc end  ::varchar(50) as plan_name   
     
,'4A'||pdr.dependentid||'B' ::char(10) as sort_seq

FROM person_identity pi

LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'AVS_BasicPacific_COBRA_QB_Export'

JOIN person_employment pe 
  ON pe.personid = pi.personid 
 AND current_date between pe.effectivedate AND pe.enddate 
 AND current_timestamp between pe.createts AND pe.endts

join (select personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid,max(effectivedate) as effectivedate, max(enddate) as enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
       from person_bene_election where benefitsubclass in ('10','11','14','60') and benefitelection = 'E' and selectedoption = 'Y' and effectivedate < enddate and current_timestamp between createts and endts             
      group by personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid) pbe on pbe.personid = pe.personid and pbe.rank = 1

join person_dependent_relationship pdr
  on pdr.personid = pi.personid
 and current_date between pdr.effectivedate and pdr.enddate
 and current_timestamp between pdr.createts and pdr.endts

JOIN dependent_enrollment de
  on de.personid = pdr.personid
 and de.dependentid = pdr.dependentid
 AND de.selectedoption = 'Y'
 and de.benefitsubclass = pbe.benefitsubclass
 --and current_date between de.effectivedate and de.enddate
 and current_timestamp between de.createts and de.endts

LEFT JOIN person_identity pid
  ON pid.personid = pdr.dependentid
 AND pid.identitytype = 'SSN'::bpchar 
 and current_timestamp between pid.createts and pid.endts

JOIN benefit_plan_desc bpd  
  on bpd.benefitsubclass = pbe.benefitsubclass
 and bpd.benefitplanid = pbe.benefitplanid
 AND current_date between bpd.effectivedate and bpd.enddate
 AND current_timestamp between bpd.createts and bpd.endts 

WHERE pi.identitytype = 'SSN' 
  and current_timestamp between pi.createts and pi.endts
  and pe.effectivedate >= elu.lastupdatets::DATE 
  and pe.emplstatus = 'T'
  --and pi.personid = '6094'


order by pi.personid