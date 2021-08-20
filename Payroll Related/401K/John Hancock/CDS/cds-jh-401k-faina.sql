
select distinct
pi.personid
,'PARTICIPATING EE' ::varchar(40) as qsource 
,pe.emplstatus
,pe.effectivedate
---------------start -------------------------------------------------------------------------------------------------------------------------------------------
,'comb.d  ' ::char(8) as comb_h10 --col 1
,'140886 '::char(7) as Cont --col 2
,replace(pi.identity,'-','')::char(9) as SSN -- col 3

--,TRIM(UPPER('"'||pn.fname||'"'))::varchar(18) as FirstName -- col 4
--,TRIM(UPPER('"'||pn.lname||'"'))::varchar(20) as LastName -- col 5
--,TRIM(UPPER('"'||coalesce(LEFT(pn.mname,1),'')||'"'))::varchar(1) as Initial -- col 6
,TRIM(UPPER(pn.fname))::varchar(18) as FirstName -- col 4
,TRIM(UPPER(pn.lname))::varchar(20) as LastName -- col 5
,TRIM(UPPER(coalesce(LEFT(pn.mname,1),'')))::varchar(1) as Initial -- col 6
,null :: varchar(4) as NamePrefix --col 7
,pie.identity ::char(9) as EEID -- col 8
--,'"'||pa.streetaddress||'"' ::varchar(30) as Address1 -- col 9
--,'"'||pa.streetaddress2||'"' ::varchar(30) as Address2 -- col 10
--,'"'||pa.city||'"' ::varchar(25) as city -- col 11

,pa.streetaddress ::varchar(30) as Address1 -- col 9
,pa.streetaddress2 ::varchar(30) as Address2 -- col 10
,pa.city::varchar(25) as city -- col 11

,rtrim(ltrim(pa.stateprovincecode)) ::char(2) as state -- col 12
,pa.postalcode::varchar(10) as zip -- col 13
,null :: char(3) as country -- col 14
,rtrim(ltrim(pa.stateprovincecode)) ::char(2) as StateRes -- col 15
,null :: char(99) as ERProvEmail --col 16

--,replace(pu.employertaxid,'-','') as division -- col Q
,replace(pu.payunitdesc,'-','') as division -- col 17
----------------------------------------------------------------------
,to_char(pv.birthdate,'mmddyyyy')::char(8) as dob -- col 18
,case when pe.emplhiredate > current_date then '' else to_char(pe.emplhiredate,'mmddyyyy') end::char(8) as doh -- col 19 original date of hire
,case when pe.emplstatus in ('A','T','L','D') then pe.emplstatus 
      when pe.emplstatus = 'P' then 'A' 
 end ::char(1) as empstatus -- col 20

------
,case when pe.empllasthiredate <> pe.emplhiredate and pe.emplstatus = 'A' then to_char(pe.empllasthiredate,'mmddyyyy') 
      when pe.empllasthiredate = pe.emplhiredate and pe.emplstatus = 'A' then to_char(pe.emplhiredate,'mmddyyyy') 
      when pe.emplstatus in ('R','T')then to_char(pe.effectivedate,'mmddyyyy') 
      else '' 
end ::char(8) as EmplStatDate -- col 21
-----
,null ::char(1) as EligInd -- col 22
,null ::char(8) as EligDate --col 23
,null ::char(1) as OptOutInd --col 24

,total_hours.hours as YTDhrs --col 25
,wage_amount.Amount as PlanYTDComp --col 26

,to_char(dedamt.check_date,'mmddyyyy')::char(8) as YTDHrsWkCompDt --col 27 as paydate

,case when pc.frequencycode = 'A' then to_char(pc.compamount,'FM0000000000D00')
      when pc.frequencycode = 'H' then to_char((pc.compamount * 2080 ) ,'FM0000000000D00')
end as BaseSalary -- col 28

---------           
,pfpe.financialelectionrate as BfTxDefPct --col 29
,pfpe.financialelectionamount as BfTxFltDoDef --col 30
,pfpe1.financialelectionrate as DesigRothPct --col 31
,pfpe1.financialelectionamount as DesigRothAmt --col 32
------------------
,'505' as Trans --33
--,psp.payenddate as Date_end --col 34 Pay Period End Date
,to_char(psp.periodenddate,'mmddyyyy')::char(8) as Date_end --col 34 Pay Period End Date

