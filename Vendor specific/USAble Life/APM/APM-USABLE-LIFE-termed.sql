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
,pm.maritalstatus ::char(1) as marital_status
,to_char(pv.birthdate,'mm/dd/yyyy')::char(10) as dob
,pv.gendercode ::char(1) as gender
,' ' ::char(1) as dep_rel
,to_char(pe.emplhiredate,'mm/dd/yyyy') ::char(10) as doh
,case when pc.frequencycode = 'A' then round(pc.compamount,2) 
      when ((pe.emplstatus in ('R','T')) or pos.scheduledhours = 0) and pc.frequencycode = 'H' then round((pc.compamount * 2080),2)
      when pc.frequencycode = 'H' then round((pc.compamount * (pos.scheduledhours * fcpos.annualfactor)),2) end as annual_salary
,to_char(pc.effectivedate,'mm/dd/yyyy')::char(10) as salary_eff_date
,pe.emplstatus ::char(1) as empl_status
,case when pe.emplstatus in ('A','L') then to_char(coalesce(pe.emplhiredate,pe.empllasthiredate),'mm/dd/yyyy')
      when pe.emplstatus in ('R','T') then to_char(pe.effectivedate,'mm/dd/yyyy') 
      else '' end ::char(10) as empl_status_eff_date
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
,pbe.coverageamount as benefit_amt
,to_char(pbe.effectivedate,'mm/dd/yyyy') ::char(10) as benefit_eff_date
,case when pbe.benefitelection = 'E' then to_char(pbe.enddate,'mm/dd/yyyy')
      when pe.emplstatus = 'T' then to_char(pe.effectivedate,'mm/dd/yyyy') end ::char(10) as bene_term_date

,pa.streetaddress ::varchar(30) as addr1
,pa.streetaddress2 ::varchar(30) as addr2
,pa.city ::varchar(30) as city
,pa.stateprovincecode ::char(2) as state
,pa.postalcode ::char(9) as zip

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
         as lkup on lkup.benefitsubclass = pbe.benefitsubclass and lkup.dep_rel in ('EE','D','S','C','ND','NS','NC') ---('EE','DP','SP','NA','D','S','C','ND','NS','NC') 

where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  and pbe.benefitelection != 'W'
  and (pe.emplstatus in ('R','T') and pe.effectivedate::date >= elu.lastupdatets::date)