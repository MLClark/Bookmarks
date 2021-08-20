 SELECT distinct  
 pi.personid
,'Active' ::varchar(30) as qsource 
,pbe.benefitsubclass
,pbe.effectivedate
,pbe.benefitelection
,'0' ::char(1) as query_source
,'PeopleStrategy' :: varchar(50) as PartnerID
,replace(pi.identity,'-','') :: varchar(255) as InsuredID
,replace(pi.identity,'-','')||'01' :: varchar(255) as MemberID
,'18' ::char(2) as relation
,rtrim(pn.lname) :: varchar(50) as emp_last_name
,rtrim(ltrim(pn.fname)) :: varchar(50) as emp_first_name
,rtrim(ltrim(pn.mname)) :: varchar(50) as emp_middle_initial
,case when substring(pi.identity from 4 for 1) = '-' then pi.identity 
      else left(pi.identity,3)||'-'||substring(pi.identity,4,2)||'-'||substring(pi.identity,6,4)::char(11) end as  emp_ssn
,'C98599' ::varchar(25) as  GroupID
,'C98599 Flexible Compensation Plan'::varchar(100) as group_name
,rtrim(ltrim(pa.streetaddress)) ::varchar(255) as address1
,rtrim(ltrim(pa.streetaddress2)) ::varchar(255) as address2
,rtrim(ltrim(pa.city)) ::varchar(50) as city
,rtrim(ltrim(pa.stateprovincecode)) ::char(2) as state
,replace(pa.postalcode,'-','')   ::char(10) as zip_code
,to_char(pv.birthdate, 'yyyy-mm-dd')::char(10) as emp_dob
,to_char(pe.emplhiredate,'yyyy-mm-dd') ::char(10) as emp_doh
,replace(ppcw.phoneno,'-','') ::char(10) as w_phone
,null ::char(5) as w_phone_ext
,replace(ppch.phoneno,'-','') ::char(10) as h_phone
,null ::char(5) as h_phone_ext
,replace(ppcm.phoneno,'-','') ::char(10) as c_phone
,null ::char(10) as fax
,rtrim(ltrim(pnc.url)) ::varchar(100) as w_email
,rtrim(ltrim(pncH.url))::varchar(100) as p_email
,case when pnc.url is not null then '1'
      when pnc.url is null then '0' end ::char(1) as use_work_email
,to_char(pbe.effectivedate,'yyyy-mm-dd') ::char(10) as eff_date
,to_char(pbe.planyearenddate,'yyyy-mm-dd') ::char(10) as end_date
,case when pbe.benefitsubclass = '60' then 'MED'
      when pbe.benefitsubclass = '61' then 'DEP'
      end ::varchar(20) as plan_type
,case when pbe.coverageamount != 0 then to_char(coalesce(pbe.coverageamount,0),'999999.99')
      when pbe.coverageamount  = 0 then to_char(coalesce(greatest(hcra.annualized_election_amount,dcra.annualized_election_amount),0),'999999.99') end as election
