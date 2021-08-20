Select distinct
---- If any of the PSN joins change - make sure the change is propogated in the ADR, CVG and DCS sqls 
---- Those sqls make sure we pull rows that match back to psn query
 'PSN'::char(3) AS recordType
,'HAR'::char(5) AS client
,pi.personid
,to_char(pbe.effectivedate,'mm/dd/yyyy')::char(10) as effectivedate
,replace(PI.identity,'-','') ::char(10) AS certNumber
,'0' as dependentrelationship
,'00'::char(2) AS relation
,PI.identity ::char(9) AS ssnbr
,UPPER(pne.lname) ::char(35) AS lname
,UPPER(pne.fname) ::char(25) AS fname
,UPPER(pne.mname) ::char(1) AS mname
,' ' ::char(5) AS honors
,TO_CHAR(pv.birthdate,'MM/DD/YYYY') ::char(10) AS dob
,UPPER(pv.gendercode) ::char(1) AS gender

,coalesce(UPPER(pmse.maritalstatus),'U') ::char(1) AS maritalStatus
,' ' ::char(12) AS memberId
,' ' ::char(15) AS xrefid
,UPPER(coalesce(pncw.url,pnch.url,pnco.url)) ::char(50) AS email
,to_char(pbe.effectivedate,'MM/DD/YYYY') ::char(10) AS origEffDate
,'M' ::char(1) AS billMode
,' ' ::char(6) AS billFeeR
,' ' ::char(6) AS billFeeA
,' ' ::char(1) AS billMethod
,' ' ::char(9) AS eftRoutingNbr
,' ' ::char(17) AS eftAccountNbr
,' ' ::char(1) AS eftType
,' ' ::char(2) AS draftDay
,' ' ::char(19) AS ccNumber
,' ' ::char(1) AS ccType
,' ' ::char(1) AS ftStudent
,UPPER(PV.smoker) ::char(1) AS smoker

,case when pl.locationid = '1' then ('460192'||'-'||'1')
      when pl.locationid = '2' then ('460192'||'-'||'2')
      when pl.locationid = '3' then ('460192'||'-'||'4')
      when pl.locationid = '4' then ('460192'||'-'||'5')
      when pl.locationid = '5' then ('460192'||'-'||'1')
      when pl.locationid = '6' then ('460192'||'-'||'3')
      end ::char(10) AS empID
/*

Please change mapping of PS location codes to Hartford location codes:
PS Location Code      to     Hartford Location Code
 1 - Charlotte               001
 2 - Elgin                   002
 3 - Germantown              004
 4 - Lake Forest             005
 5 - Charlotte               001
 6 - Portland/Wilsonville    003
 7 - Peterborough(not used)  007

Thanks
Lori



*/
,case when pl.locationid = '1' then '001' 
      when pl.locationid = '2' then '002' 
      when pl.locationid = '3' then '004' 
      when pl.locationid = '4' then '005'   
      when pl.locationid = '5' then '001'     
      when pl.locationid = '6' then '003' 
else  '   ' end ::char(5) as branch
,to_char(PE.emplhiredate,'mm/dd/yyyy')::char(10) AS empEffDt
,CASE WHEN pe.emplstatus = 'T' THEN to_char(pe.enddate,'MM/DD/YYYY') END ::char(10) AS empTermDt
,' ' ::char(1) AS cobra
,to_char(coalesce(pe.empllasthiredate,PE.emplhiredate),'MM/DD/YYYY') ::char(10) AS effectivedate
,' ' ::char(10) AS termdate
,' ' ::char(1) AS termCode
,' ' ::char(8) AS unapplied
,to_char(current_date,'mm/dd/yyyy') ::char(10) AS maintDate
,' ' ::char(5) AS ccExpDate
,' ' ::char(4) AS ccCVV2
,' ' ::char(10) AS coverageExCode
,' ' ::char(10) AS exclusionEffDate
,' ' ::char(10) AS exclusionTermDate

,'0' ::char(1) as sortseq

FROM person_identity PI 

left join person_names pne
  on pne.personid = pi.personid
 and pne.nametype = 'Legal'  
 and current_date between pne.effectivedate and pne.enddate
 and current_timestamp between pne.createts and pne.endts
 
left join person_maritalstatus pmse
  on pmse.personid = pi.personid
 and current_date between pmse.effectivedate and pmse.enddate
 and current_timestamp between pmse.createts and pmse.endts 

left join person_net_contacts pncw 
  on pncw.personid = pi.personid 
 and pncw.netcontacttype = 'WRK'::bpchar 
 and current_date between pncw.effectivedate and pncw.enddate
 and current_timestamp between pncw.createts and pncw.enddate 
left join person_net_contacts pnch 
  on pnch.personid = pi.personid 
 and pnch.netcontacttype = 'HomeEmail'::bpchar 
 and current_date between pnch.effectivedate and pnch.enddate
 and current_timestamp between pnch.createts and pnch.enddate      
