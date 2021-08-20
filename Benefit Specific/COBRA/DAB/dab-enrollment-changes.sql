
select distinct

 pe.personid
,pba.eventname 
,'ENROLLMENT CHANGES INELIGIBLE DEP' ::varchar(40) as qsource
,'3' ::char(1) as change_type
,pn.lname ::varchar(30) as lname
,pn.fname ::varchar(30) as fname
,pn.mname ::char(1) as mname
,pi.identity ::char(9) as ssn
,pa.streetaddress ::varchar(40) as addr1
,pa.streetaddress2 ::varchar(40) as addr2
,pa.city ::varchar(40) as city
,pa.stateprovincecode ::char(2) as state
,pa.postalcode ::char(5) as zip
,to_char(pv.birthdate,'yyyy-mm-dd')::char(10) as dob
,to_char(pe.emplhiredate,'yyyy-mm-dd')::char(10) as doh
,pv.gendercode ::char(1) as gender
,to_char(pba.eventeffectivedate,'yyyy-mm-dd')::char(10) as coverage_eff_date

,case when pdr.dependentrelationship in ('SP','DP','NA') then pnd.name else null end ::varchar(30) as sp_name
,case when pdr.dependentrelationship in ('SP','DP','NA') then pid.identity else null end ::char(9) as sp_ssn
,case when pdr.dependentrelationship in ('SP','DP','NA') then to_char(pvd.birthdate,'yyyy-mm-dd') else null end ::char(10) as sp_dob
,case when pdr.dependentrelationship in ('S','D','C','NS','ND','NC') then pnd.name else null end ::varchar(30) as dp_name
,case when pdr.dependentrelationship in ('S','D','C','NS','ND','NC') then to_char(pvd.birthdate,'yyyy-mm-dd') else null end ::char(10) as dp_dob

,case when pbe.benefitsubclass in ('10','12') then 'Medical'
      when pbe.benefitsubclass in ('11','1H') then 'Dental'
      when pbe.benefitsubclass in ('14','1V') then 'Vision'
      end ::varchar(15) as coverage_type
,case when bcd.benefitcoveragedesc in ('Employee Only') then 'EE'
      when bcd.benefitcoveragedesc in ('Employee + Spouse') then ('EE+SPOUSE')
      when bcd.benefitcoveragedesc in ('Employee + Children','EE & 1 Dep') then ('EE+CHILDREN')
      when bcd.benefitcoveragedesc in ('EE&Child(ren) + DP Adult&DP Ch') then ('EE+FAMILY')
      when bcd.benefitcoveragedesc in ('Family') then ('EE+FAMILY')
      when pbe.benefitsubclass = '60' and pbe.benefitplanid = '66' then 'EE'
      when pbe.benefitsubclass = '61' and pbe.benefitplanid = '30' then 'EE+CHILDREN'
      else 'EE' end :: varchar(15) as coverage_level  
 
from person_identity pi 

LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'AWT_Discovery_COBRA_QB_Export'

join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts
 
join person_benefit_action pba
  on pba.personid = pe.personid
 and pba.eventname in ('DepAge','OAC') 

JOIN person_bene_election pbe 
  on pbe.personid = pba.personid 
 and pbe.selectedoption = 'Y' 
 and pbe.benefitelection <> 'W'
 and pbe.benefitsubclass in ('10','11','12','14','1H','1V')
 and pbe.effectivedate < pbe.enddate
 and pbe.personbenefitactionpid = pba.personbenefitactionpid
 AND current_timestamp between pbe.createts AND pbe.endts
  -- to be qualified for cobra the emp must have participated in employer's health care plan  
 and pbe.personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts 
                         and benefitsubclass in ('10','11','12','14','1H','1V') and benefitelection = 'E' and selectedoption = 'Y' and effectivedate < enddate) 
                         
 --- medical ppo salaried
left join person_bene_election pbemedppos
  on pbemedppos.personid = pbe.personid
 and pbemedppos.selectedoption = 'Y'
 and pbemedppos.benefitelection <> 'W'
 and pbemedppos.effectivedate < pbemedppos.enddate
 and current_timestamp between pbemedppos.createts and pbemedppos.endts
 and pbemedppos.benefitsubclass in ('10') 
 
