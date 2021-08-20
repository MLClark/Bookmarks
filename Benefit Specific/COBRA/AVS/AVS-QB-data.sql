SELECT  
 pi.personid
,pu.payunitxid::char(2)
, 'TERMED EE'::varchar(30)		-- voluntary term/involuntary term/layoff qualifying event
,'[QB]' :: varchar(35) as recordtype
,case when pu.employertaxid = lookup.key1 then '"' || lookup.client || '"'
      else '' end :: varchar(100) as client_name
,case when pu.employertaxid = lookup1.key1 then '"' || lookup1.division || '"'
      else '' end :: varchar(100) as client_division_name
,' ' ::char(1) as salutation
,pne.fname ::varchar(50) as fname
,pne.mname ::char(1) as mname
,pne.lname ::varchar(50) as lname
,pi.identity ::char(9) as SSN
,' ' ::char(1) as indv_id

,rtrim(ltrim(pncw.url)) ::varchar(100) as email 
,ppc.phoneno ::char(15) as phone
,' ' ::char(1) as phone2
,pae.streetaddress ::varchar(50) as addr1
,pae.streetaddress2 ::varchar(50) as addr2
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

,pve.gendercode ::char(1) as gender
,to_char(pve.birthdate, 'MM/dd/YYYY')::char(10) as dob
,case when pve.smoker = 'Y' then 'YES'
      when pve.smoker = 'N' then 'NO'
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
,'1A' ::char(10) as sort_seq


FROM person_identity pi

LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'AVS_BasicPacific_COBRA_QB_Export'

LEFT JOIN person_vitals pvE 
  ON pvE.personid = pi.personid 
 AND current_date between pvE.effectivedate AND pvE.enddate 
 AND current_timestamp between pvE.createts AND pvE.endts

LEFT JOIN person_names pne 
  ON pne.personid = pi.personid 
 AND pne.nametype = 'Legal'::bpchar 
 AND current_date between pne.effectivedate AND pne.enddate 
 AND current_timestamp between pne.createts AND pne.endts
 
JOIN person_employment pe 
  ON pe.personid = pi.personid 
 AND current_date between pe.effectivedate AND pe.enddate 
 AND current_timestamp between pe.createts AND pe.endts

LEFT JOIN person_address pae 
  ON pae.personid = pi.personid 
 AND pae.addresstype = 'Res'::bpchar 
 AND current_date between pae.effectivedate AND pae.enddate 
 AND current_timestamp between pae.createts AND pae.endts

LEFT JOIN person_phone_contacts ppc
 ON ppc.personid = pi.personid
 AND current_date between ppc.effectivedate and ppc.enddate
 AND current_timestamp between ppc.createts and ppc.endts 
 
LEFT JOIN person_net_contacts pncw 
  ON pncw.personid = pi.personid 
 AND pncw.netcontacttype = 'WRK'::bpchar 
 AND current_date between pncw.effectivedate and pncw.enddate
 AND current_timestamp between pncw.createts and pncw.endts

left join pers_pos pp 
  on pp.personid = pe.personid
 and current_date between pp.effectivedate and pp.enddate
 and current_timestamp between pp.createts and pp.endts
 
left join position_desc pd
  on pd.positionid = pp.positionid
 and current_date between pd.effectivedate and pd.enddate
 and current_timestamp between pd.createts and pd.endts 

-- for termed ee's

join person_benefit_action pba
  on pba.personid = pe.personid
 and pba.eventname in ('TER','RET')    

JOIN person_bene_election pbe 
  on pbe.personid = pba.personid 
 and pbe.personbenefitactionpid = pba.personbenefitactionpid  
 and pbe.selectedoption = 'Y' 
 and pbe.benefitelection <> 'W'
 and pbe.benefitsubclass in ('10','11','14','60')
/*
For cobra - need to make sure that they had elected benefit coverage on their last day of employment 
(effectivedate - 1 day of term record) is between the effectivedate 
and enddate of the person_bene_election row with benefitelection = 'E' 
*/
 AND current_date between pbe.effectivedate and pbe.enddate
 AND current_timestamp between pbe.createts AND pbe.endts
  -- to be qualified for cobra the emp must have participated in employer's health care plan  
and pbe.personid in (select personid from person_bene_election where benefitsubclass in ('10','11','14','60') and benefitelection = 'E' and selectedoption = 'Y' 
                        and current_timestamp between createts and endts and effectivedate < enddate and date_part('year',deductionstartdate::date)=date_part('year',pe.effectivedate::date - interval '1 Day'))
and pe.effectivedate - interval '1 day' < pbe.effectivedate

left join person_payroll perpay on perpay.personid = pi.personid
AND current_date between perpay.effectivedate and perpay.enddate
AND current_timestamp between perpay.createts and perpay.endts

left join pay_unit pu on pu.payunitid = perpay.payunitid
AND current_timestamp between pu.createts and pu.endts

JOIN  (select lp.lookupid, lp.key1, lp.value1 as client from edi.lookup lp
    join edi.lookup_schema els on lp.lookupid = els.lookupid and els.lookupname = 'Client Name Lookup' and lp.lookupid = els.lookupid
    --join pay_unit pu on lp.key1 = pu.employertaxid AND current_timestamp between pu.createts and pu.endts
	--where current_date between lp.effectivedate and lp.enddate and current_timestamp between lp.createts and lp.endts
    ) lookup on lookup.lookupid is not null and lookup.key1 = pu.employertaxid                                        
-- ------------------------------------------
join (select lp1.lookupid, lp1.key1, lp1.value1 as division from edi.lookup lp1
    join edi.lookup_schema els1 on lp1.lookupid = els1.lookupid and els1.lookupname = 'Division Name Lookup' and lp1.lookupid = els1.lookupid
    --join pay_unit pu on lp1.key1 = pu.employertaxid AND current_timestamp between pu.createts and pu.endts 
	--where current_date between lp1.effectivedate and lp1.enddate and current_timestamp between lp1.createts and lp1.endts 
    ) lookup1 on lookup1.lookupid is not null and lookup1.key1 = pu.employertaxid  

