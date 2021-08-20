select distinct

pi.personid
,pu.payunitdesc
,to_char(elu.lastupdatets,'MM/DD/YYYY')::char(10) as lookbackDate
,'CONTRIBUTION'  ::varchar(50) as qsource
,'Grand Totals' ::varchar(25) as grandTotals
,pn.fname ::char(15) as fname
,pn.lname ::char(20) as lname 
,pi.identity ::char(9) as ssn
,pv.gendercode::char(1) as gender
,pms.maritalstatus::char(1) as marital_status
,pa.streetaddress ::char(33) as addr1
,pa.streetaddress2 ::char(33) as addr2
,pa.city ::char(25) as city
,pa.stateprovincecode ::char(2) as state
,pa.postalcode ::char(5) as zip
,to_char(pv.birthdate,'MM/DD/YYYY') ::char(10) as dob
,to_char(least(pe.effectivedate,pe.emplservicedate,pe.emplhiredate),'MM/DD/YYYY') ::char(10) as doh
,case when pe.emplstatus = 'T' then to_char(pe.effectivedate,'MM/DD/YYYY') else '' end ::char(10) as dot
,to_char(dedamt.periodpaydate,'MM/DD/YYYY')::char(10) as payroll_date

-- current pay period values
,cast(coalesce(grosscur.taxable_wage,0.00) as dec(10,2)) as planCompensation
,cast(coalesce(grosscur.hours,0) as dec(10,2)) as HoursWorked			
,cast(dedamt.e12_amount as dec(10,2)) as ExcludedEarnings
,cast(coalesce(dedamt.vb1_amount,0.00) as dec(10,2)) as empDeferral
,cast(coalesce(dedamt.vb3_amount,0.00) as dec(10,2)) as empRoth
,cast(coalesce(dedamt.vb5_amount,0.00) as dec(10,2)) as erMatch
,'' as erBaseContrib  ---- erBaseContrib SHOULD NOT BE POPULATED IN THIS FEED ONLY IN QUARTERLY FEED

--YTD Values
,cast(coalesce(grossytd.taxable_wage,0.00) as dec(10,2)) as planCompensationYTD
,cast(coalesce(grossytd.hours,0) as dec(10,2)) as HoursWorkedYTD
,cast(coalesce(dedamtytd.vb1_amount,0.00) as dec(10,2)) as empDeferralYTD
,cast(coalesce(dedamtytd.vb3_amount,0.00) as dec(10,2)) as empRothYTD
,cast(coalesce(dedamtytd.vb5_amount,0.00) as dec(10,2)) as erMatchYTD
,'' as erBaseContribYTD  ---- erBaseContribYTD SHOULD NOT BE POPULATED IN THIS FEED ONLY IN QUARTERLY FEED

,lookup.value2 as erNumber 
,lookup.value3 as planType 

-- loans
,cast(coalesce(dedamt.loan1_amount,0.00) as dec(10,2)) as loanPayment1
,dedamt.loan1_number as loanNumber1
,cast(coalesce(dedamt.loan2_amount,0.00) as dec(10,2)) as loanPayment2
,dedamt.loan2_number as loanNumber2
,cast(coalesce(dedamt.loan3_amount,0.00) as dec(10,2)) as loanPayment3
,dedamt.loan3_number as loanNumber3
,cast(coalesce(dedamt.loan4_amount,0.00) as dec(10,2)) as loanPayment4
,dedamt.loan4_number as loanNumber4
,cast(coalesce(dedamt.loan5_amount,0.00) as dec(10,2)) as loanPayment5
,dedamt.loan5_number as loanNumber5

,ppos.schedulefrequency as payroll_frequency
,' ' as empDeferralPercent
,lookup.value1 as pay_comp_code 
,pn.mname::char(1) as mname
,pd.positiontitle as title
,pip.identity as empno
,case when pe.emplstatus in ('T','R') then 'Inactive' else 'Active' end as emplstatus
,' ' as paytype
,' ' as rehiredate
,' ' as loa_begin_date
,' ' as loa_end_date
,' ' as cost1code
,' ' as cost2code
,' ' as cost3code
,pncw.url as email
,elu.lastupdatets

from person_identity pi

left join edi.edi_last_update elu on elu.feedid = 'Mutual_Of_America'

