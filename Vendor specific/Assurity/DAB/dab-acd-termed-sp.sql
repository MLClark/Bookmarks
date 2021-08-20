select distinct
 pi.personid
,bcdac.benefitcoveragedesc as accvgtier
,tier.cicvgtier
,bcdhi.benefitcoveragedesc as hicvgtier
,'1 TERMED SP' ::varchar(30) as qsource 
,2 AS SORTSEQ
,left(pi.identity,3)||'-'||substring(pi.identity,4,2)||'-'||right(pi.identity,4) ::char(11) as essn
,'SPOUSE' ::varchar(15) as relation
,pnd.fname ::varchar(30) as fname
,pnd.lname ::varchar(50) as lname
,pnd.mname ::char(1) as mname
,pvd.gendercode ::char(1) as gender
,to_char(pvd.birthdate,'mm/dd/yyyy')::char(10) as dob
,to_char(pe.empllasthiredate,'mm/dd/yyyy')::char(10) as doh

,case when substring(pip.identity,1,5) = 'DAB00' then '120000A460'
      when substring(pip.identity,1,5) in ('DAB05','DAB20','DAB25') then '120000C460'
      when substring(pip.identity,1,5) = 'DAB10' then '1200000460'
      when substring(pip.identity,1,5) = 'DAB15' then '120000B460'
      else '1200000460' end ::char(11) as group_id

,0 as hourspw   
,0 as annual_salary   

,case when pvd.smoker = 'S' then 'Y' else 'N' end ::char(1) as smoker_flag
,pa.streetaddress ::varchar(30) as addr1
,pa.streetaddress2 ::varchar(30) as addr2 
,pa.city ::varchar(30) as city
,pa.stateprovincecode ::char(2) as state
,pa.postalcode ::char(5) as zip
,ppcw.phoneno ::char(15) as workphone
,coalesce(pnc.url,pnch.url) ::varchar(100) AS email
,null as bene_rel
,null as bene_pct
,'Term' ::char(4) as status_chg      

,to_char(greatest(pbeac.enddate,pbecis.enddate,pbehi.enddate),'mm/dd/yyyy')::char(10) as edoc
,null as comp_state_question
----------------------------------------
----- accident (13)                -----
----------------------------------------
,case when pbeac.benefitsubclass = '13' then 'Accident' else null end ::varchar(30) as ae_plan_type
,case when pbeac.benefitsubclass = '13'  and bcdac.benefitcoveragedesc in ('EE','Employee Only','Employee') then 'EMPLOYEE'
      when pbeac.benefitsubclass = '13'  and bcdac.benefitcoveragedesc = 'Employee + Spouse' then 'EMPLOYEE + SPOUSE'
      when pbeac.benefitsubclass = '13'  and bcdac.benefitcoveragedesc = 'Family' then 'EMPLOYEE + FAMILY'
      when pbeac.benefitsubclass = '13'  and bcdac.benefitcoveragedesc = 'Employee + Children' then 'EMPLOYEE + CHILD(REN)'
      else null end ::varchar(30) as ae_insured_option
,case when pbeac.benefitsubclass = '13' then cast(pocac.employeerate::numeric as dec(18,2)) else null end as ae_prem_amt          
,case when pbeac.benefitsubclass = '13' then to_char(pbeac.effectivedate,'mm/dd/yyyy')else null end ::char(10) as ae_edoi -- issue date
,case when pbeac.benefitsubclass = '13' then to_char(pbeac.createts,'mm/dd/yyyy')else null end ::char(10) as ae_edos -- signed date Debbie said use createts 
,case when pbeac.benefitsubclass = '13' and pbeac.benefitelection = 'T' then to_char(pbeac.enddate,'mm/dd/yyyy')
      when pbeac.benefitsubclass = '13' and pe.emplstatus = 'T' then to_char(pbeac.enddate,'mm/dd/yyyy')
      else null end ::char(10) as ae_edot
