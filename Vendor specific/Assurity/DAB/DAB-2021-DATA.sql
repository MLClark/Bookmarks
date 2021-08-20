/*

-- waives with prior elected for 2020 plan year (2735,2767,3898)
-- Possible issues:
 3898 Homar Mendoza - waived emp CI, but not Child CI
 3899 Kim Hess - has emp+sp coverage for accident, but there is no dep record in dependent_enrollment
 3769 Timothy Johnston - Retired (CI&HI - waived with prior elected) and (current elected accident coverage) 

*/

---------------
-- ACTIVE EE --
---------------

select
 pi.personid
,coalesce(bcdac.benefitcoveragedesc, bcdacw.benefitcoveragedesc) as accvgtier
,tier.cicvgtier
,coalesce(bcdhi.benefitcoveragedesc, bcdhiw.benefitcoveragedesc) as hicvgtier

,'60 ACTIVE EE' ::varchar(30) as qsource 
,1 AS SORTSEQ
,left(pi.identity,3)||'-'||substring(pi.identity,4,2)||'-'||right(pi.identity,4) ::char(11) as essn
,'EMPLOYEE' ::varchar(15) as relation
,pn.fname ::varchar(30) as fname
,pn.lname ::varchar(50) as lname
,pn.mname ::char(1) as mname
,pv.gendercode ::char(1) as gender
,to_char(pv.birthdate,'mm/dd/yyyy')::char(10) as dob
,to_char(pe.empllasthiredate,'mm/dd/yyyy')::char(10) as doh
,case when substring(pip.identity,1,5) = 'DAB00' then '120000A460'
      when substring(pip.identity,1,5) in ('DAB05','DAB20','DAB25') then '120000C460'
      when substring(pip.identity,1,5) = 'DAB10' then '1200000460'
      when substring(pip.identity,1,5) = 'DAB15' then '120000B460'
      else '1200000460' end ::char(11) as group_id
,cast(pp.scheduledhours / 2 as dec (18,2)) as hourspw
,case when pc.frequencycode = 'H' then cast((pc.compamount * pp.scheduledhours) * 26 as dec(18,2)) else cast(pc.compamount as dec(18,2)) end as annual_salary
,case when pv.smoker = 'S' then 'Y' else 'N' end ::char(1) as smoker_flag
,pa.streetaddress ::varchar(30) as addr1
,pa.streetaddress2 ::varchar(30) as addr2 
,pa.city ::varchar(30) as city
,pa.stateprovincecode ::char(2) as state
,pa.postalcode ::char(5) as zip
,coalesce(ppcm.phoneno,ppch.phoneno,ppcw.phoneno) ::char(15) as workphone
,coalesce(pnc.url,pnch.url) ::varchar(100) AS email
,null as bene_rel
,null as bene_pct
,case when pe.effectivedate   >= elu.lastupdatets::date and (greatest(pbeac.effectivedate,pbecie.effectivedate,pbehi.effectivedate)) >= elu.lastupdatets then 'New Enrollment' 
      when pa.effectivedate   >= elu.lastupdatets::date and pe.effectivedate <= elu.lastupdatets::date then 'ADDRESS CHANGE'
      when pv.effectivedate   >= elu.lastupdatets::date and pe.effectivedate <= elu.lastupdatets::date then 'VITAL INFORMATION CHANGE'
      when pn.effectivedate   >= elu.lastupdatets::date and pe.effectivedate <= elu.lastupdatets::date then 'NAME CHANGE'
      when ppl.effectivedate  >= elu.lastupdatets::date and pe.effectivedate <= elu.lastupdatets::date then 'PAY UNIT CHANGE'
      when pc.effectivedate   >= elu.lastupdatets::date and pe.effectivedate <= elu.lastupdatets::date then 'COMPENSATION CHANGE'
      when pnc.effectivedate  >= elu.lastupdatets::date and pe.effectivedate <= elu.lastupdatets::date then 'WORK EMAIL CHANGE'
      when pnch.effectivedate >= elu.lastupdatets::date and pe.effectivedate <= elu.lastupdatets::date then 'HOME EMAIL CHANGE'
      when ppcm.effectivedate >= elu.lastupdatets::date and pe.effectivedate <= elu.lastupdatets::date then 'MOBILE PHONE CHANGE'
      when ppcb.effectivedate >= elu.lastupdatets::date and pe.effectivedate <= elu.lastupdatets::date then 'BUSINESS PHONE CHANGE'
      when ppcw.effectivedate >= elu.lastupdatets::date and pe.effectivedate <= elu.lastupdatets::date then 'WORK PHONE CHANGE'
      when ppch.effectivedate >= elu.lastupdatets::date and pe.effectivedate <= elu.lastupdatets::date then 'HOME PHONE CHANGE'
      else 'Coverage Change'  end ::varchar(50) as status_chg
,to_char(greatest(pbeac.effectivedate,pbecie.effectivedate,pbehi.effectivedate
                 ,ppl.effectivedate,pa.effectivedate,pn.effectivedate,pc.effectivedate,pe.effectivedate,pv.effectivedate
                 ,pnc.effectivedate,pnch.effectivedate
                 ,ppcm.effectivedate,ppcb.effectivedate,ppcw.effectivedate,ppch.effectivedate
                 ),'mm/dd/yyyy')::char(10) as edoc
,null as comp_state_question
----------------------------------------
----- accident (13)                -----
----------------------------------------
-- First case/argument is for active ee/dep with current elected coverage
-- Second case/argument is for active ee/dep with current waived coverage and prior elected coverage 
,case when pbeac.benefitelection = 'E' or (pbe13.benefitelection = 'W' and pbeacw.benefitelection = 'E') then 'Accident' else null end ::varchar(30) as ae_plan_type
,case when (pbeac.benefitelection = 'E' and bcdac.benefitcoveragedesc in ('EE','Employee Only','Employee')) 
	or (pbe13.benefitelection = 'W' and pbeacw.benefitelection = 'E' and bcdacw.benefitcoveragedesc in ('EE','Employee Only','Employee')) then 'EMPLOYEE'
      when (pbeac.benefitelection = 'E' and bcdac.benefitcoveragedesc in ('Employee + Spouse')) 
	or (pbe13.benefitelection = 'W' and pbeacw.benefitelection = 'E' and bcdacw.benefitcoveragedesc in ('Employee + Spouse')) then 'EMPLOYEE + SPOUSE'
      when (pbeac.benefitelection = 'E' and bcdac.benefitcoveragedesc in ('Family')) 
	or (pbe13.benefitelection = 'W' and pbeacw.benefitelection = 'E' and bcdacw.benefitcoveragedesc in ('Family')) then 'EMPLOYEE + FAMILY'
      when (pbeac.benefitelection = 'E' and bcdac.benefitcoveragedesc in ('Employee + Children')) 
	or (pbe13.benefitelection = 'W' and pbeacw.benefitelection = 'E' and bcdacw.benefitcoveragedesc in ('EE & Child','Employee + Children')) then 'EMPLOYEE + CHILD(REN)'
      else null end ::varchar(30) as ae_insured_option
,case when pbeac.benefitelection = 'E' then cast(pocac.employeerate::numeric as dec(18,2))
      when (pbe13.benefitelection = 'W' and pbeacw.benefitelection = 'E') then cast(pocacw.employeerate::numeric as dec(18,2)) else null end as ae_prem_amt    
,case when pbeac.benefitelection = 'E' then to_char(pbeac.effectivedate,'mm/dd/yyyy')
      when (pbe13.benefitelection = 'W' and pbeacw.benefitelection = 'E') then to_char(pbeacw.effectivedate,'mm/dd/yyyy') else null end ::char(10) as ae_edoi -- issue date
,case when pbeac.benefitelection = 'E' then to_char(pbeac.createts,'mm/dd/yyyy')
      when (pbe13.benefitelection = 'W' and pbeacw.benefitelection = 'E') then to_char(pbeacw.createts,'mm/dd/yyyy') else null end ::char(10) as ae_edos -- signed date Debbie said use createts 
,case when pbe13.benefitelection = 'W' and pbeacw.benefitelection = 'E' then to_char(pbeacw.enddate,'mm/dd/yyyy') else null end ::char(10) as ae_edot
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
-- First case/argument is for active ee/dep with current elected coverage
-- Second case/argument is for active ee/dep with current waived coverage and prior elected coverage 
,case when pbecie.benefitelection = 'E' or (pbe1W.benefitelection = 'W' and pbeciew.benefitelection = 'E') then 'Critical Illness' else null end ::varchar(30) as ci_plan_type
,case when pbecie.benefitelection = 'E' or (pbe1W.benefitelection = 'W' and pbeciew.benefitelection = 'E') then tier.cicvgtier else null end ::varchar(30) as ci_insured_option 
,case when pbecie.benefitelection = 'E' or (pbe1W.benefitelection = 'W' and pbeciew.benefitelection = 'E') then 10000.00 else null end as ci_bene_amt     
,case when pbecie.benefitelection = 'E' then cast(pocci.employeerate::numeric as dec(18,2))
      when (pbe1W.benefitelection = 'W' and pbeciew.benefitelection = 'E') then cast(pocciw.employeerate::numeric as dec(18,2)) else null end as ci_prem_amt      
,case when pbecie.benefitelection = 'E' then to_char(pbecie.effectivedate,'mm/dd/yyyy')
      when (pbe1W.benefitelection = 'W' and pbeciew.benefitelection = 'E') then to_char(pbeciew.effectivedate,'mm/dd/yyyy') else null end ::char(10) as ci_edoi -- issue date
,case when pbecie.benefitelection = 'E' then to_char(pbecie.createts,'mm/dd/yyyy')
      when (pbe1W.benefitelection = 'W' and pbeciew.benefitelection = 'E') then to_char(pbeciew.createts,'mm/dd/yyyy') else null end ::char(10) as ci_edos -- signed date Debbie said use createts 
,case when pbe1W.benefitelection = 'W' and pbeciew.benefitelection = 'E' then to_char(pbeciew.enddate,'mm/dd/yyyy') else null end ::char(10) as ci_edot
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
-- First case/argument is for active ee/dep with current elected coverage
-- Second case/argument is for active ee/dep with current waived coverage and prior elected coverage 
,case when (pbehi.benefitelection = 'E' and pbehi.benefitplanid in ('125','128','131','137','140','146')) then 'Hospital Indemnity - Low (A)'
      when (pbe1I.benefitelection = 'W' and pbehiw.benefitelection = 'E' and pbehiw.benefitplanid in ('125','128','131','137','140','146')) then 'Hospital Indemnity - Low (A)'
      when (pbehi.benefitelection = 'E' and pbehi.benefitplanid in ('149','155','158','161','164','167')) then 'Hospital Indemnity - High (B)'
      when (pbe1I.benefitelection = 'W' and pbehiw.benefitelection = 'E' and pbehiw.benefitplanid in ('149','155','158','161','164','167')) then 'Hospital Indemnity - High (B)'
      else null end ::varchar(30) as hi_plan_type
,case when (pbehi.benefitelection = 'E' and bcdhi.benefitcoveragedesc in ('EE','Employee Only','Employee'))
	or (pbe1I.benefitelection = 'W' and pbehiw.benefitelection = 'E' and bcdhiw.benefitcoveragedesc in ('EE','Employee Only')) then 'EMPLOYEE'
      when (pbehi.benefitelection = 'E' and bcdhi.benefitcoveragedesc = 'Employee + Spouse')
	or (pbe1I.benefitelection = 'W' and pbehiw.benefitelection = 'E' and bcdhiw.benefitcoveragedesc = 'Employee + Spouse') then 'EMPLOYEE + SPOUSE'
      when (pbehi.benefitelection = 'E' and bcdhi.benefitcoveragedesc = 'Family') 
	or (pbe1I.benefitelection = 'W' and pbehiw.benefitelection = 'E' and bcdhiw.benefitcoveragedesc = 'Family') then 'EMPLOYEE + FAMILY'
      when (pbehi.benefitelection = 'E' and bcdhi.benefitcoveragedesc in ('Employee + Children'))
	or (pbe1I.benefitelection = 'W' and pbehiw.benefitelection = 'E' and bcdhiw.benefitcoveragedesc in ('Employee + Children')) then 'EMPLOYEE + CHILD(REN)'
      else null end ::varchar(30) as hi_insured_option 
,null as hi_benefit_amt
,case when pbehi.benefitelection = 'E' then cast(pochi.employeerate::numeric as dec(18,2))
      when (pbe1I.benefitelection = 'W' and pbehiw.benefitelection = 'E') then cast(pochiw.employeerate::numeric as dec(18,2)) else null end as hi_prem_amt         
,case when pbehi.benefitelection = 'E' then to_char(pbehi.effectivedate,'mm/dd/yyyy')
      when (pbe1I.benefitelection = 'W' and pbehiw.benefitelection = 'E') then to_char(pbehiw.effectivedate,'mm/dd/yyyy') else null end ::char(10) as hi_edoi -- issue date
,case when pbehi.benefitelection = 'E' then to_char(pbehi.createts,'mm/dd/yyyy')
      when (pbe1I.benefitelection = 'W' and pbehiw.benefitelection = 'E') then to_char(pbehiw.createts,'mm/dd/yyyy') else null end ::char(10) as hi_edos -- signed date Debbie said use createts 
,case when pbe1I.benefitelection = 'W' and pbehiw.benefitelection = 'E' then to_char(pbehiw.enddate,'mm/dd/yyyy') else null end ::char(10) as hi_edot      
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
,elu.lastupdatets
from person_identity pi
left join edi.edi_last_update elu on elu.feedid = 'DAB_Assurity_CI_HI_Accident_Export'

left join person_identity pip
  on pip.personid = pi.personid
 and pip.identitytype = 'PSPID'
 and current_timestamp between pip.createts and pip.endts
 
left join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts
 
left join 
(select personid, benefitplanid,benefitelection,benefitcoverageid, max(createts) as createts,max(effectivedate) as effectivedate, max(enddate) as enddate, rank() over (partition by personid order by max(effectivedate) desc) as rank
 from person_bene_election pbe
 where benefitsubclass in ('1W','1S','1C','1I','13')
 and benefitelection in ('E','W')
 and selectedoption = 'Y'
 and effectivedate < enddate
 and current_timestamp between createts and endts
 group by 1,2,3,4) pbe on pbe.personid = pe.personid and pbe.rank = 1

-------------------------------------------------
-- Joins for Case Statements ---
-------------------------------------------------
-- Had to split out benefits to prevent dupes
left join 
(select personid, benefitplanid,benefitelection,benefitcoverageid, max(createts) as createts,max(effectivedate) as effectivedate, max(enddate) as enddate, rank() over (partition by personid order by max(effectivedate) desc) as rank
 from person_bene_election pbe
 where benefitsubclass in ('13')
 and benefitelection in ('E','W')
 and selectedoption = 'Y'
 and effectivedate < enddate
 and current_timestamp between createts and endts
 group by 1,2,3,4) pbe13 on pbe13.personid = pe.personid and pbe13.rank = 1

left join 
(select personid, benefitplanid,benefitelection,benefitcoverageid, max(createts) as createts,max(effectivedate) as effectivedate, max(enddate) as enddate, rank() over (partition by personid order by max(effectivedate) desc) as rank
 from person_bene_election pbe
 where benefitsubclass in ('1W')
 and benefitelection in ('E','W')
 and selectedoption = 'Y'
 and effectivedate < enddate
 and current_timestamp between createts and endts
 group by 1,2,3,4) pbe1W on pbe1W.personid = pe.personid and pbe1W.rank = 1

left join 
(select personid, benefitplanid,benefitelection,benefitcoverageid, max(createts) as createts,max(effectivedate) as effectivedate, max(enddate) as enddate, rank() over (partition by personid order by max(effectivedate) desc) as rank
 from person_bene_election pbe
 where benefitsubclass in ('1I')
 and benefitelection in ('E','W')
 and selectedoption = 'Y'
 and effectivedate < enddate
 and current_timestamp between createts and endts
 group by 1,2,3,4) pbe1I on pbe1I.personid = pe.personid and pbe1I.rank = 1

-----------------------------------------------------------------------------------------------------------------------------
-- Elected coverages for Active Employees
-----------------------------------------------------------------------------------------------------------------------------

left join 
(select personid, benefitplanid,benefitelection,benefitcoverageid,personbeneelectionpid, max(createts) as createts,max(effectivedate) as effectivedate, max(enddate) as enddate, rank() over (partition by personid order by max(effectivedate) desc) as rank
 from person_bene_election pbe
 where benefitsubclass in ('13')
 --and benefitelection in ('E')
 and selectedoption = 'Y'
 and effectivedate < enddate
 and current_timestamp between createts and endts
 group by 1,2,3,4,5) pbeac on pbeac.personid = pe.personid and pbeac.rank = 1

left join benefit_coverage_desc bcdac
  on bcdac.benefitcoverageid = pbeac.benefitcoverageid
 and current_date between bcdac.effectivedate and bcdac.enddate
 and current_timestamp between bcdac.createts and bcdac.endts  

left join 
(select personid, benefitplanid,benefitelection,benefitcoverageid,personbeneelectionpid, max(createts) as createts,max(effectivedate) as effectivedate, max(enddate) as enddate, rank() over (partition by personid order by max(effectivedate) desc) as rank
 from person_bene_election pbe
 where benefitsubclass in ('1W')
 --and benefitelection in ('E')
 and selectedoption = 'Y'
 and effectivedate < enddate
 and current_timestamp between createts and endts
 group by 1,2,3,4,5) pbecie on pbecie.personid = pe.personid and pbecie.rank = 1

left join benefit_coverage_desc bcdcie
  on bcdcie.benefitcoverageid = pbecie.benefitcoverageid
 and current_date between bcdcie.effectivedate and bcdcie.enddate
 and current_timestamp between bcdcie.createts and bcdcie.endts
  
left join 
(select personid, benefitplanid,benefitelection,benefitcoverageid,personbeneelectionpid, max(createts) as createts,max(effectivedate) as effectivedate, max(enddate) as enddate, rank() over (partition by personid order by max(effectivedate) desc) as rank
 from person_bene_election pbe
 where benefitsubclass in ('1I')
 --and benefitelection in ('E')
 and selectedoption = 'Y'
 and effectivedate < enddate
 and current_timestamp between createts and endts
 group by 1,2,3,4,5) pbehi on pbehi.personid = pe.personid and pbehi.rank = 1

left join benefit_coverage_desc bcdhi
  on bcdhi.benefitcoverageid = pbehi.benefitcoverageid
 and current_date between bcdhi.effectivedate and bcdhi.enddate
 and current_timestamp between bcdhi.createts and bcdhi.endts
------------------------------------------------------------------------------------------------------------------------
--Coverage for active employees with waived records and prior elected --
-----------------------------------------------------------------------------------------------------------------------------

-- Double ranked join to grab previous record
left join (select pbe.personid,pbe.benefitelection,pbe.benefitcoverageid,pbe.benefitplanid,pbe.benefitsubclass,pbe.compplanid,pbe.personbeneelectionpid,max(pbe.createts) as createts,max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate, rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
		from person_bene_election pbe
		left join person_employment pe on pe.personid = pbe.personid and current_date between pe.effectivedate and pe.enddate and current_timestamp between pe.createts and pe.endts
		left join (select pbe.personid,pbe.benefitelection,pbe.benefitcoverageid,max(pbe.createts) as createts,max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate, rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
				from person_bene_election pbe
				left join person_employment pe on pe.personid = pbe.personid and current_date between pe.effectivedate and pe.enddate and current_timestamp between pe.createts and pe.endts
				where pbe.benefitsubclass in ('13') and pbe.selectedoption = 'Y' 
					and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate
					group by 1,2,3 order by 1,7) pbeno on pbeno.personid = pbe.personid and pbeno.rank = 1
                 where pbe.benefitsubclass in ('13') and pbe.selectedoption = 'Y'
                        and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate and pbeno.effectivedate <> pbe.effectivedate
                         group by 1,2,3,4,5,6,7 order by 1,11) pbeacw on pbeacw.personid = pbe.personid and pbeacw.rank = 1

left join benefit_coverage_desc bcdacw
  on bcdacw.benefitcoverageid = pbeacw.benefitcoverageid
 and current_date between bcdacw.effectivedate and bcdacw.enddate
 and current_timestamp between bcdacw.createts and bcdacw.endts  

-- Double ranked join to grab previous record
left join (select pbe.personid,pbe.benefitelection,pbe.benefitcoverageid,pbe.benefitplanid,pbe.benefitsubclass,pbe.compplanid,pbe.personbeneelectionpid,max(pbe.createts) as createts,max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate, rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
		from person_bene_election pbe
		left join person_employment pe on pe.personid = pbe.personid and current_date between pe.effectivedate and pe.enddate and current_timestamp between pe.createts and pe.endts
		left join (select pbe.personid,pbe.benefitelection,pbe.benefitcoverageid,max(pbe.createts) as createts,max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate, rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
				from person_bene_election pbe
				left join person_employment pe on pe.personid = pbe.personid and current_date between pe.effectivedate and pe.enddate and current_timestamp between pe.createts and pe.endts
				where pbe.benefitsubclass in ('1W') and pbe.selectedoption = 'Y'
					and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate
					group by 1,2,3 order by 1,7) pbeno on pbeno.personid = pbe.personid and pbeno.rank = 1
                 where pbe.benefitsubclass in ('1W') and pbe.selectedoption = 'Y'
                        and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate and pbeno.effectivedate <> pbe.effectivedate
                         group by 1,2,3,4,5,6,7 order by 1,11) pbeciew on pbeciew.personid = pbe.personid and pbeciew.rank = 1

left join benefit_coverage_desc bcdciew
  on bcdciew.benefitcoverageid = pbeciew.benefitcoverageid
 and current_date between bcdciew.effectivedate and bcdciew.enddate
 and current_timestamp between bcdciew.createts and bcdciew.endts