left join person_identity pip
  on pip.personid = pi.personid
and pip.identitytype = 'EmpNo'
and current_timestamp between pip.createts and pip.endts

left join person_employment pe
  on pe.personid = pi.personid
and current_date between pe.effectivedate and pe.enddate
and current_timestamp between pe.createts and pe.endts

/*
left join person_financial_plan_election pfp on pe.personid = pfp.personid
 and current_date between pfp.effectivedate and pfp.enddate
 and current_timestamp between pfp.createts and pfp.endts
 and pfp.benefitcalctype in ('P','F')
*/

LEFT JOIN pers_pos ppos
  on ppos.personid = pi.personid 
 and CURRENT_DATE BETWEEN ppos.effectivedate AND ppos.enddate 
 and CURRENT_TIMESTAMP BETWEEN ppos.createts AND ppos.endts

LEFT JOIN position_desc pd on ppos.positionid = pd.positionid 
AND current_date between pd.effectivedate and pd.enddate
AND current_timestamp between pd.createts and pd.endts

LEFT JOIN person_net_contacts pncw 
  ON pncw.personid = pi.personid
 AND current_date between pncw.effectivedate and pncw.enddate
 AND current_timestamp between pncw.createts and pncw.endts 
 AND pncw.netcontacttype = 'WRK'

left join person_names pn
  on pn.personid = pi.personid
and pn.nametype = 'Legal'
and current_date between pn.effectivedate and pn.enddate
and current_timestamp between pn.createts and pn.endts

left join person_maritalstatus pms
  on pms.personid = pi.personid
and current_date between pms.effectivedate and pms.enddate
and current_timestamp between pms.createts and pms.endts

left join person_address pa 
  on pa.personid = pi.personid
and pa.addresstype = 'Res'
and current_date between pa.effectivedate and pa.enddate
and current_timestamp between pa.createts and pa.endts

left join person_vitals pv
  on pv.personid = pi.personid
and current_date between pv.effectivedate and pv.enddate
and current_timestamp between pv.createts and pv.endts
   
LEFT JOIN person_payroll pp 
  on pp.personid = pi.personid 
 and CURRENT_DATE BETWEEN pp.effectivedate AND pp.enddate 
 and CURRENT_TIMESTAMP BETWEEN pp.createts AND pp.endts

left join person_locations pl
  on pl.personid = pi.personid
and current_date between pl.effectivedate and pl.enddate
and current_timestamp between pl.createts and pl.endts

left join location_codes lc
  on lc.locationid = pl.locationid
and current_date between lc.effectivedate and lc.enddate
and current_timestamp between lc.createts and lc.endts  

LEFT JOIN pay_unit pu 
   ON pu.payunitid = pp.payunitid
  AND current_timestamp between pu.createts and pu.endts
   
