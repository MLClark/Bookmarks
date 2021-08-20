select distinct
 pi.personid
,pn.lname ::varchar(26) as lname
,pn.fname ::varchar(19) as fname
,'ACTIVE EE ACTIVE MED FSA BENEFITS' ::varchar(50) as qsource 
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

,'2' ::char(1) as account_status
,to_char(pbe.coverageamount,'9999D99') as annual_fsa_election_amount
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
 and pbe.benefitsubclass in ('60')
 and pbe.selectedoption = 'Y' 
 and pbe.benefitelection <> 'W'
 and current_date between pbe.effectivedate and pbe.enddate
 and current_timestamp between pbe.createts and pbe.endts
 
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

where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  and pe.emplstatus = 'A'
  and pbe.personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts --and personid = '216'
                          and benefitsubclass in ('60') and benefitelection = 'E' and selectedoption = 'Y' and effectivedate < enddate)
     
  
  union
  
select distinct
 pi.personid
,pn.lname ::varchar(26) as lname
,pn.fname ::varchar(19) as fname
,'ACTIVE EE ACTIVE DEP FSA BENEFITS' ::varchar(50) as qsource 
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

,'2' ::char(1) as account_status
,to_char(pbe.coverageamount,'9999D99') as annual_fsa_election_amount
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
 and pbe.benefitsubclass in ('61')
 and pbe.selectedoption = 'Y' 
 and pbe.benefitelection <> 'W'
 and current_date between pbe.effectivedate and pbe.enddate
 and current_timestamp between pbe.createts and pbe.endts
 
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

where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  and pe.emplstatus = 'A'
  and pbe.personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts --and personid = '216'
                          and benefitsubclass in ('61') and benefitelection = 'E' and selectedoption = 'Y' and effectivedate < enddate)
   