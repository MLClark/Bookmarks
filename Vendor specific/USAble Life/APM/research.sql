--INSERT into edi.edi_last_update (feedid,lastupdatets) values ('APM_USAble_Life_Export','2019-03-06 00:00:00');
select * from edi.edi_last_update;
update edi.edi_last_update set lastupdatets = '2020-02-01 00:00:00' where feedid = 'APM_USAble_Life_Export'; ----'2020-02-01 00:00:00'



select * from person_employment where emplstatus = 'T';
select * from benefit_plan_desc where benefitsubclass in ('20','21','30','31','25','2Z') ;

select * from person_bene_election pbe where personid = '910' and benefitsubclass in ('20','21','30','31','25','2Z') ;

select * from person_bene_election pbe where personid = '932' 
 and pbe.selectedoption = 'Y' 
 and pbe.benefitelection <> 'W'
 and pbe.benefitsubclass in ('20','21','30','31','25','2Z')
 and ((pbe.enddate - interval '1 day' > pbe.effectivedate and pbe.benefitelection = 'E'))
 AND current_timestamp between pbe.createts and pbe.endts 


 and ((pe.effectivedate - interval '1 day' between pbe.effectivedate and pbe.enddate) or (pbe.enddate - interval '1 day' > pbe.effectivedate and pbe.benefitelection = 'E'))


(select distinct personid||benefitsubclass||effectivedate from person_bene_election
        join edi.edi_last_update elu on elu.feedid = 'APM_USAble_Life_Export'
       where current_timestamp between createts and endts and personid = '932'
         and benefitsubclass in ('20','21','30','31','25','2Z') and benefitelection = 'E' and selectedoption = 'Y' and effectivedate < enddate
         and enddate - interval '1 day' > effectivedate and effectivedate::date >= elu.lastupdatets::date) 
;
select *

 ( select personid, compamount, increaseamount, compevent, frequencycode, earningscode, max(createts) as createts, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate, RANK() OVER (PARTITION BY personid ORDER BY max(effectivedate)desc) AS RANK
              from person_compensation where effectivedate < enddate and current_timestamp between createts and endts
               and earningscode <> 'BenBase' and personid = '930'
             group by personid, compamount, increaseamount, compevent, frequencycode, earningscode)
;             

left join (select pbe.personid,pbe.benefitsubclass,pbe.benefitelection,pbe.selectedoption,pbe.eventdate,pbe.benefitplanid,pbe.benefitcoverageid,pbe.compplanid,pbe.personbeneelectionpid,pbe.coverageamount,
              max(pbe.effectivedate) as effectivedate,max(pbe.enddate) as enddate,max(pbe.createts) as createts,rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
             from person_bene_election pbe
             left join comp_plan_plan_year cppy on cppy.compplanid = pbe.compplanid and cppy.compplanplanyeartype = 'Bene' and ?::date between cppy.planyearstart and cppy.planyearend
             join edi.edi_lastupdate elu on elu.feedid = 'APM_USAble_Life_Export'
            where pbe.effectivedate < pbe.enddate and pbe.personid = '1728'
              and current_timestamp between pbe.createts and pbe.endts
              and pbe.benefitsubclass in ('20','21','30','31','25','2Z')
              and pbe.selectedoption = 'Y'
              and pbe.effectivedate between cppy.planyearstart and cppy.planyearend
            group by 1,2,3,4,5,6,7,8,9,10) 
            pbe on pbe.personid = pe.personid and pbe.rank = 1    


left join pers_pos pos
  on pos.personid = pe.personid 
 and current_date between pos.effectivedate and pos.enddate
 and current_timestamp between pos.createts and pos.endts 
 
 (select personid, scheduledhours, schedulefrequency, max(createts) as createts, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate, RANK() OVER (PARTITION BY personid ORDER BY max(effectivedate)desc) AS RANK
    from pers_pos  where effectivedate < enddate and current_timestamp between createts and endts and personid = '1347'
   group by personid, scheduledhours, schedulefrequency)

select * from person_names where lname like 'Weaver%';
select * from person_names where personid = '930';
select * from pers_pos where personid in ('1337');

--insert into edi.edi_last_update (feedid,lastupdatets) values ('APM_USAble_Life_Export','2019-10-01') 