-- Double ranked join to grab previous record
left join (select pbe.personid,pbe.benefitelection,pbe.benefitcoverageid,pbe.benefitplanid,pbe.benefitsubclass,pbe.compplanid,pbe.personbeneelectionpid,max(pbe.createts) as createts,max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate, rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
		from person_bene_election pbe
		left join person_employment pe on pe.personid = pbe.personid and current_date between pe.effectivedate and pe.enddate and current_timestamp between pe.createts and pe.endts
		left join (select pbe.personid,pbe.benefitelection,pbe.benefitcoverageid,max(pbe.createts) as createts,max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate, rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
				from person_bene_election pbe
				left join person_employment pe on pe.personid = pbe.personid and current_date between pe.effectivedate and pe.enddate and current_timestamp between pe.createts and pe.endts
				where pbe.benefitsubclass in ('1I') and pbe.selectedoption = 'Y'
					and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate
					group by 1,2,3 order by 1,7) pbeno on pbeno.personid = pbe.personid and pbeno.rank = 1
                 where pbe.benefitsubclass in ('1I') and pbe.selectedoption = 'Y'
                        and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate and pbeno.effectivedate <> pbe.effectivedate
                         group by 1,2,3,4,5,6,7 order by 1,11) pbehiw on pbehiw.personid = pbe.personid and pbehiw.rank = 1

left join benefit_coverage_desc bcdhiw
  on bcdhiw.benefitcoverageid = pbehiw.benefitcoverageid
 and current_date between bcdhiw.effectivedate and bcdhiw.enddate
 and current_timestamp between bcdhiw.createts and bcdhiw.endts   

-----------------------------------------------------------------------------------------------------------------------------

left join personbenoptioncostl pocac
  on pocac.personid = pbeac.personid
 and pocac.benefitelection = 'E'
 and pocac.personbeneelectionpid = pbeac.personbeneelectionpid
 and pocac.costsby = 'P'

left join personbenoptioncostl pocacw
  on pocacw.personid = pbeacw.personid
 and pocacw.benefitelection = 'E'
 and pocacw.personbeneelectionpid = pbeacw.personbeneelectionpid
 and pocacw.costsby = 'P'

left join personbenoptioncostl pocci
  on pocci.personid = pbecie.personid
 and pocci.benefitelection = 'E'
 and pocci.personbeneelectionpid = pbecie.personbeneelectionpid
 and pocci.costsby = 'P'

left join personbenoptioncostl pocciw
  on pocciw.personid = pbeciew.personid
 and pocciw.benefitelection = 'E'
 and pocciw.personbeneelectionpid = pbeciew.personbeneelectionpid
 and pocciw.costsby = 'P'

left join personbenoptioncostl pochi
  on pochi.personid = pbehi.personid
 and pochi.benefitelection = 'E'
 and pochi.personbeneelectionpid = pbehi.personbeneelectionpid
 and pochi.costsby = 'P' 

left join personbenoptioncostl pochiw
  on pochiw.personid = pbehiw.personid
 and pochiw.benefitelection = 'E'
 and pochiw.personbeneelectionpid = pbehiw.personbeneelectionpid
 and pochiw.costsby = 'P' 

---- coverage tiers pertaining to the dependent needs to be on the dependent's record 
---- this join defaults a flags to N when a coverage does not apply to dep or spouse 
---- check how the flags are set to provide the correct coverage tier used for CI plans only
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
 ,case when pbecie.benefitelection = 'E' then pbecie.benefitsubclass 
       when pbecie.benefitelection = 'W' and pbeciew.benefitelection = 'E' then pbeciew.benefitsubclass 
       else 'N' end as e_benefitsubclass
 ,case when pbecis.benefitelection = 'E' then coalesce(pbecis.benefitsubclass,'N')
       when pbecis.benefitelection = 'W' and pbecisw.benefitelection = 'E' then coalesce(pbecisw.benefitsubclass,'N') 
       else 'N' end as s_benefitsubclass
 ,case when pbecic.benefitelection = 'E' then coalesce(pbecic.benefitsubclass,'N') 
       when pbecic.benefitelection = 'W' and pbecicw.benefitelection = 'E' then coalesce(pbecicw.benefitsubclass,'N') 
       else 'N' end as c_benefitsubclass
  from person_bene_election pbe 
     
left join 
(select personid, benefitplanid,benefitelection,benefitsubclass,benefitcoverageid,personbeneelectionpid, max(createts) as createts,max(effectivedate) as effectivedate, max(enddate) as enddate, rank() over (partition by personid order by max(effectivedate) desc) as rank
 from person_bene_election pbe
 where benefitsubclass in ('1W')
 and selectedoption = 'Y'
 and effectivedate < enddate
 and current_timestamp between createts and endts
 group by 1,2,3,4,5,6) pbecie on pbecie.personid = pbe.personid and pbecie.rank = 1
left join 
(select personid, benefitplanid,benefitelection,benefitsubclass,benefitcoverageid,personbeneelectionpid, max(createts) as createts,max(effectivedate) as effectivedate, max(enddate) as enddate, rank() over (partition by personid order by max(effectivedate) desc) as rank
 from person_bene_election pbe
 where benefitsubclass in ('1S')
 and selectedoption = 'Y'
 and effectivedate < enddate
 and current_timestamp between createts and endts
 group by 1,2,3,4,5,6) pbecis on pbecis.personid = pbe.personid and pbecis.rank = 1
left join 
(select personid, benefitplanid,benefitelection,benefitsubclass,benefitcoverageid,personbeneelectionpid, max(createts) as createts,max(effectivedate) as effectivedate, max(enddate) as enddate, rank() over (partition by personid order by max(effectivedate) desc) as rank
 from person_bene_election pbe
 where benefitsubclass in ('1C')
 and selectedoption = 'Y'
 and effectivedate < enddate
 and current_timestamp between createts and endts
 group by 1,2,3,4,5,6) pbecic on pbecic.personid = pbe.personid and pbecic.rank = 1

-- Double ranked join to grab previous record
left join (select pbe.personid,pbe.benefitelection,pbe.benefitcoverageid,pbe.benefitplanid,pbe.benefitsubclass,pbe.compplanid,pbe.personbeneelectionpid,max(pbe.createts) as createts,max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate, rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
		from person_bene_election pbe
		left join person_employment pe on pe.personid = pbe.personid and current_date between pe.effectivedate and pe.enddate and current_timestamp between pe.createts and pe.endts
		left join (select pbe.personid,pbe.benefitelection,pbe.benefitcoverageid,max(pbe.createts) as createts,max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate, rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
				from person_bene_election pbe
				left join person_employment pe on pe.personid = pbe.personid and current_date between pe.effectivedate and pe.enddate and current_timestamp between pe.createts and pe.endts
				where pbe.benefitsubclass in ('1W') and pbe.selectedoption = 'Y'
					and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate
					group by 1,2,3 order by 1,7) pbeno on pbeno.personid = pbe.personid and pbeno.rank = 1
                 where pbe.benefitsubclass in ('1W') and pbe.selectedoption = 'Y'
                        and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate and pbeno.effectivedate <> pbe.effectivedate
                         group by 1,2,3,4,5,6,7 order by 1,11) pbeciew on pbeciew.personid = pbe.personid and pbeciew.rank = 1

-- Double ranked join to grab previous record
left join (select pbe.personid,pbe.benefitelection,pbe.benefitcoverageid,pbe.benefitplanid,pbe.benefitsubclass,pbe.compplanid,pbe.personbeneelectionpid,max(pbe.createts) as createts,max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate, rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
		from person_bene_election pbe
		left join person_employment pe on pe.personid = pbe.personid and current_date between pe.effectivedate and pe.enddate and current_timestamp between pe.createts and pe.endts
		left join (select pbe.personid,pbe.benefitelection,pbe.benefitcoverageid,max(pbe.createts) as createts,max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate, rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
				from person_bene_election pbe
				left join person_employment pe on pe.personid = pbe.personid and current_date between pe.effectivedate and pe.enddate and current_timestamp between pe.createts and pe.endts
				where pbe.benefitsubclass in ('1S') and pbe.selectedoption = 'Y'
					and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate
					group by 1,2,3 order by 1,7) pbeno on pbeno.personid = pbe.personid and pbeno.rank = 1
                 where pbe.benefitsubclass in ('1S') and pbe.selectedoption = 'Y'
                        and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate and pbeno.effectivedate <> pbe.effectivedate
                         group by 1,2,3,4,5,6,7 order by 1,11) pbecisw on pbecisw.personid = pbe.personid and pbecisw.rank = 1 

-- Double ranked join to grab previous record
left join (select pbe.personid,pbe.benefitelection,pbe.benefitcoverageid,pbe.benefitplanid,pbe.benefitsubclass,pbe.compplanid,pbe.personbeneelectionpid,max(pbe.createts) as createts,max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate, rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
		from person_bene_election pbe
		left join person_employment pe on pe.personid = pbe.personid and current_date between pe.effectivedate and pe.enddate and current_timestamp between pe.createts and pe.endts
		left join (select pbe.personid,pbe.benefitelection,pbe.benefitcoverageid,max(pbe.createts) as createts,max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate, rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
				from person_bene_election pbe
				left join person_employment pe on pe.personid = pbe.personid and current_date between pe.effectivedate and pe.enddate and current_timestamp between pe.createts and pe.endts
				where pbe.benefitsubclass in ('1C') and pbe.selectedoption = 'Y'
					and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate
					group by 1,2,3 order by 1,7) pbeno on pbeno.personid = pbe.personid and pbeno.rank = 1
                 where pbe.benefitsubclass in ('1C') and pbe.selectedoption = 'Y'
                        and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate and pbeno.effectivedate <> pbe.effectivedate
                         group by 1,2,3,4,5,6,7 order by 1,11) pbecicw on pbecicw.personid = pbe.personid and pbecicw.rank = 1

where current_date between pbe.effectivedate and pbe.enddate and current_timestamp between pbe.createts and pbe.endts
  and pbe.benefitsubclass in ('1W','1S','1C') and pbe.benefitelection in ('E','W')   
--pull all elected records or waived records with prior elected
  and (((pbecie.benefitelection = 'E') or (pbecie.benefitelection = 'W' and pbeciew.benefitelection = 'E'))
   or  ((pbecis.benefitelection = 'E') or (pbecis.benefitelection = 'W' and pbecisw.benefitelection = 'E'))
   or  ((pbecic.benefitelection = 'E') or (pbecic.benefitelection = 'W' and pbecicw.benefitelection = 'E')))     
) ci ) tier on tier.personid = pbe.personid

left join benefit_coverage_desc bcd
  on bcd.benefitcoverageid = pbe.benefitcoverageid
 and current_date between bcd.effectivedate and bcd.enddate
 and current_timestamp between bcd.createts and bcd.endts    
 
left join benefit_plan_desc bpdhi
  on bpdhi.benefitsubclass = pbehiw.benefitsubclass
 and current_date between bpdhi.effectivedate and bpdhi.enddate
 and current_timestamp between bpdhi.createts and bpdhi.endts    
 
join person_names pn
  on pn.personid = pe.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts 

left join person_vitals pv
  on pv.personid = pe.personid
 and current_date between pv.effectivedate and pv.enddate
 and current_timestamp between pv.createts and pv.endts 

left join pers_pos pp
  on pp.personid = pe.personid
 and current_date between pp.effectivedate and pp.enddate
 and current_timestamp between pp.createts and pp.endts 
  
left join person_compensation pc
  on pc.personid = pp.personid
 and current_date between pc.effectivedate and pc.enddate
 and current_timestamp between pc.createts and pc.endts
 and pc.earningscode <> 'BenBase'

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
   
left join person_payroll ppl 
  on ppl.personid = pe.personid 
 and current_date between ppl.effectivedate and ppl.enddate
 and current_timestamp between ppl.createts and ppl.endts
    
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  and pe.emplstatus not in ('T','R')

--pull all elected records or waived records with prior elected

and  ((pbe13.benefitelection = 'E' or (pbe13.benefitelection = 'W' and pbeacw.benefitelection = 'E'))
   or  (pbe1W.benefitelection = 'E' or (pbe1W.benefitelection = 'W' and pbeciew.benefitelection = 'E'))
   or  (pbe1I.benefitelection = 'E' or (pbe1I.benefitelection = 'W' and pbehiw.benefitelection = 'E')))


  and (
      (ppl.effectivedate >= elu.lastupdatets::DATE 
   or (ppl.createts > elu.lastupdatets and ppl.effectivedate < coalesce(elu.lastupdatets::date, '2017-01-01')) ) 

   or   
      ((pbe.effectivedate >= ?::DATE)
   or (pbe.createts >= elu.lastupdatets)  --- 1/21/2021 - ADDED createts to pick up coverage changes where only the createts changed and not effectivedate see Baptista personid '3486' coverage changes for 1C 
   or (pbe.createts > ?::DATE and pbe.effectivedate < coalesce(?::date, '2017-01-01')) )  
   --select * from person_bene_election where personid = '3486' and benefitsubclass = '1C' and createts > '2021-01-15';
   or
      (pn.effectivedate >= elu.lastupdatets::DATE 
   or (pn.createts > elu.lastupdatets and pn.effectivedate < coalesce(elu.lastupdatets::date, '2017-01-01')) ) 
   
   or
      (pa.effectivedate >= elu.lastupdatets::DATE 
   or (pa.createts > elu.lastupdatets and pa.effectivedate < coalesce(elu.lastupdatets::date, '2017-01-01')) ) 

   or
      (pc.effectivedate >= elu.lastupdatets::DATE 
   or (pc.createts > elu.lastupdatets and pc.effectivedate < coalesce(elu.lastupdatets::date, '2017-01-01')) ) 

   or
      (pe.effectivedate >= elu.lastupdatets::DATE 
   or (pe.createts > elu.lastupdatets and pe.effectivedate < coalesce(elu.lastupdatets::date, '2017-01-01')) ) 
      
   or
      (pp.effectivedate >= elu.lastupdatets::DATE 
   or (pp.createts > elu.lastupdatets and pp.effectivedate < coalesce(elu.lastupdatets::date, '2017-01-01')) ) 
      
   or
      (ppcm.effectivedate >= elu.lastupdatets::DATE 
   or (ppcm.createts > elu.lastupdatets and ppcm.effectivedate < coalesce(elu.lastupdatets::date, '2017-01-01')) ) 

   or
      (ppcb.effectivedate >= elu.lastupdatets::DATE 
   or (ppcb.createts > elu.lastupdatets and ppcb.effectivedate < coalesce(elu.lastupdatets::date, '2017-01-01')) ) 

   or
      (ppcw.effectivedate >= elu.lastupdatets::DATE 
   or (ppcw.createts > elu.lastupdatets and ppcw.effectivedate < coalesce(elu.lastupdatets::date, '2017-01-01')) ) 
         
   or
      (ppch.effectivedate >= elu.lastupdatets::DATE 
   or (ppch.createts > elu.lastupdatets and ppch.effectivedate < coalesce(elu.lastupdatets::date, '2017-01-01')) ) 
      
   or
      (pnc.effectivedate >= elu.lastupdatets::DATE 
   or (pnc.createts > elu.lastupdatets and pnc.effectivedate < coalesce(elu.lastupdatets::date, '2017-01-01')) ) 

   or
      (pnch.effectivedate >= elu.lastupdatets::DATE 
   or (pnch.createts > elu.lastupdatets and pnch.effectivedate < coalesce(elu.lastupdatets::date, '2017-01-01')) ) 
 
   or
      (pv.effectivedate >= elu.lastupdatets::DATE 
   or (pv.createts > elu.lastupdatets and pv.effectivedate < coalesce(elu.lastupdatets::date, '2017-01-01')) ) 
                    
      )



---------------------------------------------------------------------------------------------------------------------------------------------------       
   UNION
---------------------------------------------------------------------------------------------------------------------------------------------------

-------------------
-- ACTIVE SPOUSE --
-------------------

select
 pi.personid
,case when bcdac.benefitcoveragedesc in ('Employee + Spouse','Family') then bcdac.benefitcoveragedesc
      when bcdacw.benefitcoveragedesc in ('Employee + Spouse','Family') then bcdacw.benefitcoveragedesc else null end as accvgtier
,case when tier.cicvgtier in ('EMPLOYEE + SPOUSE','FAMILY') then tier.cicvgtier else null end 
,case when bcdhi.benefitcoveragedesc in ('Employee + Spouse','Family') then bcdhi.benefitcoveragedesc
      when bcdhiw.benefitcoveragedesc in ('Employee + Spouse','Family') and pbehi.benefitelection = 'E' then bcdhiw.benefitcoveragedesc else null end as hicvgtier
,'17 ACTIVE EE SP' ::varchar(30) as qsource 
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

,case when pe.effectivedate   >= elu.lastupdatets::date and (greatest(pbeac.effectivedate,pbecis.effectivedate,pbehi.effectivedate)) >= elu.lastupdatets then 'New Enrollment' 
      when pa.effectivedate   >= elu.lastupdatets::date and pe.effectivedate <= elu.lastupdatets::date then 'ADDRESS CHANGE'
      when pv.effectivedate   >= elu.lastupdatets::date and pe.effectivedate <= elu.lastupdatets::date then 'VITAL INFORMATION CHANGE'
      when pn.effectivedate   >= elu.lastupdatets::date and pe.effectivedate <= elu.lastupdatets::date then 'NAME CHANGE'
      when ppl.effectivedate  >= elu.lastupdatets::date and pe.effectivedate <= elu.lastupdatets::date then 'PAY UNIT CHANGE'
      when pc.effectivedate   >= elu.lastupdatets::date and pe.effectivedate <= elu.lastupdatets::date then 'COMPENSATION CHANGE'
      when pnc.effectivedate  >= elu.lastupdatets::date and pe.effectivedate <= elu.lastupdatets::date then 'WORK EMAIL CHANGE'
      when pnch.effectivedate >= elu.lastupdatets::date and pe.effectivedate <= elu.lastupdatets::date then 'HOME EMAIL CHANGE'
      when ppcm.effectivedate >= elu.lastupdatets::date and pe.effectivedate <= elu.lastupdatets::date then 'MOBILE PHONE CHANGE'
      when ppcb.effectivedate >= elu.lastupdatets::date and pe.effectivedate <= elu.lastupdatets::date then 'BUSINESS PHONE CHANGE'
      when ppcw.effectivedate >= elu.lastupdatets::date and pe.effectivedate <= elu.lastupdatets::date then 'WORK PHONE CHANGE'
      when ppch.effectivedate >= elu.lastupdatets::date and pe.effectivedate <= elu.lastupdatets::date then 'HOME PHONE CHANGE'
      else 'Coverage Change'  end ::varchar(50) as status_chg
,to_char(greatest(pbeac.effectivedate,pbecis.effectivedate,pbehi.effectivedate
                 ,pa.effectivedate,pnd.effectivedate,pvd.effectivedate
                 ),'mm/dd/yyyy')::char(10) as edoc

,null as comp_state_question
----------------------------------------
----- accident (13)                -----
----------------------------------------
-- First case/argument is for active ee/dep with current elected coverage
-- Second case/argument is for active ee/dep with current waived coverage and prior elected coverage 
,case when (deac.selectedoption = 'Y' and pbeac.benefitelection = 'E') or (deacw.selectedoption = 'Y' and pbe13.benefitelection = 'W' and pbeacw.benefitelection = 'E') then 'Accident' else null end ::varchar(30) as ae_plan_type
,case when (deac.selectedoption = 'Y' and pbeac.benefitelection = 'E' and bcdac.benefitcoveragedesc in ('EE','Employee Only','Employee'))
	or (deacw.selectedoption = 'Y' and pbe13.benefitelection = 'W' and pbeacw.benefitelection = 'E' and bcdacw.benefitcoveragedesc in ('EE','Employee Only','Employee')) then 'EMPLOYEE'
      when (deac.selectedoption = 'Y' and pbeac.benefitelection = 'E' and bcdac.benefitcoveragedesc in ('Employee + Spouse'))
	or (deacw.selectedoption = 'Y' and pbe13.benefitelection = 'W' and pbeacw.benefitelection = 'E' and bcdacw.benefitcoveragedesc in ('Employee + Spouse')) then 'EMPLOYEE + SPOUSE'
      when (deac.selectedoption = 'Y' and pbeac.benefitelection = 'E' and bcdac.benefitcoveragedesc in ('Family'))
	or (deacw.selectedoption = 'Y' and pbe13.benefitelection = 'W' and pbeacw.benefitelection = 'E' and bcdacw.benefitcoveragedesc in ('Family')) then 'EMPLOYEE + FAMILY'
      when (deac.selectedoption = 'Y' and pbeac.benefitelection = 'E' and bcdac.benefitcoveragedesc in ('Employee + Children'))
	or (deacw.selectedoption = 'Y' and pbe13.benefitelection = 'W' and pbeacw.benefitelection = 'E' and bcdacw.benefitcoveragedesc in ('Employee + Children')) then 'EMPLOYEE + CHILD(REN)'
      else null end ::varchar(30) as ae_insured_option
,case when (deac.selectedoption = 'Y' and pbeac.benefitelection = 'E') then cast(pocac.employeerate::numeric as dec(18,2))
      when (deacw.selectedoption = 'Y' and pbe13.benefitelection = 'W' and pbeacw.benefitelection = 'E') then cast(pocacw.employeerate::numeric as dec(18,2)) else null end as ae_prem_amt    
,case when (deac.selectedoption = 'Y' and pbeac.benefitelection = 'E') then to_char(pbeac.effectivedate,'mm/dd/yyyy')
      when (deacw.selectedoption = 'Y' and pbe13.benefitelection = 'W' and pbeacw.benefitelection = 'E') then to_char(pbeacw.effectivedate,'mm/dd/yyyy') else null end ::char(10) as ae_edoi -- issue date
,case when (deac.selectedoption = 'Y' and pbeac.benefitelection = 'E') then to_char(pbeac.createts,'mm/dd/yyyy')
      when (deacw.selectedoption = 'Y' and pbe13.benefitelection = 'W' and pbeacw.benefitelection = 'E') then to_char(pbeacw.createts,'mm/dd/yyyy') else null end ::char(10) as ae_edos -- signed date Debbie said use createts 
