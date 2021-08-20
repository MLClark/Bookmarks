
select
--- Split this into unions for each benefit because rows are being generated for waived benefits - can't change the case clauses to benefit specific values 
 pi.personid
,'MED TERMED EE' ::varchar(30) as qsource 
,'0' as dependentid
,'4' ::char(10) as sort_seq
,pn.name
,'OFC' ::char(3) as recordtype
,case when pbe.benefitplanid = lookup.benefitplanid::int then lookup.value1 end ::char(15) as plan_code
,case when pbe.benefitplanid = lookup.benefitplanid::int then lookup.value2 end ::char(15) as coverage_code 
,case when pbe.benefitplanid = lookup.benefitplanid::int and bcd.benefitcoverageid = '1' then lookup.value3					  --EE Only
      when pbe.benefitplanid = lookup.benefitplanid::int and bcd.benefitcoverageid in ('16','11','3','2') then lookup.value4			  --EE+1
      when pbe.benefitplanid = lookup.benefitplanid::int and bcd.benefitcoverageid in ('5','8','10','12','13','14','15','17') then lookup.value5  --EE+FAMILY
      else null end ::char(15) as option_code
,case when pbe.benefitsubclass = '10' then to_char(pbe.effectivedate - interval '1 day','YYYY-MM-DD') end ::char(10) as loss_of_coverage_date  
,to_char(pba.eventeffectivedate,'YYYY-MM-DD')::char(10) as event_date 
,null ::char(7) as premium  
,case when pbe.benefitsubclass = '10' then cast(poc.employeerate as dec(18,2)) else null end  ::char(7) as premium_not_used
,' ' ::char(2) as day_due
,' ' ::char(10) as waiting_period_begin
,' ' ::char(10) as coverage_begin      

-- Control Report Fields --
,pie.identity ::varchar(15) as empno
,pn.fname || ' ' || pn.lname ::varchar(50) as empname
,en.description ::varchar(50) as eventtype
,pba.createts ::varchar(20) as eventcreatets
,pba.eventeffectivedate ::varchar(10) as eventdate
,pbelast.effectivedate ::varchar(10) as benefitstart
,pbelast.enddate ::varchar(10) as benefitend
,null ::char(10) as coverageamount
---------------------------

from person_identity pi

left join edi.edi_last_update elu on elu.feedid = 'AXU_Infinisource_Cobra_QE_Export'
 
left join person_names pn
  on pn.personid = pi.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts 

left join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts

left join (select personid, eventname, personbenefitactionpid, max(eventeffectivedate) as eventeffectivedate,max(createts) as createts,
rank() over (partition by personid order by max(eventeffectivedate) desc) as rank
from person_benefit_action
where current_timestamp between createts and endts and eventname in ('TER','Retirement','FTP','RED','RET') 
group by 1,2,3) pba on pba.personid = pe.personid and pba.rank = 1 

LEFT JOIN person_bene_election pbe
  on pbe.personid = pba.personid 
 and pbe.personbenefitactionpid = pba.personbenefitactionpid  
 and pbe.selectedoption = 'Y' 
 and pbe.benefitelection <> 'W'
 and pbe.benefitsubclass in ('10')
/*
For cobra - need to make sure that they had elected benefit coverage on their last day of employment 
(effectivedate - 1 day of term record) is between the effectivedate 
and enddate of the person_bene_election row with benefitelection = 'E' 
*/
 AND pbe.effectivedate < pbe.enddate
 AND current_timestamp between pbe.createts AND pbe.endts
 and pe.effectivedate - interval '1 day' < pbe.effectivedate  

-- to be qualified for cobra the emp must have participated in employer's health care plan  
-- Double ranked join to check that record previous to the term was elected
left join (select pbe.personid,pba.eventname,pbe.benefitelection,pbe.benefitcoverageid,pbe.benefitplanid,pbe.benefitsubclass,pbe.compplanid,max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate, rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
		from person_bene_election pbe
		left join person_benefit_action pba on pba.personid = pbe.personid
		left join (select pbe.personid,pba.eventname,pbe.benefitelection,pbe.benefitcoverageid,max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate, rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
				from person_bene_election pbe
				left join person_benefit_action pba on pba.personid = pbe.personid
				where pbe.benefitsubclass in ('10') and pbe.selectedoption = 'Y' and pba.eventname in ('TER','Retirement','FTP','RED','RET') and pbe.benefitelection = 'T'
					and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate
					group by 1,2,3,4 order by 2,1,7) pbeno on pbeno.personid = pbe.personid and pbeno.rank = 1
                 where pbe.benefitsubclass in ('10') and pbe.selectedoption = 'Y' and pba.eventname in ('TER','Retirement','FTP','RED','RET')
                        and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate and pbeno.effectivedate <> pbe.effectivedate
                         group by 1,2,3,4,5,6,7 order by 2,1,8) pbelast on pbelast.personid = pbe.personid and pbelast.rank = 1

---------------------------------------------
-- ETVID LOOKUP TABLE JOIN --
---------------------------------------------
LEFT JOIN  (select lp.lookupid, key1 as benefitplanid, value1,value2,value3,value4,value5,value6,lp.effectivedate,lp.enddate from edi.lookup lp
    		join edi.lookup_schema els on lp.lookupid = els.lookupid and els.lookupname = 'AXU_Infinisource_Cobra_QE_Export'
			where lp.effectivedate < lp.enddate and current_timestamp between lp.createts and lp.endts
		) lookup on lookup.benefitplanid::int = pbe.benefitplanid and pbelast.enddate between lookup.effectivedate and lookup.enddate 
-----------------------------------------------

left join benefit_coverage_desc bcd
  on bcd.benefitcoverageid = pbe.benefitcoverageid
 and current_date between bcd.effectivedate and bcd.enddate
 and current_timestamp between bcd.createts and bcd.endts       

left join personbenoptioncostl poc
  on poc.personid = pbe.personid
 and poc.personbeneelectionpid = pbe.personbeneelectionpid
 and poc.costsby = 'M'    

-- Control Report Joins --
left join person_identity pie on pie.personid = pi.personid
and pie.identitytype = 'EmpNo'
and current_timestamp between pie.createts and pie.endts

left join eventname en on en.eventname = pba.eventname
---------------------------      

where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts 
  and pbelast.benefitcoverageid is not null
  and pbe.createts > ?::timestamp      

 UNION  ---------------------------------------------------------------------------------------------------------------------------------------
  
select
--- Split this into unions for each benefit because rows are being generated for waived benefits - can't change the case clauses to benefit specific values 
 pi.personid
,'MED TERMED DEP' ::varchar(30) as qsource 
,pdr.dependentid as dependentid
,'4' ::char(10) as sort_seq
,pnd.name
,'OFC' ::char(3) as recordtype
,case when pbe.benefitplanid = lookup.benefitplanid::int then lookup.value1 end ::char(15) as plan_code
,case when pbe.benefitplanid = lookup.benefitplanid::int then lookup.value2 end ::char(15) as coverage_code 
,case when pbe.benefitplanid = lookup.benefitplanid::int and bcd.benefitcoverageid = '1' then lookup.value3					  --EE Only
      when pbe.benefitplanid = lookup.benefitplanid::int and bcd.benefitcoverageid in ('16','11','3','2') then lookup.value4			  --EE+1
      when pbe.benefitplanid = lookup.benefitplanid::int and bcd.benefitcoverageid in ('5','8','10','12','13','14','15','17') then lookup.value5  --EE+FAMILY
      else null end ::char(15) as option_code
,case when pbe.benefitsubclass = '10' then to_char(pbe.effectivedate - interval '1 day','YYYY-MM-DD') end ::char(10) as loss_of_coverage_date  
,to_char(pba.eventeffectivedate,'YYYY-MM-DD')::char(10) as event_date 
,null ::char(7) as premium  
,case when pbe.benefitsubclass = '10' then cast(poc.employeerate as dec(18,2)) else null end  ::char(7) as premium_not_used
,' ' ::char(2) as day_due
,' ' ::char(10) as waiting_period_begin
,' ' ::char(10) as coverage_begin      

-- Control Report Fields --
,pie.identity ::varchar(15) as empno
,pnd.fname || ' ' || pnd.lname ::varchar(50) as empname
,en.description ::varchar(50) as eventtype
,pba.createts ::varchar(20) as eventcreatets
,pba.eventeffectivedate ::varchar(10) as eventdate
,pbelast.effectivedate ::varchar(10) as benefitstart
,pbelast.enddate ::varchar(10) as benefitend
,null ::char(10) as coverageamount
--------------------------- 

from person_identity pi

left join edi.edi_last_update elu on elu.feedid = 'AXU_Infinisource_Cobra_QE_Export'

left join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts

left join (select personid, eventname, personbenefitactionpid, max(eventeffectivedate) as eventeffectivedate,max(createts) as createts,
rank() over (partition by personid order by max(eventeffectivedate) desc) as rank
from person_benefit_action
where current_timestamp between createts and endts and eventname in ('TER','Retirement','FTP','RED','RET') 
group by 1,2,3) pba on pba.personid = pe.personid and pba.rank = 1 

LEFT JOIN person_bene_election pbe
  on pbe.personid = pba.personid 
 and pbe.personbenefitactionpid = pba.personbenefitactionpid  
 and pbe.selectedoption = 'Y' 
 and pbe.benefitelection <> 'W'
 and pbe.benefitsubclass in ('10')
/*
For cobra - need to make sure that they had elected benefit coverage on their last day of employment 
(effectivedate - 1 day of term record) is between the effectivedate 
and enddate of the person_bene_election row with benefitelection = 'E' 
*/
 AND pbe.effectivedate < pbe.enddate
 AND current_timestamp between pbe.createts AND pbe.endts
 and pe.effectivedate - interval '1 day' < pbe.effectivedate  

-- to be qualified for cobra the emp must have participated in employer's health care plan  
-- Double ranked join to check that record previous to the term was elected
left join (select pbe.personid,pba.eventname,pbe.benefitelection,pbe.benefitcoverageid,pbe.benefitplanid,pbe.benefitsubclass,pbe.compplanid,max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate, rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
		from person_bene_election pbe
		left join person_benefit_action pba on pba.personid = pbe.personid
		left join (select pbe.personid,pba.eventname,pbe.benefitelection,pbe.benefitcoverageid,max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate, rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
				from person_bene_election pbe
				left join person_benefit_action pba on pba.personid = pbe.personid
				where pbe.benefitsubclass in ('10') and pbe.selectedoption = 'Y' and pba.eventname in ('TER','Retirement','FTP','RED','RET') and pbe.benefitelection = 'T'
					and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate
					group by 1,2,3,4 order by 2,1,7) pbeno on pbeno.personid = pbe.personid and pbeno.rank = 1
                 where pbe.benefitsubclass in ('10') and pbe.selectedoption = 'Y' and pba.eventname in ('TER','Retirement','FTP','RED','RET')
                        and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate and pbeno.effectivedate <> pbe.effectivedate
                         group by 1,2,3,4,5,6,7 order by 2,1,8) pbelast on pbelast.personid = pbe.personid and pbelast.rank = 1

---------------------------------------------
-- ETVID LOOKUP TABLE JOIN --
---------------------------------------------
LEFT JOIN  (select lp.lookupid, key1 as benefitplanid, value1,value2,value3,value4,value5,value6,lp.effectivedate,lp.enddate from edi.lookup lp
    		join edi.lookup_schema els on lp.lookupid = els.lookupid and els.lookupname = 'AXU_Infinisource_Cobra_QE_Export'
			where lp.effectivedate < lp.enddate and current_timestamp between lp.createts and lp.endts
		) lookup on lookup.benefitplanid::int = pbelast.benefitplanid and pbelast.enddate between lookup.effectivedate and lookup.enddate
-----------------------------------------------

left join benefit_coverage_desc bcd
  on bcd.benefitcoverageid = pbe.benefitcoverageid
 and current_date between bcd.effectivedate and bcd.enddate
 and current_timestamp between bcd.createts and bcd.endts

left join benefit_plan_desc bpd
  on bpd.benefitsubclass = pbe.benefitsubclass
 and bpd.benefitplanid = pbe.benefitplanid
 and current_date between bpd.effectivedate and bpd.enddate
 and current_timestamp between bpd.createts and bpd.endts      

left join personbenoptioncostl poc
  on poc.personid = pbe.personid
 and poc.personbeneelectionpid = pbe.personbeneelectionpid
 and poc.costsby = 'M'        

join person_dependent_relationship pdr
  on pdr.personid = pbelast.personid
 and current_date between pdr.effectivedate and pdr.enddate
 and current_timestamp between pdr.createts and pdr.endts  

left join dependent_enrollment de
  on de.personid = pbelast.personid
 and de.dependentid = pdr.dependentid
 and de.selectedoption = 'Y'
 and de.benefitplanid = pbelast.benefitplanid
 and de.benefitsubclass = pbelast.benefitsubclass
 and pba.eventeffectivedate - interval '1 day' between de.effectivedate and de.enddate 
 and current_timestamp between de.createts and de.endts          

LEFT JOIN person_names pnd 
  ON pnd.personid = pdr.dependentid 
 and pnd.nametype = 'Dep' 
 and current_date between pnd.effectivedate and pnd.enddate
 and current_timestamp between pnd.createts and pnd.endts    

-- Control Report Joins --
left join person_identity pie on pie.personid = pi.personid
and pie.identitytype = 'EmpNo'
and current_timestamp between pie.createts and pie.endts

left join eventname en on en.eventname = pba.eventname
---------------------------
 
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts 
  and de.dependentid is not null
  and pbe.createts > ?::timestamp     
  
  UNION  ---------------------------------------------------------------------------------------------------------------------------------------
 
 select

 pi.personid
