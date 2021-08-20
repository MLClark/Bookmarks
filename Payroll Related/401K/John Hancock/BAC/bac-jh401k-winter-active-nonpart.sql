select distinct
 pi.personid
,pe.emplstatus
,elu.lastupdatets
,'ACTIVE NON-PARTICIPATING EE' ::varchar(50) as qsource
,'MO1302' ::char(8) as plan_nbr --col A
,'BAC' ::char(7) as contnbr -- col B
,replace(pi.identity,'-','') ::char(9) as Essn -- col C
,TRIM(UPPER('"' ||pne.lname||', '||pne.fname||' '|| coalesce(LEFT(pne.mname,1),' '))||'"')::varchar(43) as fullname -- col D
,replace(pae.streetaddress,',','')  ::varchar(30) as addr1 -- col E
,replace(pae.streetaddress2,',','') ::varchar(30) as addr2 -- col F
,replace(pae.streetaddress3,',','') ::varchar(30) as addr3 -- col G
,replace(pae.streetaddress4,',','') ::varchar(30) as addr4 -- col H
,pae.city ::varchar(18) as city -- col I
,pae.stateprovincecode ::char(2) as state -- col J
,' ' ::char(1) as province -- col K
,pae.countrycode ::char(3) as country -- col L
,pae.postalcode ::varchar(10) as zip -- col M
,substring(pip.identity,1,5) ::char(5) as division -- col N
,' ' ::char(1) as region -- col O
,to_char(pve.birthdate,'mmddyyyy')::char(8) as dob -- col P
,to_char(pe.empllasthiredate,'mmddyyyy')::char(8) as doh -- col Q
,case when pe.emplstatus in ('R','T') then to_char(pe.effectivedate,'MMDDYYYY') end ::char(8) as term_date -- col R
,case when pe.empleventdetcode in ('TrOut') then to_char(pe.effectivedate,'MMDDYYYY') else ' ' end ::char(8) as int_xfer_date -- col S
,case when pe.emplhiredate <> pe.effectivedate then to_char(pe.effectivedate,'MMDDYYYY') else null end ::char(8) as rehire_date -- col T
,case when pe.emplstatus in ('A','T','L','R') then pe.emplstatus 
      when pe.emplstatus = 'P' then 'A' end ::char(1) as empstatus -- col U
,case when pve.gendercode = 'U' then ' ' else pve.gendercode ::char(1) end as gender -- col V
,pie.identity ::char(10) as empnbr -- col W      
,case when pc.frequencycode =  'H' and substring(pip.identity,1,5) in ('BAC05','BAC15') then 'W' 
      when pc.frequencycode =  'H' then 'B' 
      when pc.frequencycode =  'A' then 'B' else 'B'  end ::char(1) as frequency  ---- needs to be converted to W / B
,' ' ::char(1) as excludable_code -- col Y  
,case when substring(pip.identity,1,5) in ('BAC05','BAC15') then 'U' else 'N' end ::char(1) as union_code -- col Z   
,coalesce(pncw.url,' ') ::varchar(30) AS WorkEmail -- col AA
,coalesce(ppch.phoneno,ppcw.phoneno,ppcb.phoneno,ppcm.phoneno,' ') ::varchar(10) AS PrimaryPhone -- col AB
,case when pc.frequencycode = 'A' then 'S' else 'H' end ::char(1) as sal_code -- col AC
,ytd401k.hours as ytd_hours -- col AD
,' ' ::char(1) as retire_elig_date -- col AE
,' ' ::char(1) as match_elig_date -- col AF
,' ' ::char(1) as spanish_ind -- col AG
----------------------------------------------------------------
,ytd401k.taxable_amount  as ytd_401k_wage          ----- col AH  
,cur401k.taxable_amount  as current_401k_wage      ----- col AI
----------------------------------------------------------------
,ytdwages.gross_pay      as gross_wage_ytd         ----- col AJ
,wages.gross_pay         as gross_wage_current     ----- col AK
----------------------------------------------------------------
,' ' ::char(1)           as match_ytd              ----- col AL
,' ' ::char(1)           as match_current          ----- col AM
,case when pc.frequencycode = 'A' then pc.compamount
      when pc.frequencycode = 'H' then (pc.compamount * 2080 ) 
      end as annualSalary                          ----- col AN