,case when (deacw.selectedoption = 'Y' and pbe13.benefitelection = 'W' and pbeacw.benefitelection = 'E') then to_char(pbeacw.enddate,'mm/dd/yyyy') else null end ::char(10) as ae_edot
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
-- First case/argument is for active ee/dep with current elected coverage
-- Second case/argument is for active ee/dep with current waived coverage and prior elected coverage 
,case when pbecis.benefitelection = 'E' or (pbe1S.benefitelection = 'W' and pbecisw.benefitelection = 'E') then 'Critical Illness' else null end ::varchar(30) as ci_plan_type
,case when pbecis.benefitelection = 'E' or (pbe1S.benefitelection = 'W' and pbecisw.benefitelection = 'E') then tier.cicvgtier else null end ::varchar(30) as ci_insured_option 
,case when pbecis.benefitelection = 'E' or (pbe1S.benefitelection = 'W' and pbecisw.benefitelection = 'E') then 5000.00 else null end as ci_bene_amt  ---- 1/4/2021 - CSD-40243 CI benefit amount should be 5,000 per dependent   
,case when pbecis.benefitelection = 'E' then cast(pocci.employeerate::numeric as dec(18,2))
      when (pbe1S.benefitelection = 'W' and pbecisw.benefitelection = 'E') then cast(pocciw.employeerate::numeric as dec(18,2)) else null end as ci_prem_amt      
,case when pbecis.benefitelection = 'E' then to_char(pbecis.effectivedate,'mm/dd/yyyy')
      when (pbe1S.benefitelection = 'W' and pbecisw.benefitelection = 'E') then to_char(pbecisw.effectivedate,'mm/dd/yyyy') else null end ::char(10) as ci_edoi -- issue date
,case when pbecis.benefitelection = 'E' then to_char(pbecis.createts,'mm/dd/yyyy')
      when (pbe1S.benefitelection = 'W' and pbecisw.benefitelection = 'E') then to_char(pbecisw.createts,'mm/dd/yyyy') else null end ::char(10) as ci_edos -- signed date Debbie said use createts  
,case when pbe1S.benefitelection = 'W' and pbecisw.benefitelection = 'E' then to_char(pbecisw.enddate,'mm/dd/yyyy') else null end ::char(10) as ci_edot
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
-- First case/argument is for active ee/dep with current elected coverage
-- Second case/argument is for active ee/dep with current waived coverage and prior elected coverage 
,case when (dehi.selectedoption = 'Y' and pbehi.benefitelection = 'E' and pbehi.benefitplanid in ('125','128','131','137','140','146')) 
	or (dehiw.selectedoption = 'Y' and pbe1I.benefitelection = 'W' and pbehiw.benefitelection = 'E' and pbehiw.benefitplanid in ('125','128','131','137','140','146')) then 'Hospital Indemnity - Low (A)'
      when (dehi.selectedoption = 'Y' and pbehi.benefitelection = 'E' and pbehi.benefitplanid in ('149','155','158','161','164','167'))
	or (dehiw.selectedoption = 'Y' and pbe1I.benefitelection = 'W' and pbehiw.benefitelection = 'E' and pbehiw.benefitplanid in ('149','155','158','161','164','167')) then 'Hospital Indemnity - High (B)'
      else null end ::varchar(30) as hi_plan_type
,case when (dehi.selectedoption = 'Y' and pbehi.benefitelection = 'E' and bcdhi.benefitcoveragedesc in ('EE','Employee Only')) 
	or (dehiw.selectedoption = 'Y' and pbe1I.benefitelection = 'W' and pbehiw.benefitelection = 'E' and bcdhiw.benefitcoveragedesc in ('EE','Employee Only')) then 'EMPLOYEE'
      when (dehi.selectedoption = 'Y' and pbehi.benefitelection = 'E' and bcdhi.benefitcoveragedesc = 'Employee + Spouse') 
	or (dehiw.selectedoption = 'Y' and pbe1I.benefitelection = 'W' and pbehiw.benefitelection = 'E' and bcdhiw.benefitcoveragedesc = 'Employee + Spouse') then 'EMPLOYEE + SPOUSE'
      when (dehi.selectedoption = 'Y' and pbehi.benefitelection = 'E' and bcdhi.benefitcoveragedesc = 'Family') 
	or (dehiw.selectedoption = 'Y' and pbe1I.benefitelection = 'W' and pbehiw.benefitelection = 'E' and bcdhiw.benefitcoveragedesc = 'Family') then 'EMPLOYEE + FAMILY'
      when (dehi.selectedoption = 'Y' and pbehi.benefitelection = 'E' and bcdhi.benefitcoveragedesc in ('Employee + Children'))
	or (dehiw.selectedoption = 'Y' and pbe1I.benefitelection = 'W' and pbehiw.benefitelection = 'E' and bcdhiw.benefitcoveragedesc in ('Employee + Children')) then 'EMPLOYEE + CHILD(REN)'
      else null end ::varchar(30) as hi_insured_option 
,null as hi_benefit_amt
,case when (dehi.selectedoption = 'Y' and pbehi.benefitelection = 'E') then cast(pochi.employeerate::numeric as dec(18,2))
      when (dehiw.selectedoption = 'Y' and pbe1I.benefitelection = 'W' and pbehiw.benefitelection = 'E') then cast(pochiw.employeerate::numeric as dec(18,2)) else null end as hi_prem_amt         
,case when (dehi.selectedoption = 'Y' and pbehi.benefitelection = 'E') then to_char(pbehi.effectivedate,'mm/dd/yyyy') 
      when (dehiw.selectedoption = 'Y' and pbe1I.benefitelection = 'W' and pbehiw.benefitelection = 'E') then to_char(pbehiw.effectivedate,'mm/dd/yyyy')else null end ::char(10) as hi_edoi -- issue date
,case when (dehi.selectedoption = 'Y' and pbehi.benefitelection = 'E') then to_char(pbehi.createts,'mm/dd/yyyy')
      when (dehiw.selectedoption = 'Y' and pbe1I.benefitelection = 'W' and pbehiw.benefitelection = 'E') then to_char(pbehiw.createts,'mm/dd/yyyy')else null end ::char(10) as hi_edos -- signed date Debbie said use createts 
,case when (dehiw.selectedoption = 'Y' and pbe1I.benefitelection = 'W' and pbehiw.benefitelection = 'E') then to_char(pbehiw.enddate,'mm/dd/yyyy') else null end ::char(10) as hi_edot      
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
,elu.lastupdatets
from person_identity pi

left join edi.edi_last_update elu on elu.feedid = 'DAB_Assurity_CI_HI_Accident_Export'

left join person_identity pip
  on pip.personid = pi.personid
 and pip.identitytype = 'PSPID'
 and current_timestamp between pip.createts and pip.endts
 
left join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts
 
left join 
(select personid, benefitplanid,benefitelection,benefitsubclass,benefitcoverageid, max(createts) as createts,max(effectivedate) as effectivedate, max(enddate) as enddate, rank() over (partition by personid order by max(effectivedate) desc) as rank
 from person_bene_election pbe
 where benefitsubclass in ('1S','1I','13','1C') --- 1/21/2021 added benefitsubclass 1C - to trigger sending spouse record if dep record changed and the coverage is FAMILY
 and benefitelection in ('E','W')
 and selectedoption = 'Y'
 and effectivedate < enddate
 and current_timestamp between createts and endts
 group by 1,2,3,4,5) pbe on pbe.personid = pe.personid and pbe.rank = 1
 
-------------------------------------------------
-- Joins for Case Statements ---
-------------------------------------------------
-- Had to split out benefits to prevent dupes
left join 
(select personid, benefitplanid,benefitelection,benefitcoverageid, max(createts) as createts,max(effectivedate) as effectivedate, max(enddate) as enddate, rank() over (partition by personid order by max(effectivedate) desc) as rank
 from person_bene_election pbe
 where benefitsubclass in ('13')
 and benefitelection in ('E','W')
 and selectedoption = 'Y'
 and effectivedate < enddate
 and current_timestamp between createts and endts
 group by 1,2,3,4) pbe13 on pbe13.personid = pe.personid and pbe13.rank = 1

left join 
(select personid, benefitplanid,benefitelection,benefitcoverageid, max(createts) as createts,max(effectivedate) as effectivedate, max(enddate) as enddate, rank() over (partition by personid order by max(effectivedate) desc) as rank
 from person_bene_election pbe
 where benefitsubclass in ('1S')
 and benefitelection in ('E','W')
 and selectedoption = 'Y'
 and effectivedate < enddate
 and current_timestamp between createts and endts
 group by 1,2,3,4) pbe1S on pbe1S.personid = pe.personid and pbe1S.rank = 1

left join 
(select personid, benefitplanid,benefitelection,benefitcoverageid, max(createts) as createts,max(effectivedate) as effectivedate, max(enddate) as enddate, rank() over (partition by personid order by max(effectivedate) desc) as rank
 from person_bene_election pbe
 where benefitsubclass in ('1I')
 and benefitelection in ('E','W')
 and selectedoption = 'Y'
 and effectivedate < enddate
 and current_timestamp between createts and endts
 group by 1,2,3,4) pbe1I on pbe1I.personid = pe.personid and pbe1I.rank = 1

-----------------------------------------------------------------------------------------------------------------------------
-- Elected coverages for Active Employees
-----------------------------------------------------------------------------------------------------------------------------

left join 
(select personid, benefitplanid,benefitelection,benefitsubclass,benefitcoverageid,personbeneelectionpid, max(createts) as createts,max(effectivedate) as effectivedate, max(enddate) as enddate, rank() over (partition by personid order by max(effectivedate) desc) as rank
 from person_bene_election pbe
 where benefitsubclass in ('13')
 --and benefitelection in ('E')
 and selectedoption = 'Y'
 and effectivedate < enddate
 and current_timestamp between createts and endts
 group by 1,2,3,4,5,6) pbeac on pbeac.personid = pe.personid and pbeac.rank = 1

left join benefit_coverage_desc bcdac
  on bcdac.benefitcoverageid = pbeac.benefitcoverageid
 and current_date between bcdac.effectivedate and bcdac.enddate
 and current_timestamp between bcdac.createts and bcdac.endts  

left join 
(select personid, benefitplanid,benefitelection,benefitsubclass,benefitcoverageid,personbeneelectionpid, max(createts) as createts,max(effectivedate) as effectivedate, max(enddate) as enddate, rank() over (partition by personid order by max(effectivedate) desc) as rank
 from person_bene_election pbe
 where benefitsubclass in ('1S')
 --and benefitelection in ('E')
 and selectedoption = 'Y'
 and effectivedate < enddate
 and current_timestamp between createts and endts
 group by 1,2,3,4,5,6) pbecis on pbecis.personid = pe.personid and pbecis.rank = 1

left join benefit_coverage_desc bcdcis
  on bcdcis.benefitcoverageid = pbecis.benefitcoverageid
 and current_date between bcdcis.effectivedate and bcdcis.enddate
 and current_timestamp between bcdcis.createts and bcdcis.endts
  
left join 
(select personid, benefitplanid,benefitelection,benefitsubclass,benefitcoverageid,personbeneelectionpid, max(createts) as createts,max(effectivedate) as effectivedate, max(enddate) as enddate, rank() over (partition by personid order by max(effectivedate) desc) as rank
 from person_bene_election pbe
 where benefitsubclass in ('1I')
 --and benefitelection in ('E')
 and selectedoption = 'Y'
 and effectivedate < enddate
 and current_timestamp between createts and endts
 group by 1,2,3,4,5,6) pbehi on pbehi.personid = pe.personid and pbehi.rank = 1

left join benefit_coverage_desc bcdhi
  on bcdhi.benefitcoverageid = pbehi.benefitcoverageid
 and current_date between bcdhi.effectivedate and bcdhi.enddate
 and current_timestamp between bcdhi.createts and bcdhi.endts

------------------------------------------------------------------------------------------------------------------------
--Coverage for active employees with waived records and prior elected --
-----------------------------------------------------------------------------------------------------------------------------

-- Double ranked join to grab previous record
left join (select pbe.personid,pbe.benefitelection,pbe.benefitcoverageid,pbe.benefitplanid,pbe.benefitsubclass,pbe.compplanid,pbe.personbeneelectionpid,max(pbe.createts) as createts,max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate, rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
		from person_bene_election pbe
		left join person_employment pe on pe.personid = pbe.personid and current_date between pe.effectivedate and pe.enddate and current_timestamp between pe.createts and pe.endts
		left join (select pbe.personid,pbe.benefitelection,pbe.benefitcoverageid,max(pbe.createts) as createts,max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate, rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
				from person_bene_election pbe
				left join person_employment pe on pe.personid = pbe.personid and current_date between pe.effectivedate and pe.enddate and current_timestamp between pe.createts and pe.endts
				where pbe.benefitsubclass in ('13') and pbe.selectedoption = 'Y' 
					and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate
					group by 1,2,3 order by 1,7) pbeno on pbeno.personid = pbe.personid and pbeno.rank = 1
                 where pbe.benefitsubclass in ('13') and pbe.selectedoption = 'Y' 
                        and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate and pbeno.effectivedate <> pbe.effectivedate
                         group by 1,2,3,4,5,6,7 order by 1,11) pbeacw on pbeacw.personid = pbe.personid and pbeacw.rank = 1

left join benefit_coverage_desc bcdacw
  on bcdacw.benefitcoverageid = pbeacw.benefitcoverageid
 and current_date between bcdacw.effectivedate and bcdacw.enddate
 and current_timestamp between bcdacw.createts and bcdacw.endts  

-- Double ranked join to grab previous record
left join (select pbe.personid,pbe.benefitelection,pbe.benefitcoverageid,pbe.benefitplanid,pbe.benefitsubclass,pbe.compplanid,pbe.personbeneelectionpid,max(pbe.createts) as createts,max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate, rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
		from person_bene_election pbe
		left join person_employment pe on pe.personid = pbe.personid and current_date between pe.effectivedate and pe.enddate and current_timestamp between pe.createts and pe.endts
		left join (select pbe.personid,pbe.benefitelection,pbe.benefitcoverageid,max(pbe.createts) as createts,max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate, rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
				from person_bene_election pbe
				left join person_employment pe on pe.personid = pbe.personid and current_date between pe.effectivedate and pe.enddate and current_timestamp between pe.createts and pe.endts
				where pbe.benefitsubclass in ('1S') and pbe.selectedoption = 'Y'
					and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate
					group by 1,2,3 order by 1,7) pbeno on pbeno.personid = pbe.personid and pbeno.rank = 1
                 where pbe.benefitsubclass in ('1S') and pbe.selectedoption = 'Y'
                        and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate and pbeno.effectivedate <> pbe.effectivedate
                         group by 1,2,3,4,5,6,7 order by 1,11) pbecisw on pbecisw.personid = pbe.personid and pbecisw.rank = 1

left join benefit_coverage_desc bcdcisw
  on bcdcisw.benefitcoverageid = pbecisw.benefitcoverageid
 and current_date between bcdcisw.effectivedate and bcdcisw.enddate
 and current_timestamp between bcdcisw.createts and bcdcisw.endts

-- Double ranked join to grab previous record
left join (select pbe.personid,pbe.benefitelection,pbe.benefitcoverageid,pbe.benefitplanid,pbe.benefitsubclass,pbe.compplanid,pbe.personbeneelectionpid,max(pbe.createts) as createts,max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate, rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
		from person_bene_election pbe
		left join person_employment pe on pe.personid = pbe.personid and current_date between pe.effectivedate and pe.enddate and current_timestamp between pe.createts and pe.endts
		left join (select pbe.personid,pbe.benefitelection,pbe.benefitcoverageid,max(pbe.createts) as createts,max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate, rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
				from person_bene_election pbe
				left join person_employment pe on pe.personid = pbe.personid and current_date between pe.effectivedate and pe.enddate and current_timestamp between pe.createts and pe.endts
				where pbe.benefitsubclass in ('1I') and pbe.selectedoption = 'Y' 
					and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate
					group by 1,2,3 order by 1,7) pbeno on pbeno.personid = pbe.personid and pbeno.rank = 1
                 where pbe.benefitsubclass in ('1I') and pbe.selectedoption = 'Y' 
                        and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate and pbeno.effectivedate <> pbe.effectivedate
                         group by 1,2,3,4,5,6,7 order by 1,11) pbehiw on pbehiw.personid = pbe.personid and pbehiw.rank = 1

left join benefit_coverage_desc bcdhiw
  on bcdhiw.benefitcoverageid = pbehiw.benefitcoverageid
 and current_date between bcdhiw.effectivedate and bcdhiw.enddate
 and current_timestamp between bcdhiw.createts and bcdhiw.endts   

-----------------------------------------------------------------------------------------------------------------------------
 
left join personbenoptioncostl pocac
  on pocac.personid = pbeac.personid
 and pocac.benefitelection = 'E'
 and pocac.personbeneelectionpid = pbeac.personbeneelectionpid
 and pocac.costsby = 'P'
left join personbenoptioncostl pocacw
  on pocacw.personid = pbeacw.personid
 and pocacw.benefitelection = 'E'
 and pocacw.personbeneelectionpid = pbeacw.personbeneelectionpid
 and pocacw.costsby = 'P'
left join personbenoptioncostl pocci
  on pocci.personid = pbecis.personid
 and pocci.benefitelection = 'E'
 and pocci.personbeneelectionpid = pbecis.personbeneelectionpid
 and pocci.costsby = 'P'
left join personbenoptioncostl pocciw
  on pocciw.personid = pbecisw.personid
 and pocciw.benefitelection = 'E'
 and pocciw.personbeneelectionpid = pbecisw.personbeneelectionpid
 and pocciw.costsby = 'P'
left join personbenoptioncostl pochi
  on pochi.personid = pbehi.personid
 and pochi.benefitelection = 'E'
 and pochi.personbeneelectionpid = pbehi.personbeneelectionpid
 and pochi.costsby = 'P' 
left join personbenoptioncostl pochiw
  on pochiw.personid = pbehiw.personid
 and pochiw.benefitelection = 'E'
 and pochiw.personbeneelectionpid = pbehiw.personbeneelectionpid
 and pochiw.costsby = 'P' 
 
---- coverage tiers pertaining to the dependent needs to be on the dependent's record 
---- this join defaults a flags to N when a coverage does not apply to dep or spouse 
---- check how the flags are set to provide the correct coverage tier used for CI plans only
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
 ,case when pbecie.benefitelection = 'E' then pbecie.benefitsubclass 
       when pbecie.benefitelection = 'W' and pbeciew.benefitelection = 'E' then pbeciew.benefitsubclass 
       else 'N' end as e_benefitsubclass
 ,case when pbecis.benefitelection = 'E' then coalesce(pbecis.benefitsubclass,'N')
       when pbecis.benefitelection = 'W' and pbecisw.benefitelection = 'E' then coalesce(pbecisw.benefitsubclass,'N') 
       else 'N' end as s_benefitsubclass
 ,case when pbecic.benefitelection = 'E' then coalesce(pbecic.benefitsubclass,'N') 
       when pbecic.benefitelection = 'W' and pbecicw.benefitelection = 'E' then coalesce(pbecicw.benefitsubclass,'N') 
       else 'N' end as c_benefitsubclass
  from person_bene_election pbe 
     
left join 
(select personid, benefitplanid,benefitelection,benefitsubclass,benefitcoverageid,personbeneelectionpid, max(createts) as createts,max(effectivedate) as effectivedate, max(enddate) as enddate, rank() over (partition by personid order by max(effectivedate) desc) as rank
 from person_bene_election pbe
 where benefitsubclass in ('1W')
 and selectedoption = 'Y'
 and effectivedate < enddate
 and current_timestamp between createts and endts
 group by 1,2,3,4,5,6) pbecie on pbecie.personid = pbe.personid and pbecie.rank = 1
left join 
(select personid, benefitplanid,benefitelection,benefitsubclass,benefitcoverageid,personbeneelectionpid, max(createts) as createts,max(effectivedate) as effectivedate, max(enddate) as enddate, rank() over (partition by personid order by max(effectivedate) desc) as rank
 from person_bene_election pbe
 where benefitsubclass in ('1S')
 and selectedoption = 'Y'
 and effectivedate < enddate
 and current_timestamp between createts and endts
 group by 1,2,3,4,5,6) pbecis on pbecis.personid = pbe.personid and pbecis.rank = 1
left join 
(select personid, benefitplanid,benefitelection,benefitsubclass,benefitcoverageid,personbeneelectionpid, max(createts) as createts,max(effectivedate) as effectivedate, max(enddate) as enddate, rank() over (partition by personid order by max(effectivedate) desc) as rank
 from person_bene_election pbe
 where benefitsubclass in ('1C')
 and selectedoption = 'Y'
 and effectivedate < enddate
 and current_timestamp between createts and endts
 group by 1,2,3,4,5,6) pbecic on pbecic.personid = pbe.personid and pbecic.rank = 1

-- Double ranked join to grab previous record
left join (select pbe.personid,pbe.benefitelection,pbe.benefitcoverageid,pbe.benefitplanid,pbe.benefitsubclass,pbe.compplanid,pbe.personbeneelectionpid,max(pbe.createts) as createts,max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate, rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
		from person_bene_election pbe
		left join person_employment pe on pe.personid = pbe.personid and current_date between pe.effectivedate and pe.enddate and current_timestamp between pe.createts and pe.endts
		left join (select pbe.personid,pbe.benefitelection,pbe.benefitcoverageid,max(pbe.createts) as createts,max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate, rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
				from person_bene_election pbe
				left join person_employment pe on pe.personid = pbe.personid and current_date between pe.effectivedate and pe.enddate and current_timestamp between pe.createts and pe.endts
				where pbe.benefitsubclass in ('1W') and pbe.selectedoption = 'Y' 
					and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate
					group by 1,2,3 order by 1,7) pbeno on pbeno.personid = pbe.personid and pbeno.rank = 1
                 where pbe.benefitsubclass in ('1W') and pbe.selectedoption = 'Y' 
                        and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate and pbeno.effectivedate <> pbe.effectivedate
                         group by 1,2,3,4,5,6,7 order by 1,11) pbeciew on pbeciew.personid = pbe.personid and pbeciew.rank = 1

