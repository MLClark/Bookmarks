select distinct
 pi.personid

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
 and pbe.benefitplanid is not null
 and pbe.effectivedate < pbe.enddate
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
  --and pe.personid = '329'

union

select distinct
 pi.personid

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
 and pbe.benefitplanid is not null
 and pbe.effectivedate < pbe.enddate
 and current_timestamp between pbe.createts and pbe.endts
   -- to be qualified for cobra the emp must have participated in employer's health care plan  
 and pbe.personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts 
                         and benefitsubclass in ('10','11','14','60') and benefitelection = 'E' and selectedoption = 'Y' and effectivedate < enddate) 
 

left JOIN benefit_coverage_desc bcd 
  on bcd.benefitcoverageid = pbe.benefitcoverageid 
 and current_date between bcd.effectivedate and bcd.enddate
 and current_timestamp between bcd.createts and bcd.endts 
          
join person_dependent_relationship pdr
  on pdr.personid = pe.personid
 and current_date between pdr.effectivedate and pdr.enddate
 and current_timestamp between pdr.createts and pdr.endts
 and pdr.effectivedate < pdr.enddate

join dependent_enrollment de
  on de.dependentid = pdr.dependentid
 and de.benefitsubclass = pbe.benefitsubclass
 and de.personid = pi.personid
 and current_timestamp between de.createts and de.endts
 and de.dependentid in 
 ( select distinct de.dependentid as dependentid
    from dependent_enrollment de 
    join person_names pne
      on pne.personid = de.personid
     and pne.nametype = 'Legal'
     and current_date between pne.effectivedate and pne.enddate
     and current_timestamp between pne.createts and pne.endts
    join person_names pnd
      on pnd.personid = de.dependentid
     and pnd.nametype = 'Dep'
     and current_date between pnd.effectivedate and pnd.enddate
     and current_timestamp between pnd.createts and pnd.endts  
     and pnd.effectivedate < pnd.enddate  
    join person_vitals pvd
      on pvd.personid = de.dependentid
     and current_date between pvd.effectivedate and pvd.enddate
     and current_timestamp between pvd.createts and pvd.endts
    join person_dependent_relationship pdr
      on pdr.personid = de.personid
     and pdr.dependentid = de.dependentid
     and current_date between pdr.effectivedate and pdr.enddate
     and current_timestamp between pdr.createts and pdr.endts
     and pdr.effectivedate < pdr.enddate
    join person_employment pe
      on pe.personid = de.personid
     and current_date between pe.effectivedate and pe.enddate
     and current_timestamp between pe.createts and pe.endts
    join person_bene_election pbe
      on pbe.personid = de.personid
     and pbe.benefitsubclass in ('10','11','14','60')
     and pbe.selectedoption = 'Y'
     and pbe.benefitcoverageid > '1'     
     and current_date between pbe.effectivedate and pbe.enddate
     and current_timestamp between pbe.createts and pbe.endts   
   where current_timestamp between de.createts and de.endts
    and de.benefitsubclass in ('10','11','14','60')
    and pe.emplstatus = 'A'
    and pbe.benefitelection <> 'W' 
    and date_part('year',de.enddate)=date_part('year',current_date)
    and de.dependentid not in 
   (select distinct de.dependentid from dependent_enrollment de
      join person_dependent_relationship pdr
        on pdr.personid = de.personid
       and pdr.dependentid = de.dependentid
       and current_date between pdr.effectivedate and pdr.enddate
       and current_timestamp between pdr.createts and pdr.endts
       and pdr.effectivedate < pdr.enddate
     where current_date between de.effectivedate and de.enddate
       and current_timestamp between de.createts and de.endts
       and de.effectivedate < de.enddate
       and de.benefitsubclass in ('10','11','14','60')
   )
)  

where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  and pe.emplstatus = 'A'


  order by 1