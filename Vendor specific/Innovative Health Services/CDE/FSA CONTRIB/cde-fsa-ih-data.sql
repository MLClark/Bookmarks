select distinct
  pi.personid
,'IH'::char(2) as recordtype
,'IHS'::char(3) as tpaid
,'IHSSBS'::char(6) as employerid
,pi.identity ::char(9) as ssn
,pn.name as pnname
,case when pbe.benefitsubclass = '60' then 'FSA'
      when pbe.benefitsubclass = '61' then 'DCA' else null end ::char(4) as account_type_code
,case when pbe.benefitsubclass = '60' then 'HEALTH-26'
      when pbe.benefitsubclass = '61' then 'DEPEND-26' else null end ::char(10) as plan_id      
,to_char(ppd.check_date,'YYYYMMDD')::char(8) as effectivedate
,'1' ::char(1) as deposit_type
,case when pbe.benefitsubclass = '60' then ppdvba.etv_amount 
      when pbe.benefitsubclass = '61' then ppdvbb.etv_amount else null end as employee_amt
,'0' ::char(1) as employer_amt
,to_char(cppy.planyearstart,'YYYYMMDD')::char(8) as plan_year_start_date
,to_char(pbe.planyearenddate,'YYYYMMDD')::char(8) as plan_year_end_date
 
from person_identity pi

join person_names pn
  on pn.personid = pi.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts
 
join person_bene_election pbe
  on pbe.personid = pi.personid
 and pbe.benefitsubclass in ('60','61')
 and pbe.selectedoption = 'Y' 
 and pbe.benefitelection = 'E'
 and current_date between pbe.effectivedate and pbe.enddate
 and current_timestamp between pbe.createts and pbe.endts
 
left join person_bene_election pbefsa
  on pbefsa.personid = pbe.personid
 and pbefsa.benefitsubclass = '60'
 and pbefsa.selectedoption = 'Y'
 and pbefsa.benefitelection = 'E'
 and current_date between pbefsa.effectivedate and pbefsa.enddate
 and current_timestamp between pbefsa.createts and pbefsa.endts

left join person_bene_election pbedfsa
  on pbedfsa.personid = pbe.personid
 and pbedfsa.benefitsubclass = '61'
 and pbedfsa.selectedoption = 'Y'
 and pbedfsa.benefitelection = 'E'
 and current_date between pbedfsa.effectivedate and pbedfsa.enddate
 and current_timestamp between pbedfsa.createts and pbedfsa.endts 

join pay_schedule_period psp 
  on psp.payrolltypeid = 1
 and psp.processfinaldate is not null
 and psp.periodpaydate = ?::date

join pspay_payment_header pph
  on pph.check_date = psp.periodpaydate
 and pph.payscheduleperiodid = psp.payscheduleperiodid  

join pspay_payment_detail ppd
  on ppd.etv_id IN ('VBA','VBB')
 and ppd.personid = pi.personid
 and ppd.check_date = psp.periodpaydate
 and ppd.paymentheaderid = pph.paymentheaderid 
 
 --- need to add debbie's joins to this to get comp plan year
 
LEFT JOIN pers_pos persp 
  ON persp.personid = pi.personid
 AND (CURRENT_DATE BETWEEN persp.effectivedate and persp.enddate
  or (persp.effectivedate > current_date AND persp.enddate > persp.effectivedate))
 AND CURRENT_TIMESTAMP BETWEEN persp.createts and persp.endts
-- select * from position_comp_plan
LEFT JOIN position_comp_plan pcp 
  on pcp.positionid = persp.positionid
 AND CURRENT_DATE BETWEEN pcp.effectivedate and pcp.enddate
 AND CURRENT_TIMESTAMP BETWEEN pcp.createts and pcp.endts
  
LEFT JOIN comp_plan_plan_year cppy 
  on cppy.compplanid = pcp.compplanid
 AND cppy.compplanplanyeartype = 'Bene'
 AND cppy.planyear = date_part('year',current_date) -- ${PLANYEAR}::int--extract(year from CURRENT_DATE)
 

-- HCRA                           
LEFT JOIN (SELECT personid,check_date,paymentheaderid, sum(etv_amount) as etv_amount
             FROM pspay_payment_detail            
            WHERE etv_id in  ('VBA')           
         GROUP BY personid,check_date,paymentheaderid
          ) ppdvba
  ON ppdvba.personid = pi.personid and ppdvba.check_date = psp.periodpaydate and ppdvba.paymentheaderid = pph.paymentheaderid 
  
-- DCRA 
LEFT JOIN (SELECT personid,check_date,paymentheaderid, sum(etv_amount) as etv_amount
             FROM pspay_payment_detail            
            WHERE etv_id in  ('VBB')           
         GROUP BY personid,check_date,paymentheaderid
          ) ppdvbb
  ON ppdvbb.personid = pi.personid and ppdvbb.check_date = psp.periodpaydate and ppdvbb.paymentheaderid = pph.paymentheaderid 
 
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  and (ppdvba.etv_amount <> 0 or  ppdvbb.etv_amount <> 0)

  
  order by ssn