,'DNT TERMED EE' ::varchar(30) as qsource 
,'0' as dependentid
,'4' ::char(10) as sort_seq
,pn.name
,'OFC' ::char(3) as recordtype
,case when pbe.benefitplanid = lookup.benefitplanid::int then lookup.value1 end ::char(15) as plan_code
,case when pbe.benefitplanid = lookup.benefitplanid::int then lookup.value2 end ::char(15) as coverage_code 
,case when pbe.benefitplanid = lookup.benefitplanid::int and bcd.benefitcoverageid = '1' then lookup.value3					  
      when pbe.benefitplanid = lookup.benefitplanid::int and bcd.benefitcoverageid in ('16','11','3','2') then lookup.value4			  
      when pbe.benefitplanid = lookup.benefitplanid::int and bcd.benefitcoverageid in ('5','8','10','12','13','14','15','17') then lookup.value5  
      else null end ::char(15) as option_code
,case when pbe.benefitsubclass = '11' then to_char(pbe.effectivedate - interval '1 day','YYYY-MM-DD') end ::char(10) as loss_of_coverage_date  
,to_char(pba.eventeffectivedate,'YYYY-MM-DD')::char(10) as event_date 
,null ::char(7) as premium  
,case when pbe.benefitsubclass = '11' then cast(poc.employeerate as dec(18,2)) else null end  ::char(7) as premium_not_used
,' ' ::char(2) as day_due
,' ' ::char(10) as waiting_period_begin
,' ' ::char(10) as coverage_begin  

-- Control Report Fields --
,pie.identity ::varchar(15) as empno
,pn.fname || ' ' || pn.lname ::varchar(50) as empname
,en.description ::varchar(50) as eventtype
,pba.createts ::varchar(20) as eventcreatets
,pba.eventeffectivedate ::varchar(10) as eventdate
,pbelast.effectivedate ::varchar(10) as benefitstart
,pbelast.enddate ::varchar(10) as benefitend
,null ::char(10) as coverageamount
---------------------------    

from person_identity pi

left join edi.edi_last_update elu on elu.feedid = 'AXU_Infinisource_Cobra_QE_Export'

left join person_names pn
  on pn.personid = pi.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts 

join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts

left join (select personid, eventname, personbenefitactionpid, max(eventeffectivedate) as eventeffectivedate,max(createts) as createts,
rank() over (partition by personid order by max(eventeffectivedate) desc) as rank
from person_benefit_action
where current_timestamp between createts and endts and eventname in ('TER','Retirement','FTP','RED','RET') 
group by 1,2,3) pba on pba.personid = pe.personid and pba.rank = 1 

LEFT JOIN person_bene_election pbe
  on pbe.personid = pba.personid 
 and pbe.personbenefitactionpid = pba.personbenefitactionpid  
 and pbe.selectedoption = 'Y' 
 and pbe.benefitelection <> 'W'
 and pbe.benefitsubclass in ('11')
/*
For cobra - need to make sure that they had elected benefit coverage on their last day of employment 
(effectivedate - 1 day of term record) is between the effectivedate 
and enddate of the person_bene_election row with benefitelection = 'E' 
*/
 AND pbe.effectivedate < pbe.enddate
 AND current_timestamp between pbe.createts AND pbe.endts
 and pe.effectivedate - interval '1 day' < pbe.effectivedate  

-- to be qualified for cobra the emp must have participated in employer's health care plan  
-- Double ranked join to check that record previous to the term was elected
left join (select pbe.personid,pba.eventname,pbe.benefitelection,pbe.benefitcoverageid,pbe.benefitplanid,pbe.benefitsubclass,pbe.compplanid,max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate, rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
		from person_bene_election pbe
		left join person_benefit_action pba on pba.personid = pbe.personid
		left join (select pbe.personid,pba.eventname,pbe.benefitelection,pbe.benefitcoverageid,max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate, rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
				from person_bene_election pbe
				left join person_benefit_action pba on pba.personid = pbe.personid
				where pbe.benefitsubclass in ('11') and pbe.selectedoption = 'Y' and pba.eventname in ('TER','Retirement','FTP','RED','RET') and pbe.benefitelection = 'T'
					and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate
					group by 1,2,3,4 order by 2,1,7) pbeno on pbeno.personid = pbe.personid and pbeno.rank = 1
                 where pbe.benefitsubclass in ('11') and pbe.selectedoption = 'Y' and pba.eventname in ('TER','Retirement','FTP','RED','RET')
                        and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate and pbeno.effectivedate <> pbe.effectivedate
                         group by 1,2,3,4,5,6,7 order by 2,1,8) pbelast on pbelast.personid = pbe.personid and pbelast.rank = 1

---------------------------------------------
-- ETVID LOOKUP TABLE JOIN --
---------------------------------------------
LEFT JOIN  (select lp.lookupid, key1 as benefitplanid, value1,value2,value3,value4,value5,value6,lp.effectivedate,lp.enddate from edi.lookup lp
    		join edi.lookup_schema els on lp.lookupid = els.lookupid and els.lookupname = 'AXU_Infinisource_Cobra_QE_Export'
			where lp.effectivedate < lp.enddate and current_timestamp between lp.createts and lp.endts
		) lookup on lookup.benefitplanid::int = pbe.benefitplanid and pbelast.enddate between lookup.effectivedate and lookup.enddate 
-----------------------------------------------

left join benefit_coverage_desc bcd
  on bcd.benefitcoverageid = pbe.benefitcoverageid
 and current_date between bcd.effectivedate and bcd.enddate
 and current_timestamp between bcd.createts and bcd.endts

left join benefit_plan_desc bpd
  on bpd.benefitsubclass = pbe.benefitsubclass
 and bpd.benefitplanid = pbe.benefitplanid
 and current_date between bpd.effectivedate and bpd.enddate
 and current_timestamp between bpd.createts and bpd.endts            

left join personbenoptioncostl poc
  on poc.personid = pbe.personid
 and poc.personbeneelectionpid = pbe.personbeneelectionpid
 and poc.costsby = 'M'        

-- Control Report Joins --
left join person_identity pie on pie.personid = pi.personid
and pie.identitytype = 'EmpNo'
and current_timestamp between pie.createts and pie.endts

left join eventname en on en.eventname = pba.eventname
---------------------------       

where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts 
  and pbelast.benefitelection <>'W'
  --and pbelast.benefitcoverageid is not null
  and pbe.createts > ?::timestamp       
  
   UNION ---------------------------------------------------------------------------------------------------------------------------------------
 
 select

 pi.personid
,'DNT TERMED DEP' ::varchar(30) as qsource 
,pdr.dependentid as dependentid
,'4' ::char(10) as sort_seq
,pnd.name
,'OFC' ::char(3) as recordtype
,case when pbe.benefitplanid = lookup.benefitplanid::int then lookup.value1 end ::char(15) as plan_code
,case when pbe.benefitplanid = lookup.benefitplanid::int then lookup.value2 end ::char(15) as coverage_code 
,case when pbe.benefitplanid = lookup.benefitplanid::int and bcd.benefitcoverageid = '1' then lookup.value3					 
      when pbe.benefitplanid = lookup.benefitplanid::int and bcd.benefitcoverageid in ('16','11','3','2') then lookup.value4			 
      when pbe.benefitplanid = lookup.benefitplanid::int and bcd.benefitcoverageid in ('5','8','10','12','13','14','15','17') then lookup.value5  
      else null end ::char(15) as option_code
,case when pbe.benefitsubclass = '11' then to_char(pbe.effectivedate - interval '1 day','YYYY-MM-DD') end ::char(10) as loss_of_coverage_date  
,to_char(pba.eventeffectivedate,'YYYY-MM-DD')::char(10) as event_date  
,null ::char(7) as premium  
,case when pbe.benefitsubclass = '11' then cast(poc.employeerate as dec(18,2)) else null end  ::char(7) as premium_not_used
,' ' ::char(2) as day_due
,' ' ::char(10) as waiting_period_begin
,' ' ::char(10) as coverage_begin  

-- Control Report Fields --
,pie.identity ::varchar(15) as empno
,pnd.fname || ' ' || pnd.lname ::varchar(50) as empname
,en.description ::varchar(50) as eventtype
,pba.createts ::varchar(20) as eventcreatets
,pba.eventeffectivedate ::varchar(10) as eventdate
,pbelast.effectivedate ::varchar(10) as benefitstart
,pbelast.enddate ::varchar(10) as benefitend
,null ::char(10) as coverageamount
---------------------------      

from person_identity pi

left join edi.edi_last_update elu on elu.feedid = 'AXU_Infinisource_Cobra_QE_Export'

left join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts

left join (select personid, eventname, personbenefitactionpid, max(eventeffectivedate) as eventeffectivedate,max(createts) as createts,
rank() over (partition by personid order by max(eventeffectivedate) desc) as rank
from person_benefit_action
where current_timestamp between createts and endts and eventname in ('TER','Retirement','FTP','RED','RET') 
group by 1,2,3) pba on pba.personid = pe.personid and pba.rank = 1 

LEFT JOIN person_bene_election pbe
  on pbe.personid = pba.personid 
 and pbe.personbenefitactionpid = pba.personbenefitactionpid  
 and pbe.selectedoption = 'Y' 
 and pbe.benefitelection <> 'W'
 and pbe.benefitsubclass in ('11')
/*
For cobra - need to make sure that they had elected benefit coverage on their last day of employment 
(effectivedate - 1 day of term record) is between the effectivedate 
and enddate of the person_bene_election row with benefitelection = 'E' 
*/
 AND pbe.effectivedate < pbe.enddate
 AND current_timestamp between pbe.createts AND pbe.endts
 and pe.effectivedate - interval '1 day' < pbe.effectivedate  

-- to be qualified for cobra the emp must have participated in employer's health care plan  
-- Double ranked join to check that record previous to the term was elected
left join (select pbe.personid,pba.eventname,pbe.benefitelection,pbe.benefitcoverageid,pbe.benefitplanid,pbe.benefitsubclass,pbe.compplanid,max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate, rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
		from person_bene_election pbe
		left join person_benefit_action pba on pba.personid = pbe.personid
		left join (select pbe.personid,pba.eventname,pbe.benefitelection,pbe.benefitcoverageid,max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate, rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
				from person_bene_election pbe
				left join person_benefit_action pba on pba.personid = pbe.personid
				where pbe.benefitsubclass in ('11') and pbe.selectedoption = 'Y' and pba.eventname in ('TER','Retirement','FTP','RED','RET') and pbe.benefitelection = 'T'
					and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate
					group by 1,2,3,4 order by 2,1,7) pbeno on pbeno.personid = pbe.personid and pbeno.rank = 1
                 where pbe.benefitsubclass in ('11') and pbe.selectedoption = 'Y' and pba.eventname in ('TER','Retirement','FTP','RED','RET')
                        and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate and pbeno.effectivedate <> pbe.effectivedate
                         group by 1,2,3,4,5,6,7 order by 2,1,8) pbelast on pbelast.personid = pbe.personid and pbelast.rank = 1

---------------------------------------------
-- ETVID LOOKUP TABLE JOIN --
---------------------------------------------
LEFT JOIN  (select lp.lookupid, key1 as benefitplanid, value1,value2,value3,value4,value5,value6,lp.effectivedate,lp.enddate from edi.lookup lp
    		join edi.lookup_schema els on lp.lookupid = els.lookupid and els.lookupname = 'AXU_Infinisource_Cobra_QE_Export'
			where lp.effectivedate < lp.enddate and current_timestamp between lp.createts and lp.endts
		) lookup on lookup.benefitplanid::int = pbelast.benefitplanid and pbelast.enddate between lookup.effectivedate and lookup.enddate
-----------------------------------------------

left join benefit_coverage_desc bcd
  on bcd.benefitcoverageid = pbelast.benefitcoverageid
 and current_date between bcd.effectivedate and bcd.enddate
 and current_timestamp between bcd.createts and bcd.endts

left join benefit_plan_desc bpd
  on bpd.benefitsubclass = pbe.benefitsubclass
 and bpd.benefitplanid = pbe.benefitplanid
 and current_date between bpd.effectivedate and bpd.enddate
 and current_timestamp between bpd.createts and bpd.endts      

left join personbenoptioncostl poc
  on poc.personid = pbelast.personid
 and poc.personbeneelectionpid = pbe.personbeneelectionpid
 and poc.costsby = 'M'        

left join person_dependent_relationship pdr
  on pdr.personid = pbelast.personid
 and current_date between pdr.effectivedate and pdr.enddate
 and current_timestamp between pdr.createts and pdr.endts  

left join dependent_enrollment de
  on de.personid = pbelast.personid
 and de.dependentid = pdr.dependentid
 and de.selectedoption = 'Y'
 and de.benefitplanid = pbelast.benefitplanid
 and de.benefitsubclass = pbelast.benefitsubclass
 and pba.eventeffectivedate - interval '1 day' between de.effectivedate and de.enddate
 and current_timestamp between de.createts and de.endts          

LEFT JOIN person_names pnd 
  ON pnd.personid = pdr.dependentid 
 and pnd.nametype = 'Dep' 
 and current_date between pnd.effectivedate and pnd.enddate
 and current_timestamp between pnd.createts and pnd.endts   

-- Control Report Joins --
left join person_identity pie on pie.personid = pi.personid
and pie.identitytype = 'EmpNo'
and current_timestamp between pie.createts and pie.endts

left join eventname en on en.eventname = pba.eventname
---------------------------         

where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts 
  and de.dependentid is not null
  and pbe.createts > ?::timestamp    
 
 UNION ---------------------------------------------------------------------------------------------------------------------------------------
 
 select 

 pi.personid
