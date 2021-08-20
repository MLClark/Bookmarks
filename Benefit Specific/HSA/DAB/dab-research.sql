  select * from person_bene_election 
where effectivedate >= '2019-09-01'
  and current_timestamp between createts and endts
  and selectedoption = 'Y'
  and benefitsubclass in ('6Z','6H')
;



select * from benefit_plan_desc where edtcode like 'HSA%';

select * from person_bene_election  
where current_date between effectivedate and enddate
  and current_timestamp between createts and endts
  --and selectedoption = 'Y'
  and benefitsubclass in ('6Z','6H')
  and personid = '2948'
;

select * from person_names where lname like 'Jone%';
select * from person_bene_election  
where current_date between effectivedate and enddate
  and current_timestamp between createts and endts
  --and selectedoption = 'Y'
  and benefitsubclass in ('6H') and benefitplanid = '98'
  --and benefitelection = 'E'
  
  select * from person_bene_election 
where current_date between effectivedate and enddate
  and current_timestamp between createts and endts
  and selectedoption = 'Y'
  and benefitsubclass in ('6Z','6H')
  and benefitelection = 'T';
  
select * from person_names where personid = '2110';  
select * from person_names where lname like 'Provo%';
select * from person_employment where personid = '2948';

select * from pspay_payment_detail where etv_id = 'V42';
select * from pspay_etv_list;
select * from edi.edi_last_update;

insert into edi.edi_last_update (feedid,lastupdatets) values ('DAB_EBenefits_HSA_Export','2018-01-01 00:00:00');
update edi.edi_last_update set lastupdatets = '2018-07-01 00:00:00' where feedid in ('DAB_EBenefits_HSA_Export');

select * from person_address where addresstype = 'Res' and personid = '2986'
and current_date between effectivedate and enddate and current_timestamp between createts and endts;

select * from pspay_etv_operators;
select * from person_employment where emplstatus = 'T' and current_date between effectivedate and enddate and current_timestamp between createts and endts 
and personid in (select distinct personid from person_bene_election where benefitsubclass in ('6Z','6H') and selectedoption = 'Y' and benefitelection = 'E');

select * from person_bene_election where personid = '3028' and benefitsubclass in ('6Z','6H');

left join (SELECT personid, emplstatus, emplevent,  empleventdetcode, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate, 
            RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
            FROM person_employment pe1
            WHERE enddate > effectivedate 
                   AND current_timestamp BETWEEN createts AND endts
                   and emplstatus = 'L'
                   and enddate <= current_date
            GROUP BY personid, emplstatus, emplevent, empleventdetcode ) leavest on leavest.rank = 1 and leavest.personid = pe.personid

select * from person_phone_contacts where personid = '2734';
select * from benefit_plan_desc where benefitsubclass in ('1W','1S','1I','13');
select * from person_bene_election where benefitsubclass = '1W' and benefitplanid = '113';
select * from person_bene_election where benefitsubclass = '1S' and benefitplanid = '116';


  