--------------------------------------
------ Current 401K Deductions -------
--------------------------------------
--Catchup contributions would also be included in the Employee Deferral or Roth Deferral field.
left join 
(select
 x.personid
,x.periodpaydate
,sum(x.e12_amount) as e12_amount -- excluded earnings
,sum(x.vb1_amount) as vb1_amount -- Pre Taxed 403(b)  -- VD0 and VDP
,sum(x.vb3_amount) as vb3_amount -- Roth
,sum(x.vb5_amount) as vb5_amount -- ER Match
,sum(x.vb6_amount) as vb6_amount -- ER Base Contribution
,sum(x.loan1_amount) as loan1_amount -- loan 1 amount
,max(x.loan1_number) as loan1_number -- loan 1 number
,sum(x.loan2_amount) as loan2_amount -- loan 2 amount
,max(x.loan2_number) as loan2_number -- loan 2 number
,sum(x.loan3_amount) as loan3_amount -- loan 3 amount
,max(x.loan3_number) as loan3_number -- loan 3 number
,sum(x.loan4_amount) as loan4_amount -- loan 4 amount
,max(x.loan4_number) as loan4_number -- loan 4 number
,sum(x.loan5_amount) as loan5_amount -- loan 5 amount
,max(x.loan5_number) as loan5_number -- loan 5 number
,sum(x.vb1_amount + x.vb3_amount + x.vb5_amount + x.vb6_amount + x.loan1_amount + x.loan2_amount + x.loan3_amount + x.loan4_amount + x.loan5_amount) as total_payroll_amount

from

(select
ppd.personid
,psp.periodpaydate
,case when ppd.paycode = lookup.etvid and lookup.value1 = '4' then amount  else 0 end as e12_amount  -- Exlcuded Earnings
,case when ppd.paycode = lookup.etvid and lookup.value1 = '1' then amount  else 0 end as vb1_amount  -- 403b/401k deductions VD0
,case when ppd.paycode = lookup.etvid and lookup.value1 = '2' then amount  else 0 end as vb3_amount  -- Roth deductions  
,case when ppd.paycode = lookup.etvid and lookup.value1 = '3' then amount  else 0 end as vb5_amount  -- Employer Match
,case when ppd.paycode = lookup.etvid and lookup.value1 = '6' then amount  else 0 end as vb6_amount  -- Employer Base Contribution
,case when ppd.paycode = lookup.etvid and lookup.value1 = '5' and lookup.value2 = '1' then amount  else 0 end as loan1_amount  -- Loan 1
,case when ppd.paycode = lookup.etvid and lookup.value1 = '5' and lookup.value2 = '1' then lookup.value2  else null end as loan1_number  -- Loan 1
,case when ppd.paycode = lookup.etvid and lookup.value1 = '5' and lookup.value2 = '2' then amount  else 0 end as loan2_amount  -- Loan 2
,case when ppd.paycode = lookup.etvid and lookup.value1 = '5' and lookup.value2 = '2' then lookup.value2  else null end as loan2_number  -- Loan 2
,case when ppd.paycode = lookup.etvid and lookup.value1 = '5' and lookup.value2 = '3' then amount  else 0 end as loan3_amount  -- Loan 3
,case when ppd.paycode = lookup.etvid and lookup.value1 = '5' and lookup.value2 = '3' then lookup.value2  else null end as loan3_number  -- Loan 3
,case when ppd.paycode = lookup.etvid and lookup.value1 = '5' and lookup.value2 = '4' then amount  else 0 end as loan4_amount  -- Loan 3
,case when ppd.paycode = lookup.etvid and lookup.value1 = '5' and lookup.value2 = '4' then lookup.value2  else null end as loan4_number  -- Loan 3
,case when ppd.paycode = lookup.etvid and lookup.value1 = '5' and lookup.value2 = '5' then amount  else 0 end as loan5_amount  -- Loan 3
,case when ppd.paycode = lookup.etvid and lookup.value1 = '5' and lookup.value2 = '5' then lookup.value2  else null end as loan5_number  -- Loan 3
,ppd.paymentheaderid

from PAYROLL.payment_detail ppd 
---------------------------------------------
-- ETVID LOOKUP TABLE JOIN --
---------------------------------------------
JOIN  (select lp.lookupid, key1 as etvid, value1, value2 from edi.lookup lp
    		join edi.lookup_schema els on lp.lookupid = els.lookupid and els.lookupname = 'ETV IDs' 
			where current_date between lp.effectivedate and lp.enddate and current_timestamp between lp.createts and lp.endts
    		) lookup on lookup.lookupid is not null and lookup.etvid = ppd.paycode
---------------------------------------------
join PAYROLL.payment_header pph on ppd.paymentheaderid = pph.paymentheaderid
join pay_schedule_period psp on psp.payscheduleperiodid = pph.payscheduleperiodid
where ppd.paymentheaderid in 
        (select paymentheaderid from PAYROLL.payment_header where payscheduleperiodid in 
                (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay  
                           join edi.edi_last_update elu  on elu.feedid =  'Mutual_Of_America' and coalesce(?::timestamp,elu.lastupdatets) <= ppay.statusdate
					       where ppay.pspaypayrollstatusid = 4 )))) x 			       
 group by 1,2 having sum(x.vb1_amount + x.vb3_amount + x.vb5_amount + x.vb6_amount + x.loan1_amount + x.loan2_amount + x.loan3_amount + x.loan4_amount + x.loan5_amount) <> 0) dedamt on dedamt.personid = pi.personid