---------------------------------------- 
,null as di_plan_type
,null as di_benefit_amt
,null as di_prem_amt
,null as di_edoi
,null as di_edos
,null as di_edot
----------------------------------------
----- critical illness ('1W','1S') -----
----------------------------------------
,case when pbecis.benefitsubclass = '1S' then 'Critical Illness' else null end ::varchar(30) as ci_plan_type
,case when pbecis.benefitsubclass = '1S' then tier.cicvgtier else null end ::varchar(30) as ci_insured_option 
,case when pbecis.benefitsubclass = '1S' then 5000.00 else null end as ci_bene_amt     
,case when pbecis.benefitsubclass = '1S' then cast(pocci.employeerate::numeric as dec(18,2)) else null end as ci_prem_amt      
,case when pbecis.benefitsubclass = '1S' then to_char(pbecis.effectivedate,'mm/dd/yyyy') else null end ::char(10) as ci_edoi -- issue date
,case when pbecis.benefitsubclass = '1S' then to_char(pbecis.createts,'mm/dd/yyyy') else null end ::char(10) as ci_edos -- signed date Debbie said use createts 
,case when pbecis.benefitsubclass = '1S'  and pbecis.benefitelection = 'T' then to_char(pbecis.enddate,'mm/dd/yyyy')
      when pbecis.benefitsubclass = '1S'  and pe.emplstatus = 'T' then to_char(pbecis.enddate,'mm/dd/yyyy') else null end ::char(10) as ci_edot
----------------------------------------
,null as ce_plan_type
,null as ce_benefit_amt
,null as ce_prem_amt
,null as ce_edoi
,null as ce_edos
,null as ce_edot
----------------------------------------
----- Hospital Indemnity ('1I')    -----
----------------------------------------
,case when pbehi.benefitsubclass = '1I' and pbehi.benefitplanid in ('125','128','131','137','140','146') then 'Hospital Indemnity - Low (A)'
      when pbehi.benefitsubclass = '1I' and pbehi.benefitplanid in ('149','155','158','161','164','167') then 'Hospital Indemnity - High (B)'
      else null end ::varchar(30) as hi_plan_type
,case when pbehi.benefitsubclass = '1I' and bcdhi.benefitcoveragedesc in ('EE','Employee Only') then 'EMPLOYEE'
      when pbehi.benefitsubclass = '1I' and bcdhi.benefitcoveragedesc = 'Employee + Spouse' then 'EMPLOYEE + SPOUSE'
      when pbehi.benefitsubclass = '1I' and bcdhi.benefitcoveragedesc = 'Family' then 'EMPLOYEE + FAMILY'
      when pbehi.benefitsubclass = '1I' and bcdhi.benefitcoveragedesc = 'Employee + Children' then 'EMPLOYEE + CHILD(REN)'
      else null end ::varchar(30) as hi_insured_option 
,null as hi_benefit_amt
,case when pbehi.benefitsubclass = '1I' then cast (pochi.employeerate::numeric as dec(18,2)) else null end as hi_prem_amt        
,case when pbehi.benefitsubclass = '1I' then to_char(pbehi.effectivedate,'mm/dd/yyyy')else null end ::char(10) as hi_edoi -- issue date
,case when pbehi.benefitsubclass = '1I' then to_char(pbehi.createts,'mm/dd/yyyy')else null end ::char(10) as hi_edos -- signed date Debbie said use createts 
,case when pbehi.benefitsubclass = '1I'and pbehi.benefitelection = 'T' then to_char(pbehi.enddate,'mm/dd/yyyy')
      when pbehi.benefitsubclass = '1I'and pe.emplstatus = 'T' then to_char(pbehi.enddate,'mm/dd/yyyy')
      else null end ::char(10) as hi_edot      
----------------------------------------
,null as lf_plan_type
,null as lf_cert_amt
,null as lf_insured_option
,null as lf_prem_amt
,null as lf_edoi
,null as lf_edos
----------------------------------------
,null as lti_rider
,null as lti_rider_amt
,null as sti_rider
,null as sti_rider_amt
,null as cti_rider
,null as cti_rider_amt
,null as lf_edot              

from person_identity pi

left join edi.edi_last_update elu on elu.feedid = 'DAB_Assurity_CI_HI_Accident_Export'

join person_identity pip
  on pip.personid = pi.personid
 and pip.identitytype = 'PSPID'
 and current_timestamp between pip.createts and pip.endts
 
join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts


left join person_address pa
  on pa.personid = pe.personid
 and pa.addresstype = 'Res'
 and current_date between pa.effectivedate and pa.enddate
 and current_timestamp between pa.createts and pa.endts 

left join person_net_contacts pnc 
  on pnc.personid = pi.personid 
 and pnc.netcontacttype = 'WRK'::bpchar 
 and current_date between pnc.effectivedate and pnc.enddate
 and current_timestamp between pnc.createts and pnc.enddate 

left join person_net_contacts pnch 
  on pnch.personid = pi.personid 
 and pnch.netcontacttype = 'HomeEmail'::bpchar 
 and current_date between pnch.effectivedate and pnch.enddate
 and current_timestamp between pnch.createts and pnch.enddate  

