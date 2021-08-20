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
select 
 perschkdt.personid
,pe.emplstatus
,pn.name
,'ACTIVE EE' ::varchar(50) as qsource
,'3' ::char(1) as sort_seq
,'220EMPLPAYDTL' ::char(15) as rectype
,'11340' ::char(16) as cocode
,replace(pi.identity,'-','') ::char(11) as ssn
,replace(pi.identity,'-','') ::char(64) as empl_id
,null ::char(1) as verdiv

,case when pp.schedulefrequency = 'S' then '05' else '04' end ::char(2) as payfreq

,rpad(''||pu.employertaxid,15,' ') ::char(15) as fein
,rpad(''||puc.identification,15,' ') ::char(15) as suiacctnum    
 
,la.stateprovincecode ::char(2) as wrkstate

,case when lc.locationcode = 'HO' and pd.positiontitle <> 'Agent' then 'HMNHO' 
      when lc.locationcode <> 'HO' and pd.positiontitle = 'Agent' then 'HMNFA' 
      else 'HMNFN' end ::char(20) as wrkloccd

,to_char(perschkdt.periodenddate, 'YYYYMMDD') ::char(8) as enddate
,to_char(perschkdt.periodstartdate, 'YYYYMMDD') ::char(8) as begdate
,to_char(perschkdt.check_date, 'YYYYMMDD') ::char(8) as paydate  

-------------------------------------------------
----- paytype_A = A                         -----
----- ALL WAGES ALL HOURS                   -----
----- Gross Pay all wages for pay period    -----
----- Net Pay for pay period                -----
----- Hours - all hours paid for pay period -----
-------------------------------------------------
,'A' ::char(1) as paytype_a  

,case when pph.gross_pay    < 0 then 'Y' 
      when pph.net_pay      < 0 then 'Y' 
      when paydtl.hoursA    < 0 then 'Y' 
      when paydtl.grosspayR < 0 then 'Y'
      when paydtl.hoursR    < 0 then 'Y'
      when paydtl.grosspayO < 0 then 'Y'
      when paydtl.hoursO    < 0 then 'Y'  
      when paydtl.grosspayV < 0 then 'Y'
      when paydtl.hoursV    < 0 then 'Y'  
      when paydtl.grosspayS < 0 then 'Y'
      when paydtl.hoursS    < 0 then 'Y'              
      when paydtl.grosspayH < 0 then 'Y'
      when paydtl.hoursH    < 0 then 'Y'      
      when paydtl.grosspayB < 0 then 'Y'
      when paydtl.hoursB    < 0 then 'Y'   
      when paydtl.grosspayE < 0 then 'Y'
      when paydtl.hoursE    < 0 then 'Y'
      when paydtl.grosspayC < 0 then 'Y'
      when paydtl.hoursC    < 0 then 'Y'  
      when paydtl.grosspayM < 0 then 'Y'
      when paydtl.hoursM    < 0 then 'Y'                   
      else ' ' end ::char(1) as error_flag
      
,case --when sign(pph.gross_pay) < 0 then to_char(pph.gross_pay,'S0000009D99')
      when sign(pph.gross_pay) < 0 then '00000000.00'
      when pph.gross_pay       > 0 then lpad(''||pph.gross_pay, 11, '0') 
      else '00000000.00' end ::char(11) as grosspay_a 
,case --when sign(pph.net_pay)   < 0 then to_char(pph.net_pay,'S0000009D99')
      when sign(pph.net_pay)   < 0 then '00000000.00'
      when pph.net_pay   <> 0 then lpad(''||pph.net_pay, 11, '0')  
      else '00000000.00' end ::char(11) as netpay_a 
,case --when sign(paydtl.hoursA) < 0 then to_char(paydtl.hoursA,'S0009D99')
      when sign(paydtl.hoursA) < 0 then '00000.00'
      when paydtl.hoursA <> 0 then lpad(''||paydtl.hoursA, 8, '0')
      else '00000.00' end ::char(8) as hours_a 

,'I19M' ::char(4) as inhousenum 

----- For each group of 3 fields, populate only if there are wages/hours for the desired wage types

