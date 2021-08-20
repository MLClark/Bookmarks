select distinct
 pie.personid
,pl.locationid
,LC.SALARYGRADEREGION
,pie.identity as employee_nbr
--,pis.identity   ::char(9) as ssn
,left(pis.identity,3)||'-'||substring(pis.identity,4,2)||'-'||right(pis.identity,4) ::char(11) as ssn_wdashes
,pn.lname  ::varchar(50) as lastname
,pn.fname  ::varchar(50)as firstname
,pn.mname  ::varchar(50)as middlename

,'??' ::char(2) as position_code --- waiting on Julius to load data 

,pa.streetaddress  ::varchar(50)as address1
,pa.streetaddress2 ::varchar(50)as address2
,pa.city ::varchar(50)
,pa.stateprovincecode ::char(2) as state
,pa.postalcode  ::char(5) as zip
--,pa.countrycode ::char(2) as country

,sgrl_v.salarygraderegiondesc ::varchar(25) as emp_class_id
,ppch.phoneno     ::char(10) as homephone
,case when pv.gendercode = 'M' then '1' else '2' end ::char(1) as sex
,to_char(pv.birthdate,'MM/DD/YYYY') ::char(10) as dob
,to_char(pe.emplhiredate,'MM/DD/YYYY') ::char(10)  as hiredate

,'??' ::char(10) as last_review_date
,case when pv.ethniccode = 'W' then '1'
      when pv.ethniccode = 'I' then '2'
      when pv.ethniccode = 'B' then '3'
      when pv.ethniccode = 'H' then '4'
      when pv.ethniccode = 'T' then '6'
      when pv.ethniccode = 'P' then '8' else '7' end ::char(1) as ethnic_code
,pc.compamount as rate
,coalesce(oc.orgcode,oct.orgcode) ::varchar(50) as department   --- org level 3
,'?' as filing_status
,'?' as fed_exempt
,la.stateprovincecode ::char(2) as tax_state_code
,'?' as state_filing_status
,'?' as state_self_exempt
,'?' as state_exempt
,'?' as local_withheld
,'?' as local_code
,'?' as add_fed_wh
,'?' as add_state_wh




--,ltrim(cn.companycodesearch,' ') ::char(3) as companyid
--,pu.payunitdesc ::char(5) as paygroup

--,pe.emplstatus ::char(1) as empstatus
--,pe.emplclass  ::char(1) as emptype

--,case when pe.empleventdetcode = 'RH' then to_char(pe.empllasthiredate,'MM/DD/YYYY') else NULL end ::char(10) as rehiredate
--,to_char(pe.emplsenoritydate,'MM/DD/YYYY') ::char(10) as adjsenioritydate
--,case when pe.emplstatus in ('T','R') then to_char(pe.effectivedate,'MM/DD/YYYY') else NULL end ::char(10) as termdate
--,pc.frequencycode     ::char(1) as freq_code
--,pp.schedulefrequency ::char(1) as payfrequency
--,pp.scheduledhours as defaulthours
--,pm.maritalstatus ::char(1) as marital_status
--,pdd.positionxid  ::char(5) as positioncode
--,prr.deptcode ::varchar(50) as deptlevel1
--,prr.divcode  ::varchar(50) as divlevel2

--,coalesce(oc.organizationdesc,oct.organizationdesc) as department
--,coalesce(oc.orgcode,oct.orgcode) ::varchar(50) as deptnum
--,prr.orgcode  ::varchar(50) as orglevel3
--,coalesce(oc.orgcode,oct.orgcode) ::varchar(50) as orglevel3
--,prr.cccode   ::varchar(50) as costcenterlevel4
--,prr.cc5code  ::varchar(50) as costcenterlevel5
--,pdd.flsacode ::char(1) as flsacode
--,(case when pe.emplstatus = 'T' then pe.empleventdetcode else NULL end)::varchar(20) as termreason
--,NULL as citizenship
--,(pnn.fname || ' ' || pnn.lname)::varchar(255) as nickname
--,pn.title ::varchar(50) as salutations
--,(case when pdd.dtip = 'Y' then 'D' else NULL end)::varchar(1) as tipped