--- medical ppo hourly
left join person_bene_election pbemedppoh
  on pbemedppoh.personid = pbe.personid
 and pbemedppoh.selectedoption = 'Y'
 and pbemedppoh.benefitelection <> 'W'
 and pbemedppoh.effectivedate < pbemedppoh.enddate
 and current_timestamp between pbemedppoh.createts and pbemedppoh.endts
 and pbemedppoh.benefitsubclass in ('12')  
 
left join person_bene_election pbednt
  on pbednt.personid = pbe.personid
 and pbednt.selectedoption = 'Y'
 and pbednt.benefitelection <> 'W'
 and pbednt.effectivedate < pbednt.enddate
 and current_timestamp between pbednt.createts and pbednt.endts
 and pbednt.benefitsubclass in ('11','1H')  

left join person_bene_election pbevsn
  on pbevsn.personid = pbe.personid
 and pbevsn.selectedoption = 'Y'
 and pbevsn.benefitelection <> 'W'
 and pbevsn.effectivedate < pbevsn.enddate
 and current_timestamp between pbevsn.createts and pbevsn.endts
 and pbevsn.benefitsubclass in ('14','1V')   

left join person_names pn
  on pn.personid = pe.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts
 
left join person_address pa
  on pa.personid = pe.personid
 and pa.addresstype = 'Res'
 and current_date between pa.effectivedate and pa.enddate
 and current_timestamp between pa.createts and pa.endts
 
left join person_vitals pv 
  on pv.personid = pe.personid
 and current_date between pv.effectivedate and pv.enddate
 and current_timestamp between pv.createts and pv.endts   
 
left JOIN benefit_coverage_desc bcd 
  on bcd.benefitcoverageid = pbe.benefitcoverageid 
 and current_date between bcd.effectivedate and bcd.enddate
 and current_timestamp between bcd.createts and bcd.endts 
 and bcd.effectivedate < bcd.enddate                    

--------------------------------------------------------------------------
----- dependent data        
--------------------------------------------------------------------------
join person_dependent_relationship pdr
  on pdr.personid = pbe.personid
 and current_date between pdr.effectivedate and pdr.enddate
 and current_timestamp between pdr.createts and pdr.endts

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
    join person_vitals pvd
      on pvd.personid = de.dependentid
     and current_date between pvd.effectivedate and pvd.enddate
     and current_timestamp between pvd.createts and pvd.endts 
    join person_dependent_relationship pdr
      on pdr.personid = de.personid
     and pdr.dependentid = de.dependentid
     and current_date between pdr.effectivedate and pdr.enddate
     and current_timestamp between pdr.createts and pdr.endts
    join person_employment pe
      on pe.personid = de.personid
     and current_date between pe.effectivedate and pe.enddate
     and current_timestamp between pe.createts and pe.endts
    join person_bene_election pbe
      on pbe.personid = de.personid
     and pbe.benefitsubclass in('10','11','12','14','1H','1V')
     and pbe.selectedoption = 'Y'
     and current_date between pbe.effectivedate and pbe.enddate
     and current_timestamp between pbe.createts and pbe.endts     
   where current_timestamp between de.createts and de.endts
    and de.benefitsubclass in ('10','11','12','14','1H','1V')
    and pe.emplstatus = 'A'
    and pbe.benefitelection = 'E'
    and date_part('year',de.enddate)=date_part('year',current_date)
   -- and pe.personid = '9707'
    and de.dependentid not in 
   (select distinct de.dependentid from dependent_enrollment de
      join person_dependent_relationship pdr
        on pdr.personid = de.personid
       and pdr.dependentid = de.dependentid
       and current_date between pdr.effectivedate and pdr.enddate
       and current_timestamp between pdr.createts and pdr.endts
     where current_date between de.effectivedate and de.enddate
       and current_timestamp between de.createts and de.endts
       and de.benefitsubclass in ('10','11','12','14','1H','1V')
   )
)  

left join person_names pnd
  on pnd.personid = de.dependentid
 and pnd.nametype = 'Dep'
 and current_date between pnd.effectivedate and pnd.enddate
 and current_timestamp between pnd.createts and pnd.endts