,coalesce (dedamt.vb1_amount + dedamt.vb2_amount + dedamt.v25_amount + dedamt.vdo_amount + dedamt.vdp_amount + dedamt.vcg_amount, 0) as EEDEF --35 Employee Deferral
,coalesce (dedamt.vb5_amount, 0) as ERMAT --36 Employer Match
,null as QMAC --37
,null as SHMAC --38
,null as ERMC3 --39
,coalesce (dedamt.vb3_amount + dedamt.vb4_amount, 0) as EEROT --40 Employee Roth
,null as QNEC  --41
,null as SHNEC --42
,null as ERPS --43
,null as EERC --44
,null as EEVND --45
,null as EEVD --46
,null as EEMAN --47
,null as ERMP --48
,null as ERCON --49
,null as S_HGR --50
,null as EEMT1 --51
,null as EEMT2 --52
,null as ERMT1 --53
,null as ERMT2 --54
,null as ERMT3 --55
,null as ERMT4 --56
,null as ERMT5 --57
,null as ERMT6 --58
,null as LoanID_1 --59
,null as LoanAmt_1 --60
,null as LoanID_2 --61
,null as LoanAmt_2 --62
,null as LoanID_3 --63
,null as LoanAmt_3 --64
,null as LoanID_4 --65
,null as LoanAmt_4 --66
,null as LoanID_5 --67
,null as LoanAmt_5 --68
,null as LoanID_6 --69
,null as LoanAmt_6  --70
,null as LoanID_7  --71
,null as LoanAmt_7  --72
,null as LoanID_8  --73
,null as LoanAmt_8  --74
,null as LoanID_9  --75
,null as LoanAmt_9  --76
,null as LoanID_10  --77
,null as LoanAmt_10  --78
,'1' as sort_seq
,ed.feedid
,current_timestamp as updatets

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

left JOIN pay_unit pu
ON pu.payunitid = pp.payunitid
AND CURRENT_TIMESTAMP BETWEEN pu.createts AND pu.endts

left join ( select personid, compamount, increaseamount, compevent, frequencycode, earningscode, max(createts) as createts, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate, RANK() OVER (PARTITION BY personid ORDER BY max(effectivedate)desc) AS RANK
              from person_compensation where effectivedate < enddate and current_timestamp BETWEEN createts and endts  
             group by personid, compamount, increaseamount, compevent, frequencycode, earningscode) as pc on pc.personid = pi.personid and pc.rank = 1   


LEFT JOIN person_deduction_setup pds
  on pi.personid = pds.personid
and pds.etvid = 'V65'
and current_date between pds.effectivedate and pds.enddate
and current_timestamp between pds.createts and pds.endts 

left join 
(select 
 x.personid
,x.check_date
,sum(x.vb1_amount) as vb1_amount
,sum(x.vb2_amount) as vb2_amount
,sum(x.v25_amount) as v25_amount
,sum(x.vdo_amount) as vdo_amount
,sum(x.vdp_amount) as vdp_amount
,sum(x.vcg_amount) as vcg_amount
,sum(x.vb3_amount) as vb3_amount
,sum(x.vb4_amount) as vb4_amount
,sum(x.vb5_amount) as vb5_amount
,x.payscheduleperiodid
from


(select distinct
ppd.personid
,ppd.check_date
,case when ppd.etv_id = 'VB1' then etv_amount  else 0 end as vb1_amount
,case when ppd.etv_id = 'VB2' then etv_amount  else 0 end as vb2_amount
,case when ppd.etv_id = 'V25' then etv_amount  else 0 end as v25_amount
,case when ppd.etv_id = 'VDO' then etv_amount  else 0 end as vdo_amount
,case when ppd.etv_id = 'VDP' then etv_amount  else 0 end as vdp_amount
,case when ppd.etv_id = 'VCG' then etv_amount  else 0 end as vcg_amount
,case when ppd.etv_id = 'VB3' then etv_amount  else 0 end as vb3_amount
,case when ppd.etv_id = 'VB4' then etv_amount  else 0 end as vb4_amount
,case when ppd.etv_id = 'VB5' then etv_amount  else 0 end as vb5_amount
,ppd.paymentheaderid
,pph.payscheduleperiodid
from pspay_payment_detail ppd
join pspay_payment_header pph on ppd.paymentheaderid = pph.paymentheaderid
where pph.paymentheaderid in 
        (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay join edi.edi_last_update elu 
                             on elu.feedid =  'CDS_JH_401K_Export' and elu.lastupdatets <= ppay.statusdate
                             where ppay.pspaypayrollstatusid = 4 )))
  and ppd.etv_id  in  ('VB1','VB2','V25','VDO','VDP','VCG','VB3','VB4','VB5')) x
  group by 1,2,payscheduleperiodid  having sum(x.vb1_amount + x.vb2_amount + v25_amount + vdo_amount + vdp_amount + vcg_amount + x.vb3_amount + x.vb4_amount + x.vb5_amount) <> 0) 
        dedamt on dedamt.personid = pi.personid 