--,to_char(pup.periodstartdate,'MM/DD/YYYY') ::char(10) as firstPayDate
--,dc.disabilitycodedesc ::varchar(25) as disabilitydesc
--,case when pv.smoker = 'Y' then 1 else 0 end ::char(1) as smoker
--,ppcw.phoneno ::char(10) as workphone
--,pncw.url::varchar(255) as emailAddress
--,case when pv.deathdate <> NULL then 1 else 0 end ::char(1) as deceased
--,mpi.identity as ManagerEmpNo
--,pdd.positiontitle ::varchar(50) as PositionTitle



from person_employment pe
join edi.edi_last_update elu on elu.feedid = 'BEF_StandardPayrollExtract'

left join person_names pn 
  on pn.personid = pe.personid
 and pn.nametype = 'Legal'
 and current_timestamp between pn.createts and pn.endts
 and CURRENT_DATE between pn.effectivedate and pn.enddate
 and pn.pernamespid = 
     (select max(pernamespid) 
        from person_names pn2 
       where pn2.personid = pn.personid
			and pe.effectivedate between pn2.effectivedate and pn2.enddate
			and current_timestamp between pn2.createts and pn2.endts
			and pn2.nametype = 'Legal')
	 
left outer join person_names pnn
	 on (pnn.personid = pe.personid 
	and pnn.nametype = 'Pref'
	and CURRENT_DATE between pnn.effectivedate and pnn.enddate
	and current_timestamp between pnn.createts and pnn.endts)			
			
left outer join person_vitals pv
     on (pv.personid = pe.personid
	 and CURRENT_DATE between pv.effectivedate and pv.enddate
	 and current_timestamp between pv.createts and pv.endts)
	
left outer join person_identity pie
     on (pie.personid = pe.personid
     and pie.identitytype = 'EmpNo' and pie.endts > NOW())
left outer join person_identity pis
     on (pis.personid = pe.personid
     and pis.identitytype = 'SSN'   and pis.endts > NOW())
left outer join person_identity pin
     on (pin.personid = pe.personid 
     and pin.identitytype = 'NetId' and pin.endts > NOW())     
     
left outer join person_address pa
     on (pa.personid = pe.personid
     and pa.addresstype = 'Res'
     and CURRENT_DATE between pa.effectivedate and pa.enddate
     and current_timestamp between pa.createts and pa.endts)
     
left outer join person_phone_contacts ppch
     on (ppch.personid = pe.personid 
     and ppch.phonecontacttype = 'Home'
     and CURRENT_DATE between ppch.effectivedate and ppch.enddate
     and current_timestamp between ppch.createts and ppch.endts)
left outer join person_phone_contacts ppcw
     on (pe.personid = ppcw.personid 
     and ppcw.phonecontacttype = 'BUSN'
     and CURRENT_DATE between ppcw.effectivedate and ppcw.enddate
     and current_timestamp between ppcw.createts and ppcw.endts
     and ppcw.percontactpid = 
        (select max(ppcw2.percontactpid) 
           from person_phone_contacts ppcw2 
          where ppcw2.personid = ppcw.personid
			   and CURRENT_DATE between ppcw2.effectivedate and ppcw2.enddate
			   and current_timestamp between ppcw2.createts and ppcw2.endts
			   and ppcw2.phonecontacttype = 'BUSN'))
			
left outer join person_net_contacts pncw
     on (pncw.personid = pe.personid 
     and pncw.netcontacttype = 'WRK'
     and CURRENT_DATE between pncw.effectivedate and pncw.enddate
     and current_timestamp between pncw.createts and pncw.endts)			
			
left outer join person_maritalstatus pm
     on (pm.personid = pe.personid
     and CURRENT_DATE between pm.effectivedate and pm.enddate
     and current_timestamp between pm.createts and pm.endts)
     
left outer join person_disability pd
     on (pd.personid = pe.personid
     and CURRENT_DATE between pd.effectivedate and pd.enddate
     and current_timestamp between pd.createts and pd.endts)   
left outer join disability_code dc
     on (pd.disabilitycode = dc.disabilitycode)

left outer join person_compensation pc
     on (pe.personid = pc.personid
     and CURRENT_DATE between pc.effectivedate and pc.enddate
     and current_timestamp between  pc.createts and  pc.endts
     and pc.earningscode in ('ExcHrly', 'RegHrly','Regular'))
     
     
left outer join pers_pos pp
     on  (pe.personid = pp.personid
     and CURRENT_DATE between pp.effectivedate and pp.enddate
     and current_timestamp between pp.createts and pp.endts)
