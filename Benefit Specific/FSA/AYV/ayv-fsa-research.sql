select distinct 
 pbe.personid
,pbe.benefitsubclass
,pbe.benefitplanid
,pbe.benefitelection
,pbe.selectedoption
,pbe.effectivedate
,pbe.enddate
,pbe.coverageamount
,pbocl.employeerate

from person_bene_election pbe
join person_employment pe
  on pe.personid = pbe.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts

join personbenoptioncostl pbocl
  on pbocl.personid = pbe.personid
 and pbocl.costsby = 'P'
 and pbocl.personbeneelectionpid = pbe.personbeneelectionpid     

where current_timestamp between pbe.createts and pbe.endts
  and pbe.selectedoption = 'Y' and pbe.benefitelection = 'E'
  and date_part('year',deductionstartdate)>=date_part('year',current_date)
  and pbe.benefitsubclass in ('6Z','60','61','10','11')
  and pbe.personid = '7316'



;



select distinct 
 pbe.personid
,pbe.benefitsubclass
,pbe.benefitplanid
,pbe.benefitelection
,pbe.selectedoption
,pbe.effectivedate
,pbe.enddate
,pbe.coverageamount
,deductionstartdate
,pbocl.employeerate

from person_bene_election pbe
join person_employment pe
  on pe.personid = pbe.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts

join personbenoptioncostl pbocl
  on pbocl.personid = pbe.personid
 and pbocl.costsby = 'P'
 and pbocl.personbeneelectionpid = pbe.personbeneelectionpid     

where current_timestamp between pbe.createts and pbe.endts
  and pbe.selectedoption = 'Y' and pbe.benefitelection = 'T'
  and date_part('year',pbe.deductionstartdate)>=date_part('year',current_date)
  and pbe.benefitsubclass in ('6Z','60','61','10','11')
  and pbe.personid = '7316'



;

select * from person_bene_election where personid = '7316' and benefitsubclass in ('10')
and effectivedate < enddate and current_timestamp between createts and endts;

select * from person_bene_election where personid = '7316' and benefitsubclass in ('6Z','60','10','61','11')
and effectivedate < enddate and current_timestamp between createts and endts;


select * from personbeneelectionasof where asofdate = current_date and personid = '7316' and benefitsubclass = '10';














select * from person_names where lname like 'Brown%';

select * from person_employment where personid = '7728';

(select personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, coverageamount, personbeneelectionpid,max(effectivedate) as effectivedate, max(enddate) as enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election where benefitsubclass = '6Z'  and selectedoption = 'Y' and current_timestamp between createts and endts --and benefitelection = 'T'
             and personid = '7728'
            group by personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, coverageamount, personbeneelectionpid)
            ;

(select personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, coverageamount, personbeneelectionpid,max(effectivedate) as effectivedate, max(enddate) as enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election where benefitsubclass = '10' and benefitelection = 'T' and selectedoption = 'Y' and current_timestamp between createts and endts
              and personid = '7728'
            group by personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, coverageamount, personbeneelectionpid)
            ;

select * from person_bene_election where personid = '7316' and benefitsubclass in ('6Z','60','10','61','11')
and current_date between effectivedate and enddate and current_timestamp between createts and endts;

select * from person_bene_election where personid = '7728' and benefitsubclass in ('6Z')
and current_date between effectivedate and enddate and current_timestamp between createts and endts;


select * from benefit_plan_desc where current_date between effectivedate and enddate and current_timestamp between createts and endts;

select * from person_names where lname like 'Davis%';
select * from person_net_contacts where personid = '7285'
 and current_date between effectivedate and enddate and current_timestamp between createts and endts;

select * from pspay_etv_list;
select * from pspay_payment_detail where personid = '8111' and check_date <= '2018-08-17' and etv_id = 'VBA' ;
select * from person_bene_election where personid = '7317' and benefitsubclass in ('60','61');

select * from pspay_deduction_accumulators where individual_key = 'AYV00001443606' and etv_id = 'VBA';
select * from personbenoptioncostl where personid = '5978' and personbeneelectionpid = '39964';
select * from    person_bene_election 
 where benefitsubclass in ('11')
   and selectedoption = 'Y' and benefitelection in ('E')
   and current_timestamp between createts and endts
   and personid = '5978' 
;

select * from person_payroll where personid = '5978';
select * from pay_unit;
select * from person_names where lname like 'Kuech%';

select personid, max(coverageamount) as coverageamount
  from person_bene_election 
 where benefitsubclass in ('60')
   and selectedoption = 'Y' and benefitelection in ('E')
   and current_timestamp between createts and endts
   and date_part('year',enddate) > date_part('year',current_date)
   and personid = '8111' 
   group by 1
;



select * from person_names where lname like 'Payne%';

select * from pay_schedule_period where date_part('year',periodpaydate)= '2018' and date_part('month',periodpaydate)='09';

select * from pspay_etv_list where etv_id in ('VBA','VBB','VBC','VBD');
select * from pspay_payment_detail where check_date = '2018-09-14' and personid = '5978' and check_date = '2018-09-14';

(select personid, coverageamount, max(effectivedate) as effectivedate, max(enddate) as enddate,
             RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election
            where benefitsubclass in ('60') and selectedoption = 'Y' and benefitelection in ('E') 
              and current_date between effectivedate and enddate and current_timestamp between createts and endts
              and personid = '7805' group by 1,2)
            