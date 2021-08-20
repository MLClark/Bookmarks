select * from dependent_enrollment where personid = '2564';

select * from person_bene_election where benefitsubclass in ('10','11','14','15','16','17','60','61') and personid = '2564' and selectedoption = 'Y' 
and current_timestamp between createts and endts and effectivedate < enddate;




select * from person_benefit_action where personid = '720';




select * from person_benefit_action where personid = '871';



select * from person_employment where personid = '850';

select * from dependent_enrollment where personid = '720';


select * from edi.edi_last_update;
update edi.edi_last_update set lastupdatets = '2019-09-10 06:00:57' where feedid in ('AMJ_COBRA_EBC_QB');  -- 2019-09-10 06:00:57 2019-09-03 06:00:57 
update edi.edi_last_update set lastupdatets = '2018-01-01 00:00:00' where feedid in ('AMJ_COBRA_EBC_NPM');  
select * from person_bene_election where benefitsubclass in ('10','11','14','15','16','17','60','61') and personid = '850' and selectedoption = 'Y' and benefitelection = 'E';

select * from person_bene_election where benefitsubclass in ('10','11','14','15','16','17','60','61') and personid = '1921' and selectedoption = 'Y' 
and current_timestamp between createts and endts
and effectivedate < enddate;
select * from person_employment where personid = '836';

select * from person_names where lname like 'Anderso%';

select * from dependent_enrollment where personid = '720' and benefitsubclass in ('10','11','14','15','16','17','60','61') and selectedoption = 'Y'
and effectivedate < enddate and current_timestamp between createts and endts
and date_part('year',effectivedate)=date_part('year',current_date);

select * from person_bene_election where benefitsubclass in ('10','11','14','15','16','17','60','61') and personid = '720' and selectedoption = 'Y' 
and current_timestamp between createts and endts and benefitelection = 'E'
and effectivedate < enddate
and date_part('year',effectivedate)=date_part('year',current_date);

select * from dependent_enrollment where personid = '850' and benefitsubclass in ('10','11','14','15','16','17','60','61') and selectedoption = 'Y'
and effectivedate < enddate and current_timestamp between createts and endts
and date_part('year',effectivedate)=date_part('year',current_date);

select * from person_bene_election where benefitsubclass in ('10','11','14','15','16','17','60','61') and personid = '850' and selectedoption = 'Y' 
and current_timestamp between createts and endts and benefitelection = 'E'
and effectivedate < enddate
and date_part('year',effectivedate)=date_part('year',current_date);

(select distinct personid, enddate, max(effectivedate) as effectivedate,
  RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) desc) AS RANK
  from person_bene_election 
 where benefitsubclass in ('10','11','14','15','16','17','60','61')
   and enddate < '2199-12-30'
   and selectedoption = 'Y'
   and benefitelection = 'E'
   and personid in ('1921')
   and date_part('year',enddate)=date_part('year',current_date)
   group by 1,2)
   


;

select * from person_names where personid = '1260';

