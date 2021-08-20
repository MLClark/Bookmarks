 (select personid, max(effectivedate) as effectivedate
        from person_bene_election 
       where current_date between effectivedate and enddate
         and current_timestamp between createts and endts
         and date_part('year',deductionstartdate::date)>=date_part('year',current_date::date)
         and benefitsubclass in ('30','31','21','2Z','2X','2CI','2CS','2SI','2SS','23','13')
         and benefitelection in ('E') and selectedoption = 'Y'
       group by 1) 















select * from person_bene_election where personid = '5220' and benefitsubclass in ('23') and current_timestamp between createts and endts and current_date between effectivedate and enddate;
select * from person_bene_election where personid = '5231' and benefitsubclass in ('21') and current_timestamp between createts and endts and current_date between effectivedate and enddate;

select * from person_bene_election where personid = '5231' and benefitsubclass in ('30') and current_timestamp between createts and endts and current_date between effectivedate and enddate;
select * from person_bene_election where personid = '5231' and benefitsubclass in ('31') and current_timestamp between createts and endts and current_date between effectivedate and enddate;


select * from person_bene_election where personid = '5231' and benefitsubclass in ('2Z') and current_timestamp between createts and endts and current_date between effectivedate and enddate;
select * from person_bene_election where personid = '5231' and benefitsubclass in ('2X') and current_timestamp between createts and endts and current_date between effectivedate and enddate;
select * from person_bene_election where personid = '5231' and benefitsubclass in ('2SI') and current_timestamp between createts and endts and current_date between effectivedate and enddate;
select * from person_bene_election where personid = '5231' and benefitsubclass in ('2SS') and current_timestamp between createts and endts and current_date between effectivedate and enddate;
select * from person_bene_election where personid = '5231' and benefitsubclass in ('2CI') and current_timestamp between createts and endts and current_date between effectivedate and enddate;
select * from person_bene_election where personid = '5231' and benefitsubclass in ('2CS') and current_timestamp between createts and endts and current_date between effectivedate and enddate;

select * from person_bene_election where personid = '5211' and benefitsubclass in ('13') and current_timestamp between createts and endts and current_date between effectivedate and enddate;


select * from person_employment where personid = '5231';

select * from edi.edi_last_update;
update edi.edi_last_update set lastupdatets = '2019-09-24 06:02:43' where feedid = 'AVS_Mutual_Of_Omaha_Carrier_Export'; --2019-09-24 06:02:43


select * from locationcodeslist;



select * from person_bene_election where personid = '5231' and benefitsubclass in ('21') and current_timestamp between createts and endts and current_date between effectivedate and enddate 
and selectedoption = 'Y' and benefitelection = 'E';
(select personid, benefitsubclass, benefitelection,  personbeneelectionpid, coverageamount, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election where benefitsubclass in ('21') and benefitelection in ('E','T') and selectedoption = 'Y' and current_timestamp between createts and endts and current_date between effectivedate and enddate
             and personid = '5231'
            group by personid, benefitsubclass, benefitelection, personbeneelectionpid, coverageamount )


(select personid, benefitsubclass, benefitelection,  personbeneelectionpid, coverageamount, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election where benefitsubclass in ('21') and benefitelection in ('E','T') and selectedoption = 'Y' and current_timestamp between createts and endts and current_date between effectivedate and enddate and personid = '5231'
            group by personid, benefitsubclass, benefitelection, personbeneelectionpid, coverageamount) pbebeevlife on pbebeevlife.personid = pbe.personid and pbebeevlife.coverageamount <> 0 and pbebeevlife.rank = 1 
              and pbebeevlife.personid in (select distinct personid from person_bene_election where benefitsubclass in ('21') and benefitelection = 'E' and selectedoption = 'Y' and current_timestamp between createts and endts and current_date between effectivedate and enddate  and personid = '5231' )            

select * from person_bene_election where personid = '5211' and benefitsubclass in ('13');

(select personid, benefitsubclass, benefitelection,  personbeneelectionpid, coverageamount, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election
            where benefitsubclass in  ('13') and benefitelection in ('E') and selectedoption = 'Y' and current_timestamp between createts and endts and effectivedate < enddate --and coverageamount > 0
              and personid = '5211'
            group by personid, benefitsubclass, benefitelection,  personbeneelectionpid, coverageamount)                    