-------------------------------------------------
----- paytype_R = R                         -----
----- Reg, Student Loan, Jury, Personal     -----
----- and / or Night Diff pay on this check -----
----- Gross REG pay and all reg pay types   -----
----- Hours - REG hours for pay period      -----
-------------------------------------------------   
,case when paydtl.grosspayR <> 0 then 'R' else ' ' end ::char(1) as paytype_r  
,case --when sign(paydtl.grosspayR) < 0 then to_char(paydtl.grosspayR,'S0000009D99')
      when sign(paydtl.grosspayR) < 0 then '00000000.00' 
      when paydtl.grosspayR       > 0 then lpad(''||paydtl.grosspayR, 11, '0') 
      else '           ' end ::char(11) as grosspay_r
,case --when sign(paydtl.hoursR) < 0 then to_char(paydtl.hoursR,'S0009D99')
      when sign(paydtl.hoursR) < 0 then '00000.00'
      when paydtl.hoursR       > 0 then lpad(''||paydtl.hoursR, 8, '0') 
      else '        ' end ::char(8) as hours_r

-------------------------------------------------
----- paytype_O = O                         -----
----- Overtime pay on this check            -----
----- Gross OT pay                          -----
----- Hours - OT hours for pay period       -----
-------------------------------------------------    
----- ETV_ID in ('E02','E03')               -----
-------------------------------------------------    
,case when paydtl.grosspayO <> 0 then 'O' else ' ' end ::char(1) as paytype_o  
,case --when sign(paydtl.grosspayO) < 0 then to_char(paydtl.grosspayO,'S0000009D99')
      when sign(paydtl.grosspayO) < 0 then '00000000.00' 
      when paydtl.grosspayO       > 0 then lpad(''||paydtl.grosspayO, 11, '0') 
      else '           ' end ::char(11) as grosspay_o
,case --when sign(paydtl.hoursO) < 0 then to_char(paydtl.hoursO,'S0009D99')
      when sign(paydtl.hoursO) < 0 then '00000.00'
      when paydtl.hoursO       > 0 then lpad(''||paydtl.hoursO, 8, '0') 
      else '        ' end ::char(8) as hours_o
-------------------------------------------------
----- paytype_V = V                         -----
----- Vacation pay on this check            -----
----- Gross VAC pay                         -----
----- Hours - VAC hours for pay period      -----
------------------------------------------------- 
----- ETV_ID in ('E15','ECH','ECI','E27')   -----
------------------------------------------------- 
,case when paydtl.grosspayV <> 0 then 'V' else ' ' end ::char(1) as paytype_v 
,case --when sign(paydtl.grosspayV) < 0 then to_char(paydtl.grosspayV,'S0000009D99')
      when sign(paydtl.grosspayV) < 0 then '00000000.00' 
      when paydtl.grosspayV       > 0 then lpad(''||paydtl.grosspayV, 11, '0') 
      else '           ' end ::char(11) as grosspay_v
,case --when sign(paydtl.hoursV) < 0 then to_char(paydtl.hoursV,'S0009D99')
      when sign(paydtl.hoursV) < 0 then '00000.00'
      when paydtl.hoursV       > 0 then lpad(''||paydtl.hoursV, 8, '0')
      else '        ' end ::char(8) as hours_v 
-------------------------------------------------
----- paytype_S = S                         -----
----- Sick pay on this check                -----
----- Gross SICK pay                        -----
----- Hours - SICK hours for pay period     -----
------------------------------------------------- 
----- ETV_ID in ('E16')                     -----
-------------------------------------------------   
,case when paydtl.grosspayS <> 0 then 'S' else ' ' end ::char(1) as paytype_s 
,case --when sign(paydtl.grosspayS) < 0 then to_char(paydtl.grosspayS,'S0000009D99')
      when sign(paydtl.grosspayS) < 0 then '00000000.00' 
      when paydtl.grosspayS       > 0 then lpad(''||paydtl.grosspayS, 11, '0') 
      else '           ' end ::char(11) as grosspay_s
,case --when sign(paydtl.hoursS) < 0 then to_char(paydtl.hoursS,'S0009D99')
      when sign(paydtl.hoursS) < 0 then '00000.00'
      when paydtl.hoursS       > 0 then lpad(''||paydtl.hoursS, 8, '0') 
      else '        ' end ::char(8) as hours_s 
-------------------------------------------------
----- paytype_H = H                         -----
----- Holiday pay on this check             -----
----- Gross Holiday pay                     -----
----- Hours - Holiday hours for pay period  -----
------------------------------------------------- 
----- ETV_ID in ('E17')                     -----
------------------------------------------------- 
--,paydtl.etv_id
,case when paydtl.grosspayH <> 0 then 'H' else ' ' end ::char(1) as paytype_h
,case --when sign(paydtl.grosspayH) < 0 then to_char(paydtl.grosspayH,'S0000009D99')
      when sign(paydtl.grosspayH) < 0 then '00000000.00' 
      when paydtl.grosspayH       > 0 then lpad(''||paydtl.grosspayH, 11, '0') 
      else '           ' end ::char(11) as grosspay_h
,case --when sign(paydtl.hoursH) < 0 then to_char(paydtl.hoursH,'S0009D99')
      when sign(paydtl.hoursH) < 0 then '00000.00'
      when paydtl.hoursH       > 0 then lpad(''||paydtl.hoursH, 8, '0') 
      else '        ' end ::char(8) as hours_h 
-------------------------------------------------
----- paytype_B = B                         -----
----- Bonus pay on this check               -----
----- Gross Bonus pay                       -----
----- Hours - Bonus hours for pay period    -----
-------------------------------------------------  
----- ETV_ID in ('E61','E63','E64','EA1','EA2','EA9','EAK','EAO','EAS','EAT','EAU','EB3','EBD','EBE','EBG','EBH','EBI','EC0','EC1','EC3','EC6','EC7','ECD','ECE','E26')                    -----
-------------------------------------------------  
,case when paydtl.grosspayB <> 0 then 'B' else ' ' end ::char(1) as paytype_b
,case --when sign(paydtl.grosspayB) < 0 then to_char(paydtl.grosspayB,'S0000009D99')
      when sign(paydtl.grosspayB) < 0 then '00000000.00' 
      when paydtl.grosspayB       > 0 then lpad(''||paydtl.grosspayB, 11, '0') 
      else '           ' end ::char(11) as grosspay_b
-------------------------------------------------
----- paytype_E = E                         -----
----- Severance pay on this check           -----
----- Gross Severance pay                   -----
----- Hours - Severance hours for pay prd   -----
-------------------------------------------------  
----- ETV_ID in ('E30')                     -----
-------------------------------------------------  
,case when paydtl.grosspayE <> 0 then 'E' else ' ' end ::char(1) as paytype_e
,case --when sign(paydtl.grosspayE) < 0 then to_char(paydtl.grosspayE,'S0000009D99')
      when sign(paydtl.grosspayE) < 0 then '00000000.00' 
      when paydtl.grosspayE       > 0 then lpad(''||paydtl.grosspayE, 11, '0') 
      else '           ' end ::char(11) as grosspay_e
-------------------------------------------------
----- paytype_C = C                         -----
----- Comission pay on this check           -----
----- Gross Comission pay                   -----
----- Hours - n/a                           -----
-------------------------------------------------  
----- ETV_ID in ('E12','E62','EB9','EBA','EBB','E25')                 -----
-------------------------------------------------   
,case when paydtl.grosspayC <> 0 then 'C' else ' ' end ::char(1) as paytype_c
,case --when sign(paydtl.grosspayC) < 0 then to_char(paydtl.grosspayC,'S0000009D99')
      when sign(paydtl.grosspayC) < 0 then '00000000.00' 
      when paydtl.grosspayC       > 0 then lpad(''||paydtl.grosspayC, 11, '0') 
      else '           ' end ::char(11) as grosspay_c
-------------------------------------------------
----- paytype_M = M                         -----
----- Misc pay on this check that don't     -----
----- fall under the above categories       -----
----- Gross Misc pay                        -----
----- Hours - Misc hours for pay period     -----
-------------------------------------------------  
,case when paydtl.grosspayM <> 0 then 'M' else ' ' end ::char(1) as paytype_m
,case --when sign(paydtl.grosspayM) < 0 then to_char(paydtl.grosspayM,'S0000009D99')
      when sign(paydtl.grosspayM) < 0 then '00000000.00' 
      when paydtl.grosspayM       > 0 then lpad(''||paydtl.grosspayM, 11, '0') 
      else '           ' end ::char(11) as grosspay_m
,case --when sign(paydtl.hoursM) < 0 then to_char(paydtl.hoursM,'S0009D99')
      when sign(paydtl.hoursM) < 0 then '00000.00'
      when paydtl.hoursM       > 0 then lpad(''||paydtl.hoursM, 8, '0') 
      else '        ' end ::char(8) as hours_m

 
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

left join (select personid, positionid, scheduledhours, schedulefrequency, max(effectivedate) as effectivedate, RANK() OVER (PARTITION BY personid ORDER BY max(effectivedate) DESC) AS RANK
             from pers_pos where effectivedate < enddate and current_timestamp between createts and endts
            group by personid, positionid, scheduledhours, schedulefrequency) pp on pp.personid = pe.personid and pp.rank = 1

left join (select positionid, grade, positiontitle, flsacode, max(effectivedate) as effectivedate, RANK() OVER (PARTITION BY positionid ORDER BY max(effectivedate) DESC) AS RANK
             from position_desc where effectivedate < enddate and current_timestamp between createts and endts 
            group by positionid, grade, positiontitle, flsacode) pd on pd.positionid = pp.positionid and pd.rank = 1   

left join person_payroll ppay
  on ppay.personid = pi.personid
 and current_date between ppay.effectivedate AND ppay.enddate
 and current_timestamp between ppay.createts AND ppay.endts 
 
join pay_unit pu
  on pu.payunitid = ppay.payunitid
 and current_timestamp between pu.createts and pu.endts  

left join (select personid, locationid, max(effectivedate) as effectivedate, RANK() OVER (PARTITION BY personid ORDER BY max(effectivedate) DESC) AS RANK
             from person_locations where effectivedate < enddate and current_timestamp between createts and endts
            group by personid, locationid) pl on pl.personid = pp.personid and pl.rank = 1 

left join (select locationid, stateprovincecode, max(effectivedate) as effectivedate, RANK() OVER (PARTITION BY locationid ORDER BY max(effectivedate) DESC) AS RANK
             from location_address where effectivedate < enddate and current_timestamp between createts and endts
            group by locationid, stateprovincecode) la on la.locationid = pl.locationid and la.rank = 1             

join pay_unit_configuration_type puct
  on puct.payunitconfigurationtypename = 'SUI'

join pay_unit_configuration puc
  on puc.payunitconfigurationtypeid = puct.payunitconfigurationtypeid
 and puc.payunitid = pu.payunitid
 and current_date between puc.effectivedate and puc.enddate
 and current_timestamp between puc.createts and puc.endts
 and puc.stateprovincecode = la.stateprovincecode                         
            
left join location_codes lc
  on lc.locationid = la.locationid
 and current_date between lc.effectivedate and lc.enddate
 and current_timestamp between lc.createts and lc.endts

join (select pph.personid, sum(pph.gross_pay) as gross_pay, sum(pph.net_pay) as net_pay
        from pspay_payment_header pph
        join perschkdt on perschkdt.personid = pph.personid and pph.check_date = perschkdt.check_date
       group by pph.personid) pph on pph.personid = perschkdt.personid

join (select ppdx.personid, ppdx.group_key
     -- ALL hours for pay period
                , sum(case when ppdx.etv_id IN ('E01','E05','E18','E19','E20','EAJ','ECA','E02','E29','E15','E16','E17','EAR','E30','E12','E62','EB9','EBA','EBB','E71','EA6','EA8','EAI','EB5','EC5'
                                               ,'E61','E63','E64','EA1','EA2','EA9','EAK','EAO','EAS','EAT','EAU','EB3','EBD','EBE','EBG','EBH','EBI','EC0','EC1','EC3','EC6','EC7','ECD','ECE','ECH','ECI','E27','E25','E26') then ppdx.etype_hours else 0 end) as hoursA

     --REGULAR hours & pay for pay period - R ----- ETV_ID in ('E01')                      -----
                , sum(case when ppdx.etv_id IN ('E01','E05','E18','E19','E20','EAJ','ECA','E08') then ppdx.etype_hours else 0 end) as hoursR
				, sum(case when ppdx.etv_id IN ('E01','E05','E18','E19','E20','EAJ','ECA','E08') then ppdx.etv_amount else 0 end) as grosspayR

	--OVERTIME hours & pay for pay period - O ----- ETV_ID in ('E02','E03')               -----
                , sum(case when ppdx.etv_id IN ('E02','E29') then ppdx.etype_hours else 0 end) as hoursO
				, sum(case when ppdx.etv_id IN ('E02','E29') then ppdx.etv_amount else 0 end) as grosspayO

	--VACATION hours & pay for pay period - V ----- ETV_ID in ('E15')                     -----
                , sum(case when ppdx.etv_id IN ('E15','ECH','ECI','E27','ECJ') then ppdx.etype_hours else 0 end) as hoursV
				, sum(case when ppdx.etv_id IN ('E15','ECH','ECI','E27','ECJ') then ppdx.etv_amount else 0 end) as grosspayV

	--SICK hours & pay for pay period - S ----- ETV_ID in ('E16')                     -----
                , sum(case when ppdx.etv_id IN ('E16') then ppdx.etype_hours else 0 end) as hoursS
				, sum(case when ppdx.etv_id IN ('E16') then ppdx.etv_amount else 0 end) as grosspayS

	--HOLIDAY hours & pay for pay period - H ----- ETV_ID in ('E17')                     -----		
                , sum(case when ppdx.etv_id IN ('E17','EAR') then ppdx.etype_hours else 0 end) as hoursH
				, sum(case when ppdx.etv_id IN ('E17','EAR') then ppdx.etv_amount else 0 end) as grosspayH

	--BONUS hours & pay for pay period - B	----- ETV_ID in ('E61')                     -----	
                , sum(case when ppdx.etv_id IN ('E61','E63','E64','EA1','EA2','EA9','EAK','EAO','EAS','EAT','EAU','EB3','EBD','EBE','EBG','EBH','EBI','EC0','EC1','EC3','EC6','EC7','ECD','ECE','E26','E23','E24')  then ppdx.etype_hours else 0 end) as hoursB
				, sum(case when ppdx.etv_id IN ('E61','E63','E64','EA1','EA2','EA9','EAK','EAO','EAS','EAT','EAU','EB3','EBD','EBE','EBG','EBH','EBI','EC0','EC1','EC3','EC6','EC7','ECD','ECE','E26','E23','E24')  then ppdx.etv_amount else 0 end) as grosspayB

	--SEVERANCE hours & pay for pay period - E ----- ETV_ID in ('E30')                     -----		
                , sum(case when ppdx.etv_id IN ('E30') then ppdx.etype_hours else 0 end) as hoursE
				, sum(case when ppdx.etv_id IN ('E30') then ppdx.etv_amount else 0 end) as grosspayE

	--COMMISSION hours & pay for pay period - C ----- ETV_ID in ('E62')                     -----
                , sum(case when ppdx.etv_id in ('E12','E62','EB9','EBA','EBB','E25') then ppdx.etype_hours else 0 end) as hoursC
				, sum(case when ppdx.etv_id in ('E12','E62','EB9','EBA','EBB','E25') then ppdx.etv_amount else 0 end) as grosspayC

	--MISC hours & pay for pay period - M
		, sum(case when ppdx.etv_id IN ('E71','EA6','EA8','EAI','EB5','EC5','EBC','EB7') then ppdx.etype_hours else 0 end) as hoursM
	 	, sum(case when ppdx.etv_id IN ('E71','EA6','EA8','EAI','EB5','EC5','EBC','EB7') then ppdx.etv_amount else 0 end) as grosspayM
		from perschkdt 
		join pspay_payment_detail ppdx on ppdx.check_date = perschkdt.check_date and perschkdt.personid = ppdx.personid
	       group by ppdx.personid, ppdx.group_key) paydtl ON paydtl.personid = pi.personid
	       
       --limit 10