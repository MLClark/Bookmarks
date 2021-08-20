select distinct
-- enrollment - change only but uses the lastupdatets to drive how far back to pull data from 
 pi.personid
,pip.identity
,pbe.benefitsubclass
--,pbe.coverageamount
,'4800-0872-9049' ::char(14) as client_tasc_id
,'0000226185' ::char(10) as plan_tasc_id
,' ' ::char(1) as part_tasc_id
,pie.identity ::char(11) as ee_id
,pe.effectivedate
,case when pe.effectivedate >= elu.lastupdatets::date then 'A' else 'C' end ::char(1) as action_cd
,coalesce(pncw.url,pnch.url,pnco.url)::varchar(100) as email
,pn.lname ::varchar(70) as lname
,pn.fname ::varchar(70) as fname
,pn.mname ::char(1) as mname
,replace(pa.streetaddress,',', ' ')  ::varchar(100) as addr1
,replace(pa.streetaddress2, ',',' ') ::varchar(100) as addr2
,pa.city ::varchar(40) as city
,pa.stateprovincecode ::char(2) as state
,pa.postalcode ::char(5) as zip
,pbe.effectivedate
,' ' ::char(1) as paydate
-----The 106 Eligibility is for the Non-Employer Sponsored Plan - FSANSP - Medical subclass code 62
,to_char(pbe_fsamed.effectivedate,'MM/DD/YYYY')::char(10) as med_elig_start_date
,' ' ::char(1) as med_elig_end_date
,to_char(pbe_fsadep.effectivedate,'MM/DD/YYYY')::char(10) as dep_elig_start_date
,' ' ::char(1) as dep_elig_end_date
,to_char(pbe_fsa106.effectivedate,'MM/DD/YYYY')::char(10) as a106_elig_start_date
,' ' ::char(1) as a106_elig_end_date
,' ' ::char(1) as trn_elig_start_date
,' ' ::char(1) as trn_elig_end_date
,' ' ::char(1) as prk_elig_start_date
,' ' ::char(1) as prk_elig_end_date
,' ' ::char(1) as emp_term_date
,' ' ::char(1) as term_last_payroll_date
,' ' ::char(1) as em_term_type
--- Participant per pay period contribs
,' ' ::char(1) as med_ppp_contrib_p
,' ' ::char(1) as dep_ppp_contrib_p
,' ' ::char(1) as a106_ppp_contrib_p
,' ' ::char(1) as trn_ppp_contrib_p
,' ' ::char(1) as prk_ppp_contrib_p

--- Clients per pay period contribs
,' ' ::char(1) as med_ppp_contrib_c
,' ' ::char(1) as dep_ppp_contrib_c
,' ' ::char(1) as a106_ppp_contrib_c
,' ' ::char(1) as trn_ppp_contrib_c
,' ' ::char(1) as prk_ppp_contrib_c

--- Participants annual elections
,pbe_fsamed.coverageamount as fsamed_annual_elec_p
,pbe_fsadep.coverageamount as fsadep_annual_elec_p
,pbe_fsa106.coverageamount as fsa106_annual_elec_p
,' ' ::char(1) as trn_annual_elec_p
,' ' ::char(1) as prk_annual_elec_p

--- Clients annual elections
,' ' ::char(1) as fsamed_annual_elec_c
,' ' ::char(1) as fsadep_annual_elec_c
,' ' ::char(1) as fsa106_annual_elec_c
,' ' ::char(1) as trn_annual_elec_c
,' ' ::char(1) as prk_annual_elec_c


,' ' ::char(1) as division
,' ' ::char(1) as section
,' ' ::char(1) as alt_part_id
  

from person_identity pi

join edi.edi_last_update elu
  on elu.feedid = 'ARO_TASC_FlexSpending_Enrollment_Export'

join person_identity pie
  on pie.personid = pi.personid
 and current_timestamp between pie.createts and pie.endts
 and pie.identitytype = 'EmpNo'
 
left join person_identity pip
  on pip.personid = pi.personid 
 and current_timestamp between pip.createts and pip.endts
 and pip.identitytype = 'PSPID'
   
left join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts   
 