select * from person_bene_election where personid = '5115' and benefitsubclass in ('30','31','21','2Z','2X','2CI','2CS','2SI','2SS','23','13');
select * from person_bene_election where personid = '5115' and benefitsubclass in ('23') and current_timestamp between createts and endts and current_date between effectivedate and enddate
--and benefitelection = 'E' and selectedoption = 'Y';
select * from person_bene_election where personid = '5331' and benefitsubclass in ('21') and current_timestamp between createts and endts and current_date between effectivedate and enddate
--and benefitelection = 'E' and selectedoption = 'Y';
select * from person_bene_election where personid = '5362' and benefitsubclass in ('30') and current_timestamp between createts and endts and current_date between effectivedate and enddate;
--and benefitelection = 'E' and selectedoption = 'Y';
select * from person_bene_election where personid = '6229' and benefitsubclass in ('31') and current_timestamp between createts and endts and current_date between effectivedate and enddate;
--and benefitelection = 'E' and selectedoption = 'Y';
select * from person_bene_election where personid = '5158' and benefitsubclass in ('2CI') and current_timestamp between createts and endts and current_date between effectivedate and enddate;
--and benefitelection = 'E' and selectedoption = 'Y';
select * from person_bene_election where personid = '5158' and benefitsubclass in ('2CS') and current_timestamp between createts and endts and current_date between effectivedate and enddate;
--and benefitelection = 'E' and selectedoption = 'Y';
select * from person_bene_election where personid = '5158' and benefitsubclass in ('2SI') and current_timestamp between createts and endts and current_date between effectivedate and enddate;
--and benefitelection = 'E' and selectedoption = 'Y';
select * from person_bene_election where personid = '5158' and benefitsubclass in ('2SS') and current_timestamp between createts and endts and current_date between effectivedate and enddate;
--and benefitelection = 'E' and selectedoption = 'Y';
select * from person_bene_election where personid = '5112' and benefitsubclass in ('13') and current_timestamp between createts and endts and current_date between effectivedate and enddate
and benefitelection = 'E' and selectedoption = 'Y';
(select personid, benefitsubclass, benefitelection,  personbeneelectionpid, coverageamount, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election where benefitsubclass in ('2SS') and selectedoption = 'Y' and current_timestamp between createts and endts and effectivedate < enddate
             and personid = '5231'
            group by personid, benefitsubclass, benefitelection, personbeneelectionpid, coverageamount);
(select personid, benefitsubclass, benefitelection,  personbeneelectionpid, coverageamount, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election where benefitsubclass in ('2SI') and benefitelection in ('E','T') and selectedoption = 'Y' and current_timestamp between createts and endts and effectivedate - interval '1 day'  < enddate
              and personid = '5231'
            group by personid, benefitsubclass, benefitelection, personbeneelectionpid, coverageamount);        





select * from person_employment where personid = '5353';


select * from person_bene_election where personid = '5153' and benefitsubclass in ('2Z') and current_timestamp between createts and endts and current_date between effectivedate and enddate;
select * from person_bene_election where personid = '5153' and benefitsubclass in ('2X') and current_timestamp between createts and endts and current_date between effectivedate and enddate;
select * from person_bene_election where personid = '5153' and benefitsubclass in ('2CI') and current_timestamp between createts and endts and current_date between effectivedate and enddate;
select * from person_bene_election where personid = '5153' and benefitsubclass in ('2CS') and current_timestamp between createts and endts and current_date between effectivedate and enddate;
select * from person_bene_election where personid = '5153' and benefitsubclass in ('2SI') and current_timestamp between createts and endts and current_date between effectivedate and enddate;
select * from person_bene_election where personid = '5153' and benefitsubclass in ('2SS') and current_timestamp between createts and endts and current_date between effectivedate and enddate;


select * from dependent_enrollment where personid = '5153';




(select personid, compamount, frequencycode, max(createts) as createts, max(effectivedate) as effectivedate, max(enddate) as enddate,rank() over (partition by personid order by max(createts), max(effectivedate) desc) as rank
             from person_compensation where compamount <> 0 
             and personid = '5120'
            group by personid, compamount, frequencycode);

select * from person_compensation where personid = '5120';

select * from person_bene_election where personid = '5120' and benefitsubclass in ('30','31','21','2Z','2X','2CI','2CS','2SI','2SS','23','13');

select * from person_bene_election where personid = '5109' and benefitsubclass in ('2X') and current_timestamp between createts and endts and effectivedate < enddate;

(select personid, benefitsubclass, benefitelection,  personbeneelectionpid, coverageamount, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election where benefitsubclass in ('23') and benefitelection in ('E','T') and selectedoption = 'Y' and current_timestamp between createts and endts and effectivedate < enddate
              and personid = '5231'
            group by personid, benefitsubclass, benefitelection, personbeneelectionpid, coverageamount)
            ;
            

select 
 pbe.personid
,pbe.benefitsubclass
,pbe.benefitcoverageid
,pdr.dependentid
,pn.lname,pn.fname
,pdr.dependentrelationship
,pnd.lname,pnd.fname
,to_char(pvd.birthdate,'YYYY-MM-DD')

from person_bene_election pbe
join person_dependent_relationship pdr
  on pdr.personid = pbe.personid
 and current_date between pdr.effectivedate and pdr.enddate
 and current_timestamp between pdr.createts and pdr.endts