,'VSN TERMED EE' ::varchar(30) as qsource 
,'0' as dependentid
,'4' ::char(10) as sort_seq
,pn.name
,'OFC' ::char(3) as recordtype
,case when pbe.benefitplanid = lookup.benefitplanid::int then lookup.value1 end ::char(15) as plan_code
,case when pbe.benefitplanid = lookup.benefitplanid::int then lookup.value2 end ::char(15) as coverage_code 
,case when pbe.benefitplanid = lookup.benefitplanid::int and bcd.benefitcoverageid = '1' then lookup.value3					  
      when pbe.benefitplanid = lookup.benefitplanid::int and bcd.benefitcoverageid in ('2') then lookup.value4			  
      when pbe.benefitplanid = lookup.benefitplanid::int and bcd.benefitcoverageid in ('3','9','10') then lookup.value5
      when pbe.benefitplanid = lookup.benefitplanid::int and bcd.benefitcoverageid in ('5','8','10','12','13','14','15','17') then lookup.value6  
      else null end ::char(15) as option_code
,case when pbe.benefitsubclass = '14' then to_char(pbe.effectivedate - interval '1 day','YYYY-MM-DD') end ::char(10) as loss_of_coverage_date  
,to_char(pba.eventeffectivedate,'YYYY-MM-DD')::char(10) as event_date   
,null ::char(7) as premium  
,case when pbe.benefitsubclass = '14' then cast(poc.employeerate as dec(18,2)) else null end  ::char(7) as premium_not_used
,' ' ::char(2) as day_due
,' ' ::char(10) as waiting_period_begin
,' ' ::char(10) as coverage_begin      

-- Control Report Fields --
,pie.identity ::varchar(15) as empno
,pn.fname || ' ' || pn.lname ::varchar(50) as empname
,en.description ::varchar(50) as eventtype
,pba.createts ::varchar(20) as eventcreatets
,pba.eventeffectivedate ::varchar(10) as eventdate
,pbelast.effectivedate ::varchar(10) as benefitstart
,pbelast.enddate ::varchar(10) as benefitend
,null ::char(10) as coverageamount
---------------------------

from person_identity pi

left join edi.edi_last_update elu on elu.feedid = 'AXU_Infinisource_Cobra_QE_Export'

left join person_names pn
  on pn.personid = pi.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts 

left join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts

left join (select personid, eventname, personbenefitactionpid, max(eventeffectivedate) as eventeffectivedate,max(createts) as createts,
rank() over (partition by personid order by max(eventeffectivedate) desc) as rank
from person_benefit_action
where current_timestamp between createts and endts and eventname in ('TER','Retirement','FTP','RED','RET') 
group by 1,2,3) pba on pba.personid = pe.personid and pba.rank = 1 

LEFT JOIN person_bene_election pbe
  on pbe.personid = pba.personid 
 and pbe.personbenefitactionpid = pba.personbenefitactionpid  
 and pbe.selectedoption = 'Y' 
 and pbe.benefitelection <> 'W'
 and pbe.benefitsubclass in ('14')
/*
For cobra - need to make sure that they had elected benefit coverage on their last day of employment 
(effectivedate - 1 day of term record) is between the effectivedate 
and enddate of the person_bene_election row with benefitelection = 'E' 
*/
 AND pbe.effectivedate < pbe.enddate
 AND current_timestamp between pbe.createts AND pbe.endts
 and pe.effectivedate - interval '1 day' < pbe.effectivedate  

-- to be qualified for cobra the emp must have participated in employer's health care plan  
-- Double ranked join to check that record previous to the term was elected
left join (select pbe.personid,pba.eventname,pbe.benefitelection,pbe.benefitcoverageid,pbe.benefitplanid,pbe.benefitsubclass,pbe.compplanid,max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate, rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
		from person_bene_election pbe
		left join person_benefit_action pba on pba.personid = pbe.personid
		left join (select pbe.personid,pba.eventname,pbe.benefitelection,pbe.benefitcoverageid,max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate, rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
				from person_bene_election pbe
				left join person_benefit_action pba on pba.personid = pbe.personid
				where pbe.benefitsubclass in ('14') and pbe.selectedoption = 'Y' and pba.eventname in ('TER','Retirement','FTP','RED','RET') and pbe.benefitelection = 'T'
					and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate
					group by 1,2,3,4 order by 2,1,7) pbeno on pbeno.personid = pbe.personid and pbeno.rank = 1
                 where pbe.benefitsubclass in ('14') and pbe.selectedoption = 'Y' and pba.eventname in ('TER','Retirement','FTP','RED','RET')
                        and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate and pbeno.effectivedate <> pbe.effectivedate
                         group by 1,2,3,4,5,6,7 order by 2,1,8) pbelast on pbelast.personid = pbe.personid and pbelast.rank = 1

---------------------------------------------
-- ETVID LOOKUP TABLE JOIN --
---------------------------------------------
LEFT JOIN  (select lp.lookupid, key1 as benefitplanid, value1,value2,value3,value4,value5,value6,lp.effectivedate,lp.enddate from edi.lookup lp
    		join edi.lookup_schema els on lp.lookupid = els.lookupid and els.lookupname = 'AXU_Infinisource_Cobra_QE_Export'
			where lp.effectivedate < lp.enddate and current_timestamp between lp.createts and lp.endts
		) lookup on lookup.benefitplanid::int = pbe.benefitplanid and pbelast.enddate between lookup.effectivedate and lookup.enddate 
-----------------------------------------------
left join benefit_coverage_desc bcd
  on bcd.benefitcoverageid = pbe.benefitcoverageid
 and current_date between bcd.effectivedate and bcd.enddate
 and current_timestamp between bcd.createts and bcd.endts

left join benefit_plan_desc bpd
  on bpd.benefitsubclass = pbe.benefitsubclass
 and bpd.benefitplanid = pbe.benefitplanid
 and current_date between bpd.effectivedate and bpd.enddate
 and current_timestamp between bpd.createts and bpd.endts            

left join personbenoptioncostl poc
  on poc.personid = pbe.personid
 and poc.personbeneelectionpid = pbe.personbeneelectionpid
 and poc.costsby = 'M'      

-- Control Report Joins --
left join person_identity pie on pie.personid = pi.personid
and pie.identitytype = 'EmpNo'
and current_timestamp between pie.createts and pie.endts

left join eventname en on en.eventname = pba.eventname
---------------------------    

where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts 
  and pbelast.benefitcoverageid is not null
  and pbe.createts > ?::timestamp       

 UNION ---------------------------------------------------------------------------------------------------------------------------------------
 
 select

 pi.personid
,'VSN TERMED DEP' ::varchar(30) as qsource 
,pdr.dependentid as dependentid
,'4' ::char(10) as sort_seq
,pnd.name
,'OFC' ::char(3) as recordtype
,case when pbe.benefitplanid = lookup.benefitplanid::int then lookup.value1 end ::char(15) as plan_code
,case when pbe.benefitplanid = lookup.benefitplanid::int then lookup.value2 end ::char(15) as coverage_code 
,case when pbe.benefitplanid = lookup.benefitplanid::int and bcd.benefitcoverageid = '1' then lookup.value3					  
      when pbe.benefitplanid = lookup.benefitplanid::int and bcd.benefitcoverageid in ('2') then lookup.value4			  
      when pbe.benefitplanid = lookup.benefitplanid::int and bcd.benefitcoverageid in ('3','9','10') then lookup.value5
      when pbe.benefitplanid = lookup.benefitplanid::int and bcd.benefitcoverageid in ('5','8','10','12','13','14','15','17') then lookup.value6  
      else null end ::char(15) as option_code
,case when pbe.benefitsubclass = '14' then to_char(pbe.effectivedate - interval '1 day','YYYY-MM-DD') end ::char(10) as loss_of_coverage_date  
,to_char(pba.eventeffectivedate,'YYYY-MM-DD')::char(10) as event_date   
,null ::char(7) as premium  
,case when pbe.benefitsubclass = '14' then cast(poc.employeerate as dec(18,2)) else null end  ::char(7) as premium_not_used
,' ' ::char(2) as day_due
,' ' ::char(10) as waiting_period_begin
,' ' ::char(10) as coverage_begin     

-- Control Report Fields --
,pie.identity ::varchar(15) as empno
,pnd.fname || ' ' || pnd.lname ::varchar(50) as empname
,en.description ::varchar(50) as eventtype
,pba.createts ::varchar(20) as eventcreatets
,pba.eventeffectivedate ::varchar(10) as eventdate
,pbelast.effectivedate ::varchar(10) as benefitstart
,pbelast.enddate ::varchar(10) as benefitend
,null ::char(10) as coverageamount
---------------------------    

from person_identity pi

left join edi.edi_last_update elu on elu.feedid = 'AXU_Infinisource_Cobra_QE_Export'

left join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts

left join (select personid, eventname, personbenefitactionpid, max(eventeffectivedate) as eventeffectivedate,max(createts) as createts,
rank() over (partition by personid order by max(eventeffectivedate) desc) as rank
from person_benefit_action
where current_timestamp between createts and endts and eventname in ('TER','Retirement','FTP','RED','RET') 
group by 1,2,3) pba on pba.personid = pe.personid and pba.rank = 1 

LEFT JOIN person_bene_election pbe
  on pbe.personid = pba.personid 
 and pbe.personbenefitactionpid = pba.personbenefitactionpid  
 and pbe.selectedoption = 'Y' 
 and pbe.benefitelection <> 'W'
 and pbe.benefitsubclass in ('14')
/*
For cobra - need to make sure that they had elected benefit coverage on their last day of employment 
(effectivedate - 1 day of term record) is between the effectivedate 
and enddate of the person_bene_election row with benefitelection = 'E' 
*/
 AND pbe.effectivedate < pbe.enddate
 AND current_timestamp between pbe.createts AND pbe.endts
 and pe.effectivedate - interval '1 day' < pbe.effectivedate  

-- to be qualified for cobra the emp must have participated in employer's health care plan  
-- Double ranked join to check that record previous to the term was elected
left join (select pbe.personid,pba.eventname,pbe.benefitelection,pbe.benefitcoverageid,pbe.benefitplanid,pbe.benefitsubclass,pbe.compplanid,max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate, rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
		from person_bene_election pbe
		left join person_benefit_action pba on pba.personid = pbe.personid
		left join (select pbe.personid,pba.eventname,pbe.benefitelection,pbe.benefitcoverageid,max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate, rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
				from person_bene_election pbe
				left join person_benefit_action pba on pba.personid = pbe.personid
				where pbe.benefitsubclass in ('14') and pbe.selectedoption = 'Y' and pba.eventname in ('TER','Retirement','FTP','RED','RET') and pbe.benefitelection = 'T'
					and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate
					group by 1,2,3,4 order by 2,1,7) pbeno on pbeno.personid = pbe.personid and pbeno.rank = 1
                 where pbe.benefitsubclass in ('14') and pbe.selectedoption = 'Y' and pba.eventname in ('TER','Retirement','FTP','RED','RET')
                        and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate and pbeno.effectivedate <> pbe.effectivedate
                         group by 1,2,3,4,5,6,7 order by 2,1,8) pbelast on pbelast.personid = pbe.personid and pbelast.rank = 1

---------------------------------------------
-- ETVID LOOKUP TABLE JOIN --
---------------------------------------------
LEFT JOIN  (select lp.lookupid, key1 as benefitplanid, value1,value2,value3,value4,value5,value6,lp.effectivedate,lp.enddate from edi.lookup lp
    		join edi.lookup_schema els on lp.lookupid = els.lookupid and els.lookupname = 'AXU_Infinisource_Cobra_QE_Export'
			where lp.effectivedate < lp.enddate and current_timestamp between lp.createts and lp.endts
		) lookup on lookup.benefitplanid::int = pbelast.benefitplanid and pbelast.enddate between lookup.effectivedate and lookup.enddate
-----------------------------------------------

left join benefit_coverage_desc bcd
  on bcd.benefitcoverageid = pbe.benefitcoverageid
 and current_date between bcd.effectivedate and bcd.enddate
 and current_timestamp between bcd.createts and bcd.endts

left join benefit_plan_desc bpd
  on bpd.benefitsubclass = pbe.benefitsubclass
 and bpd.benefitplanid = pbe.benefitplanid
 and current_date between bpd.effectivedate and bpd.enddate
 and current_timestamp between bpd.createts and bpd.endts      

left join personbenoptioncostl poc
  on poc.personid = pbe.personid
 and poc.personbeneelectionpid = pbe.personbeneelectionpid
 and poc.costsby = 'M'        

left join person_dependent_relationship pdr
  on pdr.personid = pbelast.personid
 and current_date between pdr.effectivedate and pdr.enddate
 and current_timestamp between pdr.createts and pdr.endts  

left join dependent_enrollment de
  on de.personid = pbelast.personid
 and de.dependentid = pdr.dependentid
 and de.selectedoption = 'Y'
 and de.benefitplanid = pbelast.benefitplanid
 and de.benefitsubclass = pbelast.benefitsubclass
 and pba.eventeffectivedate - interval '1 day' between de.effectivedate and de.enddate
 and current_timestamp between de.createts and de.endts          

LEFT JOIN person_names pnd 
  ON pnd.personid = pdr.dependentid 
 and pnd.nametype = 'Dep' 
 and current_date between pnd.effectivedate and pnd.enddate
 and current_timestamp between pnd.createts and pnd.endts 

-- Control Report Joins --
left join person_identity pie on pie.personid = pi.personid
and pie.identitytype = 'EmpNo'
and current_timestamp between pie.createts and pie.endts

left join eventname en on en.eventname = pba.eventname
---------------------------
 
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts 
  and de.dependentid is not null
  and pbe.createts > ?::timestamp    
 
 UNION --------------------------------------------------------------------------------------------------------------------------------------------------------

 select 

 pi.personid