-- Double ranked join to grab previous record
left join (select pbe.personid,pbe.benefitelection,pbe.benefitcoverageid,pbe.benefitplanid,pbe.benefitsubclass,pbe.compplanid,pbe.personbeneelectionpid,max(pbe.createts) as createts,max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate, rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
		from person_bene_election pbe
		left join person_employment pe on pe.personid = pbe.personid and current_date between pe.effectivedate and pe.enddate and current_timestamp between pe.createts and pe.endts
		left join (select pbe.personid,pbe.benefitelection,pbe.benefitcoverageid,max(pbe.createts) as createts,max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate, rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
				from person_bene_election pbe
				left join person_employment pe on pe.personid = pbe.personid and current_date between pe.effectivedate and pe.enddate and current_timestamp between pe.createts and pe.endts
				where pbe.benefitsubclass in ('1S') and pbe.selectedoption = 'Y' 
					and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate
					group by 1,2,3 order by 1,7) pbeno on pbeno.personid = pbe.personid and pbeno.rank = 1
                 where pbe.benefitsubclass in ('1S') and pbe.selectedoption = 'Y'
                        and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate and pbeno.effectivedate <> pbe.effectivedate
                         group by 1,2,3,4,5,6,7 order by 1,11) pbecisw on pbecisw.personid = pbe.personid and pbecisw.rank = 1 

-- Double ranked join to grab previous record
left join (select pbe.personid,pbe.benefitelection,pbe.benefitcoverageid,pbe.benefitplanid,pbe.benefitsubclass,pbe.compplanid,pbe.personbeneelectionpid,max(pbe.createts) as createts,max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate, rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
		from person_bene_election pbe
		left join person_employment pe on pe.personid = pbe.personid and current_date between pe.effectivedate and pe.enddate and current_timestamp between pe.createts and pe.endts
		left join (select pbe.personid,pbe.benefitelection,pbe.benefitcoverageid,max(pbe.createts) as createts,max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate, rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
				from person_bene_election pbe
				left join person_employment pe on pe.personid = pbe.personid and current_date between pe.effectivedate and pe.enddate and current_timestamp between pe.createts and pe.endts
				where pbe.benefitsubclass in ('1C') and pbe.selectedoption = 'Y' 
					and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate
					group by 1,2,3 order by 1,7) pbeno on pbeno.personid = pbe.personid and pbeno.rank = 1
                 where pbe.benefitsubclass in ('1C') and pbe.selectedoption = 'Y'
                        and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate and pbeno.effectivedate <> pbe.effectivedate
                         group by 1,2,3,4,5,6,7 order by 1,11) pbecicw on pbecicw.personid = pbe.personid and pbecicw.rank = 1

where current_date between pbe.effectivedate and pbe.enddate and current_timestamp between pbe.createts and pbe.endts
  and pbe.benefitsubclass in ('1W','1S','1C') and pbe.benefitelection in ('E','W')       
--pull all elected records or waived records with prior elected
  and (((pbecie.benefitelection = 'E') or (pbecie.benefitelection = 'W' and pbeciew.benefitelection = 'E'))
   or  ((pbecis.benefitelection = 'E') or (pbecis.benefitelection = 'W' and pbecisw.benefitelection = 'E'))
   or  ((pbecic.benefitelection = 'E') or (pbecic.benefitelection = 'W' and pbecicw.benefitelection = 'E')))      
) ci ) tier on tier.personid = pbe.personid  

left join person_names pn
  on pn.personid = pe.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts 

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

left join person_vitals pv
  on pv.personid = pe.personid
 and current_date between pv.effectivedate and pv.enddate
 and current_timestamp between pv.createts and pv.endts 
 
left join pers_pos pp
  on pp.personid = pe.personid
 and current_date between pp.effectivedate and pp.enddate
 and current_timestamp between pp.createts and pp.endts 
  
left join person_compensation pc
  on pc.personid = pp.personid
 and current_date between pc.effectivedate and pc.enddate
 and current_timestamp between pc.createts and pc.endts
 and pc.earningscode <> 'BenBase'
  
left join person_payroll ppl 
  on ppl.personid = pe.personid 
 and current_date between ppl.effectivedate and ppl.enddate
 and current_timestamp between ppl.createts and ppl.endts 
       

----- dependent data

left join 
(select personid,dependentrelationship,dependentid,max(createts) as createts,max(effectivedate) as effectivedate, max(enddate) as enddate, rank() over (partition by personid order by max(effectivedate) desc) as rank
 from person_dependent_relationship
 where dependentrelationship in ('SP','DP','NA')
 and effectivedate < enddate
 and current_timestamp between createts and endts
 group by 1,2,3) pdr on pdr.personid = pi.personid and pdr.rank = 1

-----------------------------------------------------------------------
-- Dependent Enrollment Joins --
-- Accident --
left join dependent_enrollment deac
  on deac.dependentid = pdr.dependentid
 and deac.personid = pdr.personid
 and deac.benefitsubclass = pbeac.benefitsubclass
 and deac.effectivedate < deac.enddate
 and current_timestamp between deac.createts and deac.endts 

left join dependent_enrollment deacw
  on deacw.dependentid = pdr.dependentid
 and deacw.benefitsubclass = pbeacw.benefitsubclass
 and deacw.personid = pi.personid
 and deacw.selectedoption = 'Y'
 and deacw.effectivedate < deacw.enddate
 and (?::DATE  <= deacw.enddate or (pbe13.effectivedate - interval '1 day' = deacw.enddate))
 --and elu.lastupdatets <= de13.enddate
 and current_timestamp between deacw.createts and deacw.endts  

-- High Indemnity --
left join dependent_enrollment dehi
  on dehi.dependentid = pdr.dependentid
 and dehi.personid = pdr.personid
 and dehi.benefitsubclass = pbehi.benefitsubclass
 and dehi.effectivedate < dehi.enddate
 and current_timestamp between dehi.createts and dehi.endts 

left join dependent_enrollment dehiw
  on dehiw.dependentid = pdr.dependentid
 and dehiw.benefitsubclass = pbehiw.benefitsubclass
 and dehiw.personid = pi.personid
 and dehiw.selectedoption = 'Y'
 and dehiw.effectivedate < dehiw.enddate
 and (?::DATE <= dehiw.enddate or (pbe1I.effectivedate - interval '1 day' = dehiw.enddate))
 --and elu.lastupdatets <= dehi.enddate
 and current_timestamp between dehiw.createts and dehiw.endts 

------------------------------------------------------------------------

left join person_identity piD
  on piD.personid = pdr.dependentid
 and piD.identitytype = 'SSN'
 and current_timestamp between piD.createts and piD.endts 
 
left join 
(select personid,fname,lname,mname,nametype,max(createts) as createts,max(effectivedate) as effectivedate, max(enddate) as enddate, rank() over (partition by personid order by max(effectivedate) desc) as rank 
from person_names
 where effectivedate < enddate
 and current_timestamp between createts and endts
 and nametype = 'Dep'
 group by 1,2,3,4,5) pnd on pnd.personid = pdr.dependentid and pnd.rank = 1

left join
(select personid,birthdate,gendercode,smoker,max(createts) as createts,max(effectivedate) as effectivedate, max(enddate) as enddate, rank() over (partition by personid order by max(effectivedate) desc) as rank 
  from person_vitals
 where effectivedate < enddate
 and current_timestamp between createts and endts
 group by 1,2,3,4) pvd on pvd.personid = pdr.dependentid and pvd.rank = 1
   
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  and pe.emplstatus not in ('T','R')

--pull all elected records or waived records with prior elected
  and ((pbeac.benefitsubclass = '13' or (pbe13.benefitelection = 'W' and pbeacw.benefitelection = 'E'))
   or  (pbecis.benefitsubclass = '1S' or (pbe1S.benefitelection = 'W' and pbecisw.benefitelection = 'E'))
   or  (pbehi.benefitsubclass = '1I' or (pbe1I.benefitelection = 'W' and pbehiw.benefitelection = 'E')))  

  and (
      (ppl.effectivedate >= elu.lastupdatets::DATE 
   or (ppl.createts > elu.lastupdatets and ppl.effectivedate < coalesce(elu.lastupdatets::date, '2017-01-01')) ) 
   
   or
      ((pbe.effectivedate >= ?::DATE)
   or (pbe.createts >= elu.lastupdatets)  --- 1/21/2021 - ADDED createts to pick up coverage changes where only the createts changed and not effectivedate see Baptista personid '3486' coverage changes for 1C 
   or (pbe.createts > ?::DATE and pbe.effectivedate < coalesce(?::date, '2017-01-01')) )  
   --select * from person_bene_election where personid = '3486' and benefitsubclass = '1C' and createts > '2021-01-15';
   
   or
      (pn.effectivedate >= elu.lastupdatets::DATE 
   or (pn.createts > elu.lastupdatets and pn.effectivedate < coalesce(elu.lastupdatets::date, '2017-01-01')) ) 

   or
      (pv.effectivedate >= elu.lastupdatets::DATE 
   or (pv.createts > elu.lastupdatets and pv.effectivedate < coalesce(elu.lastupdatets::date, '2017-01-01')) )   
   
   or
      (pa.effectivedate >= elu.lastupdatets::DATE 
   or (pa.createts > elu.lastupdatets and pa.effectivedate < coalesce(elu.lastupdatets::date, '2017-01-01')) ) 

   or
      (pc.effectivedate >= elu.lastupdatets::DATE 
   or (pc.createts > elu.lastupdatets and pc.effectivedate < coalesce(elu.lastupdatets::date, '2017-01-01')) ) 

   or
      (pe.effectivedate >= elu.lastupdatets::DATE 
   or (pe.createts > elu.lastupdatets and pe.effectivedate < coalesce(elu.lastupdatets::date, '2017-01-01')) ) 
      
   or
      (pp.effectivedate >= elu.lastupdatets::DATE 
   or (pp.createts > elu.lastupdatets and pp.effectivedate < coalesce(elu.lastupdatets::date, '2017-01-01')) ) 
      
   or
      (ppcm.effectivedate >= elu.lastupdatets::DATE 
   or (ppcm.createts > elu.lastupdatets and ppcm.effectivedate < coalesce(elu.lastupdatets::date, '2017-01-01')) ) 

   or
      (ppcb.effectivedate >= elu.lastupdatets::DATE 
   or (ppcb.createts > elu.lastupdatets and ppcb.effectivedate < coalesce(elu.lastupdatets::date, '2017-01-01')) ) 

   or
      (ppcw.effectivedate >= elu.lastupdatets::DATE 
   or (ppcw.createts > elu.lastupdatets and ppcw.effectivedate < coalesce(elu.lastupdatets::date, '2017-01-01')) ) 
         
   or
      (ppch.effectivedate >= elu.lastupdatets::DATE 
   or (ppch.createts > elu.lastupdatets and ppch.effectivedate < coalesce(elu.lastupdatets::date, '2017-01-01')) ) 
      
   or
      (pnc.effectivedate >= elu.lastupdatets::DATE 
   or (pnc.createts > elu.lastupdatets and pnc.effectivedate < coalesce(elu.lastupdatets::date, '2017-01-01')) ) 

   or
      (pnch.effectivedate >= elu.lastupdatets::DATE 
   or (pnch.createts > elu.lastupdatets and pnch.effectivedate < coalesce(elu.lastupdatets::date, '2017-01-01')) ) 
 
   or
      (pv.effectivedate >= elu.lastupdatets::DATE 
   or (pv.createts > elu.lastupdatets and pv.effectivedate < coalesce(elu.lastupdatets::date, '2017-01-01')) ) 
                    
      )
     

-- Ensures only enrolled (elected or waived with prior elected) dependent coverages are selected
  and (((bcdac.benefitcoveragedesc in ('Family', 'Employee + Spouse')) or (pbe13.benefitelection = 'W' and pbeacw.benefitelection = 'E' and bcdacw.benefitcoveragedesc in ('Family', 'Employee + Spouse')))
   or  ((bcdhi.benefitcoveragedesc in ('Family', 'Employee + Spouse')) or (pbe1I.benefitelection = 'W' and pbehiw.benefitelection = 'E' and bcdhiw.benefitcoveragedesc in ('Family', 'Employee + Spouse')))
   or  (tier.cicvgtier in ('FAMILY', 'EMPLOYEE + SPOUSE'))
   or  (pbe.benefitsubclass = '1C' and tier.cicvgtier = 'FAMILY')   ) --- 1/21/2021 added benefitsubclass 1C - to trigger sending spouse record if dep record changed and the coverage is FAMILY

---------------------------------------------------------------------------------------------------------------------------------------------------       
   UNION
---------------------------------------------------------------------------------------------------------------------------------------------------

--------------------
-- ACTIVE DEP --
--------------------

select

/*
For Critical Illness, you need to include the Spouse if they have Spouse Critical Illness plan 
and include all children under age 26 if they have Child Critical Illness Plan.  

For Critical Illness, they do not enroll dependents.

For Accident and Hospital Indemnity, include all enrolled dependents

*/
 pi.personid
 
,case when bcdac.benefitcoveragedesc in ('Employee + Children','Family') then bcdac.benefitcoveragedesc 
      when bcdacw.benefitcoveragedesc in ('Employee + Children','Family') then bcdacw.benefitcoveragedesc else null end as accvgtier
,case when tier.cicvgtier in ('EMPLOYEE + CHILD(REN)','FAMILY') then tier.cicvgtier else null end 
,case when bcdhi.benefitcoveragedesc in ('Employee + Children','Family') then bcdhi.benefitcoveragedesc
      when bcdhiw.benefitcoveragedesc in ('Employee + Children','Family') then bcdhiw.benefitcoveragedesc else null end as hicvgtier
,'22 ACTIVE EE DP' ::varchar(30) as qsource 
,3 AS SORTSEQ 
,left(pi.identity,3)||'-'||substring(pi.identity,4,2)||'-'||right(pi.identity,4) ::char(11) as essn
,'CHILD' ::varchar(15) as relation
,pnd.fname ::varchar(30) as fname
,pnd.lname ::varchar(50) as lname
,pnd.mname ::char(1) as mname
,pvd.gendercode ::char(1) as gender
--,to_char(current_date - (interval '26 years'),'mm/dd/yyyy')::char(10) as not_eligible_date
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

,case when pe.effectivedate   >= elu.lastupdatets::date and (greatest(pbeac.effectivedate,pbecic.effectivedate,pbehi.effectivedate)) >= elu.lastupdatets then 'New Enrollment' 
      when pa.effectivedate   >= elu.lastupdatets::date and pe.effectivedate <= elu.lastupdatets::date then 'ADDRESS CHANGE'
      when pv.effectivedate   >= elu.lastupdatets::date and pe.effectivedate <= elu.lastupdatets::date then 'VITAL INFORMATION CHANGE'
      when pn.effectivedate   >= elu.lastupdatets::date and pe.effectivedate <= elu.lastupdatets::date then 'NAME CHANGE'
      when ppl.effectivedate  >= elu.lastupdatets::date and pe.effectivedate <= elu.lastupdatets::date then 'PAY UNIT CHANGE'
      when pc.effectivedate   >= elu.lastupdatets::date and pe.effectivedate <= elu.lastupdatets::date then 'COMPENSATION CHANGE'
      when pnc.effectivedate  >= elu.lastupdatets::date and pe.effectivedate <= elu.lastupdatets::date then 'WORK EMAIL CHANGE'
      when pnch.effectivedate >= elu.lastupdatets::date and pe.effectivedate <= elu.lastupdatets::date then 'HOME EMAIL CHANGE'
      when ppcm.effectivedate >= elu.lastupdatets::date and pe.effectivedate <= elu.lastupdatets::date then 'MOBILE PHONE CHANGE'
      when ppcb.effectivedate >= elu.lastupdatets::date and pe.effectivedate <= elu.lastupdatets::date then 'BUSINESS PHONE CHANGE'
      when ppcw.effectivedate >= elu.lastupdatets::date and pe.effectivedate <= elu.lastupdatets::date then 'WORK PHONE CHANGE'
      when ppch.effectivedate >= elu.lastupdatets::date and pe.effectivedate <= elu.lastupdatets::date then 'HOME PHONE CHANGE'
      else 'Coverage Change'  end ::varchar(50) as status_chg
,to_char(greatest(pbeac.effectivedate,pbecic.effectivedate,pbehi.effectivedate
                 ,pa.effectivedate,pnd.effectivedate,pvd.effectivedate
                 ),'mm/dd/yyyy')::char(10) as edoc

,null as comp_state_question
----------------------------------------
----- accident (13)                -----
----------------------------------------
-- First case/argument is for active ee/dep with current elected coverage
-- Second case/argument is for active ee/dep with current waived coverage and prior elected coverage 
,case when (deac.selectedoption = 'Y' and pbeac.benefitelection = 'E') or (deacw.selectedoption = 'Y' and pbe13.benefitelection = 'W' and pbeacw.benefitelection = 'E') then 'Accident' else null end ::varchar(30) as ae_plan_type
,case when (deac.selectedoption = 'Y' and pbeac.benefitelection = 'E' and bcdac.benefitcoveragedesc in ('EE','Employee Only','Employee'))
	or (deacw.selectedoption = 'Y' and pbe13.benefitelection = 'W' and pbeacw.benefitelection = 'E' and bcdacw.benefitcoveragedesc in ('EE','Employee Only','Employee')) then 'EMPLOYEE'
      when (deac.selectedoption = 'Y' and pbeac.benefitelection = 'E' and bcdac.benefitcoveragedesc in ('Employee + Spouse'))
	or (deacw.selectedoption = 'Y' and pbe13.benefitelection = 'W' and pbeacw.benefitelection = 'E' and bcdacw.benefitcoveragedesc in ('Employee + Spouse')) then 'EMPLOYEE + SPOUSE'
      when (deac.selectedoption = 'Y' and pbeac.benefitelection = 'E' and bcdac.benefitcoveragedesc in ('Family'))
	or (deacw.selectedoption = 'Y' and pbe13.benefitelection = 'W' and pbeacw.benefitelection = 'E' and bcdacw.benefitcoveragedesc in ('Family')) then 'EMPLOYEE + FAMILY'
      when (deac.selectedoption = 'Y' and pbeac.benefitelection = 'E' and bcdac.benefitcoveragedesc in ('Employee + Children'))
	or (deacw.selectedoption = 'Y' and pbe13.benefitelection = 'W' and pbeacw.benefitelection = 'E' and bcdacw.benefitcoveragedesc in ('Employee + Children')) then 'EMPLOYEE + CHILD(REN)'
      else null end ::varchar(30) as ae_insured_option
,case when (deac.selectedoption = 'Y' and pbeac.benefitelection = 'E') then cast(pocac.employeerate::numeric as dec(18,2))
      when (deacw.selectedoption = 'Y' and pbe13.benefitelection = 'W' and pbeacw.benefitelection = 'E') then cast(pocacw.employeerate::numeric as dec(18,2)) else null end as ae_prem_amt    
,case when (deac.selectedoption = 'Y' and pbeac.benefitelection = 'E') then to_char(pbeac.effectivedate,'mm/dd/yyyy')
      when (deacw.selectedoption = 'Y' and pbe13.benefitelection = 'W' and pbeacw.benefitelection = 'E') then to_char(pbeacw.effectivedate,'mm/dd/yyyy') else null end ::char(10) as ae_edoi -- issue date
,case when (deac.selectedoption = 'Y' and pbeac.benefitelection = 'E') then to_char(pbeac.createts,'mm/dd/yyyy')
      when (deacw.selectedoption = 'Y' and pbe13.benefitelection = 'W' and pbeacw.benefitelection = 'E') then to_char(pbeacw.createts,'mm/dd/yyyy') else null end ::char(10) as ae_edos -- signed date Debbie said use createts 
,case when (deacw.selectedoption = 'Y' and pbe13.benefitelection = 'W' and pbeacw.benefitelection = 'E') then to_char(pbeacw.enddate,'mm/dd/yyyy') else null end ::char(10) as ae_edot
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
-- First case/argument is for active ee/dep with current elected coverage
-- Second case/argument is for active ee/dep with current waived coverage and prior elected coverage 
,case when pbecic.benefitelection = 'E' or (pbe1C.benefitelection = 'W' and pbecicw.benefitelection = 'E') then 'Critical Illness' else null end ::varchar(30) as ci_plan_type
,case when pbecic.benefitelection = 'E' or (pbe1C.benefitelection = 'W' and pbecicw.benefitelection = 'E') then tier.cicvgtier else null end ::varchar(30) as ci_insured_option 
,case when pbecic.benefitelection = 'E' or (pbe1C.benefitelection = 'W' and pbecicw.benefitelection = 'E') then 5000.00 else null end as ci_bene_amt  ---- 1/4/2021 - CSD-40243 CI benefit amount should be 5,000 per dependent     
,case when pbecic.benefitelection = 'E' then cast(pocci.employeerate::numeric as dec(18,2))
      when (pbe1C.benefitelection = 'W' and pbecicw.benefitelection = 'E') then cast(pocciw.employeerate::numeric as dec(18,2)) else null end as ci_prem_amt      
,case when pbecic.benefitelection = 'E' then to_char(pbecic.effectivedate,'mm/dd/yyyy')
      when (pbe1C.benefitelection = 'W' and pbecicw.benefitelection = 'E') then to_char(pbecicw.effectivedate,'mm/dd/yyyy') else null end ::char(10) as ci_edoi -- issue date
,case when pbecic.benefitelection = 'E' then to_char(pbecic.createts,'mm/dd/yyyy')
      when (pbe1C.benefitelection = 'W' and pbecicw.benefitelection = 'E') then to_char(pbecicw.createts,'mm/dd/yyyy') else null end ::char(10) as ci_edos -- signed date Debbie said use createts 
