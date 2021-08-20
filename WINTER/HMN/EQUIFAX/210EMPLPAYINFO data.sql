WITH perschkdt AS
(select eemax.personid,  
  eemax.check_date AS check_date, psp.periodstartdate, psp.periodenddate, pu.payunitid, pu.payunitxid, pu.frequencycode, pu.employertaxid
        FROM (select dpmax.personid as personid, MAX(dpmax.check_date)  AS check_date
        	from cognos_payment_earnings_by_check_date dpmax 
       		where dpmax.check_date in ( ?::DATE , 
     		( SELECT periodpaydate FROM pay_schedule_period
        		 WHERE periodpaydate < ?::DATE        		 
        		   AND payrolltypeid = 1
     		ORDER BY periodpaydate desc limit 1)) GROUP BY dpmax.personid ) AS eemax
        join person_payroll pp on eemax.personid = pp.personid and current_date between pp.effectivedate and pp.enddate and current_timestamp between pp.createts and pp.endts
        LEFT JOIN pay_unit pu ON pu.payunitid = pp.payunitid 
 join pay_schedule_period psp on psp.payunitid = pu.payunitid and psp.periodpaydate = eemax.check_date AND payrolltypeid = 1
)  
select distinct
 perschkdt.personid
,pn.name
,pe.emplstatus 
,'2' ::char(1) as sort_seq
,'ACTIVE EE' ::varchar(50) as qsource
,'210EMPLPAYINFO' ::char(15) as rectype
,'11340' ::char(16) as cocode
,replace(pi.identity,'-','') ::char(11) as ssn
,replace(pi.identity,'-','') ::char(64) as empl_id

,rpad(''||pu.employertaxid,15,' ') ::char(15) as fein

,null ::char(1) as verdiv
,'Y' ::char(1) as verpay  -- 8/7 chg to Y for all

,to_char(perschkdt.periodenddate::date,'yyyymmdd')::char(8) as pasofdate
,lpad(''||round(coalesce(ppos.scheduledhours,tppos.scheduledhours),0),3, '0') ::char(3) as avghours

,lpad(''||round(coalesce(pc.compamount,tpc.compamount), 4), 13, '0')::char(13) as payrate
,case when coalesce(pc.frequencycode,tpc.frequencycode) = 'A' then '01' else '09' end ::char(2) payratecd
,to_char(perschkdt.periodenddate,'yyyymmdd')::char(8) as ytdate_1

,case when ytdpaydtl.grossbaseyear    < 0 then 'Y' 
      when ytdpaydtl.grossoveryear    < 0 then 'Y' 
      when ytdpaydtl.grossbonusyear   < 0 then 'Y' 
      when ytdpaydtl.grosscommissyear < 0 then 'Y'
      when ytdpaydtl.grossotheryear   < 0 then 'Y'            
      else ' ' end ::char(1) as error_flag

----- YTD Gross Wages  - REG, VAC, Sick, Personal, PTO, Bereavement, Holiday, Jury Duty, Student Loan, Severance, Shift Diff, Hol Work     
,case --when sign(ytdpaydtl.grossbaseyear) < 0 then to_char(ytdpaydtl.grossbaseyear,'S0000009D99')
      when sign(ytdpaydtl.grossbaseyear) < 0 then '00000000.00' 
      when ytdpaydtl.grossbaseyear       > 0 then lpad(''||ytdpaydtl.grossbaseyear, 11, '0') 
      else '00000000.00' end ::char(11) as base_1 
,case --when sign(ytdpaydtl.grossoveryear) < 0 then to_char(ytdpaydtl.grossoveryear,'S0000009D99')
      when sign(ytdpaydtl.grossoveryear) < 0 then '00000000.00' 
      when ytdpaydtl.grossoveryear       > 0 then lpad(''||ytdpaydtl.grossoveryear, 11, '0') 
      else '00000000.00' end ::char(11) as ot_1
,case --when sign(ytdpaydtl.grossbonusyear) < 0 then to_char(ytdpaydtl.grossbonusyear,'S0000009D99')
      when sign(ytdpaydtl.grossbonusyear) < 0 then '00000000.00' 
      when ytdpaydtl.grossbonusyear       > 0 then lpad(''||ytdpaydtl.grossbonusyear, 11, '0') 
      else '00000000.00' end ::char(11) as bon_1
,case --when sign(ytdpaydtl.grosscommissyear) < 0 then to_char(ytdpaydtl.grosscommissyear,'S0000009D99')
      when sign(ytdpaydtl.grosscommissyear) < 0 then '00000000.00' 
      when ytdpaydtl.grosscommissyear       > 0 then lpad(''||ytdpaydtl.grosscommissyear, 11, '0') 
      else '00000000.00' end ::char(11) as com_1
,case --when sign(ytdpaydtl.grossotheryear) < 0 then to_char(ytdpaydtl.grossotheryear,'S0000009D99')
      when sign(ytdpaydtl.grossotheryear) < 0 then '00000000.00' 
      when ytdpaydtl.grossotheryear       > 0 then lpad(''||ytdpaydtl.grossotheryear, 11, '0' ) 
      else '00000000.00' end ::char(11) as other_1
    
