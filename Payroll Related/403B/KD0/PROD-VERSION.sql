select distinct

pi.personid
,pu.payunitdesc
,pu.payunitxid ::char(2) as payunitxid
,'CONTRIBUTION'  ::varchar(50) as qsource
,'Grand Totals' ::varchar(25) as grandTotals
,elu.lastupdatets ::varchar(19) as lookbackdate

,to_char(coalesce(dedamt.periodpaydate,psp.periodpaydate),'MM/DD/YYYY')::char(10) as pay_date
,pi.identity ::char(9) as ssn
,pip.identity ::char(9) as empno
,pn.fname ::char(15) as fname
,pn.mname ::char(1) as mname
,pn.lname ::char(20) as lname 
,ocd.organizationdesc:: varchar(50) as department
,case when lc.locationid = '12' then '101'
	  when lc.locationid = '11' then '102'
	  when lc.locationid = '13' then '103'
	  when lc.locationid = '14' then '99'
		end ::varchar(5) as location
,pe.emplstatus ::char(1) as emplstatuscode
,pa.streetaddress ::char(33) as addr1
,pa.streetaddress2 ::char(33) as addr2
,pa.city ::char(25) as city
,pa.countrycode ::varchar(10) as country
,pa.stateprovincecode ::char(2) as state
,pa.postalcode ::char(5) as zip
,case when ppos.schedulefrequency = 'B' then 'BW' else ppos.schedulefrequency end ::varchar(5) as payroll_frequency
,pv.gendercode::char(1) as gender
,coalesce(ppch.phoneno,ppcm.phoneno) ::char(10) as phoneno
,pncw.url ::varchar(75) as email
,case when pc.frequencycode = 'H' then (pc.compamount * 52 * 40) 
	when pc.frequencycode = 'B' then (pc.compamount * 26) 
	when pc.frequencycode = 'S' then (pc.compamount * 24) 
	when pc.frequencycode = 'M' then (pc.compamount * 12) 
	else pc.compamount end ::decimal(10,2)as salary
,to_char(pv.birthdate,'MM/DD/YYYY') ::char(10) as dob
,to_char(least(pe.effectivedate,pe.emplservicedate,pe.emplhiredate),'MM/DD/YYYY') ::char(10) as doh
,case when pe.emplstatus in ('T','R') then to_char(pe.effectivedate,'MM/DD/YYYY') else null end ::char(10) as dot
,case when pe.emplstatus in ('L','P') then to_char(pe.effectivedate,'MM/DD/YYYY') else null end ::char(10) as leavestart
,case when pe.emplstatus in ('L','P') then to_char(pe.enddate,'MM/DD/YYYY') else null end ::char(10) as leaveend

-- current pay period values
,cast(coalesce(grosscur.taxable_wage,0.00) as decimal(10,2)) as planCompensation
,cast(coalesce(grosscur.taxable_wage,0.00) as decimal(10,2)) as grossCompensation
,cast(coalesce(grosscur.hours,0) as decimal(10,2)) as HoursWorked		
,cast(coalesce(dedamt.vdo_amount,0.00) as decimal(10,2)) as empDeferral
,cast(coalesce(dedamt.vdp_amount,0.00) as decimal(10,2)) as empCatchup
,cast(coalesce(dedamt.vb6_amount,0.00) as decimal(10,2)) as erMatch

--YTD Values
,cast(coalesce(grossytd.taxable_wage,0.00) as decimal(10,2)) as planCompensationYTD
,cast(coalesce(grossytd.hours,0) as decimal(10,2)) as HoursWorkedYTD
,cast(coalesce(dedamtytd.vdo_amount,0.00) as decimal(10,2)) as empDeferralYTD
,cast(coalesce(dedamtytd.vdp_amount,0.00) as decimal(10,2)) as empCatchupYTD
,cast(coalesce(dedamtytd.vb6_amount,0.00) as decimal(10,2)) as erMatchYTD

-- loans
,'1' ::char(1) as loanNumber1
,cast(coalesce(dedamt.loan1_amount,0.00) as decimal(10,2)) as loanPayment1
,'2' ::char(1) as loanNumber2
,cast(coalesce(dedamt.loan2_amount,0.00) as decimal(10,2)) as loanPayment2

