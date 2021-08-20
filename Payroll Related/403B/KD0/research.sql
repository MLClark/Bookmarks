select * from company_parameters where companyparametername = 'PInt' ;


select * from dxcompanyname;
select * from pay_schedule_period where date_part('year',periodpaydate)='2020' and date_part('month',periodpaydate)='07';
select * from edi.edi_last_update where feedid = 'KD0_LincolnFinancial_403B_Contributions'; --2021-02-10 14:55:01

update edi.edi_last_update set lastupdatets = '2021-07-07 17:55:52' where feedid = 'KD0_LincolnFinancial_403B_Contributions'; --2021-07-07 17:55:52

select * from pspay_payment_detail where etv_id in ('VDO');
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
 group by 1,2 having sum(x.vdo_amount + x.vdp_amount + x.vb6_amount + x.loan1_amount + x.loan2_amount) <> 0)