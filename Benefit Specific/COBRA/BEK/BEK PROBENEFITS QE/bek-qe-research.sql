select * from benefit_plan_desc where current_date between effectivedate and enddate and current_timestamp between createts and endts;
select * from person_bene_election where current_timestamp between createts and endts and personid = '324' and benefitsubclass = '60'; 
(select distinct personid from person_bene_election where current_timestamp between createts and endts and personid = '358'
                         and benefitsubclass in ('10','11','14','60','61') and benefitelection = 'E' and selectedoption = 'Y' and effectivedate < enddate);


 ( select distinct de.dependentid as dependentid, pne.name, pnd.name, pbe.effectivedate
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
     and pnd.effectivedate < pnd.enddate  
    join person_vitals pvd
      on pvd.personid = de.dependentid
     and current_date between pvd.effectivedate and pvd.enddate
     and current_timestamp between pvd.createts and pvd.endts
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
    join person_bene_election pbe
      on pbe.personid = de.personid
     and pbe.benefitsubclass in ('10','11','14','60')
     and pbe.selectedoption = 'Y'
        
     and current_date between pbe.effectivedate and pbe.enddate
     and current_timestamp between pbe.createts and pbe.endts   
   where current_timestamp between de.createts and de.endts
    and de.benefitsubclass in ('10','11','14','60')
    and pe.emplstatus = 'A'
    and pbe.benefitelection <> 'W' 
    and date_part('year',de.enddate)=date_part('year',current_date)
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
       and de.benefitsubclass in ('10','11','14','60')
   )
)             ;

select * from dependent_enrollment where dependentid = '575';    

select * from person_employment where emplstatus = 'T' and emplevent = 'Death';   

select * from person_maritalstatus pm where pm.maritalstatus = 'D'       