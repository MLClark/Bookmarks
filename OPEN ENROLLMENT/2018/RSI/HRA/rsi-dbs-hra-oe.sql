select distinct
 pi.personid
,'0' ::char(1) as sort_seq
,'ACTIVE EE' ::varchar(30) as qsource 
,replace(pu.employertaxid,'-','')::varchar(20) as client_federal_id
,'0'::char(1) as plan_year_id
,pi.identity ::varchar(20) as participant_id
,'1'::char(1) as participant_id_type
,' ' ::varchar(20) as dependent_id
,pn.fname::varchar(30) as fname
,pn.mname::char(1) as mname
,ltrim(pn.lname)::varchar(30) as lname
,to_char(pv.birthdate,'mmddyyyy')::char(8) as dob
,coalesce(ppch.phoneno,ppcw.phoneno,ppcm.phoneno,ppcb.phoneno) ::varchar(16) AS phone
,pa.streetaddress ::varchar(30) as addr1
,pa.streetaddress2 ::varchar(30) as addr2
,pa.city ::varchar(30) as city
,pa.stateprovincecode ::char(2) as state
,pa.postalcode ::varchar(16) as zip
,coalesce(pncw.url,pnch.url) ::varchar(50) AS email
,case when bpdhra.benefitsubclass = '1Y' then 'HRA' else 'MED' end ::varchar(30) as enrollee_plan_type

,case when pbehra.benefitsubclass = '1Y' and bcdhra.benefitcoveragedescshort = 'Empl Only' then 'Single'
      when pbehra.benefitsubclass = '1Y' and bcdhra.benefitcoveragedescshort = 'Family' then 'Family'
      when pbehra.benefitsubclass = '1Y' and bcdhra.benefitcoveragedescshort = 'EE + 2 DP' then 'EE+2'
      when pbehra.benefitsubclass = '1Y' and bcdhra.benefitcoveragedescshort = 'Empl+Spous' then 'EE+SP'
      when pbemed.benefitsubclass = '10' and bcdmed.benefitcoveragedescshort = 'Empl Only' then 'Single'
      when pbemed.benefitsubclass = '10' and bcdmed.benefitcoveragedescshort = 'Family' then 'Family'
      when pbemed.benefitsubclass = '10' and bcdmed.benefitcoveragedescshort = 'EE + 2 DP' then 'EE+2'
      when pbemed.benefitsubclass = '10' and bcdmed.benefitcoveragedescshort = 'Empl+Spous' then 'EE+SP'
      else 'EE+1' end ::varchar(30) as enroll_cvg_type_id
,to_char(coalesce(pbehra.effectivedate,pbemed.effectivedate),'mmddyyyy')::char(8) as effectivedate
,case when pbehra.benefitelection = 'T' then to_char(pbehra.effectivedate,'mmddyyyy') 
      when pbemed.benefitelection = 'T' then to_char(pbemed.effectivedate,'mmddyyyy')
      else ' ' end ::char(8) as term_date
,null as cobra_effective_date
,null as cobra_term_date
,null as other_id
,replace(ro.org2desc,',','')::varchar(30) as location
,null as AddPostingCode
,null as AddPostingDescription
,null as AddPostingAmount
,null as AddPostingEffectiveDate
,'0'::char(1) as DebitCardEnrollment
,'0'::char(1) as AutoReimbursement
,'0'::char(1) as MedicareEligible
,null as ESRD
,pv.gendercode::char(1) as Gender
,'0'::char(1) as Relationship
,null as HICNumber
,'0'::char(1) as cob
,' '::char(1) as TerminationReason
from person_identity pi

join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts

left join person_names pn
  on pn.personid = pe.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts

join person_bene_election pbe
  on pbe.personid = pe.personid
 and pbe.effectivedate < pbe.enddate
 and current_timestamp between pbe.createts and pbe.endts 
 
left join person_bene_election pbemed
  on pbemed.personid = pbe.personid 
 and pbemed.benefitelection = 'E'
 and pbemed.selectedoption = 'Y'
 and pbemed.benefitsubclass in ('10')
 and pbemed.effectivedate >= date_trunc('year', current_date + interval '1 year') 
 and current_timestamp between pbemed.createts and pbemed.endts  

left join person_bene_election pbehra
  on pbehra.personid = pbe.personid 
 and pbehra.benefitelection = 'E'
 and pbehra.selectedoption = 'Y'
 and pbehra.benefitsubclass in ('1Y')
 and pbehra.effectivedate  >= date_trunc('year', current_date + interval '1 year') 
 and current_timestamp between pbehra.createts and pbehra.endts    

left join benefit_plan_desc bpdhra
  on bpdhra.benefitsubclass = pbehra.benefitsubclass
 and bpdhra.benefitplanid = pbehra.benefitplanid
 and current_date between bpdhra.effectivedate and bpdhra.enddate
 and current_timestamp between bpdhra.createts and bpdhra.endts     
 