left outer join position_desc pdd
     on (pp.positionid = pdd.positionid
     and CURRENT_DATE between pdd.effectivedate and pdd.enddate
     and current_timestamp between  pdd.createts and  pdd.endts)

left outer join person_payroll ppy
     on (pe.personid = ppy.personid
     and CURRENT_DATE between ppy.effectivedate and ppy.enddate
     and current_timestamp between ppy.createts and ppy.endts )
     
left join
  (select personid,max(positionid) as positionid from pers_pos
    where current_timestamp between createts and endts
      and current_timestamp between createts and endts
      group by 1) ppt
  on ppt.personid = pe.personid

     

left outer join pay_unit_periods pup
     on (ppy.payunitid = pup.payunitid
     and pup.periodenddate = 
         (select min(periodenddate)
		      from pay_unit_periods ppp 
		     where ppp.payunitid = ppy.payunitid
			    and ppp.checkdate > pe.effectivedate))
			    
left join pos_org_rel por 
       on pp.positionid = por.positionid
	   and por.posorgreltype = 'Member'
	   and CURRENT_DATE between por.effectivedate and por.enddate
	   and current_timestamp between por.createts and por.endts
left join personResolveRelationshipsUpdt prr 
       on pp.personid = prr.personid
      and pp.positionid = prr.positionid
      and pp.perspospid = prr.perspospid


 ---- end of added joins to fix unknown supersvisor

left join organization_code oc 
  on oc.organizationid = por.organizationid 
 and oc.organizationtype = 'Dept' 
 and CURRENT_DATE BETWEEN oc.effectivedate AND oc.enddate 
 and CURRENT_TIMESTAMP BETWEEN oc.createts AND oc.endts

 ---- end of added joins to fix unknown supersvisor
 
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

left join pay_unit pu on (ppy.payunitid = pu.payunitid)


---- Managers

left join pos_pos mpp 
       on mpp.topositionid = pp.positionid
	   and mpp.posposrel = 'Manages'
	   and CURRENT_DATE between mpp.effectivedate and mpp.enddate
	   and current_timestamp between mpp.createts and mpp.endts
left join pers_pos mppos 
       on mpp.positionid = mppos.positionid
	   and mppos.persposrel = 'Occupies'
	   and CURRENT_DATE between mppos.effectivedate and mppos.enddate
	   and current_timestamp between mppos.createts and mppos.endts   
left join person_identity mpi 
       on mppos.personid = mpi.personid
	   and current_timestamp between mpi.createts and mpi.endts
	   and mpi.identitytype = 'EmpNo'

--- locations
left outer join person_locations pl
     on (pe.personid = pl.personid and pl.personlocationtype = 'P'
     and CURRENT_DATE between pl.effectivedate and pl.enddate
     and current_timestamp between pl.createts and pl.endts)
left outer join location_address la
     on (pl.locationid = la.locationid
     and CURRENT_DATE between la.effectivedate and la.enddate
     and current_timestamp between la.createts and la.endts)
left outer join location_codes lc
       on lc.locationid = pl.locationid
      and current_date between lc.effectivedate and lc.enddate
      and current_timestamp between lc.createts and lc.endts     
	   
left join personcompanyrel pcr_v
       on pcr_v.personid = pe.personid
	   
left join companyname cn 
       on pu.companyid = cn.companyid
      and current_date between cn.effectivedate and cn.enddate
      and current_timestamp between cn.createts and cn.endts

--- the following view provides employee class id - in ehcm this equates to salary grade region values           
       
left join public.salarygraderegionlist sgrl_v 
       on sgrl_v.companyid = cn.companyid
     -- and sgrl_v.companyid = pcr_v.companyid
      and sgrl_v.code = lc.salarygraderegion
  
             
       
where ((pe.emplstatus not in ('T', 'R', 'D', 'V', 'X')) 
    OR (pe.emplstatus in ('T', 'R', 'D', 'V', 'X') 
   and pe.effectivedate >= current_date - interval '30 days'))
	and pe.enddate > NOW() and pe.effectivedate <= pe.enddate
	and current_timestamp between pe.createts and pe.endts
	and pe.effectivedate >= elu.lastupdatets
	
	and pn.lname is not null
	--and pe.personid in ('10')
 
 --order by pe.personid, termdate, pc.frequencycode) persimp
 



