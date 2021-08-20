select
* from
(select
pi2.identity as employeeid,
pn.personid,
cn.companycodesearch as companyid,
pu.payunitdesc as paygroup,
pn.lname as lastname,
pn.fname as firstname,
pn.mname as middlename,
pa.streetaddress as address1,
pa.streetaddress2 as address2,
pa.city,
pa.stateprovincecode as state,
pa.postalcode as zip,
pa.countrycode as country,
pii.identity as ssn,
pv.birthdate,
pv.gendercode as sex,
pe.emplstatus as empstatus,
pe.emplclass as emptype,
pe.emplhiredate as hiredate,
case when pe.empleventdetcode = 'RH' then pe.empllasthiredate
else NULL end as rehiredate,
pe.emplsenoritydate as adjsenioritydate,
case when pe.emplstatus in ('T','R') then pe.effectivedate
else NULL end as termdate,
pc.frequencycode,
pp.schedulefrequency as payfrequency,
pp.scheduledhours as defaulthours,
ppc.phoneno as homephone,
pv.ethniccode as ethnicity,
pm.maritalstatus,
pdd.positionxid as positioncode,
prr.deptcode::varchar(50) as deptlevel1,
prr.divcode::varchar(50) as divlevel2,
prr.orgcode::varchar(50) as orglevel3,
prr.cccode::varchar(50) as costcenterlevel4,
prr.cc5code::varchar(50) as costcenterlevel5,
pdd.flsacode,
(case when pe.emplstatus = 'T' then pe.empleventdetcode
else NULL end)::varchar(20) as termreason,
NULL as citizenship,
(pnn.fname || ' ' || pnn.lname)::varchar(255) as nickname,
pn.title as salutations,
(case when pdd.dtip = 'Y' then 'D'
else NULL end)::varchar(1) as tipped,
la.stateprovincecode as workstate,
pup.periodstartdate as firstPayDate,
dc.disabilitycodedesc as disabilitydesc,
case when pv.smoker = 'Y' then 1
else 0 end as smoker,
ppcw.phoneno as workphone,
pnc.url::varchar(255) as emailAddress,
case when pv.deathdate <> NULL then 1
else 0 end as deceased,
mpi.identity as ManagerEmpNo,
pdd.positiontitle as PositionTitle
from person_employment pe
left join person_names pn on pe.personid = pn.personid
	and pn.nametype = 'Legal'
	and current_timestamp between pn.createts and pn.endts
	and CURRENT_DATE between pn.effectivedate and pn.enddate
	and pn.pernamespid = (select max(pernamespid) from person_names pn2 where pn2.personid = pn.personid
				and pe.effectivedate between pn2.effectivedate and pn2.enddate
				and current_timestamp between pn2.createts and pn2.endts
				and pn2.nametype = 'Legal')
left outer join person_vitals pv
    on( pe.personid = pv.personid
	and CURRENT_DATE between pv.effectivedate and pv.enddate
	and current_timestamp between  pv.createts and  pv.endts)
left outer join person_names pnn
	on( pe.personid = pnn.personid and pnn.nametype = 'Pref'
	and CURRENT_DATE between pnn.effectivedate and pnn.enddate
	and current_timestamp between  pnn.createts and  pnn.endts)
left outer join person_identity pi2
      on (pe.personid = pi2.personid
             and pi2.identitytype = 'EmpNo' and pi2.endts > NOW())
left outer join person_identity pii
       on (pe.personid = pii.personid
             and pii.identitytype = 'SSN' and pii.endts > NOW())
left outer join person_address pa
      on (pa.personid = pe.personid
      and pa.addresstype = 'Res'
      and CURRENT_DATE between pa.effectivedate and pa.enddate
      and current_timestamp between pa.createts and pa.endts)
left outer join person_phone_contacts ppc
      on (pe.personid = ppc.personid and ppc.phonecontacttype = 'Home'
      and CURRENT_DATE between ppc.effectivedate and ppc.enddate
      and current_timestamp between ppc.createts and ppc.endts)
left outer join person_phone_contacts ppcw
      on (pe.personid = ppcw.personid and ppcw.phonecontacttype = 'BUSN'
      and CURRENT_DATE between ppcw.effectivedate and ppcw.enddate
      and current_timestamp between ppcw.createts and ppcw.endts
      and ppcw.percontactpid = (select max(ppcw2.percontactpid) from person_phone_contacts ppcw2 where ppcw2.personid = ppcw.personid
			and CURRENT_DATE between ppcw2.effectivedate and ppcw2.enddate
			and current_timestamp between ppcw2.createts and ppcw2.endts
			and ppcw2.phonecontacttype = 'BUSN'))
left outer join person_maritalstatus pm
       on (pe.personid = pm.personid
       and CURRENT_DATE between pm.effectivedate and pm.enddate
       and current_timestamp between pm.createts and pm.endts)
left outer join person_disability pd
       on(pe.personid = pd.personid
       and CURRENT_DATE between pd.effectivedate and pd.enddate
       and current_timestamp between pd.createts and pd.endts)
left outer join disability_code dc
       on(pd.disabilitycode = dc.disabilitycode)
left outer join person_net_contacts pnc
       on (pe.personid = pnc.personid and pnc.netcontacttype = 'WRK'
       and CURRENT_DATE between pnc.effectivedate and pnc.enddate
       and current_timestamp between pnc.createts and pnc.endts)
left outer join person_compensation pc
      on (pe.personid = pc.personid
      and CURRENT_DATE between pc.effectivedate and pc.enddate
      and current_timestamp between  pc.createts and  pc.endts
      and pc.earningscode like '%Reg%')
left outer join pers_pos pp
      on  (pe.personid = pp.personid
      and CURRENT_DATE between pp.effectivedate and pp.enddate
      and current_timestamp between pp.createts and pp.endts)
left outer join position_desc pdd
      on (pp.positionid = pdd.positionid
      and CURRENT_DATE between pdd.effectivedate and pdd.enddate
      and current_timestamp between  pdd.createts and  pdd.endts)
left outer join person_locations pl
      on (pe.personid = pl.personid and pl.personlocationtype = 'P'
      and CURRENT_DATE between pl.effectivedate and pl.enddate
      and current_timestamp between pl.createts and pl.endts)
left outer join location_address la
      on (pl.locationid = la.locationid
      and CURRENT_DATE between la.effectivedate and la.enddate
      and current_timestamp between la.createts and la.endts)
left outer join person_payroll ppy
      on (pe.personid = ppy.personid
      and CURRENT_DATE between ppy.effectivedate and ppy.enddate
      and current_timestamp between ppy.createts and ppy.endts )
left outer join person_identity pi3
       on (pe.personid = pi3.personid and pi3.identitytype = 'NetId' and pi3.endts > NOW())
left outer join pay_unit_periods pup
      on (ppy.payunitid = pup.payunitid
      and pup.periodenddate = (select min(periodenddate)
			from pay_unit_periods ppp where ppp.payunitid = ppy.payunitid
			and ppp.checkdate > pe.effectivedate))
left join pos_org_rel por on pp.positionid = por.positionid
	and por.posorgreltype = 'Member'
	and CURRENT_DATE between por.effectivedate and por.enddate
	and current_timestamp between por.createts and por.endts
left join personResolveRelationshipsUpdt prr on pp.personid = prr.personid
    and pp.positionid = prr.positionid
    and pp.perspospid = prr.perspospid
left join pay_unit pu on (ppy.payunitid = pu.payunitid)
left join pos_pos mpp on mpp.topositionid = pp.positionid
	and mpp.posposrel = 'Manages'
	and CURRENT_DATE between mpp.effectivedate and mpp.enddate
	and current_timestamp between mpp.createts and mpp.endts
left join pers_pos mppos on mpp.positionid = mppos.positionid
	and mppos.persposrel = 'Occupies'
	and CURRENT_DATE between mppos.effectivedate and mppos.enddate
	and current_timestamp between mppos.createts and mppos.endts
left join person_identity mpi on mppos.personid = mpi.personid
	and current_timestamp between mpi.createts and mpi.endts
	and mpi.identitytype = 'EmpNo'
left join companyname cn on pu.companyid = cn.companyid
where ((pe.emplstatus not in ('T', 'R', 'D', 'V', 'X')) OR (pe.emplstatus in ('T', 'R', 'D', 'V', 'X') and pe.effectivedate >= current_date - interval '30 days'))
	and pe.enddate > NOW() and pe.effectivedate <= pe.enddate
	and current_timestamp between pe.createts and pe.endts
 order by pe.personid, termdate, frequencycode) persimp
 