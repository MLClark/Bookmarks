SELECT distinct  
 pi.personid
,pdr.dependentid
,'[QBDEPENDENT]' :: varchar(35) as recordtype
,replace(pi.identity,'-','') :: char(9) as emp_ssn
,replace(pid.identity,'-','') :: char(9) as dep_ssn
,case when pdr.dependentrelationship = 'SP' then 'Spouse'
      when pdr.dependentrelationship in ('C','S','D','NC','ND','NS')  then 'Child'
      when pdr.dependentrelationship in ('DP','NA') then 'DomesticPartnerAdult'
       end ::varchar(35) dep_relationship
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
,pvd.gendercode ::char(1) as dep_gender_code
,to_char(pvd.birthdate, 'MM/DD/YYYY')::char(10) as dep_dob
,to_char(pve.birthdate, 'MM/DD/YYYY')::char(10) as emp_dob
,'F' ::char(1) as isqmcso
,'4'||pdr.dependentid ::char(10) as sort_seq

FROM person_identity pi

LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'AMJ_COBRA_EBC_QB'

JOIN person_employment pe 
  ON pe.personid = pi.personid 
 AND current_date between pe.effectivedate AND pe.enddate 
 AND current_timestamp between pe.createts AND pe.endts
 and pe.effectivedate < pe.enddate

JOIN person_bene_election pbe 
  on pbe.personid = pe.personid 
 and pbe.selectedoption = 'Y' 
 and pbe.benefitelection = 'E'
 and pbe.benefitsubclass in ('10','11','14','15','16','17','60','61')
 and current_date between pbe.effectivedate and pbe.enddate 
 and current_timestamp between pbe.createts and pbe.endts
  -- to be qualified for cobra the emp must have participated in employer's health care plan  
 and pbe.personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts 
                         and benefitsubclass in ('10','11','14','15','16','17','60','61') and benefitelection = 'E' and selectedoption = 'Y' and effectivedate < enddate)

join person_dependent_relationship pdr
  on pdr.personid = pi.personid
 and current_date between pdr.effectivedate and pdr.enddate
 and current_timestamp between pdr.createts and pdr.endts
 and pdr.effectivedate < pdr.enddate

LEFT JOIN person_identity pid
  ON pid.personid = pdr.dependentid
 AND pid.identitytype = 'SSN'::bpchar 
 and current_timestamp between pid.createts and pid.endts

LEFT JOIN person_names pnd 
  ON pnd.personid = pdr.dependentid 
 and pnd.nametype = 'Dep' 
 and current_date between pnd.effectivedate and pnd.enddate
 and current_timestamp between pnd.createts and pnd.endts
 and pnd.effectivedate < pnd.enddate

LEFT JOIN person_vitals pvd
  ON pvd.personid = pdr.dependentid 
 and current_date between pvd.effectivedate and pvd.enddate
 and current_timestamp between pvd.createts and pvd.endts
 and pvd.effectivedate < pvd.enddate

JOIN dependent_enrollment de
  on de.personid = pdr.personid
 and de.dependentid = pdr.dependentid
 AND de.selectedoption = 'Y'
 and de.benefitplanid = pbe.benefitplanid
 and de.benefitsubclass = pbe.benefitsubclass
 and current_timestamp between de.createts and de.endts
 and de.effectivedate < de.enddate

left join person_vitals pve
  on pve.personid = pi.personid
 and current_date between pve.effectivedate and pve.enddate
 and current_timestamp between pve.createts and pve.endts
 and pve.effectivedate < pve.enddate

WHERE pi.identitytype = 'SSN' 
  and current_timestamp between pi.createts and pi.endts
  and (pe.effectivedate >= elu.lastupdatets::DATE 
   or (pe.createts > elu.lastupdatets and pe.effectivedate < coalesce(elu.lastupdatets, '2017-01-01')) ) 
  and pe.emplstatus = 'T'
  and date_part('year',pbe.planyearenddate) = date_part('year',current_date)


order by 1,2