WHERE pi.identitytype = 'SSN' 
  and current_timestamp between pi.createts and pi.endts
  and pe.emplstatus in ('T','R') 
  and pe.benefitstatus in ('T','A')
  --and pbe.createts >= '20181101'::DATE 
  and (pbe.effectivedate >= elu.lastupdatets::DATE 
   or (pbe.createts > elu.lastupdatets and pbe.effectivedate < coalesce(elu.lastupdatets, '2017-01-01')) )   
  and pe.empleventdetcode <> 'Death'

-- ---------------------------------------------------------------------------------------------------------------------------------------- TERMED End
union	
-- ---------------------------------------------------------------------------------------------------------------------------------------- FT/PT Start

SELECT distinct  
 pi.personid
,pu.payunitxid::char(2)
, 'FT/PT EE'::varchar(30)		-- reduction in hours qualifying event
,'[QB]' :: varchar(35) as recordtype
,case when pu.employertaxid = lookup.key1 then '"' || lookup.client || '"'
      else '' end :: varchar(100) as client_name
,case when pu.employertaxid = lookup1.key1 then '"' || lookup1.division || '"'
      else '' end :: varchar(100) as client_division_name
,' ' ::char(1) as salutation
,pne.fname ::varchar(50) as fname
,pne.mname ::char(1) as mname
,pne.lname ::varchar(50) as lname
,pi.identity ::char(9) as SSN
,' ' ::char(1) as indv_id

,rtrim(ltrim(pncw.url)) ::varchar(100) as email 
,ppc.phoneno ::char(15) as phone
,' ' ::char(1) as phone2
,pae.streetaddress ::varchar(50) as addr1
,pae.streetaddress2 ::varchar(50) as addr2
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

,pve.gendercode ::char(1) as gender
,to_char(pve.birthdate, 'MM/dd/YYYY')::char(10) as dob
,case when pve.smoker = 'Y' then 'YES'
      when pve.smoker = 'N' then 'NO'
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
,'1A' ::char(10) as sort_seq


FROM person_identity pi

LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'AVS_BasicPacific_COBRA_QB_Export'

LEFT JOIN person_vitals pvE 
  ON pvE.personid = pi.personid 
 AND current_date between pvE.effectivedate AND pvE.enddate 
 AND current_timestamp between pvE.createts AND pvE.endts

LEFT JOIN person_names pne 
  ON pne.personid = pi.personid 
 AND pne.nametype = 'Legal'::bpchar 
 AND current_date between pne.effectivedate AND pne.enddate 
 AND current_timestamp between pne.createts AND pne.endts
 
JOIN person_employment pe 
  ON pe.personid = pi.personid 
 and pe.emplclass <> 'P'
 AND current_date between pe.effectivedate AND pe.enddate 
 AND current_timestamp between pe.createts AND pe.endts

LEFT JOIN person_address pae 
  ON pae.personid = pi.personid 
 AND pae.addresstype = 'Res'::bpchar 
 AND current_date between pae.effectivedate AND pae.enddate 
 AND current_timestamp between pae.createts AND pae.endts

LEFT JOIN person_phone_contacts ppc
 ON ppc.personid = pi.personid
 AND current_date between ppc.effectivedate and ppc.enddate
 AND current_timestamp between ppc.createts and ppc.endts   
 
LEFT JOIN person_net_contacts pncw 
  ON pncw.personid = pi.personid 
 AND pncw.netcontacttype = 'WRK'::bpchar 
 AND current_date between pncw.effectivedate and pncw.enddate
 AND current_timestamp between pncw.createts and pncw.endts

left join pers_pos pp 
  on pp.personid = pe.personid
 and current_date between pp.effectivedate and pp.enddate
 and current_timestamp between pp.createts and pp.endts
 
left join position_desc pd
  on pd.positionid = pp.positionid
 and current_date between pd.effectivedate and pd.enddate
 and current_timestamp between pd.createts and pd.endts 

-- for termed ee's

join person_benefit_action pba
  on pba.personid = pe.personid
 and pba.eventname in ('FTP','RED')    

JOIN person_bene_election pbe 
  on pbe.personid = pba.personid 
 and pbe.personbenefitactionpid = pba.personbenefitactionpid  
 and pbe.selectedoption = 'Y' 
 and pbe.benefitelection <> 'W'
 and pbe.benefitsubclass in ('10','11','14','60')
/*
For cobra - need to make sure that they had elected benefit coverage on their last day of employment 
(effectivedate - 1 day of term record) is between the effectivedate 
and enddate of the person_bene_election row with benefitelection = 'E' 
*/
 AND current_date between pbe.effectivedate and pbe.enddate
 AND current_timestamp between pbe.createts AND pbe.endts
  -- to be qualified for cobra the emp must have participated in employer's health care plan  
and pbe.personid in (select personid from person_bene_election where benefitsubclass in ('10','11','14','60') and benefitelection = 'E' and selectedoption = 'Y' 
                        and current_timestamp between createts and endts and effectivedate < enddate and date_part('year',deductionstartdate::date)=date_part('year',pe.effectivedate::date - interval '1 Day'))
and pe.effectivedate - interval '1 day' < pbe.effectivedate
  

left join person_payroll perpay on perpay.personid = pi.personid
AND current_date between perpay.effectivedate and perpay.enddate
AND current_timestamp between perpay.createts and perpay.endts

left join pay_unit pu on pu.payunitid = perpay.payunitid
AND current_timestamp between pu.createts and pu.endts

 -- -------------------------------------------
JOIN  (select lp.lookupid, lp.key1, lp.value1 as client from edi.lookup lp
    join edi.lookup_schema els on lp.lookupid = els.lookupid and els.lookupname = 'Client Name Lookup' 
    join pay_unit pu on lp.key1 = pu.employertaxid AND current_timestamp between pu.createts and pu.endts
	where current_date between lp.effectivedate and lp.enddate and current_timestamp between lp.createts and lp.endts
    ) lookup on lookup.lookupid is not null and lookup.key1 = pu.employertaxid                                        
