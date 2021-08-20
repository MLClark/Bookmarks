

(select personid, benefitplanid,benefitelection,benefitcoverageid, max(createts) as createts,max(effectivedate) as effectivedate, max(enddate) as enddate, rank() over (partition by personid order by max(effectivedate) desc) as rank
 from person_bene_election pbe
 where benefitsubclass in ('13') and personid = '3009'
 and benefitelection in ('E','W')
 and selectedoption = 'Y'
 and effectivedate < enddate
 and current_timestamp between createts and endts
 group by 1,2,3,4)




select * from pay_unit;

select * from person_names where lname like 'Bapt%';
select * from person_bene_election where personid = '3486' and benefitsubclass = '1C' and createts > '2021-01-15';
select * from person_bene_election where personid = '2985';
select * from benefit_plan_desc;

 
left join pay_unit pu on pu.payunitid = ppl.payunitid

select * from person_bene_election where benefitsubclass in ('1W','1S','1I','13') and current_timestamp between createts and endts and eventdate <= current_date
and personid in (select distinct personid from person_bene_election where benefitsubclass in ('1W','1S','1I','13') and current_timestamp between createts and endts 
and benefitelection in ('E') and current_date between effectivedate and enddate and selectedoption = 'Y')
;


select * from person_bene_election where benefitsubclass in ('13' ) and current_timestamp between createts and endts and eventdate >= current_date
and personid in (select distinct personid from person_bene_election where benefitsubclass in ('1I' ) and current_timestamp between createts and endts 
and benefitelection in ('E') and current_date between effectivedate and enddate and selectedoption = 'Y')
;

select * from person_names where personid = '3897';
'2021-01-06 06:18:17'
select * from edi.edi_last_update where feedid = 'DAB_Assurity_CI_HI_Accident_Export';
update edi.edi_last_update set lastupdatets = '2021-01-07 07:01:28' where feedid = 'DAB_Assurity_CI_HI_Accident_Export'; --2021-02-02 07:03:01

select * from benefit_coverage_desc;

(
select distinct
  e.personid
 ,coalesce(t.benefitsubclass,e.benefitsubclass) as benefitsubclass
 ,coalesce(t.benefitelection,e.benefitelection) as benefitelection
 ,coalesce(t.createts, e.createts) as createts
 ,coalesce(t.personbeneelectionpid, e.personbeneelectionpid) as personbeneelectionpid
 ,coalesce(e.enddate, t.enddate) as enddate
 ,coalesce(e.coverageamount, t.coverageamount) as coverageamount
 ,coalesce(t.effectivedate, e.effectivedate) as effectivedate 
 ,e.rank as rank
 from 
 
 (select personid, benefitsubclass, benefitelection,  personbeneelectionpid, coverageamount, createts, effectivedate, enddate, RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) ASC) AS RANK
             from person_bene_election
            where benefitsubclass in  ('1W') and benefitelection in ('E') and selectedoption = 'Y' and current_timestamp between createts and endts and effectivedate < enddate and coverageamount > 0 
              and date_part('year',eventdate::date) >= date_part('year',current_date - interval '1 year')
              and date_part('year',effectivedate) >= date_part('year',current_date)
            group by personid, benefitsubclass, benefitelection,  personbeneelectionpid, coverageamount, createts, effectivedate, enddate) e
            
 join 
 
( select personid, benefitsubclass, benefitelection,  personbeneelectionpid, coverageamount, createts, effectivedate, enddate, RANK() OVER (PARTITION BY personid ORDER BY MAX(createts) desc) AS RANK
             from person_bene_election
            where benefitsubclass in  ('1W') and benefitelection in ('T') and selectedoption = 'Y' and current_timestamp between createts and endts and effectivedate < enddate and coverageamount > 0 
              and date_part('year',eventdate::date) = date_part('year',current_date) 
            group by personid, benefitsubclass, benefitelection,  personbeneelectionpid, coverageamount, createts, effectivedate, enddate) t    
            on t.personid = e.personid  
);


select * from personbenoptioncostl where personid = '3009';






















select * from person_payroll limit 10;

select * from person_payroll where effectivedate >= '2019-03-01' and personid in 
(select distinct personid from person_bene_election where benefitsubclass in ('1W','1S','1I','13') )
select * from person_payroll where personid = '2662';





select * from person_vitals

select * from benefit_plan_coverage;

select * from person_bene_election where personid = '2747' and benefitsubclass in ('1W','1S','1C','1I','13') ;

select * from disability_code;

select * from person_names where personid = '2891';

select current_date - (interval '26 years')


select * from pay_unit;

select * from person_employment where personid = '2691';

select * from person_compensation where personid = '2666';

select * from benefit_plan_desc where current_timestamp between createts and endts  and benefitsubclass in ('1W','1S','1C','1I','13')
  ;
  
  select * from benefit_plan_desc where current_timestamp between createts and endts and current_date between effectivedate and enddate;
 select * from benefit_coverage_desc;