,case when pbe1C.benefitelection = 'W' and pbecicw.benefitelection = 'E' then to_char(pbecicw.enddate,'mm/dd/yyyy') else null end ::char(10) as ci_edot
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
-- First case/argument is for active ee/dep with current elected coverage
-- Second case/argument is for active ee/dep with current waived coverage and prior elected coverage 
,case when (dehi.selectedoption = 'Y' and pbehi.benefitelection = 'E' and pbehi.benefitplanid in ('125','128','131','137','140','146')) 
	or (dehiw.selectedoption = 'Y' and pbe1I.benefitelection = 'W' and pbehiw.benefitelection = 'E' and pbehiw.benefitplanid in ('125','128','131','137','140','146')) then 'Hospital Indemnity - Low (A)'
      when (dehi.selectedoption = 'Y' and pbehi.benefitelection = 'E' and pbehi.benefitplanid in ('149','155','158','161','164','167'))
	or (dehiw.selectedoption = 'Y' and pbe1I.benefitelection = 'W' and pbehiw.benefitelection = 'E' and pbehiw.benefitplanid in ('149','155','158','161','164','167')) then 'Hospital Indemnity - High (B)'
      else null end ::varchar(30) as hi_plan_type
,case when (dehi.selectedoption = 'Y' and pbehi.benefitelection = 'E' and bcdhi.benefitcoveragedesc in ('EE','Employee Only')) 
	or (dehiw.selectedoption = 'Y' and pbe1I.benefitelection = 'W' and pbehiw.benefitelection = 'E' and bcdhiw.benefitcoveragedesc in ('EE','Employee Only')) then 'EMPLOYEE'
      when (dehi.selectedoption = 'Y' and pbehi.benefitelection = 'E' and bcdhi.benefitcoveragedesc = 'Employee + Spouse') 
	or (dehiw.selectedoption = 'Y' and pbe1I.benefitelection = 'W' and pbehiw.benefitelection = 'E' and bcdhiw.benefitcoveragedesc = 'Employee + Spouse') then 'EMPLOYEE + SPOUSE'
      when (dehi.selectedoption = 'Y' and pbehi.benefitelection = 'E' and bcdhi.benefitcoveragedesc = 'Family') 
	or (dehiw.selectedoption = 'Y' and pbe1I.benefitelection = 'W' and pbehiw.benefitelection = 'E' and bcdhiw.benefitcoveragedesc = 'Family') then 'EMPLOYEE + FAMILY'
      when (dehi.selectedoption = 'Y' and pbehi.benefitelection = 'E' and bcdhi.benefitcoveragedesc in ('Employee + Children'))
	or (dehiw.selectedoption = 'Y' and pbe1I.benefitelection = 'W' and pbehiw.benefitelection = 'E' and bcdhiw.benefitcoveragedesc in ('Employee + Children')) then 'EMPLOYEE + CHILD(REN)'
      else null end ::varchar(30) as hi_insured_option 
,null as hi_benefit_amt
,case when (dehi.selectedoption = 'Y' and pbehi.benefitelection = 'E') then cast(pochi.employeerate::numeric as dec(18,2))
      when (dehiw.selectedoption = 'Y' and pbe1I.benefitelection = 'W' and pbehiw.benefitelection = 'E') then cast(pochiw.employeerate::numeric as dec(18,2)) else null end as hi_prem_amt         
,case when (dehi.selectedoption = 'Y' and pbehi.benefitelection = 'E') then to_char(pbehi.effectivedate,'mm/dd/yyyy') 
      when (dehiw.selectedoption = 'Y' and pbe1I.benefitelection = 'W' and pbehiw.benefitelection = 'E') then to_char(pbehiw.effectivedate,'mm/dd/yyyy')else null end ::char(10) as hi_edoi -- issue date
,case when (dehi.selectedoption = 'Y' and pbehi.benefitelection = 'E') then to_char(pbehi.createts,'mm/dd/yyyy')
      when (dehiw.selectedoption = 'Y' and pbe1I.benefitelection = 'W' and pbehiw.benefitelection = 'E') then to_char(pbehiw.createts,'mm/dd/yyyy')else null end ::char(10) as hi_edos -- signed date Debbie said use createts 
,case when (dehiw.selectedoption = 'Y' and pbe1I.benefitelection = 'W' and pbehiw.benefitelection = 'E') then to_char(pbehiw.enddate,'mm/dd/yyyy') else null end ::char(10) as hi_edot      
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
,elu.lastupdatets
from person_identity pi

left join edi.edi_last_update elu on elu.feedid = 'DAB_Assurity_CI_HI_Accident_Export'

left join person_identity pip
  on pip.personid = pi.personid
 and pip.identitytype = 'PSPID'
 and current_timestamp between pip.createts and pip.endts
 
left join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts
 
left join 
(select personid, benefitplanid,benefitelection,benefitsubclass,benefitcoverageid, max(createts) as createts,max(effectivedate) as effectivedate, max(enddate) as enddate, rank() over (partition by personid order by max(effectivedate) desc) as rank
 from person_bene_election pbe
 where benefitsubclass in ('1C','1I','13','1S') --- 1/21/2021 added benefitsubclass 1S - to trigger sending dep record if spouse record changed and the coverage is FAMILY
 and benefitelection in ('E','W')
 and selectedoption = 'Y'
 and effectivedate < enddate
 and current_timestamp between createts and endts
 group by 1,2,3,4,5) pbe on pbe.personid = pe.personid and pbe.rank = 1

-------------------------------------------------
-- Joins for Case Statements ---
-------------------------------------------------
-- Had to split out benefits to prevent dupes
left join 
(select personid, benefitplanid,benefitelection,benefitcoverageid, max(createts) as createts,max(effectivedate) as effectivedate, max(enddate) as enddate, rank() over (partition by personid order by max(effectivedate) desc) as rank
 from person_bene_election pbe
 where benefitsubclass in ('13')
 and benefitelection in ('E','W')
 and selectedoption = 'Y'
 and effectivedate < enddate
 and current_timestamp between createts and endts
 group by 1,2,3,4) pbe13 on pbe13.personid = pe.personid and pbe13.rank = 1

left join 
(select personid, benefitplanid,benefitelection,benefitcoverageid, max(createts) as createts,max(effectivedate) as effectivedate, max(enddate) as enddate, rank() over (partition by personid order by max(effectivedate) desc) as rank
 from person_bene_election pbe
 where benefitsubclass in ('1C')
 and benefitelection in ('E','W')
 and selectedoption = 'Y'
 and effectivedate < enddate
 and current_timestamp between createts and endts
 group by 1,2,3,4) pbe1C on pbe1C.personid = pe.personid and pbe1C.rank = 1

left join 
(select personid, benefitplanid,benefitelection,benefitcoverageid, max(createts) as createts,max(effectivedate) as effectivedate, max(enddate) as enddate, rank() over (partition by personid order by max(effectivedate) desc) as rank
 from person_bene_election pbe
 where benefitsubclass in ('1I')
 and benefitelection in ('E','W')
 and selectedoption = 'Y'
 and effectivedate < enddate
 and current_timestamp between createts and endts
 group by 1,2,3,4) pbe1I on pbe1I.personid = pe.personid and pbe1I.rank = 1

-----------------------------------------------------------------------------------------------------------------------------
-- Elected coverages for Active Employees
-----------------------------------------------------------------------------------------------------------------------------

left join 
(select personid, benefitplanid,benefitelection,benefitsubclass,benefitcoverageid,personbeneelectionpid, max(createts) as createts,max(effectivedate) as effectivedate, max(enddate) as enddate, rank() over (partition by personid order by max(effectivedate) desc) as rank
 from person_bene_election pbe
 where benefitsubclass in ('13')
 --and benefitelection in ('E')
 and selectedoption = 'Y'
 and effectivedate < enddate
 and current_timestamp between createts and endts
 group by 1,2,3,4,5,6) pbeac on pbeac.personid = pe.personid and pbeac.rank = 1

left join benefit_coverage_desc bcdac
  on bcdac.benefitcoverageid = pbeac.benefitcoverageid
 and current_date between bcdac.effectivedate and bcdac.enddate
 and current_timestamp between bcdac.createts and bcdac.endts  

left join 
(select personid, benefitplanid,benefitelection,benefitsubclass,benefitcoverageid,personbeneelectionpid, max(createts) as createts,max(effectivedate) as effectivedate, max(enddate) as enddate, rank() over (partition by personid order by max(effectivedate) desc) as rank
 from person_bene_election pbe
 where benefitsubclass in ('1C')
 --and benefitelection in ('E')
 and selectedoption = 'Y'
 and effectivedate < enddate
 and current_timestamp between createts and endts
 group by 1,2,3,4,5,6) pbecic on pbecic.personid = pe.personid and pbecic.rank = 1

left join benefit_coverage_desc bcdcic
  on bcdcic.benefitcoverageid = pbecic.benefitcoverageid
 and current_date between bcdcic.effectivedate and bcdcic.enddate
 and current_timestamp between bcdcic.createts and bcdcic.endts
  
left join 
(select personid, benefitplanid,benefitelection,benefitsubclass,benefitcoverageid,personbeneelectionpid, max(createts) as createts,max(effectivedate) as effectivedate, max(enddate) as enddate, rank() over (partition by personid order by max(effectivedate) desc) as rank
 from person_bene_election pbe
 where benefitsubclass in ('1I')
 --and benefitelection in ('E')
 and selectedoption = 'Y'
 and effectivedate < enddate
 and current_timestamp between createts and endts
 group by 1,2,3,4,5,6) pbehi on pbehi.personid = pe.personid and pbehi.rank = 1

left join benefit_coverage_desc bcdhi
  on bcdhi.benefitcoverageid = pbehi.benefitcoverageid
 and current_date between bcdhi.effectivedate and bcdhi.enddate
 and current_timestamp between bcdhi.createts and bcdhi.endts
------------------------------------------------------------------------------------------------------------------------
--Coverage for active employees with waived records and prior elected --
-----------------------------------------------------------------------------------------------------------------------------

-- Double ranked join to grab previous record
left join (select pbe.personid,pbe.benefitelection,pbe.benefitcoverageid,pbe.benefitplanid,pbe.benefitsubclass,pbe.compplanid,pbe.personbeneelectionpid,max(pbe.createts) as createts,max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate, rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
		from person_bene_election pbe
		left join person_employment pe on pe.personid = pbe.personid and current_date between pe.effectivedate and pe.enddate and current_timestamp between pe.createts and pe.endts
		left join (select pbe.personid,pbe.benefitelection,pbe.benefitcoverageid,max(pbe.createts) as createts,max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate, rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
				from person_bene_election pbe
				left join person_employment pe on pe.personid = pbe.personid and current_date between pe.effectivedate and pe.enddate and current_timestamp between pe.createts and pe.endts
				where pbe.benefitsubclass in ('13') and pbe.selectedoption = 'Y' 
					and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate
					group by 1,2,3 order by 1,7) pbeno on pbeno.personid = pbe.personid and pbeno.rank = 1
                 where pbe.benefitsubclass in ('13') and pbe.selectedoption = 'Y'
                        and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate and pbeno.effectivedate <> pbe.effectivedate
                         group by 1,2,3,4,5,6,7 order by 1,11) pbeacw on pbeacw.personid = pbe.personid and pbeacw.rank = 1

left join benefit_coverage_desc bcdacw
  on bcdacw.benefitcoverageid = pbeacw.benefitcoverageid
 and current_date between bcdacw.effectivedate and bcdacw.enddate
 and current_timestamp between bcdacw.createts and bcdacw.endts  

-- Double ranked join to grab previous record
left join (select pbe.personid,pbe.benefitelection,pbe.benefitcoverageid,pbe.benefitplanid,pbe.benefitsubclass,pbe.compplanid,pbe.personbeneelectionpid,max(pbe.createts) as createts,max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate, rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
		from person_bene_election pbe
		left join person_employment pe on pe.personid = pbe.personid and current_date between pe.effectivedate and pe.enddate and current_timestamp between pe.createts and pe.endts
		left join (select pbe.personid,pbe.benefitelection,pbe.benefitcoverageid,max(pbe.createts) as createts,max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate, rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
				from person_bene_election pbe
				left join person_employment pe on pe.personid = pbe.personid and current_date between pe.effectivedate and pe.enddate and current_timestamp between pe.createts and pe.endts
				where pbe.benefitsubclass in ('1C') and pbe.selectedoption = 'Y'
					and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate
					group by 1,2,3 order by 1,7) pbeno on pbeno.personid = pbe.personid and pbeno.rank = 1
                 where pbe.benefitsubclass in ('1C') and pbe.selectedoption = 'Y' 
                        and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate and pbeno.effectivedate <> pbe.effectivedate
                         group by 1,2,3,4,5,6,7 order by 1,11) pbecicw on pbecicw.personid = pbe.personid and pbecicw.rank = 1

left join benefit_coverage_desc bcdcicw
  on bcdcicw.benefitcoverageid = pbecicw.benefitcoverageid
 and current_date between bcdcicw.effectivedate and bcdcicw.enddate
 and current_timestamp between bcdcicw.createts and bcdcicw.endts

-- Double ranked join to grab previous record
left join (select pbe.personid,pbe.benefitelection,pbe.benefitcoverageid,pbe.benefitplanid,pbe.benefitsubclass,pbe.compplanid,pbe.personbeneelectionpid,max(pbe.createts) as createts,max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate, rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
		from person_bene_election pbe
		left join person_employment pe on pe.personid = pbe.personid and current_date between pe.effectivedate and pe.enddate and current_timestamp between pe.createts and pe.endts
		left join (select pbe.personid,pbe.benefitelection,pbe.benefitcoverageid,max(pbe.createts) as createts,max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate, rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
				from person_bene_election pbe
				left join person_employment pe on pe.personid = pbe.personid and current_date between pe.effectivedate and pe.enddate and current_timestamp between pe.createts and pe.endts
				where pbe.benefitsubclass in ('1I') and pbe.selectedoption = 'Y' 
					and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate
					group by 1,2,3 order by 1,7) pbeno on pbeno.personid = pbe.personid and pbeno.rank = 1
                 where pbe.benefitsubclass in ('1I') and pbe.selectedoption = 'Y' 
                        and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate and pbeno.effectivedate <> pbe.effectivedate
                         group by 1,2,3,4,5,6,7 order by 1,11) pbehiw on pbehiw.personid = pbe.personid and pbehiw.rank = 1

left join benefit_coverage_desc bcdhiw
  on bcdhiw.benefitcoverageid = pbehiw.benefitcoverageid
 and current_date between bcdhiw.effectivedate and bcdhiw.enddate
 and current_timestamp between bcdhiw.createts and bcdhiw.endts   

-----------------------------------------------------------------------------------------------------------------------------

left join personbenoptioncostl pocac
  on pocac.personid = pbeac.personid
 and pocac.benefitelection = 'E'
 and pocac.personbeneelectionpid = pbeac.personbeneelectionpid
 and pocac.costsby = 'P'
left join personbenoptioncostl pocacw
  on pocacw.personid = pbeacw.personid
 and pocacw.benefitelection = 'E'
 and pocacw.personbeneelectionpid = pbeacw.personbeneelectionpid
 and pocacw.costsby = 'P'
left join personbenoptioncostl pocci
  on pocci.personid = pbecic.personid
 and pocci.benefitelection = 'E'
 and pocci.personbeneelectionpid = pbecic.personbeneelectionpid
 and pocci.costsby = 'P'
left join personbenoptioncostl pocciw
  on pocciw.personid = pbecicw.personid
 and pocciw.benefitelection = 'E'
 and pocciw.personbeneelectionpid = pbecicw.personbeneelectionpid
 and pocciw.costsby = 'P'
left join personbenoptioncostl pochi
  on pochi.personid = pbehi.personid
 and pochi.benefitelection = 'E'
 and pochi.personbeneelectionpid = pbehi.personbeneelectionpid
 and pochi.costsby = 'P' 
left join personbenoptioncostl pochiw
  on pochiw.personid = pbehiw.personid
 and pochiw.benefitelection = 'E'
 and pochiw.personbeneelectionpid = pbehiw.personbeneelectionpid
 and pochiw.costsby = 'P' 

---- coverage tiers pertaining to the dependent needs to be on the dependent's record 
---- this join defaults a flags to N when a coverage does not apply to dep or spouse 
---- check how the flags are set to provide the correct coverage tier used for CI plans only
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
 ,case when pbecie.benefitelection = 'E' then pbecie.benefitsubclass 
       when pbecie.benefitelection = 'W' and pbeciew.benefitelection = 'E' then pbeciew.benefitsubclass 
       else 'N' end as e_benefitsubclass
 ,case when pbecis.benefitelection = 'E' then coalesce(pbecis.benefitsubclass,'N')
       when pbecis.benefitelection = 'W' and pbecisw.benefitelection = 'E' then coalesce(pbecisw.benefitsubclass,'N') 
       else 'N' end as s_benefitsubclass
 ,case when pbecic.benefitelection = 'E' then coalesce(pbecic.benefitsubclass,'N') 
       when pbecic.benefitelection = 'W' and pbecicw.benefitelection = 'E' then coalesce(pbecicw.benefitsubclass,'N') 
       else 'N' end as c_benefitsubclass
  from person_bene_election pbe 
     
left join 
(select personid, benefitplanid,benefitelection,benefitsubclass,benefitcoverageid,personbeneelectionpid, max(createts) as createts,max(effectivedate) as effectivedate, max(enddate) as enddate, rank() over (partition by personid order by max(effectivedate) desc) as rank
 from person_bene_election pbe
 where benefitsubclass in ('1W')
 and selectedoption = 'Y'
 and effectivedate < enddate
 and current_timestamp between createts and endts
 group by 1,2,3,4,5,6) pbecie on pbecie.personid = pbe.personid and pbecie.rank = 1
left join 
(select personid, benefitplanid,benefitelection,benefitsubclass,benefitcoverageid,personbeneelectionpid, max(createts) as createts,max(effectivedate) as effectivedate, max(enddate) as enddate, rank() over (partition by personid order by max(effectivedate) desc) as rank
 from person_bene_election pbe
 where benefitsubclass in ('1S')
 and selectedoption = 'Y'
 and effectivedate < enddate
 and current_timestamp between createts and endts
 group by 1,2,3,4,5,6) pbecis on pbecis.personid = pbe.personid and pbecis.rank = 1
left join 
(select personid, benefitplanid,benefitelection,benefitsubclass,benefitcoverageid,personbeneelectionpid, max(createts) as createts,max(effectivedate) as effectivedate, max(enddate) as enddate, rank() over (partition by personid order by max(effectivedate) desc) as rank
 from person_bene_election pbe
 where benefitsubclass in ('1C')
 and selectedoption = 'Y'
 and effectivedate < enddate
 and current_timestamp between createts and endts
 group by 1,2,3,4,5,6) pbecic on pbecic.personid = pbe.personid and pbecic.rank = 1

-- Double ranked join to grab previous record
left join (select pbe.personid,pbe.benefitelection,pbe.benefitcoverageid,pbe.benefitplanid,pbe.benefitsubclass,pbe.compplanid,pbe.personbeneelectionpid,max(pbe.createts) as createts,max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate, rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
		from person_bene_election pbe
		left join person_employment pe on pe.personid = pbe.personid and current_date between pe.effectivedate and pe.enddate and current_timestamp between pe.createts and pe.endts
		left join (select pbe.personid,pbe.benefitelection,pbe.benefitcoverageid,max(pbe.createts) as createts,max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate, rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
				from person_bene_election pbe
				left join person_employment pe on pe.personid = pbe.personid and current_date between pe.effectivedate and pe.enddate and current_timestamp between pe.createts and pe.endts
				where pbe.benefitsubclass in ('1W') and pbe.selectedoption = 'Y'
					and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate
					group by 1,2,3 order by 1,7) pbeno on pbeno.personid = pbe.personid and pbeno.rank = 1
                 where pbe.benefitsubclass in ('1W') and pbe.selectedoption = 'Y'
                        and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate and pbeno.effectivedate <> pbe.effectivedate
                         group by 1,2,3,4,5,6,7 order by 1,11) pbeciew on pbeciew.personid = pbe.personid and pbeciew.rank = 1

-- Double ranked join to grab previous record
left join (select pbe.personid,pbe.benefitelection,pbe.benefitcoverageid,pbe.benefitplanid,pbe.benefitsubclass,pbe.compplanid,pbe.personbeneelectionpid,max(pbe.createts) as createts,max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate, rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
		from person_bene_election pbe
		left join person_employment pe on pe.personid = pbe.personid and current_date between pe.effectivedate and pe.enddate and current_timestamp between pe.createts and pe.endts
		left join (select pbe.personid,pbe.benefitelection,pbe.benefitcoverageid,max(pbe.createts) as createts,max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate, rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
				from person_bene_election pbe
				left join person_employment pe on pe.personid = pbe.personid and current_date between pe.effectivedate and pe.enddate and current_timestamp between pe.createts and pe.endts
				where pbe.benefitsubclass in ('1S') and pbe.selectedoption = 'Y'
					and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate
					group by 1,2,3 order by 1,7) pbeno on pbeno.personid = pbe.personid and pbeno.rank = 1
                 where pbe.benefitsubclass in ('1S') and pbe.selectedoption = 'Y'
                        and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate and pbeno.effectivedate <> pbe.effectivedate
                         group by 1,2,3,4,5,6,7 order by 1,11) pbecisw on pbecisw.personid = pbe.personid and pbecisw.rank = 1 

-- Double ranked join to grab previous record
left join (select pbe.personid,pbe.benefitelection,pbe.benefitcoverageid,pbe.benefitplanid,pbe.benefitsubclass,pbe.compplanid,pbe.personbeneelectionpid,max(pbe.createts) as createts,max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate, rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
		from person_bene_election pbe
		left join person_employment pe on pe.personid = pbe.personid and current_date between pe.effectivedate and pe.enddate and current_timestamp between pe.createts and pe.endts
		left join (select pbe.personid,pbe.benefitelection,pbe.benefitcoverageid,max(pbe.createts) as createts,max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate, rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
				from person_bene_election pbe
				left join person_employment pe on pe.personid = pbe.personid and current_date between pe.effectivedate and pe.enddate and current_timestamp between pe.createts and pe.endts
				where pbe.benefitsubclass in ('1C') and pbe.selectedoption = 'Y'
					and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate
					group by 1,2,3 order by 1,7) pbeno on pbeno.personid = pbe.personid and pbeno.rank = 1
                 where pbe.benefitsubclass in ('1C') and pbe.selectedoption = 'Y'
                        and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate and pbeno.effectivedate <> pbe.effectivedate
                         group by 1,2,3,4,5,6,7 order by 1,11) pbecicw on pbecicw.personid = pbe.personid and pbecicw.rank = 1

