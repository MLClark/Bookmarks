(SELECT *    FROM pspay_payment_detail  
             LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'HMN_PS_CogDetGet_Export'          
            WHERE etv_id in ('EBD','E01','E64','EB5','E05','EB8','E15','E16','E17','E18','E19','E20','ECA','EAJ','EAR','EB4','EAK','ECH','E27','ECJ') --3/16/2020 added last 3 etv codes for pto  
              AND date_part('year', check_date) = date_part('year',elu.lastupdatets::DATE) ---- 1/4/2019 changed current_date to elu.lastupdatets::DATE
              and check_date <= elu.lastupdatets::DATE 

          ) 



select * from position_desc;

select * from edi.edi_last_update where feedid = 'HMN_PS_CogDetGet_Export';
update edi.edi_last_update set lastupdatets = '2020-03-31 23:59:59' where feedid = 'HMN_PS_CogDetGet_Export'; -----2020-03-31 23:59:59
select * from edt_code_descs;
      (select individual_key, etv_id, sum(etv_amount) as etv_amount
         from pspay_payment_detail 
         LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'HMN_PS_CogDetGet_Export'
        where etv_id = 'VCJ'
          AND date_part('year',check_date) = date_part('year',elu.lastupdatets)
          and date_part('month',check_date) = date_part('month',elu.lastupdatets)
          group by 1,2
      ) 
      
      select * from pspay_etv_list where etv_id in ('VCJ','VCH','V27');
select * from pspay_group_deductions where etv_id  in ('VCJ','VCH','V27');
select * from pspay_payment_detail where etv_id in ('ECJ','ECH','E27') and personid = '63041' and check_date::date = '2020-02-28';


(SELECT personid, 'Y' as eligible_flag,coalesce(sum(etv_amount),0) as taxable_wage
             FROM pspay_payment_detail  
             LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'HMN_PS_CogDetGet_Export'          
            WHERE etv_id in --('E01','E64','EB5','E05','EB8','E15','E16','E17','E18','E19','E20','ECA','EAJ','EAR','EB4','EAK','ECH','E27','ECJ') --3/16/2020 added 3 etv codes for pto
             ('ECH','E27','ECJ')
              AND date_part('year', check_date) = date_part('year',elu.lastupdatets::DATE) ---- 1/4/2019 changed current_date to elu.lastupdatets::DATE
              and check_date <= elu.lastupdatets::DATE and personid = '63041'
         GROUP BY personid,eligible_flag order by personid
          );
          
select * from person_employment where personid = '68694';          