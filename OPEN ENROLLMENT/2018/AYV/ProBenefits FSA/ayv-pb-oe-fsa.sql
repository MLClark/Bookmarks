select distinct
 pi.personid
,pip.identity
,pe.emplstatus
,case when substring(pi.identity from 4 for 1) = '-' then pi.identity 
      else left(pi.identity,3)||'-'||substring(pi.identity,4,2)||'-'||right(pi.identity,4) end as ssn

,pn.fname ::varchar(100) as fname
,pn.lname ::varchar(100) as lname
,pn.mname ::char(1) as mname
       
,pu.frequencycode ::char(1) as payroll_freq
,to_char(current_date,'mm/dd/yyyy') ::char(10) as payroll_file_date  --date of file submitted
,to_char(pbe.effectivedate,'mm/dd/yyyy') ::char(10) as edoc
-- select * from benefit_plan_desc where benefitsubclass in ('10');
,case when pbe.benefitsubclass = '6Z' and pbe.benefitplanid = '47'  then 'HSA Employee Only'
      when pbe.benefitsubclass = '6Z' and pbe.benefitplanid = '50'  then 'HSA Family'
      when pbe.benefitsubclass = '60' and pbe.benefitplanid = '83'  then 'Health FSA'
      when pbe.benefitsubclass = '60' and pbe.benefitplanid = '341' then 'Limited FSA'
      when pbe.benefitsubclass = '61' then 'Dep FSA'
      when pbe.benefitsubclass = '10' and pbe.benefitplanid = '311' then 'UHC - HDHP'
      when pbe.benefitsubclass = '10' and pbe.benefitplanid = '314' then 'UHC - PPO'
      when pbe.benefitsubclass = '10' then 'Medical'
      when pbe.benefitsubclass = '11' then 'Dental'
      else ' ' end ::varchar(20) as ded_code
      
,pu.frequencycode ::char(1) as ded_freq   

,case when pbe.benefitsubclass = '6Z' then cast(pplfsa.employeerate  as dec(18,2))
      when pbe.benefitsubclass = '60' then cast(ppmfsa.employeerate  as dec(18,2))
      when pbe.benefitsubclass = '61' then cast(ppdfsa.employeerate  as dec(18,2))
      when pbe.benefitsubclass = '10' then cast(ppmed.employeerate  as dec(18,2))
      when pbe.benefitsubclass = '11' then cast(ppdnt.employeerate  as dec(18,2))
      end as ded_amount 

,pu.frequencycode ::char(1) as er_contrib_freq

,case when pbe.benefitsubclass = '6Z' then cast(pplfsa.employercost as dec(18,2))
      when pbe.benefitsubclass = '60' then cast(ppmfsa.employercost as dec(18,2))
      when pbe.benefitsubclass = '61' then cast(ppdfsa.employercost as dec(18,2))
      when pbe.benefitsubclass = '10' then cast(ppmed.employercost  as dec(18,2))
      when pbe.benefitsubclass = '11' then cast(ppdnt.employercost  as dec(18,2))  
end as er_contrib_amt

,case when pbe.benefitsubclass  = '6Z' then cast(pbelfsa.coverageamount as dec(18,2))
      when pbe.benefitsubclass  = '60' then cast(pbemfsa.coverageamount as dec(18,2))
      when pbe.benefitsubclass  = '61' then cast(pbedfsa.coverageamount as dec(18,2)) 
      else 0 end as annual_election  
      
,' ' ::char(1) as dept_div
,to_char(pv.birthdate,'mm/dd/yyyy') ::char(10) as dob      
,to_char(pe.empllasthiredate,'mm/dd/yyyy') ::char(10) as doh        
  
,case when pe.emplstatus = 'T' then to_char(pe.effectivedate,'mm/dd/yyyy') else ' ' end ::char(10) as term_date
,case when pe.emplstatus = 'T' then to_char(pe.paythroughdate,'mm/dd/yyyy') else ' ' end ::char(10) as paythru_date
,case when pe.emplstatus = 'T' then to_char(pbe.effectivedate,'mm/dd/yyyy') else ' ' end ::char(10) as expir_date 