where current_date between pbe.effectivedate and pbe.enddate and current_timestamp between pbe.createts and pbe.endts
  and pbe.benefitsubclass in ('1W','1S','1C') and pbe.benefitelection in ('E','W')  
--pull all elected records or waived records with prior elected
  and (((pbecie.benefitelection = 'E') or (pbecie.benefitelection = 'W' and pbeciew.benefitelection = 'E'))
   or  ((pbecis.benefitelection = 'E') or (pbecis.benefitelection = 'W' and pbecisw.benefitelection = 'E'))
   or  ((pbecic.benefitelection = 'E') or (pbecic.benefitelection = 'W' and pbecicw.benefitelection = 'E')))      
) ci ) tier on tier.personid = pbe.personid  

 
left join benefit_coverage_desc bcd
  on bcd.benefitcoverageid = pbe.benefitcoverageid
 and current_date between bcd.effectivedate and bcd.enddate
 and current_timestamp between bcd.createts and bcd.endts     
 
left join benefit_plan_desc bpdhi
  on bpdhi.benefitsubclass = pbehi.benefitsubclass
 and current_date between bpdhi.effectivedate and bpdhi.enddate
 and current_timestamp between bpdhi.createts and bpdhi.endts    
 
left join person_names pn
  on pn.personid = pe.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts 

left join person_vitals pv
  on pv.personid = pe.personid
 and current_date between pv.effectivedate and pv.enddate
 and current_timestamp between pv.createts and pv.endts 

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
   
left join pers_pos pp
  on pp.personid = pe.personid
 and current_date between pp.effectivedate and pp.enddate
 and current_timestamp between pp.createts and pp.endts 
  
left join person_compensation pc
  on pc.personid = pp.personid
 and current_date between pc.effectivedate and pc.enddate
 and current_timestamp between pc.createts and pc.endts
 and pc.earningscode <> 'BenBase'
  
left join person_payroll ppl 
  on ppl.personid = pe.personid 
 and current_date between ppl.effectivedate and ppl.enddate
 and current_timestamp between ppl.createts and ppl.endts 
 
----- dependent data

left join person_dependent_relationship pdr
  on pdr.personid = pbe.personid
 and pdr.dependentrelationship in ('S','D','C','ND','NS','NC','FC','QC')
 and current_date between pdr.effectivedate and pdr.enddate
 and current_timestamp between pdr.createts and pdr.endts
 
-----------------------------------------------------------------------
-- Dependent Enrollment Joins --
------------------------------------------------------------------------
-- Accident --
left join dependent_enrollment deac
  on deac.dependentid = pdr.dependentid
 and deac.personid = pdr.personid
 and deac.benefitsubclass = pbeac.benefitsubclass
 and deac.effectivedate < deac.enddate
 and current_timestamp between deac.createts and deac.endts 

-- Waived Accident --
left join dependent_enrollment deacw
  on deacw.dependentid = pdr.dependentid
 and deacw.benefitsubclass = pbeacw.benefitsubclass
 and deacw.personid = pi.personid
 and deacw.selectedoption = 'Y'
 and deacw.effectivedate < deacw.enddate
 and (?::DATE  <= deacw.enddate or (pbe13.effectivedate - interval '1 day' = deacw.enddate))
 --and elu.lastupdatets <= de13.enddate
 and current_timestamp between deacw.createts and deacw.endts  

-- High Indemnity --
left join dependent_enrollment dehi
  on dehi.dependentid = pdr.dependentid
 and dehi.personid = pdr.personid
 and dehi.benefitsubclass = pbehi.benefitsubclass
 and dehi.effectivedate < dehi.enddate
 and current_timestamp between dehi.createts and dehi.endts 

-- Waived High Indemnity --
left join dependent_enrollment dehiw
  on dehiw.dependentid = pdr.dependentid
 and dehiw.benefitsubclass = pbehiw.benefitsubclass
 and dehiw.personid = pi.personid
 and dehiw.selectedoption = 'Y'
 and dehiw.effectivedate < dehiw.enddate
 and (?::DATE <= dehiw.enddate or (pbe1I.effectivedate - interval '1 day' = dehiw.enddate))
 --and elu.lastupdatets <= dehi.enddate
 and current_timestamp between dehiw.createts and dehiw.endts 

------------------------------------------------------------------------
 
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

left join person_disability pdb
  on pdb.personid = pdr.dependentid
 and current_date between pdb.effectivedate and pdb.enddate
 and current_timestamp between pdb.createts and pdb.endts
 
left join dependent_desc dd 
  on dd.dependentid = pdr.dependentid
 and current_date between dd.effectivedate and dd.enddate 
 and current_timestamp between dd.createts AND dd.endts
   
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  and pe.emplstatus not in ('T','R')

--pull all elected records or waived records with prior elected
  and ((pbeac.benefitsubclass = '13' or (pbe.benefitelection = 'W' and pbe.benefitsubclass = '13' and pbeacw.benefitelection = 'E'))
   or  (pbecic.benefitsubclass = '1C' or (pbe.benefitelection = 'W' and pbe.benefitsubclass = '1C' and pbecicw.benefitelection = 'E'))
   or  (pbehi.benefitsubclass = '1I' or (pbe.benefitelection = 'W' and pbe.benefitsubclass = '1I' and pbehiw.benefitelection = 'E')))


  and (
      (ppl.effectivedate >= elu.lastupdatets::DATE 
   or (ppl.createts > elu.lastupdatets and ppl.effectivedate < coalesce(elu.lastupdatets::date, '2017-01-01')) ) 

   or
      ((pbe.effectivedate >= ?::DATE)
   or (pbe.createts >= elu.lastupdatets)  --- 1/21/2021 - ADDED createts to pick up coverage changes where only the createts changed and not effectivedate see Baptista personid '3486' coverage changes for 1C 
   or (pbe.createts > ?::DATE and pbe.effectivedate < coalesce(?::date, '2017-01-01')) )  
   --select * from person_bene_election where personid = '3486' and benefitsubclass = '1C' and createts > '2021-01-15';
   
   or
      (pn.effectivedate >= elu.lastupdatets::DATE 
   or (pn.createts > elu.lastupdatets and pn.effectivedate < coalesce(elu.lastupdatets::date, '2017-01-01')) ) 

   or
      (pv.effectivedate >= elu.lastupdatets::DATE 
   or (pv.createts > elu.lastupdatets and pv.effectivedate < coalesce(elu.lastupdatets::date, '2017-01-01')) )   
   
   or
      (pa.effectivedate >= elu.lastupdatets::DATE 
   or (pa.createts > elu.lastupdatets and pa.effectivedate < coalesce(elu.lastupdatets::date, '2017-01-01')) ) 

   or
      (pc.effectivedate >= elu.lastupdatets::DATE 
   or (pc.createts > elu.lastupdatets and pc.effectivedate < coalesce(elu.lastupdatets::date, '2017-01-01')) ) 

   or
      (pe.effectivedate >= elu.lastupdatets::DATE 
   or (pe.createts > elu.lastupdatets and pe.effectivedate < coalesce(elu.lastupdatets::date, '2017-01-01')) ) 
      
   or
      (pp.effectivedate >= elu.lastupdatets::DATE 
   or (pp.createts > elu.lastupdatets and pp.effectivedate < coalesce(elu.lastupdatets::date, '2017-01-01')) ) 
      
   or
      (ppcm.effectivedate >= elu.lastupdatets::DATE 
   or (ppcm.createts > elu.lastupdatets and ppcm.effectivedate < coalesce(elu.lastupdatets::date, '2017-01-01')) ) 

   or
      (ppcb.effectivedate >= elu.lastupdatets::DATE 
   or (ppcb.createts > elu.lastupdatets and ppcb.effectivedate < coalesce(elu.lastupdatets::date, '2017-01-01')) ) 

   or
      (ppcw.effectivedate >= elu.lastupdatets::DATE 
   or (ppcw.createts > elu.lastupdatets and ppcw.effectivedate < coalesce(elu.lastupdatets::date, '2017-01-01')) ) 
         
   or
      (ppch.effectivedate >= elu.lastupdatets::DATE 
   or (ppch.createts > elu.lastupdatets and ppch.effectivedate < coalesce(elu.lastupdatets::date, '2017-01-01')) ) 
      
   or
      (pnc.effectivedate >= elu.lastupdatets::DATE 
   or (pnc.createts > elu.lastupdatets and pnc.effectivedate < coalesce(elu.lastupdatets::date, '2017-01-01')) ) 

   or
      (pnch.effectivedate >= elu.lastupdatets::DATE 
   or (pnch.createts > elu.lastupdatets and pnch.effectivedate < coalesce(elu.lastupdatets::date, '2017-01-01')) ) 
 
   or
      (pv.effectivedate >= elu.lastupdatets::DATE 
   or (pv.createts > elu.lastupdatets and pv.effectivedate < coalesce(elu.lastupdatets::date, '2017-01-01')) ) 
                    
      )


-- Make sure child is 26 y/o or younger
  and ((pbe.benefitsubclass in ('1I','1C','13') and current_date - (interval '26 years') <= pvd.birthdate) and dd.dependentstatus <> 'D')
-- Ensures only enrolled (elected or waived with prior elected) dependent coverages are selected
  and (((bcdac.benefitcoveragedesc in ('Family', 'Employee + Children')) or (pbe13.benefitelection = 'W' and pbeacw.benefitelection = 'E' and bcdacw.benefitcoveragedesc in ('Family', 'Employee + Children')))
   or  ((bcdhi.benefitcoveragedesc in ('Family', 'Employee + Children')) or (pbe1I.benefitelection = 'W' and pbehiw.benefitelection = 'E' and bcdhiw.benefitcoveragedesc in ('Family', 'Employee + Children')))
   or  (tier.cicvgtier in ('FAMILY', 'EMPLOYEE + CHILD(REN)'))
   or  (pbe.benefitsubclass = '1S' and tier.cicvgtier = 'FAMILY')   ) 
   

--and (case when pbeac.benefitelection = 'E' then pdr.dependentid = deac.dependentid else pbeac.personid = pdr.personid end )   

/*
For Critical Illness, you need to include the Spouse if they have Spouse Critical Illness plan 
and include all children under age 26 if they have Child Critical Illness Plan.  

For Critical Illness, they do not enroll dependents - benefitsubclass IC and / or IS indicates CI for dependents

For Accident and Hospital Indemnity, include all enrolled dependents

*/

---------------------------------------------------------------------------------------------------------------------------------------------------       
   UNION
---------------------------------------------------------------------------------------------------------------------------------------------------


/* NOTES
*** All Lastupdatets are turned off atm

Updated to check that prior record for terms was not waived
--When emp terms it creates a 'T' record, when they waive benefit it creates a 'W'
--Current feed was not doing this (i.e. 2685 Maria Bedolla)
*/
---------------
-- TERMED EE --
---------------

select
 pi.personid
,bcdac.benefitcoveragedesc as accvgtier
,tier.cicvgtier
,bcdhi.benefitcoveragedesc as hicvgtier
,'1 TERMED EE' ::varchar(30) as qsource 
,1 AS SORTSEQ
,left(pi.identity,3)||'-'||substring(pi.identity,4,2)||'-'||right(pi.identity,4) ::char(11) as essn
,'EMPLOYEE' ::varchar(15) as relation
,pn.fname ::varchar(30) as fname
,pn.lname ::varchar(50) as lname
,pn.mname ::char(1) as mname
,pv.gendercode ::char(1) as gender
,to_char(pv.birthdate,'mm/dd/yyyy')::char(10) as dob
,to_char(pe.empllasthiredate,'mm/dd/yyyy')::char(10) as doh

,case when substring(pip.identity,1,5) = 'DAB00' then '120000A460'
      when substring(pip.identity,1,5) in ('DAB05','DAB20','DAB25') then '120000C460'
      when substring(pip.identity,1,5) = 'DAB10' then '1200000460'
      when substring(pip.identity,1,5) = 'DAB15' then '120000B460'
      else '1200000460' end ::char(11) as group_id

,cast(pp.scheduledhours / 2 as dec (18,2)) as hourspw   
,case when pc.frequencycode = 'H' then cast((pc.compamount * pp.scheduledhours) * 26 as dec(18,2)) 
      else cast(pc.compamount as dec(18,2)) end as annual_salary   

,case when pv.smoker = 'S' then 'Y' else 'N' end ::char(1) as smoker_flag
,pa.streetaddress ::varchar(30) as addr1
,pa.streetaddress2 ::varchar(30) as addr2 
,pa.city ::varchar(30) as city
,pa.stateprovincecode ::char(2) as state
,pa.postalcode ::char(5) as zip
,ppcw.phoneno ::char(15) as workphone
,coalesce(pnc.url,pnch.url) ::varchar(100) AS email
,null as bene_rel
,null as bene_pct
,'Term' ::char(4) as status_chg -- col v 

,to_char(greatest(pbeac.enddate,pbecie.enddate,pbehi.enddate),'mm/dd/yyyy')::char(10) as edoc -- col w
,null as comp_state_question
----------------------------------------
----- accident (13)                -----
----------------------------------------
,case when pbeac.benefitelection = 'E' then 'Accident' else null end ::varchar(30) as ae_plan_type
,case when pbeac.benefitelection = 'E' and bcdac.benefitcoveragedesc in ('EE','Employee Only','Employee') then 'EMPLOYEE'
      when pbeac.benefitelection = 'E' and bcdac.benefitcoveragedesc = 'Employee + Spouse' then 'EMPLOYEE + SPOUSE'
      when pbeac.benefitelection = 'E' and bcdac.benefitcoveragedesc = 'Family' then 'EMPLOYEE + FAMILY'
      when pbeac.benefitelection = 'E' and bcdac.benefitcoveragedesc in ('Employee + Children') then 'EMPLOYEE + CHILD(REN)'
      else null end ::varchar(30) as ae_insured_option
,case when pbeac.benefitelection = 'E' then cast(pocac.employeerate::numeric as dec(18,2)) else null end as ae_prem_amt          
,case when pbeac.benefitelection = 'E' then to_char(pbeac.effectivedate,'mm/dd/yyyy')else null end ::char(10) as ae_edoi -- issue date
,case when pbeac.benefitelection = 'E' then to_char(pbeac.createts,'mm/dd/yyyy')else null end ::char(10) as ae_edos -- signed date Debbie said use createts 
,case when pbeac.benefitelection = 'E' and pe.emplstatus in ('T','R') then to_char(pbeac.enddate,'mm/dd/yyyy') else null end ::char(10) as ae_edot -- col ad
----------------------------------------  
,null as di_plan_type
,null as di_benefit_amt
,null as di_prem_amt
,null as di_edoi
,null as di_edos
,null as di_edot
----------------------------------------
----- critical illness ('1W','1S','1C') -----
----------------------------------------
,case when pbecie.benefitelection = 'E' then 'Critical Illness' else null end ::varchar(30) as ci_plan_type
,case when pbecie.benefitelection = 'E' then tier.cicvgtier else null end ::varchar(30) as ci_insured_option 
,case when pbecie.benefitelection = 'E' then 10000.00 else null end as ci_bene_amt     
,case when pbecie.benefitelection = 'E' then cast(pocci.employeerate::numeric as dec(18,2)) else null end as ci_prem_amt      
,case when pbecie.benefitelection = 'E' then to_char(pbecie.effectivedate,'mm/dd/yyyy') else null end ::char(10) as ci_edoi -- issue date
,case when pbecie.benefitelection = 'E' then to_char(pbecie.createts,'mm/dd/yyyy') else null end ::char(10) as ci_edos -- signed date Debbie said use createts 
,case when pbecie.benefitelection = 'E' and pe.emplstatus in ('T','R') then to_char(pbecie.enddate,'mm/dd/yyyy') else null end ::char(10) as ci_edot -- col aq
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
,case when pbehi.benefitelection = 'E' and pbehi.benefitplanid in ('125','128','131','137','140','146') then 'Hospital Indemnity - Low (A)'
      when pbehi.benefitelection = 'E' and pbehi.benefitplanid in ('149','155','158','161','164','167') then 'Hospital Indemnity - High (B)'
      else null end ::varchar(30) as hi_plan_type
,case when pbehi.benefitelection = 'E' and bcdhi.benefitcoveragedesc in ('EE','Employee Only') then 'EMPLOYEE'
      when pbehi.benefitelection = 'E' and bcdhi.benefitcoveragedesc = 'Employee + Spouse' then 'EMPLOYEE + SPOUSE'
      when pbehi.benefitelection = 'E' and bcdhi.benefitcoveragedesc = 'Family' then 'EMPLOYEE + FAMILY'
      when pbehi.benefitelection = 'E' and bcdhi.benefitcoveragedesc in ('Employee + Children') then 'EMPLOYEE + CHILD(REN)'
      else null end ::varchar(30) as hi_insured_option 
,null as hi_benefit_amt
,case when pbehi.benefitelection = 'E' then cast(pochi.employeerate::numeric as dec(18,2)) else null end as hi_prem_amt        
,case when pbehi.benefitelection = 'E' then to_char(pbehi.effectivedate,'mm/dd/yyyy')else null end ::char(10) as hi_edoi -- issue date
,case when pbehi.benefitelection = 'E' then to_char(pbehi.createts,'mm/dd/yyyy')else null end ::char(10) as hi_edos -- signed date Debbie said use createts 
,case when pbehi.benefitelection = 'E' and pe.emplstatus in ('T','R') then to_char(pbehi.enddate,'mm/dd/yyyy') else null end ::char(10) as hi_edot -- col bd
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
,elu.lastupdatets
from person_identity pi

left join edi.edi_last_update elu on elu.feedid = 'DAB_Assurity_CI_HI_Accident_Export'

left join person_identity pip
  on pip.personid = pi.personid
 and pip.identitytype = 'PSPID'
 and current_timestamp between pip.createts and pip.endts
 
left join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts
 
left join person_names pn
  on pn.personid = pe.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts 

left join person_vitals pv
  on pv.personid = pe.personid
 and current_date between pv.effectivedate and pv.enddate
 and current_timestamp between pv.createts and pv.endts 

left join (select personid, max(perspospid) as perspospid 
             from pers_pos 
             LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'DAB_Assurity_CI_HI_Accident_Export'
             where current_timestamp between createts and endts 
            group by 1) as maxpos on maxpos.personid = pe.personid 

left join pers_pos pp 
  on pp.personid = maxpos.personid
 and pp.perspospid = maxpos.perspospid
 and current_timestamp between pp.createts and pp.endts 

left join (select personid, max(percomppid) as percomppid
             from person_compensation 
             LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'DAB_Assurity_CI_HI_Accident_Export'
              and effectivedate <= elu.lastupdatets::DATE 
             group by 1 ) as maxpc on maxpc.personid = pe.personid
 
left join person_compensation pc
  on pc.personid = maxpc.personid
 and pc.percomppid = maxpc.percomppid
 and current_timestamp between pc.createts and pc.endts 

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
    
left join 
(select personid, benefitplanid,benefitelection,benefitcoverageid, max(createts) as createts,max(effectivedate) as effectivedate, max(enddate) as enddate, rank() over (partition by personid order by max(effectivedate) desc) as rank
 from person_bene_election pbe
 where benefitsubclass in ('1W','1S','1C','1I','13')
 --and benefitelection in ('T')
 and selectedoption = 'Y'
 and effectivedate < enddate
 and current_timestamp between createts and endts
 group by 1,2,3,4) pbe on pbe.personid = pe.personid and pbe.rank = 1

-- Double ranked join to check that record previous to the term was elected
left join (select pbe.personid,pbe.benefitelection,pbe.benefitcoverageid,pbe.benefitplanid,pbe.benefitsubclass,pbe.compplanid,pbe.personbeneelectionpid,max(pbe.createts) as createts,max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate, rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
		from person_bene_election pbe
		left join person_employment pe on pe.personid = pbe.personid and current_date between pe.effectivedate and pe.enddate and current_timestamp between pe.createts and pe.endts
		left join (select pbe.personid,pbe.benefitelection,pbe.benefitcoverageid,max(pbe.createts) as createts,max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate, rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
				from person_bene_election pbe
				left join person_employment pe on pe.personid = pbe.personid and current_date between pe.effectivedate and pe.enddate and current_timestamp between pe.createts and pe.endts
				where pbe.benefitsubclass in ('13') and pbe.selectedoption = 'Y' and pe.emplstatus in ('T','R')
					and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate
					group by 1,2,3 order by 1,7) pbeno on pbeno.personid = pbe.personid and pbeno.rank = 1
                 where pbe.benefitsubclass in ('13') and pbe.selectedoption = 'Y' and pe.emplstatus in ('T','R')
                        and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate and pbeno.effectivedate <> pbe.effectivedate
                         group by 1,2,3,4,5,6,7 order by 1,11) pbeac on pbeac.personid = pbe.personid and pbeac.rank = 1

