select * from person_bene_election where personid = '10318' and benefitsubclass = '1Hosp';
select * from person_bene_election where personid = '12822' and benefitsubclass IN ('13','30','3Y');
--select * from benefit_coverage_desc where benefitcoverageid = '3';
select * from dependent_enrollment where personid = '12822' and benefitsubclass IN ('13','30','3Y');


(select personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, benefitcoverageid, max(effectivedate) as effectivedate, max(enddate) as enddate, RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
            from person_bene_election where benefitsubclass = '13' and benefitelection = 'E' and selectedoption = 'Y' and current_timestamp between createts and endts and effectivedate < enddate and enddate < '2199-12-30' and benefitcoverageid > '1'
            and date_part('year',deductionstartdate) >= date_part('year',current_date) and personid = '12822'
           group by personid, benefitelection, benefitcoverageid,benefitsubclass,benefitplanid,benefitcoverageid) 


(select personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, effectivedate, enddate, RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
            from person_bene_election where benefitsubclass in ('30','3Y') and benefitelection = 'E' and selectedoption = 'Y' and current_timestamp between createts and endts and effectivedate < enddate and enddate < '2199-12-30'
             and personid = '12822' 
           group by personid, benefitelection, benefitcoverageid,benefitsubclass,benefitplanid, effectivedate, enddate)
           
           

( select personid, phoneno, max(createts) as createts, max(effectivedate) as effectivedate, RANK() OVER (PARTITION BY personid ORDER BY MAX(createts) DESC) AS RANK
              from person_phone_contacts where phonecontacttype = 'Home' and current_date between effectivedate and enddate and current_timestamp between createts and endts and personid = '10289'
             group by personid, phoneno)

select * from person_phone_contacts where phonecontacttype = 'Home' and personid = '10289';

select distinct personid from person_bene_election where current_date between effectivedate and enddate and current_timestamp between createts and endts and selectedoption = 'Y' and benefitelection = 'E'
and benefitsubclass in ( '1W','13','30','3Y','31','1Hosp')and personid in (select personid from person_employment where emplstatus = 'A' and current_date between effectivedate and enddate and current_timestamp between createts and endts group by 1);


select * from person_bene_election where personid = '10573' and effectivedate < enddate and current_timestamp between createts and endts and selectedoption = 'Y' and benefitelection = 'E'
and benefitsubclass in ( '1W','13','30','3Y','31','1Hosp') ;

select * from person_names where personid = '9622';


select * from person_dependent_relationship where personid = '10166';
select * from person_identity where personid = '12339';
select * from benefit_plan_desc where benefitsubclass = '1Hosp';
select * from benefit_plan_desc where benefitsubclass in ('30','3Y') ;
select * from benefit_plan_desc where benefitplanid = 111;

select * from person_bene_election where personid = '10519' and benefitsubclass in ('1Hosp');

(select personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, max(effectivedate) as effectivedate, max(enddate) as enddate, RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
            from person_bene_election where benefitsubclass in ('30','3Y') and benefitelection = 'E' and selectedoption = 'Y' and current_timestamp between createts and endts --and effectivedate < enddate
            and personid = '9936'
           group by personid, benefitelection, benefitcoverageid,benefitsubclass,benefitplanid);
           
(select personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, max(effectivedate) as effectivedate, max(enddate) as enddate, RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
            from person_bene_election where benefitsubclass in ('1Hosp') and benefitelection = 'E' and selectedoption = 'Y' and current_timestamp between createts and endts and effectivedate < enddate and effectivedate <= current_date
            and personid = '9826'
           group by personid, benefitelection, benefitcoverageid,benefitsubclass,benefitplanid)           

60 - for Salaried = '285'
Core - for Hourly
Buyup - for Hourly w Buy up plan

select * from dependent_enrollment where personid = '10322';
select * from dependent_enrollment where personid = '12648' and dependentid = '12878' and  benefitsubclass = '1W';
select * from dependent_enrollment where personid = '9707';

(select personid, dependentid, effectivedate, benefitsubclass, max(enddate) as enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) desc) AS RANK
             from dependent_enrollment where benefitsubclass = '1W' and selectedoption = 'Y' and effectivedate < enddate and personid = '12648' and current_timestamp between createts and endts
            group by personid, dependentid, effectivedate, benefitsubclass)
            
            select * from person_vitals where personid = '12878';
            
