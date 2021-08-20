select * from person_names where lname like 'Gaither%';
select * from person_identity where personid = '703';
select * from pspay_earning_accumulators where individual_key = 'AMJ00000001252';

SELECT individual_key
                 --,sum(etype_hours) AS ytdhours
                 ,sum(etv_amount) as taxable_wage
             FROM pspay_payment_detail            
             -- Hours include Reg,OT,DT,PTO,Jury,Bereavement - exclude reg shift and OT shift
             -- 6/16 feedback need holiday pay included in ytd totals adding ECZ, EC8, E17
            WHERE etv_id in  ('E01','E02','E03','E15','E19','E18','E08', 'E61','E05')           
              --AND date_part('year', check_date) = date_part('year',now())
              AND check_date <= ?::DATE
              and individual_key = 'AMJ00000001252'
         GROUP BY individual_key
         ;
select * from pspay_payment_detail where personid = '703' and date_part('year',check_date) = '2017' and date_part('month',check_date) = '12'
and etv_id in  ('E01','E02','E03','E15','E19','E18','E08', 'E61','E05') ;         
select * from pspay_payment_detail where personid = '703' and check_date::date = '2017-12-29' and etv_id in  ('E01','E02','E03','E15','E19','E18','E08', 'E61','E05') ;
select * from pspay_payment_detail where personid = '703' and check_date::date = '2017-12-29' and etv_id in  ('VB1','VB2','VB3','VB4','VB5','V25','V65', 'VCQ');
select * from pspay_etv_list where etv_id in ('TB1','TB2');

select * from pspay_payment_detail where personid = '1936' and check_date = '2019-02-08' and etv_id in  ('VB1','VB2','VB3','VB4','VB5','V25','V65', 'VCQ');