left join person_phone_contacts ppch 
  on ppch.personid = pi.personid
 and current_date between ppch.effectivedate and ppch.enddate
 and current_timestamp between ppch.createts and ppch.endts 
 and ppch.phonecontacttype = 'Home'
left join person_phone_contacts ppcw
  on ppcw.personid = pi.personid
 and current_date between ppcw.effectivedate and ppcw.enddate
 and current_timestamp between ppcw.createts and ppcw.endts  
 and ppcw.phonecontacttype = 'Work'   
left join person_phone_contacts ppcb
  on ppcb.personid = pi.personid
 and current_date between ppcb.effectivedate and ppcb.enddate
 and current_timestamp between ppcb.createts and ppcb.endts 
 and ppcb.phonecontacttype = 'BUSN'      
left join person_phone_contacts ppcm
  on ppcm.personid = pi.personid
 and current_date between ppcm.effectivedate and ppcm.enddate
 and current_timestamp between ppcm.createts and ppcm.endts 
 and ppcm.phonecontacttype = 'Mobile'           
    
JOIN person_bene_election pbe 
  on pbe.personid = pi.personid 
 and pbe.selectedoption = 'Y' 
 and pbe.benefitelection <> 'W'
 and pbe.benefitsubclass in ('1S','1I','13')
 AND pbe.effectivedate < pbe.enddate 
 and pbe.enddate < '2199-12-30' 
 AND current_timestamp between pbe.createts AND pbe.endts
  -- to be qualified for cobra the emp must have participated in employer's health care plan  
 and pbe.personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts 
                         and benefitsubclass in ('1S','1I','13') and benefitelection = 'E' and selectedoption = 'Y' and effectivedate < enddate) 

left join (SELECT personid,personbeneelectionpid,benefitcoverageid,benefitsubclass,createts,benefitelection,benefitplanid, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             FROM person_bene_election WHERE enddate > effectivedate AND current_timestamp BETWEEN createts AND endts and effectivedate < enddate 
              and benefitsubclass in ('13') and benefitelection <> 'W' and selectedoption = 'Y' and enddate < '2199-12-30'
            GROUP BY personid,personbeneelectionpid,benefitcoverageid,benefitsubclass,createts,benefitelection,benefitplanid ) as pbeac on pbeac.personid = pbe.personid and pbeac.rank = 1  
 
left join (SELECT personid,personbeneelectionpid,benefitcoverageid,benefitsubclass,createts,benefitelection,benefitplanid, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             FROM person_bene_election WHERE enddate > effectivedate AND current_timestamp BETWEEN createts AND endts and effectivedate < enddate 
              and benefitsubclass in ('1S') and benefitelection <> 'W' and selectedoption = 'Y' and enddate < '2199-12-30'
            GROUP BY personid,personbeneelectionpid,benefitcoverageid,benefitsubclass,createts,benefitelection,benefitplanid ) as pbecis on pbecis.personid = pbe.personid and pbecis.rank = 1   

left join (SELECT personid,personbeneelectionpid,benefitcoverageid,benefitsubclass,createts,benefitelection,benefitplanid, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             FROM person_bene_election WHERE enddate > effectivedate AND current_timestamp BETWEEN createts AND endts and effectivedate < enddate 
              and benefitsubclass in ('1I') and benefitelection <> 'W' and selectedoption = 'Y' and enddate < '2199-12-30'
            GROUP BY personid,personbeneelectionpid,benefitcoverageid,benefitsubclass,createts,benefitelection,benefitplanid ) as pbehi on pbehi.personid = pbe.personid and pbehi.rank = 1    
              

left join personbenoptioncostl pocac
  on pocac.personid = pbeac.personid
 and pocac.benefitelection = 'E'
 and pocac.personbeneelectionpid = pbeac.personbeneelectionpid
 and pocac.costsby = 'P'
left join personbenoptioncostl pocci
  on pocci.personid = pbecis.personid
 and pocci.benefitelection = 'E'
 and pocci.personbeneelectionpid = pbecis.personbeneelectionpid
 and pocci.costsby = 'P'
left join personbenoptioncostl pochi
  on pochi.personid = pbehi.personid
 and pochi.benefitelection = 'E'
 and pochi.personbeneelectionpid = pbehi.personbeneelectionpid
 and pochi.costsby = 'P' 

