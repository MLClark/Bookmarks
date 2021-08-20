select distinct
 pi.personid
,elu.lastupdatets::date 
,'0' as dependentid
,'ACTIVE EE' ::varchar(30) as qsource
,'50037079' ::char(8) as group_nbr
,left(pi.identity,3)||'-'||substring(pi.identity,4,2)||'-'||right(pi.identity,4) ::char(11) as ssn
,pie.identity ::char(9) as empid 
,' ' ::char(1) as dep_ssn
,pn.fname ::varchar(50) as fname
,pn.mname ::char(1) as mname 
,pn.lname ::varchar(50) as lname
,pn.title ::varchar(10) as suffix
,case when pm.maritalstatus = 'S' then 'Single' 
      when pm.maritalstatus = 'M' then 'Married'
      when pm.maritalstatus = 'W' then 'Single'
      when pm.maritalstatus = 'D' then 'Divorced'
      when pm.maritalstatus = 'E' then 'Separated'
      when pm.maritalstatus = 'C' then 'Common Law'
      when pm.maritalstatus = 'P' then 'Domestic Partner'
      when pm.maritalstatus = 'N' then 'Not Married'
      else ' ' end ::varchar(20) as marital_status
,to_char(pv.birthdate,'mm/dd/yyyy')::char(10) as dob
,pv.gendercode ::char(1) as gender
,' ' ::char(1) as dep_rel
,to_char(pe.emplhiredate,'mm/dd/yyyy') ::char(10) as doh
,case when pc.frequencycode = 'A' then round(pc.compamount,2) 
      when ((pe.emplstatus in ('R','T')) or pos.scheduledhours = 0) and pc.frequencycode = 'H' then round((pc.compamount * 2080),2)
      when pc.frequencycode = 'H' then round((pc.compamount * (pos.scheduledhours * fcpos.annualfactor)),2) end as annual_salary
      
,to_char(greatest(pc.effectivedate,'10/01/2019'),'mm/dd/yyyy')::char(10) as salary_eff_date  --- 3/2 pass the oldest date 10/1/2019

,case when pe.emplstatus = 'A' then 'Active'
      when pe.emplstatus = 'T' then 'Terminated'
      when pe.emplstatus = 'R' then 'Retired'
      when pe.emplstatus = 'L' then 'Leave'
      when pe.emplstatus = 'D' then 'Deceased'
      when pe.emplstatus = 'p' then 'Leave with Pay'
      end  ::varchar(20) as empl_status
      
,case when pe.emplstatus in ('A','L') then to_char(greatest(coalesce(pe.emplhiredate,pe.empllasthiredate),'10/01/2019'),'mm/dd/yyyy')
      when pe.emplstatus in ('R','T') then to_char(greatest(pe.effectivedate,'10/01/2019'),'mm/dd/yyyy') 
      else '' end ::char(10) as empl_status_eff_date --- 3/2 pass the oldest date 10/1/2019
      
,' ' ::char(1) as smoker_status
,case when pos.schedulefrequency = 'W' then pos.scheduledhours
      when pos.schedulefrequency = 'M' then round((pos.scheduledhours * 12 / 52),2)
      end as hours_per_week        
,'4196180' ::char(7) as class
,'426971' ::char(6) as bill_group
,' ' ::char(1) as dept
,pbe.benefitsubclass ::char(2)
,pbe.benefitelection
,lkup.value1 ::varchar(30) as benefit_desc
,case when pbe.benefitsubclass in ('30','31') then 0.6
      else pbe.coverageamount end as benefit_amt
,to_char(pbe.effectivedate,'mm/dd/yyyy') ::char(10) as benefit_eff_date
,case when pbe.benefitelection = 'T' then to_char(pbe.effectivedate,'mm/dd/yyyy')
      when pe.emplstatus = 'T' then to_char(pe.effectivedate,'mm/dd/yyyy') end ::char(10) as bene_term_date
,pa.streetaddress ::varchar(30) as addr1
,pa.streetaddress2 ::varchar(30) as addr2
,pa.city ::varchar(30) as city
,pa.stateprovincecode ::char(2) as state
,pa.postalcode ::char(5) as zip  --- 3/2 restrict to 5 chars

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
    
join (select lu.key1 ::char(2) as benefitsubclass
            ,lu.key2 ::char(2) as dep_rel
            ,lu.value1  
       from edi.lookup lu
       join edi.lookup_schema ls on ls.lookupid = lu.lookupid
      where ls.keycoldesc1='Subclass' and lookupname='Useable Life Benefit Lookup' ) as lkup on lkup.benefitsubclass = pbe.benefitsubclass 
      and lkup.dep_rel in ('EE','DP','SP','NA','D','S','C','ND','NS','NC')