-----------------------------------------  ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------ Current 401K Taxable Wages -------
-----------------------------------------  
--- using the WS15 operand to determine which etv's should be included for 401k taxable wage
LEFT JOIN (SELECT 
			ppd.personid
			,sum(amount_ytd)
			,sum(ppd.units) AS hours
			,sum(ppd.amount) as taxable_wage
            FROM PAYROLL.payment_detail ppd
               join edi.edi_last_update elu  on elu.feedid =  'Mutual_Of_America' 
	   		join PAYROLL.payment_header pph on ppd.paymentheaderid = pph.paymentheaderid
	   		join pspay_payroll_pay_sch_periods ppsp on ppsp.payscheduleperiodid = pph.payscheduleperiodid
	   		join pspay_payroll ppay on ppay.pspaypayrollid = ppsp.pspaypayrollid and ppay.pspaypayrollstatusid = 4 and ppay.statusdate is not null
            WHERE ppd.paycode in (select a.paycode from payroll.pay_code_relationships a where a.paycoderelationshiptype in ('401kWg') and current_date between a.effectivedate and a.enddate and current_timestamp between a.createts and a.endts group by paycode)
	    	    and coalesce(?::timestamp,elu.lastupdatets) <= ppay.statusdate
            GROUP BY ppd.personid, gross_pay, pph.gross_pay_ytd) grosscur ON grosscur.personid = pi.personid 
            
-------------------------------------  -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------ YTD 401K Taxable Wages -------
------------------------------------- 
--- using the WS15 operand to determine which etv's should be included for 401k taxable wage
LEFT JOIN (SELECT 
			ppd.personid
			,sum(ppd.units) AS hours
			,sum(ppd.amount) as taxable_wage
            FROM PAYROLL.payment_detail ppd
	   		join PAYROLL.payment_header pph on ppd.paymentheaderid = pph.paymentheaderid
	   		join pspay_payroll_pay_sch_periods ppsp on ppsp.payscheduleperiodid = pph.payscheduleperiodid
	   		join pspay_payroll ppay on ppay.pspaypayrollid = ppsp.pspaypayrollid and ppay.pspaypayrollstatusid = 4 and ppay.statusdate is not null
            WHERE ppd.paycode in (select a.paycode from payroll.pay_code_relationships a where a.paycoderelationshiptype in ('401kWg') and current_date between a.effectivedate and a.enddate and current_timestamp between a.createts and a.endts group by paycode)
            AND date_part('year', ppd.check_date) = date_part('year',current_date::DATE)
            GROUP BY 1) grossytd ON grossytd.personid = pip.personid 

