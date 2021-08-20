
--   Production Query

SELECT DISTINCT
  pi.identity as employeeid -- EMPNO
 ,pn.fname as firstname
 ,pn.mname as middlename
 ,pn.lname as lastname
 ,pnc.url
 ,pe.emplstatus
 ,pe.effectivedate as d_emplstatus
 ,pe.emplhiredate
 ,coalesce(pd.positiontitle,pdt.positiontitle) as positiontitle
 ,coalesce(pd.effectivedate,pdt.effectivedate) as d_positiontitle
 ,coalesce(pinSup1.employeeid,pinSupt.employeeid)::varchar(40) AS supervisorid
 ,coalesce(pinSup1.emailaddress,pinSupt.emailaddress)::varchar(100) AS supervisorurl
 ,coalesce(pinSup1.firstname,pinSupt.firstname)::varchar(100) AS sup_firstname
 ,coalesce(pinSup1.lastname,pinSupt.lastname)::varchar(100) AS sup_lastname
 ,coalesce(ppSup1.effectivedate,ppSupt.effectivedate)::varchar(100) AS sup_date
 ,coalesce(por.effectivedate,port.effectivedate) as d_department
 ,coalesce(oc.organizationdesc,oct.organizationdesc) as department
 ,coalesce(oc.orgcode,oct.orgcode) as deptnum
 ,coalesce(pl.effectivedate,plt.effectivedate) as d_location
 ,coalesce(lc.locationdescription,lct.locationdescription) as location
 ,case pe.emplstatus
		when 'T' then pe.effectivedate
		else null
  end as TermDate

FROM person_identity pi  
JOIN edi.edi_last_update elu
  on elu.feedid = 'RND_NewHire_Term'

left join
  (select personid,max(positionid) as positionid from pers_pos
    where current_timestamp between createts and endts
      and current_timestamp between createts and endts
      group by 1) ppt
  on ppt.personid = pi.personid
    

LEFT JOIN person_names pn 
  ON pn.personid = pi.personid 
 AND pn.nametype = 'Legal'::bpchar 
 AND current_date between pn.effectivedate AND pn.enddate 
 AND current_timestamp between pn.createts AND pn.endts
 
LEFT JOIN person_net_contacts pnc 
  ON pnc.personid = pi.personid 
 AND pnc.netcontacttype = 'WRK'::bpchar
 AND current_date between pnc.effectivedate AND pnc.enddate 
 AND current_timestamp between pnc.createts AND pnc.endts


left join person_employment pe 
  on pe.personid = pi.personid 
 and CURRENT_DATE BETWEEN pe.effectivedate AND pe.enddate 
 and CURRENT_TIMESTAMP BETWEEN pe.createts AND pe.endts 

left join person_locations pl 
  on pl.personid = pi.personid 
 and CURRENT_DATE BETWEEN pl.effectivedate AND pl.enddate 
 and CURRENT_TIMESTAMP BETWEEN pl.createts AND pl.endts

left join location_codes lc 
  on lc.locationid = pl.locationid 
 and CURRENT_DATE BETWEEN lc.effectivedate AND lc.enddate 
 and CURRENT_TIMESTAMP BETWEEN lc.createts AND lc.endts

/*  Supervisor */
LEFT JOIN pos_pos ppSup1 
  ON ppSup1.topositionid = ppt.positionid
 AND ppSup1.posposrel = 'Manages'
 AND CURRENT_DATE BETWEEN ppSup1.effectivedate AND ppSup1.enddate
 AND CURRENT_TIMESTAMP BETWEEN ppSup1.createts AND ppSup1.endts

LEFT JOIN pers_pos ppoSup1 
  ON ppoSup1.positionid = ppSup1.positionid
 AND CURRENT_DATE BETWEEN ppoSup1.effectivedate AND ppoSup1.enddate
 AND CURRENT_TIMESTAMP BETWEEN ppoSup1.createts AND ppoSup1.endts
 
LEFT JOIN edi.etl_personal_info pinSup1 
  ON pinSup1.personid = ppoSup1.personid


