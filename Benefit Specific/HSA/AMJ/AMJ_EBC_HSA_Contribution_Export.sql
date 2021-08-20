SELECT 
 'PeopleStrategy' ::varchar(50) as PartnerID
,UPPER(pn.lname) ::varchar(50) as LastName
,UPPER(pn.title) ::varchar(50) as Suffix
,UPPER(pn.fname) ::varchar(50) as FirstName
,UPPER(pn.mname) ::varchar(50) as MI
,pis.identity as SSN
,'C98599_HSA' ::varchar(25) as GroupID
,to_char(pd.check_date,'YYYY-MM-DD') as PayrollDate
,'1' ::char(1) as DepositType   
,cast(round((pd.employeeamt ) ,2 )as dec) as EEContribution
,cast(round((pd.employeramt ) ,2 )as dec) as ERContribution
,trailer.record_count
,cast(round((trailer.total_employeeamt) ,2 )as dec) as total_employeeamt
,cast(round((trailer.total_employeramt) ,2 )as dec) as total_employeramt


  FROM (
 	SELECT distinct pd.individual_key
             , pd.check_date
             , coalesce(pd1x.employeramt, 0) as employeramt
             , coalesce(pd2x.employeeamt, 0) as employeeamt
          FROM pspay_payment_detail pd
        LEFT JOIN (select individual_key, sum(coalesce(etv_amount,0)) as employeramt 
                       from pspay_payment_detail pd1
                       where pd1.check_date = ?::date
                         AND pd1.etv_id = 'VEK' 
                   group by individual_key ) pd1x on pd1x.individual_key = pd.individual_key              
        LEFT JOIN (select individual_key, sum(coalesce(etv_amount,0)) as employeeamt 
                        from pspay_payment_detail pd2
                       where pd2.check_date = ?::date
                         AND pd2.etv_id in ('VEH','VEJ') 
                       group by individual_key ) pd2x on pd2x.individual_key = pd.individual_key              
       WHERE pd.check_date = ?::date
           AND pd.etv_id IN ('VEH','VEK','VEJ') 
  ) pd
  LEFT JOIN person_identity pi
    ON pi.identity     = pd.individual_key
   AND pi.identitytype = 'PSPID'
   AND CURRENT_TIMESTAMP BETWEEN pi.createts and pi.endts
  LEFT JOIN person_identity pis
    ON pis.personid     = pi.personid
   AND pis.identitytype = 'SSN'
   AND CURRENT_TIMESTAMP BETWEEN pis.createts and pis.endts
  LEFT JOIN person_names pn 
    ON pn.personid = pi.personid
   AND CURRENT_DATE BETWEEN pn.effectivedate and pn.enddate
   AND CURRENT_TIMESTAMP BETWEEN pn.createts and pn.endts
   AND nametype = 'Legal'
  LEFT JOIN person_payroll pp
    ON pp.personid = pi.personid
   AND CURRENT_DATE BETWEEN pp.effectivedate AND pp.enddate
   AND CURRENT_TIMESTAMP BETWEEN pp.createts AND pp.endts
  LEFT JOIN pay_unit pu 
    ON pu.payunitid = pp.payunitid
    
  cross join 
  (
  SELECT 
count(*) as record_count  
,sum(pd.employeramt ) as total_employeramt
,sum(pd.employeeamt ) as total_employeeamt

  FROM (
 	SELECT distinct pd.individual_key
             , pd.check_date
             , coalesce(pd1x.employeramt, 0) as employeramt
             , coalesce(pd2x.employeeamt, 0) as employeeamt
          FROM pspay_payment_detail pd
        LEFT JOIN (select individual_key, sum(coalesce(etv_amount,0)) as employeramt 
                        from pspay_payment_detail pd1
                       where pd1.check_date = ?::date
                         AND pd1.etv_id = 'VEK' 
                   group by individual_key ) pd1x on pd1x.individual_key = pd.individual_key              
        LEFT JOIN (select individual_key, sum(coalesce(etv_amount,0)) as employeeamt 
                        from pspay_payment_detail pd2
                       where pd2.check_date = ?::date
                         AND pd2.etv_id in ('VEH','VEJ') 
                       group by individual_key ) pd2x on pd2x.individual_key = pd.individual_key              
       WHERE pd.check_date = ?::date
           AND pd.etv_id IN ('VEH','VEK','VEJ') 
  ) pd
  LEFT JOIN person_identity pi
    ON pi.identity     = pd.individual_key
   AND pi.identitytype = 'PSPID'
   AND CURRENT_TIMESTAMP BETWEEN pi.createts and pi.endts
  LEFT JOIN person_identity pis
    ON pis.personid     = pi.personid
   AND pis.identitytype = 'SSN'
   AND CURRENT_TIMESTAMP BETWEEN pis.createts and pis.endts
  LEFT JOIN person_names pn 
    ON pn.personid = pi.personid
   AND CURRENT_DATE BETWEEN pn.effectivedate and pn.enddate
   AND CURRENT_TIMESTAMP BETWEEN pn.createts and pn.endts
   AND nametype = 'Legal'
  LEFT JOIN person_payroll pp
    ON pp.personid = pi.personid
   AND CURRENT_DATE BETWEEN pp.effectivedate AND pp.enddate
   AND CURRENT_TIMESTAMP BETWEEN pp.createts AND pp.endts
  LEFT JOIN pay_unit pu 
    ON pu.payunitid = pp.payunitid
   ) as trailer    

ORDER BY 3,5
;