----------------------------------
------ YTD 401K Deductions -------
----------------------------------
left join 
(select
 x.personid
,sum(x.e12_amount) as e12_amount -- excluded earnings
,sum(x.vb1_amount) as vb1_amount -- Pre Taxed 403(b)   
,sum(x.vb3_amount) as vb3_amount -- Roth
,sum(x.vb5_amount) as vb5_amount -- ER Match
,sum(x.vb6_amount) as vb6_amount -- ER Base Contribution
,sum(x.loan1_amount) as loan1_amount -- loan 1 amount
,max(x.loan1_number) as loan1_number -- loan 1 number
,sum(x.loan2_amount) as loan2_amount -- loan 2 amount
,max(x.loan2_number) as loan2_number -- loan 2 number
,sum(x.loan3_amount) as loan3_amount -- loan 3 amount
,max(x.loan3_number) as loan3_number -- loan 3 number
,sum(x.loan4_amount) as loan4_amount -- loan 4 amount
,max(x.loan4_number) as loan4_number -- loan 4 number
,sum(x.loan5_amount) as loan5_amount -- loan 5 amount
,max(x.loan5_number) as loan5_number -- loan 5 number
,sum(x.vb1_amount + x.vb3_amount + x.vb5_amount + x.vb6_amount + x.loan1_amount + x.loan2_amount + x.loan3_amount + x.loan4_amount + x.loan5_amount) as total_payroll_amount

from

(select
ppd.personid
,case when ppd.paycode = lookup.etvid and lookup.value1 = '4' then amount  else 0 end as e12_amount  -- Exlcuded Earnings
,case when ppd.paycode = lookup.etvid and lookup.value1 = '1' then amount  else 0 end as vb1_amount  -- 403b/401k deductions
,case when ppd.paycode = lookup.etvid and lookup.value1 = '2' then amount  else 0 end as vb3_amount  -- Roth deductions  
,case when ppd.paycode = lookup.etvid and lookup.value1 = '3' then amount  else 0 end as vb5_amount  -- Employer Match
,case when ppd.paycode = lookup.etvid and lookup.value1 = '6' then amount  else 0 end as vb6_amount  -- Employer Base Contribution
,case when ppd.paycode = lookup.etvid and lookup.value1 = '5' and lookup.value2 = '1' then amount  else 0 end as loan1_amount  -- Loan 1
,case when ppd.paycode = lookup.etvid and lookup.value1 = '5' and lookup.value2 = '1' then lookup.value2  else null end as loan1_number  -- Loan 1
,case when ppd.paycode = lookup.etvid and lookup.value1 = '5' and lookup.value2 = '2' then amount  else 0 end as loan2_amount  -- Loan 2
,case when ppd.paycode = lookup.etvid and lookup.value1 = '5' and lookup.value2 = '2' then lookup.value2  else null end as loan2_number  -- Loan 2
,case when ppd.paycode = lookup.etvid and lookup.value1 = '5' and lookup.value2 = '3' then amount  else 0 end as loan3_amount  -- Loan 3
,case when ppd.paycode = lookup.etvid and lookup.value1 = '5' and lookup.value2 = '3' then lookup.value2  else null end as loan3_number  -- Loan 3
,case when ppd.paycode = lookup.etvid and lookup.value1 = '5' and lookup.value2 = '4' then amount  else 0 end as loan4_amount  -- Loan 3
,case when ppd.paycode = lookup.etvid and lookup.value1 = '5' and lookup.value2 = '4' then lookup.value2  else null end as loan4_number  -- Loan 3
,case when ppd.paycode = lookup.etvid and lookup.value1 = '5' and lookup.value2 = '5' then amount  else 0 end as loan5_amount  -- Loan 3
,case when ppd.paycode = lookup.etvid and lookup.value1 = '5' and lookup.value2 = '5' then lookup.value2  else null end as loan5_number  -- Loan 3
,ppd.paymentheaderid

from PAYROLL.payment_detail ppd 
---------------------------------------------
-- ETVID LOOKUP TABLE JOIN --
---------------------------------------------
JOIN  (select lp.lookupid, key1 as etvid, value1, value2 from edi.lookup lp
    		join edi.lookup_schema els on lp.lookupid = els.lookupid and els.lookupname = 'ETV IDs' 
			where current_date between lp.effectivedate and lp.enddate and current_timestamp between lp.createts and lp.endts
    		) lookup on lookup.lookupid is not null and lookup.etvid = ppd.paycode
---------------------------------------------
join PAYROLL.payment_header pph on ppd.paymentheaderid = pph.paymentheaderid
join pay_schedule_period psp on psp.payscheduleperiodid = pph.payscheduleperiodid
where ppd.paymentheaderid in 
        (select paymentheaderid from PAYROLL.payment_header where payscheduleperiodid in 
                (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay 
					       where ppay.pspaypayrollstatusid = 4 
						   AND date_part('year', ppd.check_date) = date_part('year',current_date::DATE) )))) x 			       
 group by 1 having sum(x.vb1_amount + x.vb3_amount + x.vb5_amount + x.vb6_amount + x.loan1_amount + x.loan2_amount + x.loan3_amount + x.loan4_amount + x.loan5_amount) <> 0) dedamtytd on dedamtytd.personid = pi.personid

---------------------------------------------  -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- PLAN INFO LOOKUP TABLE JOIN --
---------------------------------------------
LEFT JOIN  (select lp.lookupid, value1, value2, value3 from edi.lookup lp
    		join edi.lookup_schema els on lp.lookupid = els.lookupid and els.lookupname = 'Plan Info' 
			where current_date between lp.effectivedate and lp.enddate and current_timestamp between lp.createts and lp.endts
    		) lookup on lookup.lookupid is not null
---------------------------------------------
where pi.identitytype = 'SSN' --and pi.personid = '834'
  and current_timestamp between pi.createts and pi.endts
  and coalesce(dedamt.vb1_amount,dedamt.vb3_amount,dedamt.vb5_amount,dedamt.vb6_amount,dedamt.loan1_amount,dedamt.loan2_amount,dedamt.loan3_amount,dedamt.loan4_amount,dedamt.loan5_amount) >= 0
  order by 1;