--left join 
(select ppd.personid,sum(etype_hours) AS hours 
             from pay_schedule_period psp 
             join pspay_payment_header pph
               on pph.check_date = psp.periodpaydate
              and pph.payscheduleperiodid = psp.payscheduleperiodid              
             join pspay_payment_detail ppd 
               on ppd.etv_id in (select a.etv_id from pspay_etv_operators a where a.operand = 'WS23' and a.etvindicator = 'E' and group_key <> '$$$$$' group by 1)
              and ppd.personid = pph.personid
              and ppd.check_date = psp.periodpaydate
              and pph.paymentheaderid = ppd.paymentheaderid               
            where psp.payrolltypeid in (1,2)
              and psp.processfinaldate is not null
              and psp.periodpaydate <= ?::date
              and date_part('year',psp.periodpaydate) = date_part('year',?::DATE)
              and ppd.personid = '17436'
            group by 1) -- ytdhrs ON ytdhrs.personid = pe.personid 
            ;

(select ppd.personid, sum(etype_hours) AS hours 
             from pspay_payment_detail ppd
            where ppd.paymentheaderid in 
                  (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                     (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay join edi.edi_last_update elu 
                             on elu.feedid = 'DGH_JH_401K_Export' 
                            and date_part('year',ppay.statusdate) = date_part('year',elu.lastupdatets)
                             where ppay.pspaypayrollstatusid = 4 )))
    and ppd.etv_id in (select a.etv_id from pspay_etv_operators a where a.operand = 'WS23' and a.etvindicator = 'E' and group_key <> '$$$$$' group by 1)   
    and ppd.personid = '17436'                          
group by 1) 
;            

(select personid, paymentheaderid, payscheduleperiodid, payscheduleperiodid from pspay_payment_header where payscheduleperiodid in 
                (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay join edi.edi_last_update elu 
                             on elu.feedid = 'DGH_JH_401K_Export' and date_part('year',ppay.statusdate) = date_part('year',elu.lastupdatets)
                             where ppay.pspaypayrollstatusid = 4 ) ) and personid = '17436' );

(select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay join edi.edi_last_update elu 
                             on elu.feedid = 'DGH_JH_401K_Export' and elu.lastupdatets <= ppay.statusdate
                             where ppay.pspaypayrollstatusid = 4 ) ); 
                             
/*(select pspaypayrollid from pspay_payroll ppay join edi.edi_last_update elu 
                             on elu.feedid = 'DGH_JH_401K_Export' and elu.lastupdatets <= ppay.statusdate
                             where ppay.pspaypayrollstatusid = 4 );  
                             */           

--select * from person_names where personid = '17436';                             
select * from pspay_payment_header where payscheduleperiodid in ('729','730','731','732','733','734','735') and personid = '17436';  ---- payscheduleperiodid in ( '1024','619','590','648','735','677','764','706') are all the psp id's for voided and processed batches
select * from pspay_payment_detail where paymentheaderid in ('692','2072','3554','4839','6285','7725','8960') and personid = '17436' and etv_id in (select a.etv_id from pspay_etv_operators a where a.operand = 'WS23' and a.etvindicator = 'E' and group_key <> '$$$$$' group by 1); ---- paymentheaderid in ('8281','9450','9448','9447','8282') are all the paymentheader id's for voided and processed batches

--select * from pspay_payment_header where personid = '17436';  ---- payscheduleperiodid in ( '1024','619','590','648','735','677','764','706') are all the psp id's for voided and processed batches


(select a.etv_id from pspay_etv_operators a where a.operand = 'WS15' and a.etvindicator = 'E' and group_key <> '$$$$$' group by 1)  