-- ------------------------------------------
LEFT JOIN  (select lp1.lookupid, lp1.key1, lp1.value1 as division from edi.lookup lp1
    join edi.lookup_schema els1 on lp1.lookupid = els1.lookupid and els1.lookupname = 'Division Name Lookup'
    join pay_unit pu on lp1.key1 = pu.employertaxid AND current_timestamp between pu.createts and pu.endts 
	where current_date between lp1.effectivedate and lp1.enddate and current_timestamp between lp1.createts and lp1.endts 
    ) lookup1 on lookup1.lookupid is not null and lookup1.key1 = pu.employertaxid                                         
-- ------------------------------------------

WHERE pi.identitytype = 'SSN' 
  and current_timestamp between pi.createts and pi.endts
  and pe.emplstatus not in ('T','R') 
  and pe.emplevent in ('FullPart','LvReturn')
  --and pbe.createts >= '20181101'::DATE 
  and (pbe.effectivedate >= elu.lastupdatets::DATE 
   or (pbe.createts > elu.lastupdatets and pbe.effectivedate < coalesce(elu.lastupdatets, '2017-01-01')) )   

-- ----------------------------------------------------------------------------------------------------------------------------------
union
-- ---------------------------------------------------------------------------------------------------------------------------------

SELECT distinct  
 pi.personid
,pu.payunitxid::char(2)
, 'TERMED EE DEP'::varchar(30)		-- reduction in hours qualifying event
,'[QB]' :: varchar(35) as recordtype
,case when pu.employertaxid = lookup.key1 then '"' || lookup.client || '"'
      else '' end :: varchar(100) as client_name
,case when pu.employertaxid = lookup1.key1 then '"' || lookup1.division || '"'
      else '' end :: varchar(100) as client_division_name
,' ' ::char(1) as salutation
,pne.fname ::varchar(50) as fname
,pne.mname ::char(1) as mname
,pne.lname ::varchar(50) as lname
,pi.identity ::char(9) as SSN
,' ' ::char(1) as indv_id

,rtrim(ltrim(pncw.url)) ::varchar(100) as email 
,ppc.phoneno ::char(15) as phone
,' ' ::char(1) as phone2
,pae.streetaddress ::varchar(50) as addr1
,pae.streetaddress2 ::varchar(50) as addr2
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

,pve.gendercode ::char(1) as gender
,to_char(pve.birthdate, 'MM/dd/YYYY')::char(10) as dob
,case when pve.smoker = 'Y' then 'YES'
      when pve.smoker = 'N' then 'NO'
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
,'1A' ::char(10) as sort_seq

FROM person_identity pi

LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'AVS_BasicPacific_COBRA_QB_Export'

LEFT JOIN person_vitals pvE 
  ON pvE.personid = pi.personid 
 AND current_date between pvE.effectivedate AND pvE.enddate 
 AND current_timestamp between pvE.createts AND pvE.endts

LEFT JOIN person_names pne 
  ON pne.personid = pi.personid 
 AND pne.nametype = 'Legal'::bpchar 
 AND current_date between pne.effectivedate AND pne.enddate 
 AND current_timestamp between pne.createts AND pne.endts
 
JOIN person_employment pe 
  ON pe.personid = pi.personid 
 and pe.emplclass <> 'P'
 AND current_date between pe.effectivedate AND pe.enddate 
 AND current_timestamp between pe.createts AND pe.endts

LEFT JOIN person_address pae 
  ON pae.personid = pi.personid 
 AND pae.addresstype = 'Res'::bpchar 
 AND current_date between pae.effectivedate AND pae.enddate 
 AND current_timestamp between pae.createts AND pae.endts

LEFT JOIN person_phone_contacts ppc
 ON ppc.personid = pi.personid
 AND current_date between ppc.effectivedate and ppc.enddate
 AND current_timestamp between ppc.createts and ppc.endts 

LEFT JOIN person_net_contacts pncw 
  ON pncw.personid = pi.personid 
 AND pncw.netcontacttype = 'WRK'::bpchar 
 AND current_date between pncw.effectivedate and pncw.enddate
 AND current_timestamp between pncw.createts and pncw.endts 

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

JOIN person_bene_election pbe 
  on pbe.personid = pba.personid 
 and pbe.personbenefitactionpid = pba.personbenefitactionpid  
 and pbe.selectedoption = 'Y' 
 and pbe.benefitelection <> 'W'
 and pbe.benefitsubclass in ('10','11','14','60')
/*
For cobra - need to make sure that they had elected benefit coverage on their last day of employment 
(effectivedate - 1 day of term record) is between the effectivedate 
and enddate of the person_bene_election row with benefitelection = 'E' 
*/
 AND current_date between pbe.effectivedate and pbe.enddate
 AND current_timestamp between pbe.createts AND pbe.endts
  -- to be qualified for cobra the emp must have participated in employer's health care plan  
and pbe.personid in (select personid from person_bene_election where benefitsubclass in ('10','11','14','60') and benefitelection = 'E' and selectedoption = 'Y' 
                        and current_timestamp between createts and endts and effectivedate < enddate and date_part('year',deductionstartdate::date)=date_part('year',pe.effectivedate::date - interval '1 Day'))
and pe.effectivedate - interval '1 day' < pbe.effectivedate
  
join person_dependent_relationship pdr
  on pdr.personid = pi.personid
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
     and pne.effectivedate < pne.enddate
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
     and pvd.effectivedate < pvd.enddate
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
     and pe.effectivedate < pe.enddate
    join person_bene_election pbe
      on pbe.personid = de.personid
     and pbe.benefitsubclass in ('10','11','14','60')
     and pbe.selectedoption = 'Y'
     and current_timestamp between pbe.createts and pbe.endts 
     and pbe.effectivedate < pbe.enddate    
   where current_timestamp between de.createts and de.endts
    and de.benefitsubclass in ('10','11','14','60')
    and pe.emplstatus = 'A'
    and pbe.benefitelection = 'E'
    and date_part('year',de.enddate)=date_part('year',current_date)    
    and de.dependentid not in 
   (select distinct de.dependentid from dependent_enrollment de
      join person_dependent_relationship pdr
        on pdr.personid = de.personid
       and pdr.dependentid = de.dependentid
       and current_timestamp between pdr.createts and pdr.endts
       and pdr.effectivedate < pdr.enddate
     where current_date between de.effectivedate and de.enddate
       and current_timestamp between de.createts and de.endts
       and de.benefitsubclass in ('10','11','14','60')
   )
)  

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