---- coverage tiers pertaining to the dependent needs to be on the dependent's record 
---- this join defaults a flags to N when a coverage does not apply to dep or spouse 
---- check how the flags are set to provide the correct coverage tier
left join 
(
select 
 ci.personid
,case when ci.e_benefitsubclass = '1W' and ci.s_benefitsubclass = '1S' and ci.c_benefitsubclass = '1C' then 'FAMILY'
      when ci.e_benefitsubclass = '1W' and ci.s_benefitsubclass = '1S' and ci.c_benefitsubclass = 'N'  then 'EMPLOYEE + SPOUSE'
      when ci.e_benefitsubclass = '1W' and ci.s_benefitsubclass = 'N'  and ci.c_benefitsubclass = '1C' then 'EMPLOYEE + CHILD(REN)'
      when ci.e_benefitsubclass = '1W' and ci.s_benefitsubclass = 'N'  and ci.c_benefitsubclass = 'N'  then 'EMPLOYEE'
      end cicvgtier

from 
(
 select distinct
  pbe.personid
 ,pbecie.benefitsubclass as e_benefitsubclass
 ,coalesce(pbecis.benefitsubclass,'N') as s_benefitsubclass
 ,coalesce(pbecic.benefitsubclass,'N') as c_benefitsubclass
  from person_bene_election pbe 
     
  join person_bene_election pbecie on pbecie.personid = pbe.personid 
     and current_timestamp between pbecie.createts and pbecie.endts and pbecie.effectivedate < pbecie.enddate
     and pbecie.benefitelection = 'E' and pbecie.selectedoption = 'Y' and pbecie.benefitsubclass in ('1W')
  left join person_bene_election pbecis on pbecis.personid = pbe.personid 
     and current_timestamp between pbecis.createts and pbecis.endts and pbecis.effectivedate < pbecis.enddate
     and pbecis.benefitelection = 'E' and pbecis.selectedoption = 'Y' and pbecis.benefitsubclass in ('1S')     
  left join person_bene_election pbecic on pbecic.personid = pbe.personid 
     and current_timestamp between pbecic.createts and pbecic.endts and pbecic.effectivedate < pbecic.enddate
     and pbecic.benefitelection = 'E' and pbecic.selectedoption = 'Y' and pbecic.benefitsubclass in ('1C') 
where current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate
  and pbe.benefitsubclass in ('1W','1S','1C') and pbe.benefitelection = 'E' and pbe.selectedoption = 'Y'           
) ci ) tier on tier.personid = pbe.personid
   


left join benefit_coverage_desc bcdac
  on bcdac.benefitcoverageid = pbeac.benefitcoverageid
 and current_date between bcdac.effectivedate and bcdac.enddate
 and current_timestamp between bcdac.createts and bcdac.endts  
 
left join benefit_coverage_desc bcdhi
  on bcdhi.benefitcoverageid = pbehi.benefitcoverageid
 and current_date between bcdhi.effectivedate and bcdhi.enddate
 and current_timestamp between bcdhi.createts and bcdhi.endts    
                       

----- dependent data

join person_dependent_relationship pdr
  on pdr.personid = pbe.personid
 and pdr.dependentrelationship in ('SP','DP','NA')
 and current_date between pdr.effectivedate and pdr.enddate
 and current_timestamp between pdr.createts and pdr.endts
 

left join person_identity piD
  on piD.personid = pdr.dependentid
 and piD.identitytype = 'SSN'
 and current_timestamp between piD.createts and piD.endts 

left join person_names pnd
  on pnD.personid = pdr.dependentid
 and current_date between pnD.effectivedate and pnD.enddate
 and current_timestamp between pnD.createts and pnD.endts
 and pnD.nametype = 'Dep' 

left join person_vitals pvd
  on pvd.personid = pdr.dependentid
 and current_date between pvd.effectivedate and pvd.enddate
 and current_timestamp between pvd.createts and pvd.endts 
                           
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  and pe.emplstatus in ('T','R')
  and (pe.effectivedate >= elu.lastupdatets::DATE 
   or (pe.createts > elu.lastupdatets and pe.effectivedate < coalesce(elu.lastupdatets, '2017-01-01')) ) 
  and ((bcdac.benefitcoveragedesc = 'Family' or bcdac.benefitcoveragedesc = 'Employee + Spouse')   
   or  (bcdhi.benefitcoveragedesc = 'Family' or bcdhi.benefitcoveragedesc = 'Employee + Spouse')
   or  (tier.cicvgtier = 'FAMILY' or tier.cicvgtier = 'EMPLOYEE + SPOUSE'))  
   