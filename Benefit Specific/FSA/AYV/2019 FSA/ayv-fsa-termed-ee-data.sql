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

left join edi.edi_last_update elu on elu.feedid = 'AYV_ProBenefits_FSA_DCA'

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
 and pbe.benefitsubclass in ('6Z','60','10','61','11')
 and pbe.selectedoption = 'Y'
 and pbe.benefitelection <> 'W'
 and pbe.effectivedate < pbe.enddate
 and current_timestamp between pbe.createts and pbe.endts
 and pbe.personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts 
                         and benefitsubclass in ('6Z','60','10','61','11') and benefitelection = 'E' and selectedoption = 'Y' and effectivedate < enddate)  

------------------------
----- (10) Medical -----
------------------------
left join (select personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, coverageamount, personbeneelectionpid,max(effectivedate) as effectivedate, max(enddate) as enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election where benefitsubclass = '10' and benefitelection = 'E' and selectedoption = 'Y' and current_timestamp between createts and endts --and personid = '10146'
            group by personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, coverageamount, personbeneelectionpid) pbemed on pbemed.personid = pbe.personid and pbemed.rank = 1         
-----------------------
----- (11) Dental -----
-----------------------
left join (select personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, coverageamount, personbeneelectionpid,max(effectivedate) as effectivedate, max(enddate) as enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election where benefitsubclass = '11' and benefitelection = 'E' and selectedoption = 'Y' and current_timestamp between createts and endts --and personid = '10146'
            group by personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, coverageamount, personbeneelectionpid) pbednt on pbednt.personid = pbe.personid and pbednt.rank = 1     
--------------------------------------- 
----- (6Z) Limited FSA (NEW 2019) -----
--------------------------------------- 
left join (select personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, coverageamount, personbeneelectionpid,max(effectivedate) as effectivedate, max(enddate) as enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election where benefitsubclass = '6Z' and benefitelection = 'E' and selectedoption = 'Y' and current_timestamp between createts and endts --and personid = '10146'
            group by personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, coverageamount, personbeneelectionpid) pbelfsa on pbelfsa.personid = pbe.personid and pbelfsa.rank = 1     
----------------------------
----- (60) Medical FSA -----
----------------------------  
left join (select personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, coverageamount, personbeneelectionpid,max(effectivedate) as effectivedate, max(enddate) as enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election where benefitsubclass = '60' and benefitelection = 'E' and selectedoption = 'Y' and current_timestamp between createts and endts --and personid = '10146'
            group by personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, coverageamount, personbeneelectionpid) pbemfsa on pbemfsa.personid = pbe.personid and pbemfsa.rank = 1    
-----------------------------------
----- (61) Dependent Care FSA -----
-----------------------------------
left join (select personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, coverageamount, personbeneelectionpid,max(effectivedate) as effectivedate, max(enddate) as enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election where benefitsubclass = '61' and benefitelection = 'E' and selectedoption = 'Y' and current_timestamp between createts and endts --and personid = '10146'
            group by personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, coverageamount, personbeneelectionpid) pbedfsa on pbedfsa.personid = pbe.personid and pbedfsa.rank = 1                          
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

left join  (select personid, positionid, scheduledhours, schedulefrequency, max(effectivedate) as effectivedate, RANK() OVER (PARTITION BY personid ORDER BY max(effectivedate) DESC) AS RANK
             from pers_pos where effectivedate < enddate and current_timestamp between createts and endts
            group by personid, positionid, scheduledhours, schedulefrequency) pp on pp.personid = pe.personid and pp.rank = 1
            
left join (select positionid, grade, positiontitle, flsacode, max(effectivedate) as effectivedate, RANK() OVER (PARTITION BY positionid ORDER BY max(effectivedate) DESC) AS RANK
             from position_desc where effectivedate < enddate and current_timestamp between createts and endts 
            group by positionid, grade, positiontitle, flsacode) pd on pd.positionid = pp.positionid and pd.rank = 1    

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
  and pe.emplstatus in ('R','T')
  and pe.personid = '7728'
 -- and (pe.effectivedate >= elu.lastupdatets::DATE 
 --  or (pe.createts > elu.lastupdatets and pe.effectivedate < coalesce(elu.lastupdatets, '2017-01-01')))