LEFT JOIN person_net_contacts pnco ON pnco.personid = pi.personid 
 AND pnco.netcontacttype = 'OtherEmail'::bpchar 
 AND current_date between pnco.effectivedate and pnco.enddate
 AND current_timestamp between pnco.createts and pnco.enddate 

left join person_locations pl
  on pl.personid = pi.personid
 and current_date between pl.effectivedate and pl.enddate
 and current_timestamp between pl.createts and pl.endts 
 and pl.locationid in ('1','2','3','4','5','6')

JOIN person_vitals pv 
  on pi.personid = pv.personid
 AND current_date between pv.effectivedate and pv.enddate
 AND current_timestamp between pv.createts and pv.endts
 
LEFT JOIN person_employment pe 
  ON pe.personid = pi.personid
 AND current_date between pe.effectivedate and pe.enddate
 AND current_timestamp between pe.createts and pe.endts
 
LEFT JOIN company_identity ci 
  ON ci.companyid = pe.companyid 
 AND ci.companyidentitytype = 'FEIN'::bpchar 
 AND current_timestamp between ci.createts and ci.endts
 
JOIN person_bene_election pbe 
 on pbe.personid = pi.personid 
AND current_timestamp between pbe.createts and pbe.endts
and date_part('year',pbe.effectivedate) = date_part('year',current_date + interval '1 year')
AND pbe.benefitsubclass IN ( '1W','13','30','31' )
AND pbe.selectedoption = 'Y'
and pbe.benefitelection in ('E')


left JOIN 
(select 
benefitsubclass,
edtcode
FROM benefit_plan_desc pbd 
where current_date between pbd.effectivedate and pbd.enddate
  AND current_timestamp between pbd.createts and pbd.endts 
  AND pbd.benefitsubclass IN ( '1W','13','30','31' )
group by 1,2
ORDER BY 2
) cov
on cov.benefitsubclass = pbe.benefitsubclass 

WHERE PI.identitytype = 'SSN' 
  and current_timestamp between PI.createts and PI.endts and pne.lname is not null
--and pi.personid = '9911'



--%%%%%  
union
--%%%%%
Select distinct
 'PSN' ::char(3) AS recordType
,'HAR' ::char(5) AS client
,pi.personid
,to_char(pbe.effectivedate,'mm/dd/yyyy')::char(10) as effectivedate
,replace(PI.identity,'-','') ::char(10) AS certNumber
,pdr.dependentrelationship
,case pdr.dependentrelationship when '0' then '00' when 'SP' then '01' else '02' end ::char(2) AS relation

,pid.identity ::char(9) AS ssnbr
,UPPER(pnd.lname) ::char(35) AS lname
,UPPER(pnd.fname) ::char(25) AS fname
,UPPER(pnd.mname) ::char(1) AS mname
,' ' ::char(5) AS honors
,TO_CHAR(pvd.birthdate,'MM/DD/YYYY') ::char(10) AS dob
,UPPER(pvd.gendercode) ::char(1) AS gender
,coalesce(UPPER(pmsd.maritalstatus),'U') ::char(1) AS maritalStatus
,' ' ::char(12) AS memberId
,' ' ::char(15) AS xrefID
--,UPPER(dep.emailaddress) ::char(50) AS email
,UPPER(coalesce(pncw.url,pnch.url,pnco.url)) ::char(50) AS email
--,to_char(PE.emplhiredate,'MM/DD/YYYY') ::char(10) AS origEffDate
,to_char(pbe.effectivedate,'MM/DD/YYYY') ::char(10) AS origEffDate
,'M' ::char(1) AS billMode
,' ' ::char(6) AS billFeeR
,' ' ::char(6) AS billFeeA
,' ' ::char(1) AS billMethod
,' ' ::char(9) AS eftRoutingNbr
,' ' ::char(17) AS eftAccountNbr
,' ' ::char(1) AS eftType
,' ' ::char(2) AS draftDay
,' ' ::char(19) AS ccNumber
,' ' ::char(1) AS ccType
,case pdr.dependentrelationship when 'C' then (dd.student) else ' ' end ::char(1) AS ftStudent
,UPPER(pvd.smoker) ::char(1) AS smoker
,case when pl.locationid = '6' then ('460192'||'-'||'3') else ('460192'||'-'||pl.locationid) end ::char(10) AS empID

