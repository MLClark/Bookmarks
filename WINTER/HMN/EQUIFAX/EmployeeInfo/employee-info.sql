SELECT distinct
 pi.personid
,pe.emplclass
,pe.emplpermanency
,'11340' :: char(5) as COCODE
,REPLACE(pu.payunitdesc,'-','')::varchar(11) as DataSource
,pu.employertaxid::varchar(11) as FEIN 
,substring(pi2.identity,1,3)||'-'||substring(pi2.identity,4,2)||'-'||substring(pi2.identity,6,4) :: char(11) as ssn
,pi.identity :: varchar(12) as EmployeeID
,'N' :: char(1) as AssignmentID
,'N' :: char(1) as BillingCode
,'0' :: char(1) as IsPrimaryAssignment
,case when pe.emplstatus <> 'A' then 'I' 
      else pe.emplstatus
 end :: char(1) as CurrentStatus
 
,to_char(pe.emplhiredate,'MM/DD/YYYY') ::char(10) as OriginalHireDate

,to_char(pe.empllasthiredate,'MM/DD/YYYY') ::char(10) as MostRecentHireDate
 
,to_char(pe.empllasthiredate,'MM/DD/YYYY') ::char(10) as MostRecentStartDate
 
,case when pe.emplstatus = 'T' then to_char(pe.effectivedate,'MM/DD/YYYY') 
       else ' ' 
 end ::char(10) as TerminationDate
 
,pn.fname :: char(12) as FirstName
,case when pn.title is not null then pn.lname||', '||pn.title else pn.lname end :: char(24) as LastName
,pn.mname :: char(1) as MiddleName

,case when pc.frequencycode = 'H' then to_char(pc.compamount,'9999D9999')
      when pc.compamount = 0 then to_char(0,'9990D9999')
      when pc.frequencycode = 'A' and (perspos.scheduledhours is null or perspos.scheduledhours = 0) then to_char(pc.compamount/(86.67 * 24),'9999D9999')
      when pc.frequencycode = 'A' and perspos.scheduledhours is not null then to_char(pc.compamount/(perspos.scheduledhours * 24),'9999D9999')
      else to_char(0,'9990D9999')
end ::char(10) as PayRate

,'HY' :: char(2) as PayType
,'SM' :: char(2) as PayCycleFrequency 
,rtrim(ltrim(pa.streetaddress)) :: char(24) as HomeAddressLine1
,rtrim(ltrim(pa.streetaddress2)) :: char(24) as HomeAddressLine2
,rtrim(ltrim(pa.city)) ::char(16) as HomeAddressCity
,rtrim(ltrim(pa.stateprovincecode)) ::char(2) as HomeAddressState
,rtrim(ltrim(pa.postalcode)) :: char(5) as HomeAddressZIP
,case when rtrim(ltrim(pa.countrycode)) = 'US' then 'USA' 
      else '' 
 end ::char(3) as HomeAddressCountry
,rtrim(ltrim(coalesce(pncw.url,pnco.url))) :: char(32)  as NotificationEmail
,to_char(pv.birthdate,'MM/DD/YYYY')::char(10) as DateOfBirth
,case when substring(pv.gendercode,1,1) = 'F' then 'F'
      when substring(pv.gendercode,1,1) = 'M' then 'M'
      else ' '
 end :: char(1) as Gender
,' ' :: char(1) as UnionAffiliation


,case when pufv.ufvalue = 'Agent Manager' then 'AM'
      when pufv.ufvalue = 'Career Agent' then 'CA'
      when pufv.ufvalue = 'Finance Agent' then 'FA'
          when pe.emplclass = 'F' and pe.emplpermanency = 'P' and pd.flsacode = 'E' then 'EF'
	      when pe.emplclass = 'P' and pe.emplpermanency = 'P' and pd.flsacode = 'E' then 'EP'
	      when pe.emplclass = 'F' and pe.emplpermanency = 'P' and pd.flsacode <> 'E' then 'NF'
	      when pe.emplclass = 'P' and pe.emplpermanency = 'P' and pd.flsacode <> 'E' then 'NP'
	      when pe.emplclass = 'T' or pe.emplpermanency = 'T' then 'NT'
	      when pe.emplstatus = 'T' and pe.emplclass = 'F' and pd.flsacode is null then 'EF'
	      when pe.emplstatus = 'T' and pe.emplclass = 'P' and pd.flsacode is null then 'EP'
 end ::char(2) as EmployeeClassCode 

