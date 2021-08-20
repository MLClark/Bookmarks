
select * from payroll.pay_codes where (paycodetypeid = ANY (ARRAY[3, 5, 6])) and paycode not in (select paycode from payroll.cognos_payrollregisterdeductions_mv ) ;
select * from payroll.pay_codes where (paycodetypeid = ANY (ARRAY[4, 8, 9])) and paycode not in (select paycode from payroll.cognos_payrollregistertaxes_mv )   ; 
     
select * from payroll.pay_codes where (paycodetypeid = ANY (ARRAY[1, 2, 7, 10])) and paycode not in (select paycode from payroll.cognos_pspaypayrollregisterearnings_mv )   ; 
select * from payroll.payment_detail where paycode in (select paycode from payroll.pay_codes where (paycodetypeid = ANY (ARRAY[1, 2, 7])) and paycode not in (select paycode from payroll.cognos_pspaypayrollregisterearnings_mv ));
select * from payroll.pay_code_types;
--10 needs to be added to proposed verify proposed paycodetypeid

select * from payroll.pay_codes where (paycodetypeid = ANY (ARRAY[1, 2, 7 ,10])) and paycode not in (select paycode from payroll.cognos_pspaypayrollregisterearnings_mv )   ; 

select * from payroll.payment_detail where paycode in (select paycode from payroll.pay_codes where (paycodetypeid = ANY (ARRAY[1, 2, 7])) and paycode not in (select paycode from payroll.cognos_pspaypayrollregisterearnings_mv ));

     select * from person_earning_setup where etvid = 'EBO';
     select * from payroll.payment_detail where paycode = 'EBO';
     select * from pay_schedule_period where payscheduleperiodid in (select payscheduleperiodid from payroll.payment_header where paymentheaderid in (select paymentheaderid from payroll.payment_detail where paycode = 'EBO'));
     select * from pspay_payroll_pay_sch_periods where payscheduleperiodid in (select payscheduleperiodid from pay_schedule_period where payscheduleperiodid in  (select payscheduleperiodid from payroll.payment_header where paymentheaderid in (select paymentheaderid from payroll.payment_detail where paycode = 'EBO')));
     
     select * from person_names where personid in ('1451');