left JOIN dependent_enrollment de
  on de.personid = pdr.personid
 and de.dependentid = pdr.dependentid
 AND de.selectedoption = 'Y'
 and de.benefitplanid = pbe.benefitplanid
 and de.benefitsubclass = pbe.benefitsubclass
 and current_date between de.effectivedate and de.enddate
 and current_timestamp between de.createts and de.endts

left join person_names pn
  on pn.personid = pbe.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts 
 
left join person_names pnd
  on pnD.personid = pdr.dependentid
 and current_date between pnD.effectivedate and pnD.enddate
 and current_timestamp between pnD.createts and pnD.endts
 and pnD.nametype = 'Dep' 

left join person_vitals pvD
  on pvD.personid = pdr.dependentid
 and current_date between pvD.effectivedate and pvD.enddate
 and current_timestamp between pvD.createts and pvD.endts 

where pbe.selectedoption = 'Y' and pbe.benefitelection = 'E'
  and current_date between pbe.effectivedate and pbe.enddate
  and current_timestamp between pbe.createts and pbe.endts
  and pbe.benefitsubclass in ('2Z','2X','13','2SI','2SS')
  and pbe.benefitcoverageid > '1'
  and pdr.dependentrelationship in ('DP','SP','D','S','C','ND','NS','NC')

ORDER BY 5


select * from person_bene_election where personid = '5144' and benefitsubclass = '23' ;

select * from person_bene_election where personid = '5144' and benefitsubclass in ('30','31','21','2Z','2X','2CI','2CS','2SI','2SS','23','13')
and selectedoption = 'Y' and benefitelection = 'E' and current_date between effectivedate and enddate and current_timestamp between createts and endts;
select * from person_names where personid = '5144';

select * from person_employment where personid = '6035';
(select personid, benefitsubclass, benefitelection,  personbeneelectionpid, coverageamount, eventdate, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election
            where benefitsubclass in  ('23') and benefitelection in ('E','T') and selectedoption = 'Y' and current_timestamp between createts and endts and effectivedate < enddate and coverageamount > 0
            and personid = '6035'
            group by personid, benefitsubclass, benefitelection,  personbeneelectionpid, coverageamount, eventdate)
            ;
            
            

select * from person_vitals where personid = '5266';
select * from person_vitals where personid = '5266' and current_timestamp between createts and endts and effectivedate < enddate;
select * from person_compensation where personid = '5120' and current_timestamp between createts and endts and effectivedate < enddate;
(select personid, compamount, frequencycode, max(effectivedate) as effecitvedate, max(enddate) as enddate, rank() over (partition by personid order by max(createts) desc) as rank
             from person_compensation where compamount > 0 and personid = '5120'
            group by personid, compamount, frequencycode);


(select personid, birthdate, gendercode, max(effectivedate) as effecitvedate rank() over (partition by personid order by max(effectivedate) desc) as rank
   from person_vitals where where current_timestamp between createts and endts and effectivedate < enddate)

select * from location_codes;

(select personid, compamount, frequencycode, max(effectivedate) as effecitvedate, max(enddate) as enddate,rank() over (partition by personid order by max(effectivedate) desc) as rank
             from person_compensation where current_timestamp between createts and endts and current_date between effectivedate and enddate and compamount <> 0 and enddate >= '2199-12-30' 
             and personid = '5203'
            group by personid, compamount, frequencycode) ;             
select * from person_compensation where personid = '5137';

(select personid, scheduledhours, max(createts) as createts, max(effectivedate) as effectivedate, max(enddate) as enddate,rank() over (partition by personid order by max(createts) desc) as rank
            from pers_pos where current_timestamp between createts and endts 
           group by personid, scheduledhours)            
            
            

select * from person_compensation where personid = '5135';
select * from person_compensation where personid = '5143';
select * from person_compensation where personid = '5183';
select * from person_compensation where personid = '5184';
select * from person_compensation where personid = '5895';
select * from person_compensation where personid = '6035';
select * from person_compensation where personid = '6133';
select * from person_compensation where personid = '6136';
select * from person_compensation where personid = '5106' order by 3;

select * from person_compensation where personid = '5895' order by 3;
select * from person_compensation where personid = '5184' order by 3;

--and current_date between effectivedate and enddate
and current_timestamp between createts and endts

select * from pspay_group_earnings;


select personid, max(percomppid) as percomppid
  from person_compensation 
 where current_timestamp between createts and endts
   and personid in ('5184')
   group by 1;

select personid, sum(compamount) as compamount, min(percomppid) as percomppid
  from person_compensation 
 where current_timestamp between createts and endts
   and personid in ('5184')
   group by 1; 






