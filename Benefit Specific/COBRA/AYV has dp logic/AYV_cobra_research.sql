(select *from person_bene_election where current_timestamp between createts and endts and date_part('year',deductionstartdate)>=date_part('year',current_date)
   and benefitsubclass in ('10','11','14','15','16','17') and benefitelection = 'E' and selectedoption = 'Y' and effectivedate < enddate
   and personid = '5976');


select * from benefit_plan_desc where current_date between effectivedate and enddate and current_timestamp between createts and endts and benefitsubclass in ('10','11','14','15','16','17');


select * from benefit_plan_desc where current_date between effectivedate and enddate and current_timestamp between createts and endts and benefitsubclass in ('60','61');

select * from dependentenrollment where personid = '7728';
select * from person_bene_election where personid in ('6021','7728') and current_timestamp between createts and endts 
and benefitsubclass = '60' and effectivedate < enddate;

select * from dependentenrollmentvalid where personid = '7728' and asofdate = current_date;
select * from dependentselectsubclass where personid = '7728' ;
select * from dependent_enrollment where personid = '7728';

select pe.* from person_employment pe
  join edi.edi_last_update elu on feedid = 'AYV_SHDR_COBRA_QB_Export'
  
  select * from person_names where personid = '8557';
select * from person_employment where personid = '8557';
  
where pe.emplstatus in ('R','T')
  and (pe.effectivedate >= elu.lastupdatets::DATE 
   or (pe.createts > elu.lastupdatets and pe.effectivedate < coalesce(elu.lastupdatets, '2017-01-01')) ) 
;

select * from person_benefit_action where eventname in ('TER') and eventeffectivedate >= '2018-12-01' and personid in 
(select personid from person_bene_election where benefitsubclass in ('10','11','14','15','16','17','60','61') 
    and current_timestamp between createts and endts and benefitelection = 'E' and selectedoption = 'Y' and effectivedate < enddate group by 1)
    ;
join person_benefit_action pba
  on pba.personid = pe.personid
 and pba.eventname in ('TER')    

select * from person_names where lname like 'Frank%';
select * from person_dependent_relationship where personid = '6060';
select * from person_names where personid in ('8215');
select * from person_employment where personid = '8101';

select * from benefit_plan_desc where benefitsubclass in ('14');

select * from person_bene_election 
where benefitsubclass in ('10','11','14','15','16','17')
  and  effectivedate < enddate
  and current_timestamp between createts and endts
  and selectedoption = 'Y' and benefitelection = 'E'
  and personid in ('5976')
  ;
(select distinct personid from person_bene_election where current_timestamp between createts and endts 
                         and benefitsubclass in ('10','11','14','15','16','17') and benefitelection = 'E' and selectedoption = 'Y' and effectivedate < enddate  and personid = '6090');

select * from dependent_enrollment where personid = '5977';
select * from dependent_relationship;
select benefitsubclass from comp_plan_benefit_plan where cobraplan = 'Y' group by 1;
select * from benefit_plan_desc where benefitsubclass in ('15','16','17');

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
     and pbe.benefitsubclass in ('10','11','14')
     and pbe.selectedoption = 'Y'
     and current_date between pbe.effectivedate and pbe.enddate
     and current_timestamp between pbe.createts and pbe.endts     
   where current_timestamp between de.createts and de.endts
    and de.benefitsubclass in ('10','11','14')
    and pdr.dependentrelationship in ('SP','C','NA','S','DP','D')
    and pe.emplstatus = 'A'
    and pbe.benefitelection = 'E'
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
       and de.benefitsubclass in ('10','11','14')
       and pdr.dependentrelationship in ('SP','C','NA','S','DP','D')
   )
)  
















;
select * from dependent_enrollment where personid = '7343';
select * from person_bene_election where personid = '7343' and benefitsubclass = '11';

select * from benefit_plan_desc where benefitsubclass in (
select benefitsubclass from comp_plan_benefit_plan
where current_date between effectivedate and enddate
and current_timestamp between createts and endts
and cobraplan = 'Y'
group by 1)
and current_date between effectivedate and enddate
and current_timestamp between createts and endts;

select personid, benefitsubclass, effectivedate, enddate
  from person_bene_election 
 where benefitsubclass in ('10','11','14','15')
   and enddate < '2199-12-30'
   and date_part('year',enddate)=date_part('year',current_date)
   and personid = '6017'
 ;

select * from person_bene_election 
where benefitsubclass in ('10','11','14','15')
  --and current_date between effectivedate and enddate
  and current_timestamp between createts and endts
  and personid = '6017'
  ;

select * from dependent_enrollment
where current_timestamp between createts and endts
  and current_date between effectivedate and enddate
  and personid = '5988'
  ;

select * from person_employment where personid = '6016';

select * from benefit_plan_desc 
where benefitsubclass in ('10')
  and current_date between effectivedate and enddate
  and current_timestamp between createts and endts
  ;  
select * from person_employment where personid = '1861';
select emplclass from person_employment group by 1;
select * from employmentclasslist;
select * from position_desc;