------------------------------------------------------------------------------------------------------------------------------------------
-- New Hours Start 

LEFT JOIN (SELECT h.personid
             ,h.check_date 
                 ,sum(h.etype_hours) as Hours
             FROM          
            
       (Select distinct
             ppdh.personid
             ,ppdh.check_date
             ,ppdh.etype_hours
             ,ppdh.paymentheaderid
             from pspay_payment_detail ppdh
             where ppdh.paymentheaderid in 
                    (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                           (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                                 (select pspaypayrollid from pspay_payroll ppay join edi.edi_last_update elu 
                                      on elu.feedid =  'CDS_JH_401K_Export' and elu.lastupdatets <= ppay.statusdate
                                      where ppay.pspaypayrollstatusid = 4 ))) and ppdh.etv_id  in  (select a.etv_id from pspay_etv_operators a  
                                                where a.operand = 'WS23' and a.etvindicator = 'E' and a.opcode = 'A' and a.group_key <> '$$$$$' group by 1)) h group by 1,2) 
                                                            total_hours on total_hours.personid = pi.personid and total_hours.check_date = dedamt.check_date



-- New Hours End 
------------------------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------------------------
--New Wages Start 

LEFT JOIN (SELECT w.personid
             ,w.check_date 
                 ,sum(w.etv_amount) as  Amount
             FROM          
            
       (Select distinct
             ppdw.personid
             ,ppdw.check_date
             ,ppdw.etv_amount 
             ,ppdw.paymentheaderid
             from pspay_payment_detail ppdw
             where ppdw.paymentheaderid in 
                    (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                           (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                                 (select pspaypayrollid from pspay_payroll ppay join edi.edi_last_update elu 
                                      on elu.feedid =  'CDS_JH_401K_Export' and elu.lastupdatets <= ppay.statusdate
                                      where ppay.pspaypayrollstatusid = 4 ))) and ppdw.etv_id  in  (select a.etv_id from pspay_etv_operators a
                                                            where a.operand = 'WS15' and a.etvindicator = 'E' and a.opcode = 'A' and a.group_key <> '$$$$$' group by 1)) w group by 1,2) 
                                                            wage_amount on wage_amount.personid = pi.personid 
                                                            and wage_amount.check_date = dedamt.check_date


------------------------------------------------------------------------------------------------------------------------------------------
left join person_financial_plan_election pfpe --percent
  on pfpe.personid = pi.personid
--and pfpe.benefitsubclass in  ('40','43','46','47','4C','457')
and pfpe.benefitsubclass in  ('40')
and current_date between pfpe.effectivedate and pfpe.enddate
and current_timestamp between pfpe.createts and pfpe.endts
-------------------------------------------------------------------------------------------------------------------------
left join person_financial_plan_election pfpe1 --flat amt
  on pfpe1.personid = pi.personid
--and pfpe1.benefitsubclass in   ('4R','4Z')
and pfpe1.benefitsubclass in   ('4Z')
and current_date between pfpe1.effectivedate and pfpe1.enddate
and current_timestamp between pfpe1.createts and pfpe1.endts
-------------------------------------------------------------------------------------------------------------------------
join (select personid, check_date, etv_id from pspay_payment_detail) as ppd on ppd.personid = pi.personid 
             --and ppd.etv_id  in  ('VB1','VB2','V25','VDO','VDP','VCG','VB3','VB4','VB5')
                               
join pay_schedule_period psp on psp.payscheduleperiodid = dedamt.payscheduleperiodid



