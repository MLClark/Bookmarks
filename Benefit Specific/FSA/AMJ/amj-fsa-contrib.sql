SELECT distinct
 PI.PERSONID
--,PPD.ETV_ID
,'PeopleStrategy' :: char(50) as "PartnerID"
,replace(pis.identity,'-','') :: char(255) as "InsuredID"
,replace(pis.identity,'-','') || '01':: char(255) as "MemberID"-- needs more info
,'18' :: char(2) as "Relation"
,rtrim(ltrim(pn.lname)) :: char(50) as "LastName"
,rtrim(ltrim(pn.fname)) :: char(50) as "FirstName"
,rtrim(ltrim(pn.mname)) :: char(50) as "MI"
--,SUBSTRING(pis.identity, 1, 3) || SUBSTRING(pis.identity, 4, 2) || SUBSTRING(pis.identity, 6, 4) :: char(11) as "SSN"
, SUBSTRING(replace (pis.identity,'-',''), 1, 3) || '-' || SUBSTRING(replace (pis.identity,'-',''), 4, 2) || '-' || SUBSTRING(replace(pis.identity,'-',''), 6, 4) :: char(11) as "SSN"
--,--(pis.identity) :: char(11) as "SSN"
,'C98599' :: char(25) as "GroupID"

,case when ppd.etv_id = 'VBA' then 'MED' 
      when ppd.etv_id = 'VBB' then 'DEP' 
	  else '' end :: char(20) as "PlanType"

,'BW26' :: char(50) as "PayrollSchedule"	

,case when ppd.etv_id = 'VBA' then to_char(ppd.check_date,'YYYY-MM-DD') 
      when ppd.etv_id = 'VBB' then to_char(ppd.check_date,'YYYY-MM-DD') 
      else ''end :: char(10) as "PayrollDate"
	
--,to_char(ppdvba.check_date,'YYYY-MM-DD') :: char(10) as "PayrollDate"
--,round((pd.employeeamt * 100) ,2 ) :: money () as "PayrollDeduction"

,case when (ppd.etv_id = 'VBA') then to_char(ppd.etv_amount,'999999.99') 
      when (ppd.etv_id = 'VBB')  then to_char(ppd.etv_amount,'999999.99') end :: char(10)  as "PayrollDeduction" 		


,case when ppd.etv_id = 'VBA' and trim(ppd.etv_code) = 'EE' and ppd.etv_amount IS NOT NULL then '0' 
	  when ppd.etv_id = 'VBB' and trim(ppd.etv_code) = 'EE' and ppd.etv_amount IS NOT NULL then '0' 
      when ppd.etv_id = 'VBA' and trim(ppd.etv_code) = 'ER' and ppd.etv_amount IS NOT NULL then '1' 
	  when ppd.etv_id = 'VBB' and trim(ppd.etv_code) = 'ER' and ppd.etv_amount IS NOT NULL then '1' 
	  else '' end  :: char(1) as "DepositType"
     
--verify if required
 ,'' :: char(10) as "QE_Date"
 ,'' :: char(10) as "FirstPayrollDate"
 ,'' :: char(2) as "QE_Reason"
 ,'' :: char(10) as "LastPayrollDate"
--,' ' as endline

----

,'1' as sort_seq  
--,ed.feedid
,current_timestamp as updatets



from person_identity pi



LEFT JOIN person_identity pis
     ON pis.personid     = pi.personid
     AND pis.identitytype = 'SSN'
     AND now() between pis.createts and pis.endts

LEFT JOIN person_names pn 
     ON pn.personid = pi.personid
     AND now() between pn.effectivedate and pn.enddate
     AND now() between pn.createts      and pn.endts
     AND nametype = 'Legal'

left join person_identity pip
     on pip.personid = pi.personid
     and pip.identitytype = 'PSPID'
     and current_timestamp between pip.createts and pip.endts

JOIN pspay_payment_detail ppd 
  on ppd.individual_key = pi.identity
 AND ppd.check_date = ? ::DATE
 and ppd.etv_id in ('VBA','VBB')
 and ppd.etv_amount > 0

join person_bene_election pbe
  on rtrim(ltrim(pbe.personid)) = rtrim(ltrim(pi.personid))
 and current_date between pbe.effectivedate and pbe.enddate
 and current_timestamp between pbe.createts and pbe.endts
 and pbe.benefitsubclass in ('60','61')
 --and pbe.benefitelection in ('E','T','W')
 and pbe.selectedoption = 'Y'
 --and pbe.effectivedate >= elu.lastupdatets

--med
join person_bene_election pbe_fsamed
  on pbe_fsamed.personid = pbe.personid
 and current_date between pbe_fsamed.effectivedate and pbe_fsamed.enddate
 and current_timestamp between pbe_fsamed.createts and pbe_fsamed.endts
 and pbe_fsamed.benefitsubclass in ('60')
 --and pbe_fsamed.benefitelection in ('E','T','W')
 and pbe_fsamed.selectedoption = 'Y' 
 
--dependent
 join person_bene_election pbe_fsadep
  on pbe_fsadep.personid = pbe.personid
 and current_date between pbe_fsadep.effectivedate and pbe_fsadep.enddate
 and current_timestamp between pbe_fsadep.createts and pbe_fsadep.endts
 and pbe_fsadep.benefitsubclass in ('61')
 --and pbe_fsadep.benefitelection in ('E','T','W')
 and pbe_fsadep.selectedoption = 'Y' 

--LEFT JOIN edi.edi_last_update ed
--ON ed.feedid = 'AMJ_EBC_FSA_Eligibility'


WHERE current_timestamp between pi.createts and pi.endts
and pi.identitytype = 'PSPID'
AND ppd.check_date = ? ::DATE
AND ppd.etv_amount IS NOT NULL
and ppd.etv_id in ('VBA','VBB')
--AND PI.PERSONID = '963'
ORDER BY 1


