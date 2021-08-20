SELECT distinct  
------- don't send dependent row for termed dep of active employee
 pi.personid
,pdr.dependentid
,'TERMED EE' ::varchar(30) as qsource
,'[QBDEPENDENT]' :: varchar(35) as recordtype
,replace(pid.identity,'-','') :: char(9) as dep_ssn
,case when pdr.dependentrelationship = 'SP' then 'SPOUSE'
      when pdr.dependentrelationship = 'C'  then 'CHILD'
      when pdr.dependentrelationship = 'S'  then 'CHILD'
      when pdr.dependentrelationship = 'D'  then 'CHILD'
      when pdr.dependentrelationship = 'NA' then 'DOMESTICPARTNER'
      when pdr.dependentrelationship = 'DP' then 'DOMESTICPARTNER' end ::varchar(35) dep_relationship
,null as salutation
,pnd.fname ::varchar(50) as dep_fisrt_name
,pnd.mname ::char(1) as dep_mid_initial
,pnd.lname ::varchar(50) as dep_last_name

,null as email
,null as phone
,null as phone_2
,'T' ::char(1) as address_sameas_qb
,null as address_1
,null as address_2
,null as city
,null as state
,null as zip
,null as country
,' '::char(10) as  enrollment_date
,case when pdr.dependentrelationship in ('SP','C','NA','S','DP','D') then pvd.gendercode  end ::char(1) as dep_gender_code
,to_char(pvd.birthdate, 'MM/DD/YYYY')::char(10) as dep_dob
,'F' ::char(1) as isqmcso
,'4'||pdr.dependentid ::char(10) as sort_seq
FROM person_identity pi

LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'AWT_Discovery_COBRA_QB_Export'

JOIN person_employment pe 
  ON pe.personid = pi.personid 
 AND current_date between pe.effectivedate AND pe.enddate 
 AND current_timestamp between pe.createts AND pe.endts

JOIN person_bene_election pbe 
  on pbe.personid = pi.personid 
 and pbe.selectedoption = 'Y' 
 and pbe.benefitsubclass in ('10','11','14')
 AND current_date between pbe.effectivedate AND pbe.enddate 
 AND current_timestamp between pbe.createts AND pbe.endts
  -- to be qualified for cobra the emp must have participated in employer's health care plan  
 and pbe.personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts 
                         and benefitsubclass in ('10','11','14') and benefitelection = 'E' and selectedoption = 'Y') 

--- select dependentrelationship from  person_dependent_relationship group by 1;
join person_dependent_relationship pdr
  on pdr.personid = pi.personid
 and current_date between pdr.effectivedate and pdr.enddate
 and current_timestamp between pdr.createts and pdr.endts
 AND pdr.dependentrelationship in ('SP','C','NA','S','DP','D')

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
 
-- select * from dependent_enrollment
JOIN dependent_enrollment de
  on de.personid = pdr.personid
 and de.dependentid = pdr.dependentid
 AND de.selectedoption = 'Y'
 and de.benefitplanid = pbe.benefitplanid
 and de.benefitsubclass = pbe.benefitsubclass
 --and current_date between de.effectivedate and de.enddate
 and current_timestamp between de.createts and de.endts

left join person_vitals pve
  on pve.personid = pi.personid
 and current_date between pve.effectivedate and pve.enddate
 and current_timestamp between pve.createts and pve.endts

WHERE pi.identitytype = 'SSN' 
  and current_timestamp between pi.createts and pi.endts
  and pe.effectivedate >= elu.lastupdatets::DATE 
  and pe.emplstatus = 'T'
  --and pi.personid = '5988'


order by 1,2