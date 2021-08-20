select distinct
 pi.personid
,'PARTICIPATING EE' ::varchar(40) as qsource 
,pe.emplstatus
,pe.effectivedate
,sg.grade
--,coalesce(ppos.positionid,ppost.positionid) as positionid
--,coalesce(ppos.scheduledhours,ppost.scheduledhours) as scheduledhours
/*
,dedamt.vb1_amount as k401pt
,loans.v65_amount as ln1
,loans.v73_amount as ln2
,loans.vci_amount as ln3
,loans.vcj_amount as ln4
*/
,case when pu.payunitxid in ('10','15','16') then 'CER'
      when lc.locationcode in ('7B9') then 'SLK' else 'MAC' end ::char(3) as payunitxid
,'MO1302' ::char(6) as plan_nbr --col A
,'DGH'::char(3) as PayrollProvider --col B
,replace(pi.identity,'-','')::char(9) as SSN -- col C
,TRIM(UPPER('"'||pn.lname||', '||pn.fname||' '|| coalesce(LEFT(pn.mname,1),'')||'"'))::varchar(43) as fullname -- col D
,'"'||pa.streetaddress||'"' ::varchar(30) as addr1 -- col E
,'"'||pa.streetaddress2||'"' ::varchar(30) as addr2 -- col F
,''::varchar(1) as addr3 -- col G
,''::varchar(1) as addr4 -- col H
,'"'||pa.city||'"' ::varchar(18) as city -- col I
,case when trim(pa.countrycode) = 'US' then pa.stateprovincecode::char(8) end as state -- col J
,case when trim(pa.countrycode) = 'CA' then pa.stateprovincecode::char(8) end as province -- col K
,case when trim(pa.countrycode) = 'US' then '' else pa.countrycode::char(2) end as country -- col L
,pa.postalcode::varchar(15) as zip -- col M
,lc.locationcode as division -- col N
,' ' ::char(1) as region -- col O
,to_char(pv.birthdate,'mmddyyyy')::char(8) as dob -- col P
,case when pe.emplhiredate > current_date then '' else to_char(pe.emplhiredate,'mmddyyyy') end::char(8) as doh -- col Q original date of hire
,case when pe.emplstatus = 'T' then to_char(pe.effectivedate,'MMDDYYYY') else '' end ::char(8) as term_date -- col R
,' ' ::char(8) as date_of_transfer -- col S ??? not sure what to use here - it's supposed to be based off termination with reason code transfer out. Not set up in system. Lori is checking.
,case when pe.empllasthiredate <> pe.emplhiredate then to_char(pe.empllasthiredate,'MMDDYYYY') else '' end ::char(8) as rehire_date -- col T
,case when pe.emplstatus in ('A','T','L','D') then pe.emplstatus 
      when pe.emplstatus = 'P' then 'A' end ::char(1) as empstatus -- col U
,pv.gendercode -- col V
,pie.identity ::char(10) as empnbr -- col W
,'B' as pay_frequency -- col X

--,case when sg.grade in ('6') then ' ' else 'X' end::char(1) as ExcludableCode -- col Y ---'If Grade (union Code) = LAT or WDR, value is 'X', otherwise blank note sg.grade = 6 is non-union

--,case when sg.grade in ('6') then 'N' else 'U' end::char(1) as UnionCode -- col Z -- U if Grade = LAT or WDR, BED, HAY , else N  
/* Plan B if sg.grade does not hold true.
,case when unionloc.wdr = 'WDR' then 'X' 
      when unionloc.lat = 'LAT' then 'X' else ' ' end ::char(1) as ExcludableCode -- col Y ---'If Grade (union Code) = LAT or WDR, value is 'X', otherwise blank   
,case when unionloc.wdr = 'WDR' then 'U'
      when unionloc.lat = 'LAT' then 'U'
      when unionloc.bed = 'BED' then 'U'
      when unionloc.hay = 'HAY' then 'U' else 'N' end ::char(1) as UnionCode -- col Z -- U if Grade = LAT or WDR, BED, HAY , else N
--*/   
---- 1/31/19 third change for excludable union status codes
,case when sg.grade in ('1','4') then 'X' 
      when pe.emplclass = 'P' and ppos.scheduledhours < 40 then 'X' else ' ' end::char(1) as ExcludableCode -- col Y   
