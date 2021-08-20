select distinct
---- active ee followed by active ee deps
 pi.personid
,'137 ACTIVE EE' ::varchar(30) as qsource
,'1' ::char(2) as sortseq
,pe.emplstatus
,'PSN'::char(3) AS recordType
,'HAR'::char(5) AS client 
,PI.identity ::char(10) AS certNumber
,'00'::char(2) AS relation
,PI.identity ::char(9) AS ssnbr
,ltrim(UPPER(pne.lname),' ') ::char(35) AS lname
,UPPER(pne.fname) ::char(25) AS fname
,UPPER(pne.mname) ::char(1) AS mname
,' ' ::char(5) AS honors
,TO_CHAR(pv.birthdate,'MM/DD/YYYY') ::char(10) AS dob
,UPPER(pv.gendercode) ::char(1) AS gender
,coalesce(UPPER(pmse.maritalstatus),'U') ::char(1) AS maritalStatus
,' ' ::char(12) AS memberId
,' ' ::char(15) AS xrefid
,UPPER(coalesce(pncw.url,pnch.url,pnco.url)) ::char(50) AS email
-- Original Effective Date Earliest effective date of all CI or Accident
,to_char(least(pbeci.effectivedate,pbeac.effectivedate),'MM/DD/YYYY') ::char(10) AS origEffDate
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
-- Employment Effective Date Hire Date (or Service date if appropriate)
,to_char(PE.emplhiredate,'mm/dd/yyyy')::char(10) AS empEffDt
,CASE WHEN pe.emplstatus = 'T' THEN to_char(pe.effectivedate,'MM/DD/YYYY') END ::char(10) AS empTermDt
,' ' ::char(1) AS cobra
,to_char(coalesce(pe.empllasthiredate,PE.emplhiredate),'MM/DD/YYYY') ::char(10) AS effectivedate
,' ' ::char(10) AS termdate  --- not for employee terminations
,' ' ::char(1)  AS termCode  --- not for employee terminations
,' ' ::char(8)  AS unapplied
,to_char(current_date,'mm/dd/yyyy') ::char(10) AS maintDate
,' ' ::char(5)  AS ccExpDate
,' ' ::char(4)  AS ccCVV2
,' ' ::char(10) AS coverageExCode
,' ' ::char(10) AS exclusionEffDate
,' ' ::char(10) AS exclusionTermDate


from person_identity pi

JOIN person_employment pe 
  ON pe.personid = pi.personid
 AND current_date between pe.effectivedate and pe.enddate
 AND current_timestamp between pe.createts and pe.endts
 
join person_names pne
  on pne.personid = pi.personid
 and pne.nametype = 'Legal'
 and current_date between pne.effectivedate and pne.enddate
 and current_timestamp between pne.createts and pne.endts 

JOIN person_vitals pv 
  on pi.personid = pv.personid
 AND current_date between pv.effectivedate and pv.enddate
 AND current_timestamp between pv.createts and pv.endts
 
left join person_maritalstatus pmse
  on pmse.personid = pi.personid
 and current_date between pmse.effectivedate and pmse.enddate
 and current_timestamp between pmse.createts and pmse.endts 

left join person_net_contacts pncw 
  on pncw.personid = pi.personid 
 and pncw.netcontacttype = 'WRK'::bpchar 
 and current_date between pncw.effectivedate and pncw.enddate
 and current_timestamp between pncw.createts and pncw.endts 
 
left join person_net_contacts pnch 
  on pnch.personid = pi.personid 
 and pnch.netcontacttype = 'HomeEmail'::bpchar 
 and current_date between pnch.effectivedate and pnch.enddate
 and current_timestamp between pnch.createts and pnch.endts  
    
LEFT JOIN person_net_contacts pnco
  ON pnco.personid = pi.personid 
 AND pnco.netcontacttype = 'OtherEmail'::bpchar 
 AND current_date between pnco.effectivedate and pnco.enddate
 AND current_timestamp between pnco.createts and pnco.endts  

left join person_locations pl
  on pl.personid = pi.personid
 and current_date between pl.effectivedate and pl.enddate
 and current_timestamp between pl.createts and pl.endts  

JOIN person_bene_election pbe 
  on pbe.personid = pi.personid 
 AND current_date between pbe.effectivedate and pbe.enddate
 AND current_timestamp between pbe.createts and pbe.endts
 AND pbe.benefitsubclass IN ( '1W','13')
 AND pbe.selectedoption = 'Y'
 and pbe.benefitelection in ('T','E')
 and pbe.personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts 
                         and benefitsubclass in ( '1W','13') and benefitelection = 'E' and selectedoption = 'Y')  
 
-- 10KCritNT           
left JOIN person_bene_election pbeci
  on pbeci.personid = pi.personid 
 AND current_date between pbeci.effectivedate and pbeci.enddate
 AND current_timestamp between pbeci.createts and pbeci.endts
 AND pbeci.benefitsubclass IN ('1W')
 AND pbeci.selectedoption = 'Y'
  
--- accident
left JOIN person_bene_election pbeac
  on pbeac.personid = pi.personid 
 AND current_date between pbeac.effectivedate and pbeac.enddate
 AND current_timestamp between pbeac.createts and pbeac.endts
 AND pbeac.benefitsubclass IN ('13')
 AND pbeac.selectedoption = 'Y' 
  
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts 
  and pe.emplstatus = 'A'
 -- and pe.personid in ('10081','10166','10296','9707')