-- Double ranked join to check that record previous to the term was elected
left join (select pbe.personid,pbe.benefitelection,pbe.benefitcoverageid,pbe.benefitplanid,pbe.benefitsubclass,pbe.compplanid,pbe.personbeneelectionpid,max(pbe.createts) as createts,max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate, rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
		from person_bene_election pbe
		left join person_employment pe on pe.personid = pbe.personid and current_date between pe.effectivedate and pe.enddate and current_timestamp between pe.createts and pe.endts
		left join (select pbe.personid,pbe.benefitelection,pbe.benefitcoverageid,max(pbe.createts) as createts,max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate, rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
				from person_bene_election pbe
				left join person_employment pe on pe.personid = pbe.personid and current_date between pe.effectivedate and pe.enddate and current_timestamp between pe.createts and pe.endts
				where pbe.benefitsubclass in ('1W') and pbe.selectedoption = 'Y' and pe.emplstatus in ('T','R')
					and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate
					group by 1,2,3 order by 1,7) pbeno on pbeno.personid = pbe.personid and pbeno.rank = 1
                 where pbe.benefitsubclass in ('1W') and pbe.selectedoption = 'Y' and pe.emplstatus in ('T','R')
                        and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate and pbeno.effectivedate <> pbe.effectivedate
                         group by 1,2,3,4,5,6,7 order by 1,11) pbecie on pbecie.personid = pbe.personid and pbecie.rank = 1

-- Double ranked join to check that record previous to the term was elected
left join (select pbe.personid,pbe.benefitelection,pbe.benefitcoverageid,pbe.benefitplanid,pbe.benefitsubclass,pbe.compplanid,pbe.personbeneelectionpid,max(pbe.createts) as createts,max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate, rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
		from person_bene_election pbe
		left join person_employment pe on pe.personid = pbe.personid and current_date between pe.effectivedate and pe.enddate and current_timestamp between pe.createts and pe.endts
		left join (select pbe.personid,pbe.benefitelection,pbe.benefitcoverageid,max(pbe.createts) as createts,max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate, rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
				from person_bene_election pbe
				left join person_employment pe on pe.personid = pbe.personid and current_date between pe.effectivedate and pe.enddate and current_timestamp between pe.createts and pe.endts
				where pbe.benefitsubclass in ('1I') and pbe.selectedoption = 'Y' and pe.emplstatus in ('T','R')
					and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate
					group by 1,2,3 order by 1,7) pbeno on pbeno.personid = pbe.personid and pbeno.rank = 1
                 where pbe.benefitsubclass in ('1I') and pbe.selectedoption = 'Y' and pe.emplstatus in ('T','R')
                        and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate and pbeno.effectivedate <> pbe.effectivedate
                         group by 1,2,3,4,5,6,7 order by 1,11) pbehi on pbehi.personid = pbe.personid and pbehi.rank = 1   


left join personbenoptioncostl pocac
  on pocac.personid = pbeac.personid
 and pocac.benefitelection = 'E'
 and pocac.personbeneelectionpid = pbeac.personbeneelectionpid
 and pocac.costsby = 'P'
left join personbenoptioncostl pocci
  on pocci.personid = pbecie.personid
 and pocci.benefitelection = 'E'
 and pocci.personbeneelectionpid = pbecie.personbeneelectionpid
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
 ,case when pbecis.benefitelection = 'E' then pbecis.benefitsubclass else 'N' end as s_benefitsubclass
 ,case when pbecic.benefitelection = 'E' then pbecic.benefitsubclass else 'N' end as c_benefitsubclass
  from person_bene_election pbe 
     
-- Double ranked join to check that record previous to the term was elected
left join (select pbe.personid,pbe.benefitelection,pbe.benefitcoverageid,pbe.benefitplanid,pbe.benefitsubclass,pbe.compplanid,pbe.personbeneelectionpid,max(pbe.createts) as createts,max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate, rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
		from person_bene_election pbe
		left join person_employment pe on pe.personid = pbe.personid and current_date between pe.effectivedate and pe.enddate and current_timestamp between pe.createts and pe.endts
		left join (select pbe.personid,pbe.benefitelection,pbe.benefitcoverageid,max(pbe.createts) as createts,max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate, rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
				from person_bene_election pbe
				left join person_employment pe on pe.personid = pbe.personid and current_date between pe.effectivedate and pe.enddate and current_timestamp between pe.createts and pe.endts
				where pbe.benefitsubclass in ('1W') and pbe.selectedoption = 'Y' and pe.emplstatus in ('T','R')
					and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate
					group by 1,2,3 order by 1,7) pbeno on pbeno.personid = pbe.personid and pbeno.rank = 1
                 where pbe.benefitsubclass in ('1W') and pbe.selectedoption = 'Y' and pe.emplstatus in ('T','R')
                        and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate and pbeno.effectivedate <> pbe.effectivedate
                         group by 1,2,3,4,5,6,7 order by 1,11) pbecie on pbecie.personid = pbe.personid and pbecie.rank = 1

-- Double ranked join to check that record previous to the term was elected
left join (select pbe.personid,pbe.benefitelection,pbe.benefitcoverageid,pbe.benefitplanid,pbe.benefitsubclass,pbe.compplanid,pbe.personbeneelectionpid,max(pbe.createts) as createts,max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate, rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
		from person_bene_election pbe
		left join person_employment pe on pe.personid = pbe.personid and current_date between pe.effectivedate and pe.enddate and current_timestamp between pe.createts and pe.endts
		left join (select pbe.personid,pbe.benefitelection,pbe.benefitcoverageid,max(pbe.createts) as createts,max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate, rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
				from person_bene_election pbe
				left join person_employment pe on pe.personid = pbe.personid and current_date between pe.effectivedate and pe.enddate and current_timestamp between pe.createts and pe.endts
				where pbe.benefitsubclass in ('1S') and pbe.selectedoption = 'Y' and pe.emplstatus in ('T','R')
					and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate
					group by 1,2,3 order by 1,7) pbeno on pbeno.personid = pbe.personid and pbeno.rank = 1
                 where pbe.benefitsubclass in ('1S') and pbe.selectedoption = 'Y' and pe.emplstatus in ('T','R')
                        and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate and pbeno.effectivedate <> pbe.effectivedate
                         group by 1,2,3,4,5,6,7 order by 1,11) pbecis on pbecis.personid = pbe.personid and pbecis.rank = 1

-- Double ranked join to check that record previous to the term was elected
left join (select pbe.personid,pbe.benefitelection,pbe.benefitcoverageid,pbe.benefitplanid,pbe.benefitsubclass,pbe.compplanid,pbe.personbeneelectionpid,max(pbe.createts) as createts,max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate, rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
		from person_bene_election pbe
		left join person_employment pe on pe.personid = pbe.personid and current_date between pe.effectivedate and pe.enddate and current_timestamp between pe.createts and pe.endts
		left join (select pbe.personid,pbe.benefitelection,pbe.benefitcoverageid,max(pbe.createts) as createts,max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate, rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
				from person_bene_election pbe
				left join person_employment pe on pe.personid = pbe.personid and current_date between pe.effectivedate and pe.enddate and current_timestamp between pe.createts and pe.endts
				where pbe.benefitsubclass in ('1C') and pbe.selectedoption = 'Y' and pe.emplstatus in ('T','R')
					and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate
					group by 1,2,3 order by 1,7) pbeno on pbeno.personid = pbe.personid and pbeno.rank = 1
                 where pbe.benefitsubclass in ('1C') and pbe.selectedoption = 'Y' and pe.emplstatus in ('T','R')
                        and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate and pbeno.effectivedate <> pbe.effectivedate
                         group by 1,2,3,4,5,6,7 order by 1,11) pbecic on pbecic.personid = pbe.personid and pbecic.rank = 1

where current_timestamp between pbe.createts and pbe.endts
  and pbe.benefitsubclass in ('1W','1S','1C') and (pbecie.benefitelection = 'E' or pbecis.benefitelection = 'E' or pbecic.benefitelection = 'E')  
) ci ) tier on tier.personid = pbe.personid

left join benefit_coverage_desc bcdac
  on bcdac.benefitcoverageid = pbeac.benefitcoverageid
 and current_date between bcdac.effectivedate and bcdac.enddate
 and current_timestamp between bcdac.createts and bcdac.endts  

left join benefit_coverage_desc bcdhi
  on bcdhi.benefitcoverageid = pbehi.benefitcoverageid
 and current_date between bcdhi.effectivedate and bcdhi.enddate
 and current_timestamp between bcdhi.createts and bcdhi.endts                      
                         
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  and pe.emplstatus in ('T','R')
  and (pbeac.benefitelection = 'E' or pbecie.benefitelection = 'E' or pbehi.benefitelection = 'E')
  and (pe.effectivedate >= ?::DATE 
   or (pe.createts > ?::DATE and pe.effectivedate < coalesce(?::date, '2017-01-01')) )

---------------------------------------------------------------------------------------------------------------------------------------------------       
   UNION
---------------------------------------------------------------------------------------------------------------------------------------------------

--------------------
-- TERMED SPOUSE --
--------------------

select
 pi.personid
,case when bcdac.benefitcoveragedesc in ('Employee + Spouse','Family') then bcdac.benefitcoveragedesc else null end as accvgtier
,case when tier.cicvgtier in ('EMPLOYEE + SPOUSE','FAMILY') then tier.cicvgtier else null end 
,case when bcdhi.benefitcoveragedesc in ('Employee + Spouse','Family') then bcdhi.benefitcoveragedesc else null end as hicvgtier
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
,case when de13.selectedoption = 'Y' and pbeac.benefitelection = 'E' then 'Accident' else null end ::varchar(30) as ae_plan_type
,case when de13.selectedoption = 'Y' and pbeac.benefitelection = 'E'  and bcdac.benefitcoveragedesc in ('EE','Employee Only','Employee') then 'EMPLOYEE'
      when de13.selectedoption = 'Y' and pbeac.benefitelection = 'E'  and bcdac.benefitcoveragedesc = 'Employee + Spouse' then 'EMPLOYEE + SPOUSE'
      when de13.selectedoption = 'Y' and pbeac.benefitelection = 'E'  and bcdac.benefitcoveragedesc = 'Family' then 'EMPLOYEE + FAMILY'
      when de13.selectedoption = 'Y' and pbeac.benefitelection = 'E'  and bcdac.benefitcoveragedesc in ('Employee + Children') then 'EMPLOYEE + CHILD(REN)'
      else null end ::varchar(30) as ae_insured_option
,case when de13.selectedoption = 'Y' and pbeac.benefitelection = 'E' then cast(pocac.employeerate::numeric as dec(18,2)) else null end as ae_prem_amt          
,case when de13.selectedoption = 'Y' and pbeac.benefitelection = 'E' then to_char(pbeac.effectivedate,'mm/dd/yyyy')else null end ::char(10) as ae_edoi -- issue date
,case when de13.selectedoption = 'Y' and pbeac.benefitelection = 'E' then to_char(pbeac.createts,'mm/dd/yyyy')else null end ::char(10) as ae_edos -- signed date Debbie said use createts 
,case when de13.selectedoption = 'Y' and pbeac.benefitelection = 'E' and pe.emplstatus in ('T','R') then to_char(pbeac.enddate,'mm/dd/yyyy') else null end ::char(10) as ae_edot
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
,case when pbecis.benefitelection = 'E' then 'Critical Illness' else null end ::varchar(30) as ci_plan_type
,case when pbecis.benefitelection = 'E' then tier.cicvgtier else null end ::varchar(30) as ci_insured_option 
,case when pbecis.benefitelection = 'E' then 5000.00 else null end as ci_bene_amt     
,case when pbecis.benefitelection = 'E' then cast(pocci.employeerate::numeric as dec(18,2)) else null end as ci_prem_amt      
,case when pbecis.benefitelection = 'E' then to_char(pbecis.effectivedate,'mm/dd/yyyy') else null end ::char(10) as ci_edoi -- issue date
,case when pbecis.benefitelection = 'E' then to_char(pbecis.createts,'mm/dd/yyyy') else null end ::char(10) as ci_edos -- signed date Debbie said use createts 
,case when pbecis.benefitelection = 'E' and pe.emplstatus in ('T','R') then to_char(pbecis.enddate,'mm/dd/yyyy') else null end ::char(10) as ci_edot
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
,case when dehi.selectedoption = 'Y' and pbehi.benefitelection = 'E' and pbehi.benefitplanid in ('125','128','131','137','140','146') then 'Hospital Indemnity - Low (A)'
      when dehi.selectedoption = 'Y' and pbehi.benefitelection = 'E' and pbehi.benefitplanid in ('149','155','158','161','164','167') then 'Hospital Indemnity - High (B)'
      else null end ::varchar(30) as hi_plan_type
,case when dehi.selectedoption = 'Y' and pbehi.benefitelection = 'E' and bcdhi.benefitcoveragedesc in ('EE','Employee Only') then 'EMPLOYEE'
      when dehi.selectedoption = 'Y' and pbehi.benefitelection = 'E' and bcdhi.benefitcoveragedesc = 'Employee + Spouse' then 'EMPLOYEE + SPOUSE'
      when dehi.selectedoption = 'Y' and pbehi.benefitelection = 'E' and bcdhi.benefitcoveragedesc = 'Family' then 'EMPLOYEE + FAMILY'
      when dehi.selectedoption = 'Y' and pbehi.benefitelection = 'E' and bcdhi.benefitcoveragedesc in ('Employee + Children') then 'EMPLOYEE + CHILD(REN)'
      else null end ::varchar(30) as hi_insured_option 
,null as hi_benefit_amt
,case when dehi.selectedoption = 'Y' and pbehi.benefitelection = 'E' then cast (pochi.employeerate::numeric as dec(18,2)) else null end as hi_prem_amt        
,case when dehi.selectedoption = 'Y' and pbehi.benefitelection = 'E' then to_char(pbehi.effectivedate,'mm/dd/yyyy')else null end ::char(10) as hi_edoi -- issue date
,case when dehi.selectedoption = 'Y' and pbehi.benefitelection = 'E' then to_char(pbehi.createts,'mm/dd/yyyy')else null end ::char(10) as hi_edos -- signed date Debbie said use createts 
,case when dehi.selectedoption = 'Y' and pbehi.benefitelection = 'E' and pe.emplstatus in ('T','R') then to_char(pbehi.enddate,'mm/dd/yyyy') else null end ::char(10) as hi_edot      
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
,elu.lastupdatets
from person_identity pi

left join edi.edi_last_update elu on elu.feedid = 'DAB_Assurity_CI_HI_Accident_Export'

left join person_identity pip
  on pip.personid = pi.personid
 and pip.identitytype = 'PSPID'
 and current_timestamp between pip.createts and pip.endts
 
left join person_employment pe
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
    
left join 
(select personid, benefitplanid,benefitelection,benefitcoverageid, max(createts) as createts,max(effectivedate) as effectivedate, max(enddate) as enddate, rank() over (partition by personid order by max(effectivedate) desc) as rank
 from person_bene_election pbe
 where benefitsubclass in ('1S','1I','13')
 --and benefitelection in ('T')
 and selectedoption = 'Y'
 and effectivedate < enddate
 and current_timestamp between createts and endts
 group by 1,2,3,4) pbe on pbe.personid = pe.personid and pbe.rank = 1


-- Double ranked join to check that record previous to the term was elected
left join (select pbe.personid,pbe.benefitelection,pbe.benefitcoverageid,pbe.benefitplanid,pbe.benefitsubclass,pbe.compplanid,pbe.personbeneelectionpid,max(pbe.createts) as createts,max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate, rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
		from person_bene_election pbe
		left join person_employment pe on pe.personid = pbe.personid and current_date between pe.effectivedate and pe.enddate and current_timestamp between pe.createts and pe.endts
		left join (select pbe.personid,pbe.benefitelection,pbe.benefitcoverageid,max(pbe.createts) as createts,max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate, rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
				from person_bene_election pbe
				left join person_employment pe on pe.personid = pbe.personid and current_date between pe.effectivedate and pe.enddate and current_timestamp between pe.createts and pe.endts
				where pbe.benefitsubclass in ('13') and pbe.selectedoption = 'Y' and pe.emplstatus in ('T','R')
					and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate
					group by 1,2,3 order by 1,7) pbeno on pbeno.personid = pbe.personid and pbeno.rank = 1
                 where pbe.benefitsubclass in ('13') and pbe.selectedoption = 'Y' and pe.emplstatus in ('T','R')
                        and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate and pbeno.effectivedate <> pbe.effectivedate
                         group by 1,2,3,4,5,6,7 order by 1,11) pbeac on pbeac.personid = pbe.personid and pbeac.rank = 1

-- Double ranked join to check that record previous to the term was elected
left join (select pbe.personid,pbe.benefitelection,pbe.benefitcoverageid,pbe.benefitplanid,pbe.benefitsubclass,pbe.compplanid,pbe.personbeneelectionpid,max(pbe.createts) as createts,max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate, rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
		from person_bene_election pbe
		left join person_employment pe on pe.personid = pbe.personid and current_date between pe.effectivedate and pe.enddate and current_timestamp between pe.createts and pe.endts
		left join (select pbe.personid,pbe.benefitelection,pbe.benefitcoverageid,max(pbe.createts) as createts,max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate, rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
				from person_bene_election pbe
				left join person_employment pe on pe.personid = pbe.personid and current_date between pe.effectivedate and pe.enddate and current_timestamp between pe.createts and pe.endts
				where pbe.benefitsubclass in ('1S') and pbe.selectedoption = 'Y' and pe.emplstatus in ('T','R')
					and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate
					group by 1,2,3 order by 1,7) pbeno on pbeno.personid = pbe.personid and pbeno.rank = 1
                 where pbe.benefitsubclass in ('1S') and pbe.selectedoption = 'Y' and pe.emplstatus in ('T','R')
                        and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate and pbeno.effectivedate <> pbe.effectivedate
                         group by 1,2,3,4,5,6,7 order by 1,11) pbecis on pbecis.personid = pbe.personid and pbecis.rank = 1

-- Double ranked join to check that record previous to the term was elected
left join (select pbe.personid,pbe.benefitelection,pbe.benefitcoverageid,pbe.benefitplanid,pbe.benefitsubclass,pbe.compplanid,pbe.personbeneelectionpid,max(pbe.createts) as createts,max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate, rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
		from person_bene_election pbe
		left join person_employment pe on pe.personid = pbe.personid and current_date between pe.effectivedate and pe.enddate and current_timestamp between pe.createts and pe.endts
		left join (select pbe.personid,pbe.benefitelection,pbe.benefitcoverageid,max(pbe.createts) as createts,max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate, rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
				from person_bene_election pbe
				left join person_employment pe on pe.personid = pbe.personid and current_date between pe.effectivedate and pe.enddate and current_timestamp between pe.createts and pe.endts
				where pbe.benefitsubclass in ('1I') and pbe.selectedoption = 'Y' and pe.emplstatus in ('T','R')
					and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate
					group by 1,2,3 order by 1,7) pbeno on pbeno.personid = pbe.personid and pbeno.rank = 1
                 where pbe.benefitsubclass in ('1I') and pbe.selectedoption = 'Y' and pe.emplstatus in ('T','R')
                        and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate and pbeno.effectivedate <> pbe.effectivedate
                         group by 1,2,3,4,5,6,7 order by 1,11) pbehi on pbehi.personid = pbe.personid and pbehi.rank = 1   
              

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
 --,coalesce(pbecis.benefitsubclass,'N') as s_benefitsubclass
 --,coalesce(pbecic.benefitsubclass,'N') as c_benefitsubclass
 ,case when pbecis.benefitelection = 'E' then pbecis.benefitsubclass else 'N' end as s_benefitsubclass
 ,case when pbecic.benefitelection = 'E' then pbecic.benefitsubclass else 'N' end as c_benefitsubclass
  from person_bene_election pbe 
     
-- Double ranked join to check that record previous to the term was elected
left join (select pbe.personid,pbe.benefitelection,pbe.benefitcoverageid,pbe.benefitplanid,pbe.benefitsubclass,pbe.compplanid,pbe.personbeneelectionpid,max(pbe.createts) as createts,max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate, rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
		from person_bene_election pbe
		left join person_employment pe on pe.personid = pbe.personid and current_date between pe.effectivedate and pe.enddate and current_timestamp between pe.createts and pe.endts
		left join (select pbe.personid,pbe.benefitelection,pbe.benefitcoverageid,max(pbe.createts) as createts,max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate, rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
				from person_bene_election pbe
				left join person_employment pe on pe.personid = pbe.personid and current_date between pe.effectivedate and pe.enddate and current_timestamp between pe.createts and pe.endts
				where pbe.benefitsubclass in ('1W') and pbe.selectedoption = 'Y' and pe.emplstatus in ('T','R')
					and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate
					group by 1,2,3 order by 1,7) pbeno on pbeno.personid = pbe.personid and pbeno.rank = 1
                 where pbe.benefitsubclass in ('1W') and pbe.selectedoption = 'Y' and pe.emplstatus in ('T','R')
                        and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate and pbeno.effectivedate <> pbe.effectivedate
                         group by 1,2,3,4,5,6,7 order by 1,11) pbecie on pbecie.personid = pbe.personid and pbecie.rank = 1

-- Double ranked join to check that record previous to the term was elected
left join (select pbe.personid,pbe.benefitelection,pbe.benefitcoverageid,pbe.benefitplanid,pbe.benefitsubclass,pbe.compplanid,pbe.personbeneelectionpid,max(pbe.createts) as createts,max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate, rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
		from person_bene_election pbe
		left join person_employment pe on pe.personid = pbe.personid and current_date between pe.effectivedate and pe.enddate and current_timestamp between pe.createts and pe.endts
		left join (select pbe.personid,pbe.benefitelection,pbe.benefitcoverageid,max(pbe.createts) as createts,max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate, rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
				from person_bene_election pbe
				left join person_employment pe on pe.personid = pbe.personid and current_date between pe.effectivedate and pe.enddate and current_timestamp between pe.createts and pe.endts
				where pbe.benefitsubclass in ('1S') and pbe.selectedoption = 'Y' and pe.emplstatus in ('T','R')
					and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate
					group by 1,2,3 order by 1,7) pbeno on pbeno.personid = pbe.personid and pbeno.rank = 1
                 where pbe.benefitsubclass in ('1S') and pbe.selectedoption = 'Y' and pe.emplstatus in ('T','R')
                        and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate and pbeno.effectivedate <> pbe.effectivedate
                         group by 1,2,3,4,5,6,7 order by 1,11) pbecis on pbecis.personid = pbe.personid and pbecis.rank = 1