,to_char(pbe.monthlyemployeramount,'999999.99') as er_contribution
,CASE WHEN pu.frequencycode = 'B' THEN 'BW26' else null end ::char(50) as payroll_Schedule
/*
,case when lc.locationdescription = 'Atlanta' then 'ATL'
      when lc.locationdescription = 'Baltimore' then 'BAL'
      when lc.locationdescription = 'BGL' then 'BGL'
      when lc.locationdescription = 'Chicago' then 'CHI'
      when lc.locationdescription = 'Corporate' then 'COR'
      when lc.locationdescription = 'Dallas' then 'DAL'
      when lc.locationdescription = 'Denver' then 'DEN'
      when lc.locationdescription = 'East Bay' then 'EB'
      when lc.locationdescription = 'Houston' then 'HOU'
      when lc.locationdescription = 'Miami' then 'MIA'
      when lc.locationdescription = 'Philadelphia' then 'PHI'
      when lc.locationdescription = 'Phoenix' then 'PHX'
      when lc.locationdescription = 'Remote' then 'CCG'
      when lc.locationdescription = 'San Diego' then 'SD'
      when lc.locationdescription = 'San Francisco' then 'SF'
      when lc.locationdescription = 'Washington DC' then 'DC' 
      else lc.locationcode end ::char(50) as division
*/
-- select * from location_codes;
,lc.locationcode
,CASE lc.locationcode
   WHEN 'ATL'  THEN 'ATL'
   WHEN 'BET'  THEN 'DC'   
   WHEN 'COR'  THEN 'COR'
   WHEN 'DAL'  THEN 'DAL'
   WHEN 'SFR'  THEN 'SF'
   WHEN 'REM'  THEN 'REM'
   WHEN 'PHI'  THEN 'PHI'
   WHEN 'BAL'  THEN 'BAL'        
   WHEN 'HOU'  THEN 'HOU'
   WHEN 'CHI'  THEN 'CHI'   
   WHEN 'PHO'  THEN 'PHX'   
   WHEN 'DEN'  THEN 'DEN'
   WHEN 'EBA'  THEN 'EB'   
   WHEN 'MIA'  THEN 'MIA'  
   WHEN 'SDG'  THEN 'SD'   
   WHEN 'BGL'  THEN 'BGL'   
   WHEN 'CHA'  THEN 'CHAR'   
   WHEN 'CON'  THEN 'CMG' 
   WHEN 'KAN'  THEN 'KC'  
   WHEN 'MAD'  THEN 'MAD'   
   WHEN 'NJY'  THEN 'NJY'   
   WHEN 'NYC'  THEN 'NYC' 
   WHEN 'WAS'  THEN 'DC'   
   WHEN 'CCG'  THEN 'CCG'   
   --ELSE lc.locationcode END ::varchar(50) AS DivisionCode
   ELSE ' ' END ::varchar(50) AS division

,null ::char(50) as alt_id
,pv.gendercode ::char(1) as gender
,null as hicn     

from person_identity pi

LEFT join edi.edi_last_update elu on elu.feedid = 'AMJ_EBC_FSA_Eligibility'

JOIN person_bene_election pbe
  ON pbe.personid = pi.personid
 and pbe.benefitsubclass in ('60', '61' )
 AND pbe.benefitelection in ('E')
 AND pbe.selectedoption = 'Y'---
 AND current_date between pbe.effectivedate and pbe.enddate 
 AND current_timestamp between pbe.createts and pbe.endts
 
left join   
        (
        select 
         ppd.personid
        ,ppd.payperiods
        ,hcra.etv_amount
        ,(hcra.etv_amount * ppd.payperiods) as annualized_election_amount
        from 
        (
        select pbe.personid,pbe.effectivedate,count(psp.*) payperiods
          from person_bene_election pbe
          join pay_schedule_period psp  
            on date_part('year',psp.periodstartdate)=date_part('year',current_date) 
           and psp.periodstartdate >= pbe.effectivedate
           and psp.payrolltypeid = 1 ----- NORMAL
           and psp.payunitid = '1'
         where current_date between pbe.effectivedate and pbe.enddate
           and current_timestamp between pbe.createts and pbe.endts
           and pbe.benefitsubclass in ('60' )
           AND pbe.benefitelection in ('E')
           AND pbe.selectedoption = 'Y'---
           --and pbe.personid = '2187'
           group by 1,2
        ) ppd
        join 
        (
        select distinct pbe.personid,pbe.effectivedate,ppd.etv_amount,ppd.etv_id
          from person_bene_election pbe
          join pspay_payment_detail ppd  
            on date_part('year',ppd.check_date)=date_part('year',current_date) 
           and ppd.check_date >= pbe.effectivedate
           and ppd.etv_id in ('VBA')
           and ppd.personid = pbe.personid
         where current_date between pbe.effectivedate and pbe.enddate
           and current_timestamp between pbe.createts and pbe.endts
           and pbe.benefitsubclass in ('60')
           AND pbe.benefitelection in ('E')
           AND pbe.selectedoption = 'Y'---
           --and pbe.personid = '2187'
        ) hcra on hcra.personid = ppd.personid
) hcra on hcra.personid = pi.personid    

