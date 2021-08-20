select distinct

 pi.personid 
,'NPM DATA' ::varchar(40) as qsource
,'1' ::char(1) as change_type
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
,to_char(greatest
(pbemedppos.effectivedate
,pbemedppoh.effectivedate
,pbednt.effectivedate
,pbevsn.effectivedate),'yyyy-mm-dd')::char(10) as coverage_eff_date
,case when pdr.dependentrelationship in ('SP','DP','NA') then pnd.lname || pnd.fname || pnd.mname else null end ::varchar(30) as sp_name
,case when pdr.dependentrelationship in ('SP','DP','NA') then pid.identity else null end ::char(9) as sp_ssn
,case when pdr.dependentrelationship in ('SP','DP','NA') then to_char(pvd.birthdate,'yyyy-mm-dd') else null end ::char(10) as sp_dob
,case when pdr.dependentrelationship in ('S','D','C','NS','ND','NC') then pnd.lname || pnd.fname || pnd.mname else null end ::varchar(30) as dp_name
,case when pdr.dependentrelationship in ('S','D','C','NS','ND','NC') then to_char(pvd.birthdate,'yyyy-mm-dd') else null end ::char(10) as dp_dob
,case when pbe.benefitsubclass in ('10','12') then 'Medical'
      when pbe.benefitsubclass in ('11') then 'Dental'
      when pbe.benefitsubclass in ('14') then 'Vision'
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

left join edi.edi_last_update elu on elu.feedid = 'DAB_EBenefits_Cobra_Export'

join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts

join person_bene_election pbe 
  on pbe.personid = pe.personid
 and pbe.selectedoption = 'Y'
 and pbe.benefitelection = 'E'
 and current_date between pbe.effectivedate and pbe.enddate
 and current_timestamp between pbe.createts and pbe.endts
 and pbe.benefitsubclass in ('10','11','12','14')
 
 --- medical ppo salaried
left join person_bene_election pbemedppos
  on pbemedppos.personid = pe.personid
 and pbemedppos.selectedoption = 'Y'
 and pbemedppos.benefitelection = 'E'
 and current_date between pbemedppos.effectivedate and pbemedppos.enddate
 and current_timestamp between pbemedppos.createts and pbemedppos.endts
 and pbemedppos.benefitsubclass in ('10') 
 
--- medical ppo hourly
left join person_bene_election pbemedppoh
  on pbemedppoh.personid = pe.personid
 and pbemedppoh.selectedoption = 'Y'
 and pbemedppoh.benefitelection = 'E'
 and current_date between pbemedppoh.effectivedate and pbemedppoh.enddate
 and current_timestamp between pbemedppoh.createts and pbemedppoh.endts
 and pbemedppoh.benefitsubclass in ('12')  
 
left join person_bene_election pbednt
  on pbednt.personid = pe.personid
 and pbednt.selectedoption = 'Y'
 and pbednt.benefitelection = 'E'
 and current_date between pbednt.effectivedate and pbednt.enddate
 and current_timestamp between pbednt.createts and pbednt.endts
 and pbednt.benefitsubclass in ('11')  
 
left join person_bene_election pbevsn
  on pbevsn.personid = pe.personid
 and pbevsn.selectedoption = 'Y'
 and pbevsn.benefitelection = 'E'
 and current_date between pbevsn.effectivedate and pbevsn.enddate
 and current_timestamp between pbevsn.createts and pbevsn.endts
 and pbevsn.benefitsubclass in ('14')  
  
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
  
join 
(select distinct personid, enddate, max(effectivedate) as effectivedate,
  RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) desc) AS RANK
  from person_bene_election 
 where benefitsubclass in ('10','11','12','14')
   and current_date between effectivedate and enddate
   and current_timestamp between createts and endts
   and selectedoption = 'Y'
   and benefitelection = 'E'
   group by 1,2) maxpbe on maxpbe.personid = pe.personid and maxpbe.rank = 1 
 
--------------------------------------------------------------------------
----- dependent data        
--------------------------------------------------------------------------

join person_dependent_relationship pdr
  on pdr.personid = pbe.personid
 and current_date between pdr.effectivedate and pdr.enddate
 and current_timestamp between pdr.createts and pdr.endts
 
JOIN dependent_enrollment de
  on de.personid = pdr.personid
 and de.dependentid = pdr.dependentid
 AND de.selectedoption = 'Y'
 and de.benefitplanid = pbe.benefitplanid
 and de.benefitsubclass = pbe.benefitsubclass
 and de.effectivedate >= maxpbe.effectivedate
 and current_timestamp between de.createts and de.endts

LEFT JOIN person_identity pid
  ON pid.personid = pdr.dependentid
 AND pid.identitytype = 'SSN'::bpchar 
 and current_timestamp between pid.createts and pid.endts

LEFT JOIN person_names pnd 
  ON pnd.personid = pdr.dependentid 
 and pnd.nametype = 'Dep' 
 and current_date between pnd.effectivedate and pnd.enddate
 and current_timestamp between pnd.createts and pnd.endts

LEFT JOIN person_vitals pvd
  ON pvd.personid = pdr.dependentid 
 and current_date between pvd.effectivedate and pvd.enddate
 and current_timestamp between pvd.createts and pvd.endts 
 
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  and pe.emplstatus = 'A'
  and (pbe.effectivedate >= elu.lastupdatets::DATE 
   or (pbe.createts > elu.lastupdatets and pbe.effectivedate < coalesce(elu.lastupdatets, '2017-01-01')) )   
  ; 