,case when sg.grade in ('6') then 'N' else 'U' end::char(1) as UnionCode -- col Z       
   
,coalesce(pnch.url,pncw.url,' ')::varchar(30) AS WorkEmail -- col AA 
,coalesce(ppch.phoneno, ppcm.phoneno, ' ')::varchar(10) AS PrimaryPhone -- col AB
,case when pc.frequencycode = 'H' then 'H'
      when pc.frequencycode = 'A' then 'S' else 'H' end ::char(1) as salarycode -- col AC
      
      
--,ytd401k.hours as ytd401k_hrs 
,ytdhrs.hours as ytd_hours -- col AD
,' ' ::char(1) as retire_elig_date -- col AE
,' ' ::char(1) as match_elig_date -- col AF
,' ' ::char(1) as spanish_ind -- col AG


--,ytd401k.taxable_amount as ytd401k
,cast(ytd401k.taxable_amount as dec(18,2)) as total_plan_ytd_comp -- col AH

--,cur401k.taxable_amount as cur401k
,cast(cur401K.taxable_amount as dec(18,2)) as total_ptd_comp -- col AI

----- 5/8/2019 - changed gross ytd and ptd to use payment header --- note vendor does not use this value
----- 5/8/2019 - gross or net wages not stored in bucket - can't be pulled from pspay_etv_operators table.

,cast(ytdwages.ytd_gross_pay as dec(18,2)) as gross_wage_ytd -- col AJ
,cast(wages.gross_pay as dec(18,2)) as gross_ptd_comp -- col AK


,' ' ::char(1) as total_plan_ytd_match -- col AL
,' ' ::char(1) as total_plan_ptd_match -- col AM
,case when pc.frequencycode = 'A' then pc.compamount
      when pc.frequencycode = 'H' then (pc.compamount * 2080 ) 
      end as annualSalary -- col AN
,' ' ::char(1) as total_plan_ytd_profitshr -- col AO
,cast(dedamt.vb1_amount as dec(18,2)) as ptd_401k_contrib -- col AP
,cast(dedamt.vb5_amount as dec(18,2)) as ptd_401k_match -- col AQ
,cast(dedamt.vb6_amount as dec(18,2)) as profit_sharing -- col AR --- Total RSA for all pay groups 
,' ' ::char(1) as ptd_after_tax_contrib -- col AS
,cast(dedamt.vb2_amount as dec(18,2)) as ptd_precu_contrib -- col AT
,cast(dedamt.vb3_amount as dec(18,2)) as ptd_roth_contrib -- col AU
,cast(dedamt.vb4_amount as dec(18,2)) as ptd_roth_cu -- col AV
,case when loans.check_date = dedamt.check_date then cast(loans.total_loan_amount as dec(18,2)) 
      when loans.check_date is not null and dedamt.check_date is null then cast(loans.total_loan_amount as dec(18,2)) 
      else 0.00 end as ptd_loan_repayments -- col AW
,' ' ::char(1) as ptd_misc1_contrib -- col AX
,' ' ::char(1) as ptd_misc2_contrib -- col AY
,to_char(dedamt.check_date,'MMDDYYYY')::char(8) as pay_date -- col AZ
,CASE WHEN pe.Emplevent = 'PartFull' AND pe.empleventdetcode = 'PF' THEN 'P' 
      else pe.emplclass END ::char(1) as work_status -- col BA


from person_identity pi

left join person_identity pie
  on pie.personid = pi.personid
 and pie.identitytype = 'EmpNo'
 and current_timestamp between pie.createts and pie.endts
 
join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts
 and pe.emplstatus not in ('C')
 
left join person_names pn
  on pn.personid = pe.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts
 
left join person_address pa
  on pa.personid = pe.personid
 and pa.addresstype = 'Res'
 and current_date between pa.effectivedate and pa.enddate
 and current_timestamp between pa.createts and pa.endts 

left join person_vitals pv
  on pv.personid = pe.personid
 and current_date between pv.effectivedate and pv.enddate
 and current_timestamp between pv.createts and pv.endts 
 
left join person_payroll pp
  on pp.personid = pi.personid
 and current_date between pp.effectivedate and pp.enddate
 and current_timestamp between pp.createts and pp.endts
 and pp.effectivedate - interval '1 day' <> pp.enddate 

