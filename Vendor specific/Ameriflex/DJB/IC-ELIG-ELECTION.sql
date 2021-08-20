--Active employees
SELECT
PI.PERSONID
,'IC' :: char(2) as record_ID
,'AMF001' :: char(6) as TPA_ID
,lookup.GroupCode :: char(9) as Group_Code	--update value by client in lookup table
,lookup.PlanID :: char(10) as Plan_ID				--update value by client in lookup table
,replace(pi2.identity ,'-','') :: char(9) as emp_ssn

,case when pbe.benefitsubclass in ('60','62') then 'FSA'
      when pbe.benefitsubclass in ('61','63') then 'DCA'
      when pbe.benefitsubclass in ('6A','6AP') then 'TRN'
      when pbe.benefitsubclass in ('6B','6BP') then 'PKG'
      WHEN pbe.benefitsubclass in ('67','6H','6J','6Y','6Z') THEN 'UMB'
      WHEN pbe.benefitsubclass in ('1Y') THEN 'HRA'
end :: char(3) as Account_Type

,to_char(coalesce(lookup.plan_year_start_date,cppy.planyearstart),'YYYYMMDD') :: char(8) as Plan_Year_Start_date
,to_char(coalesce(lookup.plan_year_end_date,cppy.planyearend),'YYYYMMDD') :: char(8) as  Plan_Year_End_date

,CASE WHEN pbe.benefitsubclass in ('60','62') and pbe.benefitelection = 'E' then 'A'
      WHEN pbe.benefitsubclass in ('61','63') and pbe.benefitelection = 'E' then 'A'
      WHEN pbe.benefitsubclass in ('6A','6AP') and pbe.benefitelection = 'E' then 'A'
      WHEN pbe.benefitsubclass in ('6B','6BP') and pbe.benefitelection = 'E' then 'A'
      WHEN pbe.benefitsubclass in ('67','6H','6J','6Y','6Z')and pbe.benefitelection = 'E' then 'A'
      WHEN pbe.benefitsubclass in ('1Y')and pbe.benefitelection = 'E' then 'A'
      WHEN pbe.benefitsubclass in ('60','62') and pbe.benefitelection in ('T','R','I','D') then 'T'
      WHEN pbe.benefitsubclass in ('61','63') and pbe.benefitelection in ('T','R','I','D') then 'T'
      WHEN pbe.benefitsubclass in ('6A','6AP') and pbe.benefitelection in ('T','R','I','D') then 'T'
      WHEN pbe.benefitsubclass in ('6B','6BP') and pbe.benefitelection in ('T','R','I','D') then 'T'
      WHEN pbe.benefitsubclass in ('67','6H','6J','6Y','6Z') and pbe.benefitelection in ('T','R','I','D') then 'T'
      WHEN pbe.benefitsubclass in ('1Y') and pbe.benefitelection in ('T','R','I','D') then 'T'
 end :: char(1) as Account_Status


,(pbe.coverageamount) :: decimal(18,2) as Goal_Amount
        
,case when pbe.PayFrequencyCode = 'B' then (((pbe.MonthlyAmount)*12)/26)
      when pbe.PayFrequencyCode = 'S' then (((pbe.MonthlyAmount)*12)/24)
      when pbe.PayFrequencyCode = 'M' then (((pbe.MonthlyAmount)*12)/12)
      when pbe.PayFrequencyCode = 'W' then (((pbe.MonthlyAmount)*12)/52)       
end :: decimal(18,2) as Per_Pay_Amount 

,case when pbe.PayFrequencyCode = 'B' then (((pbe.MonthlyEmployerAmount)*12)/26)
      when pbe.PayFrequencyCode = 'S' then (((pbe.MonthlyEmployerAmount)*12)/24)
      when pbe.PayFrequencyCode = 'M' then (((pbe.MonthlyEmployerAmount)*12)/12)
      when pbe.PayFrequencyCode = 'W' then (((pbe.MonthlyEmployerAmount)*12)/52)       
end :: decimal(18,2) as ER_Per_Pay_Amount

,to_char(greatest(coalesce(lookup.plan_year_start_date,cppy.planyearstart),pbe.effectivedate),'YYYYMMDD'):: char(8) as Effective_date

,null :: char(8) as term_Date
,null :: char(8) as Deposit_Start_Date
,null :: char(18) as Calendar_ID
,null :: char(1) as Add_All_Dependents


--Control Report Values --
,pie.identity ::varchar(15) as cr_empno
,rtrim(ltrim(replace(pn.lname,',',' '))) :: char(26) as emp_last_name
,rtrim(ltrim(replace(pn.fname,',',' '))) :: char(19) as emp_first_name
,rtrim(ltrim(substring(pn.mname,1,1))) :: char(1) as emp_middle_intial