select distinct de.dependentid from dependent_enrollment de
      join person_dependent_relationship pdr
        on pdr.personid = '871'
       and pdr.dependentid = de.dependentid
       --and current_date between pdr.effectivedate and pdr.enddate
       and current_timestamp between pdr.createts and pdr.endts
       and pdr.effectivedate < pdr.enddate
     where current_date between de.effectivedate and de.enddate
       and current_timestamp between de.createts and de.endts
       and de.benefitsubclass in ('10','11','14','15','16','17','60','61')
       ;


 ( select distinct de.dependentid as dependentid,
    pnd.name
    from dependent_enrollment de 
    join person_bene_election pbe
      on pbe.personid = de.personid
     and pbe.benefitsubclass in ('10','11','14','15','16','17','60','61')
     and pbe.selectedoption = 'Y'
     and pbe.benefitelection <> 'W' 
     and pbe.benefitcoverageid > '1'
     and current_date between pbe.effectivedate and pbe.enddate
     and current_timestamp between pbe.createts and pbe.endts  
     and pbe.effectivedate < pbe.enddate       
    join person_names pne
      on pne.personid = de.personid
     and pne.nametype = 'Legal'
     and current_date between pne.effectivedate and pne.enddate
     and current_timestamp between pne.createts and pne.endts
     and pne.effectivedate < pne.enddate
    join person_names pnd
      on pnd.personid = de.dependentid
     and pnd.nametype = 'Dep'
     and current_date between pnd.effectivedate and pnd.enddate
     and current_timestamp between pnd.createts and pnd.endts  
     and pnd.effectivedate < pnd.enddate  
    join person_vitals pvd
      on pvd.personid = de.dependentid
     and current_date between pvd.effectivedate and pvd.enddate
     and current_timestamp between pvd.createts and pvd.endts
     and pvd.effectivedate < pvd.enddate
    join person_dependent_relationship pdr
      on pdr.personid = de.personid
     and pdr.dependentid = de.dependentid
     and current_date between pdr.effectivedate and pdr.enddate
     and current_timestamp between pdr.createts and pdr.endts
     and pdr.effectivedate < pdr.enddate
    join person_employment pe
      on pe.personid = de.personid
     and current_date between pe.effectivedate and pe.enddate
     and current_timestamp between pe.createts and pe.endts
     and pe.effectivedate < pe.enddate

   where current_timestamp between de.createts and de.endts
    and de.benefitsubclass in ('10','11','14','15','16','17','60','61')
    and pe.emplstatus = 'A'
    and date_part('year',de.enddate)=date_part('year',current_date)
    and de.personid = '836'
    and de.dependentid not in 
   (select distinct de.dependentid from dependent_enrollment de
      join person_dependent_relationship pdr
        on pdr.personid = de.personid
       and pdr.dependentid = de.dependentid
       and current_date between pdr.effectivedate and pdr.enddate
       and current_timestamp between pdr.createts and pdr.endts
       and pdr.effectivedate < pdr.enddate
     where current_date between de.effectivedate and de.enddate
       and current_timestamp between de.createts and de.endts
       and de.effectivedate < de.enddate
       and de.benefitsubclass in ('10','11','14','15','16','17','60','61')
   )
)  
;

select * from person_address where personid = '1827';
select * from person_names where lname like 'Behm%';

select * from person_dependent_relationship where personid in ('2020','704');

select * from person_maritalstatus where personid in ('2020','704');

select * from person_names where lname like 'Montana%';
select * from dependent_enrollment where personid = '739'  and dependentid = '1043';
select * from person_names where personid in ('1040');
select * from person_bene_election where personid = '871' and benefitsubclass in ('10','11','14','15','16','17','60','61');
select * from person_bene_election where personid = '930' and benefitsubclass in ('10');


select * from benefit_plan_desc where benefitsubclass in ('10','11','14','15','16','17','60','61');




(SELECT personid, MAX(effectivedate) AS enrollment_date, MAX(enddate) AS eventdate, 
            RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
            FROM person_bene_election pc1
            LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'AMJ_COBRA_EBC_QB'
            WHERE benefitcoverageid > '1'
              and benefitsubclass in ('10','11','14')
              and personid = '1921'
            GROUP BY personid ) ;

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
     and pbe.benefitsubclass in ('10','11','14','15','16','17','60','61')
     and pbe.selectedoption = 'Y'
     and current_date between pbe.effectivedate and pbe.enddate
     and current_timestamp between pbe.createts and pbe.endts     
   where current_timestamp between de.createts and de.endts
    and de.benefitsubclass in ('10','11','14','15','16','17','60','61')
    and pe.emplstatus = 'A'
    and pbe.benefitelection = 'E'
    and date_part('year',de.enddate)=date_part('year',current_date)    
    and pe.personid = '739'
    and de.dependentid not in 
   (select distinct de.dependentid from dependent_enrollment de
      join person_dependent_relationship pdr
        on pdr.personid = de.personid
       and pdr.dependentid = de.dependentid
       and current_date between pdr.effectivedate and pdr.enddate
       and current_timestamp between pdr.createts and pdr.endts
     where current_date between de.effectivedate and de.enddate
       and current_timestamp between de.createts and de.endts
       and pdr.personid = '739'
       and de.benefitsubclass in ('10','11','14','15','16','17','60','61')

   )
)  


