left join   
        (select 
         ppd.personid
        ,ppd.payperiods
        ,dcra.etv_amount
        ,(dcra.etv_amount * ppd.payperiods) as annualized_election_amount
        from 
        (
        select pbe.personid,pbe.effectivedate,count(psp.*) payperiods
          from person_bene_election pbe
          join pay_schedule_period psp  
            on date_part('year',psp.periodstartdate)=date_part('year',current_date) 
           and psp.periodstartdate >= pbe.effectivedate
           and psp.payrolltypeid = 1 ----- NORMAL
           and psp.payunitid = '1'
         where current_date between pbe.effectivedate and pbe.enddate
           and current_timestamp between pbe.createts and pbe.endts
           and pbe.benefitsubclass in ('61' )
           AND pbe.benefitelection in ('E')
           AND pbe.selectedoption = 'Y'---
           --and pbe.personid = '2187'
           group by 1,2
        ) ppd
        join 
        (
        select distinct pbe.personid,pbe.effectivedate,ppd.etv_amount,ppd.etv_id
          from person_bene_election pbe
          join pspay_payment_detail ppd  
            on date_part('year',ppd.check_date)=date_part('year',current_date) 
           and ppd.check_date >= pbe.effectivedate
           and ppd.etv_id in ('VBB')
           and ppd.personid = pbe.personid
         where current_date between pbe.effectivedate and pbe.enddate
           and current_timestamp between pbe.createts and pbe.endts
           and pbe.benefitsubclass in ('61')
           AND pbe.benefitelection in ('E')
           AND pbe.selectedoption = 'Y'---
           --and pbe.personid = '2187'
        ) dcra on dcra.personid = ppd.personid
) dcra on dcra.personid = pi.personid        

JOIN person_identity pie 
  ON pie.personid = pi.personid
 AND pie.identitytype = 'EmpNo' ::bpchar 
 AND CURRENT_TIMESTAMP BETWEEN pie.createts and pie.endts

JOIN person_names pn 
  ON pn.personid = pi.personid 
 AND pn.nametype = 'Legal'::bpchar 
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts

JOIN person_address pa 
  ON pa.personid = pi.personid 
 AND pa.addresstype = 'Res'::bpchar 
 and current_date between pa.effectivedate and pa.enddate
 and current_timestamp between pa.createts and pa.endts

join person_locations pl
  on pl.personid = pi.personid
 and current_date between pl.effectivedate and pl.enddate
 and current_timestamp between pl.createts and pl.endts 

join location_codes lc 
  on lc.locationid = pl.locationid  
 AND current_date BETWEEN lc.effectivedate AND lc.enddate
 AND current_timestamp BETWEEN lc.createts AND lc.endts 

JOIN person_vitals pv 
  ON pv.personid = pi.personid 
 and current_date between pv.effectivedate and pv.enddate
 and current_timestamp between pv.createts and pv.endts

JOIN person_employment pe
  ON pe.personid = pi.personid
 AND current_date BETWEEN pe.effectivedate AND pe.enddate
 AND current_timestamp BETWEEN pe.createts AND pe.endts

LEFT JOIN person_phone_contacts ppcw 
  ON ppcw.personid = pi.personid 
 AND ppcw.phonecontacttype = 'Work'::bpchar 
 and current_date between ppcw.effectivedate and ppcw.enddate
 and current_timestamp between ppcw.createts and ppcw.endts

LEFT JOIN person_phone_contacts ppch 
  ON ppch.personid = pi.personid 
 AND ppch.phonecontacttype = 'Home'::bpchar 
 AND current_date BETWEEN ppch.effectivedate AND ppch.enddate
 AND current_timestamp BETWEEN ppch.createts AND ppch.endts

