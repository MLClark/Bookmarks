--Active employees
SELECT distinct
PI.PERSONID
,'IB' :: char(2) as record_ID
,'AMF001' :: char(6) as TPA_ID
,lookup.GroupCode :: char(9) as Group_Code
,replace(pi2.identity ,'-','') :: char(9) as emp_ssn
,substring(pn.title,1,5) :: char(5) as Prefix
,rtrim(ltrim(replace(pn.lname,',',' '))) :: char(26) as emp_last_name
,rtrim(ltrim(replace(pn.fname,',',' '))) :: char(19) as emp_first_name
,rtrim(ltrim(substring(pn.mname,1,1))) :: char(1) as emp_middle_intial

,coalesce (
	    '('||substring(ppch.phoneno,1,3)||')'||substring(ppch.phoneno,4,3)||'-'||substring(ppch.phoneno,7,4), 
	    '('||substring(ppcm.phoneno,1,3)||')'||substring(ppcm.phoneno,4,3)||'-'||substring(ppcm.phoneno,7,4),
	    '('||substring(ppcw.phoneno,1,3)||')'||substring(ppcw.phoneno,4,3)||'-'||substring(ppcw.phoneno,7,4),
	    '('||substring(ppcb.phoneno,1,3)||')'||substring(ppcb.phoneno,4,3)||'-'||substring(ppcb.phoneno,7,4)
          ):: char(19) as phone

,rtrim(ltrim(replace(pa.streetaddress,',',' '))) :: char(36) as emp_address1
,rtrim(ltrim(replace(pa.streetaddress2,',',' '))) :: char(36) as emp_address2
,rtrim(ltrim(pa.city)) ::char(20) as emp_city
,rtrim(ltrim(pa.stateprovincecode)) ::char(2) as emp_state
,substring(pa.postalcode,1,5) :: char(9) as emp_zip
,'USA' :: char(3) as Country
,to_char(pv.birthdate,'YYYYMMDD')::char(8) as emp_dob
,case when substring(pv.gendercode,1,1) = 'F' then 'F'
      when substring(pv.gendercode,1,1) = 'M' then 'M'
      else ' '
 end :: char(1) as gender
,null :: char(12) as HICN
,'~' :: char(1) as Reimbursement_Method
,'~' :: char(50) as Bank_Name
,'~' :: char(9) as ABA_Routing_Number
,'~' :: char(20) as Bank_Account_Number
,'~' :: char(1) as ACH_Account_Type
,coalesce(pncw.url,pnch.url,pnco.url) :: char(100)  AS EMPLOYEE_EMAIL
,null :: char(20) as Location_Code
,CASE WHEN pe.emplstatus   in ('A','C','M','P') then 'A'
      WHEN pe.emplstatus   in ('T','R','D','V','T') THEN 'T'
      else null
 end :: char(1) as Employment_Status
,to_char(pe.empllasthiredate,'YYYYMMDD') :: char(8) as effective_date --use date of hire
,'' :: char(8) as term_date
,null :: char(9) as New_SSN
,null :: char(30) as Health_Plan_ID

--Control Report Values --
,pie.identity ::varchar(15) as cr_empno

from person_identity pi

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

left join public.person_vitals pv
  on pv.personid = pi.personid
and (current_date between pv.effectivedate and pv.enddate
	or (pv.effectivedate > current_date
	    and pv.effectivedate < pv.enddate))
and current_timestamp between pv.createts and pv.endts

left join public.person_address pa
  on pa.personid = pi.personid
and (current_date between pa.effectivedate and pa.enddate
	or (pa.effectivedate > current_date
	    and pa.effectivedate < pa.enddate))
and current_timestamp between pa.createts and pa.endts
and pa.addresstype = 'Res'

LEFT JOIN person_phone_contacts ppch
  ON ppch.personid = pi.personid 
 AND ppch.phonecontacttype = 'Home' 
 and (current_date between ppch.effectivedate and ppch.enddate
	or (ppch.effectivedate > current_date
	    and ppch.effectivedate < ppch.enddate))
and current_timestamp between ppch.createts and ppch.endts

LEFT JOIN person_phone_contacts ppcm 
  ON ppcm.personid = pi.personid 
 AND ppcm.phonecontacttype = 'Mobile' 
 and (current_date between ppcm.effectivedate and ppcm.enddate
	or (ppcm.effectivedate > current_date
	    and ppcm.effectivedate < ppcm.enddate))