LEFT JOIN edi.edi_last_update ed
ON ed.feedid = 'CDS_JH_401K_Export'

------------------------------------------------------------------------------------------------------------------------
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  --and pe.personid in ('17972','18116','18251','19806')
  and (pe.emplstatus in ('L','A','P')
   or 
 (pe.personid NOT in 
  (select distinct pe.personid 
     from person_employment pe 
     join pspay_payment_detail ppd on ppd.personid = pe.personid
    where pe.emplstatus in ('R','T')
      and ppd.paymentheaderid in 
        (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay join edi.edi_last_update elu 
                             on elu.feedid = 'CDS_JH_401K_Export' and elu.lastupdatets <= ppay.statusdate
                             where ppay.pspaypayrollstatusid = 4 ))))))



union

select distinct
 pi.personid
,'TERMED EE' ::varchar(40) as qsource 
,pe.emplstatus
,pe.effectivedate
---------------start -------------------------------------------------------------------------------------------------------------------------------------------
,'comb.d  ' ::char(8) as comb_h10 --col 1
,'140886 '::char(7) as Cont --col 2
,replace(pi.identity,'-','')::char(9) as SSN -- col 3

--,TRIM(UPPER('"'||pn.fname||'"'))::varchar(18) as FirstName -- col 4
--,TRIM(UPPER('"'||pn.lname||'"'))::varchar(20) as LastName -- col 5
--,TRIM(UPPER('"'||coalesce(LEFT(pn.mname,1),'')||'"'))::varchar(1) as Initial -- col 6
,TRIM(UPPER(pn.fname))::varchar(18) as FirstName -- col 4
,TRIM(UPPER(pn.lname))::varchar(20) as LastName -- col 5
,TRIM(UPPER(coalesce(LEFT(pn.mname,1),'')))::varchar(1) as Initial -- col 6
,null :: varchar(4) as NamePrefix --col 7
,pie.identity ::char(9) as EEID -- col 8
--,'"'||pa.streetaddress||'"' ::varchar(30) as Address1 -- col 9
--,'"'||pa.streetaddress2||'"' ::varchar(30) as Address2 -- col 10
--,'"'||pa.city||'"' ::varchar(25) as city -- col 11

,pa.streetaddress ::varchar(30) as Address1 -- col 9
,pa.streetaddress2 ::varchar(30) as Address2 -- col 10
,pa.city::varchar(25) as city -- col 11

,rtrim(ltrim(pa.stateprovincecode)) ::char(2) as state -- col 12
,pa.postalcode::varchar(10) as zip -- col 13
,null :: char(3) as country -- col 14
,rtrim(ltrim(pa.stateprovincecode)) ::char(2) as state -- col 15
,null :: char(99) as ERProvEmail --col 16

--need more info-----------------------------------------------------
--,replace(pu.employertaxid,'-','') as division -- col Q
,replace(pu.payunitdesc,'-','') as division -- col 17
----------------------------------------------------------------------
,to_char(pv.birthdate,'mmddyyyy')::char(8) as dob -- col 18
,case when pe.emplhiredate > current_date then '' else to_char(pe.emplhiredate,'mmddyyyy') end::char(8) as doh -- col 19 original date of hire
,case when pe.emplstatus in ('A','T','L','D','R') then pe.emplstatus 
      when pe.emplstatus = 'P' then 'A' 
 end ::char(1) as empstatus -- col 20
  ------
  
,case when pe.empllasthiredate <> pe.emplhiredate and pe.emplstatus = 'A' then to_char(pe.empllasthiredate,'MMDDYYYY') 
      when pe.empllasthiredate = pe.emplhiredate and pe.emplstatus = 'A' then to_char(pe.emplhiredate,'MMDDYYYY') 
      when pe.emplstatus in ('R','T')then to_char(pe.effectivedate,'MMDDYYYY') 
     -- when pe.emplstatus = 'R' then to_char(pe.effectivedate,'MMDDYYYY') 
      else '' 
end ::char(8) as EmplStatDate -- col 21
 -----

 -----
,null ::char(1) as EligInd -- col 22
,null ::char(8) as EligDate --col 23
,null ::char(1) as OptOutInd --col 24

,total_hours.hours as YTDhrs --col 25
,wage_amount.Amount as PlanYTDComp --col 26

