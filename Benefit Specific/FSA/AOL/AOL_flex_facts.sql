-- Started with the AJG_HealthEquity_FSA Query

SELECT distinct
 pi.identity

--,elu.lastupdatets
,pbe.selectedoption
,to_char(pbe.effectivedate,'MM/DD/YYYY')::char(10) AS "Effective Date"
,CASE pbe.benefitelection WHEN 'T' THEN to_char(pbe.effectivedate,'MM/DD/YYYY')END ::char(10) AS "Term_Ben_Date"

,left(trim(pi.identity), 5)::char(5) as payunit
--,epi.trankey ::char(20) AS "EMPLOYEE ID"

,coalesce(trim(pi1.identity), trim(pi2.identity)) ::char(9) AS ssno
,trim(pne.fname)::varchar(40) AS firstname
,trim(pne.lname)::varchar(40) AS lastname

-- work e-mail if it exists, home e-mail if it doesn't
,coalesce(trim(pnc.url), trim(pncH.url))::varchar(50) as email

,to_char(pve.birthdate, 'MM/DD/YYYY')::char(10) AS birthdate
,pve.gendercode ::char(1) AS gender

,(pa.streetaddress || ' ' || coalesce(pa.streetaddress2, ''))::varchar(100) as address

,trim(pa.city)::varchar(50) AS city
,trim(pa.stateprovincecode)::char(2) AS state
,trim(pa.postalcode)::char(9) AS zip

,coalesce(ppcw.phoneno,ppch.phoneno)::varchar(20) as phone

,case pbe.benefitsubclass WHEN '60' THEN '1' ELSE '2' END ::char(5) AS "PLAN TYPE"
--,to_char(pbe.effectivedate,'MM/DD/YYYY') ::char(10) AS "ACCOUNT START DATE"
,to_char(pbe.planyearenddate,'MM/DD/YYYY') ::char(10) AS "ACCOUNT END DATE"

,pbe.coverageamount AS "ACCOUNT ELECTION AMOUNT"

,pbe.benefitplanid ::char(10) AS "RA PLAN ID"
,to_char(pbe.effectivedate,'MM/DD/YYYY') ::char(10) as account_start_date
,case when pbe.benefitsubclass = '60'
	then pbe.coverageamount
	else null end as Medical_FSA_Amount

,case when pbe.benefitsubclass = '61'
	then pbe.coverageamount
	else null end as Dependent_FSA_Amount

,pbe.overrideeeperpayamt
,pbe.monthlyamount
,fc.annualfactor
,pe.emplstatus

--,coalesce(pbe.overrideeeperpayamt, (pbe.monthlyamount * 12 / fc.annualfactor),pbe.coverageamount/fc.annualfactor) as PayPeriodAmount

,case	when pbe.overrideeeperpayamt > 0 then pbe.overrideeeperpayamt
		when (pbe.monthlyamount * 12 / fc.annualfactor) > 0 then (pbe.monthlyamount * 12 / fc.annualfactor)
		else pbe.coverageamount/fc.annualfactor
	end as PayPeriodAmount
,current_timestamp as cur_time
/*
,pc.compamount
,pp.partialpercent
,fc.frequencydesc
,fc.annualfactor
*/

from person_identity pi

left join person_identity pi1 on pi1.personid = pi.personid
	and pi1.identitytype = 'SSN'
	AND current_timestamp BETWEEN pi1.createts AND pi1.endts

left join person_identity pi2 on pi2.personid = pi.personid
	and pi2.identitytype = 'SIN'
	AND current_timestamp BETWEEN pi2.createts AND pi2.endts


left JOIN edi.edi_last_update elu
  ON elu.feedid = 'AOL_Flex_Facts'

/*
LEFT JOIN edi.edidependent eed
  ON eed.employeepersonid = pi.personid
*/

LEFT JOIN person_net_contacts pnc ON pnc.personid = pi.personid
	AND	pnc.netcontacttype = 'WRK'::bpchar
	and current_date between pnc.effectivedate and pnc.enddate
	and current_timestamp between pnc.createts and pnc.endts

