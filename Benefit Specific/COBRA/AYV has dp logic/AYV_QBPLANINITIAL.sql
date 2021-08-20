SELECT  distinct
 pi.personid
,pbe.benefitsubclass
,pbe.effectivedate 
,pbe.enddate
,pe.effectivedate as term_date
,bpd.benefitplandesc
,bcd.benefitcoveragedesc
,'[QBPLANINITIAL]' :: varchar(35) as recordtype

/*
**Plan Name** **Carrier Plan Identification** **Insurance Type** **Carrier**

[Medical - AR-YS (2017 Balanced) Rx 5U High] AR-YS Medical United Healthcare of GA
[Medical-AR-1L (2017 Choice Plus Adv)Rx 5U Medium] AR-1L Medical United Healthcare of GA
[Medical-AR-1M (2017 Choice Plus Adv) Rx 5U Low] AR-1M Medical United Healthcare of GA
Dental - High Plan 010-46689 Dental Ameritas
Dental - Low Plan 010-46689 Dental Ameritas

Medical - BB-1C MOD 529 913237 Medical United Healthcare of GA
Medical - BB-WW MOD (2V) HSA 913237 Medical United Healthcare of GA
Vision - Guardian 544441 Vision Guardian


Flex - Limited Scope - ProBenefits Flexible Spending Account ProBenefits 
Flex - ProBenefits 208833786 Flexible Spending Account ProBenefits

61   	Dependent Flexible Spending
60   	Medical Flexible Spending
60   	Medical Flexible Spending
60   	Limited Health Care FSA

*/

,case when pbe.benefitsubclass in ('11','16') and pbe.benefitplanid in ('53','287') then '"Dental - High Plan"'
      when pbe.benefitsubclass in ('11','16') and pbe.benefitplanid in ('56','290') then '"Dental - Low Plan"'
      when pbe.benefitsubclass in ('10','15') and pbe.benefitplanid in ('311','350') then '"Medical - BB-WW MOD (2V) HSA"'
      when pbe.benefitsubclass in ('10','15') and pbe.benefitplanid in ('314','347') then '"Medical - BB-1C MOD 529"'
      when pbe.benefitsubclass in ('10','15') and pbe.benefitplanid in ('26','38') then '"Medical - AR-1L (2017 Choice Plus Adv)Rx 5U Medium"'
      when pbe.benefitsubclass in ('10','15') and pbe.benefitplanid in ('23','41') then '"Medical - AR-1M (2017 Choice Plus Adv) Rx 5U Low"'
      when pbe.benefitsubclass in ('10','15') and pbe.benefitplanid in ('135','35') then '"Medical - AR-YS (2017 Balanced) Rx 5U High"'
      when pbe.benefitsubclass in ('14','17') then '"Vision - Guardian"'
      end  ::varchar(100) as plan_name     

,case when bcd.benefitcoveragedesc in ('Employee Only') then 'EE'
      when bcd.benefitcoveragedesc in ('Employee + Spouse') then ('EE+SPOUSE')
      when bcd.benefitcoveragedesc in ('Employee + Children','EE & 1 Dep') then ('EE+CHILDREN')
      when bcd.benefitcoveragedesc in ('EE&Child(ren) + DP Adult&DP Ch','EE + 2 or more DP Adult/Child') then ('EE+FAMILY')
      when bcd.benefitcoveragedesc in ('Employee + Children','EE & 1 Dep','Family','DP Family') then ('EE+FAMILY')
      else bcd.benefitcoveragedesc end :: varchar(15) as coverage_level

,' ' ::char(1) as numberofunits
,'3A' ::char(10) as sort_seq
FROM person_identity pi

LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'AYV_SHDR_COBRA_QB_Export'

JOIN person_employment pe 
  ON pe.personid = pi.personid 
 AND current_date between pe.effectivedate AND pe.enddate 
 AND current_timestamp between pe.createts AND pe.endts

JOIN person_bene_election pbe 
  on pbe.personid = pi.personid 
 and pbe.selectedoption = 'Y' 
 and pbe.benefitelection = 'E' 
 and pbe.benefitsubclass in ('10','11','14','15','16','17')  --- 15,16,17 for domestic partner benefits
 AND pbe.effectivedate < pbe.enddate 
 and date_part('year',deductionstartdate)>=date_part('year',current_date)
 AND current_timestamp between pbe.createts AND pbe.endts
  -- to be qualified for cobra the emp must have participated in employer's health care plan  
 and pbe.personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts and date_part('year',deductionstartdate)>=date_part('year',current_date)
                         and benefitsubclass in ('10','11','14','15','16','17') and benefitelection = 'E' and selectedoption = 'Y' and effectivedate < enddate) 
          

                         
left join (select benefitplandesc, benefitsubclass, benefitplanid, max(effectivedate) as effectived, rank () OVER (PARTITION BY benefitplandesc ORDER BY MAX(effectivedate) DESC) AS RANK
             from benefit_plan_desc bpd where benefitsubclass in ('10','11','14','15','16','17','60','61') and current_date between effectivedate and enddate and current_timestamp between createts and endts
            group by 1,2,3) bpd on bpd.benefitplanid = pbe.benefitplanid and bpd.rank = 1
            
left JOIN benefit_coverage_desc bcd 
  on bcd.benefitcoverageid = pbe.benefitcoverageid 
 and current_date between bcd.effectivedate and bcd.enddate
 and current_timestamp between bcd.createts and bcd.endts 
 

WHERE pi.identitytype = 'SSN' 
  and current_timestamp between pi.createts and pi.endts
  and (pe.effectivedate >= elu.lastupdatets::DATE 
   or (pe.createts > elu.lastupdatets and pe.effectivedate < coalesce(elu.lastupdatets, '2017-01-01')) ) 
   
     
  and pe.emplstatus in ('R','T')
 
order by pi.personid, plan_name