----- issue with 18326 not pulling because of between on createts and endts
left join ( select personid, compamount, increaseamount, compevent, frequencycode, earningscode, max(createts) as createts, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate, RANK() OVER (PARTITION BY personid ORDER BY max(effectivedate)desc) AS RANK
              from person_compensation where effectivedate < enddate and current_timestamp BETWEEN createts and endts  
             group by personid, compamount, increaseamount, compevent, frequencycode, earningscode) as pc on pc.personid = pi.personid and pc.rank = 1   

left join ( select personid, positionid, scheduledhours, schedulefrequency, max(effectivedate) as effectivedate, RANK() OVER (PARTITION BY personid ORDER BY max(createts) DESC) AS RANK
              from pers_pos where current_timestamp between createts and endts and current_date between effectivedate and enddate
             group by personid, positionid, scheduledhours, schedulefrequency) ppos on ppos.personid = pe.personid and ppos.rank = 1  
            
left join ( select personid, positionid, scheduledhours, schedulefrequency, max(effectivedate) as effectivedate, RANK() OVER (PARTITION BY personid ORDER BY max(createts) DESC) AS RANK
             from pers_pos where current_timestamp between createts and endts and effectivedate < enddate
            group by personid, positionid, scheduledhours, schedulefrequency) ppost on ppost.personid = pe.personid and ppost.rank = 1                         
 
left join ( select personid, url, max(effectivedate) as effectivedate,  RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
              from person_net_contacts where netcontacttype = 'HomeEmail' and current_date between effectivedate and enddate and current_timestamp between createts and endts
             group by personid, url) pnch on pnch.personid = pe.personid and pnch.rank = 1 

left join ( select personid, url, max(effectivedate) as effectivedate,  RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
              from person_net_contacts where netcontacttype = 'WRK' and current_date between effectivedate and enddate and current_timestamp between createts and endts
             group by personid, url) pncw on pncw.personid = pe.personid and pncw.rank = 1              
 
left join ( select personid, phoneno, max(effectivedate) as effectivedate,  RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
              from person_phone_contacts where phonecontacttype = 'Home' and current_date between effectivedate and enddate and current_timestamp between createts and endts
             group by personid, phoneno) ppch on ppch.personid = pe.personid and ppch.rank = 1

left join ( select personid, phoneno, max(effectivedate) as effectivedate,  RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
              from person_phone_contacts where phonecontacttype = 'Mobile' and current_date between effectivedate and enddate and current_timestamp between createts and endts
             group by personid, phoneno) ppcm on ppcm.personid = pe.personid and ppcm.rank = 1
             
left join person_locations ploc
  on ploc.personid = pe.personid 
 and ploc.personlocationtype = 'P'
 and current_date between ploc.effectivedate and ploc.enddate
 and current_timestamp between ploc.createts and ploc.endts

left join location_codes lc
  on lc.locationid = ploc.locationid
 and current_date between lc.effectivedate and lc.enddate
 and current_timestamp between lc.createts and lc.endts  
 
left join person_payroll ppl 
  on ppl.personid = pe.personid 
 and current_date between ppl.effectivedate and ppl.enddate
 and current_timestamp between ppl.createts and ppl.endts
 
left join pay_unit pu on pu.payunitid = ppl.payunitid

left join (select positionid, grade, positiontitle, flsacode, max(effectivedate) as effectivedate, RANK() OVER (PARTITION BY positionid ORDER BY max(effectivedate) DESC) AS RANK
             from position_desc where effectivedate < enddate and current_timestamp between createts and endts 
            group by positionid, grade, positiontitle, flsacode) pd on pd.positionid = coalesce(ppos.positionid,ppost.positionid) and pd.rank = 1
          

left join salary_grade sg
  on sg.grade = pd.grade
 and current_date between sg.effectivedate and sg.enddate
 and current_timestamp between sg.createts and sg.endts  