left join pos_org_rel por 
  on por.positionid = ppt.positionid 
 and CURRENT_DATE BETWEEN por.effectivedate AND por.enddate 
 and CURRENT_TIMESTAMP BETWEEN por.createts AND por.endts 
 and por.posorgreltype = 'Member'

left join organization_code oc 
  on oc.organizationid = por.organizationid 
 and oc.organizationtype = 'Dept' 
 and CURRENT_DATE BETWEEN oc.effectivedate AND oc.enddate 
 and CURRENT_TIMESTAMP BETWEEN oc.createts AND oc.endts

left join position_desc pd 
  on pd.positionid = ppt.positionid 
 and CURRENT_DATE BETWEEN pd.effectivedate AND pd.enddate 
 and CURRENT_TIMESTAMP BETWEEN pd.createts AND pd.endts

left join person_payroll pp 
  on pp.personid = pi.personid 
 and CURRENT_DATE BETWEEN pp.effectivedate AND pp.enddate 
 and CURRENT_TIMESTAMP BETWEEN pp.createts AND pp.endts

left join pay_schedule_period psp 
  on psp.payunitid = pp.payunitid 
 --and current_date between psp.periodstartdate and psp.periodenddate
 --and '2017/07/01' between psp.periodstartdate and psp.periodenddate
 and elu.lastupdatets::date >= psp.periodstartdate 
 and elu.lastupdatets::date <= psp.periodenddate
 
left join pers_pos pos
  on pos.personid = pi.personid
 and current_date between pos.effectivedate and pos.enddate
 and current_timestamp between pos.createts and pos.endts 
 

---- Terminated Employees 


 
left join position_desc pdt
  on pdt.positionid = ppt.positionid 
  and CURRENT_DATE BETWEEN pd.effectivedate AND pd.enddate 
  and CURRENT_TIMESTAMP BETWEEN pdt.createts AND pdt.endts
  --and pdt.positionevent = 'Title'
 
/*  Terminated Employee's Supervisor */
LEFT JOIN pos_pos ppSupt
  ON ppSupt.topositionid = ppt.positionid
 AND ppSupt.posposrel = 'Manages'
 AND CURRENT_DATE BETWEEN ppSupt.effectivedate AND ppSupt.enddate
 AND CURRENT_TIMESTAMP BETWEEN ppSupt.createts AND ppSupt.endts

LEFT JOIN pers_pos ppoSupt 
  ON ppoSupt.positionid = ppSupt.positionid
 AND CURRENT_DATE BETWEEN ppoSupt.effectivedate AND ppoSupt.enddate
 AND CURRENT_TIMESTAMP BETWEEN ppoSupt.createts AND ppoSupt.endts
 
LEFT JOIN edi.etl_personal_info pinSupt 
  ON pinSupt.personid = ppoSupt.personid
  
   
/* Terminated Employee's Dept, Location */

left join pos_org_rel port 
  on port.positionid = ppt.positionid
 and CURRENT_DATE BETWEEN port.effectivedate AND port.enddate 
 and CURRENT_TIMESTAMP BETWEEN port.createts AND port.endts 
 and port.posorgreltype = 'Member'

left join organization_code oct 
  on oct.organizationid = port.organizationid 
 and oct.organizationtype = 'Dept' 
 and CURRENT_DATE BETWEEN oct.effectivedate AND oct.enddate 
 and CURRENT_TIMESTAMP BETWEEN oct.createts AND oct.endts

left join person_locations plt 
  on plt.personid = pi.personid 
 and CURRENT_DATE BETWEEN plt.effectivedate AND plt.enddate 
 and CURRENT_TIMESTAMP BETWEEN plt.createts AND plt.endts

left join location_codes lct 
  on lct.locationid = plt.locationid 
 and CURRENT_DATE BETWEEN lct.effectivedate AND lct.enddate 
 and CURRENT_TIMESTAMP BETWEEN lct.createts AND lct.endts
   

WHERE pi.identitytype = 'EmpNo'::bpchar 
  AND current_timestamp between pi.createts AND pi.endts 
  --and pi.personid = '116666'
  and (pos.effectivedate >= elu.lastupdatets 
   or pe.effectivedate >= elu.lastupdatets)


ORDER BY pn.lname