left join person_identity pid
  on pid.personid = de.dependentid
 and pid.identitytype = 'SSN'
 and current_timestamp between pid.createts and pid.endts 

left join person_maritalstatus pm
  on pm.personid = de.dependentid
 and current_date between pm.effectivedate and pm.enddate
 and current_timestamp between pm.createts and pm.endts 
 
LEFT JOIN person_vitals pvd 
  ON pvd.personid = de.dependentid
 AND current_date between pvd.effectivedate AND pvd.enddate 
 AND current_timestamp between pvd.createts AND pvd.endts 

WHERE pi.identitytype = 'SSN' 
  and current_timestamp between pi.createts and pi.endts 
  and pe.emplstatus = 'A'
  
  UNION
  

select distinct

 pe.personid
,pba.eventname 
,'ENROLLMENT CHANGES DIVORCE' ::varchar(40) as qsource
,'3' ::char(1) as change_type
,pn.lname ::varchar(30) as lname
,pn.fname ::varchar(30) as fname
,pn.mname ::char(1) as mname
,pi.identity ::char(9) as ssn
,pa.streetaddress ::varchar(40) as addr1
,pa.streetaddress2 ::varchar(40) as addr2
,pa.city ::varchar(40) as city
,pa.stateprovincecode ::char(2) as state
,pa.postalcode ::char(5) as zip
,to_char(pv.birthdate,'yyyy-mm-dd')::char(10) as dob
,to_char(pe.emplhiredate,'yyyy-mm-dd')::char(10) as doh
,pv.gendercode ::char(1) as gender
,to_char(pba.eventeffectivedate,'yyyy-mm-dd')::char(10) as coverage_eff_date

,case when pdr.dependentrelationship in ('SP','DP','NA') then pnd.name else null end ::varchar(30) as sp_name
,case when pdr.dependentrelationship in ('SP','DP','NA') then pid.identity else null end ::char(9) as sp_ssn
,case when pdr.dependentrelationship in ('SP','DP','NA') then to_char(pvd.birthdate,'yyyy-mm-dd') else null end ::char(10) as sp_dob
,case when pdr.dependentrelationship in ('S','D','C','NS','ND','NC') then pnd.name else null end ::varchar(30) as dp_name
,case when pdr.dependentrelationship in ('S','D','C','NS','ND','NC') then to_char(pvd.birthdate,'yyyy-mm-dd') else null end ::char(10) as dp_dob

,case when pbe.benefitsubclass in ('10','12') then 'Medical'
      when pbe.benefitsubclass in ('11','1H') then 'Dental'
      when pbe.benefitsubclass in ('14','1V') then 'Vision'
      end ::varchar(15) as coverage_type
,case when bcd.benefitcoveragedesc in ('Employee Only') then 'EE'
      when bcd.benefitcoveragedesc in ('Employee + Spouse') then ('EE+SPOUSE')
      when bcd.benefitcoveragedesc in ('Employee + Children','EE & 1 Dep') then ('EE+CHILDREN')
      when bcd.benefitcoveragedesc in ('EE&Child(ren) + DP Adult&DP Ch') then ('EE+FAMILY')
      when bcd.benefitcoveragedesc in ('Family') then ('EE+FAMILY')
      when pbe.benefitsubclass = '60' and pbe.benefitplanid = '66' then 'EE'
      when pbe.benefitsubclass = '61' and pbe.benefitplanid = '30' then 'EE+CHILDREN'
      else 'EE' end :: varchar(15) as coverage_level  
 
from person_identity pi 

LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'AWT_Discovery_COBRA_QB_Export'

join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts
 
join person_benefit_action pba
  on pba.personid = pe.personid
 and pba.eventname in ('DIV') 

JOIN person_bene_election pbe 
  on pbe.personid = pba.personid 
 and pbe.selectedoption = 'Y' 
 and pbe.benefitelection <> 'W'
 and pbe.benefitsubclass in ('10','11','12','14','1H','1V')
 and pbe.effectivedate < pbe.enddate
 and pbe.personbenefitactionpid = pba.personbenefitactionpid
 AND current_timestamp between pbe.createts AND pbe.endts
  -- to be qualified for cobra the emp must have participated in employer's health care plan  
 and pbe.personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts 
                         and benefitsubclass in ('10','11','12','14','1H','1V') and benefitelection = 'E' and selectedoption = 'Y' and effectivedate < enddate) 
                         
 --- medical ppo salaried