and current_timestamp between ppcm.createts and ppcm.endts 

left JOIN person_phone_contacts ppcw 
  ON ppcw.personid = pi.personid
 AND (current_date between ppcw.effectivedate and ppcw.enddate
      or (ppcw.effectivedate > current_date
	  and ppcw.effectivedate < ppcw.enddate))
 AND current_timestamp between ppcw.createts and ppcw.endts 
 AND ppcw.phonecontacttype in ('Work','C-WK')
  
left JOIN person_phone_contacts ppcb 
  ON ppcb.personid = pi.personid
 AND (current_date between ppcb.effectivedate and ppcb.enddate
      or (ppcb.effectivedate > current_date
          and ppcb.effectivedate < ppcb.enddate))
 AND current_timestamp between ppcb.createts and ppcb.endts 
 AND ppcb.phonecontacttype = 'BUSN' 

left join person_net_contacts pnch 
  on pnch.personid = pi.personid 
 and pnch.netcontacttype = 'HomeEmail'::bpchar 
 and (current_date between pnch.effectivedate and pnch.enddate
      or (pnch.effectivedate > current_date
          and pnch.effectivedate < pnch.enddate))
 and current_timestamp between pnch.createts and pnch.enddate   

left join person_net_contacts pncw 
  on pncw.personid = pi.personid 
 and pncw.netcontacttype = 'WRK'::bpchar 
 and (current_date between pncw.effectivedate and pncw.enddate
      or (pncw.effectivedate > current_date
          and pncw.effectivedate < pncw.enddate))
 and current_timestamp between pncw.createts and pncw.enddate   
  
LEFT JOIN person_net_contacts pnco 
  ON pnco.personid = pi.personid 
 AND pnco.netcontacttype = 'OtherEmail'::bpchar 
 AND (current_date between pnco.effectivedate and pnco.enddate
      or (pnco.effectivedate > current_date
         and pnco.effectivedate < pnco.enddate))
 AND current_timestamp between pnco.createts and pnco.enddate 


left join public.person_employment pe
  on pe.personid = pi.personid 
 and (current_date between pe.effectivedate and pe.enddate or
      (pe.effectivedate > current_date
      and pe.effectivedate < pe.enddate))
and current_timestamp between pe.createts and pe.endts 


--fsa, dep fsa
left JOIN person_bene_election pbe 
  ON pbe.personid = pI.personid
  and pbe.selectedoption = 'Y' 
  and pbe.benefitsubclass in ('60','62','61','63','6A','6AP','6B','6BP','67','6H','6J','6Y','6Z','1Y' )
and pbe.coverageamount >= 0 --
AND pbe.benefitelection IN ('E')
 AND (current_date BETWEEN pbe.effectivedate AND pbe.enddate 
 or (pbe.effectivedate > current_date
    and pbe.effectivedate < pbe.enddate))
 AND current_timestamp BETWEEN pbe.createts AND pbe.endts
 
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
 -- and pbe.effectivedate between cppy.planyearstart and cppy.planyearend -- mlc 12/20/2020 changed to use plan year start and end dates from lookup table.
  and pbe.effectivedate between lookup.plan_year_start_date and lookup.plan_year_end_date
  and pbe.benefitplanid = bpd.benefitplanid
  and pbe.benefitelection IN ('E')

-------------------------------------------------------------------------------------------------------------------
union
-------------------------------------------------------------------------------------------------------------------

--termed employees
SELECT distinct
PI.PERSONID
,'IB' :: char(2) as record_ID
,'AMF001' :: char(6) as TPA_ID
,lookup.GroupCode :: char(9) as Group_Code
,replace(pi2.identity ,'-','') :: char(9) as emp_ssn
,substring(pn.title,1,5) :: char(5) as Prefix
,rtrim(ltrim(replace(pn.lname,',',' '))) :: char(26) as emp_last_name
,rtrim(ltrim(replace(pn.fname,',',' '))) :: char(19) as emp_first_name
,rtrim(ltrim(substring(pn.mname,1,1))) :: char(1) as emp_middle_name