left join person_payroll perpay on perpay.personid = pi.personid
AND current_date between perpay.effectivedate and perpay.enddate
AND current_timestamp between perpay.createts and perpay.endts

left join pay_unit pu on pu.payunitid = perpay.payunitid
AND current_timestamp between pu.createts and pu.endts

 -- -------------------------------------------
JOIN  (select lp.lookupid, lp.key1, lp.value1 as client from edi.lookup lp
    join edi.lookup_schema els on lp.lookupid = els.lookupid and els.lookupname = 'Client Name Lookup' 
    join pay_unit pu on lp.key1 = pu.employertaxid AND current_timestamp between pu.createts and pu.endts
	where current_date between lp.effectivedate and lp.enddate and current_timestamp between lp.createts and lp.endts
    ) lookup on lookup.lookupid is not null and lookup.key1 = pu.employertaxid                                        
-- ------------------------------------------
LEFT JOIN  (select lp1.lookupid, lp1.key1, lp1.value1 as division from edi.lookup lp1
    join edi.lookup_schema els1 on lp1.lookupid = els1.lookupid and els1.lookupname = 'Division Name Lookup'
    join pay_unit pu on lp1.key1 = pu.employertaxid AND current_timestamp between pu.createts and pu.endts 
	where current_date between lp1.effectivedate and lp1.enddate and current_timestamp between lp1.createts and lp1.endts 
    ) lookup1 on lookup1.lookupid is not null and lookup1.key1 = pu.employertaxid                                         
-- ------------------------------------------

WHERE pi.identitytype = 'SSN' 
  and current_timestamp between pi.createts and pi.endts
  and de.enddate = (pbe.effectivedate - interval '1 day')   --HS 10/24/2218--
  and pe.emplstatus in ('T','R') 
  and pbe.benefitelection <> 'W' 
  --and pbe.createts >= '20181101'::DATE 
  and (pbe.effectivedate >= elu.lastupdatets::DATE 
   or (pbe.createts > elu.lastupdatets and pbe.effectivedate < coalesce(elu.lastupdatets, '2017-01-01')) )   
  and pe.empleventdetcode <> 'Death'

-- ----------------------------------------------------------------------------------------------------------------------------------
union
-- ---------------------------------------------------------------------------------------------------------------------------------

SELECT distinct  
 pi.personid
,pu.payunitxid::char(2)
, 'DIVORCELEGALSEPARATION'::varchar(30)	
,'[QB]' :: varchar(35) as recordtype
,case when pu.employertaxid = lookup.key1 then '"' || lookup.client || '"'
      else '' end :: varchar(100) as client_name
,case when pu.employertaxid = lookup1.key1 then '"' || lookup1.division || '"'
      else '' end :: varchar(100) as client_division_name
,' ' ::char(1) as salutation
,pnd.fname ::varchar(50) as fname
,pnd.mname ::char(1) as mname
,pnd.lname ::varchar(50) as lname
,pi.identity ::char(9) as SSN
,' ' ::char(1) as indv_id

,rtrim(ltrim(pncw.url)) ::varchar(100) as email 
,ppc.phoneno ::char(15) as phone
,' ' ::char(1) as phone2
,pae.streetaddress ::varchar(50) as addr1
,pae.streetaddress2 ::varchar(50) as addr2
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
,'' ::varchar(35) as EmployeePayrollType

,' ' ::char(1) as years_of_service
,'COUPONBOOK' ::varchar(35) AS PremiumCouponType    
,'F' ::char(1) as UsesHCTC
,'T' ::char(1) as active
,'F' ::char(1) as allow__member_sso
,' ' ::char(1) as benefitgroup
,' ' ::char(1) as account_structure
,' ' ::char(1) as client_specific_data
,'1A' ::char(10) as sort_seq

FROM person_identity pi

LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'AVS_BasicPacific_COBRA_QB_Export'

JOIN person_employment pe 
  ON pe.personid = pi.personid 
 AND current_date between pe.effectivedate AND pe.enddate 
 AND current_timestamp between pe.createts AND pe.endts 

join person_dependent_relationship pdr
  on pdr.personid = pe.personid
 and current_date between pdr.effectivedate and pdr.enddate
 and current_timestamp between pdr.createts and pdr.endts


LEFT JOIN person_address pae 
  ON pae.personid = pdr.dependentid 
 AND pae.addresstype = 'Res'::bpchar 
 AND current_date between pae.effectivedate AND pae.enddate 
 AND current_timestamp between pae.createts AND pae.endts

LEFT JOIN person_names pnd 
  ON pnd.personid = pdr.dependentid 
 and current_date between pnd.effectivedate and pnd.enddate
and current_timestamp between pnd.createts and pnd.endts

LEFT JOIN person_vitals pvd
  ON pvd.personid = pdr.dependentid 
 and current_date between pvd.effectivedate and pvd.enddate
and current_timestamp between pvd.createts and pvd.endts

LEFT JOIN person_phone_contacts ppc
ON ppc.personid = pdr.dependentid
AND current_date between ppc.effectivedate and ppc.enddate
AND current_timestamp between ppc.createts and ppc.endts  
 
LEFT JOIN person_net_contacts pncw 
  ON pncw.personid = pdr.dependentid 
 AND pncw.netcontacttype = 'WRK'::bpchar 
 AND current_date between pncw.effectivedate and pncw.enddate
AND current_timestamp between pncw.createts and pncw.endts