where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  and (pe.emplstatus in ('A','L','P')) 
   
  union
 
 select distinct
 pi.personid
,elu.lastupdatets::date 
,'0' as dependentid
,'TERMED EE' ::varchar(30) as qsource
,'50037079' ::char(8) as group_nbr
,left(pi.identity,3)||'-'||substring(pi.identity,4,2)||'-'||right(pi.identity,4) ::char(11) as ssn
,pie.identity ::char(9) as empid 
,' ' ::char(1) as dep_ssn
,pn.fname ::varchar(50) as fname
,pn.mname ::char(1) as mname 
,pn.lname ::varchar(50) as lname
,pn.title ::varchar(10) as suffix
,case when pm.maritalstatus = 'S' then 'Single' 
      when pm.maritalstatus = 'M' then 'Married'
      when pm.maritalstatus = 'W' then 'Single'
      when pm.maritalstatus = 'D' then 'Divorced'
      when pm.maritalstatus = 'E' then 'Separated'
      when pm.maritalstatus = 'C' then 'Common Law'
      when pm.maritalstatus = 'P' then 'Domestic Partner'
      when pm.maritalstatus = 'N' then 'Not Married'
      else ' ' end ::varchar(20) as marital_status
,to_char(pv.birthdate,'mm/dd/yyyy')::char(10) as dob
,pv.gendercode ::char(1) as gender
,' ' ::char(1) as dep_rel
,to_char(pe.emplhiredate,'mm/dd/yyyy') ::char(10) as doh
,case when pc.frequencycode = 'A' then round(pc.compamount,2) 
      when ((pe.emplstatus in ('R','T')) or pos.scheduledhours = 0) and pc.frequencycode = 'H' then round((pc.compamount * 2080),2)
      when pc.frequencycode = 'H' then round((pc.compamount * (pos.scheduledhours * fcpos.annualfactor)),2) end as annual_salary
      
,to_char(greatest(pc.effectivedate,'10/01/2019'),'mm/dd/yyyy')::char(10) as salary_eff_date  --- 3/2 pass the oldest date 10/1/2019

,case when pe.emplstatus = 'A' then 'Active'
      when pe.emplstatus = 'T' then 'Terminated'
      when pe.emplstatus = 'R' then 'Retired'
      when pe.emplstatus = 'L' then 'Leave'
      when pe.emplstatus = 'D' then 'Deceased'
      when pe.emplstatus = 'p' then 'Leave with Pay'
      end  ::varchar(20) as empl_status
      
,case when pe.emplstatus in ('A','L') then to_char(greatest(coalesce(pe.emplhiredate,pe.empllasthiredate),'10/01/2019'),'mm/dd/yyyy')
      when pe.emplstatus in ('R','T') then to_char(greatest(pe.effectivedate,'10/01/2019'),'mm/dd/yyyy') 
      else '' end ::char(10) as empl_status_eff_date --- 3/2 pass the oldest date 10/1/2019
      
,' ' ::char(1) as smoker_status
,case when pos.schedulefrequency = 'W' then pos.scheduledhours
      when pos.schedulefrequency = 'M' then round((pos.scheduledhours * 12 / 52),2)
      end as hours_per_week        
,'4196180' ::char(7) as class
,'426971' ::char(6) as bill_group
,' ' ::char(1) as dept
,pbe.benefitsubclass ::char(2)
,pbe.benefitelection
,lkup.value1 ::varchar(30) as benefit_desc
,case when pbe.benefitsubclass in ('30','31') then 0.6
      else pbe.coverageamount end as benefit_amt
,to_char(pbe.effectivedate,'mm/dd/yyyy') ::char(10) as benefit_eff_date
,case when pbe.benefitelection = 'E' then to_char(pbe.enddate,'mm/dd/yyyy')
      when pe.emplstatus = 'T' then to_char(pe.effectivedate,'mm/dd/yyyy') end ::char(10) as bene_term_date

,pa.streetaddress ::varchar(30) as addr1
,pa.streetaddress2 ::varchar(30) as addr2
,pa.city ::varchar(30) as city
,pa.stateprovincecode ::char(2) as state
,pa.postalcode ::char(5) as zip  --- 3/2 restrict to 5 chars

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

