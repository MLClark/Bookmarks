SELECT 
count(*) as record_count  
,sum(pd.employeramt * 100) as total_employeramt
,sum(pd.employeeamt * 100) as total_employeeamt

  FROM (
 	SELECT distinct pd.individual_key
             , pd.check_date
             , coalesce(pd1x.employeramt, 0) as employeramt
             , coalesce(pd2x.employeeamt, 0) as employeeamt
          FROM pspay_payment_detail pd
        LEFT JOIN (select individual_key, sum(coalesce(etv_amount,0)) as employeramt from pspay_payment_detail pd1
                       where pd1.check_date = ?::date
                         AND pd1.etv_id             = 'VEK' 
                   group by individual_key ) pd1x on pd1x.individual_key = pd.individual_key              

--JT Add employee catchup amount in VEJ
        LEFT JOIN (select individual_key, sum(coalesce(etv_amount,0)) as employeeamt from pspay_payment_detail pd2
                       where pd2.check_date = ?::date
                         AND pd2.etv_id            in ('VEH', 'VEJ') 
--                         AND pd2.etv_id             = 'VEH' 
                       group by individual_key ) pd2x on pd2x.individual_key = pd.individual_key              
       --WHERE pd.check_date = (select max(check_date) from pspay_payment_detail)
       WHERE pd.check_date = ?::date
           AND pd.etv_id IN ('VEH','VEK', 'VEJ') 
--           AND pd.etv_id IN ('VEH','VEK') 
  ) pd
  LEFT JOIN person_identity pi
    ON pi.identity     = pd.individual_key
   AND pi.identitytype = 'PSPID'
   AND now() between pi.createts and pi.endts
  LEFT JOIN person_identity pis
    ON pis.personid     = pi.personid
   AND pis.identitytype = 'SSN'
   AND now() between pis.createts and pis.endts
  LEFT JOIN person_names pn 
    ON pn.personid = pi.personid
   AND now() between pn.effectivedate and pn.enddate
   AND now() between pn.createts      and pn.endts
   AND nametype = 'Legal'
  LEFT JOIN person_payroll pp
    ON pp.personid = pi.personid
   AND now()      between pp.effectivedate AND pp.enddate
   AND now() between pp.createts      AND pp.endts
  LEFT JOIN pay_unit pu 
    ON pu.payunitid = pp.payunitid


;