left join benefit_plan_desc bpdmed
  on bpdmed.benefitsubclass = pbemed.benefitsubclass
 and bpdmed.benefitplanid = pbemed.benefitplanid
 and current_date between bpdmed.effectivedate and bpdmed.enddate
 and current_timestamp between bpdmed.createts and bpdmed.endts                               
 
left join benefit_coverage_desc bcdhra
  on bcdhra.benefitcoverageid = pbehra.benefitcoverageid 
 and current_date between bcdhra.effectivedate and bcdhra.enddate
 and current_timestamp between bcdhra.createts and bcdhra.endts 
 
left join benefit_coverage_desc bcdmed
  on bcdmed.benefitcoverageid = pbemed.benefitcoverageid 
 and current_date between bcdmed.effectivedate and bcdmed.enddate
 and current_timestamp between bcdmed.createts and bcdmed.endts 
  
left join person_vitals pv
  on pv.personid = pe.personid
 and current_date between pv.effectivedate and pv.enddate
 and current_timestamp between pv.createts and pv.endts
 
left join person_address pa
  on pa.personid = pe.personid
 and pa.addresstype = 'Res'
 and current_date between pa.effectivedate and pa.enddate
 and current_timestamp between pa.createts and pa.endts 
 
left join person_phone_contacts ppch 
  on ppch.personid = pe.personid
 and current_date between ppch.effectivedate and ppch.enddate
 and current_timestamp between ppch.createts and ppch.endts 
 and ppch.phonecontacttype = 'Home'
        
left join person_phone_contacts ppcm
  on ppch.personid = pe.personid
 and current_date between ppcm.effectivedate and ppcm.enddate
 and current_timestamp between ppcm.createts and ppcm.endts 
 and ppcm.phonecontacttype = 'Mobile' 
 
left join person_phone_contacts ppcb
  on ppcb.personid = pe.personid
 and current_date between ppcb.effectivedate and ppcb.enddate
 and current_timestamp between ppcb.createts and ppcb.endts 
 and ppcb.phonecontacttype = 'BUSN'    
  
left join person_phone_contacts ppcw
  on ppcw.personid = pe.personid
 and current_date between ppcw.effectivedate and ppcw.enddate
 and current_timestamp between ppcw.createts and ppcw.endts  
 and ppcw.phonecontacttype = 'Work'   
    
left join person_net_contacts pncw 
  on pncw.personid = pe.personid 
 and pncw.netcontacttype = 'WRK'::bpchar 
 and current_date between pncw.effectivedate and pncw.enddate
 and current_timestamp between pncw.createts and pncw.enddate 

left join person_net_contacts pnch 
  on pnch.personid = pe.personid 
 and pnch.netcontacttype = 'HomeEmail'::bpchar 
 and current_date between pnch.effectivedate and pnch.enddate
 and current_timestamp between pnch.createts and pnch.enddate   

left join person_payroll ppay
  on ppay.personid = pe.personid
 and current_date between ppay.effectivedate and ppay.enddate
 and current_timestamp between ppay.createts and ppay.endts

left join pers_pos pp
  on pp.personid = pe.personid
 and current_date between pp.effectivedate and pp.enddate
 and current_timestamp between pp.createts and pp.endts
 
LEFT JOIN pos_org_rel por
  on por.positionid = pp.positionid
 AND current_date between por.effectivedate AND por.enddate
 AND current_timestamp between por.createts AND por.endts
 AND por.posorgreltype = 'Member'

LEFT JOIN cognos_orgstructure ro
  ON ro.org1id = por.organizationid  
    
left join pay_unit pu on pu.payunitid = ppay.payunitid 
  
where pi.identitytype = 'SSN' 
  and current_timestamp between pi.createts and pi.endts
  and pe.emplstatus = 'A'
  and pbe.effectivedate >= date_trunc('year', current_date + interval '1 year') 
  and pbe.benefitelection = 'E' and pbe.selectedoption = 'Y'  
  and pbe.benefitsubclass in ('10','1Y')  
  
  union
  
select distinct
 pi.personid
     
,case when pdr.dependentrelationship in ('SP','DP','NA') then '2' else '3' end ::char(1) as sort_seq 
,'ACTIVE EE DEP' ::varchar(30) as qsource 
,replace(pu.employertaxid,'-','')::varchar(20) as client_federal_id
,'0'::char(1) as plan_year_id
,pi.identity ::varchar(20) as participant_id
,'1'::char(1) as participant_id_type
,pid.identity ::varchar(20) as dependent_id

