select * from person_bene_election where benefitsubclass in ('10','11','14') AND personid in 
(select personid from person_names where lname like 'Antoine%' GROUP BY 1 );
select * from edi.edi_last_update;
update edi.edi_last_update set lastupdatets = '2018-10-09 07:02:27' where feedid = 'AWT_Discovery_COBRA_NPM_Export';
2018-10-23 07:06:37
 AWT_Discovery_COBRA_NPM_Export

SELECT min(effectivedate) as effectivedate from person_bene_election 
where benefitsubclass in ('10','11','14','60','61') and benefitelection = 'E' and selectedoption = 'Y';

select * from person_names where lname like 'Kurinsky%' ;
select * from benefit_plan_desc 


select * from person_names where lname like 'Galli%';
select * from person_maritalstatus where personid = '7105';
select * from dependent_enrollment where personid = '7119' and dependentid = '8534';

select * from person_bene_election where benefitsubclass in ('10','11','14','60','61')
and selectedoption = 'Y' and benefitelection = 'E' and effectivedate > '2018-10-09';

--select * from person_bene_election where personid = '9173' and benefitsubclass in ('10','11','14','60','61');
--select * from person_bene_election where personid = '9230' and benefitsubclass in ('10','11','14','60','61');
--select * from person_bene_election where personid = '9199' and benefitsubclass in ('10','11','14','60','61');
--select * from person_bene_election where personid = '9214' and benefitsubclass in ('10','11','14','60','61');
--select * from person_bene_election where personid = '8713' and benefitsubclass in ('10','11','14','60','61');
select * from person_bene_election where personid = '9124' and benefitsubclass in ('10','11','14','60','61');

select * from person_employment where personid = '9157';


select * from person_dependent_relationship where personid = '8666';



select * from person_employment where personid = '7084';
select * from person_names where lname like 'Cohen%';
select * from person_maritalstatus where personid = '7105';
select * from dependent_enrollment where personid = '8627';

select * from person_bene_election where personid ='8056' and benefitsubclass in ('10','11','14') ;

(select distinct personid, benefitsubclass, enddate, max(effectivedate) as effectivedate,
        RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK  
        from person_bene_election where benefitsubclass in ('10','11') and benefitelection = 'E' and selectedoption = 'Y'
         and current_timestamp between createts and endts and benefitcoverageid > '1'
         and effectivedate - interval '1 day' <> enddate
         and personid = '8056'
       group by personid, benefitsubclass, enddate) 
       
       
       

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
     and pbe.benefitsubclass in ('10','11')
     and pbe.selectedoption = 'Y'
     and current_date between pbe.effectivedate and pbe.enddate
     and current_timestamp between pbe.createts and pbe.endts     
   where current_timestamp between de.createts and de.endts
    and de.benefitsubclass in ('10','11')
    --and pdr.dependentrelationship in ('S','D','C','SP','DP')
    and pe.emplstatus = 'A'
    and pbe.benefitelection = 'E'
    and date_part('year',de.enddate)=date_part('year',current_date)
   -- and pe.personid = '9707'
    and de.dependentid not in 
   (select distinct de.dependentid from dependent_enrollment de
      join person_dependent_relationship pdr
        on pdr.personid = de.personid
       and pdr.dependentid = de.dependentid
       and current_date between pdr.effectivedate and pdr.enddate
       and current_timestamp between pdr.createts and pdr.endts
     where current_date between de.effectivedate and de.enddate
       and current_timestamp between de.createts and de.endts
       and de.benefitsubclass in ('10','11')
       --and pdr.dependentrelationship in ('S','D','C','SP','DP')
   )
)  ;

select * from person_dependent_relationship where personid = '7105' and current_date between effectivedate and enddate and current_timestamp between createts and endts;
select distinct de.dependentid as dependentid
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
     and pbe.benefitsubclass in ('10','11')
     and pbe.selectedoption = 'Y'
     and current_date between pbe.effectivedate and pbe.enddate
     and current_timestamp between pbe.createts and pbe.endts     
   where current_timestamp between de.createts and de.endts
    and de.benefitsubclass in ('10','11')
    and pdr.dependentrelationship in ('S','D','C','SP','DP')
    and pe.emplstatus = 'A'
    and pbe.benefitelection = 'E'
    --and date_part('year',de.enddate)=date_part('year',current_date)
    and pdr.personid = '7105'