LEFT JOIN person_phone_contacts ppcm 
  ON ppcm.personid = pi.personid 
 AND ppcm.phonecontacttype = 'Mobile'::bpchar 
 AND current_date BETWEEN ppcm.effectivedate AND ppcm.enddate
 AND current_timestamp BETWEEN ppcm.createts AND ppcm.endts

LEFT JOIN person_net_contacts pnc 
  ON pnc.personid = pi.personid
 AND pnc.netcontacttype = 'WRK'::bpchar
 and current_date between pnc.effectivedate and pnc.enddate
 and current_timestamp between pnc.createts and pnc.endts

LEFT JOIN person_net_contacts pncH 
  ON pncH.personid = pi.personid
 AND pncH.netcontacttype = 'HomeEmail'::bpchar
 and current_date between pncH.effectivedate and pncH.enddate
 and current_timestamp between pncH.createts and pncH.endts

LEFT JOIN benefit_plan_desc bpd 
  on bpd.benefitplanid = pbe.benefitplanid 
 and current_date between bpd.effectivedate and bpd.enddate
 and current_timestamp between bpd.createts and bpd.endts 

LEFT JOIN person_payroll pp 
  on pp.personid = pi.personid 
 and CURRENT_DATE BETWEEN pp.effectivedate AND pp.enddate 
 and CURRENT_TIMESTAMP BETWEEN pp.createts AND pp.endts

LEFT JOIN pay_unit pu 
   ON pu.payunitid = pp.payunitid
  AND current_timestamp between pu.createts and pu.endts

where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  and pbe.effectivedate >= elu.lastupdatets::DATE 

union 
--- termed employees

 SELECT distinct  
 pi.personid
,'Termed' ::varchar(30) as qsource
,pbet.benefitsubclass
,pbet.effectivedate
,pbet.benefitelection
,'1' ::char(1) as query_source
,'PeopleStrategy' :: varchar(50) as PartnerID
,replace(pi.identity,'-','') :: varchar(255) as InsuredID
,replace(pi.identity,'-','')||'01' :: varchar(255) as MemberID
,'18' ::char(2) as relation
,rtrim(pn.lname) :: varchar(50) as emp_last_name
,rtrim(ltrim(pn.fname)) :: varchar(50) as emp_first_name
,rtrim(ltrim(pn.mname)) :: varchar(50) as emp_middle_initial
,case when substring(pi.identity from 4 for 1) = '-' then pi.identity 
      else left(pi.identity,3)||'-'||substring(pi.identity,4,2)||'-'||substring(pi.identity,6,4)::char(11) end as  emp_ssn
,'C98599' ::varchar(25) as  GroupID
,'C98599 Flexible Compensation Plan'::varchar(100) as group_name
,rtrim(ltrim(pa.streetaddress)) ::varchar(255) as address1
,rtrim(ltrim(pa.streetaddress2)) ::varchar(255) as address2
,rtrim(ltrim(pa.city)) ::varchar(50) as city
,rtrim(ltrim(pa.stateprovincecode)) ::char(2) as state
,replace(pa.postalcode,'-','')   ::char(10) as zip_code
,to_char(pv.birthdate, 'yyyy-mm-dd')::char(10) as emp_dob
,to_char(pe.emplhiredate,'yyyy-mm-dd') ::char(10) as emp_doh
,replace(ppcw.phoneno,'-','') ::char(10) as w_phone
,null ::char(5) as w_phone_ext
,replace(ppch.phoneno,'-','') ::char(10) as h_phone
,null ::char(5) as h_phone_ext
,replace(ppcm.phoneno,'-','') ::char(10) as c_phone
,null ::char(10) as fax
,rtrim(ltrim(pnc.url)) ::varchar(100) as w_email
,rtrim(ltrim(pncH.url))::varchar(100) as p_email
,case when pnc.url is not null then '1'
      when pnc.url is null then '0' end ::char(1) as use_work_email
