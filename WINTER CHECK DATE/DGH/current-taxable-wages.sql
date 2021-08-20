--left join 
(select ppd.personid, sum(ppd.etv_amount) AS taxable_amount
             from pspay_payment_detail ppd
            where ppd.paymentheaderid in 
                  (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                     (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay join edi.edi_last_update elu 
                             on elu.feedid = 'DGH_JH_401K_Export' and elu.lastupdatets <= ppay.statusdate
                             where ppay.pspaypayrollstatusid = 4 )))
    and ppd.etv_id in (select a.etv_id from pspay_etv_operators a where a.operand = 'WS15' and a.etvindicator = 'E' and group_key <> '$$$$$' group by 1)   
    and ppd.personid = '18064'                          
group by 1)  --cur ON cur.personid = pe.personid 
;

select * from pspay_payment_header where payscheduleperiodid in ('1024','1037','590','619','648','677','706','735','764') and personid = '18064';  ---- payscheduleperiodid in ( '1024','619','590','648','735','677','764','706') are all the psp id's for voided and processed batches
select * from pspay_payment_detail where paymentheaderid in ('8977') and etv_id in (select a.etv_id from pspay_etv_operators a where a.operand = 'WS15' and a.etvindicator = 'E' and group_key <> '$$$$$' group by 1); ---- paymentheaderid in ('8281','9450','9448','9447','8282') are all the paymentheader id's for voided and processed batches

select * from pspay_payment_header where personid = '18064';  ---- payscheduleperiodid in ( '1024','619','590','648','735','677','764','706') are all the psp id's for voided and processed batches


select * from person_names where personid = '18064';
select * from pspay_payment_header where payscheduleperiodid in ('1024','1037','590','619','648','677','706','735','764') and personid = '18064';  ---- payscheduleperiodid in ( '1024','619','590','648','735','677','764','706') are all the psp id's for voided and processed batches
select * from pspay_payment_detail where paymentheaderid in ('8977') and etv_id in (select a.etv_id from pspay_etv_operators a where a.operand = 'WS15' and a.etvindicator = 'E' and group_key <> '$$$$$' group by 1); ---- paymentheaderid in ('8281','9450','9448','9447','8282') are all the paymentheader id's for voided and processed batches

select * from pspay_payroll_pay_sch_periods where pspaypayrollid in ('16', '14','15'); -- valid pspaypayrollid's for lastupdatets = '2019-03-19 16:01:50' 

 (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay join edi.edi_last_update elu 
                             on elu.feedid = 'DGH_JH_401K_Export' and elu.lastupdatets <= ppay.statusdate
                             where ppay.pspaypayrollstatusid = 4 ) ) );

(select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay join edi.edi_last_update elu 
                             on elu.feedid = 'DGH_JH_401K_Export' and elu.lastupdatets <= ppay.statusdate
                             where ppay.pspaypayrollstatusid = 4 ) ); 
                             
(select pspaypayrollid from pspay_payroll ppay join edi.edi_last_update elu 
                             on elu.feedid = 'DGH_JH_401K_Export' and elu.lastupdatets <= ppay.statusdate
                             where ppay.pspaypayrollstatusid = 4 ); 