select

pi.personid
,pip.identity as pspid
,'11340' as COCODE
,pu.payunitdesc ::char(5) as DataSource
,pi.identity||to_char(payroll.periodpaydate,'yyyymmdd')||payroll.record_stat||case when payroll.payrollfinal = 'Y' then '0' else '1' end ||'00'  as PayrollSystemID 
,to_char(payroll.periodpaydate::date,'mm/dd/yyyy')  as PayDate
,to_char(payroll.periodstartdate::date,'mm/dd/yyyy')  as PayPeriodStartDate
,to_char(payroll.periodenddate::date,'mm/dd/yyyy')  as PayPeriodEndDate
,pu.employertaxid  as FEIN
,left(pi.identity,3)||'-'||substring(pi.identity,4,2)||'-'||substring(pi.identity,6,4)  as SSN
--,to_char(pid.identity::int,'999999999') as EmployeeID
,pid.identity as EmployeeID
,' ' ::char(1) as AssignmentID 
,' ' ::char(1) as BillingCode
,' ' ::char(1) as CompensationType
,' ' ::char(1) as AdjustmentKey
,case when pc.frequencycode = 'H' and pc.compamount <> 0 then to_char(pc.compamount,'9999D9999')
      when pc.frequencycode <> 'H' and pc.compamount <> 0 then to_char(((pc.compamount/24)/perspos.scheduledhours),'9999D9999') 
      else '0.00' end ::char(10) as PayRate -- converted to hourly pay rate
,'HY' as PayType
,'SM' as PayCycleFrequency
,to_char(case when payroll.hours <> 0 then payroll.hours when payroll.hours = 0 and payroll.check_number = 'DIRDEP' then perspos.scheduledhours else 0 end,'9999999999999D99') ::char(17) as HoursWorked
,case when payroll.gross <> 0 then to_char(payroll.gross,'999999D99') else '0.00' end ::char(10) as GrossPay 
,' ' ::char(1) as W2Box1Deductions
,' ' ::char(1) as ACASecurityKey
,case when payroll.net <> 0 then to_char(payroll.net,'9999999999999D99') else '0.00' end ::char(17) as NetPay  
,ocdi.organizationdesc as WorkNumberDivision

-- Footer

,'' as Footer_Fill
,'Total Record, ' as totalRecord
,'Number of Payment Records =  ' as numPmtText

from person_identity pi 
 
left join person_identity pip
  on pip.personid = pi.personid
and pip.identitytype = 'PSPID'
and current_timestamp between pip.createts and pip.endts

left join person_identity pid
  on pid.personid = pi.personid
and pid.identitytype = 'EmpNo'
and current_timestamp between pid.createts and pid.endts

left join person_employment pe
  on pe.personid = pi.personid
and current_date between pe.effectivedate and pe.enddate
and current_timestamp between pe.createts and pe.endts
   
LEFT JOIN person_payroll pp 
  on pp.personid = pi.personid 
 and CURRENT_DATE BETWEEN pp.effectivedate AND pp.enddate 
 and CURRENT_TIMESTAMP BETWEEN pp.createts AND pp.endts

LEFT JOIN pay_unit pu 
   ON pu.payunitid = pp.payunitid
  AND current_timestamp between pu.createts and pu.endts

 LEFT JOIN 
(select personid, frequencycode, compamount, max(effectivedate) as effectivedate, max(enddate) as enddate,
 rank() over (partition by personid order by max(effectivedate) desc) as rank
 from person_compensation
 where effectivedate < enddate and current_timestamp between createts and endts group by 1,2,3)
 as pc on pc.personid = pi.personid and pc.rank = 1

--- NEW LOGIC ORG JOINS
left join (select personid, positionid, scheduledhours, schedulefrequency, max(effectivedate) as effectivedate, RANK() OVER (PARTITION BY personid ORDER BY max(effectivedate) DESC) AS RANK
             from pers_pos where effectivedate < enddate and current_timestamp between createts and endts
            group by personid, positionid, scheduledhours, schedulefrequency) perspos on perspos.personid = pe.personid and perspos.rank = 1