,' ' :: char(1) as EmployeeClassLabel
,case when pe.emplstatus = 'T' then 'S '
	  when pe.emplclass = 'F' then 'FT'
      when pe.emplclass in ('P','X') then 'PT'
      when pe.emplclass in ('T') then 'V '
 end :: char(2) as ACAEmployeeDesignationCode 
,'CG1EC1' :: char(6) as ACAEmployeeCategoryCode
,'H' :: char(1) as ACAPayTypeClassificationCode
,pd.positiontitle :: varchar(30) as JobTitle
,substring(pd.eeocode,1,1)||jd.jobexperience||fjc.federaljobcode :: char(6) as JobClassCode
,substring(pd.eeocode,1,1)||jd.jobexperience||fjc.federaljobcode :: char(6) as JobClassLabel

,case when lc.locationcode = 'HO' THEN 'Home Office'
      when lc.locationcode not in ('HO') and pufv.ufid is not null then 'Field Agent'
      when lc.locationcode not in ('HO') and pufv.ufid is null then 'Field Non-Agent'
      else 'Field Non-Agent' 
 end::char(15) as WorkLocation 
 
,' ' ::char(1) as Region
,ocdi.organizationdesc :: char(48) as Division
,ocd.organizationdesc :: char(48) as Department
,rtrim(ltrim(pa.streetaddress)) :: char(24) as WorkAddressLine1
,rtrim(ltrim(pa.streetaddress2)) :: char(24) as WorkAddressLine2
,rtrim(ltrim(pa.city)) ::char(16) as WorkAddressCity
,rtrim(ltrim(pa.stateprovincecode)) ::char(2) as WorkAddressState
,rtrim(ltrim(pa.postalcode)) :: char(5) as WorkAddressZIP
,'USA' :: char(3) as WorkAddressCountry
,' ' ::char(1) as ACASecurityKey
,' ' ::char(1) as WorkNumberUserID
, to_char(pe.emplservicedate,'MM/DD/YYYY')::char(10)  as AdjustedHireDate

, case when pe.emplstatus = 'T' and pe.effectivedate > pe.emplservicedate then to_char(date_part('year',age(greatest(pe.effectivedate,pe.emplservicedate))), 'fm00')
       when pe.emplstatus <> 'T' and payroll.periodenddate > pe.emplservicedate then to_char(date_part('year',age(greatest(payroll.periodenddate,pe.emplservicedate))), 'fm00') 
	else '00' end ::char(2) as YearsOfService
  
,' ' ::char(1) as MonthsOfService
,ocdi.organizationdesc :: char(48) as WorkNumberDivision
,' ' ::char(1) as WorkNumberDefaultPIN
,elu.lastupdatets

-- Footer

,' '  as Footer_Fill
,'Total Record, ' as totalRecord
,'Number of Payment Records =  ' as numPmtText

from person_identity pi

-- JOINS TO GET YEARS OF SERVICE-------------------
left join edi.edi_last_update elu on elu.feedid = 'HMN_Equifax_EmployeeInfo_Export' 

left join (select periodstartdate, periodenddate, periodpaydate from pay_schedule_period where processfinaldate is not null and payrolltypeid = '1') payroll
on payroll.periodpaydate >= elu.lastupdatets

-- PERSONAL DETAIL JOINS --------------------------------
LEFT JOIN person_identity pi2 
ON pi.personid = pi2.personid
AND pi2.identitytype = 'SSN' ::bpchar 
AND CURRENT_TIMESTAMP BETWEEN pi2.createts and pi2.endts 

LEFT JOIN person_names pn 
ON pn.personid = pi.personid 
AND pn.nametype = 'Legal'::bpchar 
and current_date between pn.effectivedate and pn.enddate
and current_timestamp between pn.createts and pn.endts