,'"'||pd.positiontitle||'"' ::varchar(100) as job_title

,case when pc.frequencycode = 'H' then cast(pc.compamount  * pp.scheduledhours * 24 as dec(18,2))
      else cast(pc.compamount as dec(18,2)) end as salary
,' ' ::char(1) as ownership_pct
,'"'||pa.streetaddress||'"' ::varchar(50) as addr1
,'"'||pa.streetaddress2||'"' ::varchar(50) as addr2
,pa.city ::varchar(50) as city
,pa.stateprovincecode ::char(2) as state
,pa.postalcode ::varchar(11) as zip
,coalesce(pncw.url,pnch.url,pnco.url) ::varchar(200) as email
,'"Strategic Link Consulting"' ::varchar(50) as company_code

from person_identity pi

join person_identity pip
  on pip.personid = pi.personid
 and pip.identitytype = 'PSPID'
 and current_timestamp between pip.createts and pip.endts

join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts

join person_names pn
  on pn.personid = pi.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts 

join person_vitals pv
  on pv.personid = pi.personid
 and current_date between pv.effectivedate and pv.enddate
 and current_timestamp between pv.createts and pv.endts  

left join person_compensation pc
  on pc.personid = pi.personid
 and current_date between pc.effectivedate and pc.enddate
 and current_timestamp between pc.createts and pc.endts  

join person_address pa
  on pa.personid = pi.personid
 and pa.addresstype = 'Res'
 and current_date between pa.effectivedate and pa.enddate
 and current_timestamp between pa.createts and pa.endts 

LEFT JOIN person_net_contacts pncw 
  ON pncw.personid = pi.personid 
 AND pncw.netcontacttype = 'WRK'::bpchar 
 AND current_date between pncw.effectivedate and pncw.enddate
 AND current_timestamp between pncw.createts and pncw.endts
 
LEFT JOIN person_net_contacts pnch
  ON pnch.personid = pi.personid 
 AND pnch.netcontacttype = 'HomeEmail'::bpchar 
 AND current_date between pnch.effectivedate and pnch.enddate
 AND current_timestamp between pnch.createts and pnch.endts 

LEFT JOIN person_net_contacts pnco
  ON pnco.personid = pi.personid 
 AND pnco.netcontacttype = 'Other'::bpchar 
 AND current_date between pnco.effectivedate and pnco.enddate
 AND current_timestamp between pnco.createts and pnco.endts   
 
join person_bene_election pbe
  on pbe.personid = pi.personid
 and pbe.selectedoption = 'Y'
 and current_timestamp between pbe.createts and pbe.endts
--------------------------------------- 
----- (6Z) Limited FSA (NEW 2019) -----
--------------------------------------- 
left join person_bene_election pbelfsa
  on pbelfsa.personid = pbe.personid
 and pbelfsa.benefitsubclass in ('6Z')
 and pbelfsa.selectedoption = 'Y'
 and case when ? = 'OE' then pbelfsa.benefitelection  = 'E' and pbelfsa.effectivedate >= date_trunc('year', current_date + interval '1 year') and pbelfsa.enddate >= '2199-12-30'
          when ? = 'FF' then pbelfsa.benefitelection <> 'W' and current_date between pbelfsa.effectivedate and pbelfsa.enddate end
 and current_timestamp between pbelfsa.createts and pbelfsa.endts 
-------------------------------------- 
----- Limited FSA Per Pay Amount -----
--------------------------------------
left join personbenoptioncostl pplfsa
  on pplfsa.personid = pbelfsa.personid
 and pplfsa.costsby = 'P'
 and pplfsa.personbeneelectionpid = pbelfsa.personbeneelectionpid    
