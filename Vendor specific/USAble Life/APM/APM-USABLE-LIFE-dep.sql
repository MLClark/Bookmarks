select distinct
 pi.personid
,elu.lastupdatets::date 
,pdr.dependentid
,'ACTIVE DEP' ::varchar(30) as qsource
,'50037079' ::char(8) as group_nbr
,left(pi.identity,3)||'-'||substring(pi.identity,4,2)||'-'||right(pi.identity,4) ::char(11) as ssn
,null ::char(9) as empid 
,left(pid.identity,3)||'-'||substring(pid.identity,4,2)||'-'||right(pid.identity,4) ::char(11) as dep_ssn
,pnd.fname ::varchar(50) as fname
,pnd.mname ::char(1) as mname 
,pnd.lname ::varchar(50) as lname
,pnd.title ::varchar(10) as suffix
,' ' ::char(1) as marital_status
,to_char(pvd.birthdate,'mm/dd/yyyy')::char(10) as dob
,pvd.gendercode ::char(1) as gender
,dr.dependentreldesc ::varchar(20) as dep_rel
,null as doh
,null as annual_salary
,null as salary_eff_date
,null as empl_status
,null as empl_status_eff_date
,null as smoker_status
,null as hours_per_week        
,'4196180' ::char(7) as class
,'426971' ::char(6) as bill_group
,null as dept
,null as benefitsubclass 
,null as benefitelection
,null as benefit_desc
,null as benefit_amt
,null as benefit_eff_date
,null as bene_term_date
,null as addr1
,null as addr2
,null as city
,null as state
,null as zip

from person_identity pi

join edi.edi_last_update elu on elu.feedid = 'APM_USAble_Life_Export'

join person_identity pie
  on pie.personid = pi.personid 
 and pie.identitytype = 'EmpNo'
 and current_timestamp between pie.createts and pie.endts

left join person_address pa
  on pa.personid = pi.personid
 and pa.addresstype = 'Res'
 and (current_date between pa.effectivedate and pa.enddate
  or (pa.effectivedate > current_date and pa.enddate > pa.effectivedate and extract(year from pa.effectivedate) = extract(year from current_date)))
 
left join person_vitals pv
  on pv.personid = pi.personid
 and (current_date between pv.effectivedate and pv.enddate
  or (pv.effectivedate > current_date and pv.enddate > pv.effectivedate and extract(year from pv.effectivedate) = extract(year from current_date)))
   
left join person_employment pe
  on pe.personid = pi.personid
 and (current_date between pe.effectivedate and pe.enddate
  or (pe.effectivedate > current_date and pe.enddate > pe.effectivedate and extract(year from pe.effectivedate) = extract(year from current_date)))
 and current_timestamp between pe.createts and pe.endts

left join person_maritalstatus pm
  on pm.personid = pi.personid
 and (current_date between pm.effectivedate and pm.enddate
  or (pm.effectivedate > current_date and pm.enddate > pm.effectivedate and extract(year from pm.effectivedate) = extract(year from current_date)))
 and current_timestamp between pm.createts and pm.endts
 
left join person_names pn
  on pn.personid = pi.personid
 and pn.nametype = 'Legal'
 and (current_date between pn.effectivedate and pn.enddate
  or (pm.effectivedate > current_date and pn.enddate > pn.effectivedate and extract(year from pn.effectivedate) = extract(year from current_date)))
 and current_timestamp between pn.createts and pn.endts
 
left join (select personid, compamount, increaseamount, compevent, frequencycode, earningscode, max(createts) as createts, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate, RANK() OVER (PARTITION BY personid ORDER BY max(effectivedate)desc) AS RANK
             from person_compensation where effectivedate < enddate and current_timestamp between createts and endts and earningscode <> 'BenBase'  
            group by personid, compamount, increaseamount, compevent, frequencycode, earningscode) as pc on pc.personid = pi.personid and pc.rank = 1   

left join  (select personid, scheduledhours, schedulefrequency, max(createts) as createts, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate, RANK() OVER (PARTITION BY personid ORDER BY max(effectivedate)desc) AS RANK
              from pers_pos  where effectivedate < enddate and current_timestamp between createts and endts 
             group by personid, scheduledhours, schedulefrequency) as pos on pos.personid = pi.personid and pos.rank = 1
 
left join frequency_codes fcpos
  on fcpos.frequencycode = pos.schedulefrequency  

join (select personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid, pbe.compplanid, coverageamount, max(effectivedate) as effectivedate, max(enddate) as enddate
             from person_bene_election pbe 
             left join comp_plan_plan_year cppy on cppy.compplanid = pbe.compplanid and cppy.compplanplanyeartype = 'Bene' 
                   and ?::date between cppy.planyearstart::date and cppy.planyearend::date			-- Checks for planYearStartDate parameter for OE and uses current_date for non-OE when planYearStartDate parameter is null
            where benefitsubclass in ('20','21','30','31','25','2Z') and benefitelection = 'E' and selectedoption = 'Y' and current_timestamp between pbe.createts and pbe.endts 
              and case when ?::date > current_date then pbe.effectivedate >= cppy.planyearstart::date 
                       else pbe.effectivedate < pbe.enddate and current_timestamp between pbe.createts and pbe.endts end and pbe.enddate >= '2199-12-30'

            group by personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid, pbe.compplanid, coverageamount) pbe on pbe.personid = pi.personid      
    
----- dependent data

join person_dependent_relationship pdr
  on pdr.personid = pbe.personid
 and current_date between pdr.effectivedate and pdr.enddate
 and current_timestamp between pdr.createts and pdr.endts
 and pdr.dependentrelationship in ('DP','SP','NA')
--  and pdr.dependentrelationship in ('DP','SP','NA','D','S','C','ND','NS','NC') 

left join dependent_enrollment de
  on de.personid = pdr.personid
 and de.dependentid = pdr.dependentid
 AND de.selectedoption = 'Y'
 and de.benefitplanid = pbe.benefitplanid
 and de.benefitsubclass = pbe.benefitsubclass
 and current_date between de.effectivedate and de.enddate
 and current_timestamp between de.createts and de.endts    

join (select lu.key1 ::char(2) as benefitsubclass
            ,lu.key2 ::char(2) as dep_rel
            ,lu.value1  
            ,lu.value2  
       from edi.lookup lu
       join edi.lookup_schema ls on ls.lookupid = lu.lookupid
      where ls.keycoldesc1='Subclass' and lookupname='Useable Life Benefit Lookup' ) as lkup
         on lkup.benefitsubclass = pbe.benefitsubclass and lkup.dep_rel = pdr.dependentrelationship

left join person_identity piD
  on piD.personid = pdr.dependentid
 and piD.identitytype = 'SSN'
 and current_timestamp between piD.createts and piD.endts 
 
left join person_names pnd
  on pnD.personid = pdr.dependentid
 and current_date between pnD.effectivedate and pnD.enddate
 and current_timestamp between pnD.createts and pnD.endts
 and pnD.nametype = 'Dep'
 
left join person_vitals pvD
  on pvD.personid = piD.personid
 and current_date between pvD.effectivedate and pvD.enddate
 and current_timestamp between pvD.createts and pvD.endts  
 
left join person_maritalstatus pmd
  on pmd.personid = pid.personid
 and current_date between pmd.effectivedate and pmd.enddate
 and current_timestamp between pmd.createts and pmd.endts 

left join dependent_relationship dr
  on dr.dependentrelationship = pdr.dependentrelationship
 
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  and (pe.emplstatus in ('A','L','P')) 

