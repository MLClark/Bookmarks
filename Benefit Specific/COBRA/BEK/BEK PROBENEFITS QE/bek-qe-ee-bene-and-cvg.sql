select distinct
 pi.personid
,pbe.benefitsubclass
,case when pbe.benefitsubclass = '10' and pbe.benefitplanid = '61' then 'Middle PPO'
      when pbe.benefitsubclass = '10' and pbe.benefitplanid = '64' then 'High PPO'
      when pbe.benefitsubclass = '10' and pbe.benefitplanid = '9'  then 'Medical - HDHP'
      when pbe.benefitsubclass = '60' and pbe.benefitplanid = '33' then 'Limited FSA'
      when pbe.benefitsubclass = '60' and pbe.benefitplanid = '36' then 'Health FSA'
      when pbe.benefitsubclass = '11' then 'Dental'
      when pbe.benefitsubclass = '14' then 'Vision'
      end ::varchar(20) as bene_desc
,case when bcd.benefitcoveragedesc in ('Employee Only') then 'EE'
      when bcd.benefitcoveragedesc in ('Employee + Spouse') then ('EE+SPOUSE')
      when bcd.benefitcoveragedesc in ('Employee + Children','EE & 1 Dep') then ('EE+CHILDREN')
      when bcd.benefitcoveragedesc in ('EE&Child(ren) + DP Adult&DP Ch') then ('EE+FAMILY')
      when bcd.benefitcoveragedesc in ('Family') then ('EE+FAMILY')
      when pbe.benefitsubclass = '60' and pbe.benefitplanid = '36' then 'EE'
      when pbe.benefitsubclass = '60' and pbe.benefitplanid = '33' then 'EE'
      when pbe.benefitsubclass = '61' and pbe.benefitplanid = '30' then 'EE+CHILDREN'
      else null end :: varchar(15) as coverage_level
 



from person_identity pi

LEFT JOIN edi.edi_last_update elu ON elu.feedid =  'BEK_ProBenefits_QE_Export'

join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts
 
join person_bene_election pbe 
  on pbe.personid = pi.personid
 and pbe.benefitsubclass in ('10','11','14','60')
 and pbe.selectedoption = 'Y' 
 and current_timestamp between pbe.createts and pbe.endts
   -- to be qualified for cobra the emp must have participated in employer's health care plan  
 and pbe.personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts 
                         and benefitsubclass in ('10','11','14','60') and benefitelection = 'E' and selectedoption = 'Y' and effectivedate < enddate) 
 

left JOIN benefit_coverage_desc bcd 
  on bcd.benefitcoverageid = pbe.benefitcoverageid 
 and current_date between bcd.effectivedate and bcd.enddate
 and current_timestamp between bcd.createts and bcd.endts 
          
 
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  and pe.emplstatus = 'T'
  and pe.personid = '324'


  order by 1