from person_identity pi

left join person_identity pie on pie.personid = pi.personid
and current_timestamp between pie.createts and pie.endts
and pie.identitytype = 'EmpNo'

LEFT JOIN person_names pn 
  ON pn.personid = pi.personid 
 AND pn.nametype = 'Legal'::bpchar 
 and (current_date between pn.effectivedate and pn.enddate
	or (pn.effectivedate > current_date
	    and pn.effectivedate < pn.enddate))
and current_timestamp between pn.createts and pn.endts

--- mlc 12/22/2020 - added value3 and value4 
LEFT JOIN (select lp.lookupid, value1 as GroupCode, value2 as PlanID, lp.VALUE3 ::date as plan_year_start_date, lp.VALUE4 ::date as plan_year_end_date
from edi.lookup lp
join edi.lookup_schema els on lp.lookupid = els.lookupid and els.lookupname = 'Ameriflex_FLEX_Eligibility_Election' 
and current_date between lp.effectivedate and lp.enddate
 )lookup on lookup.lookupid is not null


LEFT JOIN person_identity pi2 
ON pi.personid = pi2.personid
AND pi2.identitytype = 'SSN' ::bpchar 
AND CURRENT_TIMESTAMP BETWEEN pi2.createts and pi2.endts 


left join public.person_employment pe
  on pe.personid = pi.personid 
 and current_date between pe.effectivedate and pe.enddate
and current_timestamp between pe.createts and pe.endts 

--fsa, dep fsa
left JOIN person_bene_election pbe 
  ON pbe.personid = pI.personid
  and pbe.selectedoption = 'Y' 
  and pbe.benefitsubclass in ('60','62','61','63','6A','6AP','6B','6BP','67','6H','6J','6Y','6Z','1Y' )
and pbe.coverageamount > 0 --
AND pbe.benefitelection IN ('E')
 AND (current_date BETWEEN pbe.effectivedate AND pbe.enddate 
 or (pbe.effectivedate > current_date
    and pbe.effectivedate < pbe.enddate))
 AND current_timestamp BETWEEN pbe.createts AND pbe.endts
 
 
/* mlc changed this to match ib join - missing future dated and retained waived using this join.
JOIN person_bene_election pbe 
  ON pbe.personid = pI.personid
  and pbe.selectedoption = 'Y' 
  and pbe.benefitsubclass in ('60','62','61','63', '6A','6AP','6B','6BP','67','6H','6J','6Y','6Z','1Y')
  and pbe.coverageamount > 0 --
AND pbe.benefitelection IN ('E')
 AND current_date BETWEEN pbe.effectivedate AND pbe.enddate 
 AND current_timestamp BETWEEN pbe.createts AND pbe.endts
*/

 
LEFT JOIN personbenoptioncostl poc 
  ON poc.personid              = pbe.personid
 AND poc.personbeneelectionpid = pbe.personbeneelectionpid
 AND poc.costsby = 'P'
 AND poc.employeerate > 0

join benefit_plan_desc bpd
  on bpd.benefitsubclass = pbe.benefitsubclass
 and current_date between bpd.effectivedate and bpd.enddate
 and current_timestamp between bpd.createts and bpd.endts

 left join Comp_plan_plan_year cppy
 on pbe.compplanid = cppy.compplanid
 and cppy.compplanplanyeartype = 'Bene'
 and current_date between cppy.planyearstart and cppy.planyearend


WHERE pi.identitytype = 'PSPID'
  and pbe.benefitsubclass in ('60','62','61','63', '6A','6AP','6B','6BP','67','6H','6J','6Y','6Z','1Y' )
  and current_timestamp between pi.createts and pi.endts
    --and pbe.effectivedate between cppy.planyearstart and cppy.planyearend -- mlc 12/20/2020 changed to use plan year start and end dates from lookup table.
    and pbe.effectivedate between lookup.plan_year_start_date and lookup.plan_year_end_date
    and pbe.benefitplanid = bpd.benefitplanid
  and pbe.benefitelection IN ('E')

------------------------------------------------------------------------------------------------------------------------------------------------
union
------------------------------------------------------------------------------------------------------------------------------------------------

--termed employees
SELECT
PI.PERSONID
,'IC' :: char(2) as record_ID
,'AMF001' :: char(6) as TPA_ID
,lookup.GroupCode :: char(9) as Group_Code	--update value by client in lookup table
,lookup.PlanID :: char(10) as Plan_ID				--update value by client in lookup table
,replace(pi2.identity ,'-','') :: char(9) as emp_ssn

