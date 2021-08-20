select distinct

 pi.personid
,'0' as dependentid
,'TERMED EE' ::varchar(30)
,'2' ::char(10) as sort_seq
,pe.emplstatus
,pe.effectivedate
,'EMP' ::char(3) as recordtype
,'4A1032' ::char(15) as company_no
,pie.identity ::char(20) as empnbr
,left(pi.identity,3)||'-'||substring(pi.identity,4,2)||'-'||right(pi.identity,4) ::char(12) as ssn
,to_char(pv.birthdate,'yyyy-mm-dd')::char(10) as dob
,pn.fname ::char(25) as fname
,pn.lname ::char(35) as lname
,pn.mname ::char(1) as mname
,'English' ::char(25) as language_code


from person_identity pi

left join edi.edi_last_update elu on elu.feedid = 'AXU_Infinisource_Cobra_QE_Export'

join person_identity pie
  on pie.personid = pi.personid
 and pie.identitytype = 'EmpNo'
 and current_timestamp between pie.createts and pie.endts
 
left join person_vitals pv
  on pv.personid = pi.personid
 and current_date between pv.effectivedate and pv.enddate
 and current_timestamp between pv.createts and pv.endts 

left join person_names pn
  on pn.personid = pi.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts 

join person_employment pe
  on pe.personid = pi.personid
 and pe.emplclass <> 'P'
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts

-- for termed ee's

join person_benefit_action pba
  on pba.personid = pe.personid
 and pba.eventeffectivedate >= elu.lastupdatets::date  
 and pba.eventname in ('TER','OAC','FTP')  

JOIN person_bene_election pbe 
  on pbe.personid = pba.personid 
 --and pbe.personbenefitactionpid = pba.personbenefitactionpid  
 and pbe.selectedoption = 'Y' 
 and pbe.benefitelection <> 'W'
 and pbe.benefitsubclass in ('10','11','14','60')
 and pe.effectivedate - interval '1 day' <= pbe.effectivedate 
 and pbe.effectivedate < pbe.enddate
 AND current_timestamp between pbe.createts AND pbe.endts
  -- to be qualified for cobra the emp must have participated in employer's health care plan  
 and pbe.personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts 
                         and benefitsubclass in ('10','11','14','60') and benefitelection = 'E' and selectedoption = 'Y' and effectivedate < enddate) 

where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts 
  and pe.emplstatus in ('T','R') 
  and pe.benefitstatus in ('T','A')
  and (pe.effectivedate >= elu.lastupdatets::DATE 
   or (pe.createts > elu.lastupdatets and pe.effectivedate < coalesce(elu.lastupdatets, '2017-01-01')) )   
  and pe.emplclass <> 'P'
  and pe.empleventdetcode <> 'Death'
  
  UNION
     
select distinct

 pi.personid
,'0' as dependentid
,'DECEASED EE' ::varchar(30)
,'2' ::char(10) as sort_seq
,pe.emplstatus
,pe.effectivedate
,'EMP' ::char(3) as recordtype
,'4A1032' ::char(15) as company_no
,pie.identity ::char(20) as empnbr
,left(pi.identity,3)||'-'||substring(pi.identity,4,2)||'-'||right(pi.identity,4) ::char(12) as ssn
,to_char(pv.birthdate,'yyyy-mm-dd')::char(10) as dob
,pn.fname ::char(25) as fname
,pn.lname ::char(35) as lname
,pn.mname ::char(1) as mname
,'English' ::char(25) as language_code


from person_identity pi

left join edi.edi_last_update elu on elu.feedid = 'AXU_Infinisource_Cobra_QE_Export'

join person_identity pie
  on pie.personid = pi.personid
 and pie.identitytype = 'EmpNo'
 and current_timestamp between pie.createts and pie.endts
 
left join person_vitals pv
  on pv.personid = pi.personid
 and current_date between pv.effectivedate and pv.enddate
 and current_timestamp between pv.createts and pv.endts 

left join person_names pn
  on pn.personid = pi.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts 

join person_employment pe
  on pe.personid = pi.personid
 and pe.emplclass <> 'P'
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts

-- for termed ee's

join person_benefit_action pba
  on pba.personid = pe.personid
 and pba.eventeffectivedate >= elu.lastupdatets::date
 and pba.eventname in ('TER')    