left join person_payroll perpay on perpay.personid = pe.personid
AND current_date between perpay.effectivedate and perpay.enddate
AND current_timestamp between perpay.createts and perpay.endts

left join pay_unit pu on pu.payunitid = perpay.payunitid
AND current_timestamp between pu.createts and pu.endts


-- -------------------------------------------
JOIN  (select lp.lookupid, lp.key1, lp.value1 as client from edi.lookup lp
    join edi.lookup_schema els on lp.lookupid = els.lookupid and els.lookupname = 'Client Name Lookup' 
    join pay_unit pu on lp.key1 = pu.employertaxid AND current_timestamp between pu.createts and pu.endts
	where current_date between lp.effectivedate and lp.enddate and current_timestamp between lp.createts and lp.endts
    ) lookup on lookup.lookupid is not null and lookup.key1 = pu.employertaxid                                        
-- ------------------------------------------
LEFT JOIN  (select lp1.lookupid, lp1.key1, lp1.value1 as division from edi.lookup lp1
    join edi.lookup_schema els1 on lp1.lookupid = els1.lookupid and els1.lookupname = 'Division Name Lookup'
    join pay_unit pu on lp1.key1 = pu.employertaxid AND current_timestamp between pu.createts and pu.endts 
	where current_date between lp1.effectivedate and lp1.enddate and current_timestamp between lp1.createts and lp1.endts 
    ) lookup1 on lookup1.lookupid is not null and lookup1.key1 = pu.employertaxid                                         
-- ------------------------------------------


WHERE pi.identitytype = 'SSN' 
  and current_timestamp between pi.createts and pi.endts
 and pdr.dependentrelationship in ('SP','X','NA','DP')

and pe.personid in (
select distinct pe.personid

from person_employment pe

join person_benefit_action pba
  on pba.personid = pe.personid
 and pba.eventname in ('DIV')   

JOIN person_bene_election pbe 
  on pbe.personid = pba.personid 
 and pbe.personbenefitactionpid = pba.personbenefitactionpid  
 and pbe.selectedoption = 'Y' 
 and pbe.benefitelection <> 'W'
and pbe.benefitsubclass in ('10','11','14','60')
and pbe.personid in (select personid from person_bene_election where benefitsubclass in ('10','11','14','60') and benefitelection = 'E' and selectedoption = 'Y' 
                        and current_timestamp between createts and endts and effectivedate < enddate and date_part('year',deductionstartdate::date)=date_part('year',pe.effectivedate::date - interval '1 Day'))

  
join person_dependent_relationship pdr
  on pdr.personid = pbe.personid
 and current_date between pdr.effectivedate and pdr.enddate
 and current_timestamp between pdr.createts and pdr.endts

join dependent_enrollment de
  on de.personid = pdr.personid
and de.dependentid = pdr.dependentid
and de.selectedoption = 'Y'
and de.benefitplanid = pbe.benefitplanid
and de.benefitsubclass = pbe.benefitsubclass
and current_date >= de.effectivedate 
 and current_timestamp between de.createts and de.endts  

 where current_date between pe.effectivedate AND pe.enddate 
 AND current_timestamp between pe.createts AND pe.endts
 and pe.emplstatus not in ('T','R') 
 and pe.emplclass <> 'P'
 and pe.benefitstatus in ('T','A')
 --and pbe.createts >= '20181101'::DATE 
 and (pbe.effectivedate >= elu.lastupdatets::DATE 
  or (pbe.createts > elu.lastupdatets and pbe.effectivedate < coalesce(elu.lastupdatets, '2017-01-01')) )   
)  

-- ----------------------------------------------------------------------------------------------------------------------------------
union
-- ---------------------------------------------------------------------------------------------------------------------------------

SELECT distinct  
 pi.personid
,pu.payunitxid::char(2)
, 'ACTIVE EE TERMED DEP'::varchar(30)	
,'[QB]' :: varchar(35) as recordtype
,case when pu.employertaxid = lookup.key1 then '"' || lookup.client || '"'
      else '' end :: varchar(100) as client_name
,case when pu.employertaxid = lookup1.key1 then '"' || lookup1.division || '"'
      else '' end :: varchar(100) as client_division_name
,' ' ::char(1) as salutation
,pne.fname ::varchar(50) as fname
,pne.mname ::char(1) as mname
,pne.lname ::varchar(50) as lname
,pi.identity ::char(9) as SSN
,' ' ::char(1) as indv_id

,rtrim(ltrim(pncw.url)) ::varchar(100) as email 
,ppc.phoneno ::char(15) as phone
,' ' ::char(1) as phone2
,pae.streetaddress ::varchar(50) as addr1
,pae.streetaddress2 ::varchar(50) as addr2
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

,pve.gendercode ::char(1) as gender
,to_char(pve.birthdate, 'MM/dd/YYYY')::char(10) as dob
,case when pve.smoker = 'Y' then 'YES'
      when pve.smoker = 'N' then 'NO'
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
,'1A' ::char(10) as sort_seq

FROM person_identity pi

LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'AVS_BasicPacific_COBRA_QB_Export'

JOIN person_employment pe 
  ON pe.personid = pi.personid 
 AND current_date between pe.effectivedate AND pe.enddate 
 AND current_timestamp between pe.createts AND pe.endts 

LEFT JOIN person_names pne 
  ON pne.personid = pi.personid 
 AND pne.nametype = 'Legal'::bpchar 
 AND current_date between pne.effectivedate AND pne.enddate 
 AND current_timestamp between pne.createts AND pne.endts

LEFT JOIN person_address pae 
  ON pae.personid = pi.personid 
 AND pae.addresstype = 'Res'::bpchar 
 AND current_date between pae.effectivedate AND pae.enddate 
 AND current_timestamp between pae.createts AND pae.endts

LEFT JOIN person_phone_contacts ppc
 ON ppc.personid = pi.personid
 AND current_date between ppc.effectivedate and ppc.enddate
 AND current_timestamp between ppc.createts and ppc.endts 
 
