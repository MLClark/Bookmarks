select distinct
 pi.personid
,pbe.effectivedate
,pbe.coverageamount
,pn.lname ::varchar(26) as lname
,pn.fname ::varchar(19) as fname
,'FUTURE DATED EE' ::varchar(30) as qsource 


,'IC' ::char(2) as recordtype
,'IHS' ::varchar(6) as tpaid
,'IHSSBS' ::varchar(9) as employerid
,pi.identity ::char(9) as employeeid
,case when pbe.benefitsubclass = '60' then 'HEALTH-26'
      when pbe.benefitsubclass = '61' then 'DEPEND-26' else null end ::char(10) as plan_id  
,' ' ::char(1) as re_enroll
,case when pbe.benefitsubclass = '60' then 'FSA'
      when pbe.benefitsubclass = '61' then 'DCA' else null end ::char(4) as account_type_code  
,to_char(cppy.planyearstart,'YYYYMMDD')::char(8) as plan_year_start_date
,to_char(cppy.planyearend,'YYYYMMDD')::char(8) as plan_year_end_date 

,'2' ::char(1) as account_status
,case when pbe.benefitsubclass = '60' then to_char(pbe.coverageamount,'9999D99') 
      when pbe.benefitsubclass = '61' then to_char(pbe.coverageamount,'9999D99') else null end as annual_fsa_election_amount
,'0' ::char(1) as ee_perpay_period  
,'0' ::char(1) as er_perpay_period
,'0' ::char(1) as auto_dep_calid
,to_char(pbe.effectivedate,'YYYYMMDD')::char(8) as effectivedate
,case when pe.emplstatus = 'T' then to_char(pe.effectivedate,'YYYYMMDD')
      when pbe.benefitelection = 'T' then to_char(pe.effectivedate,'YYYYMMDD')
      else ' ' end ::char(8) as term_date
,'0' ::char(1) as auto_add_dependents
      

from person_identity pi

left join edi.edi_last_update elu on elu.feedid = 'CDE_Innovative_Health_Services_FSADC_Enroll_Export'

join person_employment pe 
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts

left join person_names pn
  on pn.personid = pe.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts 
 
 
join person_bene_election pbe
  on pbe.personid = pi.personid
 and pbe.benefitsubclass in ('60','61')
 and pbe.selectedoption = 'Y' 
 and pbe.benefitelection = 'E'
 and current_timestamp between pbe.createts and pbe.endts
 and (current_date between pbe.effectivedate and pbe.enddate or (pbe.effectivedate > current_date and pbe.enddate > pbe.effectivedate))

 	AND current_date <= pbe.planyearenddate
 	AND ((pbe.effectivedate, pbe.enddate) overlaps (cppy.planyearstart, cppy.planyearend) OR cppy.planyearstart IS NULL) 


 and pbe.personid in
(select distinct effcovdate.personid 
        from       (select pbe.personid,pbe.benefitsubclass, min(pbe.createts) as createts, min(pbe.effectivedate) as min_effectivedate,max(pbe.effectivedate) as max_effectivedate
                from person_bene_election pbe 
                left join edi.edi_last_update elu on elu.feedid = 'CDE_Innovative_Health_Services_FSADC_Enroll_Export'
               where pbe.benefitsubclass in ('60','61') and pbe.effectivedate < pbe.enddate and current_timestamp between pbe.createts and pbe.endts
                 and pbe.selectedoption = 'Y' and pbe.benefitelection = 'E' 
                 and pbe.effectivedate <= elu.lastupdatets
               group by 1,2) effcovdate
       left join edi.edi_last_update elu on elu.feedid = 'CDE_Innovative_Health_Services_FSADC_Enroll_Export'
      where effcovdate.min_effectivedate <= elu.lastupdatets)  
 


where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  and pe.emplstatus = 'A' and pbe.benefitelection = 'E'  and pbe.effectivedate >= date_trunc('year', current_date + interval '1 year')  