,pd.positiontitle ::varchar(75) as title
,case when pe.emplstatus in ('T','R') then 'Inactive' else 'Active' end ::varchar(10) as emplstatus

from person_identity pi

left join edi.edi_last_update elu on elu.feedid = 'KD0_LincolnFinancial_403B_Contributions'

left join person_identity pip
  on pip.personid = pi.personid
and pip.identitytype = 'EmpNo'
and current_timestamp between pip.createts and pip.endts

left join person_employment pe
  on pe.personid = pi.personid
and current_date between pe.effectivedate and pe.enddate
and current_timestamp between pe.createts and pe.endts

LEFT JOIN 
(select personid, positionid,schedulefrequency, max(effectivedate) as effectivedate, max(enddate) as enddate,
RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
from pers_pos 
where effectivedate < enddate 
 and CURRENT_TIMESTAMP BETWEEN createts AND endts
group by 1,2,3) ppos on ppos.personid = pi.personid and ppos.rank = 1

LEFT JOIN 
(select positionid,positiontitle, max(effectivedate) as effectivedate, max(enddate) as enddate,
RANK() OVER (PARTITION BY positionid ORDER BY MAX(effectivedate) DESC) AS RANK
from position_desc
where effectivedate < enddate 
 and CURRENT_TIMESTAMP BETWEEN createts AND endts
group by 1,2) pd on ppos.positionid = pd.positionid and pd.rank = 1

-- ORGANIZATION JOINS ------------------------------------------------
left join (select positionid,posorgreltype,organizationid, max(effectivedate) as effectivedate, RANK() OVER (PARTITION BY positionid ORDER BY max(effectivedate) DESC) AS RANK
	    from pos_org_rel where effectivedate < enddate and current_timestamp between createts and endts and posorgreltype = 'Member'
	    group by 1,2,3) pord on pord.positionid = ppos.positionid and pord.rank = 1

left JOIN (select organizationid,memberoforgid, max(effectivedate) as effectivedate, RANK() OVER (PARTITION BY organizationid ORDER BY max(effectivedate) DESC) AS RANK
	    from org_rel where effectivedate < enddate and current_timestamp between createts and endts
	    group by 1,2) orel ON orel.organizationid = pord.organizationid and orel.rank = 1
 
left JOIN (select organizationid,organizationtype,organizationdesc,max(effectivedate) as effectivedate, RANK() OVER (PARTITION BY organizationid ORDER BY max(effectivedate) DESC) AS RANK
	    from organization_code where effectivedate < enddate and current_timestamp between createts and endts AND organizationtype = 'Div' 
	    group by 1,2,3) ocdi ON ocdi.organizationid = orel.memberoforgid and ocdi.rank = 1
 
left JOIN (select organizationid,organizationtype,organizationdesc,max(effectivedate) as effectivedate, RANK() OVER (PARTITION BY organizationid ORDER BY max(effectivedate) DESC) AS RANK
	    from organization_code where effectivedate < enddate and current_timestamp between createts and endts AND organizationtype = 'Dept'
	    group by 1,2,3) ocd ON ocd.organizationid = pord.organizationid and ocd.rank = 1

left join (select personid,locationid,max(effectivedate) as effectivedate, RANK() OVER (PARTITION BY personid ORDER BY max(effectivedate) DESC) AS RANK
	    from person_locations where effectivedate < enddate and current_timestamp between createts and endts 
	    group by 1,2) pl ON pl.personid = ppos.personid and pl.rank = 1
 
LEFT JOIN (select locationid,locationcode, max(effectivedate) as effectivedate, RANK() OVER (PARTITION BY locationid ORDER BY max(effectivedate) DESC) AS RANK
	    from location_codes where effectivedate < enddate and current_timestamp between createts and endts 
	    group by 1,2) lc ON pl.locationid = lc.locationid and lc.rank = 1

---------------------------

left join person_phone_contacts ppch
 on ppch.personid = pi.personid
 AND current_date between ppch.effectivedate and ppch.enddate
 AND current_timestamp between ppch.createts and ppch.endts 
 AND ppch.phonecontacttype = 'Home' 