,' ' ::char(1)          as profit_sharing_ytd      ----- col AO
----------------------------------------------------------------
,0                      as current_401k_ee         ----- col AP
----------------------------------------------------------------
,0                      as current_401k_er_match   ----- col AQ
----------------------------------------------------------------
,0                      as profit_sharing          ----- col AR 
----------------------------------------------------------------
,' ' ::char(1)          as after_tax_contrib       ----- col AS
,0                      as pretax_cu               ----- col AT 
----------------------------------------------------------------
,0                      as roth_contrib            ----- col AU   
----------------------------------------------------------------
,0                      as roth_cu                 ----- col AV
----------------------------------------------------------------
,0                      as loan_payment            ----- col AW 
----------------------------------------------------------------
,0                      as profit_sharing_cur      ----- col AX     
----------------------------------------------------------------  
,' ' ::char(1)          as ptd_misc2_contrib       ----- col AY
,null                   as pay_date -- col AZ   
,case when pe.emplevent = 'PartFull' and pe.empleventdetcode = 'PF' then 'P'
      else 'F' end ::char(1) as work_status        ----- col BA
  

from person_identity pi

join edi.edi_last_update elu on elu.feedid = 'BAC_JH_401K_Export'

join person_identity pip
  on pip.personid = pi.personid
 and pip.identitytype = 'PSPID'
 and current_timestamp between pip.createts and pip.endts

join person_identity pie
  on pie.personid = pi.personid
 and pie.identitytype = 'EmpNo'
 and current_timestamp between pie.createts and pie.endts 
 
left join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts
 and pe.effectivedate - interval '1 day' <> pe.enddate 
 
join person_vitals pve
  on pve.personid = pi.personid
 and current_date between pve.effectivedate and pve.enddate
 and current_timestamp between pve.createts and pve.endts  
 and pve.effectivedate - interval '1 day' <> pve.enddate
 
join person_names pne
  on pne.personid = pi.personid
 and pne.nametype = 'Legal'
 and current_date between pne.effectivedate and pne.enddate
 and current_timestamp between pne.createts and pne.endts
 and pne.effectivedate - interval '1 day' <> pne.enddate
  
join person_address pae 
  on pae.personid = pi.personid
 and addresstype = 'Res'  
 and current_date between pae.effectivedate and pae.enddate
 and current_timestamp between pae.createts and pae.endts 
 and pae.effectivedate - interval '1 day' <> pae.enddate

left join person_net_contacts pncw 
  on pncw.personid = pi.personid 
 and pncw.netcontacttype = 'WRK'::bpchar 
 and current_date between pncw.effectivedate and pncw.enddate
 and current_timestamp between pncw.createts and pncw.enddate   
 and pncw.effectivedate - interval '1 day' <> pncw.enddate 

-- select * from person_phone_contacts where personid = '1027';
left join (select personid, phoneno, enddate, max(effectivedate) as effectivedate, max(endts) as endts,  RANK() OVER (PARTITION BY personid ORDER BY max(endts) DESC) AS RANK
             from person_phone_contacts where phonecontacttype in ('BUSN') and current_date between effectivedate and enddate and current_timestamp between createts and endts
            group by personid, phoneno, enddate) ppcb on ppcb.personid = pi.personid  
left join (select personid, phoneno, enddate, max(effectivedate) as effectivedate, max(endts) as endts,  RANK() OVER (PARTITION BY personid ORDER BY max(endts) DESC) AS RANK
             from person_phone_contacts where phonecontacttype in ('Work') and current_date between effectivedate and enddate and current_timestamp between createts and endts
            group by personid, phoneno, enddate) ppcw on ppcw.personid = pi.personid  
left join (select personid, phoneno, enddate, max(effectivedate) as effectivedate, max(endts) as endts,  RANK() OVER (PARTITION BY personid ORDER BY max(endts) DESC) AS RANK
             from person_phone_contacts where phonecontacttype in ('Home') and current_date between effectivedate and enddate and current_timestamp between createts and endts
            group by personid, phoneno, enddate) ppch on ppch.personid = pi.personid     
left join (select personid, phoneno, enddate, max(effectivedate) as effectivedate, max(endts) as endts,  RANK() OVER (PARTITION BY personid ORDER BY max(endts) DESC) AS RANK
             from person_phone_contacts where phonecontacttype in ('Mobile') and current_date between effectivedate and enddate and current_timestamp between createts and endts
            group by personid, phoneno, enddate) ppcm on ppcm.personid = pi.personid 

