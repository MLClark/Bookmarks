select distinct
 pi.personid
,'11320' ::char(5) as company_code
,'HMN00' ::char(5) as pay_group
,pu.employertaxid  :: char(9) as fein
,left(pi.identity,3)||'-'||substring(pi.identity,4,2)||'-'||right(pi.identity,4) ::char(11) as ssn
,pie.identity ::char(9) as empno
,'N' ::char(1) as assignment_id
,'N' ::char(1) as billing_code
,'0' ::char(1) as primary_assignment
,case when pe.emplstatus = 'A' then 'A' else 'I' end :: char(1) as current_status
,to_char(pe.empllasthiredate,'MM/DD/YYYY')::char(10) as original_hire_date
,to_char(pe.emplsenoritydate,'MM/DD/YYYY')::char(10) as last_hire_date 
,to_char(pe.emplsenoritydate,'MM/DD/YYYY')::char(10) as last_recent_start_date 
,case when pe.emplstatus = 'T' then to_char(pe.effectivedate,'MM/DD/YYYY') else ' ' end ::char(10) as term_date
,pn.fname ::varchar(40) as fname
,pn.lname ::varchar(40) as lname
,pn.mname ::char(1) as mname
,case when pc.frequencycode = 'A' then trunc(pc.compamount / 2080,2) else trunc(pc.compamount,2) end as hourly_rate
,'HY' ::char(2) as pay_type
,'SM' ::char(2) as semi_monthly
,pa.streetaddress ::varchar(40) as addr1
,pa.streetaddress2 ::varchar(40) as addr2
,pa.city ::varchar(40) as city
,pa.stateprovincecode ::char(2) as state
,pa.postalcode ::varchar(9) as zip
,'USA' ::char(3) as country
,pncw.url ::varchar(50) AS WorkEmail
,to_char(pv.birthdate,'MM/DD/YYYY') ::char(10) as dob
,pv.gendercode ::char(1) as gender
,' ' ::char(2) as union_affiliat
,case when pd.positiontitle = 'Agent' then 'AM' else ' ' end ::char(2) as emp_class_code
,' ' ::char(1) as emp_class_label
,case when pe.emplclass = 'F' then 'FT'
      when pe.emplclass = 'P' then 'PT'
      when pe.emplclass = 'T' then 'S'
      else null end :: char(2)  as aca_employee_designation_code 
,'CG1EC1' ::char(6) as aca_emp_category_code
,'H' ::char(1) as aca_pay_type_classification_code
,coalesce(pd.positiontitle, ' '):: char(50) as job_title_desc
,case when pd.eeocode = '50' then '5'
      when pd.eeocode = '60' then '6'
      when pd.eeocode = '11' then 'A'
      when pd.eeocode = '12' then '1'
      when pd.eeocode = '80' then '8'
      when pd.eeocode = '70' then '7'
      when pd.eeocode = '20' then '2'
      when pd.eeocode = '40' then '4'
      when pd.eeocode = '90' then '9'
      when pd.eeocode = '30' then '3'
      else ' ' end ::char(1) as job_class_code
,case when pd.eeocode = '50' then '5'
      when pd.eeocode = '60' then '6'
      when pd.eeocode = '11' then 'A'
      when pd.eeocode = '12' then '1'
      when pd.eeocode = '80' then '8'
      when pd.eeocode = '70' then '7'
      when pd.eeocode = '20' then '2'
      when pd.eeocode = '40' then '4'
      when pd.eeocode = '90' then '9'
      when pd.eeocode = '30' then '3'
      else ' ' end ::char(1) as job_class_label      

,case when lc.locationdescription = 'Home Office' then 'HO' 
      when lc.locationdescription = 'Agent' then 'FA'
      else 'FN' end :: char(4) as work_location

,' ' ::char(1) as region
,oc_div.orgcode :: char(10) as division_code
,oc.orgcode :: char(10) as department_code      
,' ' ::char(1) as work_addr1
,' ' ::char(1) as work_addr2
,' ' ::char(1) as work_city      
,' ' ::char(1) as work_state
,' ' ::char(1) as work_zip
,' ' ::char(1) as work_country
,' ' ::char(1) as aca_security_key
,' ' ::char(1) as work_nbr_user_id
,to_char(pe.emplhiredate,'MM/DD/YYYY')    ::char(10) as adj_hire_date ---- use service date
,case when pe.emplstatus = 'T' then 
           cast(date_part('year',age(pe.effectivedate,pe.emplhiredate)) + (date_part('month',age(pe.effectivedate,pe.emplhiredate)) * .10) as dec (18,0))
           else cast(date_part('year',age(current_date,pe.emplhiredate)) + (date_part('month',age(current_date,pe.emplhiredate)) * .10) as dec (18,0)) end 
           as years_of_service  