left join person_bene_election pbemedppos
  on pbemedppos.personid = pbe.personid
 and pbemedppos.selectedoption = 'Y'
 and pbemedppos.benefitelection <> 'W'
 and pbemedppos.effectivedate < pbemedppos.enddate
 and current_timestamp between pbemedppos.createts and pbemedppos.endts
 and pbemedppos.benefitsubclass in ('10') 
 
--- medical ppo hourly
left join person_bene_election pbemedppoh
  on pbemedppoh.personid = pbe.personid
 and pbemedppoh.selectedoption = 'Y'
 and pbemedppoh.benefitelection <> 'W'
 and pbemedppoh.effectivedate < pbemedppoh.enddate
 and current_timestamp between pbemedppoh.createts and pbemedppoh.endts
 and pbemedppoh.benefitsubclass in ('12')  
 
left join person_bene_election pbednt
  on pbednt.personid = pbe.personid
 and pbednt.selectedoption = 'Y'
 and pbednt.benefitelection <> 'W'
 and pbednt.effectivedate < pbednt.enddate
 and current_timestamp between pbednt.createts and pbednt.endts
 and pbednt.benefitsubclass in ('11','1H')  

left join person_bene_election pbevsn
  on pbevsn.personid = pbe.personid
 and pbevsn.selectedoption = 'Y'
 and pbevsn.benefitelection <> 'W'
 and pbevsn.effectivedate < pbevsn.enddate
 and current_timestamp between pbevsn.createts and pbevsn.endts
 and pbevsn.benefitsubclass in ('14','1V')   

left join person_names pn
  on pn.personid = pe.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts
 
left join person_address pa
  on pa.personid = pe.personid
 and pa.addresstype = 'Res'
 and current_date between pa.effectivedate and pa.enddate
 and current_timestamp between pa.createts and pa.endts
 
left join person_vitals pv 
  on pv.personid = pe.personid
 and current_date between pv.effectivedate and pv.enddate
 and current_timestamp between pv.createts and pv.endts   
 
left JOIN benefit_coverage_desc bcd 
  on bcd.benefitcoverageid = pbe.benefitcoverageid 
 and current_date between bcd.effectivedate and bcd.enddate
 and current_timestamp between bcd.createts and bcd.endts 
 and bcd.effectivedate < bcd.enddate                    

--------------------------------------------------------------------------
----- dependent data        
--------------------------------------------------------------------------
join person_dependent_relationship pdr
  on pdr.personid = pbe.personid
 and current_date between pdr.effectivedate and pdr.enddate
 and current_timestamp between pdr.createts and pdr.endts

join dependent_enrollment de
  on de.dependentid = pdr.dependentid
 and de.benefitsubclass = pbe.benefitsubclass
 and de.personid = pi.personid
 and current_timestamp between de.createts and de.endts

left join person_names pnd
  on pnd.personid = de.dependentid
 and pnd.nametype = 'Dep'
 and current_date between pnd.effectivedate and pnd.enddate
 and current_timestamp between pnd.createts and pnd.endts

left join person_identity pid
  on pid.personid = de.dependentid
 and pid.identitytype = 'SSN'
 and current_timestamp between pid.createts and pid.endts 

left join person_maritalstatus pm
  on pm.personid = de.dependentid
 and current_date between pm.effectivedate and pm.enddate
 and current_timestamp between pm.createts and pm.endts 
 
LEFT JOIN person_vitals pvd 
  ON pvd.personid = de.dependentid
 AND current_date between pvd.effectivedate AND pvd.enddate 
 AND current_timestamp between pvd.createts AND pvd.endts 

WHERE pi.identitytype = 'SSN' 
  and current_timestamp between pi.createts and pi.endts 
  and pe.emplstatus = 'A'
  and pdr.dependentrelationship in ('SP','DP','X','NA')
  