left join person_phone_contacts ppcm
 on ppcm.personid = pi.personid
 AND current_date between ppcm.effectivedate and ppcm.enddate
 AND current_timestamp between ppcm.createts and ppcm.endts 
 AND ppcm.phonecontacttype = 'Mobile'

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

LEFT JOIN pay_unit pu 
   ON pu.payunitid = pp.payunitid
  AND current_timestamp between pu.createts and pu.endts

left join (select pc.personid, pc.compamount,pc.frequencycode, max(pc.effectivedate) as effectivedate, RANK() OVER (PARTITION BY pc.personid ORDER BY max(pc.effectivedate) DESC) AS RANK
             from person_compensation pc
			where pc.effectivedate < pc.enddate and current_timestamp between pc.createts and pc.endts
            group by 1,2,3) pc on pc.personid = pe.personid and pc.rank = 1
   
-----------------------------------------  ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------ Current 401K Taxable Wages -------
-----------------------------------------  
--- using the WS15 operand to determine which etv's should be included for 401k taxable wage
LEFT JOIN (SELECT 
			ppd.personid
			,sum(etv_amount_ytd)
			,sum(ppd.etype_hours) AS hours
			,sum(ppd.etv_amount) as taxable_wage
            FROM pspay_payment_detail ppd
	   		join pspay_payment_header pph on ppd.paymentheaderid = pph.paymentheaderid
	   		join pspay_payroll_pay_sch_periods ppsp on ppsp.payscheduleperiodid = pph.payscheduleperiodid
	   		join pspay_payroll ppay on ppay.pspaypayrollid = ppsp.pspaypayrollid and ppay.pspaypayrollstatusid = 4 and ppay.statusdate is not null
            WHERE ppd.etv_id in (select etv_id from pspay_etv_operators where operand = 'WS15' and etvindicator in ('E') and group_key <> '$$$$$' and opcode = 'A' group by 1)
	    	and ppay.statusdate >= ?::timestamp
            GROUP BY 1) grosscur ON grosscur.personid = pi.personid 

--------------------------------------
------ Current 401K Deductions -------
--------------------------------------
left join 
(select
 x.personid
,x.periodpaydate
,sum(x.vdo_amount) as vdo_amount -- Pre Taxed 403(b)  
,sum(x.vdp_amount) as vdp_amount -- 403b EE Catchup
,sum(x.vb6_amount) as vb6_amount -- ER Base Contribution
,sum(x.loan1_amount) as loan1_amount -- loan 1 amount
,sum(x.loan2_amount) as loan2_amount -- loan 2 amount
,sum(x.vdo_amount + x.vdp_amount + x.vb6_amount + x.loan1_amount + x.loan2_amount) as total_payroll_amount

from

(select
ppd.personid
,psp.periodpaydate
,case when ppd.etv_id = 'VDO' then etv_amount else 0 end as vdo_amount  -- 403b EE deductions
,case when ppd.etv_id = 'VDP' then etv_amount else 0 end as vdp_amount  -- 403b EE Catchup
,case when ppd.etv_id = 'VB6' then etv_amount else 0 end as vb6_amount  -- Employer Match
,case when ppd.etv_id = 'VAT' then etv_amount else 0 end as loan1_amount  -- Loan 1
,case when ppd.etv_id = 'VAU' then etv_amount else 0 end as loan2_amount  -- Loan 2
,ppd.paymentheaderid

from pspay_payment_detail ppd 
join pspay_payment_header pph on ppd.paymentheaderid = pph.paymentheaderid
join pay_schedule_period psp on psp.payscheduleperiodid = pph.payscheduleperiodid
where ppd.paymentheaderid in 
        (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay 
					       where ?::timestamp <= ppay.statusdate and ppay.pspaypayrollstatusid = 4 )))) x 			       
 group by 1,2 having sum(x.vdo_amount + x.vdp_amount + x.vb6_amount + x.loan1_amount + x.loan2_amount) <> 0) dedamt on dedamt.personid = pi.personid