--- neeed to determine actual union associations for EE - if salary_grade doesn't work.
left join (select distinct pp.personid,pn.name ,pp.positionid,wdr.organizationdesc as wdr,lat.organizationdesc as lat,bed.organizationdesc as bed,case when hay.organizationdesc = 'CER' then 'HAY' else null end as hay
             from pers_pos pp
             join pos_org_rel porb 
               ON porb.positionid = pp.positionid
              and current_date between pp.effectivedate and pp.enddate
              and current_timestamp between pp.createts and pp.endts
             join person_names pn on pn.personid = pp.personid and pn.nametype = 'Legal' and current_date between pn.effectivedate and pn.enddate and current_timestamp between pn.createts and pn.endts
left join (select organizationdesc::char(3) as organizationdesc, organizationid
             from organization_code 
            where current_date between effectivedate and enddate 
              and current_timestamp between createts and endts 
              and organizationtype = 'Dept' and orgcode like 'Y%' group by 1,2) wdr on wdr.organizationid = porb.organizationid
left join (select organizationdesc::char(3) as organizationdesc, organizationid
             from organization_code 
            where current_date between effectivedate and enddate 
              and current_timestamp between createts and endts 
              and organizationtype = 'Dept' 
              and orgcode in (select orgcode from organization_code where current_date between effectivedate and enddate and current_timestamp between createts and endts and organizationtype = 'Dept' and organizationdesc like 'LAT%' group by 1)
         group by 1,2) lat on lat.organizationid = porb.organizationid
left join (select organizationdesc::char(3) as organizationdesc, organizationid
             from organization_code 
            where current_date between effectivedate and enddate 
              and current_timestamp between createts and endts 
              and organizationtype = 'Dept' 
              and orgcode in (select orgcode from organization_code where current_date between effectivedate and enddate and current_timestamp between createts and endts and organizationtype = 'Dept' and organizationdesc like 'BED%' group by 1)
         group by 1,2) bed on bed.organizationid = porb.organizationid
left join (select organizationdesc::char(3) as organizationdesc, organizationid
             from organization_code 
            where current_date between effectivedate and enddate 
              and current_timestamp between createts and endts 
              and organizationtype = 'Dept' 
              and orgcode in (select orgcode from organization_code where current_date between effectivedate and enddate and current_timestamp between createts and endts and organizationtype = 'Dept' and organizationdesc like 'CER%' group by 1)
         group by 1,2) hay on hay.organizationid = porb.organizationid where current_date between pp.effectivedate and pp.enddate and current_timestamp between pp.createts and pp.endts        
) unionloc on unionloc.personid = pe.personid  

--------------------------------------------------             
----- YTD 401K HOURS - BASED ON WS23 OPERAND -----
--------------------------------------------------    
left join (select ppd.personid, sum(ppd.etype_hours) as hours, sum(etv_amount) as taxable_amount
   from pspay_payment_detail ppd
   join pspay_etv_operators peo on peo.etv_id = ppd.etv_id and peo.group_key = ppd.group_key 
  where peo.operand = 'WS23' and peo.etvindicator = 'E' and peo.group_key <> '$$$$$' and peo.opcode = 'A'  
    and ppd.paymentheaderid in 
                  (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                     (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay join edi.edi_last_update elu 
                             on elu.feedid = 'DGH_JH_401K_Export' 
                            and date_part('year',ppay.statusdate) = date_part('year',elu.lastupdatets)
                             where ppay.pspaypayrollstatusid = 4 ))) group by 1) ytdhrs ON ytdhrs.personid = pe.personid  
                             
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
                             on elu.feedid = 'DGH_JH_401K_Export' 
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
                             on elu.feedid = 'DGH_JH_401K_Export' 
                            and ppay.statusdate >= elu.lastupdatets
                             where ppay.pspaypayrollstatusid = 4 )))
    --and ppd.etv_id in (select a.etv_id from pspay_etv_operators a where a.operand = 'WS15' and a.etvindicator = 'E' and a.group_key <> '$$$$$' and a.opcode = 'A' group by 1)                  
     and peo.operand = 'WS15' and peo.etvindicator = 'E' and peo.group_key <> '$$$$$' and peo.opcode = 'A' 
group by 1) cur401k  ON cur401k.personid = pi.personid    

----- 5/8/2019 - changed gross ytd and ptd to use payment header --- note vendor does not use this value
----- 5/8/2019 - gross or net wages not stored in bucket - can't be pulled from pspay_etv_operators table.

left join 
(select
 pph.personid
--,pph.check_date
,sum(pph.gross_pay) as gross_pay
--,pph.paymentheaderid

from pspay_payment_header pph

where paymentheaderid in 
        (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay join edi.edi_last_update elu 
                             on elu.feedid = 'DGH_JH_401K_Export' and elu.lastupdatets <= ppay.statusdate
                             where ppay.pspaypayrollstatusid = 4 ))) group by 1
                             ) wages on wages.personid = pi.personid
