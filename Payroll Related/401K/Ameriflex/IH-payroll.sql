--NEW 
SELECT distinct
PI.PERSONID
,'IH' :: char(2) as record_ID
,'AMF001' :: char(6) as TPA_ID

,lookup.GroupCode :: char(9) as Group_Code 

,dedamt_EE.account_type :: char(3) as Account_Type

,to_char(coalesce(lookup.plan_year_start_date,cppy.planyearstart),'YYYYMMDD') :: char(8) as Plan_Year_Start_date
,to_char(coalesce(lookup.plan_year_end_date,cppy.planyearend),'YYYYMMDD') :: char(8) as  Plan_Year_End_date

,replace(pi.identity ,'-','') :: char(9) as emp_ssn

,Case when dedamt_ee.account_type = 'FSA' then dedamt_ee.fsa_amount
      when dedamt_ee.account_type = 'DCA' then dedamt_ee.dca_amount
      when dedamt_ee.account_type = 'TRN' then dedamt_ee.trn_amount --trn
      when dedamt_ee.account_type = 'PKG' then dedamt_ee.pkg_amount --pkg
      when dedamt_ee.account_type = 'UMB' then dedamt_ee.umb_amount --umb
      when dedamt_ee.account_type = 'HRA' then dedamt_ee.hra_amount --hsa
      else '0.00'
 end :: decimal(18,2) as ee_amount

,Case when dedamt_er.account_type = 'FSA' then dedamt_er.fsa_amount
      when dedamt_er.account_type = 'DCA' then dedamt_er.dca_amount
      when dedamt_er.account_type = 'TRN' then dedamt_er.trn_amount --trn
      when dedamt_er.account_type = 'PKG' then dedamt_er.pkg_amount --pkg
      when dedamt_er.account_type = 'UMB' then dedamt_er.umb_amount --umb
      when dedamt_er.account_type = 'HRA' then dedamt_er.hra_amount --hsa
      else '0.00'
 end :: decimal(18,2) as er_amount
 
,to_char(dedamt_ee.check_date,'YYYYMMDD')::char(8) as Deposit_Date


--Control Report Values --
,pie.identity ::varchar(15) as cr_empno
,rtrim(ltrim(replace(pn.lname,',',' '))) :: char(26) as emp_last_name
,rtrim(ltrim(replace(pn.fname,',',' '))) :: char(19) as emp_first_name
,rtrim(ltrim(substring(pn.mname,1,1))) :: char(1) as emp_middle_intial

,elu.lastupdatets

from person_identity pi

left join edi.edi_last_update elu on elu.feedid = 'Ameriflex_FLEX_Payroll_Deduction'

LEFT JOIN person_names pn 
  ON pn.personid = pi.personid 
 AND pn.nametype = 'Legal'::bpchar 
 and (current_date between pn.effectivedate and pn.enddate
	or (pn.effectivedate > current_date
	    and pn.effectivedate < pn.enddate))
and current_timestamp between pn.createts and pn.endts

--- mlc 12/22/2020 - added value3 and value4 
LEFT JOIN (select lp.lookupid, value1 as GroupCode, value2 as PlanID, lp.VALUE3 ::date as plan_year_start_date, lp.VALUE4 ::date as plan_year_end_date
from edi.lookup lp
join edi.lookup_schema els on lp.lookupid = els.lookupid and els.lookupname = 'Ameriflex_FLEX_Eligibility_Election' 
and current_date between lp.effectivedate and lp.enddate
 )lookup on lookup.lookupid is not null


left join person_identity pie
  on pie.personid = pi.personid
 and pie.identitytype = 'EmpNo'
 and current_timestamp between pie.createts and pie.endts
 

left join person_identity pip
  on pip.personid = pi.personid
  and pip.identitytype = 'PSPID'
  and current_timestamp between pip.createts and pip.endts 


left join dxpersonposition div
  on div.personid = pi.personid  

left join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts 

/*
FSA = 60,62
DCA = 61,63
TRN = 6A,6AP
PKG = 6B,6BP
UMB = 67,6H,6J,6Y,6Z
HRA = 1Y
*/

JOIN person_bene_election pbe 
  ON pbe.personid = pI.personid
  and pbe.selectedoption = 'Y' 
  and pbe.benefitsubclass in ('60','62','61','63','6A','6AP','6B','6BP','67','6H','6J','6Y','6Z','1Y' )
  AND pbe.benefitelection IN ('E','T')
  AND current_date BETWEEN pbe.effectivedate AND pbe.enddate 
  AND current_timestamp BETWEEN pbe.createts AND pbe.endts

 left join Comp_plan_plan_year cppy
 on pbe.compplanid = cppy.compplanid
 and cppy.compplanplanyeartype = 'Bene'
 and current_date between cppy.planyearstart and cppy.planyearend

LEFT JOIN person_payroll ppay
  ON ppay.personid = pe.personid
 AND current_date BETWEEN ppay.effectivedate AND ppay.enddate
 AND current_timestamp BETWEEN ppay.createts AND ppay.endts      

LEFT JOIN pay_unit pu
  ON pu.payunitid = ppay.payunitid
   