,coalesce (
	    '('||substring(ppch.phoneno,1,3)||')'||substring(ppch.phoneno,4,3)||'-'||substring(ppch.phoneno,7,4), 
	    '('||substring(ppcm.phoneno,1,3)||')'||substring(ppcm.phoneno,4,3)||'-'||substring(ppcm.phoneno,7,4),
	    '('||substring(ppcw.phoneno,1,3)||')'||substring(ppcw.phoneno,4,3)||'-'||substring(ppcw.phoneno,7,4),
	    '('||substring(ppcb.phoneno,1,3)||')'||substring(ppcb.phoneno,4,3)||'-'||substring(ppcb.phoneno,7,4)
          ):: char(19) as phone

,rtrim(ltrim(replace(pa.streetaddress,',',' '))) :: char(36) as emp_address1
,rtrim(ltrim(replace(pa.streetaddress2,',',' '))) :: char(36) as emp_address2
,rtrim(ltrim(pa.city)) ::char(20) as emp_city
,rtrim(ltrim(pa.stateprovincecode)) ::char(2) as emp_state
,substring(pa.postalcode,1,5) :: char(9) as emp_zip
,'USA' :: char(3) as Country
,to_char(pv.birthdate,'YYYYMMDD')::char(8) as emp_dob
,case when substring(pv.gendercode,1,1) = 'F' then 'F'
      when substring(pv.gendercode,1,1) = 'M' then 'M'
      else ' '
 end :: char(1) as gender
,null :: char(12) as HICN
,'~' :: char(1) as Reimbursement_Method
,'~' :: char(50) as Bank_Name
,'~' :: char(9) as ABA_Routing_Number
,'~' :: char(20) as Bank_Account_Number
,'~' :: char(1) as ACH_Account_Type
,coalesce(pncw.url,pnch.url,pnco.url) :: char(100)  AS EMPLOYEE_EMAIL
,null :: char(20) as Location_Code
,CASE WHEN pe.emplstatus   in ('A','C','M','P') then 'A'
      WHEN pe.emplstatus   in ('T','R','D','V','T') THEN 'T'
      else null
end :: char(1) as Employment_Status

,to_char(pe.empllasthiredate,'YYYYMMDD') :: char(8) as effective_date --use date of hire

,case when pbet.benefitelection in ('T','R') then to_char(pe.effectivedate,'YYYYMMDD') else ' ' end ::char(8) as term_date       
,null :: char(9) as New_SSN
,null :: char(30) as Health_Plan_ID

--Control Report Values --
,pie.identity ::varchar(15) as cr_empno

from person_identity pi

left join person_identity pie on pie.personid = pi.personid
and current_timestamp between pie.createts and pie.endts
and pie.identitytype = 'EmpNo'

LEFT JOIN person_identity pi2 
ON pi.personid = pi2.personid
AND pi2.identitytype = 'SSN' ::bpchar 
AND CURRENT_TIMESTAMP BETWEEN pi2.createts and pi2.endts 

--- mlc 12/22/2020 - added value3 and value4 
LEFT JOIN (select lp.lookupid, value1 as GroupCode, value2 as PlanID, lp.VALUE3 ::date as plan_year_start_date, lp.VALUE4 ::date as plan_year_end_date
from edi.lookup lp
join edi.lookup_schema els on lp.lookupid = els.lookupid and els.lookupname = 'Ameriflex_FLEX_Eligibility_Election' 
and current_date between lp.effectivedate and lp.enddate
 )lookup on lookup.lookupid is not null

left join edi.edi_last_update elu on elu.feedid = 'Ameriflex_FLEX_Demographic_Election'

LEFT JOIN person_names pn 
  ON pn.personid = pi.personid 
 AND pn.nametype = 'Legal'::bpchar 
 and current_date between pn.effectivedate and pn.enddate
and current_timestamp between pn.createts and pn.endts

left join public.person_vitals pv
  on pv.personid = pi.personid
and current_date between pv.effectivedate and pv.enddate
and current_timestamp between pv.createts and pv.endts

left join public.person_address pa
  on pa.personid = pi.personid
and current_date between pa.effectivedate and pa.enddate
and current_timestamp between pa.createts and pa.endts
and pa.addresstype = 'Res'

LEFT JOIN person_phone_contacts ppch
  ON ppch.personid = pi.personid 
 AND ppch.phonecontacttype = 'Home' 
 and current_date between ppch.effectivedate and ppch.enddate
and current_timestamp between ppch.createts and ppch.endts

LEFT JOIN person_phone_contacts ppcm 
  ON ppcm.personid = pi.personid 
 AND ppcm.phonecontacttype = 'Mobile' 
 and current_date between ppcm.effectivedate and ppcm.enddate
