--- YTD COMP
(SELECT personid,'Y' as eligible_flag, paymentheaderid, check_date, coalesce(sum(etv_amount),0) as taxable_wage
             FROM pspay_payment_detail    
             LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'HMN_PS_CogDetGet_Export'        
            WHERE etv_id in ('EBD','E01','E64','EB5','E05','EB8','E15','E16','E17','E18','E19','E20','ECA','EAJ','EAR','EB4','EAK','ECH','E27','ECJ') --3/16/2020 added 3 etv codes for pto          
              AND date_part('year', check_date) = date_part('year',elu.lastupdatets::DATE) ---- 1/4/2019 changed current_date to elu.lastupdatets::DATE
              and check_date <= elu.lastupdatets::DATE and paymentheaderid = '106240'
         GROUP BY personid,eligible_flag,paymentheaderid,check_date
          ); 

select * from pspay_payment_detail where paymentheaderid = '106240';                               
select * from pspay_payment_header where paymentheaderid = '106240';
select * from pspay_payroll_pay_sch_periods where payscheduleperiodid = '122';
select * from pspay_payroll where pspaypayrollid = '84';

select * from person_names where personid = '64640';
select * from person_employment where personid = '66583' and effectivedate < enddate and current_timestamp between createts and endts;
select * from log_entries where transactionstart between  '2020-09-09 11:00:44' and '2020-09-09 11:56:33' and subjectkey = '66583';

(SELECT personid,'Y' as eligible_flag,coalesce(sum(etv_amount),0) as taxable_wage   from pspay_payment_detail ppd 
   join edi.edi_last_update elu on elu.feedid = 'HMN_PS_CogDetGet_Export' AND date_part('year', check_date) = date_part('year',elu.lastupdatets::DATE) and check_date <= elu.lastupdatets::DATE 
   where paymentheaderid in 
        (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay
                             where ppay.pspaypayrollstatusid = 4 )))  and ppd.etv_id  in  ('EBD','E01','E64','EB5','E05','EB8','E15','E16','E17','E18','E19','E20','ECA','EAJ','EAR','EB4','EAK','ECH','E27','ECJ') --3/16/2020 added last 3 etv codes for pto  
                             group by personid, eligible_flag)  
;      

select * from person_names where lname like 'Goen%';
(select personid, positionid, scheduledhours, schedulefrequency, max(effectivedate) as effectivedate, RANK() OVER (PARTITION BY personid ORDER BY max(effectivedate) DESC) AS RANK
              from pers_pos where effectivedate < enddate and current_timestamp between createts and endts and personid = '68346'
             group by personid, positionid, scheduledhours, schedulefrequency) 
             ; -- pp
select * from pers_pos where personid = '68346';             

(select personid, positionid, scheduledhours, schedulefrequency, perspospid, max(effectivedate) as effectivedate, RANK() OVER (PARTITION BY personid ORDER BY max(effectivedate) DESC) AS RANK
              from pers_pos where current_timestamp between createts and endts and personid = '68346'
             group by personid, positionid, scheduledhours, schedulefrequency, perspospid) 


select * from edi.edi_last_update;
update edi.edi_last_update set lastupdatets = '2020-02-29 22:59:59' where feedid = 'HMN_PS_CogDetGet_Export_MLC';

select * from pspay_payment_detail where personid = '63041' and etv_id in ('EBD','E01','E64','EB5','E05','EB8','E15','E16','E17','E18','E19','E20','ECA','EAJ','EAR','EB4','EAK','ECH','E27','ECJ') and date_part('year',check_date)='2020';


(select personid, 'Y' as eligible_flag, coalesce(sum(etv_amount),0) as taxable_wage      
   from pspay_payment_detail ppd 
   join edi.edi_last_update elu on elu.feedid = 'HMN_PS_CogDetGet_Export_MLC'
   where personid = '63041' and paymentheaderid in 
        (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay
                             where ppay.pspaypayrollstatusid = 4 )))  and ppd.etv_id  in  ('EBD','E01','E64','EB5','E05','EB8','E15','E16','E17','E18','E19','E20','ECA','EAJ','EAR','EB4','EAK','ECH','E27','ECJ') --3/16/2020 added last 3 etv codes for pto  
                               AND date_part('year', check_date) = date_part('year',elu.lastupdatets::DATE) 
                             group by personid, eligible_flag)    ;

(SELECT personid
                  ,'Y' as eligible_flag 
                 ,coalesce(sum(etv_amount),0) as taxable_wage
             FROM pspay_payment_detail    
             LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'HMN_PS_CogDetGet_Export_MLC'        
            WHERE personid = '63041' and etv_id in ('EBD','E01','E64','EB5','E05','EB8','E15','E16','E17','E18','E19','E20','ECA','EAJ','EAR','EB4','EAK','ECH','E27','ECJ') --3/16/2020 added 3 etv codes for pto          
              AND date_part('year', check_date) = date_part('year',elu.lastupdatets::DATE) ---- 1/4/2019 changed current_date to elu.lastupdatets::DATE
              and check_date <= elu.lastupdatets::DATE 
         GROUP BY personid,eligible_flag
          )          ;                   