LEFT JOIN (select personid,streetaddress,streetaddress2,city,stateprovincecode,postalcode,countrycode,addresstype, max(effectivedate) as effectivedate,max(enddate) as enddate, RANK() OVER (PARTITION BY personid ORDER BY max(createts) DESC) AS RANK
from person_address 
where effectivedate < enddate and current_timestamp between createts and endts AND addresstype = 'Res' 
group by 1,2,3,4,5,6,7,8) pa ON pa.personid = pi.personid and pa.rank = 1

left join person_vitals pv
  on pv.personid = pi.personid
 and current_date between pv.effectivedate and pv.enddate
 and current_timestamp between pv.createts and pv.endts

LEFT JOIN person_net_contacts pncw
  ON pncw.personid = pi.personid 
 AND pncw.netcontacttype = 'WRK'::bpchar 
 AND current_date between pncw.effectivedate and pncw.enddate
 AND current_timestamp between pncw.createts and pncw.endts

left join (select distinct personid,netcontacttype,url,max(createts) as createts, max(effectivedate) as effectivedate,max(enddate) as enddate, RANK() OVER (PARTITION BY personid ORDER BY max(createts) DESC) AS RANK
from person_net_contacts where effectivedate < enddate and current_timestamp between createts and endts and netcontacttype in ('HomeEmail','OtherEmail')
group by 1,2,3) pnco on pnco.personid = pi.personid and pnco.rank = 1


-- EMPLOYMENT AND POSITION JOINS ------------------------------------------------------
left join person_employment pe on pe.personid = pi.personid
and current_date between pe.effectivedate and pe.enddate
and current_timestamp between pe.createts and pe.endts

left join (select personid, positionid, scheduledhours, schedulefrequency, max(effectivedate) as effectivedate,max(enddate) as enddate, RANK() OVER (PARTITION BY personid ORDER BY max(effectivedate) DESC) AS RANK
             from pers_pos where effectivedate < enddate and current_timestamp between createts and endts
            group by 1,2,3,4) perspos on perspos.personid = pe.personid and perspos.rank = 1

left join (select positionid, grade, positiontitle, flsacode, eeocode, max(effectivedate) as effectivedate, max(enddate) as enddate, RANK() OVER (PARTITION BY positionid ORDER BY max(effectivedate) DESC) AS RANK
             from position_desc where effectivedate < enddate and current_timestamp between createts and endts 
            group by 1,2,3,4,5) pd on pd.positionid = perspos.positionid and pd.rank = 1    
  
left join (select positionid,jobid, max(effectivedate) as effectivedate, RANK() OVER (PARTITION BY positionid ORDER BY max(effectivedate) DESC) AS RANK
	    from position_job where effectivedate < enddate and current_timestamp between createts and endts 
	    group by 1,2) pj on pj.positionid = perspos.positionid and pj.rank = 1

left join (select jobid, federaljobcodeid, jobexperience, max(effectivedate) as effectivedate, RANK() OVER (PARTITION BY jobid ORDER BY max(effectivedate) DESC) AS RANK
	    from job_desc where effectivedate < enddate and current_timestamp between createts and endts
	    group by 1,2,3) jd on pj.jobid = jd.jobid and jd.rank = 1

LEFT join federal_job_code fjc
on fjc.federaljobcodeid = jd.federaljobcodeid

-- LOGIC TO PULL THE PAY RATE AS OF THE CURRENT PAY PERIOD END DATE ------------------------------------------------------
left join (select pc.personid, pc.compamount,pc.frequencycode, max(pc.effectivedate) as effectivedate, RANK() OVER (PARTITION BY pc.personid ORDER BY max(pc.effectivedate) DESC) AS RANK
             from person_compensation pc
        left join person_payroll pp on pp.personid = pc.personid and pp.effectivedate < pp.enddate and current_timestamp between pp.createts and pp.endts
	left join pay_unit pu on pu.payunitid = pp.payunitid and current_timestamp between pp.createts and pp.endts
	left join pay_schedule_period psp on psp.payunitid = pu.payunitid and psp.processfinaldate is not null and psp.payrolltypeid = '1'
	where pc.effectivedate <= pc.enddate and current_timestamp between pc.createts and pc.endts and pc.effectivedate <= psp.periodenddate
            group by 1,2,3) pc on pc.personid = pe.personid and pc.rank = 1