LEFT JOIN person_net_contacts pncw 
  ON pncw.personid = pi.personid 
 AND pncw.netcontacttype = 'WRK'::bpchar 
 AND current_date between pncw.effectivedate and pncw.enddate
 AND current_timestamp between pncw.createts and pncw.endts

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

JOIN person_bene_election pbe 
  on pbe.personid = pba.personid 
 and pbe.personbenefitactionpid = pba.personbenefitactionpid  
 and pbe.selectedoption = 'Y' 
 and pbe.benefitelection <> 'W'
 and pbe.benefitsubclass in ('10','11','14','60')
/*
For cobra - need to make sure that they had elected benefit coverage on their last day of employment 
(effectivedate - 1 day of term record) is between the effectivedate 
and enddate of the person_bene_election row with benefitelection = 'E' 
*/
 AND current_date between pbe.effectivedate and pbe.enddate
 AND current_timestamp between pbe.createts AND pbe.endts
  -- to be qualified for cobra the emp must have participated in employer's health care plan  
and pbe.personid in (select personid from person_bene_election where benefitsubclass in ('10','11','14','60') and benefitelection = 'E' and selectedoption = 'Y' 
                        and current_timestamp between createts and endts and effectivedate < enddate and date_part('year',deductionstartdate::date)=date_part('year',pe.effectivedate::date - interval '1 Day'))
and pe.effectivedate - interval '1 day' < pbe.effectivedate
  
join person_dependent_relationship pdr
  on pdr.personid = pi.personid
 and current_date between pdr.effectivedate and pdr.enddate
 and current_timestamp between pdr.createts and pdr.endts

join dependent_enrollment de
  on de.dependentid = pdr.dependentid
 and de.benefitsubclass = pbe.benefitsubclass
 and de.personid = pbe.personid
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
     and pbe.benefitsubclass in ('10','11','14','60')
     and pbe.selectedoption = 'Y'
     and current_date between pbe.effectivedate and pbe.enddate
     and current_timestamp between pbe.createts and pbe.endts     
   where current_timestamp between de.createts and de.endts
    and de.benefitsubclass in ('10','11','14','60')
    --and pdr.dependentrelationship in ('S','D','C','NC','NS','ND')
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
       and de.benefitsubclass in ('10','11','14','60')-- and de.dependentid = '1964'
       --and pdr.dependentrelationship in ('S','D','C','NC','NS','ND')
   )
) 

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

left join person_vitals pve
  on pve.personid = pi.personid
 and current_date between pve.effectivedate and pve.enddate
 and current_timestamp between pve.createts and pve.endts

left join person_payroll perpay on perpay.personid = pi.personid
AND current_date between perpay.effectivedate and perpay.enddate
AND current_timestamp between perpay.createts and perpay.endts

left join pay_unit pu on pu.payunitid = perpay.payunitid
AND current_timestamp between pu.createts and pu.endts

-- -------------------------------------------
JOIN  (select lp.lookupid, lp.key1, lp.value1 as client from edi.lookup lp
    join edi.lookup_schema els on lp.lookupid = els.lookupid and els.lookupname = 'Client Name Lookup' 
    join pay_unit pu on lp.key1 = pu.employertaxid AND current_timestamp between pu.createts and pu.endts
	where current_date between lp.effectivedate and lp.enddate and current_timestamp between lp.createts and lp.endts
    ) lookup on lookup.lookupid is not null and lookup.key1 = pu.employertaxid                                        
-- ------------------------------------------
LEFT JOIN  (select lp1.lookupid, lp1.key1, lp1.value1 as division from edi.lookup lp1
    join edi.lookup_schema els1 on lp1.lookupid = els1.lookupid and els1.lookupname = 'Division Name Lookup'
    join pay_unit pu on lp1.key1 = pu.employertaxid AND current_timestamp between pu.createts and pu.endts 
	where current_date between lp1.effectivedate and lp1.enddate and current_timestamp between lp1.createts and lp1.endts 
    ) lookup1 on lookup1.lookupid is not null and lookup1.key1 = pu.employertaxid                                         
-- ------------------------------------------

WHERE pi.identitytype = 'SSN' 
  and current_timestamp between pi.createts and pi.endts
  and pe.emplstatus not in ('T','R') 
  --and pbe.createts >= '20181101'::DATE 
  and (pbe.effectivedate >= elu.lastupdatets::DATE 
   or (pbe.createts > elu.lastupdatets and pbe.effectivedate < coalesce(elu.lastupdatets, '2017-01-01')) )

-- ----------------------------------------------------------------------------------------------------------------------------------
union
-- ---------------------------------------------------------------------------------------------------------------------------------

SELECT distinct  
 pi.personid
,pu.payunitxid::char(2)
, 'FT/PT DEP'::varchar(30)	
,'[QB]' :: varchar(35) as recordtype
,case when pu.employertaxid = lookup.key1 then '"' || lookup.client || '"'
      else '' end :: varchar(100) as client_name
,case when pu.employertaxid = lookup1.key1 then '"' || lookup1.division || '"'
      else '' end :: varchar(100) as client_division_name
,' ' ::char(1) as salutation
,pne.fname ::varchar(50) as fname
,pne.mname ::char(1) as mname
,pne.lname ::varchar(50) as lname
,pi.identity ::char(9) as SSN
,' ' ::char(1) as indv_id

,rtrim(ltrim(pncw.url)) ::varchar(100) as email 
,ppc.phoneno ::char(15) as phone
,' ' ::char(1) as phone2
,pae.streetaddress ::varchar(50) as addr1
,pae.streetaddress2 ::varchar(50) as addr2
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

,pve.gendercode ::char(1) as gender
,to_char(pve.birthdate, 'MM/dd/YYYY')::char(10) as dob
,case when pve.smoker = 'Y' then 'YES'
      when pve.smoker = 'N' then 'NO'
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
,'1A' ::char(10) as sort_seq

FROM person_identity pi

LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'AVS_BasicPacific_COBRA_QB_Export'

