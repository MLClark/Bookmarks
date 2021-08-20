select distinct
 pi.personid
,pie.identity ::char(9) as empno 
,to_char(pbe.effectivedate,'YYYY-MM-DD')::char(10) as change_date
,' ' ::char(1) as dep_change_date
,case when pe.emplstatus = 'T' then to_char(pe.effectivedate,'YYYY-MM-DD') else ' ' end ::char(10) as term_date
,pn.fname ::varchar(50) as fname
,pn.lname ::varchar(50) as lname
,pn.mname ::char(1) as mname
,pi.identity ::char(9) as ssn
,pv.gendercode ::char(1) as gender
,to_char(pv.birthdate,'YYYY-MM-DD') ::char(10) as dob
,to_char(pbe.effectivedate,'YYYY-MM-DD')::char(10) as commit_date
,pd.positiontitle ::varchar(50) as occupation
,pp.scheduledhours as hours_per_week
,pc.compamount as salary_amt
,pc.frequencycode as salary_code
,to_char(pc.effectivedate,'YYYY-MM-DD')::char(10) as salary_eff_date
,pa.streetaddress ::varchar(50) as addr1
,pa.streetaddress2 ::varchar(50) as addr2
,pa.city ::varchar(50) as city
,pa.stateprovincecode ::char(2) as state
,pa.postalcode ::char(5) as zip
,' ' ::char(4) as zip_plus

,ppch.phoneno ::char(14) as homephone
,ppcw.phoneno ::char(15) as workphone
,' ' ::char(1) as extension

,coalesce(pnc.url,pnch.url) ::varchar(100) AS email
,to_char(pe.emplhiredate,'YYYY-MM-DD')::char(10) as bene_elig_date
,to_char(pe.empllasthiredate,'YYYY-MM-DD')::char(10) as sub_date_of_elig
,',,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,' ::char(90) as ac_thru_do
-- BASIC LIFE (20) DO - DX
,'000010235921-00000' ::char(19) as life_policy_nbr
,'1588157' ::char(7) as life_bill_loc_ac_nbr
,'?' ::char(1) as life_sort_group
,to_char(pbelife.effectivedate,'YYYY-MM-DD')::char(10) as life_eff_date
,'1' ::char(1) as life_plan_code
,case when pc.frequencycode = 'H' then '2' else '1' end ::char(1) as life_class_code
,pbelife.coverageamount as li_cvgs
,case when pe.emplstatus = 'T' then to_char(pbelife.effectivedate,'YYYY-MM-DD') else ' ' end ::char(10) as life_term_date
,'AD-1' ::char(4) as li_cvgs
,case when pe.emplstatus = 'T' then to_char(pbelife.effectivedate,'YYYY-MM-DD') else ' ' end ::char(10) as add_term_date
,',,,,,,,,,,,,,,,,,,,,,,,' ::char(24) as dy_thru_ev
-- STD (30) EW - FD
,'000010235923-00000' ::char(19) as wi_policy_nbr
,'1588157' ::char(7) as wi_bill_loc_ac_nbr
,'?' ::char(1) as wi_sort_group
,to_char(pbestd.effectivedate,'YYYY-MM-DD')::char(10) as wi_eff_date
,'1' ::char(1) as wi_plan_code
,case when pc.frequencycode = 'H' then '2' else '1' end ::char(1) as wi_class_code
,pbestd.coverageamount as wi_cvgs
,case when pe.emplstatus = 'T' then to_char(pbestd.effectivedate,'YYYY-MM-DD') else ' ' end ::char(10) as wi_term_date
,',' ::char(2) as fe_thru_ff
-- LTD (30) FG - FN
,'000010235922-00000' ::char(19) as ltd_policy_nbr
,'1588157' ::char(7) as ltd_bill_loc_ac_nbr
,'?' ::char(1) as ltd_sort_group
,to_char(pbeltd.effectivedate,'YYYY-MM-DD')::char(10) as ltd_eff_date
,'1' ::char(1) as ltd_plan_code
,case when pc.frequencycode = 'H' then '2' else '1' end ::char(1) as ltd_class_code
,pbeltd.coverageamount as ltd_cvgs
,case when pe.emplstatus = 'T' then to_char(pbeltd.effectivedate,'YYYY-MM-DD') else ' ' end ::char(10) as ltd_term_date
,',,' ::char(2) as fo_thru_ff
,',,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,' ::char(55) as fo_thru_ht
-- VOL LIFE EE SP DP (21,2Z,25) HU - ID
,'000400001000-23324' ::char(19) as vlif_policy_nbr
,'1588157' ::char(7) as vlif_bill_loc_ac_nbr
,'?' ::char(1) as vlif_sort_group
,to_char(pbebeevlife.effectivedate,'YYYY-MM-DD')::char(10) as vlif_eff_date
,'1' ::char(1) as vlif_plan_code
,case when pc.frequencycode = 'H' then '2' else '1' end ::char(1) as vlif_class_code
,pbebeevlife.coverageamount as vlif_cvgs
,case when pe.emplstatus = 'T' then to_char(pbebeevlife.effectivedate,'YYYY-MM-DD') else ' ' end ::char(10) as vlif_term_date
,pbebDPvlife.coverageamount  vad_cvgs
,case when pe.emplstatus = 'T' then to_char(pbebDPvlife.effectivedate,'YYYY-MM-DD') else ' ' end ::char(10) as vad_term_date
,pbebSPvlife.coverageamount  vsad_cvgs
,case when pe.emplstatus = 'T' then to_char(pbebSPvlife.effectivedate,'YYYY-MM-DD') else ' ' end ::char(10) as vsad_term_date
,',,,,,,'::char(6) as ie_thru_ij
,',,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,' ::char(49) as ik_thru_kf
 