,'FSA TERMED EE' ::varchar(30) as qsource 
,'0' as dependentid
,'4' ::char(10) as sort_seq
,pn.name
,'OFC' ::char(3) as recordtype
,case when pbe.benefitplanid = lookup.benefitplanid::int then lookup.value1 end ::char(15) as plan_code
,case when pbe.benefitplanid = lookup.benefitplanid::int then lookup.value2 end ::char(15) as coverage_code 
,case when pbe.benefitplanid = lookup.benefitplanid::int then lookup.value3 end ::char(15) as option_code
,case when pbe.benefitsubclass = '60' then to_char(pbe.effectivedate - interval '1 day','YYYY-MM-DD') end ::char(10) as loss_of_coverage_date  
,to_char(pba.eventeffectivedate,'YYYY-MM-DD')::char(10) as event_date 
,case when pbe.benefitsubclass = '60' then cast(poc.employeerate as dec(18,2)) else null end  ::char(7) as premium  
,case when pbe.benefitsubclass = '60' then cast(poc.employeerate as dec(18,2)) else null end  ::char(7) as premium_not_used
,' ' ::char(2) as day_due
,' ' ::char(10) as waiting_period_begin
,' ' ::char(10) as coverage_begin   

-- Control Report Fields --
,pie.identity ::varchar(15) as empno
,pn.fname || ' ' || pn.lname ::varchar(50) as empname
,en.description ::varchar(50) as eventtype
,pba.createts ::varchar(20) as eventcreatets
,pba.eventeffectivedate ::varchar(10) as eventdate
,pbelast.effectivedate ::varchar(10) as benefitstart
,pbelast.enddate ::varchar(10) as benefitend
,pbelast.coverageamount ::char(10) as coverageamount
---------------------------   

from person_identity pi

left join edi.edi_last_update elu on elu.feedid = 'AXU_Infinisource_Cobra_QE_Export'

left join person_names pn
  on pn.personid = pi.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts 

left join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts

left join (select personid, eventname, personbenefitactionpid, max(eventeffectivedate) as eventeffectivedate,max(createts) as createts,
rank() over (partition by personid order by max(eventeffectivedate) desc) as rank
from person_benefit_action
where current_timestamp between createts and endts and eventname in ('TER','Retirement','FTP','RED','RET') 
group by 1,2,3) pba on pba.personid = pe.personid and pba.rank = 1 

LEFT JOIN person_bene_election pbe
  on pbe.personid = pba.personid 
 and pbe.personbenefitactionpid = pba.personbenefitactionpid  
 and pbe.selectedoption = 'Y' 
 and pbe.benefitelection <> 'W'
 and pbe.benefitsubclass in ('60')
/*
For cobra - need to make sure that they had elected benefit coverage on their last day of employment 
(effectivedate - 1 day of term record) is between the effectivedate 
and enddate of the person_bene_election row with benefitelection = 'E' 
*/
 AND pbe.effectivedate < pbe.enddate
 AND current_timestamp between pbe.createts AND pbe.endts
 and pe.effectivedate - interval '1 day' < pbe.effectivedate  

-- to be qualified for cobra the emp must have participated in employer's health care plan  
-- Double ranked join to check that record previous to the term was elected
left join (select pbe.personid,pba.eventname,pbe.benefitelection,pbe.benefitcoverageid,pbe.benefitplanid,pbe.benefitsubclass,pbe.coverageamount,max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate, rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
		from person_bene_election pbe
		left join person_benefit_action pba on pba.personid = pbe.personid
		left join (select pbe.personid,pba.eventname,pbe.benefitelection,pbe.benefitcoverageid,max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate, rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
				from person_bene_election pbe
				left join person_benefit_action pba on pba.personid = pbe.personid
				where pbe.benefitsubclass in ('60') and pbe.selectedoption = 'Y' and pba.eventname in ('TER','Retirement','FTP','RED','RET') and pbe.benefitelection = 'T'
					and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate
					group by 1,2,3,4 order by 2,1,7) pbeno on pbeno.personid = pbe.personid and pbeno.rank = 1
                 where pbe.benefitsubclass in ('60') and pbe.selectedoption = 'Y' and pba.eventname in ('TER','Retirement','FTP','RED','RET')
                        and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate and pbeno.effectivedate <> pbe.effectivedate
                         group by 1,2,3,4,5,6,7 order by 2,1,8) pbelast on pbelast.personid = pbe.personid and pbelast.rank = 1

---------------------------------------------
-- ETVID LOOKUP TABLE JOIN --
---------------------------------------------
LEFT JOIN  (select lp.lookupid, key1 as benefitplanid, value1,value2,value3,value4,value5,value6,lp.effectivedate,lp.enddate from edi.lookup lp
    		join edi.lookup_schema els on lp.lookupid = els.lookupid and els.lookupname = 'AXU_Infinisource_Cobra_QE_Export'
			where lp.effectivedate < lp.enddate and current_timestamp between lp.createts and lp.endts
		) lookup on lookup.benefitplanid::int = pbe.benefitplanid 
-----------------------------------------------
            
left join (select personid,personbeneelectionpid,benefitoptionid,max(createts) as createts, RANK() OVER (PARTITION BY personid ORDER BY MAX(createts) DESC) AS RANK
             from person_bene_election where current_timestamp between createts and endts and benefitsubclass in ('60') 
              and benefitelection = 'E' and selectedoption = 'Y' and effectivedate < enddate --and personid = '915'
            group by 1,2,3) pbemed on pbemed.personid = pbe.personid and pbemed.rank = 1    
            
left join personbenoptioncostl poc
  on poc.personid = pbemed.personid
 and poc.benefitoptionid = pbemed.benefitoptionid
 and poc.personbeneelectionpid = pbemed.personbeneelectionpid
 and poc.costsby = 'M'    

left join benefit_coverage_desc bcd
  on bcd.benefitcoverageid = pbe.benefitcoverageid
 and current_date between bcd.effectivedate and bcd.enddate
 and current_timestamp between bcd.createts and bcd.endts

left join benefit_plan_desc bpd
  on bpd.benefitsubclass = pbe.benefitsubclass
 and bpd.benefitplanid = pbe.benefitplanid
 and current_date between bpd.effectivedate and bpd.enddate
 and current_timestamp between bpd.createts and bpd.endts            

-- Control Report Joins --
left join person_identity pie on pie.personid = pi.personid
and pie.identitytype = 'EmpNo'
and current_timestamp between pie.createts and pie.endts

left join eventname en on en.eventname = pba.eventname
---------------------------

where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts 
  and pbe.createts > ?::timestamp    
  and pbelast.enddate between lookup.effectivedate and lookup.enddate    

  UNION ---------------------------------------------------------------------------------------------------------------------------------------

  
select
 pi.personid
,'MED DECEASED/MEDICARE EE' ::varchar(30) as qsource 
,pdr.dependentid as dependentid
,'4' ::char(10) as sort_seq
,pnd.name
,'OFC' ::char(3) as recordtype
,case when pbe.benefitplanid = lookup.benefitplanid::int then lookup.value1 end ::char(15) as plan_code
,case when pbe.benefitplanid = lookup.benefitplanid::int then lookup.value2 end ::char(15) as coverage_code 
,case when pbe.benefitplanid = lookup.benefitplanid::int and bcd.benefitcoverageid = '1' then lookup.value3					  
      when pbe.benefitplanid = lookup.benefitplanid::int and bcd.benefitcoverageid in ('16','11','3','2') then lookup.value4			  
      when pbe.benefitplanid = lookup.benefitplanid::int and bcd.benefitcoverageid in ('5','8','10','12','13','14','15','17') then lookup.value5  
      else null end ::char(15) as option_code
,case when de.benefitsubclass = '10' then to_char(de.enddate,'YYYY-MM-DD') end ::char(10) as loss_of_coverage_date  
,to_char(pba.eventeffectivedate,'YYYY-MM-DD')::char(10) as event_date 
,null ::char(7) as premium  
,case when pbe.benefitsubclass = '10' then cast(poc.employeerate as dec(18,2)) else null end  ::char(7) as premium_not_used
,' ' ::char(2) as day_due
,' ' ::char(10) as waiting_period_begin
,' ' ::char(10) as coverage_begin   

-- Control Report Fields --
,pie.identity ::varchar(15) as empno
,pn.fname || ' ' || pn.lname ::varchar(50) as empname
,en.description ::varchar(50) as eventtype
,pba.createts ::varchar(20) as eventcreatets
,pba.eventeffectivedate ::varchar(10) as eventdate
,pbelast.effectivedate ::varchar(10) as benefitstart
,pbelast.enddate ::varchar(10) as benefitend
,null ::char(10) as coverageamount
---------------------------  

from person_identity pi

left join edi.edi_last_update elu on elu.feedid = 'AXU_Infinisource_Cobra_QE_Export'
 
left join person_vitals pv
  on pv.personid = pi.personid
 and current_date between pv.effectivedate and pv.enddate
 and current_timestamp between pv.createts and pv.endts 

left join person_names pn
  on pn.personid = pi.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts 

left join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts

left join (select personid, eventname, personbenefitactionpid, max(eventeffectivedate) as eventeffectivedate,max(createts) as createts,
rank() over (partition by personid order by max(eventeffectivedate) desc) as rank
from person_benefit_action
where current_timestamp between createts and endts and eventname in ('DEA','DTH','Medicare') 
group by 1,2,3) pba on pba.personid = pe.personid and pba.rank = 1 

LEFT JOIN person_bene_election pbe
  on pbe.personid = pba.personid 
 and pbe.personbenefitactionpid = pba.personbenefitactionpid  
 and pbe.selectedoption = 'Y' 
 --and pbe.benefitelection <> 'W'
 and pbe.benefitsubclass in ('10')
/*
For cobra - need to make sure that they had elected benefit coverage on their last day of employment 
(effectivedate - 1 day of term record) is between the effectivedate 
and enddate of the person_bene_election row with benefitelection = 'E' 
*/
 AND pbe.effectivedate < pbe.enddate
 AND current_timestamp between pbe.createts AND pbe.endts
 and pe.effectivedate - interval '1 day' < pbe.effectivedate  

-- to be qualified for cobra the emp must have participated in employer's health care plan  
-- Double ranked join to check that record previous to the term was elected
left join (select pbe.personid,pba.eventname,pbe.benefitelection,pbe.benefitcoverageid,pbe.benefitplanid,pbe.benefitsubclass,pbe.compplanid,max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate, rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
		from person_bene_election pbe
		left join person_benefit_action pba on pba.personid = pbe.personid
		left join (select pbe.personid,pba.eventname,pbe.benefitelection,pbe.benefitcoverageid,max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate, rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
				from person_bene_election pbe
				left join person_benefit_action pba on pba.personid = pbe.personid
				where pbe.benefitsubclass in ('10') and pbe.selectedoption = 'Y' and pba.eventname in ('DEA','DTH','Medicare') and pbe.benefitelection = 'T'
					and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate
					group by 1,2,3,4 order by 2,1,7) pbeno on pbeno.personid = pbe.personid and pbeno.rank = 1
                 where pbe.benefitsubclass in ('10') and pbe.selectedoption = 'Y' and pba.eventname in ('DEA','DTH','Medicare')
                        and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate and pbeno.effectivedate <> pbe.effectivedate
                         group by 1,2,3,4,5,6,7 order by 2,1,8) pbelast on pbelast.personid = pbe.personid and pbelast.rank = 1

---------------------------------------------
-- ETVID LOOKUP TABLE JOIN --
---------------------------------------------
LEFT JOIN  (select lp.lookupid, key1 as benefitplanid, value1,value2,value3,value4,value5,value6,lp.effectivedate,lp.enddate from edi.lookup lp
    		join edi.lookup_schema els on lp.lookupid = els.lookupid and els.lookupname = 'AXU_Infinisource_Cobra_QE_Export'
			where lp.effectivedate < lp.enddate and current_timestamp between lp.createts and lp.endts
		) lookup on lookup.benefitplanid::int = pbelast.benefitplanid and pbelast.enddate between lookup.effectivedate and lookup.enddate
-----------------------------------------------

left join benefit_coverage_desc bcd
  on bcd.benefitcoverageid = pbe.benefitcoverageid
 and current_date between bcd.effectivedate and bcd.enddate
 and current_timestamp between bcd.createts and bcd.endts

left join benefit_plan_desc bpd
  on bpd.benefitsubclass = pbe.benefitsubclass
 and bpd.benefitplanid = pbe.benefitplanid
 and current_date between bpd.effectivedate and bpd.enddate
 and current_timestamp between bpd.createts and bpd.endts      

left join personbenoptioncostl poc
  on poc.personid = pbe.personid
 and poc.personbeneelectionpid = pbe.personbeneelectionpid
 and poc.costsby = 'M'        

left join person_dependent_relationship pdr
  on pdr.personid = pbelast.personid
 and current_date between pdr.effectivedate and pdr.enddate
 and current_timestamp between pdr.createts and pdr.endts  

left join dependent_enrollment de
  on de.personid = pbelast.personid
 and de.dependentid = pdr.dependentid
 and de.selectedoption = 'Y'
 and de.benefitplanid = pbelast.benefitplanid
 and de.benefitsubclass = pbelast.benefitsubclass
 and pba.eventeffectivedate - interval '1 day' between de.effectivedate and de.enddate 
 and current_timestamp between de.createts and de.endts          

LEFT JOIN person_names pnd 
  ON pnd.personid = pdr.dependentid 
 and pnd.nametype = 'Dep' 
 and current_date between pnd.effectivedate and pnd.enddate
 and current_timestamp between pnd.createts and pnd.endts

-- Control Report Joins --
left join person_identity pie on pie.personid = pi.personid
and pie.identitytype = 'EmpNo'
and current_timestamp between pie.createts and pie.endts

left join eventname en on en.eventname = pba.eventname
---------------------------

where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts 
  and pbe.createts > ?::timestamp     
  and de.selectedoption = 'Y'
  and pbelast.benefitcoverageid is not null

  /* DEATH EVENTS - EE must have surviving dependents to get included on QE file  */
  and pe.personid in   

(  select distinct pe.personid
 
        from person_employment pe
	left join edi.edi_last_update elu on elu.feedid = 'AXU_Infinisource_Cobra_QE_Export'
        join person_benefit_action pba
          on pba.personid = pe.personid
         and pba.eventeffectivedate >= elu.lastupdatets::date  
         and pba.eventname in ('DEA','DTH','Medicare')   
	 and current_timestamp between pba.createts and pba.endts
        
        left JOIN person_bene_election pbe 
          on pbe.personid = pba.personid 
         and pbe.personbenefitactionpid = pba.personbenefitactionpid  
         and pbe.selectedoption = 'Y' 
         and pbe.benefitelection <> 'W'
         and pbe.benefitsubclass in ('10','11','14','60')
         and pe.effectivedate - interval '1 day' <= pbe.effectivedate 
         
        left join person_dependent_relationship pdr
          on pdr.personid = pbe.personid
         and current_date between pdr.effectivedate and pdr.enddate
         and current_timestamp between pdr.createts and pdr.endts  
        
        left join dependent_enrollment de
          on de.personid = pdr.personid
         and de.dependentid = pdr.dependentid
         and de.selectedoption = 'Y'
         and de.benefitplanid = pbe.benefitplanid
         and de.benefitsubclass = pbe.benefitsubclass
          and pba.eventeffectivedate - interval '1 day' between de.effectivedate and de.enddate
         and current_timestamp between de.createts and de.endts 

        where current_date between pe.effectivedate and pe.enddate
          and current_timestamp between pe.createts and pe.endts
  )     

 UNION ---------------------------------------------------------------------------------------------------------------------------------------
 
 select

 pi.personid
,'DNT DECEASED EE' ::varchar(30) as qsource 
,pdr.dependentid as dependentid
,'4' ::char(10) as sort_seq
,pnd.name
,'OFC' ::char(3) as recordtype
,case when pbe.benefitplanid = lookup.benefitplanid::int then lookup.value1 end ::char(15) as plan_code
,case when pbe.benefitplanid = lookup.benefitplanid::int then lookup.value2 end ::char(15) as coverage_code 
,case when pbe.benefitplanid = lookup.benefitplanid::int and bcd.benefitcoverageid = '1' then lookup.value3					  
      when pbe.benefitplanid = lookup.benefitplanid::int and bcd.benefitcoverageid in ('16','11','3','2') then lookup.value4			  
      when pbe.benefitplanid = lookup.benefitplanid::int and bcd.benefitcoverageid in ('5','8','10','12','13','14','15','17') then lookup.value5  
      else null end ::char(15) as option_code
,case when pbe.benefitsubclass = '11' then to_char(de.enddate,'YYYY-MM-DD') end ::char(10) as loss_of_coverage_date  
,to_char(pba.eventeffectivedate,'YYYY-MM-DD')::char(10) as event_date  
,null ::char(7) as premium  
,case when pbe.benefitsubclass = '11' then cast(poc.employeerate as dec(18,2)) else null end  ::char(7) as premium_not_used
,' ' ::char(2) as day_due
,' ' ::char(10) as waiting_period_begin
,' ' ::char(10) as coverage_begin     

-- Control Report Fields --
,pie.identity ::varchar(15) as empno
,pn.fname || ' ' || pn.lname ::varchar(50) as empname
,en.description ::varchar(50) as eventtype
,pba.createts ::varchar(20) as eventcreatets
,pba.eventeffectivedate ::varchar(10) as eventdate
,pbelast.effectivedate ::varchar(10) as benefitstart
,pbelast.enddate ::varchar(10) as benefitend
,null ::char(10) as coverageamount
---------------------------

from person_identity pi

left join edi.edi_last_update elu on elu.feedid = 'AXU_Infinisource_Cobra_QE_Export'

left join person_names pn
  on pn.personid = pi.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts 

left join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts

left join (select personid, eventname, personbenefitactionpid, max(eventeffectivedate) as eventeffectivedate,max(createts) as createts,
rank() over (partition by personid order by max(eventeffectivedate) desc) as rank
from person_benefit_action
where current_timestamp between createts and endts and eventname in ('DEA','DTH') 
group by 1,2,3) pba on pba.personid = pe.personid and pba.rank = 1 

LEFT JOIN person_bene_election pbe
  on pbe.personid = pba.personid 
 and pbe.personbenefitactionpid = pba.personbenefitactionpid  
 and pbe.selectedoption = 'Y' 
 and pbe.benefitelection <> 'W'
 and pbe.benefitsubclass in ('11')
/*
For cobra - need to make sure that they had elected benefit coverage on their last day of employment 
(effectivedate - 1 day of term record) is between the effectivedate 
and enddate of the person_bene_election row with benefitelection = 'E' 
*/
 AND pbe.effectivedate < pbe.enddate
 AND current_timestamp between pbe.createts AND pbe.endts
 and pe.effectivedate - interval '1 day' < pbe.effectivedate  

-- to be qualified for cobra the emp must have participated in employer's health care plan  
-- Double ranked join to check that record previous to the term was elected
left join (select pbe.personid,pba.eventname,pbe.benefitelection,pbe.benefitcoverageid,pbe.benefitplanid,pbe.benefitsubclass,pbe.compplanid,max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate, rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
		from person_bene_election pbe
		left join person_benefit_action pba on pba.personid = pbe.personid
		left join (select pbe.personid,pba.eventname,pbe.benefitelection,pbe.benefitcoverageid,max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate, rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
				from person_bene_election pbe
				left join person_benefit_action pba on pba.personid = pbe.personid
				where pbe.benefitsubclass in ('11') and pbe.selectedoption = 'Y' and pba.eventname in ('DEA','DTH') and pbe.benefitelection = 'T'
					and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate
					group by 1,2,3,4 order by 2,1,7) pbeno on pbeno.personid = pbe.personid and pbeno.rank = 1
                 where pbe.benefitsubclass in ('11') and pbe.selectedoption = 'Y' and pba.eventname in ('DEA','DTH')
                        and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate and pbeno.effectivedate <> pbe.effectivedate
                         group by 1,2,3,4,5,6,7 order by 2,1,8) pbelast on pbelast.personid = pbe.personid and pbelast.rank = 1

---------------------------------------------
-- ETVID LOOKUP TABLE JOIN --
---------------------------------------------
LEFT JOIN  (select lp.lookupid, key1 as benefitplanid, value1,value2,value3,value4,value5,value6,lp.effectivedate,lp.enddate from edi.lookup lp
    		join edi.lookup_schema els on lp.lookupid = els.lookupid and els.lookupname = 'AXU_Infinisource_Cobra_QE_Export'
			where lp.effectivedate < lp.enddate and current_timestamp between lp.createts and lp.endts
		) lookup on lookup.benefitplanid::int = pbelast.benefitplanid and pbelast.enddate between lookup.effectivedate and lookup.enddate
-----------------------------------------------

left join benefit_coverage_desc bcd
  on bcd.benefitcoverageid = pbe.benefitcoverageid
 and current_date between bcd.effectivedate and bcd.enddate
 and current_timestamp between bcd.createts and bcd.endts

left join benefit_plan_desc bpd
  on bpd.benefitsubclass = pbe.benefitsubclass
 and bpd.benefitplanid = pbe.benefitplanid
 and current_date between bpd.effectivedate and bpd.enddate
 and current_timestamp between bpd.createts and bpd.endts      

left join personbenoptioncostl poc
  on poc.personid = pbe.personid
 and poc.personbeneelectionpid = pbe.personbeneelectionpid
 and poc.costsby = 'M'        

left join person_dependent_relationship pdr
  on pdr.personid = pbelast.personid
 and current_date between pdr.effectivedate and pdr.enddate
 and current_timestamp between pdr.createts and pdr.endts  

left join dependent_enrollment de
  on de.personid = pbelast.personid
 and de.dependentid = pdr.dependentid
 and de.selectedoption = 'Y'
 and de.benefitplanid = pbelast.benefitplanid
 and de.benefitsubclass = pbelast.benefitsubclass
 and pba.eventeffectivedate - interval '1 day' between de.effectivedate and de.enddate 
 and current_timestamp between de.createts and de.endts          

LEFT JOIN person_names pnd 
  ON pnd.personid = pdr.dependentid 
 and pnd.nametype = 'Dep' 
 and current_date between pnd.effectivedate and pnd.enddate
 and current_timestamp between pnd.createts and pnd.endts

-- Control Report Joins --
left join person_identity pie on pie.personid = pi.personid
and pie.identitytype = 'EmpNo'
and current_timestamp between pie.createts and pie.endts

left join eventname en on en.eventname = pba.eventname
---------------------------

where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts 
  and pbe.createts > ?::timestamp   
  and de.selectedoption = 'Y'
  and pbelast.benefitcoverageid is not null 

  /* DEATH EVENTS - EE must have surviving dependents to get included on QE file  */
  and pe.personid in   

(  select distinct pe.personid
 
        from person_employment pe
	left join edi.edi_last_update elu on elu.feedid = 'AXU_Infinisource_Cobra_QE_Export'
        join person_benefit_action pba
          on pba.personid = pe.personid
         and pba.eventeffectivedate >= elu.lastupdatets::date  
         and pba.eventname in ('DEA','DTH')   
	 and current_timestamp between pba.createts and pba.endts
        
        JOIN person_bene_election pbe 
          on pbe.personid = pba.personid 
         and pbe.personbenefitactionpid = pba.personbenefitactionpid  
         and pbe.selectedoption = 'Y' 
         and pbe.benefitelection <> 'W'
         and pbe.benefitsubclass in ('10','11','14','60')
         and pe.effectivedate - interval '1 day' <= pbe.effectivedate 
         
        join person_dependent_relationship pdr
          on pdr.personid = pbe.personid
         and current_date between pdr.effectivedate and pdr.enddate
         and current_timestamp between pdr.createts and pdr.endts  
        
        join dependent_enrollment de
          on de.personid = pdr.personid
         and de.dependentid = pdr.dependentid
         and de.selectedoption = 'Y'
         and de.benefitplanid = pbe.benefitplanid
         and de.benefitsubclass = pbe.benefitsubclass
          and pba.eventeffectivedate - interval '1 day' between de.effectivedate and de.enddate
         and current_timestamp between de.createts and de.endts 

        where current_date between pe.effectivedate and pe.enddate
          and current_timestamp between pe.createts and pe.endts
  )  
   

 UNION ---------------------------------------------------------------------------------------------------------------------------------------
 
 select

 pi.personid
,'VSN DECEASED EE' ::varchar(30) as qsource 
,pdr.dependentid as dependentid
,'4' ::char(10) as sort_seq
,pnd.name
,'OFC' ::char(3) as recordtype
,case when pbe.benefitplanid = lookup.benefitplanid::int then lookup.value1 end ::char(15) as plan_code
,case when pbe.benefitplanid = lookup.benefitplanid::int then lookup.value2 end ::char(15) as coverage_code 
,case when pbe.benefitplanid = lookup.benefitplanid::int and bcd.benefitcoverageid = '1' then lookup.value3					  
      when pbe.benefitplanid = lookup.benefitplanid::int and bcd.benefitcoverageid in ('2') then lookup.value4			  
      when pbe.benefitplanid = lookup.benefitplanid::int and bcd.benefitcoverageid in ('3','9','10') then lookup.value5
      when pbe.benefitplanid = lookup.benefitplanid::int and bcd.benefitcoverageid in ('5','8','10','12','13','14','15','17') then lookup.value6  
      else null end ::char(15) as option_code
,case when pbe.benefitsubclass = '14' then to_char(de.enddate,'YYYY-MM-DD') end ::char(10) as loss_of_coverage_date  
,to_char(pba.eventeffectivedate,'YYYY-MM-DD')::char(10) as event_date   
,null ::char(7) as premium  
,case when pbe.benefitsubclass = '14' then cast(poc.employeerate as dec(18,2)) else null end  ::char(7) as premium_not_used
,' ' ::char(2) as day_due
,' ' ::char(10) as waiting_period_begin
,' ' ::char(10) as coverage_begin      

-- Control Report Fields --
,pie.identity ::varchar(15) as empno
,pn.fname || ' ' || pn.lname ::varchar(50) as empname
,en.description ::varchar(50) as eventtype
,pba.createts ::varchar(20) as eventcreatets
,pba.eventeffectivedate ::varchar(10) as eventdate
,pbelast.effectivedate ::varchar(10) as benefitstart
,pbelast.enddate ::varchar(10) as benefitend
,null ::char(10) as coverageamount
---------------------------  

from person_identity pi

left join edi.edi_last_update elu on elu.feedid = 'AXU_Infinisource_Cobra_QE_Export'

left join person_names pn
  on pn.personid = pi.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts 

left join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts

left join (select personid, eventname, personbenefitactionpid, max(eventeffectivedate) as eventeffectivedate,max(createts) as createts,
rank() over (partition by personid order by max(eventeffectivedate) desc) as rank
from person_benefit_action
where current_timestamp between createts and endts and eventname in ('DEA','DTH') 
group by 1,2,3) pba on pba.personid = pe.personid and pba.rank = 1 

LEFT JOIN person_bene_election pbe
  on pbe.personid = pba.personid 
 and pbe.personbenefitactionpid = pba.personbenefitactionpid  
 and pbe.selectedoption = 'Y' 
 and pbe.benefitelection <> 'W'
 and pbe.benefitsubclass in ('14')
/*
For cobra - need to make sure that they had elected benefit coverage on their last day of employment 
(effectivedate - 1 day of term record) is between the effectivedate 
and enddate of the person_bene_election row with benefitelection = 'E' 
*/
 AND pbe.effectivedate < pbe.enddate
 AND current_timestamp between pbe.createts AND pbe.endts
 and pe.effectivedate - interval '1 day' < pbe.effectivedate  

-- to be qualified for cobra the emp must have participated in employer's health care plan  
-- Double ranked join to check that record previous to the term was elected
left join (select pbe.personid,pba.eventname,pbe.benefitelection,pbe.benefitcoverageid,pbe.benefitplanid,pbe.benefitsubclass,pbe.compplanid,max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate, rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
		from person_bene_election pbe
		left join person_benefit_action pba on pba.personid = pbe.personid
		left join (select pbe.personid,pba.eventname,pbe.benefitelection,pbe.benefitcoverageid,max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate, rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
				from person_bene_election pbe
				left join person_benefit_action pba on pba.personid = pbe.personid
				where pbe.benefitsubclass in ('14') and pbe.selectedoption = 'Y' and pba.eventname in ('DEA','DTH') and pbe.benefitelection = 'T'
					and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate
					group by 1,2,3,4 order by 2,1,7) pbeno on pbeno.personid = pbe.personid and pbeno.rank = 1
                 where pbe.benefitsubclass in ('14') and pbe.selectedoption = 'Y' and pba.eventname in ('DEA','DTH')
                        and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate and pbeno.effectivedate <> pbe.effectivedate
                         group by 1,2,3,4,5,6,7 order by 2,1,8) pbelast on pbelast.personid = pbe.personid and pbelast.rank = 1

---------------------------------------------
-- ETVID LOOKUP TABLE JOIN --
---------------------------------------------
LEFT JOIN  (select lp.lookupid, key1 as benefitplanid, value1,value2,value3,value4,value5,value6,lp.effectivedate,lp.enddate from edi.lookup lp
    		join edi.lookup_schema els on lp.lookupid = els.lookupid and els.lookupname = 'AXU_Infinisource_Cobra_QE_Export'
			where lp.effectivedate < lp.enddate and current_timestamp between lp.createts and lp.endts
		) lookup on lookup.benefitplanid::int = pbelast.benefitplanid and pbelast.enddate between lookup.effectivedate and lookup.enddate
-----------------------------------------------

left join benefit_coverage_desc bcd
  on bcd.benefitcoverageid = pbe.benefitcoverageid
 and current_date between bcd.effectivedate and bcd.enddate
 and current_timestamp between bcd.createts and bcd.endts

left join benefit_plan_desc bpd
  on bpd.benefitsubclass = pbe.benefitsubclass
 and bpd.benefitplanid = pbe.benefitplanid
 and current_date between bpd.effectivedate and bpd.enddate
 and current_timestamp between bpd.createts and bpd.endts      

left join personbenoptioncostl poc
  on poc.personid = pbe.personid
 and poc.personbeneelectionpid = pbe.personbeneelectionpid
 and poc.costsby = 'M'        

left join person_dependent_relationship pdr
  on pdr.personid = pbelast.personid
 and current_date between pdr.effectivedate and pdr.enddate
 and current_timestamp between pdr.createts and pdr.endts  

left join dependent_enrollment de
  on de.personid = pbelast.personid
 and de.dependentid = pdr.dependentid
 and de.selectedoption = 'Y'
 and de.benefitplanid = pbelast.benefitplanid
 and de.benefitsubclass = pbelast.benefitsubclass
 and pba.eventeffectivedate - interval '1 day' between de.effectivedate and de.enddate  
 and current_timestamp between de.createts and de.endts          

LEFT JOIN person_names pnd 
  ON pnd.personid = pdr.dependentid 
 and pnd.nametype = 'Dep' 
 and current_date between pnd.effectivedate and pnd.enddate
 and current_timestamp between pnd.createts and pnd.endts

-- Control Report Joins --
left join person_identity pie on pie.personid = pi.personid
and pie.identitytype = 'EmpNo'
and current_timestamp between pie.createts and pie.endts

left join eventname en on en.eventname = pba.eventname
---------------------------
 
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts 
  and pbe.createts > ?::timestamp     
  and de.selectedoption = 'Y'
  and pbelast.benefitcoverageid is not null

  /* DEATH EVENTS - EE must have surviving dependents to get included on QE file  */
  and pe.personid in   

(  select distinct pe.personid
 
        from person_employment pe
	left join edi.edi_last_update elu on elu.feedid = 'AXU_Infinisource_Cobra_QE_Export'
        join person_benefit_action pba
          on pba.personid = pe.personid
         and pba.eventeffectivedate >= elu.lastupdatets::date  
         and pba.eventname in ('DEA','DTH')   
	 and current_timestamp between pba.createts and pba.endts
        
        JOIN person_bene_election pbe 
          on pbe.personid = pba.personid 
         and pbe.personbenefitactionpid = pba.personbenefitactionpid  
         and pbe.selectedoption = 'Y' 
         and pbe.benefitelection <> 'W'
         and pbe.benefitsubclass in ('10','11','14','60')
         and pe.effectivedate - interval '1 day' <= pbe.effectivedate 
         
        join person_dependent_relationship pdr
          on pdr.personid = pbe.personid
         and current_date between pdr.effectivedate and pdr.enddate
         and current_timestamp between pdr.createts and pdr.endts  
        
        join dependent_enrollment de
          on de.personid = pdr.personid
         and de.dependentid = pdr.dependentid
         and de.selectedoption = 'Y'
         and de.benefitplanid = pbe.benefitplanid
         and de.benefitsubclass = pbe.benefitsubclass
          and pba.eventeffectivedate - interval '1 day' between de.effectivedate and de.enddate
         and current_timestamp between de.createts and de.endts 

        where current_date between pe.effectivedate and pe.enddate
          and current_timestamp between pe.createts and pe.endts
  ) 
   

   UNION ---------------------------------------------------------------------------------------------------------------------------------------
 
 select

 pi.personid
,'FSA DECEASED EE' ::varchar(30) as qsource 
,'0' as dependentid
,'4' ::char(10) as sort_seq
,pn.name
,'OFC' ::char(3) as recordtype
,case when pbe.benefitplanid = lookup.benefitplanid::int then lookup.value1 end ::char(15) as plan_code
,case when pbe.benefitplanid = lookup.benefitplanid::int then lookup.value2 end ::char(15) as coverage_code 
,case when pbe.benefitplanid = lookup.benefitplanid::int then lookup.value3 end ::char(15) as option_code
,case when pbe.benefitsubclass = '60' then to_char(pbe.enddate,'YYYY-MM-DD') end ::char(10) as loss_of_coverage_date  
,to_char(pba.eventeffectivedate,'YYYY-MM-DD')::char(10) as event_date 
,case when pbe.benefitsubclass = '60' then cast(poc.employeerate as dec(18,2)) else null end  ::char(7) as premium  
,case when pbe.benefitsubclass = '60' then cast(poc.employeerate as dec(18,2)) else null end  ::char(7) as premium_not_used
,' ' ::char(2) as day_due
,' ' ::char(10) as waiting_period_begin
,' ' ::char(10) as coverage_begin 

-- Control Report Fields --
,pie.identity ::varchar(15) as empno
,pn.fname || ' ' || pn.lname ::varchar(50) as empname
,en.description ::varchar(50) as eventtype
,pba.createts ::varchar(20) as eventcreatets
,pba.eventeffectivedate ::varchar(10) as eventdate
,pbelast.effectivedate ::varchar(10) as benefitstart
,pbelast.enddate ::varchar(10) as benefitend
,pbelast.coverageamount ::char(10) as coverageamount
---------------------------      

from person_identity pi

left join edi.edi_last_update elu on elu.feedid = 'AXU_Infinisource_Cobra_QE_Export'

left join person_names pn
  on pn.personid = pi.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts 

left join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts

left join (select personid, eventname, personbenefitactionpid, max(eventeffectivedate) as eventeffectivedate,max(createts) as createts,
rank() over (partition by personid order by max(eventeffectivedate) desc) as rank
from person_benefit_action
where current_timestamp between createts and endts and eventname in ('DEA','DTH') 
group by 1,2,3) pba on pba.personid = pe.personid and pba.rank = 1 

LEFT JOIN person_bene_election pbe
  on pbe.personid = pba.personid 
 and pbe.personbenefitactionpid = pba.personbenefitactionpid  
 and pbe.selectedoption = 'Y' 
 and pbe.benefitelection <> 'W'
 and pbe.benefitsubclass in ('60')
/*
For cobra - need to make sure that they had elected benefit coverage on their last day of employment 
(effectivedate - 1 day of term record) is between the effectivedate 
and enddate of the person_bene_election row with benefitelection = 'E' 
*/
 AND pbe.effectivedate < pbe.enddate
 AND current_timestamp between pbe.createts AND pbe.endts
 and pe.effectivedate - interval '1 day' < pbe.effectivedate  

-- to be qualified for cobra the emp must have participated in employer's health care plan  
-- Double ranked join to check that record previous to the term was elected
left join (select pbe.personid,pba.eventname,pbe.benefitelection,pbe.benefitcoverageid,pbe.benefitplanid,pbe.benefitsubclass,pbe.coverageamount,max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate, rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
		from person_bene_election pbe
		left join person_benefit_action pba on pba.personid = pbe.personid
		left join (select pbe.personid,pba.eventname,pbe.benefitelection,pbe.benefitcoverageid,max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate, rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
				from person_bene_election pbe
				left join person_benefit_action pba on pba.personid = pbe.personid
				where pbe.benefitsubclass in ('60') and pbe.selectedoption = 'Y' and pba.eventname in ('DEA','DTH') and pbe.benefitelection = 'T'
					and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate
					group by 1,2,3,4 order by 2,1,7) pbeno on pbeno.personid = pbe.personid and pbeno.rank = 1
                 where pbe.benefitsubclass in ('60') and pbe.selectedoption = 'Y' and pba.eventname in ('DEA','DTH')
                        and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate and pbeno.effectivedate <> pbe.effectivedate
                         group by 1,2,3,4,5,6,7 order by 2,1,8) pbelast on pbelast.personid = pbe.personid and pbelast.rank = 1

---------------------------------------------
-- ETVID LOOKUP TABLE JOIN --
---------------------------------------------
LEFT JOIN  (select lp.lookupid, key1 as benefitplanid, value1,value2,value3,value4,value5,value6,lp.effectivedate,lp.enddate from edi.lookup lp
    		join edi.lookup_schema els on lp.lookupid = els.lookupid and els.lookupname = 'AXU_Infinisource_Cobra_QE_Export'
			where lp.effectivedate < lp.enddate and current_timestamp between lp.createts and lp.endts
		) lookup on lookup.benefitplanid::int = pbe.benefitplanid and pbelast.enddate between lookup.effectivedate and lookup.enddate 
-----------------------------------------------
            
left join personbenoptioncostl poc
  on poc.personid = pbe.personid
 and poc.benefitoptionid = pbe.benefitoptionid
 and poc.personbeneelectionpid = pbe.personbeneelectionpid
 and poc.costsby = 'M'      

left join benefit_coverage_desc bcd
  on bcd.benefitcoverageid = pbe.benefitcoverageid
 and current_date between bcd.effectivedate and bcd.enddate
 and current_timestamp between bcd.createts and bcd.endts

left join benefit_plan_desc bpd
  on bpd.benefitsubclass = pbe.benefitsubclass
 and bpd.benefitplanid = pbe.benefitplanid
 and current_date between bpd.effectivedate and bpd.enddate
 and current_timestamp between bpd.createts and bpd.endts            

-- Control Report Joins --
left join person_identity pie on pie.personid = pi.personid
and pie.identitytype = 'EmpNo'
and current_timestamp between pie.createts and pie.endts

left join eventname en on en.eventname = pba.eventname
---------------------------

where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts 
  and pbe.createts > ?::timestamp   
  and pbelast.benefitcoverageid is not null 
  /* DEATH EVENTS - EE must have surviving dependents to get included on QE file  */
  and pe.personid in   

(  select distinct pe.personid
 
        from person_employment pe
	left join edi.edi_last_update elu on elu.feedid = 'AXU_Infinisource_Cobra_QE_Export'
        join person_benefit_action pba
          on pba.personid = pe.personid
         and pba.eventeffectivedate >= elu.lastupdatets::date  
         and pba.eventname in ('DEA','DTH')   
	 and current_timestamp between pba.createts and pba.endts
        
        JOIN person_bene_election pbe 
          on pbe.personid = pba.personid 
         and pbe.personbenefitactionpid = pba.personbenefitactionpid  
         and pbe.selectedoption = 'Y' 
         and pbe.benefitelection <> 'W'
         and pbe.benefitsubclass in ('10','11','14','60')
         and pe.effectivedate - interval '1 day' <= pbe.effectivedate 
         
        join person_dependent_relationship pdr
          on pdr.personid = pbe.personid
         and current_date between pdr.effectivedate and pdr.enddate
         and current_timestamp between pdr.createts and pdr.endts  
        
        join dependent_enrollment de
          on de.personid = pdr.personid
         and de.dependentid = pdr.dependentid
         and de.selectedoption = 'Y'
         and de.benefitplanid = pbe.benefitplanid
         and de.benefitsubclass = pbe.benefitsubclass
          and pba.eventeffectivedate - interval '1 day' between de.effectivedate and de.enddate
         and current_timestamp between de.createts and de.endts 

        where current_date between pe.effectivedate and pe.enddate
          and current_timestamp between pe.createts and pe.endts
  ) 

