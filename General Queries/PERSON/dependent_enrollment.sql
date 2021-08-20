 
  SELECT 
 de.personid
,de.dependentid
,pn.name
,mindep.dependentrelationship
,de.selectedoption
,de.effectivedate
,de.benefitsubclass
,de.benefitplanid
,bs.benefitsubclassdesc
,bpd.benefitplandesc

from dependent_enrollment de
 join ( select pdr.personid,pdr.dependentid,pdr.dependentrelationship,min(pdr.effectivedate) AS mineffdt
          from person_dependent_relationship pdr 
         where pdr.effectivedate <= pdr.enddate and current_date < pdr.enddate 
           and current_timestamp between pdr.createts and pdr.endts
         group by pdr.personid, pdr.dependentid, pdr.dependentrelationship ) mindep on de.personid = mindep.personid and de.dependentid = mindep.dependentid
 join person_names pn
   on pn.personid = de.dependentid
  and pn.nametype = 'Dep'
  and current_date between pn.effectivedate and pn.enddate
  and current_timestamp between pn.createts and pn.endts
 join benefit_plan_desc bpd 
   on de.benefitplanid = bpd.benefitplanid 
  and greatest(current_date, mindep.mineffdt) >= bpd.effectivedate
  and greatest(current_date, mindep.mineffdt) <= bpd.enddate 
  and current_timestamp between de.createts AND de.endts
 join benefit_subclass bs on bpd.benefitsubclass = bs.benefitsubclass

 where greatest(current_date, mindep.mineffdt) >= de.effectivedate 
   and greatest(current_date, mindep.mineffdt) <= de.enddate 
   and current_timestamp between bpd.createts AND bpd.endts
   and bs.benefitsubclass in ('1W','1C','1I','13')
   and de.personid in ('2838','2676')
;
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 SELECT de.personid
    ,de.dependentid
    ,pn.name
   ,mindep.dependentrelationship
   -- ,de.effectivedate
    ,case when bs.benefitsubclass in ('30','3Y')  then 'X' else null end ::char(1) as STD
    ,case when bs.benefitsubclass in ('31') then 'X' else null end ::char(1) as LTD
    ,case when bs.benefitsubclass in ('1W') then 'X' else null end ::char(1) as CI
    ,case when bs.benefitsubclass in ('13') then 'X' else null end ::char(1) as ACD
    ,case when bs.benefitsubclass in ('1Hosp') then 'X' else null end ::char(1) as HI
   -- ,de.benefitplanid
   -- ,bs.benefitsubclassdesc
   -- ,bpd.benefitplandesc
    ,mindep.emplstatus

   FROM dependent_enrollment de
     JOIN ( SELECT pdr.personid,pdr.dependentid,pe.emplstatus,dependentrelationship,min(pdr.effectivedate) AS mineffdt
           FROM person_dependent_relationship pdr
           join person_employment pe on pe.personid = pdr.personid and current_date between pe.effectivedate and pe.enddate and current_timestamp between pe.createts and pe.endts
          WHERE pdr.effectivedate <= pdr.enddate AND pdr.enddate > 'now'::text::date AND now() >= pdr.createts AND now() <= pdr.endts
          GROUP BY pdr.personid, pdr.dependentid, pe.emplstatus,dependentrelationship) mindep ON de.personid = mindep.personid AND de.dependentid = mindep.dependentid
     JOIN benefit_plan_desc bpd ON de.benefitplanid = bpd.benefitplanid AND GREATEST('now'::text::date, mindep.mineffdt) >= bpd.effectivedate 
     AND GREATEST('now'::text::date, mindep.mineffdt) <= bpd.enddate AND now() >= de.createts AND now() <= de.endts
     JOIN benefit_subclass bs ON bpd.benefitsubclass = bs.benefitsubclass
     join person_names pn on pn.personid = de.dependentid and current_date between pn.effectivedate and pn.enddate and current_timestamp between pn.createts and pn.endts and pn.nametype in ('Dep','Legal')
  WHERE GREATEST('now'::text::date, mindep.mineffdt) >= de.effectivedate AND GREATEST('now'::text::date, mindep.mineffdt) <= de.enddate AND now() >= bpd.createts AND now() <= bpd.endts
 and  bs.benefitsubclass in ( '1W','13','30','3Y','31','1Hosp')
order by de.personid, de.dependentid;

select * from dependent_enrollment where dependentid = '11666' and benefitsubclass in ( '1W','13','30','3Y','31','1Hosp');
( SELECT pdr.personid,pdr.dependentid,pe.emplstatus,dependentrelationship,min(pdr.effectivedate) AS mineffdt
           FROM person_dependent_relationship pdr
           join person_employment pe on pe.personid = pdr.personid and current_date between pe.effectivedate and pe.enddate and current_timestamp between pe.createts and pe.endts
          WHERE pdr.effectivedate <= pdr.enddate AND pdr.enddate > 'now'::text::date AND now() >= pdr.createts AND now() <= pdr.endts and pdr.personid = '10081'
          GROUP BY pdr.personid, pdr.dependentid, pe.emplstatus,dependentrelationship);
          
select * from dependent_enrollment where dependentid = '11666' and benefitsubclass = '1W' and personid = '10081' and current_date between effectivedate and enddate and current_timestamp between createts and endts;         
join dependent_enrollment de
  on de.dependentid = pdr.dependentid
 and de.benefitsubclass = pbe.benefitsubclass
 and de.personid = pdr.personid
 and current_date between de.effectivedate and de.enddate
 and current_timestamp between de.createts and de.endts        
 
select * from person_dependent_relationship where personid = '10081' and current_date between effectivedate and enddate and current_timestamp between createts and endts;         
select * from person_vitals where personid = '10081';
join person_dependent_relationship pdr
  on pdr.personid = pbe.personid
 and current_date between pdr.effectivedate and pdr.enddate
 and current_timestamp between pdr.createts and pdr.endts   