from person_identity pi

join person_identity pie
  on pie.personid = pi.personid
 and pie.identitytype = 'EmpNo'
 and current_timestamp between pie.createts and pie.endts
 
join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts
 
join person_bene_election pbe
  on pbe.personid = pi.personid
 and pbe.benefitsubclass in ('20','21','2Z','25','30','31')
 and pbe.selectedoption = 'Y'
 and pbe.benefitelection = 'E'
 and current_date between pbe.effectivedate and pbe.enddate
 and current_timestamp between pbe.createts and pbe.endts 

left join person_bene_election pbelife
  on pbelife.personid = pi.personid
 and pbelife.benefitsubclass in ('20')
 and pbelife.benefitelection in ('E')
 and pbelife.selectedoption = 'Y' 
 and current_date between pbelife.effectivedate and pbelife.enddate
 and current_timestamp between pbelife.createts and pbelife.endts   

left join person_bene_election pbebeevlife
  on pbebeevlife.personid = pi.personid
 and pbebeevlife.benefitsubclass in ('21')
 and pbebeevlife.benefitelection in ('E')
 and pbebeevlife.selectedoption = 'Y' 
 and current_date between pbebeevlife.effectivedate and pbebeevlife.enddate
 and current_timestamp between pbebeevlife.createts and pbebeevlife.endts 

left join person_bene_election pbebSPvlife
  on pbebSPvlife.personid = pi.personid
 and pbebSPvlife.benefitsubclass in ('2Z')
 and pbebSPvlife.benefitelection in ('E')
 and pbebSPvlife.selectedoption = 'Y' 
 and current_date between pbebSPvlife.effectivedate and pbebSPvlife.enddate
 and current_timestamp between pbebSPvlife.createts and pbebSPvlife.endts  

left join person_bene_election pbebDPvlife
  on pbebDPvlife.personid = pi.personid
 and pbebDPvlife.benefitsubclass in ('25')
 and pbebDPvlife.benefitelection in ('E')
 and pbebDPvlife.selectedoption = 'Y' 
 and current_date between pbebDPvlife.effectivedate and pbebDPvlife.enddate
 and current_timestamp between pbebDPvlife.createts and pbebDPvlife.endts    

left join person_bene_election pbestd
  on pbestd.personid = pi.personid
 and pbestd.benefitsubclass in ('30')
 and pbestd.benefitelection in ('E')
 and pbestd.selectedoption = 'Y' 
 and current_date between pbestd.effectivedate and pbestd.enddate
 and current_timestamp between pbestd.createts and pbestd.endts

left join person_bene_election pbeltd
  on pbeltd.personid = pi.personid
 and pbeltd.benefitsubclass in ('31')
 and pbeltd.benefitelection in ('E')
 and pbeltd.selectedoption = 'Y' 
 and current_date between pbeltd.effectivedate and pbeltd.enddate
 and current_timestamp between pbeltd.createts and pbeltd.endts  

join person_names pn
  on pn.personid = pi.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts 

left join person_address pa
  on pa.personid = pi.personid
 and pa.addresstype = 'Res'
 and current_date between pa.effectivedate and pa.enddate
 and current_timestamp between pa.createts and pa.endts 

left join person_vitals pv
  on pv.personid = pi.personid
 and current_date between pv.effectivedate and pv.enddate
 and current_timestamp between pv.createts and pv.endts 

left join pers_pos pp 
  on pp.personid = pe.personid
 and current_date between pp.effectivedate and pp.enddate
 and current_timestamp between pp.createts and pp.endts 

left join position_desc pd
  on pd.positionid = pp.positionid
 and current_date between pd.effectivedate and pd.enddate
 and current_timestamp between pd.createts and pd.endts  

left join person_compensation pc
  on pc.personid = pi.personid
 and current_date between pc.effectivedate and pc.enddate
 and current_timestamp between pc.createts and pc.endts 

left join person_phone_contacts ppch 
  on ppch.personid = pi.personid
 and current_date between ppch.effectivedate and ppch.enddate
 and current_timestamp between ppch.createts and ppch.endts 
 and ppch.phonecontacttype = 'Home'
left join person_phone_contacts ppcw
  on ppcw.personid = pi.personid
 and current_date between ppcw.effectivedate and ppcw.enddate
 and current_timestamp between ppcw.createts and ppcw.endts  
 and ppcw.phonecontacttype = 'Work'   
left join person_phone_contacts ppcb
  on ppcb.personid = pi.personid
 and current_date between ppcb.effectivedate and ppcb.enddate
 and current_timestamp between ppcb.createts and ppcb.endts 
 and ppcb.phonecontacttype = 'BUSN'      
left join person_phone_contacts ppcm
  on ppch.personid = pi.personid
 and current_date between ppcm.effectivedate and ppcm.enddate
 and current_timestamp between ppcm.createts and ppcm.endts 
 and ppcm.phonecontacttype = 'Mobile'         
  
left join person_net_contacts pnc 
  on pnc.personid = pi.personid 
 and pnc.netcontacttype = 'WRK'::bpchar 
 and current_date between pnc.effectivedate and pnc.enddate
 and current_timestamp between pnc.createts and pnc.enddate 
-- select * from person_net_contacts
left join person_net_contacts pnch 
  on pnch.personid = pi.personid 
 and pnch.netcontacttype = 'HomeEmail'::bpchar 
 and current_date between pnch.effectivedate and pnch.enddate
 and current_timestamp between pnch.createts and pnch.enddate  
 
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts 