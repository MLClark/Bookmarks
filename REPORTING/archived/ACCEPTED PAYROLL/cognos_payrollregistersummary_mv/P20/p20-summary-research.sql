select * from pspay_payment_header where personid = '4510' and payscheduleperiodid = '477';
select * from payroll.payment_header where personid = '4510' and payscheduleperiodid = '477';
select * from person_identity where personid = '4510';
select * from pay_unit;
select * from pay_schedule_period where payscheduleperiodid = '477';
select * from pspay_payroll_pay_sch_periods where payscheduleperiodid = '477';
select * from pspay_payroll ;
select * from company_parameters where companyparametername = 'PInt'::bpchar ;

   --  JOIN company_parameters cp ON cp.companyparametername = 'PInt'::bpchar and cp.companyparametervalue::text = 'P20'::text