left join (select personid, compamount, frequencycode, max(createts) as createts, max(effectivedate) as effectivedate, max(enddate) as enddate,rank() over (partition by personid order by max(createts),max(effectivedate) desc) as rank
             from person_compensation where compamount <> 0 
            group by personid, compamount, frequencycode) pc on pc.personid = pi.personid and pc.rank = 1 

--------------------------------------------------             
----- YTD 401K WAGES - BASED ON WS15 OPERAND -----
--------------------------------------------------             
left join (select ppd.personid, sum(ppd.etype_hours) as hours, sum(etv_amount) as taxable_amount
             from pspay_payment_detail ppd
             join pspay_etv_operators peo on peo.etv_id = ppd.etv_id and peo.group_key = ppd.group_key 
            where ppd.paymentheaderid in 
                  (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                     (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay join edi.edi_last_update elu 
                             on elu.feedid = 'BAC_JH_401K_Export' 
                            and date_part('year',ppay.statusdate) = date_part('year',elu.lastupdatets)
                             where ppay.pspaypayrollstatusid = 4 )))
    --and ppd.etv_id in (select a.etv_id from pspay_etv_operators a where a.operand = 'WS15' and a.etvindicator = 'E' and a.group_key <> '$$$$$' and a.opcode = 'A' group by 1)                  
     and peo.operand = 'WS15' and peo.etvindicator = 'E' and peo.group_key <> '$$$$$' and peo.opcode = 'A' 
group by 1) ytd401k  ON ytd401k.personid = pi.personid  
--------------------------------------------------             
----- CUR 401K WAGES - BASED ON WS15 OPERAND -----
--------------------------------------------------  
left join (select ppd.personid, sum(ppd.etype_hours) as hours, sum(etv_amount) AS taxable_amount
             from pspay_payment_detail ppd
             join pspay_etv_operators peo on peo.etv_id = ppd.etv_id and peo.group_key = ppd.group_key 
            where ppd.paymentheaderid in 
                  (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                     (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay join edi.edi_last_update elu 
                             on elu.feedid = 'BAC_JH_401K_Export' 
                            and elu.lastupdatets <= ppay.statusdate
                             where ppay.pspaypayrollstatusid = 4 )))
    --and ppd.etv_id in (select a.etv_id from pspay_etv_operators a where a.operand = 'WS15' and a.etvindicator = 'E' and a.group_key <> '$$$$$' and a.opcode = 'A' group by 1)                  
     and peo.operand = 'WS15' and peo.etvindicator = 'E' and peo.group_key <> '$$$$$' and peo.opcode = 'A' 
group by 1) cur401k  ON cur401k.personid = pi.personid  
---------------------------------------------------------------------------------------
---- gross CURRENT should come from batch header NOT BASED ON pspay_etv_operators -----
---------------------------------------------------------------------------------------
left join 
(select
 pph.personid
,sum(pph.gross_pay) as gross_pay
from pspay_payment_header pph
where paymentheaderid in 
        (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay join edi.edi_last_update elu 
                             on elu.feedid = 'BAC_JH_401K_Export' and elu.lastupdatets <= ppay.statusdate
                             where ppay.pspaypayrollstatusid = 4 ))) group by 1 
                             ) wages on wages.personid = pi.personid ----grosscur
-----------------------------------------------------------------------------------
---- gross YTD should come from batch header NOT BASED ON pspay_etv_operators -----
-----------------------------------------------------------------------------------                             
left join
(select 
 pph.personid
,sum(pph.gross_pay) as gross_pay
from pspay_payment_header pph
where paymentheaderid in 
        (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay 
                             where ppay.pspaypayrollstatusid = 4 )))
                             AND date_part('year', pph.check_date) = date_part('year',current_date)
                            group by 1) ytdwages on ytdwages.personid = pi.personid   -----grossytd         
---------------------------------------
------    MEMBER CONTRIBUTIONS    -----
---------------------------------------


where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts 
  and pe.emplstatus in ('A','L')
  --and pe.personid = '2657'
  ------ include all ee not currently participaing in 401k
  and (pe.personid not in (select distinct ppd.personid from pspay_payment_detail ppd where ppd.paymentheaderid in 
        (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay join edi.edi_last_update elu 
                             on elu.feedid = 'BAC_JH_401K_Export' and elu.lastupdatets <= ppay.statusdate
                             where ppay.pspaypayrollstatusid = 4 )))))