and current_timestamp between ppcm.createts and ppcm.endts 

left JOIN person_phone_contacts ppcw 
  ON ppcw.personid = pi.personid
 AND current_date between ppcw.effectivedate and ppcw.enddate
 AND current_timestamp between ppcw.createts and ppcw.endts 
 AND ppcw.phonecontacttype in ('Work','C-WK') 
  
left JOIN person_phone_contacts ppcb 
  ON ppcb.personid = pi.personid
 AND current_date between ppcb.effectivedate and ppcb.enddate
 AND current_timestamp between ppcb.createts and ppcb.endts 
 AND ppcb.phonecontacttype = 'BUSN' 

left join person_net_contacts pnch 
  on pnch.personid = pi.personid 
 and pnch.netcontacttype = 'HomeEmail'::bpchar 
 and current_date between pnch.effectivedate and pnch.enddate
 and current_timestamp between pnch.createts and pnch.enddate   
   
left join person_net_contacts pncw 
  on pncw.personid = pi.personid 
 and pncw.netcontacttype = 'WRK'::bpchar 
 and (current_date between pncw.effectivedate and pncw.enddate
      or (pncw.effectivedate > current_date
          and pncw.effectivedate < pncw.enddate))
 and current_timestamp between pncw.createts and pncw.enddate 

LEFT JOIN person_net_contacts pnco 
  ON pnco.personid = pi.personid 
 AND pnco.netcontacttype = 'OtherEmail'::bpchar 
 AND current_date between pnco.effectivedate and pnco.enddate
 AND current_timestamp between pnco.createts and pnco.enddate 

left join public.person_employment pe
  on pe.personid = pi.personid 
 and current_date between pe.effectivedate and pe.enddate
and current_timestamp between pe.createts and pe.endts 

left JOIN person_bene_election pbet  
  ON pbet.personid = pI.personid
  and pbet.selectedoption = 'Y' 
 AND pbet.benefitsubclass in ('60','62','61','63', '6A','6AP','6B','6BP','67','6H','6J','6Y','6Z','1Y' )
 AND pbet.benefitelection IN ('T','R')  
 --and pbet.coverageamount > 0 --
 AND current_date BETWEEN pbet.effectivedate AND pbet.enddate 
 AND current_timestamp BETWEEN pbet.createts AND pbet.endts

and pbet.personid in (select personid from person_bene_election pbe
                join comp_plan_plan_year cppy on pbe.compplanid = cppy.compplanid and cppy.compplanplanyeartype = 'Bene'
                 where pbe.benefitsubclass in ('60','62','61','63','6A','6AP','6B','6BP','67','6H','6J','6Y','6Z','1Y' ) and pbe.benefitelection = 'E' and pbe.selectedoption = 'Y' 
                        and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate
                        AND ((pbe.effectivedate, pbe.enddate) overlaps (cppy.planyearstart, cppy.planyearend) OR cppy.planyearstart IS NULL))
and pe.effectivedate - interval '1 day' < pbet.effectivedate

join benefit_plan_desc bpd
  on bpd.benefitsubclass = pbet.benefitsubclass
 and current_date between bpd.effectivedate and bpd.enddate
 and current_timestamp between bpd.createts and bpd.endts
 
 left join Comp_plan_plan_year cppy
 on pbet.compplanid = cppy.compplanid
 and cppy.compplanplanyeartype = 'Bene'
 and current_date between cppy.planyearstart and cppy.planyearend


WHERE pi.identitytype = 'PSPID'
  and pbet.benefitsubclass in ('60','62','61','63','6A','6AP','6B','6BP','67','6H','6J','6Y','6Z','1Y')
  and current_timestamp between pi.createts and pi.endts
  --and pbet.effectivedate between cppy.planyearstart and cppy.planyearend -- mlc 12/20/2020 changed to use plan year start and end dates from lookup table.
  and pbet.effectivedate between lookup.plan_year_start_date and lookup.plan_year_end_date
  and pbet.benefitplanid = bpd.benefitplanid
  and pbet.benefitelection in ('T','R')
  and (pbet.effectivedate >= elu.lastupdatets::DATE 
   or (pbet.createts > elu.lastupdatets and pbet.effectivedate < coalesce(elu.lastupdatets, '2017-01-01')))

order by emp_ssn