select * from person_bene_election 
 where current_date between effectivedate and enddate
   and current_timestamp between createts and endts
   and benefitsubclass in ('13')
   and benefitelection = 'E'
   group by 1;

select * from person_compensation where personid = '5115';
select * from pers_pos where personid = '5152'
--and current_date between effectivedate and enddate
   and current_timestamp between createts and endts;

select * from person_dependent_relationship where personid = '5224';
select * from dependent_enrollment where personid = '5224';
select * from benefit_plan_desc 

select distinct de.personid, de.dependentid, de.benefitsubclass, de.effectivedate, de.selectedoption, pdr.dependentrelationship, bcd.benefitcoveragedesc
              from dependent_enrollment de
              join person_dependent_relationship pdr
                on pdr.personid = de.personid
               and pdr.dependentrelationship in ('D','C','S','DP','SP')
               and current_date between pdr.effectivedate and pdr.enddate
               and current_timestamp between pdr.createts and pdr.endts
              join person_bene_election pbe 
                on pbe.personid = de.personid
               and current_date between pbe.effectivedate and pbe.enddate
               and current_timestamp between pbe.createts and pbe.endts
              join benefit_coverage_desc bcd
                on bcd.benefitcoverageid = pbe.benefitcoverageid
               and current_date between bcd.effectivedate and bcd.enddate
               and current_timestamp between bcd.createts and bcd.endts               
             where current_date between de.effectivedate and de.enddate
               and current_timestamp between de.createts and de.endts
               and de.benefitsubclass in ('13')





select * from dependent_enrollment;
select * from benefit_coverage_desc;

select dependentrelationship from person_dependent_relationship group by 1;
select * from dependent_relationship;
select * from benefit_plan_desc;


select personid, max(perlocpid) perlocpid 
  from person_locations
where current_date between effectivedate and enddate
  and current_timestamp between createts and endts
  and personid = '5896'
  group by 1
  ;  

select * from person_locations
where current_date between effectivedate and enddate
  and current_timestamp between createts and endts
  and personid = '5896'
  ;
select * from locationcodeslist where locationid = '16';

select * from location_codes where locationid = '16';
select * from benefit_plan_desc
where current_date between effectivedate and enddate
  and current_timestamp between createts and endts
  and benefitsubclass in ('30','31','21','2Z','2X','2CI','2CS','2SI','2SS','23','13')
  ;


SELECT * FROM DEPENDENT_ENROLLMENT WHERE BENEFITSUBCLASS IN  ('30','31','21','2Z','2X','2CI','2CS','2SI','2SS','23','13');
SELECT * FROM PERSON_BENE_ELECTION WHERE BENEFITSUBCLASS = '';  
  select * from locationcodeslist order by locationdescription;
  
select * from person_names where personid in ('5159');
select * from person_dependent_relationship where personid = '5159';  
select * from person_vitals where personid in ('5159','5851');
  
select distinct de.personid, de.dependentid, de.benefitsubclass  
  from dependent_enrollment de
  join person_dependent_relationship pdr
    on pdr.personid = de.personid
   and pdr.dependentrelationship in ('D','C','S')
   and current_date between pdr.effectivedate and pdr.enddate
   and current_timestamp between pdr.createts and pdr.endts
 where current_date between de.effectivedate and de.enddate
   and current_timestamp between de.createts and de.endts
   and de.benefitsubclass in ('30','31','21','2Z','2X','2CI','2CS','2SI','2SS','23','13')
   and pdr.personid = '5223'
   ;
   
select * from person_compensation   
where current_date between effectivedate and enddate
  and current_timestamp between createts and endts
  and personid = '5194'
  ;
   
  
select * from person_compensation 
where personid = '5106'
  ; 
select de.* 
  from dependent_enrollment de
  join person_dependent_relationship pdr
    on pdr.personid = de.personid
   and pdr.dependentrelationship in ('D','C','S')
   and current_date between pdr.effectivedate and pdr.enddate
   and current_timestamp between pdr.createts and pdr.endts
 where current_date between de.effectivedate and de.enddate
   and current_timestamp between de.createts and de.endts
   and de.benefitsubclass in ('30','31','21','2Z','2X','2CI','2CS','2SI','2SS','23','13')
   and pdr.personid = '5223'
   ;  
  
select * from person_vitals where personid = '5106';  

select * from benefit_plan_coverage
 where current_date between effectivedate and enddate
   and current_timestamp between createts and endts
   ;
   
select * from benefit_coverage_desc;   

select * from person_bene_election 
 where current_date between effectivedate and enddate
   and current_timestamp between createts and endts
   and benefitsubclass in ('2Z')
   and benefitelection = 'E'
   and personid = '5239'
   ;
select * from dependent_enrollment   
 where  personid = '5239';
select * from person_dependent_relationship where personid = '5141'; 
select * from person_vitals where personid in ('5795','5962');