-------------------------------------
----- Limited FSA Annual Amount -----
-------------------------------------
left join personbenoptioncostl anlfsa
  on anlfsa.personid = pbelfsa.personid
 and anlfsa.costsby = 'A'
 and anlfsa.personbeneelectionpid = pbelfsa.personbeneelectionpid         
----------------------------
----- (60) Medical FSA -----
----------------------------  
left join person_bene_election pbemfsa
  on pbemfsa.personid = pbe.personid
 and pbemfsa.benefitsubclass in ('60')
 and pbemfsa.selectedoption = 'Y'
 and case when ? = 'OE' then pbemfsa.benefitelection  = 'E' and pbemfsa.effectivedate >= date_trunc('year', current_date + interval '1 year') and pbemfsa.enddate >= '2199-12-30'
          when ? = 'FF' then pbemfsa.benefitelection <> 'W' and current_date between pbemfsa.effectivedate and pbemfsa.enddate end 
 and current_timestamp between pbemfsa.createts and pbemfsa.endts
-------------------------------------- 
----- Medical FSA Per Pay Amount -----
--------------------------------------
left join personbenoptioncostl ppmfsa
  on ppmfsa.personid = pbemfsa.personid
 and ppmfsa.costsby = 'P'
 and ppmfsa.personbeneelectionpid = pbemfsa.personbeneelectionpid    
-------------------------------------
----- Medical FSA Annual Amount -----
-------------------------------------
left join personbenoptioncostl anmfsa
  on anmfsa.personid = pbemfsa.personid
 and anmfsa.costsby = 'A'
 and anmfsa.personbeneelectionpid = pbemfsa.personbeneelectionpid  
-----------------------------------
----- (61) Dependent Care FSA -----
-----------------------------------
left join person_bene_election pbedfsa
  on pbedfsa.personid = pbe.personid
 and pbedfsa.benefitsubclass in ('61')
 and pbedfsa.selectedoption = 'Y'
 and case when ? = 'OE' then pbedfsa.benefitelection  = 'E' and pbedfsa.effectivedate >= date_trunc('year', current_date + interval '1 year') and pbedfsa.enddate >= '2199-12-30'
          when ? = 'FF' then pbedfsa.benefitelection <> 'W' and current_date between pbedfsa.effectivedate and pbedfsa.enddate end  
 and current_timestamp between pbedfsa.createts and pbedfsa.endts 
------------------------------------------------------
----- Dependent Care Per Pay Contribution Amount -----
------------------------------------------------------
left join personbenoptioncostl ppdfsa
  on ppdfsa.personid = pbedfsa.personid
 and ppdfsa.costsby = 'P'
 and ppdfsa.personbeneelectionpid = pbedfsa.personbeneelectionpid   
-----------------------------------------------------
----- Dependent Care Annual Contribution Amount -----
-----------------------------------------------------
left join personbenoptioncostl andfsa
  on andfsa.personid = pbedfsa.personid
 and andfsa.costsby = 'A'
 and andfsa.personbeneelectionpid = pbedfsa.personbeneelectionpid 
------------------------
----- (10) Medical -----
------------------------
left join person_bene_election pbemed
  on pbemed.personid = pbe.personid
 and pbemed.benefitsubclass in ('10')
 and pbemed.selectedoption = 'Y'
 and case when ? = 'OE' then pbemed.benefitelection  = 'E' and pbemed.effectivedate >= date_trunc('year', current_date + interval '1 year') and pbemed.enddate >= '2199-12-30'
          when ? = 'FF' then pbemed.benefitelection <> 'W' and current_date between pbemed.effectivedate and pbemed.enddate end   
 and current_timestamp between pbemed.createts and pbemed.endts  
-----------------------------------------------
----- Medical Per Pay Contribution Amount -----
-----------------------------------------------
left join personbenoptioncostl ppmed
  on ppmed.personid = pbemed.personid
 and ppmed.costsby = 'P'
 and ppmed.personbeneelectionpid = pbemed.personbeneelectionpid   