,case when pbet.benefitsubclass in ('60','62') then 'FSA'
      when pbet.benefitsubclass in ('61','63') then 'DCA'
      when pbet.benefitsubclass in ('6A','6AP') then 'TRN'
      when pbet.benefitsubclass in ('6B','6BP') then 'PKG'
      WHEN pbet.benefitsubclass in ('67','6H','6J','6Y','6Z') THEN 'UMB'
      WHEN pbet.benefitsubclass in ('1Y') THEN 'HRA'
end :: char(3) as Account_Type

,to_char(coalesce(lookup.plan_year_start_date,cppy.planyearstart),'YYYYMMDD') :: char(8) as Plan_Year_Start_date
,to_char(coalesce(lookup.plan_year_end_date,cppy.planyearend),'YYYYMMDD') :: char(8) as  Plan_Year_End_date

,CASE WHEN pbet.benefitsubclass in ('60','62') and pbet.benefitelection = 'E' then 'A'
      WHEN pbet.benefitsubclass in ('61','63') and pbet.benefitelection = 'E' then 'A'
      WHEN pbet.benefitsubclass in ('6A','6AP') and pbet.benefitelection = 'E' then 'A'
      WHEN pbet.benefitsubclass in ('6B','6BP') and pbet.benefitelection = 'E' then 'A'
      WHEN pbet.benefitsubclass in ('67','6H','6J','6Y','6Z')and pbet.benefitelection = 'E' then 'A'
      WHEN pbet.benefitsubclass in ('1Y')and pbet.benefitelection = 'E' then 'A'
      WHEN pbet.benefitsubclass in ('60','62') and pbet.benefitelection in ('T','R','I','D') then 'T'
      WHEN pbet.benefitsubclass in ('61','63') and pbet.benefitelection in ('T','R','I','D') then 'T'
      WHEN pbet.benefitsubclass in ('6A','6AP') and pbet.benefitelection in ('T','R','I','D') then 'T'
      WHEN pbet.benefitsubclass in ('6B','6BP') and pbet.benefitelection in ('T','R','I','D') then 'T'
      WHEN pbet.benefitsubclass in ('67','6H','6J','6Y','6Z')and pbet.benefitelection in ('T','R','I','D') then 'T'
      WHEN pbet.benefitsubclass in ('1Y') and pbet.benefitelection in ('T','R','I','D') then 'T'
     -- else null
 end :: char(1) as Account_Status


,(pbet.coverageamount) :: decimal(18,2) as Goal_Amount
        
,case when pbeterm.PayFrequencyCode = 'B' then (((pbeterm.MonthlyAmount)*12)/26)
      when pbeterm.PayFrequencyCode = 'S' then (((pbeterm.MonthlyAmount)*12)/24)
      when pbeterm.PayFrequencyCode = 'M' then (((pbeterm.MonthlyAmount)*12)/12)
      when pbeterm.PayFrequencyCode = 'W' then (((pbeterm.MonthlyAmount)*12)/52)  
	  else pbeterm.MonthlyAmount     
end :: decimal(18,2) as Per_Pay_Amount

,case when pbeterm.PayFrequencyCode = 'B' then (((pbeterm.MonthlyEmployerAmount)*12)/26)
      when pbeterm.PayFrequencyCode = 'S' then (((pbeterm.MonthlyEmployerAmount)*12)/24)
      when pbeterm.PayFrequencyCode = 'M' then (((pbeterm.MonthlyEmployerAmount)*12)/12)
      when pbeterm.PayFrequencyCode = 'W' then (((pbeterm.MonthlyEmployerAmount)*12)/52)       
end :: decimal(18,2) as ER_Per_Pay_Amount 

,to_char(greatest(coalesce(lookup.plan_year_start_date,cppy.planyearstart),pbeterm.effectivedate),'YYYYMMDD'):: char(8) as Effective_date
,to_char(pe.effectivedate,'YYYYMMDD'):: char(8) as term_date
,null :: char(8) as Deposit_Start_Date
,null :: char(18) as Calendar_ID
,null :: char(1) as Add_All_Dependents


--Control Report Values --
,pie.identity ::varchar(15) as cr_empno
,rtrim(ltrim(replace(pn.lname,',',' '))) :: char(26) as emp_last_name
,rtrim(ltrim(replace(pn.fname,',',' '))) :: char(19) as emp_first_name
,rtrim(ltrim(substring(pn.mname,1,1))) :: char(1) as emp_middle_intial


from person_identity pi

left join person_identity pie on pie.personid = pi.personid
and current_timestamp between pie.createts and pie.endts
and pie.identitytype = 'EmpNo'

LEFT JOIN person_names pn 
  ON pn.personid = pi.personid 
 AND pn.nametype = 'Legal'::bpchar 
 and (current_date between pn.effectivedate and pn.enddate
	or (pn.effectivedate > current_date
	    and pn.effectivedate < pn.enddate))
and current_timestamp between pn.createts and pn.endts

