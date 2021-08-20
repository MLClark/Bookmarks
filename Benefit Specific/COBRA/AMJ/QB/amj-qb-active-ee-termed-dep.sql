SELECT distinct  
 pi.personid
,de.dependentid
,'ACTIVE EE TERMED DEP' ::varchar(30) as qsource  
,'[QB]' :: varchar(35) as recordtype
,'"Cresa Global, Inc"' :: varchar(100) as client_name
,'"Cresa Global, Inc"' :: varchar(50) as client_division_name
,' ' ::char(1) as salutation

,pnd.fname ::varchar(50) as fname
,pnd.mname ::char(1) as mname
,pnd.lname ::varchar(50) as lname
,pid.identity ::char(9) as SSN
,' ' ::char(1) as indv_id

,rtrim(ltrim(pncw.url)) ::varchar(100) as email 
,ppcW.phoneno ::char(15) as phone
,' ' ::char(1) as phone2
,'"'||pae.streetaddress||'"'  ::varchar(50) as addr1
,'"'||pae.streetaddress2||'"' ::varchar(50) as addr2
,pae.city ::varchar(50) as city
,pae.stateprovincecode ::char(2) as state
,pae.postalcode ::varchar(35) as zip
,case when pae.countrycode = 'US' then ' ' else pae.countrycode end ::varchar(50) as country

,'T' ::char(1) as PremiumAddressSameAsPrimary
,' ' ::char(1) as PremiumAddress1
,' ' ::char(1) as PremiumAddress2
,' ' ::char(1) as PremiumCity
,' ' ::char(1) as PremiumState
,' ' ::char(1) as PremiumZip
,' ' ::char(1) as PremiumCountry

,pvd.gendercode ::char(1) as gender
,to_char(pvd.birthdate, 'MM/dd/YYYY')::char(10) as dob
,case when pvd.smoker = 'Y' then 'YES'
      when pvd.smoker = 'N' then 'NO'
      else 'UNKNOWN' end ::varchar(35) as smoker
,CASE pe.emplclass 
      WHEN 'F' THEN 'FTE'
      WHEN 'P' THEN 'PTE'
      ELSE 'UNKNOWN' end ::varchar(35) as employeetype
,case when pd.flsacode = 'E' then 'EXEMPT'
      when pd.flsacode = 'N' then 'NONEXEMPT'
      ELSE 'UNKNOWN' end ::varchar(35) as EmployeePayrollType
,' ' ::char(1) as years_of_service
,'COUPONBOOK' ::varchar(35) AS PremiumCouponType    
,'F' ::char(1) as UsesHCTC
,'T' ::char(1) as active
,'F' ::char(1) as allow__member_sso
,' ' ::char(1) as benefitgroup
,' ' ::char(1) as account_structure
,' ' ::char(1) as client_specific_data
,'1A'||de.dependentid ::char(10) as sort_seq



FROM person_identity pi

LEFT JOIN edi.edi_last_update elu ON elu.feedid =  'AMJ_COBRA_EBC_QB'

JOIN person_employment pe 
  ON pe.personid = pi.personid 
 AND current_date between pe.effectivedate AND pe.enddate 
 AND current_timestamp between pe.createts AND pe.endts

left join pers_pos pp 
  on pp.personid = pe.personid
 and current_date between pp.effectivedate and pp.enddate
 and current_timestamp between pp.createts and pp.endts
 
left join position_desc pd
  on pd.positionid = pp.positionid
 and current_date between pd.effectivedate and pd.enddate
 and current_timestamp between pd.createts and pd.endts 

join person_benefit_action pba
  on pba.personid = pe.personid
 and pba.eventname in ('DepAge','OAC','DIV','FSC') 
 
JOIN person_bene_election pbe 
  on pbe.personid = pba.personid 
 and pbe.personbenefitactionpid = pba.personbenefitactionpid  
 and pbe.selectedoption = 'Y' 
 and pbe.benefitelection = 'E'
 and pbe.benefitsubclass in ('10','11','14','15','16','17','60','61')
 AND current_date between pbe.effectivedate AND pbe.enddate 
 AND current_timestamp between pbe.createts AND pbe.endts
 and pbe.effectivedate < pbe.enddate 
  and pbe.personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts 
                         and benefitsubclass in ('10','11','14','15','16','17','60','61') and benefitelection = 'E' and selectedoption = 'Y' and effectivedate < enddate) 
 ----------------------------------------------------------------------
 ---- Don't look for pe.effectivedate - 1 day when dealing with IE ----
 ----------------------------------------------------------------------

LEFT JOIN person_identity piP
  ON pi.personid = piP.personid 
 AND piP.identitytype = 'PSPID' 
 AND current_timestamp between piP.createts AND piP.endts 
 
LEFT JOIN person_address pae 
  ON pae.personid = pi.personid 
 AND pae.addresstype = 'Res'::bpchar 
 AND current_date between pae.effectivedate AND pae.enddate 
 AND current_timestamp between pae.createts AND pae.endts

LEFT JOIN person_phone_contacts ppcw 
  ON ppcw.personid = pi.personid
 AND current_date between ppcw.effectivedate and ppcw.enddate
 AND current_timestamp between ppcw.createts and ppcw.endts 
 AND ppcw.phonecontacttype = 'Work'   
 
LEFT JOIN person_net_contacts pncw 
  ON pncw.personid = pi.personid 
 AND pncw.netcontacttype = 'WRK'::bpchar 
 AND current_date between pncw.effectivedate and pncw.enddate
 AND current_timestamp between pncw.createts and pncw.enddate 

 ----------------------------------------------------------------------
 ----------------------------------------------------------------------

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
     and pbe.benefitsubclass in ('10','11','14','15','16','17','60','61')
     and pbe.selectedoption = 'Y'
        
     and current_date between pbe.effectivedate and pbe.enddate
     and current_timestamp between pbe.createts and pbe.endts   
   where current_timestamp between de.createts and de.endts
    and de.benefitsubclass in ('10','11','14','15','16','17','60','61')
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
       and de.benefitsubclass in ('10','11','14','15','16','17','60','61')
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
 
LEFT JOIN person_address pa
  ON pa.personid = de.dependentid
 AND pa.addresstype = 'Res'::bpchar 
 AND current_date between pa.effectivedate AND pa.enddate 
 AND current_timestamp between pa.createts AND pa.endts

LEFT JOIN person_vitals pvd 
  ON pvd.personid = de.dependentid
 AND current_date between pvd.effectivedate AND pvd.enddate 
 AND current_timestamp between pvd.createts AND pvd.endts
 
WHERE pi.identitytype = 'SSN' 
  and current_timestamp between pi.createts and pi.endts
  and (pbe.effectivedate >= elu.lastupdatets::DATE 
   or (pbe.createts > elu.lastupdatets and pbe.effectivedate < coalesce(elu.lastupdatets, '2017-01-01')) )   
  
  and pe.emplstatus = 'A' 
 
order by 1, sort_seq