left join person_names pn
  on pn.personid = pi.personid
 and pn.nametype = 'Legal'  
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts

left join person_address pa 
  on pa.personid = pi.personid
 and current_date between pa.effectivedate and pa.enddate
 and current_timestamp between pa.createts and pa.endts
 
LEFT JOIN person_net_contacts pncw 
  ON pncw.personid = pi.personid 
 AND pncw.netcontacttype = 'WRK'::bpchar 
 AND current_date between pncw.effectivedate and pncw.enddate
 AND current_timestamp between pncw.createts and pncw.enddate 

LEFT JOIN person_net_contacts pnch 
  ON pnch.personid = pi.personid 
 AND pnch.netcontacttype = 'HomeEmail'::bpchar 
 AND current_date between pnch.effectivedate and pnch.enddate
 AND current_timestamp between pnch.createts and pnch.enddate        
     

LEFT JOIN person_net_contacts pnco 
  ON pnco.personid = pi.personid 
 AND pnco.netcontacttype = 'OtherEmail'::bpchar 
 AND current_date between pnco.effectivedate and pnco.enddate
 AND current_timestamp between pnco.createts and pnco.enddate  

join person_bene_election pbe
  on pbe.personid = pi.personid
 and current_date between pbe.effectivedate and pbe.enddate
 and current_timestamp between pbe.createts and pbe.endts
 and pbe.benefitsubclass in ('60','61','62')
 and pbe.benefitelection = 'E'
 and pbe.selectedoption = 'Y'
 and pbe.effectivedate >= elu.lastupdatets

left join person_bene_election pbe_fsamed
  on pbe_fsamed.personid = pbe.personid
 and current_date between pbe_fsamed.effectivedate and pbe_fsamed.enddate
 and current_timestamp between pbe_fsamed.createts and pbe_fsamed.endts
 and pbe_fsamed.benefitsubclass in ('60')
 and pbe_fsamed.benefitelection = 'E'
 and pbe_fsamed.selectedoption = 'Y' 
 
 left join person_bene_election pbe_fsadep
  on pbe_fsadep.personid = pbe.personid
 and current_date between pbe_fsadep.effectivedate and pbe_fsadep.enddate
 and current_timestamp between pbe_fsadep.createts and pbe_fsadep.endts
 and pbe_fsadep.benefitsubclass in ('61')
 and pbe_fsadep.benefitelection = 'E'
 and pbe_fsadep.selectedoption = 'Y' 
 
 left join person_bene_election pbe_fsa106
  on pbe_fsa106.personid = pbe.personid
 and current_date between pbe_fsa106.effectivedate and pbe_fsa106.enddate
 and current_timestamp between pbe_fsa106.createts and pbe_fsa106.endts
 and pbe_fsa106.benefitsubclass in ('62')
 and pbe_fsa106.benefitelection = 'E'
 and pbe_fsa106.selectedoption = 'Y' 

left join 
     (select personid, sum(monthlyemployeramount) as client_annual_election 
        from person_bene_election 
       where current_date between effectivedate and enddate
         and current_timestamp between createts and endts
         and benefitsubclass in ('60')
         and benefitelection = 'E'
         and selectedoption = 'Y'
         group by 1) as pbe_fsamed_annual
  on pbe_fsamed_annual.personid = pbe_fsamed.personid
  
left join 
     (select personid, sum(monthlyemployeramount) as client_annual_election 
        from person_bene_election 
       where current_date between effectivedate and enddate
         and current_timestamp between createts and endts
         and benefitsubclass in ('61')
         and benefitelection = 'E'
         and selectedoption = 'Y'
         group by 1) as pbe_fsadep_annual
  on pbe_fsamed_annual.personid = pbe_fsadep.personid      
  
left join 
     (select personid, sum(monthlyemployeramount) as client_annual_election 
        from person_bene_election 
       where current_date between effectivedate and enddate
         and current_timestamp between createts and endts
         and benefitsubclass in ('62')
         and benefitelection = 'E'
         and selectedoption = 'Y'
         group by 1) as pbe_fsa106_annual
  on pbe_fsa106_annual.personid = pbe_fsa106.personid       
         

where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  --and pi.personid in ('4424','4129','4124')
  

;  
