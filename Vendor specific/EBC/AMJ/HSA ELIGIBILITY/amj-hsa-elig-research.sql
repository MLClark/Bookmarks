--select personid from person_bene_election where current_date between effectivedate and enddate and current_timestamp between createts and endts and benefitelection = 'E' and selectedoption = 'Y' and benefitsubclass in ('6Z','6Y') group by 1
select * from edi.edi_last_update;

update edi.edi_last_update set lastupdatets = '2019-01-01 00:00:00' where feedid = 'AMJ_EBC_HSA_Eligibility_Export';

select * from benefit_plan_desc where  benefitsubclass in ('6Z','6Y');
select * from benefit_plan_desc where  benefitsubclass in ('60','61');
select * from person_phone_contacts where personid = '1783';

select * from person_bene_election where effectivedate < enddate and current_timestamp between createts and endts 
   and benefitelection = 'E' and selectedoption = 'Y' and benefitsubclass in ('6Z','6Y') and personid = '1986';
   
select * from person_bene_election
join edi.edi_last_update elu on elu.feedid = 'AMJ_EBC_HSA_Eligibility_Export'
where  benefitsubclass in ('6Z','6Y')
and personid = '1986'
and benefitelection = 'E'
and selectedoption = 'Y' 
and (current_timestamp between createts and endts or elu.lastupdatets between effectivedate and enddate)
--and current_date between effectivedate and enddate
;
  
join person_bene_election pbe
  on pbe.personid = pe.personid
 and pbe.benefitsubclass in ('6Y','6Z')
 and pbe.benefitelection = 'E'
 and pbe.selectedoption = 'Y'
 and (current_timestamp between pbe.createts and pbe.endts or elu.lastupdatets between pbe.effectivedate and pbe.enddate)
 --and current_date between pbe.effectivedate and pbe.enddate
-- and current_timestamp between pbe.createts and pbe.endts  

join person_bene_election pbe
  on pbe.personid = pe.personid
 and pbe.benefitsubclass in ('6Y','6Z')
 and pbe.benefitelection = 'E'
 and pbe.selectedoption = 'Y'
 and pbe.enddate >= '2199-12-30'
 and current_date between pbe.effectivedate and pbe.enddate
 and current_timestamp between pbe.createts and pbe.endts   
   
   select * from person_benefit_action where personid = '1986';

select * from person_names where personid = '2607';   
select * from person_employment where personid = '1000';
select * from person_bene_election where personid = '1000';
select * from person_address where personid = '1723';

select * from person_compensation;
select * from pers_pos;

select distinct personid from person_bene_election where current_date between effectivedate and enddate and current_timestamp between createts and endts 
   --and date_part('year',effectivedate) >= date_part('year',current_date)
   and benefitelection = 'E' and selectedoption = 'Y' and benefitsubclass in ('6Z','6Y','60','61') and personid in 
   (select personid from person_employment where emplstatus in ('A', 'L') and effectivedate >= '2019-01-01' group by 1);

  

select distinct personid from person_bene_election where current_date between effectivedate and enddate and current_timestamp between createts and endts 
   --and date_part('year',effectivedate) >= date_part('year',current_date)
   and benefitelection = 'E' and selectedoption = 'Y' and benefitsubclass in ('60','61') and personid in 
   (select personid from person_employment where emplstatus in ('A', 'L') group by 1);
   
   select * from personbenoptioncostl where personid = '2323';
   
   select * from person_bene_election where effectivedate < enddate and current_timestamp between createts and endts 
   and benefitelection = 'T' and selectedoption = 'Y' and benefitsubclass in ('60','61') and personid = '2323';

--- medical fsa
left join   (select personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid,max(effectivedate) as effectivedate, max(enddate) as enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election where benefitsubclass = '60' and benefitelection = 'E' and selectedoption = 'Y' and effectivedate < enddate and current_timestamp between createts and endts 
              and personid = '2323'
            group by personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid) pbemfsa on pbemfsa.personid = pbe.personid and pbemfsa.rank = 1 
            
(select personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid,max(effectivedate) as effectivedate, max(enddate) as enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election where benefitsubclass = '61' and benefitelection = 'E' and selectedoption = 'Y' and effectivedate < enddate and current_timestamp between createts and endts 
            and personid = '2323'
            group by personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid)             
   