--- mlc 12/22/2020 - added value3 and value4 
LEFT JOIN (select lp.lookupid, value1 as GroupCode, value2 as PlanID, lp.VALUE3 ::date as plan_year_start_date, lp.VALUE4 ::date as plan_year_end_date
from edi.lookup lp
join edi.lookup_schema els on lp.lookupid = els.lookupid and els.lookupname = 'Ameriflex_FLEX_Eligibility_Election' 
and current_date between lp.effectivedate and lp.enddate
 )lookup on lookup.lookupid is not null

LEFT JOIN person_identity pi2 
ON pi.personid = pi2.personid
AND pi2.identitytype = 'SSN' ::bpchar 
AND CURRENT_TIMESTAMP BETWEEN pi2.createts and pi2.endts 

LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'Ameriflex_FLEX_Eligibility_Election'

left join public.person_employment pe
  on pe.personid = pi.personid 
 and current_date between pe.effectivedate and pe.enddate
and current_timestamp between pe.createts and pe.endts 

left JOIN person_bene_election pbet  
  ON pbet.personid = pI.personid
  and pbet.selectedoption = 'Y' 
 AND pbet.benefitsubclass in ('60','62','61','63','6A','6AP','6B','6BP','67','6H','6J','6Y','6Z','1Y' )
 AND pbet.benefitelection in ('T','R')  
 --and pbet.coverageamount > 0 --
 AND current_date BETWEEN pbet.effectivedate AND pbet.enddate 
 AND current_timestamp BETWEEN pbet.createts AND pbet.endts

and pbet.personid in (select personid from person_bene_election pbe
                join comp_plan_plan_year cppy on pbe.compplanid = cppy.compplanid and cppy.compplanplanyeartype = 'Bene'
                 where pbe.benefitsubclass in ('60','62','61','63','6A','6AP','6B','6BP','67','6H','6J','6Y','6Z','1Y' ) and pbe.benefitelection = 'E' and pbe.selectedoption = 'Y' 
                        and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate
                        AND ((pbe.effectivedate, pbe.enddate) overlaps (cppy.planyearstart, cppy.planyearend) OR cppy.planyearstart IS NULL))
and pe.effectivedate - interval '1 day' < pbet.effectivedate

/*
 and pbet.personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts 
                         and benefitsubclass in ('60','62','61','63','6A','6AP','6B','6BP','67','6H','6J','6Y','6Z','1Y') 
                         and benefitelection = 'E' and selectedoption = 'Y'
                          and enddate < pbet.effectivedate
                          ) 
 */                     
join (select personid, effectivedate, enddate,createts, monthlyamount,PayFrequencyCode,MonthlyEmployerAmount from person_bene_election pbe1 where current_timestamp between pbe1.createts and pbe1.endts 
                         and pbe1.benefitsubclass in ('60','62','61','63','6A','6AP','6B','6BP','67','6H','6J','6Y','6Z','1Y' )
                          and pbe1.benefitelection = 'E' and pbe1.selectedoption = 'Y'
                          and pbe1.enddate >=  pbe1.effectivedate
      ) as pbeterm on pbeterm.personid = pi.personid and pbeterm.enddate = pbet.effectivedate - interval '1 day'


 left join Comp_plan_plan_year cppy
 on pbet.compplanid = cppy.compplanid
 and cppy.compplanplanyeartype = 'Bene'
 and current_date between cppy.planyearstart and cppy.planyearend
 
LEFT JOIN personbenoptioncostl poc 
  ON poc.personid              = pbet.personid
 AND poc.personbeneelectionpid = pbet.personbeneelectionpid
 AND poc.costsby = 'P'
 AND poc.employeerate > 0

join benefit_plan_desc bpd
  on bpd.benefitsubclass = pbet.benefitsubclass
 and current_date between bpd.effectivedate and bpd.enddate
 and current_timestamp between bpd.createts and bpd.endts
 
		
WHERE pi.identitytype = 'PSPID'
  and pbet.benefitsubclass in ('60','62','61','63','6A','6AP','6B','6BP','67','6H','6J','6Y','6Z','1Y' )
  and current_timestamp between pi.createts and pi.endts
 -- and pbet.effectivedate < pbet.enddate
  and pbet.benefitplanid = bpd.benefitplanid
  --and pbeterm.effectivedate between cppy.planyearstart and cppy.planyearend -- mlc 12/20/2020 changed to use plan year start and end dates from lookup table.
  and pbeterm.effectivedate between lookup.plan_year_start_date and lookup.plan_year_end_date
  and pbet.benefitelection in ('T','R')
  and (pbet.effectivedate >= elu.lastupdatets::DATE 
   or (pbet.createts > elu.lastupdatets and pbet.effectivedate < coalesce(elu.lastupdatets, '2017-01-01')))

order by emp_ssn,Account_Type