,' ' ::char(1) as months_of_service
,oc_div.orgcode :: char(10) as division_code
,' ' ::char(1) as work_nbr_default_pin      
 
from person_identity pi

join person_identity pie
  on pie.personid = pi.personid
 and pie.identitytype = 'EmpNo'
 and current_timestamp between pie.createts and pie.endts

join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts 
 
join person_names pn
  on pn.personid = pi.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts 

join person_compensation pc
  on pc.personid = pi.personid
 and current_date between pc.effectivedate and pc.enddate
 and current_timestamp between pc.createts and pc.endts 

join person_address pa
  on pa.personid = pi.personid
 and pa.addresstype = 'Res'
 and current_date between pa.effectivedate and pa.enddate
 and current_timestamp between pa.createts and pa.endts

left join person_net_contacts pncw
  on pncw.personid = pi.personid 
 and pncw.netcontacttype = 'WRK'::bpchar 
 and current_date between pncw.effectivedate and pncw.enddate
 and current_timestamp between pncw.createts and pncw.endts
 and pncw.effectivedate - interval '1 day' <> pncw.enddate   

join person_vitals pv
  on pv.personid = pi.personid
 and current_date between pv.effectivedate and pv.enddate
 and current_timestamp between pv.createts and pv.endts  
 
join pers_pos pp  
  on pp.personid = pi.personid
 and current_date between pp.effectivedate and pp.enddate
 and current_timestamp between pp.createts and pp.endts
 
join position_desc pd 
  on pd.positionid = pp.positionid
 and current_date between pd.effectivedate and pd.enddate
 and current_timestamp between pd.createts and pd.endts 
 
left join pos_org_rel por 
  on por.positionid = pp.positionid 
 and por.posorgreltype = 'Member'
 and CURRENT_DATE between por.effectivedate and por.enddate
 and current_timestamp between por.createts and por.endts

left join organization_code oc
  on oc.organizationid = por.organizationid 
  and oc.organizationtype in ('Div', 'Dept')
 and CURRENT_DATE BETWEEN oc.effectivedate AND oc.enddate 
 and CURRENT_TIMESTAMP BETWEEN oc.createts AND oc.endts   
  
left join organization_code oc_dept
  on oc_dept.organizationid = por.organizationid 
 and oc_dept.organizationtype = 'Dept'
 and CURRENT_DATE BETWEEN oc_dept.effectivedate AND oc_dept.enddate 
 and CURRENT_TIMESTAMP BETWEEN oc_dept.createts AND oc_dept.endts 

LEFT JOIN org_rel org_rel 
  ON org_rel.organizationid = oc.organizationid 
 and org_rel.orgreltype = 'Management'::bpchar   
 AND current_date between org_rel.effectivedate AND org_rel.enddate 
 AND current_timestamp between org_rel.createts AND org_rel.endts 
 
left join organization_code oc_div 
  on oc_div.organizationid = org_rel.memberoforgid
 and oc_div.organizationtype =  'Div'
 and CURRENT_DATE BETWEEN oc_div.effectivedate AND oc_div.enddate 
 and CURRENT_TIMESTAMP BETWEEN oc_div.createts AND oc_div.endts       

LEFT JOIN primarylocation pl
  ON pl.personid = pi.personid
 AND current_date BETWEEN pl.effectivedate AND pl.enddate
 AND current_timestamp BETWEEN pl.createts AND pl.endts 

LEFT JOIN location_codes lc
  ON lc.locationid = pl.locationid
 AND current_date BETWEEN lc.effectivedate AND lc.enddate
 AND current_timestamp BETWEEN lc.createts AND lc.endts  


 
join pay_unit pu
  on pu.payunitdesc = 'HMN00'
 and current_timestamp between pu.createts and pu.endts

where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts 