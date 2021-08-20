select distinct
 pi.personid
,'NEW EE' ::varchar(30) as qsource
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
,to_char(pbe.planyearenddate,'YYYYMMDD')::char(8) as plan_year_end_date 

,'1' ::char(1) as account_status
,case when pbe.benefitsubclass = '60' then to_char(pbemfsa.coverageamount,'9999D99') 
      when pbe.benefitsubclass = '61' then to_char(pbedfsa.coverageamount,'9999D99') else null end as annual_fsa_election_amount
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

join person_bene_election pbe
  on pbe.personid = pi.personid
 and pbe.benefitsubclass in ('60','61')
 and pbe.selectedoption = 'Y' 
 and pbe.benefitelection = 'E'
 and current_date between pbe.effectivedate and pbe.enddate
 and current_timestamp between pbe.createts and pbe.endts
 and pbe.personid in 
 --- need to pull absolutely new enrollments for type 1 data
(select distinct effcovdate.personid 
        from (select pbe.personid,pbe.benefitsubclass, min(pbe.createts) as createts, min(pbe.effectivedate) as min_effectivedate,max(pbe.effectivedate) as max_effectivedate
                from person_bene_election pbe 
                left join edi.edi_last_update elu on elu.feedid = 'CDE_Innovative_Health_Services_FSADC_Enroll_Export'
               where pbe.benefitsubclass in ('60','61')
                 and pbe.selectedoption = 'Y' and pbe.benefitelection = 'E' 
                 and pbe.effectivedate >= elu.lastupdatets
               group by 1,2) effcovdate
       left join edi.edi_last_update elu on elu.feedid = 'CDE_Innovative_Health_Services_FSADC_Enroll_Export'
         
      where effcovdate.min_effectivedate <= elu.lastupdatets)   

left join person_bene_election pbemfsa
  on pbemfsa.personid = pbe.personid
 and pbemfsa.benefitsubclass = '60'
 and pbemfsa.selectedoption = 'Y'
 and pbemfsa.benefitelection <> 'W'
 and current_date between pbemfsa.effectivedate and pbemfsa.enddate
 and current_timestamp between pbemfsa.createts and pbemfsa.endts

left join person_bene_election pbedfsa
  on pbedfsa.personid = pbe.personid
 and pbedfsa.benefitsubclass = '61'
 and pbedfsa.selectedoption = 'Y'
 and pbedfsa.benefitelection <> 'W'
 and current_date between pbedfsa.effectivedate and pbedfsa.enddate
 and current_timestamp between pbedfsa.createts and pbedfsa.endts  

 --- need to add debbie's joins to this to get comp plan year
 
left join pers_pos persp 
  on persp.personid = pi.personid
 and (current_date between persp.effectivedate and persp.enddate
  or (persp.effectivedate > current_date and persp.enddate > persp.effectivedate))
 and current_timestamp between persp.createts and persp.endts

left join position_comp_plan pcp 
  on pcp.positionid = persp.positionid
 AND current_date between pcp.effectivedate and pcp.enddate
 AND current_timestamp between pcp.createts and pcp.endts
  
left join comp_plan_plan_year cppy 
  on cppy.compplanid = pcp.compplanid
 and cppy.compplanplanyeartype = 'Bene'
 and cppy.planyear = date_part('year',current_date) -- ${PLANYEAR}::int--extract(year from CURRENT_DATE) 
 -- select * from personbenoptioncostl where personid = '193' and costsby = 'A' and personbeneelectionpid = '61618';
 
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  and pe.emplstatus = 'A'