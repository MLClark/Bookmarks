SELECT DISTINCT
  '500112-01'                         AS "Plan Number"
, epi.employeessn                     AS "Employee SSN"
, ' '                                 AS "Division Number"
, epi.lastname                        AS "Last Name"
, epi.firstname                       AS "First Name"
, epi.middlename                      AS "Middle Name"
, ' '                                 AS "Name Suffix"
, to_char(epi.birthdate,'MM/dd/YYYY') AS "Birth Date"
, epi.gendercode                      AS "Gender"
, epi.maritalstatus                   AS "Marital Status"
, epi.streetaddress1                  AS "Address Line 1"
, epi.streetaddress2                  AS "Address Line 2"
, epi.city                            AS "City"
, epi.statecode                       AS "State"
, epi.zipcode                         AS "Zip Code"
, epi.homephone                       AS "Home Phone"
, epi.workphone                       AS "Work Phone"
, ' '                                 AS "Work Phone Ext"
, ' '                                 AS "Country Code"
, to_char(eed.emplhiredate,'MM/dd/YYYY') AS "Hire Date"
, CASE eed.emplstatus
    WHEN 'T' THEN to_char(eed.empleffectivedate,'MM/dd/YYYY')
    ELSE NULL
  END                                 AS "Termination Date"
, CASE 
    WHEN eed.empllasthiredate > eed.emplhiredate THEN
       to_char(eed.empllasthiredate,'MM/dd/YYYY')
    ELSE null
  END AS "Re-Hire Date"
, to_char(ppd.check_date,'MM/dd/YYYY') AS "Ending Paryoll Date"
, COALESCE(ppdvb1.etv_amount,0) + COALESCE(ppdvb2.etv_amount,0) AS "Employee Before Tax Contribution (BTK1)"
, COALESCE(ppdvb3.etv_amount,0) + COALESCE(ppdvb4.etv_amount,0) AS "Employee Roth Contribution (RTH1)"
, COALESCE(ppdvb5.etv_amount,0)       AS "Employer Match Amount (ERM1)"
, COALESCE(ppdv65.etv_amount,0)       AS "Loan Repayment Amount (LON1)"
, COALESCE(ppdvcq.etv_amount,0)       AS "Loan Repayment Amount (LON2)"
, ''                                  AS "Contribution Amount 5"
, ''                                  AS "Contribution Amount 6"
, ''                                  AS "Contribution Amount 7"
, ''                                  AS "Contribution Amount 8"
, hw.ytdhours                      AS "YTD Hours"
, ''                                  AS "YTD Total Compensation"
, ''                                  AS "YTD Plan Compensation"
, ''                                  AS "YTD Pre Entry Compensation"
, ''                                  AS "Highly Comp Employee Code"
, ''                                  AS "Percent of Ownership"
, ''                                  AS "Officer Determination"
, ''                                  AS "Participation Date"
, ''                                  AS "Eligibility Code"
, pc.compamount                       AS "Salary Amount"
, pc.frequencycode                    AS "Salary Amount Qualifier"
, ''                                  AS "Termination Reason Code"
, ''                                  AS "Sarbanes Oxly Reporting Indicator"
, ''                                  AS "Federal Exemptions"
, ''                                  AS "Employer Assigned ID"
, ''                                  AS "Compliance Status Code"



FROM (SELECT DISTINCT individual_key 
                     ,check_date 
                     ,check_number
                     ,payment_number
                     ,etv_code  
        FROM pspay_payment_detail
       WHERE etv_id IN ('VB1','VB2','VB3','VB4','VB5','V25','V65', 'VCQ')
         AND check_date = ?
     ) ppd

LEFT JOIN (SELECT individual_key
                 ,sum(etype_hours) AS ytdhours
             FROM pspay_payment_detail            
            WHERE etv_id like 'E%'
              AND date_part('year', check_date) = date_part('year',now())
         GROUP BY individual_key
          ) hw
  ON hw.individual_key = ppd.individual_key

LEFT JOIN pspay_payment_detail ppdvb1
  ON ppdvb1.individual_key  = ppd.individual_key
 AND ppdvb1.check_date      = ppd.check_date
 AND ppdvb1.check_number    = ppd.check_number
 AND ppdvb1.payment_number  = ppd.payment_number
 AND ppdvb1.etv_code        = ppd.etv_code
 AND ppdvb1.etv_id          = 'VB1'

LEFT JOIN pspay_payment_detail ppdvb2
  ON ppdvb2.individual_key  = ppd.individual_key
 AND ppdvb2.check_date      = ppd.check_date
 AND ppdvb2.check_number    = ppd.check_number
 AND ppdvb2.payment_number  = ppd.payment_number
 AND ppdvb2.etv_code        = ppd.etv_code
 AND ppdvb2.etv_id          = 'VB2'

LEFT JOIN pspay_payment_detail ppdvb3
  ON ppdvb3.individual_key  = ppd.individual_key
 AND ppdvb3.check_date      = ppd.check_date
 AND ppdvb3.check_number    = ppd.check_number
 AND ppdvb3.payment_number  = ppd.payment_number
 AND ppdvb3.etv_code        = ppd.etv_code
 AND ppdvb3.etv_id          = 'VB3'

LEFT JOIN pspay_payment_detail ppdvb4
  ON ppdvb4.individual_key  = ppd.individual_key
 AND ppdvb4.check_date      = ppd.check_date
 AND ppdvb4.check_number    = ppd.check_number
 AND ppdvb4.payment_number  = ppd.payment_number
 AND ppdvb4.etv_code        = ppd.etv_code
 AND ppdvb4.etv_id          = 'VB4' 

LEFT JOIN pspay_payment_detail ppdvb5
  ON ppdvb5.individual_key  = ppd.individual_key
 AND ppdvb5.check_date      = ppd.check_date
 AND ppdvb5.check_number    = ppd.check_number
 AND ppdvb5.payment_number  = ppd.payment_number
 AND ppdvb5.etv_code        = ppd.etv_code
 AND ppdvb5.etv_id          = 'VB5' 

LEFT JOIN pspay_payment_detail ppdv25
  ON ppdv25.individual_key  = ppd.individual_key
 AND ppdv25.check_date      = ppd.check_date
 AND ppdv25.check_number    = ppd.check_number
 AND ppdv25.payment_number  = ppd.payment_number
 AND ppdv25.etv_code        = ppd.etv_code
 AND ppdv25.etv_id          = 'V25' 

LEFT JOIN pspay_payment_detail ppdv65
  ON ppdv65.individual_key  = ppd.individual_key
 AND ppdv65.check_date      = ppd.check_date
 AND ppdv65.check_number    = ppd.check_number
 AND ppdv65.payment_number  = ppd.payment_number
 AND ppdv65.etv_code        = ppd.etv_code
 AND ppdv65.etv_id          = 'V65'  

LEFT JOIN pspay_payment_detail ppdvcq
  ON ppdvcq.individual_key  = ppd.individual_key
 AND ppdvcq.check_date      = ppd.check_date
 AND ppdvcq.check_number    = ppd.check_number
 AND ppdvcq.payment_number  = ppd.payment_number
 AND ppdvcq.etv_code        = ppd.etv_code
 AND ppdvcq.etv_id          = 'VCQ'   

JOIN edi.etl_personal_info epi 
  ON epi.trankey = ppd.individual_key

JOIN edi.etl_employment_data eed
  ON eed.personid = epi.personid

LEFT JOIN person_compensation pc 
  ON pc.personid = epi.personid
 AND pc.earningscode <> 'BenBase'
 AND current_timestamp between pc.createts and pc.endts
 AND pc.effectivedate < pc.enddate
 AND ( (current_date between pc.effectivedate AND pc.enddate)
         OR
       ( pc.enddate = (SELECT MAX(pcm.enddate)
                         FROM person_compensation pcm
                        WHERE pcm.personid = pc.personid
                          AND pcm.earningscode <> 'BenBase')
     ))
  
--JOIN pspay_payment_header pph on epi.trankey = pph.individual_key
--     and pph.check_date = ppd.check_date
--     AND (pph.check_date, pph.last_updt_dt) = (select max(p2.check_date), max(p2.last_updt_dt)
--               from pspay_payment_header p2
--               where p2.individual_key = pph.individual_key
--               group by p2.individual_key)
--LEFT JOIN person_payroll pp ON epi.personid = pp.personid
--     AND current_date between pp.effectivedate and pp.enddate
--     AND current_timestamp between pp.createts and pp.endts
--LEFT JOIN pay_unit pu ON pu.payunitid = pp.payunitid
--     AND current_date between pp.effectivedate and pp.enddate
--     AND current_timestamp between pp.createts and pp.endts
--LEFT JOIN pspay_etv_list pel on ppd.etv_id = pel.etv_id
--            and pel.group_key = ppd.group_key   
            
--LEFT JOIN edi.edi_import_tracking eit ON epi.personid = eit.personid
--	and eit.feedid = 'BA3LM_ImportBilling'
--	AND responsesentts is null

--left join pspay_input_transaction pit on pit.individual_key = pph.individual_key
--			and pit.effectivedate between pph.period_begin_date and pph.period_end_date
--			and substring(pit.primary_key_idd_name from 3 for 2) = 'CO'
  
ORDER BY 1,2