,pnd.fname::varchar(30) as fname
,pnd.mname::char(1) as mname
,ltrim(pnd.lname)::varchar(30) as lname
,to_char(pvd.birthdate,'mmddyyyy')::char(8) as dob
,coalesce(ppch.phoneno,ppcw.phoneno,ppcm.phoneno,ppcb.phoneno) ::varchar(16) AS phone
,pa.streetaddress ::varchar(30) as addr1
,pa.streetaddress2 ::varchar(30) as addr2
,pa.city ::varchar(30) as city
,pa.stateprovincecode ::char(2) as state
,pa.postalcode ::varchar(16) as zip
,coalesce(pncw.url,pnch.url) ::varchar(50) AS email

,case when bpdhra.benefitsubclass = '1Y' then 'HRA' else 'MED' end ::varchar(30) as enrollee_plan_type

,case when pbehra.benefitsubclass = '1Y' and bcdhra.benefitcoveragedescshort = 'Empl Only' then 'Single'
      when pbehra.benefitsubclass = '1Y' and bcdhra.benefitcoveragedescshort = 'Family' then 'Family'
      when pbehra.benefitsubclass = '1Y' and bcdhra.benefitcoveragedescshort = 'EE + 2 DP' then 'EE+2'
      when pbehra.benefitsubclass = '1Y' and bcdhra.benefitcoveragedescshort = 'Empl+Spous' then 'EE+SP'
      when pbemed.benefitsubclass = '10' and bcdmed.benefitcoveragedescshort = 'Empl Only' then 'Single'
      when pbemed.benefitsubclass = '10' and bcdmed.benefitcoveragedescshort = 'Family' then 'Family'
      when pbemed.benefitsubclass = '10' and bcdmed.benefitcoveragedescshort = 'EE + 2 DP' then 'EE+2'
      when pbemed.benefitsubclass = '10' and bcdmed.benefitcoveragedescshort = 'Empl+Spous' then 'EE+SP'
      else 'EE+1' end ::varchar(30) as enroll_cvg_type_id
,to_char(coalesce(pbehra.effectivedate,pbemed.effectivedate),'mmddyyyy')::char(8) as effectivedate
,case when pbehra.benefitelection = 'T' then to_char(pbehra.effectivedate,'mmddyyyy') 
      when pbemed.benefitelection = 'T' then to_char(pbemed.effectivedate,'mmddyyyy')
      else ' ' end ::char(8) as term_date
,null as cobra_effective_date
,null as cobra_term_date


,null as other_id
,replace(ro.org2desc,',','')::varchar(30) as location
,null as AddPostingCode
,null as AddPostingDescription
,null as AddPostingAmount
,null as AddPostingEffectiveDate
,'0'::char(1) as DebitCardEnrollment
,'0'::char(1) as AutoReimbursement
,'0'::char(1) as MedicareEligible
,null as ESRD
,pv.gendercode::char(1) as Gender
,case when pdr.dependentrelationship in ('SP') then '1'
      when pdr.dependentrelationship in ('DP','NA') then '3'
      when pdr.dependentrelationship in ('D','S','ND','NS','NC','C') then '2' end ::char(1) as Relationship
,null as HICNumber
,'0'::char(1) as cob
,' '::char(1) as TerminationReason


from person_identity pi

join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts

left join person_names pn
  on pn.personid = pe.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts

join person_bene_election pbe
  on pbe.personid = pe.personid
 and pbe.effectivedate < pbe.enddate
 and current_timestamp between pbe.createts and pbe.endts 
 
left join person_bene_election pbemed
  on pbemed.personid = pbe.personid 
 and pbemed.benefitelection = 'E'
 and pbemed.selectedoption = 'Y'
 and pbemed.benefitsubclass in ('10')
 and pbemed.effectivedate >= date_trunc('year', current_date + interval '1 year') 
 and current_timestamp between pbemed.createts and pbemed.endts  

left join person_bene_election pbehra
  on pbehra.personid = pbe.personid 
 and pbehra.benefitelection = 'E'
 and pbehra.selectedoption = 'Y'
 and pbehra.benefitsubclass in ('1Y')
 and pbehra.effectivedate  >= date_trunc('year', current_date + interval '1 year') 
 and current_timestamp between pbehra.createts and pbehra.endts    
                         
left join benefit_plan_desc bpdhra
  on bpdhra.benefitsubclass = pbehra.benefitsubclass
 and bpdhra.benefitplanid = pbehra.benefitplanid
 and current_date between bpdhra.effectivedate and bpdhra.enddate
 and current_timestamp between bpdhra.createts and bpdhra.endts     
 
left join benefit_plan_desc bpdmed
  on bpdmed.benefitsubclass = pbemed.benefitsubclass
 and bpdmed.benefitplanid = pbemed.benefitplanid
 and current_date between bpdmed.effectivedate and bpdmed.enddate
 and current_timestamp between bpdmed.createts and bpdmed.endts                         
 