,to_char(dedamt.check_date,'MMDDYYYY')::char(8) as YTDHrsWkCompDt --col 27

,case when pc.frequencycode = 'A' then to_char(pc.compamount,'FM0000000000D00')
      when pc.frequencycode = 'H' then to_char((pc.compamount * 2080 ) ,'FM0000000000D00')
end as BaseSalary -- col 28

---------		
,pfpe.financialelectionrate as BfTxDefPct --col 29
,pfpe.financialelectionamount as BfTxFltDoDef --col 30
,pfpe1.financialelectionrate as DesigRothPct --col 31
,pfpe1.financialelectionamount as DesigRothAmt --col 32
------------------
,'505' as Trans -- 33

--,psp.payenddate as Date_end --Pay Period End Date
,to_char(psp.periodenddate,'mmddyyyy')::char(8) as Date_end --col 34 Pay Period End Date
,coalesce (dedamt.vb1_amount + dedamt.vb2_amount + dedamt.v25_amount + dedamt.vdo_amount + dedamt.vdp_amount + dedamt.vcg_amount, 0) as EEDEF -- col 35
,coalesce (dedamt.vb5_amount, 0) as ERMAT -- col 36
,null as QMAC -- col 37
,null as SHMAC -- col 38
,null as ERMC3 -- col 39
,coalesce (dedamt.vb3_amount + dedamt.vb4_amount, 0) as EEROT  -- col 40
,null as QNEC  --41
,null as SHNEC --42
,null as ERPS --43
,null as EERC --44
,null as EEVND --45
,null as EEVD --46
,null as EEMAN --47
,null as ERMP --48
,null as ERCON --49
,null as S_HGR --50
,null as EEMT1 --51
,null as EEMT2 --52
,null as ERMT1 --53
,null as ERMT2 --54
,null as ERMT3 --55
,null as ERMT4 --56
,null as ERMT5 --57
,null as ERMT6 --58
,null as LoanID_1 --59
,null as LoanAmt_1 --60
,null as LoanID_2 --61
,null as LoanAmt_2 --62
,null as LoanID_3 --63
,null as LoanAmt_3 --64
,null as LoanID_4 --65
,null as LoanAmt_4 --66
,null as LoanID_5 --67
,null as LoanAmt_5 --68
,null as LoanID_6 --69
,null as LoanAmt_6  --70
,null as LoanID_7  --71
,null as LoanAmt_7  --72
,null as LoanID_8  --73
,null as LoanAmt_8  --74
,null as LoanID_9  --75
,null as LoanAmt_9  --76
,null as LoanID_10  --77
,null as LoanAmt_10  --78
,'1' as sort_seq
,ed.feedid
,current_timestamp as updatets


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
 --and pp.effectivedate - interval '1 day' <> pp.enddate 
 and pp.effectivedate < pp.enddate 

left JOIN pay_unit pu
ON pu.payunitid = pp.payunitid
AND CURRENT_TIMESTAMP BETWEEN pu.createts AND pu.endts

----- issue with 18326 not pulling because of between on createts and endts
left join ( select personid, compamount, increaseamount, compevent, frequencycode, earningscode, max(createts) as createts, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate, RANK() OVER (PARTITION BY personid ORDER BY max(effectivedate)desc) AS RANK
             from person_compensation where effectivedate < enddate and current_timestamp BETWEEN createts and endts  
            group by personid, compamount, increaseamount, compevent, frequencycode, earningscode) as pc on pc.personid = pi.personid and pc.rank = 1   
/*
left join ( select personid, compamount, increaseamount, compevent, frequencycode, earningscode, max(createts) as createts, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate, RANK() OVER (PARTITION BY personid ORDER BY max(effectivedate)desc) AS RANK
             from person_compensation --where effectivedate < enddate and current_timestamp BETWEEN createts and endts  
            group by personid, compamount, increaseamount, compevent, frequencycode, earningscode) as pc1 on pc1.personid = pi.personid and pc1.rank = 1             

left join ( select personid, positionid, scheduledhours, schedulefrequency, max(effectivedate) as effectivedate, RANK() OVER (PARTITION BY personid ORDER BY max(createts) DESC) AS RANK
              from pers_pos 
             group by personid, positionid, scheduledhours, schedulefrequency) ppos on ppos.personid = pe.personid and ppos.rank = 1  
  */           