LEFT JOIN person_net_contacts pncH ON pnc.personid = pi.personid
	AND	pnc.netcontacttype = 'HomeEmail'::bpchar
	and current_date between pncH.effectivedate and pncH.enddate
	and current_timestamp between pncH.createts and pncH.endts

JOIN person_names pne 
  ON pne.personid = pi.personid
 AND current_date BETWEEN pne.effectivedate AND pne.enddate
 AND current_timestamp BETWEEN pne.createts AND pne.endts      
 
LEFT JOIN person_address pa 
  ON pa.personid = pi.personid
 AND current_date BETWEEN pa.effectivedate AND pa.enddate
 AND current_timestamp BETWEEN pa.createts AND pa.endts      


LEFT JOIN person_payroll ppay
  ON ppay.personid = pi.personid
 AND current_date BETWEEN ppay.effectivedate AND ppay.enddate
 AND current_timestamp BETWEEN ppay.createts AND ppay.endts      

LEFT JOIN pay_unit pu
  ON pu.payunitid = ppay.payunitid

LEFT JOIN frequency_codes fc
  ON fc.frequencycode = pu.frequencycode


left JOIN person_vitals pve 
  ON pve.personid = pi.personid 
 AND current_date BETWEEN pve.effectivedate AND pve.enddate
 AND current_timestamp BETWEEN pve.createts AND pve.endts    





JOIN person_bene_election pbe  
  ON pbe.personid = pI.personid
 AND pbe.benefitsubclass IN ( '60', '61')
-- AND pbe.benefitelection IN ('E')
 AND pbe.enddate = '2199-12-31' 
-- AND current_date BETWEEN pbe.effectivedate AND pbe.enddate 
 AND current_timestamp BETWEEN pbe.createts AND pbe.endts
 




left JOIN person_employment pe
  ON pe.personid = pi.personid
 AND current_date BETWEEN pe.effectivedate AND pe.enddate
 AND current_timestamp BETWEEN pe.createts AND pe.endts
 
 
left JOIN benefit_plan_desc bpd 
  ON bpd.benefitsubclass = pbe.benefitsubclass 
 AND bpd.enddate = '2199-12-31' 
 AND bpd.benefitplanid = pbe.benefitplanid


LEFT JOIN person_phone_contacts ppcw ON ppcw.personid = pi.personid AND ppcw.phonecontacttype = 'Work'::bpchar AND 'now'::text::date >= ppcw.effectivedate AND 'now'::text::date <= ppcw.enddate AND now() >= ppcw.createts AND now() <= ppcw.endts
LEFT JOIN person_phone_contacts ppch ON ppch.personid = pi.personid AND ppch.phonecontacttype = 'Home'::bpchar AND 'now'::text::date >= ppch.effectivedate AND 'now'::text::date <= ppch.enddate AND now() >= ppch.createts AND now() <= ppch.endts

/*
LEFT JOIN edi.etl_employment_term_data eetd
  ON eetd.personid = pi.personid

LEFT JOIN edi.etl_personal_info epi
  ON epi.personid = pbe.personid
*/

--JOIN person_identity pid ON pi.personid = pid.personid AND pid.identitytype = 'EmpNo'::bpchar AND now() >= pid.createts AND now() <= pid.endts



/*  Here is the stuff for pay period calculations 
left join person_compensation pc on pi.personid = pc.personid
	and current_date between pc.effectivedate and pc.enddate
	and current_timestamp between pc.createts and pc.endts
left join frequency_codes fc on fc.frequencycode = pc.frequencycode
left join pers_pos pp on pp.personid = pi.personid
	and current_date between pp.effectivedate and pp.enddate
	and current_timestamp between pp.createts and pp.endts
*/

where pi.identitytype = 'PSPID'
	AND current_timestamp BETWEEN pi.createts AND pi.endts
	and ((? = 'C' and (pbe.effectivedate >= coalesce(elu.lastupdatets, '1960-01-01') 
	or (pe.emplstatus = 'T' and pe.effectivedate >= coalesce(elu.lastupdatets, '1960-01-01'))))

	or (? = 'F' and pe.emplstatus = 'A' and pbe.effectivedate >= ?))

-- RUN_TYPE = F or C

order by lastname