left join benefit_coverage_desc bcdhra
  on bcdhra.benefitcoverageid = pbehra.benefitcoverageid 
 and current_date between bcdhra.effectivedate and bcdhra.enddate
 and current_timestamp between bcdhra.createts and bcdhra.endts 
 
left join benefit_coverage_desc bcdmed
  on bcdmed.benefitcoverageid = pbemed.benefitcoverageid 
 and current_date between bcdmed.effectivedate and bcdmed.enddate
 and current_timestamp between bcdmed.createts and bcdmed.endts 
  
left join person_vitals pv
  on pv.personid = pe.personid
 and current_date between pv.effectivedate and pv.enddate
 and current_timestamp between pv.createts and pv.endts
 
left join person_address pa
  on pa.personid = pe.personid
 and pa.addresstype = 'Res'
 and current_date between pa.effectivedate and pa.enddate
 and current_timestamp between pa.createts and pa.endts 
 
left join person_phone_contacts ppch 
  on ppch.personid = pe.personid
 and current_date between ppch.effectivedate and ppch.enddate
 and current_timestamp between ppch.createts and ppch.endts 
 and ppch.phonecontacttype = 'Home'
        
left join person_phone_contacts ppcm
  on ppch.personid = pe.personid
 and current_date between ppcm.effectivedate and ppcm.enddate
 and current_timestamp between ppcm.createts and ppcm.endts 
 and ppcm.phonecontacttype = 'Mobile' 
 
left join person_phone_contacts ppcb
  on ppcb.personid = pe.personid
 and current_date between ppcb.effectivedate and ppcb.enddate
 and current_timestamp between ppcb.createts and ppcb.endts 
 and ppcb.phonecontacttype = 'BUSN'    
  
left join person_phone_contacts ppcw
  on ppcw.personid = pe.personid
 and current_date between ppcw.effectivedate and ppcw.enddate
 and current_timestamp between ppcw.createts and ppcw.endts  
 and ppcw.phonecontacttype = 'Work'   
    
left join person_net_contacts pncw 
  on pncw.personid = pe.personid 
 and pncw.netcontacttype = 'WRK'::bpchar 
 and current_date between pncw.effectivedate and pncw.enddate
 and current_timestamp between pncw.createts and pncw.enddate 

left join person_net_contacts pnch 
  on pnch.personid = pe.personid 
 and pnch.netcontacttype = 'HomeEmail'::bpchar 
 and current_date between pnch.effectivedate and pnch.enddate
 and current_timestamp between pnch.createts and pnch.enddate 

left join person_payroll ppay
  on ppay.personid = pe.personid
 and current_date between ppay.effectivedate and ppay.enddate
 and current_timestamp between ppay.createts and ppay.endts

left join pers_pos pp
  on pp.personid = pe.personid
 and current_date between pp.effectivedate and pp.enddate
 and current_timestamp between pp.createts and pp.endts
 
LEFT JOIN pos_org_rel por
  on por.positionid = pp.positionid
 AND current_date between por.effectivedate AND por.enddate
 AND current_timestamp between por.createts AND por.endts
 AND por.posorgreltype = 'Member'

LEFT JOIN cognos_orgstructure ro
  ON ro.org1id = por.organizationid  
    
left join pay_unit pu on pu.payunitid = ppay.payunitid 
 
----- Dependent data  
join person_dependent_relationship pdr
  on pdr.personid = pbe.personid
 and current_date between pdr.effectivedate and pdr.enddate
 and current_timestamp between pdr.createts and pdr.endts
 
join dependent_enrollment de
  on de.personid = pbe.personid 
 and de.dependentid = pdr.dependentid
 and de.benefitsubclass in ('10','1Y') 
 and de.selectedoption = 'Y'

join person_identity pid
  on pid.personid = pdr.dependentid
 and pid.identitytype = 'SSN'
 and current_timestamp between pid.createts and pid.endts 

left join person_names pnd
  on pnd.personid = pdr.dependentid 
 and pnd.nametype = 'Dep'
 and current_date between pnd.effectivedate and pnd.enddate
 and current_timestamp between pnd.createts and pnd.endts 
 
left join person_vitals pvd
  on pvd.personid = pdr.dependentid
 and current_date between pvd.effectivedate and pvd.enddate
 and current_timestamp between pvd.createts and pvd.endts 

where pi.identitytype = 'SSN' 
  and current_timestamp between pi.createts and pi.endts
  and pe.emplstatus = 'A'
  and pbe.effectivedate >= date_trunc('year', current_date + interval '1 year') 
  and pbe.benefitelection = 'E' and pbe.selectedoption = 'Y'  
  and pbe.benefitsubclass in ('10','1Y')  
  
  order by personid, lname, sort_seq asc