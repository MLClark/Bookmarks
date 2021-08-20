select etv_id, sum(amount) from payroll.cognos_proposedpayrollregisterearnings where paymentheaderid is null and amount <> 0 group by 1 order by etv_id;
select paycode, sum(amount) from payroll.staged_transaction where paycode in (select etvid as paycode from person_earning_setup group by 1) and amount <> 0 group by 1 order by paycode;

select * from person_names where personid = '49';

select * from payroll.cognos_proposedpayrollregisterearnings where paymentheaderid is null  and etv_id in (select etvid as etv_id from person_earning_setup group by 1) and payscheduleperiodid in 
(select payscheduleperiodid from payroll.staged_transaction where paycode in (select etvid as paycode from person_earning_setup group by 1) and asofdate >= current_date) and personid = '49';

select * from payroll.personperiodpayments  where personid = '49';
                                            
select * from payroll.staged_transaction where paycode in (select etvid as paycode from person_earning_setup group by 1) and asofdate >= current_date and personid = '49' order by paycode, payscheduleperiodid;

( SELECT personid, payscheduleperiodid, asofdate, paycode, units_ytd, amount_ytd, subject_wages_ytd , paymentseq, rank() OVER (PARTITION BY personid, paycode ORDER BY MAX(paymentseq) DESC) as rank
          FROM payroll.staged_transaction where personid = '49' and paycode = 'E01' GROUP BY personid, payscheduleperiodid, asofdate, paycode, units_ytd, amount_ytd, subject_wages_ytd , paymentseq)
          ;
          
select * from payroll.staged_transaction where payscheduleperiodid in 
select * from payroll.personperiodpayments ;