,to_char(pbet.effectivedate,'yyyy-mm-dd') ::char(10) as eff_date
,case when pbet.benefitelection = 'T' then to_char(pbet.effectivedate,'yyyy-mm-dd') end ::char(10) as end_date
,case when pbet.benefitsubclass = '60' then 'MED'
      when pbet.benefitsubclass = '61' then 'DEP'
      end ::varchar(20) as plan_type
,to_char(coalesce(pbet.coverageamount,0),'999999.99') as election
,to_char(pbet.monthlyemployeramount,'999999.99') as er_contribution
,CASE WHEN pu.frequencycode = 'B' THEN 'BW26' else null end ::char(50) as payroll_Schedule
/*
,case when lc.locationdescription = 'Atlanta' then 'ATL'
      when lc.locationdescription = 'Baltimore' then 'BAL'
      when lc.locationdescription = 'BGL' then 'BGL'
      when lc.locationdescription = 'Chicago' then 'CHI'
      when lc.locationdescription = 'Corporate' then 'COR'
      when lc.locationdescription = 'Dallas' then 'DAL'
      when lc.locationdescription = 'Denver' then 'DEN'
      when lc.locationdescription = 'East Bay' then 'EB'
      when lc.locationdescription = 'Houston' then 'HOU'
      when lc.locationdescription = 'Miami' then 'MIA'
      when lc.locationdescription = 'Philadelphia' then 'PHI'
      when lc.locationdescription = 'Phoenix' then 'PHX'
      when lc.locationdescription = 'Remote' then 'CCG'
      when lc.locationdescription = 'San Diego' then 'SD'
      when lc.locationdescription = 'San Francisco' then 'SF'
      when lc.locationdescription = 'Washington DC' then 'DC' 
      else lc.locationcode end ::char(50) as division
*/
,lc.locationcode
,CASE lc.locationcode
   WHEN 'ATL'  THEN 'ATL'
   WHEN 'BET'  THEN 'DC'   
   WHEN 'COR'  THEN 'COR'
   WHEN 'DAL'  THEN 'DAL'
   WHEN 'SFR'  THEN 'SF'
   WHEN 'REM'  THEN 'REM'
   WHEN 'PHI'  THEN 'PHI'
   WHEN 'BAL'  THEN 'BAL'        
   WHEN 'HOU'  THEN 'HOU'
   WHEN 'CHI'  THEN 'CHI'   
   WHEN 'PHO'  THEN 'PHX'   
   WHEN 'DEN'  THEN 'DEN'
   WHEN 'EBA'  THEN 'EB'   
   WHEN 'MIA'  THEN 'MIA'  
   WHEN 'SDG'  THEN 'SD'   
   WHEN 'BGL'  THEN 'BGL'   
   WHEN 'CHA'  THEN 'CHAR'   
   WHEN 'CON'  THEN 'CMG' 
   WHEN 'KAN'  THEN 'KC'  
   WHEN 'MAD'  THEN 'MAD'   
   WHEN 'NJY'  THEN 'NJY'   
   WHEN 'NYC'  THEN 'NYC' 
   WHEN 'WAS'  THEN 'DC'   
   WHEN 'CCG'  THEN 'CCG'   
   --ELSE lc.locationcode END ::varchar(50) AS DivisionCode
   ELSE ' ' END ::varchar(50) AS division
   
         
,null ::char(50) as alt_id
,pv.gendercode ::char(1) as gender
,null as hicn     

from person_identity pi

LEFT join edi.edi_last_update elu on elu.feedid = 'AMJ_EBC_FSA_Eligibility'

JOIN person_bene_election pbet
  ON pbet.personid = pi.personid
 and pbet.personid in ---- pull emps that elected coverage - otherwise get emps that waived then termed employment
  (select distinct personid from person_bene_election 
    where current_timestamp between createts and endts
      and current_date between effectivedate and enddate
      and date_part('year',effectivedate)=date_part('year',current_date)
      and benefitsubclass in ('60', '61' )
      AND benefitelection in ('E'))    
      