UNION ---------------------------------------------------------------------------------------------------------------------------------------
   
select

 pi.personid
,'DIVORCED SPOUSE/CHILDREN' ::varchar(30) as qsource 
,pdr.dependentid as dependentid
,'4' ::char(10) as sort_seq
,pnd.name
,'OFC' ::char(3) as recordtype
,case when de.benefitplanid = lookup.benefitplanid::int then lookup.value1 end ::char(15) as plan_code
,case when de.benefitplanid = lookup.benefitplanid::int then lookup.value2 end ::char(15) as coverage_code  
,case when de.benefitplanid = lookup.benefitplanid::int and de.benefitsubclass = '10' and pbelast10.benefitcoverageid = '1' then lookup.value3						
      when de.benefitplanid = lookup.benefitplanid::int and de.benefitsubclass = '10' and pbelast10.benefitcoverageid in ('2','3','11','16') then lookup.value4
      when de.benefitplanid = lookup.benefitplanid::int and de.benefitsubclass = '10' and pbelast10.benefitcoverageid in ('5','8','10','12','13','14','15','17') then lookup.value5
      when de.benefitplanid = lookup.benefitplanid::int and de.benefitsubclass = '11' and pbelast11.benefitcoverageid = '1' then lookup.value3     
      when de.benefitplanid = lookup.benefitplanid::int and de.benefitsubclass = '11' and pbelast11.benefitcoverageid in ('2','3','11','16') then lookup.value4
      when de.benefitplanid = lookup.benefitplanid::int and de.benefitsubclass = '11' and pbelast11.benefitcoverageid in ('5','8','10','12','13','14','15','17') then lookup.value5
      when de.benefitplanid = lookup.benefitplanid::int and de.benefitsubclass = '14' and pbelast14.benefitcoverageid = '1' then lookup.value3    
      when de.benefitplanid = lookup.benefitplanid::int and de.benefitsubclass = '14' and pbelast14.benefitcoverageid in ('2','16') then lookup.value4
      when de.benefitplanid = lookup.benefitplanid::int and de.benefitsubclass = '14' and pbelast14.benefitcoverageid in ('3','9','10') then lookup.value5
      when de.benefitplanid = lookup.benefitplanid::int and de.benefitsubclass = '14' and pbelast14.benefitcoverageid in ('5','8','10','12','13','14','15','17') then lookup.value6
      when de.benefitplanid = lookup.benefitplanid::int and de.benefitsubclass = '60' then lookup.value3
      else null end ::char(15) as option_code
,case when pbemed.benefitsubclass = '10' then to_char(pbelast10.enddate,'YYYY-MM-DD')      
      when pbednt.benefitsubclass = '11' then to_char(pbelast11.enddate,'YYYY-MM-DD')
      when pbevsn.benefitsubclass = '14' then to_char(pbelast14.enddate,'YYYY-MM-DD')
      when pbemfsa.benefitsubclass = '60' then to_char(pbelast60.enddate,'YYYY-MM-DD') end ::char(10) as loss_of_coverage_date   
,to_char(pba.eventeffectivedate,'YYYY-MM-DD')::char(10) as event_date   
,case when pbe.benefitsubclass = '60' then cast(pocmfsa.employeerate as dec(18,2)) else null end  ::char(7) as premium  
,case when pbe.benefitsubclass = '60' then cast(pocmfsa.employeerate as dec(18,2)) 
      when pbe.benefitsubclass = '10' then cast(pocmed.employeerate as dec(18,2)) 
      when pbe.benefitsubclass = '11' then cast(pocdnt.employeerate as dec(18,2))
      when pbe.benefitsubclass = '14' then cast(pocvsn.employeerate as dec(18,2))
      else null end  ::char(7) as premium_not_used
,' ' ::char(2) as day_due
,' ' ::char(10) as waiting_period_begin
,' ' ::char(10) as coverage_begin  

-- Control Report Fields --
,pie.identity ::varchar(15) as empno
,pnd.fname || ' ' || pnd.lname ::varchar(50) as empname
,en.description ::varchar(50) as eventtype
,pba.createts ::varchar(20) as eventcreatets
,pba.eventeffectivedate ::varchar(10) as eventdate
,pbe.effectivedate ::varchar(10) as benefitstart
,pbe.enddate ::varchar(10) as benefitend
,case when pbelast60.benefitsubclass = '60' then pbelast60.coverageamount end::char(10) as coverageamount
---------------------------     

from person_identity pi

left join edi.edi_last_update elu on elu.feedid = 'AXU_Infinisource_Cobra_QE_Export'

left join person_identity pie
  on pie.personid = pi.personid
 and pie.identitytype = 'EmpNo'
 and current_timestamp between pie.createts and pie.endts
 
left join person_vitals pv
  on pv.personid = pi.personid
 and current_date between pv.effectivedate and pv.enddate
 and current_timestamp between pv.createts and pv.endts 

left join person_names pn
  on pn.personid = pi.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts 

left join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts

left join person_address pa 
  on pa.personid = pe.personid
 and pa.addresstype = 'Res'
 and current_date between pa.effectivedate and pa.enddate
 and current_timestamp between pa.createts and pa.endts

left join (select personid, eventname, personbenefitactionpid, max(eventeffectivedate) as eventeffectivedate,max(createts) as createts,
rank() over (partition by personid order by max(eventeffectivedate) desc) as rank
from person_benefit_action
where current_timestamp between createts and endts and eventname in ('DIV') 
group by 1,2,3) pba on pba.personid = pe.personid and pba.rank = 1 

LEFT JOIN person_bene_election pbe
  on pbe.personid = pba.personid 
 and pbe.personbenefitactionpid = pba.personbenefitactionpid  
 and pbe.selectedoption = 'Y' 
 and pbe.benefitelection <> 'W'
 and pbe.benefitsubclass in ('10','11','14','60')
/*
For cobra - need to make sure that they had elected benefit coverage on their last day of employment 
(effectivedate - 1 day of term record) is between the effectivedate 
and enddate of the person_bene_election row with benefitelection = 'E' 
*/
 AND pbe.effectivedate < pbe.enddate
 AND current_timestamp between pbe.createts AND pbe.endts
 and pe.effectivedate - interval '1 day' < pbe.effectivedate  

--------------------------
-- PBE LAST JOINS --
--------------------------
-- to be qualified for cobra the emp must have participated in employer's health care plan  
-- Double ranked join to check that record previous to the term was elected
left join (select pbe.personid,pba.eventname,pbe.benefitelection,pbe.benefitcoverageid,pbe.benefitplanid,pbe.benefitsubclass,pbe.compplanid,max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate, rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
		from person_bene_election pbe
		left join person_benefit_action pba on pba.personid = pbe.personid
		left join (select pbe.personid,pba.eventname,pbe.benefitelection,pbe.benefitcoverageid,max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate, rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
				from person_bene_election pbe
				left join person_benefit_action pba on pba.personid = pbe.personid
				where pbe.benefitsubclass in ('10') and pbe.selectedoption = 'Y' and pba.eventname in ('DIV') --and pbe.benefitelection = 'T'
					and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate
					group by 1,2,3,4 order by 2,1,7) pbeno on pbeno.personid = pbe.personid and pbeno.rank = 1
                 where pbe.benefitsubclass in ('10') and pbe.selectedoption = 'Y' and pba.eventname in ('DIV')
                        and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate and pbeno.effectivedate <> pbe.effectivedate
                         group by 1,2,3,4,5,6,7 order by 2,1,8) pbelast10 on pbelast10.personid = pbe.personid and pbelast10.rank = 1

-- to be qualified for cobra the emp must have participated in employer's health care plan  
-- Double ranked join to check that record previous to the term was elected
left join (select pbe.personid,pba.eventname,pbe.benefitelection,pbe.benefitcoverageid,pbe.benefitplanid,pbe.benefitsubclass,pbe.compplanid,max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate, rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
		from person_bene_election pbe
		left join person_benefit_action pba on pba.personid = pbe.personid
		left join (select pbe.personid,pba.eventname,pbe.benefitelection,pbe.benefitcoverageid,max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate, rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
				from person_bene_election pbe
				left join person_benefit_action pba on pba.personid = pbe.personid
				where pbe.benefitsubclass in ('11') and pbe.selectedoption = 'Y' and pba.eventname in ('DIV') --and pbe.benefitelection = 'T'
					and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate
					group by 1,2,3,4 order by 2,1,7) pbeno on pbeno.personid = pbe.personid and pbeno.rank = 1
                 where pbe.benefitsubclass in ('11') and pbe.selectedoption = 'Y' and pba.eventname in ('DIV')
                        and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate and pbeno.effectivedate <> pbe.effectivedate
                         group by 1,2,3,4,5,6,7 order by 2,1,8) pbelast11 on pbelast11.personid = pbe.personid and pbelast11.rank = 1

-- to be qualified for cobra the emp must have participated in employer's health care plan  
-- Double ranked join to check that record previous to the term was elected
left join (select pbe.personid,pba.eventname,pbe.benefitelection,pbe.benefitcoverageid,pbe.benefitplanid,pbe.benefitsubclass,pbe.compplanid,max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate, rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
		from person_bene_election pbe
		left join person_benefit_action pba on pba.personid = pbe.personid
		left join (select pbe.personid,pba.eventname,pbe.benefitelection,pbe.benefitcoverageid,max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate, rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
				from person_bene_election pbe
				left join person_benefit_action pba on pba.personid = pbe.personid
				where pbe.benefitsubclass in ('14') and pbe.selectedoption = 'Y' and pba.eventname in ('DIV') --and pbe.benefitelection = 'T'
					and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate
					group by 1,2,3,4 order by 2,1,7) pbeno on pbeno.personid = pbe.personid and pbeno.rank = 1
                 where pbe.benefitsubclass in ('14') and pbe.selectedoption = 'Y' and pba.eventname in ('DIV')
                        and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate and pbeno.effectivedate <> pbe.effectivedate
                         group by 1,2,3,4,5,6,7 order by 2,1,8) pbelast14 on pbelast14.personid = pbe.personid and pbelast14.rank = 1

-- to be qualified for cobra the emp must have participated in employer's health care plan  
-- Double ranked join to check that record previous to the term was elected
left join (select pbe.personid,pba.eventname,pbe.benefitelection,pbe.benefitcoverageid,pbe.benefitplanid,pbe.benefitsubclass,pbe.coverageamount,max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate, rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
		from person_bene_election pbe
		left join person_benefit_action pba on pba.personid = pbe.personid
		left join (select pbe.personid,pba.eventname,pbe.benefitelection,pbe.benefitcoverageid,max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate, rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
				from person_bene_election pbe
				left join person_benefit_action pba on pba.personid = pbe.personid
				where pbe.benefitsubclass in ('60') and pbe.selectedoption = 'Y' and pba.eventname in ('DIV') --and pbe.benefitelection = 'T'
					and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate
					group by 1,2,3,4 order by 2,1,7) pbeno on pbeno.personid = pbe.personid and pbeno.rank = 1
                 where pbe.benefitsubclass in ('60') and pbe.selectedoption = 'Y' and pba.eventname in ('DIV')
                        and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate and pbeno.effectivedate <> pbe.effectivedate
                         group by 1,2,3,4,5,6,7 order by 2,1,8) pbelast60 on pbelast60.personid = pbe.personid and pbelast60.rank = 1

---------------------------------------------
-- ETVID LOOKUP TABLE JOIN --
---------------------------------------------
LEFT JOIN  (select lp.lookupid, key1 as benefitplanid, value1,value2,value3,value4,value5,value6,lp.effectivedate,lp.enddate from edi.lookup lp
    		join edi.lookup_schema els on lp.lookupid = els.lookupid and els.lookupname = 'AXU_Infinisource_Cobra_QE_Export'
			where lp.effectivedate < lp.enddate and current_timestamp between lp.createts and lp.endts
		) lookup on lookup.benefitplanid::int = pbe.benefitplanid and pbe.effectivedate between lookup.effectivedate and lookup.enddate


--- medical
left join (select personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid, max(effectivedate) as effectivedate, max(enddate) as enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election where benefitsubclass = '10' and benefitelection = 'E' and selectedoption = 'Y' and current_timestamp between createts and endts and effectivedate < enddate
            group by personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid) pbemed on pbemed.personid = pbe.personid and pbemed.rank = 1          

left join personbenoptioncostl pocmed
  on pocmed.personid = pbemed.personid
 and pocmed.personbeneelectionpid = pbemed.personbeneelectionpid
 and pocmed.costsby = 'M'
 
--- dental
left join (select personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid, max(effectivedate) as effectivedate, max(enddate) as enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election where benefitsubclass = '11' and benefitelection = 'E' and selectedoption = 'Y' and current_timestamp between createts and endts and effectivedate < enddate
            group by personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid) pbednt on pbednt.personid = pbe.personid and pbednt.rank = 1       

left join personbenoptioncostl pocdnt
  on pocdnt.personid = pbednt.personid
 and pocdnt.personbeneelectionpid = pbednt.personbeneelectionpid
 and pocdnt.costsby = 'M' 

--- vision
left join (select personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid,personbeneelectionpid, max(effectivedate) as effectivedate, max(enddate) as enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election where benefitsubclass = '14' and benefitelection = 'E' and selectedoption = 'Y' and current_timestamp between createts and endts and effectivedate < enddate
            group by personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid) pbevsn on pbevsn.personid = pbe.personid and pbevsn.rank = 1                       
                  
left join personbenoptioncostl pocvsn
  on pocvsn.personid = pbevsn.personid
 and pocvsn.personbeneelectionpid = pbevsn.personbeneelectionpid
 and pocvsn.costsby = 'M'
       