select * from person_bene_election where personid = '3019' and benefitsubclass in ('1W','1S','1C','1I','13') and current_timestamp between createts and endts and current_date between effectivedate and enddate;
 
 
 select * from benefit_coverage_desc;

select * from personbenoptioncostl where personid = '2747';
select * from person_bene_election where personid = '2682' and benefitsubclass in ('13') and benefitplanid = '266';
select * from person_bene_election where benefitsubclass in ('1W') and benefitplanid = '266';

select * from benefit_plan_desc 
where current_timestamp between createts and endts
  and benefitsubclass in ('1I')
  ;

select * from person_names where fname like 'Ricard%';
select * from person_names where lname like 'Bar%';
select * from person_dependent_relationship where dependentid = '3897';
select * from person_names where personid = '2692';
  
select * from edi.edi_last_update  where feedid = 'DAB_Assurity_CI_HI_Accident_Export';  
update edi.edi_last_update set lastupdatets = '2019-03-01 00:00:00' where feedid = 'DAB_Assurity_CI_HI_Accident_Export'; ---- 2019-03-01 00:00:00 2019-04-30 06:02:13
    
select * from person_names where lname like 'Thompson%'; 

select * from person_names where personid = '3394';   
select * from dependent_enrollment where personid = '2838' and dependentid = '3394';
select * from person_dependent_relationship where PERSONID = '2838';



select * from person_dependent_relationship where personid = '2835';
select * from dependent_enrollment where personid = '2838';

select * from person_bene_election where personid = '2692' and benefitsubclass in ('1W','1S','1I','13') ;

select * from dependent_enrollment where benefitsubclass = '1S' 
(select personid from person_bene_election where benefitsubclass = '1S' and selectedoption = 'Y' and benefitelection = 'E'  group by 1)



select * from person_compensation where personid = '3666';
select * from benefit_plan_desc;
select * from benefit_coverage_desc;
select * from person_bene_election where personid = '2914' and benefitsubclass in ('1W','1S','1I','13') and effectivedate - interval '1 day' < enddate;
select * from person_employment where personid = '2914'; 

select * from person_bene_election where benefitsubclass in ('1W','1S','1C') and current_date between effectivedate and enddate and current_timestamp between createts and endts
and benefitelection = 'E' and selectedoption = 'Y';

select * from person_bene_election where benefitsubclass in ('1S') 
and current_date between effectivedate and enddate 
and current_timestamp between createts and endts
and benefitelection = 'E' and selectedoption = 'Y'
and personid = '2930';

select * from person_bene_election where benefitsubclass in ('1C') 
and current_date between effectivedate and enddate 
and current_timestamp between createts and endts
and benefitelection = 'E' and selectedoption = 'Y'
and personid = '2930';


select * from person_bene_election where current_date between effectivedate and enddate and current_timestamp between createts and endts
and benefitelection = 'E' and selectedoption = 'Y' and benefitsubclass in ('1W','1S','1C') ;

 

select 
 ci.personid
,case when ci.e_benefitsubclass = '1W' and ci.s_benefitsubclass = '1S' and ci.c_benefitsubclass = '1C' then 'Family'
      when ci.e_benefitsubclass = '1W' and ci.s_benefitsubclass = '1S' and ci.c_benefitsubclass = 'N' then 'EE + Spouse'
      when ci.e_benefitsubclass = '1W' and ci.s_benefitsubclass = 'N' and ci.c_benefitsubclass = '1C' then 'EE + Child(ren)'
      when ci.e_benefitsubclass = '1W' and ci.s_benefitsubclass = 'N' and ci.c_benefitsubclass = 'N' then 'EE'
      end cicvgtier

from 
(
 select distinct
  pbe.personid
 ,pbecie.benefitsubclass as e_benefitsubclass
 ,coalesce(pbecis.benefitsubclass,'N') as s_benefitsubclass
 ,coalesce(pbecic.benefitsubclass,'N') as c_benefitsubclass
  from person_bene_election pbe 
     
  join person_bene_election pbecie on pbecie.personid = pbe.personid 
     and current_date between pbecie.effectivedate and pbecie.enddate and current_timestamp between pbecie.createts and pbecie.endts
     and pbecie.benefitelection = 'E' and pbecie.selectedoption = 'Y' and pbecie.benefitsubclass in ('1W')
  left join person_bene_election pbecis on pbecis.personid = pbe.personid 
     and current_date between pbecis.effectivedate and pbecis.enddate and current_timestamp between pbecis.createts and pbecis.endts
     and pbecis.benefitelection = 'E' and pbecis.selectedoption = 'Y' and pbecis.benefitsubclass in ('1S')     
  left join person_bene_election pbecic on pbecic.personid = pbe.personid 
     and current_date between pbecic.effectivedate and pbecic.enddate and current_timestamp between pbecic.createts and pbecic.endts
     and pbecic.benefitelection = 'E' and pbecic.selectedoption = 'Y' and pbecic.benefitsubclass in ('1C') 
where current_date between pbe.effectivedate and pbe.enddate and current_timestamp between pbe.createts and pbe.endts
  and pbe.benefitsubclass in ('1W','1S','1C') and pbe.benefitelection = 'E' and pbe.selectedoption = 'Y'           
) ci
  
  ;