JOIN person_identity pie 
  ON pie.personid = pi.personid
 AND pie.identitytype = 'EmpNo' ::bpchar 
 AND CURRENT_TIMESTAMP BETWEEN pie.createts and pie.endts

JOIN person_names pn 
  ON pn.personid = pi.personid 
 AND pn.nametype = 'Legal'::bpchar 
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts

JOIN person_address pa 
  ON pa.personid = pi.personid 
 AND pa.addresstype = 'Res'::bpchar 
 and current_date between pa.effectivedate and pa.enddate
 and current_timestamp between pa.createts and pa.endts

join person_locations pl
  on pl.personid = pi.personid
 and current_date between pl.effectivedate and pl.enddate
 and current_timestamp between pl.createts and pl.endts 

join location_codes lc 
  on lc.locationid = pl.locationid  
 AND current_date BETWEEN lc.effectivedate AND lc.enddate
 AND current_timestamp BETWEEN lc.createts AND lc.endts 

JOIN person_vitals pv 
  ON pv.personid = pi.personid 
 and current_date between pv.effectivedate and pv.enddate
 and current_timestamp between pv.createts and pv.endts

JOIN person_employment pe
  ON pe.personid = pi.personid
 AND current_date BETWEEN pe.effectivedate AND pe.enddate
 AND current_timestamp BETWEEN pe.createts AND pe.endts

LEFT JOIN person_phone_contacts ppcw 
  ON ppcw.personid = pi.personid 
 AND ppcw.phonecontacttype = 'Work'::bpchar 
 and current_date between ppcw.effectivedate and ppcw.enddate
 and current_timestamp between ppcw.createts and ppcw.endts

LEFT JOIN person_phone_contacts ppch 
  ON ppch.personid = pi.personid 
 AND ppch.phonecontacttype = 'Home'::bpchar 
 AND current_date BETWEEN ppch.effectivedate AND ppch.enddate
 AND current_timestamp BETWEEN ppch.createts AND ppch.endts

LEFT JOIN person_phone_contacts ppcm 
  ON ppcm.personid = pi.personid 
 AND ppcm.phonecontacttype = 'Mobile'::bpchar 
 AND current_date BETWEEN ppcm.effectivedate AND ppcm.enddate
 AND current_timestamp BETWEEN ppcm.createts AND ppcm.endts

LEFT JOIN person_net_contacts pnc 
  ON pnc.personid = pi.personid
 AND pnc.netcontacttype = 'WRK'::bpchar
 and current_date between pnc.effectivedate and pnc.enddate
 and current_timestamp between pnc.createts and pnc.endts

LEFT JOIN person_net_contacts pncH 
  ON pncH.personid = pi.personid
 AND pncH.netcontacttype = 'HomeEmail'::bpchar
 and current_date between pncH.effectivedate and pncH.enddate
 and current_timestamp between pncH.createts and pncH.endts

LEFT JOIN benefit_plan_desc bpdt
  on bpdt.benefitplanid = pbet.benefitplanid 
 and current_date between bpdt.effectivedate and bpdt.enddate
 and current_timestamp between bpdt.createts and bpdt.endts 
 
LEFT JOIN person_payroll pp 
  on pp.personid = pi.personid 
 and CURRENT_DATE BETWEEN pp.effectivedate AND pp.enddate 
 and CURRENT_TIMESTAMP BETWEEN pp.createts AND pp.endts

LEFT JOIN pay_unit pu 
   ON pu.payunitid = pp.payunitid
  AND current_timestamp between pu.createts and pu.endts

where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  and pbet.benefitsubclass in ('60', '61' )
  and pe.emplstatus = 'T'
  and pbet.effectivedate >= current_date  - interval '30 days' 
  and pbet.effectivedate >= elu.lastupdatets::DATE 


order by emp_last_name