left join (select personid, locationid, max(effectivedate) as effectivedate, RANK() OVER (PARTITION BY personid ORDER BY max(createts),max(effectivedate) DESC) AS RANK
             from person_locations where effectivedate < enddate and current_timestamp between createts and endts 
            group by personid, locationid) ploc on ploc.personid = pe.personid and ploc.rank = 1


/*
left join (select positionid, grade, positiontitle, flsacode, max(effectivedate) as effectivedate, RANK() OVER (PARTITION BY positionid ORDER BY max(effectivedate) DESC) AS RANK
             from position_desc  group by positionid, grade, positiontitle, flsacode) pd on pd.positionid = ppos.positionid
  
left join (select pph.personid,sum(pph.gross_pay) as gross_pay
             from pspay_payment_header pph
            where paymentheaderid in (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay join edi.edi_last_update elu 
                             on elu.feedid = 'CDS_JH_401K_Export' and elu.lastupdatets <= ppay.statusdate
                             where ppay.pspaypayrollstatusid = 4 ))) group by 1
                             ) wages on wages.personid = pi.personid

left join (select pph.personid,sum(pph.gross_pay) as ytd_gross_pay
             from pspay_payment_header pph
            where paymentheaderid in (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay 
                             where ppay.pspaypayrollstatusid = 4 )))
                             AND date_part('year', pph.check_date) = date_part('year',current_date)
                            group by 1) ytdwages on ytdwages.personid = pi.personid    
                                                         
                             

*/

 LEFT JOIN person_deduction_setup pds
  on pi.personid = pds.personid
 and pds.etvid = 'V65'
 and current_date between pds.effectivedate and pds.enddate
 and current_timestamp between pds.createts and pds.endts 

left join 
(select 
 x.personid
,x.check_date
,sum(x.vb1_amount) as vb1_amount
,sum(x.vb2_amount) as vb2_amount
,sum(x.v25_amount) as v25_amount
,sum(x.vdo_amount) as vdo_amount
,sum(x.vdp_amount) as vdp_amount
,sum(x.vcg_amount) as vcg_amount
,sum(x.vb3_amount) as vb3_amount
,sum(x.vb4_amount) as vb4_amount
,sum(x.vb5_amount) as vb5_amount
,x.payscheduleperiodid
from
 

(select distinct
 ppd.personid
,ppd.check_date
,case when ppd.etv_id = 'VB1' then etv_amount  else 0 end as vb1_amount
,case when ppd.etv_id = 'VB2' then etv_amount  else 0 end as vb2_amount
,case when ppd.etv_id = 'V25' then etv_amount  else 0 end as v25_amount
,case when ppd.etv_id = 'VDO' then etv_amount  else 0 end as vdo_amount
,case when ppd.etv_id = 'VDP' then etv_amount  else 0 end as vdp_amount
,case when ppd.etv_id = 'VCG' then etv_amount  else 0 end as vcg_amount
,case when ppd.etv_id = 'VB3' then etv_amount  else 0 end as vb3_amount
,case when ppd.etv_id = 'VB4' then etv_amount  else 0 end as vb4_amount
,case when ppd.etv_id = 'VB5' then etv_amount  else 0 end as vb5_amount
,ppd.paymentheaderid
,pph.payscheduleperiodid
from pspay_payment_detail ppd
join pspay_payment_header pph on ppd.paymentheaderid = pph.paymentheaderid
where pph.paymentheaderid in 
        (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay join edi.edi_last_update elu 
                             on elu.feedid =  'CDS_JH_401K_Export' and elu.lastupdatets <= ppay.statusdate
                             where ppay.pspaypayrollstatusid = 4 )))
  and ppd.etv_id  in  ('VB1','VB2','V25','VDO','VDP','VCG','VB3','VB4','VB5')) x
  group by 1,2,payscheduleperiodid having sum(x.vb1_amount + x.vb2_amount + v25_amount + vdo_amount + vdp_amount + vcg_amount + x.vb3_amount + x.vb4_amount + x.vb5_amount) <> 0) 
        dedamt on dedamt.personid = pi.personid 



------------------------------------------------------------------------------------------------------------------------------------------
-- New Hours Start 