JOIN person_bene_election pbe 
  on pbe.personid = pba.personid 
 --and pbe.personbenefitactionpid = pba.personbenefitactionpid  
 and pbe.selectedoption = 'Y' 
 and pbe.benefitelection <> 'W'
 and pbe.benefitsubclass in ('10','11','14','60')
 and pe.effectivedate - interval '1 day' <= pbe.effectivedate 
 and pbe.effectivedate < pbe.enddate
 AND current_timestamp between pbe.createts AND pbe.endts
  -- to be qualified for cobra the emp must have participated in employer's health care plan  
 and pbe.personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts 
                         and benefitsubclass in ('10','11','14','60') and benefitelection = 'E' and selectedoption = 'Y' and effectivedate < enddate) 

where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts 
  and pe.emplstatus in ('T','R') 
  and pe.benefitstatus in ('T','A')
  and (pe.effectivedate >= elu.lastupdatets::DATE 
   or (pe.createts > elu.lastupdatets and pe.effectivedate < coalesce(elu.lastupdatets, '2017-01-01')) )   
  and pe.emplclass <> 'P'
  and pe.empleventdetcode = 'Death'

  /* DEATH EVENTS - EE must have surviving dependents to get included on QE file  */
  and pe.personid in   

(  select distinct pe.personid
 
        from person_employment pe
        join person_benefit_action pba
          on pba.personid = pe.personid
         and pba.eventeffectivedate >= elu.lastupdatets::date  
         and pba.eventname in ('TER')    
        
        JOIN person_bene_election pbe 
          on pbe.personid = pba.personid 
        -- and pbe.personbenefitactionpid = pba.personbenefitactionpid  
         and pbe.selectedoption = 'Y' 
         and pbe.benefitelection <> 'W'
         and pbe.benefitsubclass in ('10','11','14','60')
         and pe.effectivedate - interval '1 day' <= pbe.effectivedate 
         
        join person_dependent_relationship pdr
          on pdr.personid = pbe.personid
         and current_date between pdr.effectivedate and pdr.enddate
         and current_timestamp between pdr.createts and pdr.endts  
        
        join dependent_enrollment de
          on de.personid = pdr.personid
         and de.dependentid = pdr.dependentid
         and de.selectedoption = 'Y'
         and de.benefitplanid = pbe.benefitplanid
         and de.benefitsubclass = pbe.benefitsubclass
         and current_date >= de.effectivedate 
         and current_timestamp between de.createts and de.endts 

        where pe.empleventdetcode = 'Death'
  )  

  UNION
  
select distinct

 pi.personid
,'0' as dependentid
,'ACTIVE EE TERMED DEP' ::varchar(30)
,'2' ::char(10) as sort_seq
,pe.emplstatus
,pe.effectivedate
,'EMP' ::char(3) as recordtype
,'4A1032' ::char(15) as company_no
,pie.identity ::char(20) as empnbr
,left(pi.identity,3)||'-'||substring(pi.identity,4,2)||'-'||right(pi.identity,4) ::char(12) as ssn
,to_char(pv.birthdate,'yyyy-mm-dd')::char(10) as dob
,pn.fname ::char(25) as fname
,pn.lname ::char(35) as lname
,pn.mname ::char(1) as mname
,'English' ::char(25) as language_code


from person_identity pi

left join edi.edi_last_update elu on elu.feedid = 'AXU_Infinisource_Cobra_QE_Export'

join person_identity pie
  on pie.personid = pi.personid
 and pie.identitytype = 'EmpNo'
 and current_timestamp between pie.createts and pie.endts
 
join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts

left join person_address pa 
  on pa.personid = pe.personid
 and pa.addresstype = 'Res'
 and current_date between pa.effectivedate and pa.enddate
 and current_timestamp between pa.createts and pa.endts

join person_benefit_action pba
  on pba.personid = pe.personid
 and pba.eventeffectivedate >= elu.lastupdatets::date
 and pba.eventname in ('TER','DepAge')     
 
join person_bene_election pbe 
  on pbe.personid = pba.personid
 and pbe.benefitsubclass in ('10','11','14','60')
 and pbe.selectedoption = 'Y' 
 AND current_date between pbe.effectivedate AND pbe.enddate 
 AND current_timestamp between pbe.createts AND pbe.endts
 and pbe.personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts 
                         and benefitsubclass in ('10','11','14','60') and benefitelection = 'E' and selectedoption = 'Y' and effectivedate < enddate)  
                         
LEFT JOIN person_names pn 
  ON pn.personid = pbe.personid
 and pn.nametype = 'Legal' 
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts
 