left join (select positionid, grade, positiontitle, flsacode, eeocode, max(effectivedate) as effectivedate, RANK() OVER (PARTITION BY positionid ORDER BY max(effectivedate) DESC) AS RANK
             from position_desc where effectivedate < enddate and current_timestamp between createts and endts 
            group by positionid, grade, positiontitle, flsacode,eeocode) pd on pd.positionid = perspos.positionid and pd.rank = 1    

left join pos_org_rel pord
  on pord.positionid = pd.positionid 
 and pord.posorgreltype = 'Member'
 and current_date between pord.effectivedate and pord.enddate 
 and current_timestamp between pord.createts and pord.endts
 
left JOIN org_rel orel 
  ON orel.organizationid = pord.organizationid
 and current_date between orel.effectivedate and orel.enddate 
 and current_timestamp between orel.createts and orel.endts
 
left JOIN organization_code ocdi
  ON ocdi.organizationid = orel.memberoforgid
 AND ocdi.organizationtype = 'Div'
 and current_date between ocdi.effectivedate and ocdi.enddate 
 and current_timestamp between ocdi.createts and ocdi.endts

--------------------------------------
------ HOURS WORKED WINTER -------
--------------------------------------
LEFT JOIN (SELECT x.personid
		,x.periodpaydate
		,x.check_date
		,x.periodstartdate
		,x.periodenddate
		,x.payrollfinal
		,x.gross_pay as gross
		,x.net_pay as net
		,x.record_stat
		,x.check_number
		,sum(x.E01 + x.E02 + x.E15 + x.E16 + x.E17 + x.E18 + x.E19 + x.E20 + x.EB5 + x.EAJ + x.EAR) as hours
	  from
	  (SELECT ppd.personid
		,psp.periodpaydate
		,ppd.check_date
		,psp.periodstartdate
		,psp.periodenddate
		,pph.gross_pay
		,pph.net_pay
		,pph.payrollfinal
		,pph.record_stat
		,pph.check_number
		,case when ppd.etv_id = 'E01' then etype_hours  else 0 end as E01  -- Regular
		,case when ppd.etv_id = 'E02' then etype_hours  else 0 end as E02  -- Overtime
		--,case when ppd.etv_id = 'E05' then etype_hours  else 0 end as E05  -- Shift Differential
		,case when ppd.etv_id = 'E15' then etype_hours  else 0 end as E15  -- Vacation
		,case when ppd.etv_id = 'E16' then etype_hours  else 0 end as E16  -- Sick
		,case when ppd.etv_id = 'E17' then etype_hours  else 0 end as E17  -- Holiday
		,case when ppd.etv_id = 'E18' then etype_hours  else 0 end as E18  -- Bereavement
		,case when ppd.etv_id = 'E19' then etype_hours  else 0 end as E19  -- Jury Duty
		,case when ppd.etv_id = 'E20' then etype_hours  else 0 end as E20  -- Personal
		,case when ppd.etv_id = 'EB5' then etype_hours  else 0 end as EB5  -- Unpaid Vacation/Sick
		,case when ppd.etv_id = 'EAJ' then etype_hours  else 0 end as EAJ  -- Administrative Leave
		,case when ppd.etv_id = 'EAR' then etype_hours  else 0 end as EAR  -- Holiday Worked
           FROM pspay_payment_detail ppd
	   join pspay_payment_header pph on ppd.paymentheaderid = pph.paymentheaderid
	   join pay_schedule_period psp on psp.payscheduleperiodid = pph.payscheduleperiodid
where ppd.paymentheaderid in 
        (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay 
							join edi.edi_last_update elu on elu.feedid = 'HMN_Equifax_PayrollDetails_Export' 
								and elu.lastupdatets <= ppay.statusdate	
                             where ppay.pspaypayrollstatusid = 4 )))) x
group by 1,2,3,4,5,6,7,8,9,10) payroll ON payroll.personid = pi.personid  


where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
and payroll.periodpaydate is not null
and payroll.gross <> 0
order by 11