left JOIN (select personid,payunitid,max(effectivedate) as effectivedate, RANK() OVER (PARTITION BY personid ORDER BY max(effectivedate) DESC) AS RANK
	    from person_payroll where effectivedate < enddate and current_timestamp between createts and endts
	    group by 1,2) pp ON pp.personid = pi.personid and pp.rank = 1

left JOIN pay_unit pu
ON pu.payunitid = pp.payunitid
AND CURRENT_TIMESTAMP BETWEEN pu.createts AND pu.endts
 
-- ORGANIZATION JOINS ------------------------------------------------
left join (select positionid,posorgreltype,organizationid, max(effectivedate) as effectivedate, RANK() OVER (PARTITION BY positionid ORDER BY max(effectivedate) DESC) AS RANK
	    from pos_org_rel where effectivedate < enddate and current_timestamp between createts and endts and posorgreltype = 'Member'
	    group by 1,2,3) pord on pord.positionid = perspos.positionid and pord.rank = 1

left JOIN (select organizationid,memberoforgid, max(effectivedate) as effectivedate, RANK() OVER (PARTITION BY organizationid ORDER BY max(effectivedate) DESC) AS RANK
	    from org_rel where effectivedate < enddate and current_timestamp between createts and endts
	    group by 1,2) orel ON orel.organizationid = pord.organizationid and orel.rank = 1
 
left JOIN (select organizationid,organizationtype,organizationdesc,max(effectivedate) as effectivedate, RANK() OVER (PARTITION BY organizationid ORDER BY max(effectivedate) DESC) AS RANK
	    from organization_code where effectivedate < enddate and current_timestamp between createts and endts AND organizationtype = 'Div' 
	    group by 1,2,3) ocdi ON ocdi.organizationid = orel.memberoforgid and ocdi.rank = 1
 
left JOIN (select organizationid,organizationtype,organizationdesc,max(effectivedate) as effectivedate, RANK() OVER (PARTITION BY organizationid ORDER BY max(effectivedate) DESC) AS RANK
	    from organization_code where effectivedate < enddate and current_timestamp between createts and endts AND organizationtype = 'Dept'
	    group by 1,2,3) ocd ON ocd.organizationid = pord.organizationid and ocd.rank = 1

left join (select personid,locationid,max(effectivedate) as effectivedate, RANK() OVER (PARTITION BY personid ORDER BY max(effectivedate) DESC) AS RANK
	    from person_locations where effectivedate < enddate and current_timestamp between createts and endts 
	    group by 1,2) pl ON pl.personid = perspos.personid and pl.rank = 1
 
LEFT JOIN (select locationid,locationcode, max(effectivedate) as effectivedate, RANK() OVER (PARTITION BY locationid ORDER BY max(effectivedate) DESC) AS RANK
	    from location_codes where effectivedate < enddate and current_timestamp between createts and endts 
	    group by 1,2) lc ON pl.locationid = lc.locationid and lc.rank = 1

-- AGENT JOIN ------------------------------------
LEFT JOIN (select personid,ufid,ufvalue,max(effectivedate) as effectivedate, RANK() OVER (PARTITION BY personid ORDER BY max(effectivedate) DESC) AS RANK
from person_user_field_vals pufv
where effectivedate < enddate AND CURRENT_TIMESTAMP BETWEEN createts and endts
AND ufid in (select ufid from user_field_desc where ufname = 'AgentType' 
and current_date between effectivedate and enddate 
and current_timestamp between createts and endts) group by 1,2,3) pufv ON pufv.personid = pi.personid and pufv.rank = 1


where pi.identitytype = 'EmpNo' 
and pi.identity is not NULL
AND current_timestamp BETWEEN pi.createts AND pi.endts
and (pe.emplstatus not in ('T','R') OR (pe.effectivedate > '2013-12-31' and pe.emplstatus in ('T','R')))
ORDER BY ssn