left join
(select 
 pph.personid
,sum(pph.gross_pay) as ytd_gross_pay

from pspay_payment_header pph

where paymentheaderid in 
        (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay 
                             where ppay.pspaypayrollstatusid = 4 )))
                             AND date_part('year', pph.check_date) = date_part('year',current_date)
                            group by 1) ytdwages on ytdwages.personid = pi.personid                           

left join 
(select 
 x.personid
,x.check_date
,sum(x.vb1_amount) as vb1_amount
,sum(x.vb2_amount) as vb2_amount
,sum(x.vb3_amount) as vb3_amount
,sum(x.vb4_amount) as vb4_amount
,sum(x.vb5_amount) as vb5_amount
,sum(x.vb6_amount) as vb6_amount
from
 

(select distinct
 ppd.personid
,ppd.check_date
,case when ppd.etv_id = 'VB1' then etv_amount  else 0 end as vb1_amount
,case when ppd.etv_id = 'VB2' then etv_amount  else 0 end as vb2_amount
,case when ppd.etv_id = 'VB3' then etv_amount  else 0 end as vb3_amount
,case when ppd.etv_id = 'VB4' then etv_amount  else 0 end as vb4_amount
,case when ppd.etv_id = 'VB5' then etv_amount  else 0 end as vb5_amount
,case when ppd.etv_id = 'VB6' then etv_amount  else 0 end as vb6_amount
,ppd.paymentheaderid

from pspay_payment_detail ppd

where paymentheaderid in 
        (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay join edi.edi_last_update elu 
                             on elu.feedid = 'DGH_JH_401K_Export' and elu.lastupdatets <= ppay.statusdate
                             where ppay.pspaypayrollstatusid = 4 )))
  and ppd.etv_id  in  ('VB1','VB2','VB3','VB4','VB5','VB6')) x
  group by 1,2 having sum(x.vb1_amount + x.vb2_amount + x.vb3_amount + x.vb4_amount + x.vb5_amount + x.vb6_amount) <> 0) dedamt on dedamt.personid = pi.personid 
  
left join 
(select 
 x.personid
,x.check_date
,sum(x.v65_amount) as v65_amount -- loan 1
,sum(x.v73_amount) as v73_amount -- loan 2
,sum(x.vci_amount) as vci_amount -- loan 3
,sum(x.vcj_amount) as vcj_amount -- loan 4
,sum(x.v65_amount+x.v73_amount+x.vci_amount+x.vcj_amount) as total_loan_amount

from
(select distinct
 ppd.personid
,ppd.check_date
,case when ppd.etv_id = 'V65' then etv_amount  else 0 end as v65_amount
,case when ppd.etv_id = 'V73' then etv_amount  else 0 end as v73_amount
,case when ppd.etv_id = 'VCI' then etv_amount  else 0 end as vci_amount
,case when ppd.etv_id = 'VCJ' then etv_amount  else 0 end as vcj_amount
,ppd.paymentheaderid

from pspay_payment_detail ppd

where paymentheaderid in 
        (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay join edi.edi_last_update elu 
                             on elu.feedid = 'DGH_JH_401K_Export' and elu.lastupdatets <= ppay.statusdate
                             where ppay.pspaypayrollstatusid = 4 ))) -- pspaypayrollstatusid = 4 means payroll completed
  and ppd.etv_id  in ('V65','V73','VCI','VCJ')) x  
group by 1,2 having sum(x.v65_amount + x.v73_amount + x.vci_amount + x.vcj_amount) <> 0) loans on loans.personid = pe.personid 

 
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  --and pe.personid in ('17972','18116','18251','19806')
  and (pe.emplstatus in ('L','A','P')
   or (pe.personid in 
  (select distinct pe.personid 
     from person_employment pe 
     join pspay_payment_detail ppd on ppd.personid = pe.personid
    where pe.emplstatus in ('R','T')
      and ppd.paymentheaderid in 
        (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay join edi.edi_last_update elu 
                             on elu.feedid = 'DGH_JH_401K_Export' and elu.lastupdatets <= ppay.statusdate
                             where ppay.pspaypayrollstatusid = 4 ))))))