join person_bene_election pbe 
  on pbe.personid = pe.personid 
 and pbe.selectedoption = 'Y' 
 and pbe.benefitelection <> 'W'
 and pbe.benefitsubclass in ('20','21','30','31','25','2Z')
 and (pbe.enddate - interval '1 day' > pbe.effectivedate and pbe.benefitelection = 'E')
 and (pe.effectivedate - interval '1 day')::date between pbe.effectivedate and pbe.enddate
 AND current_timestamp between pbe.createts and pbe.endts 
 and pbe.personid||pbe.benefitsubclass||pbe.effectivedate 
  in (select distinct personid||benefitsubclass||effectivedate from person_bene_election
        join edi.edi_last_update elu on elu.feedid = 'APM_USAble_Life_Export'
       where current_timestamp between createts and endts 
         and benefitsubclass in ('20','21','30','31','25','2Z') and benefitelection = 'E' and selectedoption = 'Y' and effectivedate < enddate
         and enddate - interval '1 day' > effectivedate and effectivedate::date >= elu.lastupdatets::date) 
 
join comp_plan_plan_year cppy 
  on cppy.compplanid = pbe.compplanid 
 and cppy.compplanplanyeartype = 'Bene' 
 and ?::date between cppy.planyearstart::date and cppy.planyearend::date			-- Checks for planYearStartDate parameter for OE and uses current_date for non-OE when planYearStartDate parameter is null
                    
join (select lu.key1 ::char(2) as benefitsubclass
            ,lu.key2 ::char(2) as dep_rel
            ,lu.value1  
       from edi.lookup lu
       join edi.lookup_schema ls on ls.lookupid = lu.lookupid
      where ls.keycoldesc1='Subclass' and lookupname='Useable Life Benefit Lookup' ) 
         as lkup on lkup.benefitsubclass = pbe.benefitsubclass and lkup.dep_rel in ('EE','DP','SP','NA','D','S','C','ND','NS','NC') 

where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  and pbe.benefitelection != 'W'
  and (pe.emplstatus in ('R','T') and pe.effectivedate::date >= elu.lastupdatets::date) 
   
    union
---- Only spouse's should appear on the file  
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
,0 as annual_salary
,null as salary_eff_date
,null as empl_status
,null as empl_status_eff_date
,null as smoker_status
,0 as hours_per_week        
,'4196180' ::char(7) as class
,'426971' ::char(6) as bill_group
,null as dept
,null as benefitsubclass 
,null as benefitelection
,null as benefit_desc
,0 as benefit_amt
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


  union 
  
 select distinct
 pi.personid
,elu.lastupdatets::date 
,pdr.dependentid
,'TERMED DEP' ::varchar(30) as qsource
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
,0 as annual_salary
,null as salary_eff_date
,null as empl_status
,null as empl_status_eff_date
,null as smoker_status
,0 as hours_per_week        
,'4196180' ::char(7) as class
,'426971' ::char(6) as bill_group
,null as dept
,null as benefitsubclass 
,null as benefitelection
,null as benefit_desc
,0 as benefit_amt
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

join person_bene_election pbe 
  on pbe.personid = pe.personid 
 and pbe.selectedoption = 'Y' 
 and pbe.benefitelection <> 'W'
 and pbe.benefitsubclass in ('20','21','30','31','25','2Z')
 and (pbe.enddate - interval '1 day' > pbe.effectivedate and pbe.benefitelection = 'E')
 and (pe.effectivedate - interval '1 day')::date between pbe.effectivedate and pbe.enddate
 AND current_timestamp between pbe.createts and pbe.endts 
 and pbe.personid||pbe.benefitsubclass||pbe.effectivedate 
  in (select distinct personid||benefitsubclass||effectivedate from person_bene_election
        join edi.edi_last_update elu on elu.feedid = 'APM_USAble_Life_Export'
       where current_timestamp between createts and endts 
         and benefitsubclass in ('20','21','30','31','25','2Z') and benefitelection = 'E' and selectedoption = 'Y' and effectivedate < enddate
         and enddate - interval '1 day' > effectivedate and effectivedate::date >= elu.lastupdatets::date) 
 
join comp_plan_plan_year cppy 
  on cppy.compplanid = pbe.compplanid 
 and cppy.compplanplanyeartype = 'Bene' 
 and ?::date between cppy.planyearstart::date and cppy.planyearend::date			-- Checks for planYearStartDate parameter for OE and uses current_date for non-OE when planYearStartDate parameter is null
    
----- dependent data

join person_dependent_relationship pdr
  on pdr.personid = pbe.personid
 and current_date between pdr.effectivedate and pdr.enddate
 and current_timestamp between pdr.createts and pdr.endts
 and pdr.dependentrelationship in ('DP','SP','NA')
 --and pdr.dependentrelationship in ('DP','SP','NA','D','S','C','ND','NS','NC')

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
  and pbe.benefitelection != 'W'
  and (pe.emplstatus in ('R','T') and pe.effectivedate::date >= elu.lastupdatets::date)  
    

  order by personid,dependentid,benefitsubclass asc
  