-- Double ranked join to check that record previous to the term was elected
left join (select pbe.personid,pbe.benefitelection,pbe.benefitcoverageid,pbe.benefitplanid,pbe.benefitsubclass,pbe.compplanid,pbe.personbeneelectionpid,max(pbe.createts) as createts,max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate, rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
		from person_bene_election pbe
		left join person_employment pe on pe.personid = pbe.personid and current_date between pe.effectivedate and pe.enddate and current_timestamp between pe.createts and pe.endts
		left join (select pbe.personid,pbe.benefitelection,pbe.benefitcoverageid,max(pbe.createts) as createts,max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate, rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
				from person_bene_election pbe
				left join person_employment pe on pe.personid = pbe.personid and current_date between pe.effectivedate and pe.enddate and current_timestamp between pe.createts and pe.endts
				where pbe.benefitsubclass in ('1C') and pbe.selectedoption = 'Y' and pe.emplstatus in ('T','R')
					and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate
					group by 1,2,3 order by 1,7) pbeno on pbeno.personid = pbe.personid and pbeno.rank = 1
                 where pbe.benefitsubclass in ('1C') and pbe.selectedoption = 'Y' and pe.emplstatus in ('T','R')
                        and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate and pbeno.effectivedate <> pbe.effectivedate
                         group by 1,2,3,4,5,6,7 order by 1,11) pbecic on pbecic.personid = pbe.personid and pbecic.rank = 1

where current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate
  and pbe.benefitsubclass in ('1W','1S','1C') and (pbecie.benefitelection = 'E' or pbecis.benefitelection = 'E' or pbecic.benefitelection = 'E')          
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

left join person_dependent_relationship pdr
  on pdr.personid = pbe.personid
 and pdr.dependentrelationship in ('SP','DP','NA')
 and current_date between pdr.effectivedate and pdr.enddate
 and current_timestamp between pdr.createts and pdr.endts
 
-----------------------------------------------------------------------
-- Dependent Enrollment Joins --
-- Accident --
left join dependent_enrollment de13
  on de13.dependentid = pdr.dependentid
 and de13.benefitsubclass = pbeac.benefitsubclass
 and de13.personid = pi.personid
 and de13.selectedoption = 'Y'
 and de13.effectivedate < de13.enddate
 and (?::DATE  <= de13.enddate or (pbe.effectivedate - interval '1 day' = de13.enddate))
 --and elu.lastupdatets <= de13.enddate
 and current_timestamp between de13.createts and de13.endts  

-- High Indemnity --
left join dependent_enrollment dehi
  on dehi.dependentid = pdr.dependentid
 and dehi.benefitsubclass = pbehi.benefitsubclass
 and dehi.personid = pi.personid
 and dehi.selectedoption = 'Y'
 and dehi.effectivedate < dehi.enddate
 and (?::DATE  <= dehi.enddate or (pbe.effectivedate - interval '1 day' = dehi.enddate))
 --and elu.lastupdatets <= dehi.enddate
 and current_timestamp between dehi.createts and dehi.endts 

------------------------------------------------------------------------

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
  and (pbeac.benefitelection = 'E' or pbecis.benefitelection = 'E' or pbehi.benefitelection = 'E')
  and (pe.effectivedate >= ?::DATE 
   or (pe.createts > ?::DATE and pe.effectivedate < coalesce(?::date, '2017-01-01')) )

-- Ensures only enrolled (elected or waived with prior elected) dependent coverages are selected
  and ((bcdac.benefitcoveragedesc in ('Family', 'Employee + Spouse'))
   or  (bcdhi.benefitcoveragedesc in ('Family', 'Employee + Spouse'))
   or  (tier.cicvgtier in ('FAMILY', 'EMPLOYEE + SPOUSE')))

---------------------------------------------------------------------------------------------------------------------------------------------------       
   UNION
---------------------------------------------------------------------------------------------------------------------------------------------------

--------------------
-- TERMED DEP --
--------------------

select
 pi.personid
,case when bcdac.benefitcoveragedesc in ('Employee + Children','Family') then bcdac.benefitcoveragedesc else null end as accvgtier
,case when tier.cicvgtier in ('EMPLOYEE + CHILD(REN)','FAMILY') then tier.cicvgtier else null end 
,case when bcdhi.benefitcoveragedesc in ('Employee + Children','Family') then bcdhi.benefitcoveragedesc else null end as hicvgtier
,'0 TERMED DP' ::varchar(30) as qsource 
,3 AS SORTSEQ 
,left(pi.identity,3)||'-'||substring(pi.identity,4,2)||'-'||right(pi.identity,4) ::char(11) as essn
,'CHILD' ::varchar(15) as relation
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
,'Term' ::char(4) as status_chg -- col v 
,to_char(greatest(pbeac.effectivedate,pbecic.effectivedate,pbehi.effectivedate),'mm/dd/yyyy')::char(10) as edoc
,null as comp_state_question
----------------------------------------
----- accident (13)                -----
----------------------------------------
,case when de13.selectedoption = 'Y' and pbeac.benefitelection = 'E' then 'Accident' else null end ::varchar(30) as ae_plan_type
,case when de13.selectedoption = 'Y' and pbeac.benefitelection = 'E' and bcdac.benefitcoveragedesc in ('EE','Employee Only','Employee') then 'EMPLOYEE'
      when de13.selectedoption = 'Y' and pbeac.benefitelection = 'E' and bcdac.benefitcoveragedesc = 'Employee + Spouse' then 'EMPLOYEE + SPOUSE'
      when de13.selectedoption = 'Y' and pbeac.benefitelection = 'E' and bcdac.benefitcoveragedesc = 'Family' then 'EMPLOYEE + FAMILY'
      when de13.selectedoption = 'Y' and pbeac.benefitelection = 'E' and bcdac.benefitcoveragedesc in ('Employee + Children') then 'EMPLOYEE + CHILD(REN)'
      else null end ::varchar(30) as ae_insured_option
,case when de13.selectedoption = 'Y' and pbeac.benefitelection = 'E' then cast(pocac.employeerate::numeric as dec(18,2)) else null end as ae_prem_amt    
,case when de13.selectedoption = 'Y' and pbeac.benefitelection = 'E' then to_char(pbeac.effectivedate,'mm/dd/yyyy')else null end ::char(10) as ae_edoi -- issue date
,case when de13.selectedoption = 'Y' and pbeac.benefitelection = 'E' then to_char(pbeac.createts,'mm/dd/yyyy')else null end ::char(10) as ae_edos -- signed date Debbie said use createts 
,case when de13.selectedoption = 'Y' and pbeac.benefitelection = 'E' and pe.emplstatus in ('T','R') then to_char(pbeac.enddate,'mm/dd/yyyy') else null end ::char(10) as ae_edot
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
,case when pbecic.benefitelection = 'E' then 'Critical Illness' else null end ::varchar(30) as ci_plan_type
,case when pbecic.benefitelection = 'E' then tier.cicvgtier else null end ::varchar(30) as ci_insured_option 
,case when pbecic.benefitelection = 'E' then 5000.00 else null end as ci_bene_amt     
,case when pbecic.benefitelection = 'E' then cast(pocci.employeerate::numeric as dec(18,2)) else null end as ci_prem_amt      
,case when pbecic.benefitelection = 'E' then to_char(pbecic.effectivedate,'mm/dd/yyyy') else null end ::char(10) as ci_edoi -- issue date
,case when pbecic.benefitelection = 'E' then to_char(pbecic.createts,'mm/dd/yyyy') else null end ::char(10) as ci_edos -- signed date Debbie said use createts 
,case when pbecic.benefitelection = 'E' and pe.emplstatus in ('T','R') then to_char(pbecic.enddate,'mm/dd/yyyy') else null end ::char(10) as ci_edot
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
,case when dehi.selectedoption = 'Y' and pbehi.benefitelection = 'E' and pbehi.benefitplanid in ('125','128','131','137','140','146') then 'Hospital Indemnity - Low (A)'
      when dehi.selectedoption = 'Y' and pbehi.benefitelection = 'E' and pbehi.benefitplanid in ('149','155','158','161','164','167') then 'Hospital Indemnity - High (B)'
      else null end ::varchar(30) as hi_plan_type
,case when dehi.selectedoption = 'Y' and pbehi.benefitelection = 'E' and bcdhi.benefitcoveragedesc in ('EE','Employee Only') then 'EMPLOYEE'
      when dehi.selectedoption = 'Y' and pbehi.benefitelection = 'E' and bcdhi.benefitcoveragedesc = 'Employee + Spouse' then 'EMPLOYEE + SPOUSE'
      when dehi.selectedoption = 'Y' and pbehi.benefitelection = 'E' and bcdhi.benefitcoveragedesc = 'Family' then 'EMPLOYEE + FAMILY'
      when dehi.selectedoption = 'Y' and pbehi.benefitelection = 'E' and bcdhi.benefitcoveragedesc in ('Employee + Children') then 'EMPLOYEE + CHILD(REN)'
      else null end ::varchar(30) as hi_insured_option 
,null as hi_benefit_amt
,case when dehi.selectedoption = 'Y' and pbehi.benefitelection = 'E' then cast(pochi.employeerate::numeric as dec(18,2)) else null end as hi_prem_amt         
,case when dehi.selectedoption = 'Y' and pbehi.benefitelection = 'E' then to_char(pbehi.effectivedate,'mm/dd/yyyy')else null end ::char(10) as hi_edoi -- issue date
,case when dehi.selectedoption = 'Y' and pbehi.benefitelection = 'E' then to_char(pbehi.createts,'mm/dd/yyyy')else null end ::char(10) as hi_edos -- signed date Debbie said use createts 
,case when dehi.selectedoption = 'Y' and pbehi.benefitelection = 'E' and pe.emplstatus in ('T','R') then to_char(pbehi.enddate,'mm/dd/yyyy') else null end ::char(10) as hi_edot      
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
,elu.lastupdatets
from person_identity pi

left join edi.edi_last_update elu on elu.feedid = 'DAB_Assurity_CI_HI_Accident_Export'

join person_identity pip
  on pip.personid = pi.personid
 and pip.identitytype = 'PSPID'
 and current_timestamp between pip.createts and pip.endts
 
left join person_employment pe
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
    
left join 
(select personid, benefitplanid,benefitelection,benefitcoverageid, max(createts) as createts,max(effectivedate) as effectivedate, max(enddate) as enddate, rank() over (partition by personid order by max(effectivedate) desc) as rank
 from person_bene_election pbe
 where benefitsubclass in ('1C','1I','13')
 --and benefitelection in ('T')
 and selectedoption = 'Y'
 and effectivedate < enddate
 and current_timestamp between createts and endts
 group by 1,2,3,4) pbe on pbe.personid = pe.personid and pbe.rank = 1

-- Double ranked join to check that record previous to the term was elected
left join (select pbe.personid,pbe.benefitelection,pbe.benefitcoverageid,pbe.benefitplanid,pbe.benefitsubclass,pbe.compplanid,pbe.personbeneelectionpid,max(pbe.createts) as createts,max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate, rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
		from person_bene_election pbe
		left join person_employment pe on pe.personid = pbe.personid and current_date between pe.effectivedate and pe.enddate and current_timestamp between pe.createts and pe.endts
		left join (select pbe.personid,pbe.benefitelection,pbe.benefitcoverageid,max(pbe.createts) as createts,max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate, rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
				from person_bene_election pbe
				left join person_employment pe on pe.personid = pbe.personid and current_date between pe.effectivedate and pe.enddate and current_timestamp between pe.createts and pe.endts
				where pbe.benefitsubclass in ('13') and pbe.selectedoption = 'Y' and pe.emplstatus in ('T','R')
					and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate
					group by 1,2,3 order by 1,7) pbeno on pbeno.personid = pbe.personid and pbeno.rank = 1
                 where pbe.benefitsubclass in ('13') and pbe.selectedoption = 'Y' and pe.emplstatus in ('T','R')
                        and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate and pbeno.effectivedate <> pbe.effectivedate
                         group by 1,2,3,4,5,6,7 order by 1,11) pbeac on pbeac.personid = pbe.personid and pbeac.rank = 1
 
-- Double ranked join to check that record previous to the term was elected
left join (select pbe.personid,pbe.benefitelection,pbe.benefitcoverageid,pbe.benefitplanid,pbe.benefitsubclass,pbe.compplanid,pbe.personbeneelectionpid,max(pbe.createts) as createts,max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate, rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
		from person_bene_election pbe
		left join person_employment pe on pe.personid = pbe.personid and current_date between pe.effectivedate and pe.enddate and current_timestamp between pe.createts and pe.endts
		left join (select pbe.personid,pbe.benefitelection,pbe.benefitcoverageid,max(pbe.createts) as createts,max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate, rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
				from person_bene_election pbe
				left join person_employment pe on pe.personid = pbe.personid and current_date between pe.effectivedate and pe.enddate and current_timestamp between pe.createts and pe.endts
				where pbe.benefitsubclass in ('1C') and pbe.selectedoption = 'Y' and pe.emplstatus in ('T','R')
					and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate
					group by 1,2,3 order by 1,7) pbeno on pbeno.personid = pbe.personid and pbeno.rank = 1
                 where pbe.benefitsubclass in ('1C') and pbe.selectedoption = 'Y' and pe.emplstatus in ('T','R')
                        and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate and pbeno.effectivedate <> pbe.effectivedate
                         group by 1,2,3,4,5,6,7 order by 1,11) pbecic on pbecic.personid = pbe.personid and pbecic.rank = 1

-- Double ranked join to check that record previous to the term was elected
left join (select pbe.personid,pbe.benefitelection,pbe.benefitcoverageid,pbe.benefitplanid,pbe.benefitsubclass,pbe.compplanid,pbe.personbeneelectionpid,max(pbe.createts) as createts,max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate, rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
		from person_bene_election pbe
		left join person_employment pe on pe.personid = pbe.personid and current_date between pe.effectivedate and pe.enddate and current_timestamp between pe.createts and pe.endts
		left join (select pbe.personid,pbe.benefitelection,pbe.benefitcoverageid,max(pbe.createts) as createts,max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate, rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
				from person_bene_election pbe
				left join person_employment pe on pe.personid = pbe.personid and current_date between pe.effectivedate and pe.enddate and current_timestamp between pe.createts and pe.endts
				where pbe.benefitsubclass in ('1I') and pbe.selectedoption = 'Y' and pe.emplstatus in ('T','R')
					and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate
					group by 1,2,3 order by 1,7) pbeno on pbeno.personid = pbe.personid and pbeno.rank = 1
                 where pbe.benefitsubclass in ('1I') and pbe.selectedoption = 'Y' and pe.emplstatus in ('T','R')
                        and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate and pbeno.effectivedate <> pbe.effectivedate
                         group by 1,2,3,4,5,6,7 order by 1,11) pbehi on pbehi.personid = pbe.personid and pbehi.rank = 1  
                 

left join personbenoptioncostl pocac
  on pocac.personid = pbeac.personid
 and pocac.benefitelection = 'E'
 and pocac.personbeneelectionpid = pbeac.personbeneelectionpid
 and pocac.costsby = 'P'
left join personbenoptioncostl pocci
  on pocci.personid = pbecic.personid
 and pocci.benefitelection = 'E'
 and pocci.personbeneelectionpid = pbecic.personbeneelectionpid
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
 ,case when pbecis.benefitelection = 'E' then pbecis.benefitsubclass else 'N' end as s_benefitsubclass
 ,case when pbecic.benefitelection = 'E' then pbecic.benefitsubclass else 'N' end as c_benefitsubclass
  from person_bene_election pbe 
     
-- Double ranked join to check that record previous to the term was elected
left join (select pbe.personid,pbe.benefitelection,pbe.benefitcoverageid,pbe.benefitplanid,pbe.benefitsubclass,pbe.compplanid,pbe.personbeneelectionpid,max(pbe.createts) as createts,max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate, rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
		from person_bene_election pbe
		left join person_employment pe on pe.personid = pbe.personid and current_date between pe.effectivedate and pe.enddate and current_timestamp between pe.createts and pe.endts
		left join (select pbe.personid,pbe.benefitelection,pbe.benefitcoverageid,max(pbe.createts) as createts,max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate, rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
				from person_bene_election pbe
				left join person_employment pe on pe.personid = pbe.personid and current_date between pe.effectivedate and pe.enddate and current_timestamp between pe.createts and pe.endts
				where pbe.benefitsubclass in ('1W') and pbe.selectedoption = 'Y' and pe.emplstatus in ('T','R')
					and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate
					group by 1,2,3 order by 1,7) pbeno on pbeno.personid = pbe.personid and pbeno.rank = 1
                 where pbe.benefitsubclass in ('1W') and pbe.selectedoption = 'Y' and pe.emplstatus in ('T','R')
                        and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate and pbeno.effectivedate <> pbe.effectivedate
                         group by 1,2,3,4,5,6,7 order by 1,11) pbecie on pbecie.personid = pbe.personid and pbecie.rank = 1

-- Double ranked join to check that record previous to the term was elected
left join (select pbe.personid,pbe.benefitelection,pbe.benefitcoverageid,pbe.benefitplanid,pbe.benefitsubclass,pbe.compplanid,pbe.personbeneelectionpid,max(pbe.createts) as createts,max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate, rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
		from person_bene_election pbe
		left join person_employment pe on pe.personid = pbe.personid and current_date between pe.effectivedate and pe.enddate and current_timestamp between pe.createts and pe.endts
		left join (select pbe.personid,pbe.benefitelection,pbe.benefitcoverageid,max(pbe.createts) as createts,max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate, rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
				from person_bene_election pbe
				left join person_employment pe on pe.personid = pbe.personid and current_date between pe.effectivedate and pe.enddate and current_timestamp between pe.createts and pe.endts
				where pbe.benefitsubclass in ('1S') and pbe.selectedoption = 'Y' and pe.emplstatus in ('T','R')
					and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate
					group by 1,2,3 order by 1,7) pbeno on pbeno.personid = pbe.personid and pbeno.rank = 1
                 where pbe.benefitsubclass in ('1S') and pbe.selectedoption = 'Y' and pe.emplstatus in ('T','R')
                        and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate and pbeno.effectivedate <> pbe.effectivedate
                         group by 1,2,3,4,5,6,7 order by 1,11) pbecis on pbecis.personid = pbe.personid and pbecis.rank = 1

-- Double ranked join to check that record previous to the term was elected
left join (select pbe.personid,pbe.benefitelection,pbe.benefitcoverageid,pbe.benefitplanid,pbe.benefitsubclass,pbe.compplanid,pbe.personbeneelectionpid,max(pbe.createts) as createts,max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate, rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
		from person_bene_election pbe
		left join person_employment pe on pe.personid = pbe.personid and current_date between pe.effectivedate and pe.enddate and current_timestamp between pe.createts and pe.endts
		left join (select pbe.personid,pbe.benefitelection,pbe.benefitcoverageid,max(pbe.createts) as createts,max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate, rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
				from person_bene_election pbe
				left join person_employment pe on pe.personid = pbe.personid and current_date between pe.effectivedate and pe.enddate and current_timestamp between pe.createts and pe.endts
				where pbe.benefitsubclass in ('1C') and pbe.selectedoption = 'Y' and pe.emplstatus in ('T','R')
					and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate
					group by 1,2,3 order by 1,7) pbeno on pbeno.personid = pbe.personid and pbeno.rank = 1
                 where pbe.benefitsubclass in ('1C') and pbe.selectedoption = 'Y' and pe.emplstatus in ('T','R')
                        and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate and pbeno.effectivedate <> pbe.effectivedate
                         group by 1,2,3,4,5,6,7 order by 1,11) pbecic on pbecic.personid = pbe.personid and pbecic.rank = 1

where current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate
  and pbe.benefitsubclass in ('1W','1S','1C') and (pbecie.benefitelection = 'E' or pbecis.benefitelection = 'E' or pbecic.benefitelection = 'E')
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

left join person_dependent_relationship pdr
  on pdr.personid = pbe.personid
 and pdr.dependentrelationship in ('S','D','C','ND','NS','NC','FC','QC')
 and current_date between pdr.effectivedate and pdr.enddate
 and current_timestamp between pdr.createts and pdr.endts
-----------------------------------------------------------------------
-- Dependent Enrollment Joins --
-- Accident --
left join dependent_enrollment de13
  on de13.dependentid = pdr.dependentid
 and de13.benefitsubclass = pbeac.benefitsubclass
 and de13.personid = pi.personid
 and de13.selectedoption = 'Y'
 and de13.effectivedate < de13.enddate
 and (?::DATE  <= de13.enddate or (pbe.effectivedate - interval '1 day' = de13.enddate))
 --and elu.lastupdatets <= de13.enddate
 and current_timestamp between de13.createts and de13.endts  

-- High Indemnity --
left join dependent_enrollment dehi
  on dehi.dependentid = pdr.dependentid
 and dehi.benefitsubclass = pbehi.benefitsubclass
 and dehi.personid = pi.personid
 and dehi.selectedoption = 'Y'
 and dehi.effectivedate < dehi.enddate
 and (?::DATE  <= dehi.enddate or (pbe.effectivedate - interval '1 day' = dehi.enddate))
 --and elu.lastupdatets <= dehi.enddate
 and current_timestamp between dehi.createts and dehi.endts 

------------------------------------------------------------------------
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
  and (pbeac.benefitelection = 'E' or pbecic.benefitelection = 'E' or pbehi.benefitelection = 'E')
  and (pe.effectivedate >= ?::DATE 
   or (pe.createts > ?::DATE  and pe.effectivedate < coalesce(?::date, '2017-01-01')) )

-- Ensures only enrolled (elected or waived with prior elected) dependent coverages are selected
  and ((bcdac.benefitcoveragedesc in ('Family', 'Employee + Children'))
   or   (bcdhi.benefitcoveragedesc in ('Family', 'Employee + Children'))
   or   (tier.cicvgtier in ('FAMILY', 'EMPLOYEE + CHILD(REN)')))
      

order by personid, sortseq