select personid, benefitcoverageid, benefitsubclass, benefitelection, selectedoption, monthlyamount, max(effectivedate) as effectivedate, enddate,
  RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS  rank
  from person_bene_election where personid = '2682' and benefitsubclass in ('1W') and effectivedate - interval '1 day' < enddate
  group by personid, benefitcoverageid, benefitsubclass, benefitelection, selectedoption, monthlyamount, enddate
  ;
select personid, benefitcoverageid, benefitsubclass, benefitelection, selectedoption, monthlyamount, max(effectivedate) as effectivedate, enddate,
  RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS  rank
  from person_bene_election where personid = '2682' and benefitsubclass in ('1S') and effectivedate - interval '1 day' < enddate
  group by personid, benefitcoverageid, benefitsubclass, benefitelection, selectedoption, monthlyamount, enddate
  ;  
select personid, benefitcoverageid, benefitsubclass, benefitelection, selectedoption, monthlyamount, max(effectivedate) as effectivedate, enddate,
  RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS  rank
  from person_bene_election where personid = '2682' and benefitsubclass in ('1I') and effectivedate - interval '1 day' < enddate
  group by personid, benefitcoverageid, benefitsubclass, benefitelection, selectedoption, monthlyamount, enddate
  ;
select personid, benefitcoverageid, benefitsubclass, benefitelection, selectedoption, monthlyamount, max(effectivedate) as effectivedate, enddate,
  RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS  rank
  from person_bene_election where personid = '2682' and benefitsubclass in ('13') and effectivedate - interval '1 day' < enddate
  group by personid, benefitcoverageid, benefitsubclass, benefitelection, selectedoption, monthlyamount, enddate
  ;    

select personid, benefitcoverageid, benefitsubclass, benefitelection, selectedoption, monthlyamount, max(effectivedate) as effectivedate, enddate,
  RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS  rank
  from person_bene_election where personid = '2682' and benefitsubclass in ('1W','1S','1I','13') and effectivedate - interval '1 day' < enddate
  group by personid, benefitcoverageid, benefitsubclass, benefitelection, selectedoption, monthlyamount, enddate
  ;

select * from person_employment where emplstatus = 'T' and personid in 
(select personid from person_bene_election where benefitsubclass in ('1W','1S','1I','13'));

select * from edi.edi_last_update;
insert into edi.edi_last_update (feedid,lastupdatets) values ('DAB_Assurity_CI_HI_Accident_Export','2018-07-01 00:00:00')
update edi.edi_last_update set lastupdatets = '2018-01-01 00:00:00' where feedid = 'DAB_Assurity_CI_HI_Accident_Export';

update edi.edi_last_update set lastupdatets = '2018-07-01 00:00:00' where feedid = 'DAB_EBenefits_HSA_Export';
DAB_Assurity_CI_HI_Accident_Export

select benefitplandesc, 
case when benefitplandesc like '% Plan A %' then 'a'
     when benefitplandesc like '% Plan B %' then 'b' end ::char(1) as plantype
     from benefit_plan_desc where current_timestamp between createts and endts
       and benefitsubclass in ('1I');
select * from person_dependent_relationship where personid = '2682';

select * from pay_schedule_period where date_part('year',periodpaydate) = '2018' and date_part('month',periodpaydate)<'08' and processfinaldate is not null and payrolltypeid = 1;

select * from pspay_payment_detail where personid = '2678' and etv_id = 'V40' and check_date = '2018-07-13';
select * from pspay_payment_header where personid = '2678' and check_date = '2018-07-13';
select * from person_address where personid = '2700';
select * from person_compensation where personid = '2911';
select * from person_bene_election where  benefitsubclass = '1I';
select * from pers_pos where personid = '2665';

select * from edi.edi_last_update;

(select personid, max(perspospid) as perspospid 
             from pers_pos 
             LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'HMN_PS_CogDetGet_Export'
             where current_timestamp between createts and endts
               and personid = '2665'
            group by 1)

(select personid, max(percomppid) as percomppid
             from person_compensation 
             LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'DAB_Assurity_CI_HI_Accident_Export'
              where personid = '2782'
             group by 1 )
select * from person_bene_election where benefitsubclass in ('1W','1S','1I','13')
  and personid in (select distinct personid from person_employment where emplstatus = 'T');
  select * from person_names where personid = '2669';
  
  select * from person_bene_election where  benefitsubclass in ('1W','1S','1I','13') and personid = '2682';