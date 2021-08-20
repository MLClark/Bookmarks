SELECT distinct
pi.personid
,pp.positionid
,pie.identity::char(12) as person_number
,'0'||right(pi.identity,5)   ::char(6) as badge
,rtrim(ltrim(pn.fname))  ::char(25) as first_name
,rtrim(replace(pn.lname,',',' ')) ::char(35) as last_name
,to_char(pv.birthdate, 'mm/dd/yyyy') ::char(10) as dob
,to_char(pe.emplhiredate,'mm/dd/yyyy')::char(10) as doh
,to_char(pe.empllasthiredate,'mm/dd/yyyy')::char(10) as anniversary_date
--csl.organizationdesc  :: char(20) as Department,
,oc.organizationdesc  :: char(20) as Department
,pd.positiontitle  :: char(60) as Job
,case when pe.emplclass = 'F' then 'Full Time'
     when pe.emplclass = 'P' then 'Part Time'
     end :: char(20) as pay_rule
     
,pi.identity  ::char(12) as payroll_id
--csl.locationid,
,lc.locationdescription :: char(60)as  store
--csl.locationdescription :: char(60)as  store,
,case when pe.emplstatus = 'T' then to_char(pe.effectivedate,'mm/dd/yyyy') end :: char(20) as termination_date
,case when pe.emplclass  = 'F' then 'ft'
      when pe.emplclass  = 'P' then 'pt'
      when pe.emplclass  = 'PU' then 'pu'
      end :: char(2) as status
--pc.compamount ::char(20) as emp_wages
,case when pc.frequencycode = 'H' then pc.compamount
      when pc.frequencycode = 'A' then (pc.compamount / 2080)
      end :: char(20) as emp_wages


FROM person_identity pi

JOIN person_identity pie 
  ON pie.personid = pi.personid 
 AND pie.identitytype = 'EmpNo' ::bpchar 
 AND CURRENT_TIMESTAMP BETWEEN pie.createts and pie.endts 

left join pers_pos pp
  on pp.personid = pi.personid 
 and current_date between pp.effectivedate and pp.enddate
 AND current_timestamp BETWEEN pp.createts AND pp.endts

JOIN person_names pn 
  ON pn.personid = pi.personid 
 AND pn.nametype = 'Legal'::bpchar 
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts 

LEFT JOIN person_vitals pv 
  ON pv.personid = pi.personid 
 and current_date between pv.effectivedate and pv.enddate
 and current_timestamp between pv.createts and pv.endts

JOIN person_employment pe
  ON pe.personid = pi.personid
 AND current_date BETWEEN pe.effectivedate AND pe.enddate
 AND current_timestamp BETWEEN pe.createts AND pe.endts
 
 -- select * from person_locations where personid = '9495';
 -- select * from position_location where positionid = '21721';
 -- select * from location_codes where locationid = '50';

left JOIN person_locations pl 
  on pl.personid = pi.personid
 AND current_date BETWEEN pl.effectivedate AND pl.enddate
 AND current_timestamp BETWEEN pl.createts AND pl.endts

left join location_codes lc 
  on lc.locationid = pl.locationid
 AND current_date BETWEEN lc.effectivedate AND lc.enddate
 AND current_timestamp BETWEEN lc.createts AND lc.endts 

left JOIN position_desc pd 
  on pd.positionid  = pp.positionid
 and current_date between pd.effectivedate and pd.enddate
 AND current_timestamp BETWEEN pd.createts AND pd.endts

left join person_compensation pc  
 on pc.personid = pi.personid 
 AND current_date BETWEEN pc.effectivedate AND pc.enddate
 AND current_timestamp BETWEEN pc.createts AND pc.endts

LEFT JOIN pos_org_rel por
  ON por.positionid = pp.positionid 
 AND por.posorgreltype = 'Member'::bpchar 
 AND current_date between por.effectivedate AND por.enddate 
 AND current_timestamp between por.createts AND por.endts

LEFT JOIN organization_code oc
  ON oc.organizationid = por.organizationid 
 AND current_date between oc.effectivedate AND oc.enddate 
 AND current_timestamp between oc.createts AND oc.endts

where pi.identitytype = 'SSN' ::bpchar
  AND current_timestamp BETWEEN pi.createts AND pi.endts
 -- and pi.personid = '9495'

order by person_number 