LEFT JOIN (SELECT h.personid
		 ,h.check_date 
                 ,sum(h.etype_hours) as Hours
             FROM          
            
	(Select distinct
		 ppdh.personid
		,ppdh.check_date
		,ppdh.etype_hours
		,ppdh.paymentheaderid
		from pspay_payment_detail ppdh
		where ppdh.paymentheaderid in 
			(select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
				(select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
					(select pspaypayrollid from pspay_payroll ppay join edi.edi_last_update elu 
					     on elu.feedid =  'CDS_JH_401K_Export' and elu.lastupdatets <= ppay.statusdate
					     where ppay.pspaypayrollstatusid = 4 ))) and ppdh.etv_id  in  (select a.etv_id from pspay_etv_operators a  
							 where a.operand = 'WS23' and a.etvindicator = 'E' and a.opcode = 'A' and a.group_key <> '$$$$$' group by 1)) h group by 1,2) 
									total_hours on total_hours.personid = pi.personid and total_hours.check_date = dedamt.check_date



-- New Hours End 
------------------------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------------------------
--New Wages Start 

LEFT JOIN (SELECT w.personid
		 ,w.check_date 
                 ,sum(w.etv_amount) as  Amount
             FROM          
            
	(Select distinct
		 ppdw.personid
		,ppdw.check_date
		,ppdw.etv_amount 
		,ppdw.paymentheaderid
		from pspay_payment_detail ppdw
		where ppdw.paymentheaderid in 
			(select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
				(select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
					(select pspaypayrollid from pspay_payroll ppay join edi.edi_last_update elu 
					     on elu.feedid =  'CDS_JH_401K_Export' and elu.lastupdatets <= ppay.statusdate
					     where ppay.pspaypayrollstatusid = 4 ))) and ppdw.etv_id  in  (select a.etv_id from pspay_etv_operators a
									where a.operand = 'WS15' and a.etvindicator = 'E' and a.opcode = 'A' and a.group_key <> '$$$$$' group by 1)) w group by 1,2) 
									wage_amount on wage_amount.personid = pi.personid 
									and wage_amount.check_date = dedamt.check_date


------------------------------------------------------------------------------------------------------------------------------------------
left join person_financial_plan_election pfpe
  on pfpe.personid = pi.personid
 --and pfpe.benefitsubclass in  ('40','43','46','47','4C','457')
 and pfpe.benefitsubclass in  ('40')
 and current_date between pfpe.effectivedate and pfpe.enddate
 and current_timestamp between pfpe.createts and pfpe.endts
-------------------------------------------------------------------------------------------------------------------------
left join person_financial_plan_election pfpe1
  on pfpe1.personid = pi.personid
 --and pfpe1.benefitsubclass in   ('4R','4Z')
 and pfpe1.benefitsubclass in   ('4Z')
 and current_date between pfpe1.effectivedate and pfpe1.enddate
 and current_timestamp between pfpe1.createts and pfpe1.endts
-------------------------------------------------------------------------------------------------------------------------
join (select personid, check_date, etv_id from pspay_payment_detail) as ppd on ppd.personid = pi.personid 
		--and ppd.etv_id  in  ('VB1','VB2','V25','VDO','VDP','VCG','VB3','VB4','VB5')
                               
join pay_schedule_period psp   on psp.payscheduleperiodid = dedamt.payscheduleperiodid

LEFT JOIN edi.edi_last_update ed
ON ed.feedid = 'CDS_JH_401K_Export'
------------------------------------------------------------------------------------------------------------------------

where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  and pe.emplstatus in ('T','R')
  and ((pe.effectivedate >= current_date - interval '1 year' )
  and (date_part('year',pe.effectivedate) >= date_part('year',current_date)))
  
/*
terms should only be for the current calendar year. 
The first file for 2020 will only have terms with 401K deductions because all 2019 terms will fall off the 1st 2020 file unless they have a 401K deduction.
*/ 
  
  --and pe.personid = '19805'
and

   (pe.personid in 
  (select distinct pe.personid 
     from person_employment pe 
     join pspay_payment_detail ppd on ppd.personid = pe.personid
    where pe.emplstatus in ('R','T')
      and ppd.paymentheaderid in 
        (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay join edi.edi_last_update elu 
                             on elu.feedid = 'CDS_JH_401K_Export' and elu.lastupdatets <= ppay.statusdate
                             where ppay.pspaypayrollstatusid = 4 )))))

 order by personid
                                                          
                             
