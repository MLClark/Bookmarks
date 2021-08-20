
--left join 
(select ppd.personid, sum(etype_hours) AS hours 
             from pspay_payment_detail ppd
            where ppd.paymentheaderid in 
                  (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                     (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay join edi.edi_last_update elu 
                             on elu.feedid = 'CDE_Principal_Financial_Group_401k_Export' 
                            and date_part('year',ppay.statusdate) = date_part('year',elu.lastupdatets)
                             where ppay.pspaypayrollstatusid = 4 )))
    and ppd.etv_id in (select a.etv_id from pspay_etv_operators a where a.operand IN ('WS23','WS15') and a.etvindicator = 'E' and group_key <> '$$$$$' group by 1)   
    and ppd.personid = '361'   
group by 1) --ytd on ytd.personid = pe.personid 
;

(select personid, paymentheaderid, payscheduleperiodid, payscheduleperiodid from pspay_payment_header where payscheduleperiodid in 
                (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay join edi.edi_last_update elu 
                             on elu.feedid = 'CDE_Principal_Financial_Group_401k_Export' and date_part('year',ppay.statusdate) = date_part('year',elu.lastupdatets)
                             where ppay.pspaypayrollstatusid = 4 ) ) and personid = '361' );

(select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay join edi.edi_last_update elu 
                             on elu.feedid = 'CDE_Principal_Financial_Group_401k_Export' and elu.lastupdatets <= ppay.statusdate
                             where ppay.pspaypayrollstatusid = 4 ) ); 
                             
(select pspaypayrollid from pspay_payroll ppay join edi.edi_last_update elu 
                             on elu.feedid = 'CDE_Principal_Financial_Group_401k_Export' and elu.lastupdatets <= ppay.statusdate
                             where ppay.pspaypayrollstatusid = 4 );  

select * from pspay_payment_header where payscheduleperiodid in ('1121','1122','1123','1124','1125','1127','1222') and personid = '361';  ---- payscheduleperiodid in ( '1024','619','590','648','735','677','764','706') are all the psp id's for voided and processed batches
select * from pspay_payment_detail where paymentheaderid in ('19803','21596','21989','22278','22594','23186','23484') and personid = '361' and etv_id in (select a.etv_id from pspay_etv_operators a where a.operand IN ('WS15','WS23') and a.etvindicator = 'E' and group_key <> '$$$$$' group by 1); ---- paymentheaderid in ('8281','9450','9448','9447','8282') are all the paymentheader id's for voided and processed batches
                             