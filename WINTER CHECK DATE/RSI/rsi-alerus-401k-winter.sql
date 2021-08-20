SELECT distinct  
pi.personid,
pi2.identity :: char(9) as emp_ssn,
pph.payscheduleperiodid,
rtrim(Coalesce(pn.lname || '','') ||','||' '|| Coalesce(pn.fname || ' ', '')|| Coalesce(pn.mname || ' ', ''))::char(30) as emp_name,
rtrim(ltrim(pa.streetaddress)) :: char(40) as emp_address1,
rtrim(ltrim(pa.streetaddress2)) :: char(40) as emp_address2,
rtrim(ltrim(pa.city)) ::char(28) as emp_city,
rtrim(ltrim(pa.stateprovincecode)) ::char(3) as emp_state,
rpad(replace(pa.postalcode,'-',''),9,'0')  :: char(9) as emp_zip,
null::char(4) as division,
case when pe.emplclass = 'F' then '1'
     when pe.emplclass = 'P' then '2'
     when pe.emplclass = 'PU' then 'pu'
     end :: char(1) as employee_type,
to_char(pv.birthdate, 'mm/dd/yyyy')::char(10) as emp_dob,
to_char(pe.emplhiredate,'mm/dd/yyyy') ::char(10) as orig_hire_date,
null::char(10) as eligibility_date,
to_char(pe.empllasthiredate,'MM/DD/YYYY') ::char(10) as rehire_date,
case when pe.emplstatus = 'T' then to_char(pe.effectivedate,'mm/dd/yyyy')else null end  ::char(10) as termdate,
paytodate_hours.pay_hours ::char(8) as pay_period_hours,
--pph.gross_pay ::char(15) as pay_period_gro_pay,
paytodate_gross.gross_pay as  pay_period_gro_pay,
null::char(15) as pay_period_excluded,
case when pc.frequencycode = 'A' then pc.compamount
      when pc.frequencycode = 'H' then (pc.compamount * 2080 ) end::char(15) as annualsalary,
ppdvb1.etv_amount+ppdvb2.etv_amount as ee_def,
ppdvb3.etv_amount::char(10) as ee_roth_def,
null::char(10) as pay_period_after_tax,
ppdvb5.etv_amount::char(10) as er_match,
null::char(10) as er_discre_amount,
null::char(10) as safe_h_profit_shar,
null::char(10) as safe_h_match,   
null::char(10) as pension,
null::char(3) as loan_num,
ppdv65.etv_amount::char(10) as cur_pay_loan_payment,
CASE WHEN pu.frequencycode = 'S' then '5'
     WHEN pu.frequencycode = 'B' then '6'
     WHEN pu.frequencycode = 'M' then '4'
     WHEN pu.frequencycode = 'W' then '7' else null end ::char(1) as payroll_freq_code,
pu.payunitxid::char(2) as  payunitxid  

from person_identity pi

LEFT JOIN person_identity pi2 
  ON pi2.personid = pi.personid
 AND pi2.identitytype = 'SSN' ::bpchar 
 AND CURRENT_TIMESTAMP BETWEEN pi2.createts and pi2.endts 

LEFT JOIN person_names pn 
  ON pn.personid = pi.personid 
 AND pn.nametype = 'Legal'::bpchar 
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts

LEFT JOIN person_address pa 
  ON pa.personid = pi.personid 
 AND pa.addresstype = 'Res'::bpchar 
 and current_date between pa.effectivedate and pa.enddate
 and current_timestamp between pa.createts and pa.endts

join person_employment pe 
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts 
 AND pe.effectivedate - interval '1 day' <> pe.enddate

LEFT JOIN person_vitals pv 
  ON pv.personid = pi.personid 
 and current_date between pv.effectivedate and pv.enddate
 and current_timestamp between pv.createts and pv.endts 

join person_identity piP 
  on piP.personid = pi.personid
 and piP.identitytype = 'PSPID'  
 and current_timestamp between piP.createts and piP.endts

join pay_schedule_period psp 
  on psp.payrolltypeid = 1
 and psp.processfinaldate is not null
 and psp.periodpaydate = ?::date

join pspay_payment_header pph
  on pph.check_date = psp.periodpaydate
 and pph.payscheduleperiodid = psp.payscheduleperiodid  

join pspay_payment_detail ppd
  on ppd.etv_id IN ('VB1','VB2','VB3','VB5','V65')
 and ppd.personid = pi.personid
 and ppd.check_date = psp.periodpaydate
 and pph.paymentheaderid = ppd.paymentheaderid
 
left join person_compensation pc
  on pc.personid = pi.personid 
 and current_date between pc.effectivedate and pc.enddate
 and current_timestamp between pc.createts and pc.endts

LEFT JOIN (SELECT personid
                 ,sum(etype_hours) AS pay_hours
              
             FROM pspay_payment_detail            
           
            WHERE etv_id in  ('E01','E02','E15','E16','E17')           
              --AND date_part('year', check_date) = date_part('year',current_date)
              AND check_date = ? --'2017-02-06'::DATE
         GROUP BY personid
          ) paytodate_hours
  ON paytodate_hours.personid = ppd.personid

left join (select personid, sum(gross_pay) as gross_pay
             from pspay_payment_header 
            where check_date = ?::date
            group by personid) paytodate_gross on paytodate_gross.personid = ppd.personid

 -- Pre Taxed 401(k)                             
left join (select personid, sum(etv_amount) as etv_amount 
             from pspay_payment_detail 
            where check_date = ?
              and etv_id = 'VB1'
            group by 1) ppdvb1 on ppdvb1.personid = ppd.personid 

left join (select personid, sum(etv_amount) as etv_amount 
             from pspay_payment_detail 
            where check_date = ?
              and etv_id = 'VB2'
            group by 1) ppdvb2 on ppdvb2.personid = ppd.personid 
            
-- roth
left join (select personid, sum(etv_amount) as etv_amount 
             from pspay_payment_detail 
            where check_date = ?
              and etv_id = 'VB3'
            group by 1) ppdvb3 on ppdvb3.personid = ppd.personid 

-- 401K employer
left join (select personid, sum(etv_amount) as etv_amount 
             from pspay_payment_detail 
            where check_date = ?
              and etv_id = 'VB5'
            group by 1) ppdvb5 on ppdvb5.personid = ppd.personid 

-- loan payment
left join (select personid, sum(etv_amount) as etv_amount 
             from pspay_payment_detail 
            where check_date = ?
              and etv_id = 'V65'
            group by 1) ppdv65 on ppdv65.personid = ppd.personid 

left join person_payroll pp 
  on pp.personid = pi.personid 
 and CURRENT_DATE BETWEEN pp.effectivedate AND pp.enddate 
 and CURRENT_TIMESTAMP BETWEEN pp.createts AND pp.endts

 LEFT JOIN pay_unit pu 
  ON pu.payunitid = pp.payunitid
 AND current_date between pp.effectivedate and pp.enddate
 AND current_timestamp between pp.createts and pp.endts

where pi.identitytype = 'EmpNo'
  and current_timestamp between pi.createts and pi.endts
 -- and pi.personid = '1896'
 order by 1
