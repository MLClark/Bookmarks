
SELECT distinct  
 pie.personid
,pdr.dependentid
--,pe.emplstatus
,'ACTIVE EE W TERMED DEP' ::VARCHAR(30) AS QSOURCE

,'[QBDEPENDENT]' :: varchar(35) as recordtype
,replace(pie.identity,'-','') :: char(9) as emp_ssn
,replace(pid.identity,'-','') :: char(9) as dep_ssn
,case when pdr.dependentrelationship = 'SP' then 'Spouse'
      when pdr.dependentrelationship = 'C'  then 'Child'
	  when pdr.dependentrelationship = 'S'  then 'Child'
	  when pdr.dependentrelationship = 'D'  then 'Child'
      when pdr.dependentrelationship = 'NA' then 'DomesticPartnerAdult'
      when pdr.dependentrelationship = 'DP' then 'DomesticPartnerAdult' end ::varchar(35) dep_relationship
,null as salutation
,pnd.fname ::varchar(50) as dep_fisrt_name
,pnd.mname ::char(1) as dep_mid_initial
,pnd.lname ::varchar(50) as dep_last_name
,null ::varchar(100) as email
,null as phone
,null as phone_2
,'T' ::char(1) as address_sameas_qb
,null as address_1
,null as address_2
,null as city
,null as state
,null as zip
,null as country
,null as enrollment_date
,case when pdr.dependentrelationship in ('SP','C','S','DP','D') then pvd.gendercode  end ::char(1) as dep_gender_code
,to_char(pvd.birthdate, 'MM/DD/YYYY')::char(10) as dep_dob
,to_char(pve.birthdate, 'MM/DD/YYYY')::char(10) as emp_dob
,'F' ::char(1) as isqmcso
,'4'||pdr.dependentid ::char(10) as sort_seq

FROM person_identity pie

LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'AMJ_COBRA_EBC_QB'

JOIN person_employment pe 
  ON pe.personid = pie.personid 
 AND current_date between pe.effectivedate AND pe.enddate 
 AND current_timestamp between pe.createts AND pe.endts

join person_bene_election pbe 
  on pbe.personid = pie.personid
 and current_date between pbe.effectivedate and pbe.enddate 
 and current_timestamp between pbe.createts and pbe.endts
 and pbe.benefitsubclass in ('10','11','14','15','16','17','60','61')
 and pbe.selectedoption = 'Y'
 and pbe.benefitelection in ('T','E')
 -- to be qualified for cobra the emp must have participated in employer's health care plan  
 and pbe.personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts 
                         and benefitsubclass in ('10','11','14','15','16','17','60','61') and benefitelection = 'E' and selectedoption = 'Y')
                         
join person_dependent_relationship pdr
  on pdr.personid = pie.personid
 and current_date between pdr.effectivedate and pdr.enddate
 and current_timestamp between pdr.createts and pdr.endts
 AND pdr.dependentrelationship in ('C','S','D')

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
 
join dependent_enrollment de
  on de.dependentid = pdr.dependentid
 and de.benefitsubclass = pbe.benefitsubclass
 and de.personid = pie.personid
 --and current_date between de.effectivedate and de.enddate
 and current_timestamp between de.createts and de.endts
--- yes I'm hardcoding this on purpose this is the earliest day I need to go back to get termed dependents for Regina 
 and de.enddate >= '2017-01-01' 
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
     and pbe.benefitsubclass in ('10','11','14','15','16','17','60','61')
     and pbe.selectedoption = 'Y'
     and current_date between pbe.effectivedate and pbe.enddate
     and current_timestamp between pbe.createts and pbe.endts     
   where current_timestamp between de.createts and de.endts
    and de.benefitsubclass in ('10','11','14','15','16','17','60','61')
    and pdr.dependentrelationship in ('S','D','C','SP','DP')
    and pe.emplstatus = 'A'
    and pbe.benefitelection = 'E'
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
       and de.benefitsubclass in ('10','11','14','15','16','17','60','61')
       and pdr.dependentrelationship in ('S','D','C','SP','DP')
   )
)  



join person_vitals pve
  on pve.personid = pdr.dependentid 
 and current_date between pve.effectivedate and pve.enddate
 and current_timestamp between pve.createts and pve.endts

left join person_maritalstatus pm
  on pm.personid = pie.personid
 and current_date between pm.effectivedate and pm.enddate
 and current_timestamp between pm.createts and pm.endts 

WHERE pie.identitytype = 'SSN' 
  and current_timestamp between pie.createts and pie.endts
  AND pe.emplstatus = 'A'
 -- and pie.personid = '879'