left join person_vitals pv
  on pv.personid = pbe.personid
 and current_date between pv.effectivedate and pv.enddate
 and current_timestamp between pv.createts and pv.endts    


join person_dependent_relationship pdr
  on pdr.personid = pbe.personid
 and current_date between pdr.effectivedate and pdr.enddate
 and current_timestamp between pdr.createts and pdr.endts  

join dependent_enrollment de
  on de.dependentid = pdr.dependentid
 and de.benefitsubclass = pbe.benefitsubclass
 and de.personid = pbe.personid
 and current_timestamp between de.createts and de.endts
 and de.dependentid in 
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
     and pbe.benefitsubclass in ('10','11','14','60')
     and pbe.selectedoption = 'Y'
     and current_date between pbe.effectivedate and pbe.enddate
     and current_timestamp between pbe.createts and pbe.endts     
   where current_timestamp between de.createts and de.endts
    and de.benefitsubclass in ('10','11','14','60')
    --and pdr.dependentrelationship in ('S','D','C','NC','NS','ND')
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
       and de.benefitsubclass in ('10','11','14','60')-- and de.dependentid = '1964'
       --and pdr.dependentrelationship in ('S','D','C','NC','NS','ND')
   )
)     

where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts 
  and pbe.effectivedate::date >= elu.lastupdatets::date
  
  UNION
  
  select distinct

 pi.personid
,'0' as dependentid
,'ACTIVE EE DIVORCED DEP' ::varchar(30)
,'2' ::char(10) as sort_seq
,pe.emplstatus
,pe.effectivedate
,'EMP' ::char(3) as recordtype
,'4A1032' ::char(15) as company_no
,pie.identity ::char(20) as empnbr
,left(pi.identity,3)||'-'||substring(pi.identity,4,2)||'-'||right(pi.identity,4) ::char(12) as ssn
,to_char(pv.birthdate,'yyyy-mm-dd')::char(10) as dob
,pn.fname ::char(25) as fname
,pn.lname ::char(35) as lname
,pn.mname ::char(1) as mname
,'English' ::char(25) as language_code


from person_identity pi

left join edi.edi_last_update elu on elu.feedid = 'AXU_Infinisource_Cobra_QE_Export'

join person_identity pie
  on pie.personid = pi.personid
 and pie.identitytype = 'EmpNo'
 and current_timestamp between pie.createts and pie.endts
 
left join person_vitals pv
  on pv.personid = pi.personid
 and current_date between pv.effectivedate and pv.enddate
 and current_timestamp between pv.createts and pv.endts 

left join person_names pn
  on pn.personid = pi.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts 

join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts

join person_benefit_action pba
  on pba.personid = pe.personid
 and pba.eventeffectivedate >= elu.lastupdatets::date
 and pba.eventname in ('DIV')      

join person_bene_election pbe 
  on pbe.personid = pba.personid
 and pbe.benefitsubclass in ('10','11','14','60')
 and pbe.selectedoption = 'Y' 
 and pbe.benefitelection <> 'W'
 and pbe.effectivedate < pbe.enddate
 and current_timestamp between pbe.createts and pbe.endts
   -- to be qualified for cobra the emp must have participated in employer's health care plan  
 and pbe.personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts 
                         and benefitsubclass in ('10','11','14','60') and benefitelection = 'E' and selectedoption = 'Y' and effectivedate < enddate)  
                         
join person_dependent_relationship pdr
  on pdr.personid = pbe.personid
 and current_date between pdr.effectivedate and pdr.enddate
 and current_timestamp between pdr.createts and pdr.endts  

join dependent_enrollment de
  on de.personid = pdr.personid
 and de.dependentid = pdr.dependentid
 and de.selectedoption = 'Y'
 and de.benefitplanid = pbe.benefitplanid
 and de.benefitsubclass = pbe.benefitsubclass
 and current_date >= de.effectivedate 
 and current_timestamp between de.createts and de.endts                           

join person_maritalstatus pm
  on pm.personid = pbe.personid 
 and current_date between pm.effectivedate and pm.enddate
 and current_timestamp between pm.createts and pm.endts                          

where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts 
  and pe.emplstatus in ('A') 
  and pm.maritalstatus = 'D'  
  and pdr.dependentrelationship in ('SP','DP','NA','X') 
  and pbe.effectivedate::date >= elu.lastupdatets::date
 
 
  order by empnbr
   