JOIN person_employment pe 
  ON pe.personid = pi.personid 
 AND current_date between pe.effectivedate AND pe.enddate 
 AND current_timestamp between pe.createts AND pe.endts 

LEFT JOIN person_names pne 
  ON pne.personid = pi.personid 
 AND pne.nametype = 'Legal'::bpchar 
 AND current_date between pne.effectivedate AND pne.enddate 
 AND current_timestamp between pne.createts AND pne.endts

LEFT JOIN person_address pae 
  ON pae.personid = pi.personid 
 AND pae.addresstype = 'Res'::bpchar 
 AND current_date between pae.effectivedate AND pae.enddate 
 AND current_timestamp between pae.createts AND pae.endts

LEFT JOIN person_phone_contacts ppc
 ON ppc.personid = pi.personid
 AND current_date between ppc.effectivedate and ppc.enddate
 AND current_timestamp between ppc.createts and ppc.endts 
 
LEFT JOIN person_net_contacts pncw 
  ON pncw.personid = pi.personid 
 AND pncw.netcontacttype = 'WRK'::bpchar 
 AND current_date between pncw.effectivedate and pncw.enddate
 AND current_timestamp between pncw.createts and pncw.endts

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
   and pba.eventname in ('FTP','RED')    

JOIN person_bene_election pbe 
  on pbe.personid = pba.personid 
 and pbe.personbenefitactionpid = pba.personbenefitactionpid  
 and pbe.selectedoption = 'Y' 
 and pbe.benefitelection <> 'W'
 and pbe.benefitsubclass in ('10','11','14','60')
/*
For cobra - need to make sure that they had elected benefit coverage on their last day of employment 
(effectivedate - 1 day of term record) is between the effectivedate 
and enddate of the person_bene_election row with benefitelection = 'E' 
*/
 AND current_date between pbe.effectivedate and pbe.enddate
 AND current_timestamp between pbe.createts AND pbe.endts
  -- to be qualified for cobra the emp must have participated in employer's health care plan  
and pbe.personid in (select personid from person_bene_election where benefitsubclass in ('10','11','14','60') and benefitelection = 'E' and selectedoption = 'Y' 
                        and current_timestamp between createts and endts and effectivedate < enddate and date_part('year',deductionstartdate::date)=date_part('year',pe.effectivedate::date - interval '1 Day'))
and pe.effectivedate - interval '1 day' < pbe.effectivedate
  
join person_dependent_relationship pdr
  on pdr.personid = pi.personid
 and current_date between pdr.effectivedate and pdr.enddate
 and current_timestamp between pdr.createts and pdr.endts

join dependent_enrollment de
  on de.personid = pdr.personid
 and de.dependentid = pdr.dependentid
 and de.selectedoption = 'Y'
 and de.benefitplanid = pbe.benefitplanid
 and de.benefitsubclass = pbe.benefitsubclass
 and current_date >= de.effectivedate 
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

left join person_vitals pve
  on pve.personid = pi.personid
 and current_date between pve.effectivedate and pve.enddate
 and current_timestamp between pve.createts and pve.endts

left join person_payroll perpay on perpay.personid = pi.personid
AND current_date between perpay.effectivedate and perpay.enddate
AND current_timestamp between perpay.createts and perpay.endts

left join pay_unit pu on pu.payunitid = perpay.payunitid
AND current_timestamp between pu.createts and pu.endts

-- -------------------------------------------
JOIN  (select lp.lookupid, lp.key1, lp.value1 as client from edi.lookup lp
    join edi.lookup_schema els on lp.lookupid = els.lookupid and els.lookupname = 'Client Name Lookup' 
    join pay_unit pu on lp.key1 = pu.employertaxid AND current_timestamp between pu.createts and pu.endts
	where current_date between lp.effectivedate and lp.enddate and current_timestamp between lp.createts and lp.endts
    ) lookup on lookup.lookupid is not null and lookup.key1 = pu.employertaxid                                        
-- ------------------------------------------
LEFT JOIN  (select lp1.lookupid, lp1.key1, lp1.value1 as division from edi.lookup lp1
    join edi.lookup_schema els1 on lp1.lookupid = els1.lookupid and els1.lookupname = 'Division Name Lookup'
    join pay_unit pu on lp1.key1 = pu.employertaxid AND current_timestamp between pu.createts and pu.endts 
	where current_date between lp1.effectivedate and lp1.enddate and current_timestamp between lp1.createts and lp1.endts 
    ) lookup1 on lookup1.lookupid is not null and lookup1.key1 = pu.employertaxid                                         
-- ------------------------------------------

WHERE pi.identitytype = 'SSN' 
  and current_timestamp between pi.createts and pi.endts
  and pe.emplstatus not in ('T','R') 
  --and pbe.createts >= '20181101'::DATE 
  and (pbe.effectivedate >= elu.lastupdatets::DATE 
   or (pbe.createts > elu.lastupdatets and pbe.effectivedate < coalesce(elu.lastupdatets, '2017-01-01')) )

-- ----------------------------------------------------------------------------------------------------------------------------------
union
-- ---------------------------------------------------------------------------------------------------------------------------------

SELECT distinct  
 pi.personid
,pu.payunitxid::char(2)
, 'CHILD OVER 26'::varchar(30)	
,'[QB]' :: varchar(35) as recordtype
,case when pu.employertaxid = lookup.key1 then '"' || lookup.client || '"'
      else '' end :: varchar(100) as client_name
,case when pu.employertaxid = lookup1.key1 then '"' || lookup1.division || '"'
      else '' end :: varchar(100) as client_division_name
,' ' ::char(1) as salutation
,pne.fname ::varchar(50) as fname
,pne.mname ::char(1) as mname
,pne.lname ::varchar(50) as lname
,pi.identity ::char(9) as SSN
,' ' ::char(1) as indv_id

,rtrim(ltrim(pncw.url)) ::varchar(100) as email 
,ppc.phoneno ::char(15) as phone
,' ' ::char(1) as phone2
,pae.streetaddress ::varchar(50) as addr1
,pae.streetaddress2 ::varchar(50) as addr2
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

