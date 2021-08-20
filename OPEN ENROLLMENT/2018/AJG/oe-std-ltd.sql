select distinct
--- active dcs for ee
 pi.personid
,'active ee' ::varchar(30) as qsource
,'4' ::char(2) as sortseq
,'DCS'                                       ::char(3) AS recordtype
,'HAR'                                       ::char(5) AS client
,PI.identity                                 ::char(10) AS certnumber
,' '                                         ::char(2) as filler
, case character_length(ppch.phoneno) 
  when 14 then(substring(ppch.phoneno from 2 for 3) || substring(ppch.phoneno from 7 for 3) || substring(ppch.phoneno from 11 for 4) )
  when 12 then(substring(ppch.phoneno from 1 for 3) || substring(ppch.phoneno from 5 for 3) || substring(ppch.phoneno from 9 for 4) )
  when 10 then ppch.phoneno else ' ' end    ::char(10) as homephone
,pe.emplstatus ::char(1) as empstatus
,to_char(pe.effectivedate, 'mm/dd/yyyy')     ::char(10) as statuseftdate
,pe.emplclass ::char(1) as salaryclass
,to_char(pe.effectivedate,'mm/dd/yyyy')      ::char(10) as salaryeffdate
,lpad(coalesce(CASE when pc.frequencycode = 'A'::bpchar THEN cast(round(pc.compamount, 2)*100 as bigint)
                    when pc.frequencycode = 'H'::bpchar THEN cast(round(pc.compamount * pp.scheduledhours * fc1.annualfactor, 2)*100 as bigint)
                    ELSE 0::numeric END,0)::text,9,'0') AS annualsalary
,'A' ::char(1) as salarybasis 
,CASE WHEN clr.companylocationtype = 'WH' ::bpchar THEN st.stateprovincecode  ELSE pa.stateprovincecode END  ::char(2) AS workstatecode     
,upper(pd.positiontitle)  ::char(25) as jobtitle
,pd.flsacode  ::char(1) as exempt_ind
,' ' ::char(1)  as union_ind
,' ' ::char(30) as union_name
,' ' ::char(10) as department
,lc.locationcode ::char(10) as division
,' ' ::char(10) as location
,' ' ::char(10) as account
,' ' ::char(10) as region
,' ' ::char(10) as company
,' ' ::char(50) as employee_email
,to_char(pbestd.effectivedate,'mm/dd/yyyy')  ::char(10) as std_cvrg_eff_dt
,case when pe.emplstatus = 'T' then to_char(pe.effectivedate,'mm/dd/yyyy') else ' ' end ::char(10) as std_cvrg_trm_dt
,case when pbestd.benefitelection <> 'W' then 'STD ' else ' ' end ::char(5) as std_cvrg_option
,to_char(pbeltd.effectivedate,'mm/dd/yyyy') ::char(10) as ltd_cvrg_eff_dt
,case when pe.emplstatus = 'T' then to_char(pe.effectivedate,'mm/dd/yyyy') else ' ' end ::char(10) as ltd_cvrg_trm_dt
,case when pbeltd.benefitelection <> 'W' then 'LTD ' else ' ' end  ::char(5) as ltd_cvrg_option
,' ' ::char(3) as flex_com_prd_day_injury
,' ' ::char(3) as flex_com_prd_day_sickness
,' ' ::char(3) as flex_benefit_duration
,' ' ::char(6) as flex_benefit_amount


from person_identity pi

JOIN person_employment pe 
  ON pe.personid = pi.personid
 AND current_date between pe.effectivedate and pe.enddate
 AND current_timestamp between pe.createts and pe.endts
 
join person_address pa
  on pa.personid = pi.personid
 and pa.addresstype = 'Res'
 and current_date between pa.effectivedate and pa.enddate
 and current_timestamp between pa.createts and pa.endts
  

left join (select personid, max(percomppid) as percomppid
from person_compensation pc 
  where pc.earningscode <> 'BenBase'::bpchar 
 AND current_date between pc.effectivedate AND pc.enddate 
 AND current_timestamp between pc.createts AND pc.endts 
 group by 1) as maxpc on maxpc.personid = pe.personid
  
left JOIN person_compensation pc 
  ON pc.personid = maxpc.personid 
 AND pc.earningscode <> 'BenBase'::bpchar 
 and pc.percomppid = maxpc.percomppid
 AND current_date between pc.effectivedate AND pc.enddate 
 AND current_timestamp between pc.createts AND pc.endts 
 
JOIN person_payroll ppr
  ON ppr.personid = pe.personid 
 AND current_date between ppr.effectivedate and ppr.enddate
 AND current_timestamp between ppr.createts AND ppr.endts
 
LEFT JOIN pay_unit pu
  ON pu.payunitid = ppr.payunitid
LEFT JOIN frequency_codes fc1
  ON fc1.frequencycode = pu.frequencycode

LEFT JOIN person_locations pl
  ON pl.personid = pi.personid 
 AND pl.personlocationtype = 'P'::bpchar 
 AND current_date between pl.effectivedate AND pl.enddate
 AND current_timestamp between pl.createts AND pl.endts
 
JOIN location_codes lc 
  on lc.locationid = pl.locationid
 and current_date between lc.effectivedate and lc.enddate
 and current_timestamp between lc.createts and lc.endts
  
LEFT JOIN company_location_rel clr
  ON clr.locationid = pl.locationid 
 AND current_timestamp between clr.createts AND clr.endts
 
LEFT JOIN state_province st
  ON st.stateprovincecode = pa.stateprovincecode
 AND pa.countrycode = st.countrycode
      
left join person_phone_contacts ppch 
  on ppch.personid = pi.personid
 and ppch.phonecontacttype = 'Home'  
 and current_date between ppch.effectivedate and ppch.enddate
 and current_timestamp between ppch.createts and ppch.endts 

JOIN person_bene_election pbe 
  on pbe.personid = pi.personid 
 AND  pbe.effectivedate < pbe.enddate
 AND current_timestamp between pbe.createts and pbe.endts
 AND pbe.benefitsubclass IN ('30','31' )
 AND pbe.selectedoption = 'Y'  
 and pbe.benefitelection in ('E')
 and pbe.effectivedate = '2019-01-01' 
 
--- std   
left JOIN person_bene_election pbestd
  on pbestd.personid = pbe.personid 
 AND pbestd.effectivedate < pbestd.enddate
 AND current_timestamp between pbestd.createts and pbestd.endts
 AND pbestd.benefitsubclass IN ('30')
 AND pbestd.selectedoption = 'Y'    
 and pbestd.benefitelection = 'E' 
 and pbestd.effectivedate = '2019-01-01'
 
--- ldt 
left JOIN person_bene_election pbeltd
  on pbeltd.personid = pbe.personid 
 AND pbeltd.effectivedate < pbeltd.enddate
 AND current_timestamp between pbeltd.createts and pbeltd.endts
 AND pbeltd.benefitsubclass IN ('31')
 AND pbeltd.selectedoption = 'Y'  
 and pbeltd.benefitelection = 'E' 
 and pbeltd.effectivedate = '2019-01-01'

JOIN pers_pos pp 
  ON pp.personid = pbe.personid 
 AND pp.persposrel = 'Occupies'::bpchar 
 AND current_date between pp.effectivedate and pp.enddate 
 AND current_timestamp between pp.createts and pp.endts   
 

left join position_desc pd 
  on pd.positionid = pp.positionid
 and current_date between pd.effectivedate and pd.enddate
 and current_timestamp between pd.createts and pd.endts 

where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  and pe.emplstatus = 'A'
  

