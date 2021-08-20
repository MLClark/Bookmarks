
select
 pi.personid
,pi.netid as employeeid
--	pi.employeeid,  Changed because Schwab did not want leading zeros
,pi.lastname
,pi.firstname
,pi.middlename
,pi.employeessn
,pi.birthdate
,pi.emailaddress
,pi.workphone
,pi.streetaddress1
,pi.streetaddress2
,pi.city
,pi.statecode
,pi.zipcode
,pi.countrycode
,current_date as rundate
,'Y' as employee_flag

/*
"Updated 5/2020:
Based on 2 user fields (Section 16 and LTIPP)
3 options in this order
A - Section 16 is Y 
I - LTIPP is Y (but section 16 is N/blank)
N - Neither Section 16 or LTIPP"
*/

,case when S16.personid is not null then 'A'
      when ltipp.personid is not null and S16.personid is null then 'I'
      when ltipp.personid is null and S16.personid is null then 'N'
       end ::char(1) as OfficerType

,S16.personid as s16
,ltip.personid as ltip
,ltipp.personid as ltipp           

,oc.orgcode
,ed.emplhiredate
,eed.empleventdetcode
,case eed.empleventdetcode 
      when 'Death' then 'IDeath'
      when 'Dis' then 'IDis'
      when 'InT' then 'InT'
      when 'SRed' then 'IRed'
      when 'END' then 'VEND'
      when 'VT' then 'VT'
      when 'RDth' then 'RDth'
      when 'RInT' then 'RInT'
      when 'RDis' then 'RDis'
      when 'RIF' then 'RRIF'
      when 'RVT' then 'RVol' end ::varchar(20) as TermTypeCode
,case pe.emplstatus when 'T' then pe.effectivedate else null end as termdate
,case eed.empleventdetcode when 'RH' then pe.effectivedate else null end as rehiredate
,(mgr_pi.firstname || ' ' || mgr_pi.lastname)::varchar(200) as mgr_name
,medicareytd.taxable_wage as medicare_wages
,fica.withheld as ssn_withheld
,dis.withheld as disability_withheld
,sup.taxable_wage as sup_compensation
,ed.positiontitle
,oc1.organizationdesc as division_description
from edi.etl_personal_info pi

join edi.etl_employment_data ed on pi.personid = ed.personid

join (select distinct personid from person_user_field_vals
       where ufid in (select ufid from user_field_desc where ufname in ('Section16','LTIPP','LTIP'))
	 and current_date between effectivedate and enddate
	 and current_timestamp between createts and endts
	 and ufvalue = 'Y') puf on puf.personid = pi.personid

left join (select distinct personid from person_user_field_vals
	    where ufid in (select ufid from user_field_desc where ufname = 'Section16')
	      and current_date between effectivedate and enddate
	      and current_timestamp between createts and endts
	      and ufvalue = 'Y') S16 on S16.personid = pi.personid

left join (select distinct personid from person_user_field_vals
	    where ufid in (select ufid from user_field_desc where ufname ='LTIP')
	      and current_date between effectivedate and enddate
	      and current_timestamp between createts and endts
	      and ufvalue = 'Y') ltip on ltip.personid = pi.personid

left join (select distinct personid from person_user_field_vals
	    where ufid in (select ufid from user_field_desc where ufname ='LTIPP')
	      and current_date between effectivedate and enddate
	      and current_timestamp between createts and endts
	      and ufvalue = 'Y') ltipp on ltipp.personid = pi.personid	      

left join pers_pos pp on pp.personid = pi.personid
 and current_date between pp.effectivedate and pp.enddate
 and current_timestamp between pp.createts and pp.endts
 and pp.persposrel = 'Occupies'
	
left join pos_org_rel por on por.positionid = pp.positionid
 and current_date between por.effectivedate and por.enddate
 and current_timestamp between por.createts and por.endts
 and por.posorgreltype = 'Budget'

left join organization_code oc on por.organizationid = oc.organizationid
 and current_date between oc.effectivedate and oc.enddate
 and current_timestamp between oc.createts and oc.endts
 and oc.organizationtype = 'CC'

left join pos_org_rel por1 on por1.positionid = pp.positionid
 and current_date between por1.effectivedate and por1.enddate
 and current_timestamp between por1.createts and por1.endts
 and por1.posorgreltype = 'Member'

left join org_rel orel on orel.organizationid = por1.organizationid
 and current_date between orel.effectivedate and orel.enddate
 and current_timestamp between orel.createts and orel.endts
 and orel.orgreltype = 'Management'

left join organization_code oc1 on orel.memberoforgid = oc1.organizationid
 and current_date between oc1.effectivedate and oc1.enddate
 and current_timestamp between oc1.createts and oc1.endts
 and oc1.organizationtype = 'Div'

left join person_employment pe on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts

left join employment_event_detail eed on eed.empleventdetcode = pe.empleventdetcode

left join pos_pos ppos on ppos.topositionid = pp.positionid
 and current_date between ppos.effectivedate and ppos.enddate
 and current_timestamp between ppos.createts and ppos.endts

left join edi.etl_employment_data mgr_ed on mgr_ed.positionid = ppos.positionid

left join edi.etl_personal_info mgr_pi on mgr_pi.personid = mgr_ed.personid

--- ytd Medicare taxable wage   
LEFT JOIN (SELECT ppd.personid,	sum(ppd.etv_taxable_wage) as taxable_wage
            FROM pspay_payment_detail ppd
            join pspay_payment_header pph on ppd.paymentheaderid = pph.paymentheaderid
           WHERE ppd.etv_id in ('T13')
-- : You are still adding Medicare and Medicare HI together you only need to include YTD Medicare Wages 
--           WHERE ppd.etv_id in ('T12', 'T13')
             AND date_part('year', ppd.check_date) = date_part('year',?::DATE)
             AND ppd.check_date <= ?::DATE 
	   group by 1 ) medicareytd ON medicareytd.personid = pi.personid  

--- ytd FICA withheld  (Social Security "T01" + Medicare "T12" + "T13")
-- The spec has been changed to just Social Security (T01)
LEFT JOIN (SELECT ppd.personid,	sum(ppd.etv_amount) as withheld
             FROM pspay_payment_detail ppd
	     join pspay_payment_header pph on ppd.paymentheaderid = pph.paymentheaderid
            WHERE ppd.etv_id in ('T01')
              AND date_part('year', ppd.check_date) = date_part('year',?::DATE)
              AND ppd.check_date <= ?::DATE 
            GROUP BY 1 ) fica ON fica.personid = pi.personid  

--- ytd State Disability withheld  (Sum amount for current year)
left join (SELECT distinct personid,sum(etv_amount) AS withheld
             FROM pspay_payment_detail 
            WHERE etv_id in ('T09', 'T10', 'T19', 'T20')
              AND date_part('year', check_date) = date_part('year',?::DATE)
              AND check_date <= ?::DATE 
            GROUP BY personid ) dis on dis.personid = pi.personid

-- ytd Supplemental Earnings
LEFT JOIN (SELECT distinct personid,sum(etv_amount) AS taxable_wage
             FROM pspay_payment_detail 
            WHERE etv_id in (select etv_id from pspay_etv_operators where etvindicator = 'E' and group_key <> '$$$$$' and opcode = 'A'
	      and etv_id not in ('E01', 'EBF', 'EAY', 'EC9', 'EC8', 'ECB') group by 1)
              AND date_part('year', check_date) = date_part('year',?::DATE)
              AND check_date <= ?::DATE 
         GROUP BY personid) sup on sup.personid = pi.personid

order by pi.lastname