-------------------------------------------------------------------------------------------------------------------------------
--ee
left join 
(select
 x.personid
,x.check_date
,x.paycode
,x.account_type
,sum(x.fsa_amount) as fsa_amount
,sum(x.dca_amount) as dca_amount
,sum(x.trn_amount) as trn_amount
,sum(x.pkg_amount) as pkg_amount
,sum(x.umb_amount) as umb_amount
,sum(x.hra_amount) as hra_amount
from
 

(select 
 ppd.personid
,ppd.check_date
,ppd.paycode
,lookup.account_type
,case when lookup.account_type = 'FSA' then ppd.amount else 0 end as fsa_amount --fsa
,case when lookup.account_type = 'DCA' then ppd.amount else 0 end as dca_amount --dca
,case when lookup.account_type = 'TRN' then ppd.amount else 0 end as trn_amount --trn
,case when lookup.account_type = 'PKG' then ppd.amount else 0 end as pkg_amount --pkg
,case when lookup.account_type = 'UMB' then ppd.amount else 0 end as umb_amount --umb
,case when lookup.account_type = 'HRA' then ppd.amount else 0 end as hra_amount --hsa
,ppd.paymentheaderid

from payroll.payment_detail ppd

join (select lp.lookupid, value1 as paycode, value2 as account_type, value3 as contrib_type from edi.lookup lp
        join edi.lookup_schema els on lp.lookupid = els.lookupid and els.lookupname = 'Ameriflex_FLEX_Payroll_Deduction'
	  where current_date between lp.effectivedate and lp.enddate and current_timestamp between lp.createts and lp.endts)
	  lookup on lookup.paycode = ppd.paycode 

where paymentheaderid in 
        (select paymentheaderid from payroll.payment_header where payscheduleperiodid in 
                (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay join edi.edi_last_update elu 
                             on elu.feedid = 'Ameriflex_FLEX_Payroll_Deduction' 
                              and elu.lastupdatets <= ppay.statusdate
                            where ppay.pspaypayrollstatusid = 4 
                             )))
  

    		
  and lookup.contrib_type = 'EE') x
  group by personid, check_date, paycode, account_type
  having sum(x.fsa_amount + x.dca_amount + x.trn_amount + x.pkg_amount + x.umb_amount + x.hra_amount) <> 0
 ) dedamt_EE on dedamt_EE.personid = pi.personid 

--------------------------------------------------------------------------------------------------------------------------------------------
----er---- etv_ids should be changes for er 05.30.2019
left join 
(select
 x.personid
,x.check_date
,x.paycode
,x.account_type
,sum(x.fsa_amount) as fsa_amount
,sum(x.dca_amount) as dca_amount
,sum(x.trn_amount) as trn_amount
,sum(x.pkg_amount) as pkg_amount
,sum(x.umb_amount) as umb_amount
,sum(x.hra_amount) as hra_amount
from
 

(select distinct
 ppd.personid
,ppd.check_date
,ppd.paycode
,lookup.account_type
,case when lookup.account_type = 'FSA' then ppd.amount else 0 end as fsa_amount --fsa
,case when lookup.account_type = 'DCA' then ppd.amount else 0 end as dca_amount --dca
,case when lookup.account_type = 'TRN' then ppd.amount else 0 end as trn_amount --trn
,case when lookup.account_type = 'PKG' then ppd.amount else 0 end as pkg_amount --pkg
,case when lookup.account_type = 'UMB' then ppd.amount else 0 end as umb_amount --umb
,case when lookup.account_type = 'HRA' then ppd.amount else 0 end as hra_amount --hsa
,ppd.paymentheaderid

from payroll.payment_detail ppd

join (select lp.lookupid, value1 as paycode, value2 as account_type, value3 as contrib_type from edi.lookup lp
        join edi.lookup_schema els on lp.lookupid = els.lookupid and els.lookupname = 'Ameriflex_FLEX_Payroll_Deduction'
	  where current_date between lp.effectivedate and lp.enddate and current_timestamp between lp.createts and lp.endts)
	  lookup on lookup.paycode = ppd.paycode 
	  
where paymentheaderid in 
        (select paymentheaderid from payroll.payment_header where payscheduleperiodid in 
                (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay join edi.edi_last_update elu 
                             on elu.feedid = 'Ameriflex_FLEX_Payroll_Deduction' 
                             and elu.lastupdatets <= ppay.statusdate
                             where ppay.pspaypayrollstatusid = 4 )))
  and lookup.contrib_type = 'ER') x
  group by personid, check_date, paycode, account_type
  having sum(x.fsa_amount + x.dca_amount + x.trn_amount + x.pkg_amount + x.umb_amount + x.hra_amount) <> 0

  ) dedamt_ER on dedamt_ER.personid = pi.personid 

------------------------------------------------------------------------------------------------------------------------------------------

where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  and coalesce(dedamt_ee.fsa_amount,dedamt_ee.dca_amount,dedamt_ee.trn_amount,dedamt_ee.pkg_amount,dedamt_ee.umb_amount,dedamt_ee.hra_amount) >= 0
   order by emp_ssn,account_type,deposit_date