,case when pl.locationid = '6' then '003' when pl.locationid = '006' then '003' else ('00'||pl.locationid) end ::char(5) as branch
,to_char(PE.emplhiredate,'mm/dd/yyyy')::char(10) AS empEffDt
,CASE WHEN pe.emplstatus = 'T' THEN to_char(pe.enddate,'MM/DD/YYYY') END ::char(10) AS empTermDt
,' ' ::char(1) AS cobra
,to_char(coalesce(pe.empllasthiredate,PE.emplhiredate),'MM/DD/YYYY') ::char(10) AS effectivedate
,' ' ::char(10) AS termdate
,' ' ::char(1) AS termCode
,' ' ::char(8) AS unapplied
,to_char(CURRENT_DATE,'mm/dd/yyyy') ::char(10) AS maintDate
,' ' ::char(5) AS ccExpDate
,' ' ::char(4) AS ccCVV2
,' ' ::char(10) AS coverageExCode
,' ' ::char(10) AS exclusionEffDate
,' ' ::char(10) AS exclusionTermDate
,'1' ::char(1) as sortseq

FROM person_identity PI 
left join person_names pne
  on pne.personid = pi.personid
 and pne.nametype = 'Legal'  
 and current_date between pne.effectivedate and pne.enddate
 and current_timestamp between pne.createts and pne.endts
 
left join person_maritalstatus pmse
  on pmse.personid = pi.personid
 and current_date between pmse.effectivedate and pmse.enddate
 and current_timestamp between pmse.createts and pmse.endts 

left join person_locations pl
  on pl.personid = pi.personid
 and current_date between pl.effectivedate and pl.enddate
 and current_timestamp between pl.createts and pl.endts 
 and pl.locationid in ('1','2','3','4','5','6') 

JOIN person_employment pe 
  ON pe.personid = pi.personid 
 AND current_date between pe.effectivedate and pe.enddate 
 AND current_timestamp between pe.createts and pe.endts
JOIN edi.etl_employment_data ed on ed.personid = pi.personid 
     
JOIN person_bene_election pbe on pbe.personid = pi.personid 
 and date_part('year',pbe.effectivedate) = date_part('year',current_date + interval '1 year') 
 AND current_timestamp between pbe.createts and pbe.endts
 AND pbe.benefitsubclass IN ( '1W','13','30','31' )
 and pbe.benefitelection in ('E')
 AND pbe.selectedoption = 'Y'
 
left JOIN 
(
 select benefitsubclass,edtcode FROM benefit_plan_desc pbd 
  where current_date between pbd.effectivedate and pbd.enddate 
    AND current_timestamp between pbd.createts and pbd.endts
    AND pbd.benefitsubclass IN ( '1W','13','30','31' )
    group by 1,2 ORDER BY 2
) cov
on cov.benefitsubclass = pbe.benefitsubclass 


join person_dependent_relationship pdr
  on pdr.personid = pi.personid
 and pdr.dependentrelationship in ('D','C','DP','SP','S')
 and current_date between pdr.effectivedate and pdr.enddate
 and current_timestamp between pdr.createts and pdr.endts

left join dependent_enrollment de
  on de.dependentid = pdr.dependentid
 and de.personid = pbe.personid
 and date_part('year',de.effectivedate) = date_part('year',current_date + interval '1 year') 
 and current_timestamp between de.createts and de.endts
 
left join person_identity piD
  on piD.personid = pdr.dependentid
 and piD.identitytype = 'SSN'
 and current_timestamp between piD.createts and piD.endts 
 
left join person_names pnd
  on pnD.personid = pdr.dependentid
 and current_date between pnD.effectivedate and pnD.enddate
 and current_timestamp between pnd.createts and pnD.endts
 and pnD.nametype = 'Dep'
 
left join person_vitals pvD
  on pvD.personid = piD.personid
 and current_date between pvD.effectivedate and pvD.enddate
 and current_timestamp between pvD.createts and pvD.endts  

left join dependent_desc dd
  on dd.dependentid = pdr.personid
 and current_date between dd.effectivedate and dd.enddate
 and current_timestamp between dd.createts and dd.endts
 
left join person_maritalstatus pmsd
  on pmsd.personid = pdr.dependentid
 and current_date between pmsd.effectivedate and pmsd.enddate
 and current_timestamp between pmsd.createts and pmsd.endts
 
left join person_net_contacts pncw 
  on pncw.personid = pdr.personid 
 and pncw.netcontacttype = 'WRK'::bpchar 
 and current_date between pncw.effectivedate and pncw.enddate
 and current_timestamp between pncw.createts and pncw.enddate 
left join person_net_contacts pnch 
  on pnch.personid = pdr.personid 
 and pnch.netcontacttype = 'HomeEmail'::bpchar 
 and current_date between pnch.effectivedate and pnch.enddate
 and current_timestamp between pnch.createts and pnch.enddate      
LEFT JOIN person_net_contacts pnco 
  ON pnco.personid = pdr.personid 
 AND pnco.netcontacttype = 'OtherEmail'::bpchar 
 AND current_date between pnco.effectivedate and pnco.enddate
 AND current_timestamp between pnco.createts and pnco.enddate 
 



WHERE PI.identitytype = 'SSN' 
  and current_timestamp between PI.createts and PI.endts
--and pi.personid = '9911'
order by 3,7,8,9
  ;