,pve.gendercode ::char(1) as gender
,to_char(pve.birthdate, 'MM/dd/YYYY')::char(10) as dob
,case when pve.smoker = 'Y' then 'YES'
      when pve.smoker = 'N' then 'NO'
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
,'1A' ::char(10) as sort_seq

FROM person_identity pi

LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'AVS_BasicPacific_COBRA_QB_Export'

JOIN person_employment pe 
  ON pe.personid = pi.personid 
 AND current_date between pe.effectivedate AND pe.enddate 
 AND current_timestamp between pe.createts AND pe.endts 

LEFT JOIN person_names pne 
  ON pne.personid = pi.personid 
 AND pne.nametype = 'Legal'::bpchar 
 AND current_date between pne.effectivedate AND pne.enddate 
 AND current_timestamp between pne.createts AND pne.endts

LEFT JOIN person_address pae 
  ON pae.personid = pi.personid 
 AND pae.addresstype = 'Res'::bpchar 
 AND current_date between pae.effectivedate AND pae.enddate 
 AND current_timestamp between pae.createts AND pae.endts

LEFT JOIN person_phone_contacts ppc
 ON ppc.personid = pi.personid
 AND current_date between ppc.effectivedate and ppc.enddate
 AND current_timestamp between ppc.createts and ppc.endts   
 
LEFT JOIN person_net_contacts pncw 
  ON pncw.personid = pi.personid 
 AND pncw.netcontacttype = 'WRK'::bpchar 
 AND current_date between pncw.effectivedate and pncw.enddate
 AND current_timestamp between pncw.createts and pncw.endts

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
 and pba.eventname in ('DepAge')    

JOIN person_bene_election pbe 
  on pbe.personid = pba.personid 
 and pbe.personbenefitactionpid = pba.personbenefitactionpid  
 and pbe.selectedoption = 'Y' 
 and pbe.benefitelection <> 'W'
 and pbe.benefitsubclass in ('10','11','14','60')
/*
For cobra - need to make sure that they had elected benefit coverage on their last day of employment 
(effectivedate - 1 day of term record) is between the effectivedate 
and enddate of the person_bene_election row with benefitelection = 'E' 
*/
 AND current_date between pbe.effectivedate and pbe.enddate
 AND current_timestamp between pbe.createts AND pbe.endts
  -- to be qualified for cobra the emp must have participated in employer's health care plan  
and pbe.personid in (select personid from person_bene_election where benefitsubclass in ('10','11','14','60') and benefitelection = 'E' and selectedoption = 'Y' 
                        and current_timestamp between createts and endts and effectivedate < enddate and date_part('year',deductionstartdate::date)=date_part('year',pe.effectivedate::date - interval '1 Day'))
and pe.effectivedate - interval '1 day' < pbe.effectivedate
  
join person_dependent_relationship pdr
  on pdr.personid = pi.personid
 and current_date between pdr.effectivedate and pdr.enddate
 and current_timestamp between pdr.createts and pdr.endts

join dependent_enrollment de
  on de.dependentid = pdr.dependentid
 and de.benefitsubclass = pbe.benefitsubclass
 and de.personid = pbe.personid
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
     and pbe.benefitsubclass in ('10','11','14','60')
     and pbe.selectedoption = 'Y'
     and current_date between pbe.effectivedate and pbe.enddate
     and current_timestamp between pbe.createts and pbe.endts     
   where current_timestamp between de.createts and de.endts
    and de.benefitsubclass in ('10','11','14','60')
    and pdr.dependentrelationship in ('S','D','C','NC','NS','ND')
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
       and de.benefitsubclass in ('10','11','14','60')-- and de.dependentid = '1964'
       and pdr.dependentrelationship in ('S','D','C','NC','NS','ND')
   )
)   

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

left join person_vitals pve
  on pve.personid = pi.personid
 and current_date between pve.effectivedate and pve.enddate
 and current_timestamp between pve.createts and pve.endts

left join person_payroll perpay on perpay.personid = pi.personid
AND current_date between perpay.effectivedate and perpay.enddate
AND current_timestamp between perpay.createts and perpay.endts

left join pay_unit pu on pu.payunitid = perpay.payunitid
AND current_timestamp between pu.createts and pu.endts

-- -------------------------------------------
JOIN  (select lp.lookupid, lp.key1, lp.value1 as client from edi.lookup lp
    join edi.lookup_schema els on lp.lookupid = els.lookupid and els.lookupname = 'Client Name Lookup' 
    join pay_unit pu on lp.key1 = pu.employertaxid AND current_timestamp between pu.createts and pu.endts
	where current_date between lp.effectivedate and lp.enddate and current_timestamp between lp.createts and lp.endts
    ) lookup on lookup.lookupid is not null and lookup.key1 = pu.employertaxid                                        
-- ------------------------------------------
LEFT JOIN  (select lp1.lookupid, lp1.key1, lp1.value1 as division from edi.lookup lp1
    join edi.lookup_schema els1 on lp1.lookupid = els1.lookupid and els1.lookupname = 'Division Name Lookup'
    join pay_unit pu on lp1.key1 = pu.employertaxid AND current_timestamp between pu.createts and pu.endts 
	where current_date between lp1.effectivedate and lp1.enddate and current_timestamp between lp1.createts and lp1.endts 
    ) lookup1 on lookup1.lookupid is not null and lookup1.key1 = pu.employertaxid                                         
-- ------------------------------------------

WHERE pi.identitytype = 'SSN' 
  and current_timestamp between pi.createts and pi.endts
  and pdr.dependentrelationship in ('S','D','C','NS','ND','NC') 
  and current_date::date - interval '26 year' > pvd.birthdate::date   
  and pe.emplstatus not in ('T','R')
  --and pbe.createts >= '20181101'::DATE 
  and (pbe.effectivedate >= elu.lastupdatets::DATE 
   or (pbe.createts > elu.lastupdatets and pbe.effectivedate < coalesce(elu.lastupdatets, '2017-01-01')) )

order by personid