select * from dependent_enrollment where personid = '12648' and dependentid = '12878' and benefitsubclass = '1W';

   (select distinct de.dependentid from dependent_enrollment de
      join person_dependent_relationship pdr
        on pdr.personid = de.personid
       and pdr.dependentid = de.dependentid  
       and current_date between pdr.effectivedate and pdr.enddate
       and current_timestamp between pdr.createts and pdr.endts
     where ((current_date between de.effectivedate and de.enddate and current_timestamp between de.createts and de.endts)
        or (de.effectivedate > current_date and de.enddate >= '2199-12-30'))
       and de.benefitsubclass in ('1W','13','1Hosp'))   ;
       
       
 ( select distinct de.dependentid as dependentid
    from dependent_enrollment de 
    join person_names pne
      on pne.personid = de.personid
     and pne.nametype = 'Legal'
     and current_date between pne.effectivedate and pne.enddate
     and current_timestamp between pne.createts and pne.endts
    join person_names pnd
      on pnd.personid = de.dependentid
     and pnd.nametype = 'Dep'
     and current_date between pnd.effectivedate and pnd.enddate
     and current_timestamp between pnd.createts and pnd.endts    
    join person_vitals pvd
      on pvd.personid = de.dependentid
     and current_date between pvd.effectivedate and pvd.enddate
     and current_timestamp between pvd.createts and pvd.endts 
    join person_dependent_relationship pdr
      on pdr.personid = de.personid
     and pdr.dependentid = de.dependentid
     and current_date between pdr.effectivedate and pdr.enddate
     and current_timestamp between pdr.createts and pdr.endts
    join person_employment pe
      on pe.personid = de.personid
     and current_date between pe.effectivedate and pe.enddate
     and current_timestamp between pe.createts and pe.endts
    join person_bene_election pbe
      on pbe.personid = de.personid
     and pbe.benefitsubclass in ('1W','13','1Hosp')
     and pbe.selectedoption = 'Y'
     and current_date between pbe.effectivedate and pbe.enddate
     and current_timestamp between pbe.createts and pbe.endts     
   where current_timestamp between de.createts and de.endts
    and de.benefitsubclass in ('1W','13','1Hosp')
    and pe.emplstatus = 'A'
    and pbe.benefitelection = 'E'
   -- issue with new enrollee's not identitfied with prior year coverage 
    and de.dependentid not in 
   (select distinct de.dependentid from dependent_enrollment de
      join person_dependent_relationship pdr
        on pdr.personid = de.personid
       and pdr.dependentid = de.dependentid  
       and current_date between pdr.effectivedate and pdr.enddate
       and current_timestamp between pdr.createts and pdr.endts and de.dependentid = '11238'
     where ((current_date between de.effectivedate and de.enddate and current_timestamp between de.createts and de.endts)
        or (de.effectivedate > current_date and de.enddate >= '2199-12-30'))
       and de.benefitsubclass in ('1W','13','1Hosp')) 
)             
       
select de.dependentid from dependent_enrollment de
  join person_vitals pvd on pvd.personid = de.depentdentid and pvd.birthdate > current_date - interval '26 years' 
 where de.benefitsubclass in ('1W','13','1Hosp')










select * from benefit_plan_desc where benefitsubclass in ( '1W','13');


select * from location_codes;


select * from person_bene_election where benefitsubclass in ( '1W','13')  and personid = '9707';
select * from dependent_enrollment where personid = '9707' and dependentid = '11234' and benefitsubclass in ( '1W','13')  ;



13	013-FORM TECHNOLOGIES CORPORATE-ACC
14	014-DYNACAST SALES-ACC
15	015-DYNACAST ELGIN-ACC
16	016-DYNACAST PORTLAND-ACC
17	017-DYNACAST TOOLING DIVISION-ACC
18	018-DYNACAST LAKE FOREST-ACC
10	010-DYNACAST PORTLAND-CI
11	011-DYNACAST TOOLING DIVISION-CI
12	012-DYNACAST LAKE FOREST-CI
7	007-FORM TECHNOLOGIES CORPORATE-CI
8	008-DYNACAST SALES-CI
9	009-DYNACAST ELGIN-CI


/*

Please change mapping of PS location codes to Hartford location codes:
PS Location Code      to     Hartford Location Code
 1 - Charlotte               001
 2 - Elgin                   002
 3 - Germantown              004
 4 - Lake Forest             005
 5 - Charlotte               001
 6 - Portland/Wilsonville    003
 7 - Peterborough(not used)  007

Thanks
Lori



*/