--- medical fsa
left join (select personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid, max(effectivedate) as effectivedate, max(enddate) as enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election where benefitsubclass = '60' and benefitelection = 'E' and selectedoption = 'Y' and current_timestamp between createts and endts and effectivedate < enddate
            group by personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid) pbemfsa on pbemfsa.personid = pbe.personid and pbemfsa.rank = 1   

left join personbenoptioncostl pocmfsa
  on pocmfsa.personid = pbemfsa.personid
 and pocmfsa.personbeneelectionpid = pbemfsa.personbeneelectionpid
 and pocmfsa.costsby = 'M'             

----------------------------

left join person_dependent_relationship pdr
  on pdr.personid = pbe.personid
 and current_date between pdr.effectivedate and pdr.enddate
 and current_timestamp between pdr.createts and pdr.endts  

left join dependent_enrollment de
  on de.personid = pbe.personid
 and de.dependentid = pdr.dependentid
 and de.selectedoption = 'Y'
 and de.benefitplanid = pbe.benefitplanid
 and de.benefitsubclass = pbe.benefitsubclass
 and pba.eventeffectivedate - interval '1 day' between de.effectivedate and de.enddate 
 and current_timestamp between de.createts and de.endts  
-- Exclude deps that started new coverage after DIV event       
 and de.dependentid not in 
 (select de.dependentid from dependent_enrollment de
   left join person_dependent_relationship pdr on pdr.dependentid = de.dependentid and current_date between pdr.effectivedate and pdr.enddate and current_timestamp between pdr.createts and pdr.endts and pdr.dependentrelationship in ('C','S','D','NS','ND','NC')
   left join person_benefit_action pba on pba.personid = pdr.personid and pba.eventname = 'DIV'
   where de.effectivedate < de.enddate and current_timestamp between de.createts and de.endts and de.benefitsubclass in ('10','11','14','60') and pba.eventeffectivedate = de.effectivedate and de.selectedoption = 'Y') 

LEFT JOIN person_names pnd 
  ON pnd.personid = pdr.dependentid 
 and pnd.nametype = 'Dep' 
 and current_date between pnd.effectivedate and pnd.enddate
 and current_timestamp between pnd.createts and pnd.endts    

join person_maritalstatus pm
  on pm.personid = pbe.personid 
 and current_date between pm.effectivedate and pm.enddate
 and current_timestamp between pm.createts and pm.endts   

-- Control Report Joins --

left join eventname en on en.eventname = pba.eventname
---------------------------                               

where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts  
  and de.selectedoption = 'Y'
  and pbe.createts > ?::timestamp
    
UNION ---------------------------------------------------------------------------------------------------------------------------------------

select
 pi.personid
,'ACTIVE EE TERMED DEP' ::varchar(30) as qsource 
,pdr.dependentid as dependentid
,'4' ::char(10) as sort_seq
,pnd.name
,'OFC' ::char(3) as recordtype
,case when de.benefitplanid = lookup.benefitplanid::int then lookup.value1 end ::char(15) as plan_code
,case when de.benefitplanid = lookup.benefitplanid::int then lookup.value2 end ::char(15) as coverage_code  
,case when de.benefitplanid = lookup.benefitplanid::int and de.benefitsubclass = '10' and pbelast.benefitcoverageid = '1' then lookup.value3						
      when de.benefitplanid = lookup.benefitplanid::int and de.benefitsubclass = '10' and pbelast.benefitcoverageid in ('2','3','11','16') then lookup.value4
      when de.benefitplanid = lookup.benefitplanid::int and de.benefitsubclass = '10' and pbelast.benefitcoverageid in ('5','8','10','12','13','14','15','17') then lookup.value5
      when de.benefitplanid = lookup.benefitplanid::int and de.benefitsubclass = '11' and pbelast.benefitcoverageid = '1' then lookup.value3     
      when de.benefitplanid = lookup.benefitplanid::int and de.benefitsubclass = '11' and pbelast.benefitcoverageid in ('2','3','11','16') then lookup.value4
      when de.benefitplanid = lookup.benefitplanid::int and de.benefitsubclass = '11' and pbelast.benefitcoverageid in ('5','8','10','12','13','14','15','17') then lookup.value5
      when de.benefitplanid = lookup.benefitplanid::int and de.benefitsubclass = '14' and pbelast.benefitcoverageid = '1' then lookup.value3    
      when de.benefitplanid = lookup.benefitplanid::int and de.benefitsubclass = '14' and pbelast.benefitcoverageid in ('2') then lookup.value4
      when de.benefitplanid = lookup.benefitplanid::int and de.benefitsubclass = '14' and pbelast.benefitcoverageid in ('3','9','10') then lookup.value5
      when de.benefitplanid = lookup.benefitplanid::int and de.benefitsubclass = '14' and pbelast.benefitcoverageid in ('5','8','10','12','13','14','15','17') then lookup.value6
      when de.benefitplanid = lookup.benefitplanid::int and de.benefitsubclass = '60' then lookup.value3
      else null end ::char(15) as option_code
,to_char(de.enddate,'YYYY-MM-DD') ::char(10) as loss_of_coverage_date 
,to_char(pba.eventeffectivedate,'YYYY-MM-DD')::char(10) as event_date   
,case when pbe.benefitsubclass = '60' then cast(pocmfsa.employeerate as dec(18,2)) else null end  ::char(7) as premium  
,case when pbe.benefitsubclass = '60' then cast(pocmfsa.employeerate as dec(18,2)) 
      when pbe.benefitsubclass = '10' then cast(pocmed.employeerate as dec(18,2)) 
      when pbe.benefitsubclass = '11' then cast(pocdnt.employeerate as dec(18,2))
      when pbe.benefitsubclass = '14' then cast(pocvsn.employeerate as dec(18,2))
      else null end  ::char(7) as premium_not_used
,' ' ::char(2) as day_due
,' ' ::char(10) as waiting_period_begin
,' ' ::char(10) as coverage_begin   

-- Control Report Fields --
,pie.identity ::varchar(15) as empno
,pnd.fname || ' ' || pnd.lname ::varchar(50) as empname
,en.description ::varchar(50) as eventtype
,pba.createts ::varchar(20) as eventcreatets
,pba.eventeffectivedate ::varchar(10) as eventdate
,pbelast.effectivedate ::varchar(10) as benefitstart
,pbelast.enddate ::varchar(10) as benefitend
,case when pbelast.benefitsubclass = '60' then pbelast.coverageamount end::char(10) as coverageamount
---------------------------

from person_identity pi

left join edi.edi_last_update elu on elu.feedid = 'AXU_Infinisource_Cobra_QE_Export'

left join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts

left join person_address pa 
  on pa.personid = pe.personid
 and pa.addresstype = 'Res'
 and current_date between pa.effectivedate and pa.enddate
 and current_timestamp between pa.createts and pa.endts

left join (select personid, eventname, personbenefitactionpid, max(eventeffectivedate) as eventeffectivedate,max(createts) as createts,
rank() over (partition by personid order by max(eventeffectivedate) desc) as rank
from person_benefit_action
where current_timestamp between createts and endts and eventname in ('DepAge') 
group by 1,2,3) pba on pba.personid = pe.personid and pba.rank = 1 

LEFT JOIN person_bene_election pbe
  on pbe.personid = pba.personid 
 and pbe.personbenefitactionpid = pba.personbenefitactionpid  
 and pbe.selectedoption = 'Y' 
 and pbe.benefitelection <> 'W'
 and pbe.benefitsubclass in ('10','11','14','60')
/*
For cobra - need to make sure that they had elected benefit coverage on their last day of employment 
(effectivedate - 1 day of term record) is between the effectivedate 
and enddate of the person_bene_election row with benefitelection = 'E' 
*/
 AND pbe.effectivedate < pbe.enddate
 AND current_timestamp between pbe.createts AND pbe.endts
 and pe.effectivedate - interval '1 day' < pbe.effectivedate  

-- to be qualified for cobra the emp must have participated in employer's health care plan  
-- Double ranked join to check that record previous to the term was elected
left join (select pbe.personid,pba.eventname,pbe.benefitelection,pbe.benefitcoverageid,pbe.benefitplanid,pbe.benefitsubclass,pbe.coverageamount,max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate, rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
		from person_bene_election pbe
		left join person_benefit_action pba on pba.personid = pbe.personid
		left join (select pbe.personid,pba.eventname,pbe.benefitelection,pbe.benefitcoverageid,pbe.benefitsubclass,max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate, rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
				from person_bene_election pbe
				left join person_benefit_action pba on pba.personid = pbe.personid
				where pbe.benefitsubclass in ('10','11','14','60') and pbe.selectedoption = 'Y' and pba.eventname in ('DepAge') --and pbe.benefitelection = 'T'
					and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate
					group by 1,2,3,4,5 order by 2,1,7) pbeno on pbeno.personid = pbe.personid and pbeno.rank = 1
                 where pbe.benefitsubclass in ('10','11','14','60') and pbe.selectedoption = 'Y' and pba.eventname in ('DepAge')
                        and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate and pbeno.effectivedate <> pbe.effectivedate
                         group by 1,2,3,4,5,6,7 order by 2,1,8) pbelast on pbelast.personid = pbe.personid and pbelast.rank = 1

---------------------------------------------
-- ETVID LOOKUP TABLE JOIN --
---------------------------------------------
LEFT JOIN  (select lp.lookupid, key1 as benefitplanid, value1,value2,value3,value4,value5,value6,lp.effectivedate,lp.enddate from edi.lookup lp
    		join edi.lookup_schema els on lp.lookupid = els.lookupid and els.lookupname = 'AXU_Infinisource_Cobra_QE_Export'
			where lp.effectivedate < lp.enddate and current_timestamp between lp.createts and lp.endts
		) lookup on lookup.benefitplanid::int = pbelast.benefitplanid and pbelast.enddate between lookup.effectivedate and lookup.enddate

-----------------------------------------------
-- JOINS TO GET PREMIUM-NOT-USED --
----------------------------------------------
--- medical
left join (select personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid, max(effectivedate) as effectivedate, max(enddate) as enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election where benefitsubclass = '10' and benefitelection = 'E' and selectedoption = 'Y' and current_timestamp between createts and endts
            group by personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid) pbemed on pbemed.personid = pbe.personid and pbemed.rank = 1 

left join personbenoptioncostl pocmed
  on pocmed.personid = pbemed.personid
 and pocmed.personbeneelectionpid = pbemed.personbeneelectionpid
 and pocmed.costsby = 'M'    

--- dental
left join (select personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid, max(effectivedate) as effectivedate, max(enddate) as enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election where benefitsubclass = '11' and benefitelection = 'E' and selectedoption = 'Y' and current_timestamp between createts and endts
            group by personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid) pbednt on pbednt.personid = pbe.personid and pbednt.rank = 1    

left join personbenoptioncostl pocdnt
  on pocdnt.personid = pbednt.personid
 and pocdnt.personbeneelectionpid = pbednt.personbeneelectionpid
 and pocdnt.costsby = 'M'     

--- vision
left join (select personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid, max(effectivedate) as effectivedate, max(enddate) as enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election where benefitsubclass = '14' and benefitelection = 'E' and selectedoption = 'Y' and current_timestamp between createts and endts
            group by personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid) pbevsn on pbevsn.personid = pbe.personid and pbevsn.rank = 1    

left join personbenoptioncostl pocvsn
  on pocvsn.personid = pbevsn.personid
 and pocvsn.personbeneelectionpid = pbevsn.personbeneelectionpid
 and pocvsn.costsby = 'M'                  
                                          
--- medical fsa
left join (select personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid, max(effectivedate) as effectivedate, max(enddate) as enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election where benefitsubclass = '60' and benefitelection = 'E' and selectedoption = 'Y' and current_timestamp between createts and endts 
            group by personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid) pbemfsa on pbemfsa.personid = pbe.personid and pbemfsa.rank = 1    

left join personbenoptioncostl pocmfsa
  on pocmfsa.personid = pbemfsa.personid
 and pocmfsa.personbeneelectionpid = pbemfsa.personbeneelectionpid
 and pocmfsa.costsby = 'M'    

--------------------------------------------

left join person_dependent_relationship pdr
  on pdr.personid = pbelast.personid
 and current_date between pdr.effectivedate and pdr.enddate
 and current_timestamp between pdr.createts and pdr.endts  
 --and pdr.dependentrelationship in ('C','D','S','NC','ND','NS')

left join dependent_enrollment de
  on de.dependentid = pdr.dependentid
 and de.benefitsubclass = pbe.benefitsubclass
 and de.personid = pbe.personid
 and de.selectedoption = 'Y'
 and current_timestamp between de.createts and de.endts
 and pba.eventeffectivedate - interval '1 day' between de.effectivedate and de.enddate

LEFT JOIN person_names pnd 
  ON pnd.personid = pdr.dependentid 
 and pnd.nametype = 'Dep' 
 and current_date between pnd.effectivedate and pnd.enddate
 and current_timestamp between pnd.createts and pnd.endts

LEFT JOIN person_vitals pvd 
  ON pvd.personid = pdr.dependentid 
 and current_date between pvd.effectivedate and pvd.enddate
 and current_timestamp between pvd.createts and pvd.endts

-- Control Report Joins --
left join person_identity pie on pie.personid = pi.personid
and pie.identitytype = 'EmpNo'
and current_timestamp between pie.createts and pie.endts

left join eventname en on en.eventname = pba.eventname
---------------------------

where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts 
  and pbelast.benefitcoverageid is not null
  and de.dependentid is not null
  and de.benefitplanid = lookup.benefitplanid::int
  --and current_date - interval '26 years' > pvd.birthdate::date

  and pbe.createts > ?::timestamp    
     
order by 1,3,7;