----------------------------------------------
----- Medical Annual Contribution Amount -----
----------------------------------------------
left join personbenoptioncostl anmed
  on anmed.personid = pbemed.personid
 and anmed.costsby = 'A'
 and anmed.personbeneelectionpid = pbemed.personbeneelectionpid  
-----------------------
----- (11) Dental -----
-----------------------
left join person_bene_election pbednt
  on pbednt.personid = pbe.personid   
 and pbednt.benefitsubclass in ('11')
 and pbednt.selectedoption = 'Y'
 and case when ? = 'OE' then pbednt.benefitelection  = 'E' and pbednt.effectivedate >= date_trunc('year', current_date + interval '1 year') and pbednt.enddate >= '2199-12-30'
          when ? = 'FF' then pbednt.benefitelection <> 'W' and current_date between pbednt.effectivedate and pbednt.enddate end    
 and current_timestamp between pbednt.createts and pbednt.endts   
----------------------------------------------
----- Dental Per Pay Contribution Amount -----
----------------------------------------------
left join personbenoptioncostl ppdnt
  on ppdnt.personid = pbednt.personid
 and ppdnt.costsby = 'P'
 and ppdnt.personbeneelectionpid = pbednt.personbeneelectionpid   
---------------------------------------------
----- Dental Annual Contribution Amount -----
---------------------------------------------
left join personbenoptioncostl andnt
  on andnt.personid = pbednt.personid
 and andnt.costsby = 'A'
 and andnt.personbeneelectionpid = pbednt.personbeneelectionpid   

left join pers_pos pp
  on pp.personid = pi.personid
 and current_date between pp.effectivedate and pp.enddate
 and current_timestamp between pp.createts and pp.endts

join position_desc pd
  on pd.positionid = pp.positionid
 and current_date between pd.effectivedate and pd.enddate
 and current_timestamp between pd.createts and pd.endts  

left join person_payroll ppy
  on ppy.personid = pi.personid
 and current_date between ppy.effectivedate and ppy.enddate
 and current_timestamp between ppy.createts and ppy.endts
  
left join pay_unit pu 
  on pu.payunitid = ppy.payunitid
 and current_date between ppy.effectivedate and ppy.enddate
 and current_timestamp between ppy.createts and ppy.endts  

where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts  
  -----------------------------------------------------------------------------------------------------------------------------------------
  ----- CASE statement controls OE vs FF (default) the where clause controls how the effective dates and election options are handled -----
  ----- NOTE - CASE STATEMENTS ARE INCLUDED IN BENEFIT SPECIFIC JOINS ABOVE                                                           -----
  ----- for 2019 OE only exclude HSA benefits - Lori sent a cognos report                                                             -----
  -----------------------------------------------------------------------------------------------------------------------------------------
  and case when ? = 'OE' and date_part('year',pbe.deductionstartdate) = '2019' then pbe.benefitsubclass in ('60','61','11','10') and pbe.benefitelection  = 'E' and pbe.effectivedate >= date_trunc('year', current_date + interval '1 year') and pbe.enddate >= '2199-12-30'
           when ? = 'OE' and date_part('year',pbe.deductionstartdate) > '2019' then pbe.benefitsubclass in ('6Z','60','61','11','10') and pbe.benefitelection  = 'E' and pbe.effectivedate >= date_trunc('year', current_date + interval '1 year') and pbe.enddate >= '2199-12-30'
           when ? = 'FF' and pbe.benefitsubclass in ('6Z','60','61','11','10') then pbe.benefitelection <> 'W' and current_date between pbe.effectivedate and pbe.enddate  
            end  
  ----- If EE is enrolled in FSA and HSA, include records for their Medical and Dental enrollments             
  and (pplfsa.employeerate <> 0 or ppmfsa.employeerate <> 0 or ppdfsa.employeerate <> 0 or ppdnt.employeerate <> 0 or ppmed.employeerate <> 0)
  and pbe.personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts and benefitsubclass in ('6Z','60','61') and selectedoption = 'Y' and benefitelection = 'E')
         