-------------------------------------  -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------ YTD 401K Taxable Wages -------
------------------------------------- 
--- using the WS15 operand to determine which etv's should be included for 401k taxable wage
LEFT JOIN (SELECT 
			ppd.personid
			,sum(ppd.etype_hours) AS hours
			,sum(ppd.etv_amount) as taxable_wage
            FROM pspay_payment_detail ppd
	   		join pspay_payment_header pph on ppd.paymentheaderid = pph.paymentheaderid
	   		join pspay_payroll_pay_sch_periods ppsp on ppsp.payscheduleperiodid = pph.payscheduleperiodid
	   		join pspay_payroll ppay on ppay.pspaypayrollid = ppsp.pspaypayrollid and ppay.pspaypayrollstatusid = 4 and ppay.statusdate is not null
            WHERE ppd.etv_id in (select etv_id from pspay_etv_operators where operand = 'WS15' and etvindicator in ('E') and group_key <> '$$$$$' and opcode = 'A' group by 1)
            AND date_part('year', ppd.check_date) = date_part('year',current_date::DATE)
-- ***** Revisit this for Yellow P20 - make sure we can do accurate as of reporting ***** --	   
--and ppay.statusdate <= '2020-06-01'::timestamp
            GROUP BY 1) grossytd ON grossytd.personid = pip.personid 

----------------------------------
------ YTD 401K Deductions -------
----------------------------------
left join 
(select
 x.personid
,sum(x.vdo_amount) as vdo_amount -- Pre Taxed 403(b)  
,sum(x.vdp_amount) as vdp_amount -- 403b EE Catchup
,sum(x.vb6_amount) as vb6_amount -- ER Base Contribution
,sum(x.loan1_amount) as loan1_amount -- loan 1 amount
,sum(x.loan2_amount) as loan2_amount -- loan 2 amount
,sum(x.vdo_amount + x.vdp_amount + x.vb6_amount + x.loan1_amount + x.loan2_amount) as total_payroll_amount

from

(select
ppd.personid
,case when ppd.etv_id = 'VDO' AND date_part('year', ppd.check_date) = date_part('year',current_date) then etv_amount else 0 end as vdo_amount  -- 403b EE deductions
,case when ppd.etv_id = 'VDP' AND date_part('year', ppd.check_date) = date_part('year',current_date) then etv_amount else 0 end as vdp_amount  -- 403b EE Catchup
,case when ppd.etv_id = 'VB6' AND date_part('year', ppd.check_date) = date_part('year',current_date) then etv_amount else 0 end as vb6_amount  -- Employer Match
,case when ppd.etv_id = 'VAT' AND date_part('year', ppd.check_date) = date_part('year',current_date) then etv_amount else 0 end as loan1_amount  -- Loan 1
,case when ppd.etv_id = 'VAU' AND date_part('year', ppd.check_date) = date_part('year',current_date) then etv_amount else 0 end as loan2_amount  -- Loan 2

from pspay_payment_detail ppd 
join pspay_payment_header pph on ppd.paymentheaderid = pph.paymentheaderid
join pay_schedule_period psp on psp.payscheduleperiodid = pph.payscheduleperiodid
where ppd.paymentheaderid in 
        (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay 
					       where ppay.pspaypayrollstatusid = 4 AND date_part('year', ppay.statusdate) = date_part('year',current_timestamp) )))) x 			       
 group by 1 having sum(x.vdo_amount + x.vdp_amount + x.vb6_amount + x.loan1_amount + x.loan2_amount) <> 0) dedamtytd on dedamtytd.personid = pi.personid


------------------------------------------------------
-- JOIN TO GET CURRENT PERIODPAYDATE FOR TERMS --
------------------------------------------------------
left join (select psp.payunitid, max(periodpaydate) as periodpaydate
             from pay_schedule_period psp
             join pay_unit pu on pu.payunitid = psp.payunitid
            where psp.payrolltypeid = 1 and psp.processfinaldate::date is not null and psp.periodpaydate >= ?::timestamp group by 1) psp on psp.payunitid = pu.payunitid
------------------------------------------------------

where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  and pu.payunitxid in ('01','02')
  and (dedamt.vdo_amount+dedamt.vdp_amount+dedamt.vb6_amount+dedamt.loan1_amount+dedamt.loan2_amount) <> 0
  order by payunitxid, pay_date