,case when sign((ytdpaydtl.grossbaseyear+ytdpaydtl.grossoveryear+ytdpaydtl.grossbonusyear+ytdpaydtl.grosscommissyear+ytdpaydtl.grossotheryear)) < 0 then '0000000000.00'
      when (ytdpaydtl.grossbaseyear+ytdpaydtl.grossoveryear+ytdpaydtl.grossbonusyear+ytdpaydtl.grosscommissyear+ytdpaydtl.grossotheryear) = 0 then '0000000000.00'
      else lpad(''||(ytdpaydtl.grossbaseyear+ytdpaydtl.grossoveryear+ytdpaydtl.grossbonusyear+ytdpaydtl.grosscommissyear+ytdpaydtl.grossotheryear), 13, '0') end ::char(13) as total_1 ---- summed in kettle script


      
,'I19M' ::char(4) as inhousenum


from perschkdt 

join person_identity pi
  on perschkdt.personid = pi.personid
 and pi.identitytype = 'SSN'
 and current_timestamp between pi.createts and pi.endts
 
join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts

join person_names pn
  on pn.personid = pi.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts  

left join person_payroll ppay
  on ppay.personid = pi.personid
 and current_date between ppay.effectivedate AND ppay.enddate
 and current_timestamp between ppay.createts AND ppay.endts 
 
left join (select personid, positionid, scheduledhours, schedulefrequency, max(effectivedate) as effectivedate, RANK() OVER (PARTITION BY personid ORDER BY max(effectivedate) DESC) AS RANK
             from pers_pos where (current_date between effectivedate and enddate or (effectivedate > current_date and enddate > effectivedate)) and current_timestamp between createts and endts
            group by personid, positionid, scheduledhours, schedulefrequency) ppos on ppos.personid = pe.personid and ppos.rank = 1 
--- termed ee 
left join (select personid, positionid, scheduledhours, schedulefrequency, max(effectivedate) as effectivedate, RANK() OVER (PARTITION BY personid ORDER BY max(effectivedate) DESC) AS RANK
             from pers_pos where effectivedate < enddate and current_timestamp between createts and endts
            group by personid, positionid, scheduledhours, schedulefrequency) tppos on tppos.personid = pe.personid and tppos.rank = 1      

left join (select personid, compamount, increaseamount, compevent, frequencycode, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate, RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_compensation where (current_date between effectivedate and enddate or (effectivedate > current_date and enddate > effectivedate)) and current_timestamp between createts and endts
            group by personid, compamount, increaseamount, compevent, frequencycode ) as pc on pc.personid = pe.personid and pc.rank = 1  

--- termed ee
left join (select personid, compamount, increaseamount, compevent, frequencycode, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate, RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_compensation where effectivedate < enddate and current_timestamp between createts and endts
            group by personid, compamount, increaseamount, compevent, frequencycode ) as tpc on tpc.personid = pe.personid and tpc.rank = 1              
         
join pay_schedule_period psp 
  on psp.payrolltypeid in (1,2)
 and psp.processfinaldate is not null
 and psp.periodpaydate = ?::date
  
join pay_unit pu
  on pu.payunitid = ppay.payunitid
 and current_timestamp between pu.createts and pu.endts 
 
left join (select ppdx.personid
           -- hours year
	           , sum(case when ppdx.etv_id IN ('E01','E05','E18','E19','E20','EAJ','ECA','E02','E29','E15','E16','E17','EAR','E30','E12','E62','EB9','EBA','EBB','E71','EA6','EA8','EAI','EB5','EC5'
                                           ,'E61','E63','E64','EA1','EA2','EA9','EAK','EAO','EAS','EAT','EAU','EB3','EBD','EBE','EBG','EBH','EBI','EC0','EC1','EC3','EC6','EC7','ECD','ECE','ECH','ECI','E27','E25','E26')  then ppdx.etype_hours else 0 end) as hoursYear
           -- gross base year
                , sum(case when ppdx.etv_id IN ('E01','E05','E18','E19','E20','EAJ','ECA','E15','E16','E17','EAR','E30','EB9','EAR','ECH','ECI','E27','ECJ','E26','E08') then ppdx.etv_amount else 0 end) as grossbaseyear
           -- gross overtime
                , sum(case when ppdx.etv_id IN ('E02','E29') then ppdx.etv_amount else 0 end) as grossoveryear
           -- gross bonus year
                , sum(case when ppdx.etv_id IN ('E61','E63','E64','EA1','EA2','EA9','EAK','EAO','EAS','EAT','EAU','EB3','EBD','EBE','EBG','EBH','EBI','EC0','EC1','EC3','EC6','EC7','ECD','ECE','E26','E23', 'E24')  then ppdx.etv_amount else 0 end) as grossbonusyear
           -- gross commission year
                , sum(case when ppdx.etv_id IN ('E12','E62','EB9','EBA','EBB','E25') then ppdx.etv_amount else 0 end) as grosscommissyear
           -- gross other pay year
                , sum(case when ppdx.etv_id IN ('E71','EA6','EA8','EAI','EB5','EC5','EBC','EB7') then ppdx.etv_amount else 0 end) as grossotheryear                                          
            from perschkdt 
            join pspay_payment_detail ppdx on perschkdt.personid = ppdx.personid
            where ppdx.check_date between (extract(year from current_date) ||'-01-01')::date and perschkdt.check_date --and perschkdt.personid = '63041'
		  	  and ppdx.check_number <> 'INIT REC'
		  	  and ppdx.check_number <> 'GrsUpNp'
            group by ppdx.personid) ytdpaydtl on ytdpaydtl.personid = perschkdt.personid
            
 
--group by 1,2,3,4,5,6,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23

--limit 10
