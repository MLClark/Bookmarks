select distinct
 pi.personid
,pi.identity ::char(11) as ssn
,RTrim(Coalesce(pn.lname || ' ','') || Coalesce(pn.fname || ' ', '')|| Coalesce(pn.mname || ' ', ''))::char(60) as emp_name
,hsa.check_date
,hsa.amount
from person_identity pi

join person_names pn
  on pn.personid = pi.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts

LEFT JOIN (SELECT personid
                 ,etv_id
                 ,check_date
                 ,etv_amount as amount
             FROM pspay_payment_detail            
            WHERE etv_id in  ('VEK','VEJ','VEH')           
              AND date_part('year',check_date) = '2018'              
         
          ) hsa
  ON hsa.personid = pi.personid         

 
 
 where pi.identitytype = 'SSN'
   and current_timestamp between pi.createts and pi.endts

group by 1,2,3,4,5
having hsa.amount < 0   
 