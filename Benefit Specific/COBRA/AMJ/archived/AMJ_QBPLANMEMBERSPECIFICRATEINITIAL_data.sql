SELECT distinct  
--- this is only required for FSA plans
 pi.personid
,'[QBPLANMEMBERSPECIFICRATEINITIAL]' :: varchar(35) as recordtype
,replace(pi.identity,'-','') :: char(9) as emp_ssn -- not in out put
,case when bpd.benefitplancode in ('MSHSA') then 'CIGNA MEDICAL SILVER HSA'
      when bpd.benefitplancode in ('MGOLD') THEN 'CIGNA MEDICAL GOLD HSA'
      when bpd.benefitplancode in ('MBHSA') THEN 'CIGNA MEDICAL BRONZE HSA'
      when bpd.benefitplancode in ('DenBuyup','DBUDP') then 'CIGNA DENTAL BUY UP'
      when bpd.benefitplancode in ('DenBase','DBDP') then 'CIGNA DENTAL BASE'
      when bpd.benefitplancode in ('VisBuyup','VBUYUP','VBUDP') then 'VSP VISION BUY UP'
      when bpd.benefitplancode in ('VisBase','VBDP') then 'VSP VISION BASE'
      when bpd.benefitplancode in ('MEDFSA','DCFSA') then 'EBC FSA'
      else bpd.benefitplancode end :: varchar(50) as plan_name

,pbe.monthlyamount as rate
,'3'||pi.personid||'B' ::char(10) as sort_seq


FROM person_identity pi

LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'AMJ_COBRA_EBC_QB'

join person_bene_election pbe 
  on pbe.personid = pi.personid
 --and current_date between pbe.effectivedate and pbe.enddate 
 and current_timestamp between pbe.createts and pbe.endts
 and pbe.benefitsubclass in ('60','61')
 and pbe.benefitelection in ('E','W')  
 and pbe.selectedoption = 'Y'

JOIN benefit_plan_desc bpd  
  on bpd.benefitsubclass = pbe.benefitsubclass
 and bpd.benefitplanid = pbe.benefitplanid
 AND current_date between bpd.effectivedate and bpd.enddate
 AND current_timestamp between bpd.createts and bpd.endts 

JOIN benefit_coverage_desc bcd 
  on bcd.benefitcoverageid = pbe.benefitcoverageid 
 and current_date between bcd.effectivedate and bcd.enddate
 and current_timestamp between bcd.createts and bcd.endts 

where pi.identitytype = 'SSN' 
 AND CURRENT_TIMESTAMP BETWEEN pi.createts and pi.endts 


order by pi.personid