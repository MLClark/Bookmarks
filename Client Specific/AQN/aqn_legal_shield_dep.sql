select distinct
 pi.personid
,pid.personid as depid
,'D' ::char(1) as record_type
,to_char(pbe.effectivedate,'YYYY-MM-DD')::char(10)
,rtrim(pnd.lname,' ') as dep_lname
,rtrim(pnd.fname,' ') as dep_fname
,rtrim(pnd.mname,' ') as dep_mname
,case when pdr.dependentrelationship = 'SP' then 'SP' else 'DP' end ::char(2) as relationship
,pi.identity as mbr_nbr
,to_char(pvd.birthdate, 'YYYY-MM-DD')::char(10) as dep_dob

from person_identity pi

left join person_bene_election pbe
  on pbe.personid = pi.personid
 and current_date between pbe.effectivedate and pbe.enddate
 and current_timestamp between pbe.createts and pbe.endts
 and pbe.benefitelection = 'E'
 and pbe.selectedoption = 'Y'


----- dependent data

left join person_dependent_relationship pdr
  on pdr.personid = pi.personid
 and pdr.dependentrelationship in ('D','C','DP','SP')
 and current_date between pdr.effectivedate and pdr.enddate
 and current_timestamp between pdr.createts and pdr.endts

left join dependent_enrollment de
  on de.dependentid = pdr.dependentid
 and de.personid = pi.personid
 and current_date between de.effectivedate and de.enddate
 and current_timestamp between de.createts and de.endts
 
left join person_identity piD
  on piD.personid = pdr.dependentid
 and piD.identitytype = 'SSN'
 and current_timestamp between piD.createts and piD.endts 
 
left join person_names pnd
  on pnD.personid = pdr.dependentid
 and current_date between pnD.effectivedate and pnD.enddate
 and current_timestamp between pnD.createts and pnD.endts
 and pnD.nametype = 'Dep'
 
left join person_vitals pvD
  on pvD.personid = piD.personid
 and current_date between pvD.effectivedate and pvD.enddate
 and current_timestamp between pvD.createts and pvD.endts  

left join person_maritalstatus pmsd
  on pmsd.personid = pdr.dependentid
 and current_date between pmsd.effectivedate and pmsd.enddate
 and current_timestamp between pmsd.createts and pmsd.endts
 
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts 
  and pbe.benefitsubclass in ('2W')
  and pbe.benefitplanid in ('60','54','66')
  and pid.personid is not null
 