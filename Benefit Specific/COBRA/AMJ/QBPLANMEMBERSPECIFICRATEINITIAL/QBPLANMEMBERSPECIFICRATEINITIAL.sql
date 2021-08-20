SELECT distinct  
--- this is only required for FSA plans
 pi.personid
,'[QBPLANMEMBERSPECIFICRATEINITIAL]' :: varchar(35) as recordtype
,replace(pi.identity,'-','') :: char(9) as emp_ssn -- not in out put
,pbe.effectivedate
,pbe.benefitelection
,case when bpd.benefitplancode in ('MEDFSA','DCFSA','HFSA','DFSA') then 'EBC FSA'
      when bpd.benefitplancode in ('DenBase','DBDP') then 'CIGNA DENTAL BASE'
      when bpd.benefitplancode in ('DenBuyup','DBUDP') then 'CIGNA DENTAL BUY UP'
      when bpd.benefitplancode in ('MBHSA') THEN 'CIGNA MEDICAL BRONZE HSA'
      when bpd.benefitplancode in ('MGOLD') THEN 'CIGNA MEDICAL GOLD HSA'
      when bpd.benefitplancode in ('MSHSA') then 'CIGNA MEDICAL SILVER HSA'  
      when bpd.benefitplancode in ('VisBuyup','VBUYUP','VBUDP') then 'VSP VISION BUY UP'
      when bpd.benefitplancode in ('VisBase','VBDP') then 'VSP VISION BASE'
      else bpd.benefitplancode end :: varchar(50) as plan_name   

,pbe.monthlyamount as rate
,poc.employeerate
,'3'||pi.personid||pbe.benefitsubclass||pbe.benefitplanid ::char(10) as sort_seq


FROM person_identity pi

LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'AMJ_COBRA_EBC_QB'

JOIN person_employment pe 
  ON pe.personid = pi.personid 
 AND current_date between pe.effectivedate AND pe.enddate 
 AND current_timestamp between pe.createts AND pe.endts
 
join person_benefit_action pba
  on pba.personid = pe.personid
 and pba.eventname in ('TER')    

left join (SELECT personid,personbeneelectionpid,benefitsubclass,benefitplanid,benefitelection,monthlyamount, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate, 
        RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
        FROM person_bene_election WHERE enddate > effectivedate 
          AND current_timestamp BETWEEN createts AND endts
          and benefitsubclass in ('60','61') and benefitelection in ( 'E') and selectedoption = 'Y'
          GROUP BY personid,personbeneelectionpid,benefitsubclass,benefitplanid,benefitelection,monthlyamount ) as pbe on pbe.personid = pba.personid and pbe.rank = 1  

JOIN benefit_plan_desc bpd  
  on bpd.benefitsubclass = pbe.benefitsubclass
 and bpd.benefitplanid = pbe.benefitplanid
 AND current_date between bpd.effectivedate and bpd.enddate
 AND current_timestamp between bpd.createts and bpd.endts

left join personbenoptioncostl poc
  on poc.personid = pbe.personid
 and poc.benefitelection = 'E'
 and poc.personbeneelectionpid = pbe.personbeneelectionpid
 and poc.costsby = 'M' 

where pi.identitytype = 'SSN' 
 AND CURRENT_TIMESTAMP BETWEEN pi.createts and pi.endts 
 and pe.effectivedate >= elu.lastupdatets::DATE 
 and pe.emplstatus = 'T'

order by pi.personid