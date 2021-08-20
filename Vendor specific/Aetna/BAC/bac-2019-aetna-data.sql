/*
emplclass = 'P' is part time
emplclass = 'F' is full time
*/

select
	pi.identity::char(9) as ssn,
	pi.identity::varchar(10) as alternateid,
	pn.lname::varchar(20) as lastname,
	pn.fname::varchar(15) as firstname,
	left(pn.mname,1)::char(1) as middleinitial,
	pn.formofaddress as prefix,
	pn.title as suffix,
	case pv.gendercode
		when 'F' then '1'
		when 'M' then '2'
	end::char(1) as gender,
	to_char(pv.birthdate,'YYYYMMDD')::char(8) as birthdate,
	pa.streetaddress AS streetaddress1,
	pa.streetaddress2,
	case	when pa.countrycode in ('US', 'UM', 'VA', 'CA') then pa.city
		else 'ZZ'
	end::varchar(50) as city,
	case	when pa.countrycode in ('US', 'UM', 'VA', 'CA') then pa.stateprovincecode
		else 'ZZ'
	end::char(8) as statecode,
	case	when pa.countrycode in ('US', 'UM', 'VA', 'CA') then pa.postalcode
		else 'ZZ'
	end::varchar(15) as zipcode,
	ppch.phoneno AS homephone,
	ppcm.phoneno AS cellphone,
	ppcw.phoneno AS workphone,
	to_char(pe.empllasthiredate,'YYYYMMDD')::char(8) as lasthiredate,
	to_char(pe.emplhiredate,'YYYYMMDD')::char(8) as hiredate,
	to_char(pe.emplsenoritydate,'YYYYMMDD')::char(8) as senoritydate,
	pe.emplstatus,
	case when pe.emplstatus in ('T', 'R', 'D') then to_char(pe.effectivedate,'YYYYMMDD')
	end::char(8) as termdate,
	coalesce(pd.positiontitle,eetd.positiontitle) as positiontitle,
	case	when la.countrycode in ('US', 'UM', 'VA', 'CA') then la.stateprovincecode
		else 'ZZ'
	end::char(8) as workstate,
	case	when la.countrycode in ('US', 'UM', 'VA', 'CA') then la.countrycode
		else 'ZZ'
	end::varchar(5) as workcountry,
	pnc.url::varchar(100) as workemail,
/*
pp.schedulefrequency,
pp.scheduledhours,
pc.compamount,
fc.annualfactor,
pu.frequencycode,
pu.payunitid,
*/
	case coalesce(pp.schedulefrequency,eetd.payfreq) 
		when 'B' then coalesce(pp.scheduledhours,eetd.scheduledhours) / 2
		else coalesce(pp.scheduledhours,eetd.scheduledhours)
	end as scheduledhours,
	
	case coalesce(pd.flsacode,eetd.flsacode)
		when 'N' then '1'
		when 'E' then '0'
	end::char(1) as flsastatus,
	
	case pu.frequencycode
		--when 'B' then coalesce(pc.compamount,eetd.compamount) / 2 * coalesce(fc.annualfactor,fct.annualfactor)
		when 'B' then coalesce(pc.compamount,eetd.compamount) * coalesce(fc.annualfactor,fct.annualfactor)
		when 'W' then coalesce(pc.compamount,eetd.compamount) * coalesce(fc.annualfactor,fct.annualfactor)
	end as salary,
	
	'06'::char(2) as basis,
	
	case coalesce(pc.frequencycode,eetd.frequencycode)
		when 'H' then 'H'
		when 'A' then 'S'
	end::char(1) as grade,
	
	to_char(coalesce(pc.effectivedate, eetd.compeffectivedate ),'YYYYMMDD')::char(8) as salarydate,

	case when pu.payunitxid in ('05','15') then 'Union'
		else 'NonUnion'
	end::varchar(20) as unionidentifier,

	lc.locationcode,
	pe.emplclass as employmentclass,
	'0473296' as STD1controlnumber,
	'014' as STD1suffix,
	'00001' as STD1account,

	case	when pu.payunitxid in ('00','10','28','29') then '201'
			when pu.payunitxid in ('20','25') then '202'
			when pu.payunitxid in ('15') then '206'
			when pu.payunitxid in ('05') then '207'
	end::char(3) as STD1planid,

	('BAC' || pu.payunitxid)::varchar(20) as reportinglevel1,

/*	coalesce(
			case pu.frequencycode
				when 'B' then (earnings.hours / 2)
				when 'W' then earnings.hours
			end, 0.0) as hours, */

	coalesce(earnings.hours,0) as hours,

	case pu.frequencycode
		when 'B' then '08'
		when 'W' then '04'
	end::char(2) as PP_Frequency,
	to_char(psp.periodstartdate,'YYYYMMDD')::char(8) as periodstartdate,
	to_char(psp.periodenddate,'YYYYMMDD')::char(8) as periodenddate,
	'0473296' as FMLAControlNum,
	'050' as FMLASuffix,
	'00001' as FMLAAccount,
	'301' as FMLAPlanId,

        pip.identity as individual_key,

	pe.emplhiredate as rawemplhiredate

from	person_employment pe
	join person_names pn ON pn.personid = pe.personid AND pn.nametype = 'Legal'::bpchar AND 'now'::text::date >= pn.effectivedate AND 'now'::text::date <= pn.enddate AND now() >= pn.createts AND now() <= pn.endts
	join person_identity pi ON pi.personid = pe.personid AND pi.identitytype = 'SSN'::bpchar AND now() >= pi.createts AND now() <= pi.endts
	left join person_vitals pv ON pv.personid = pe.personid AND 'now'::text::date >= pv.effectivedate AND 'now'::text::date <= pv.enddate AND now() >= pv.createts AND now() <= pv.endts
	left join person_address pa ON pa.personid = pe.personid AND pa.addresstype = 'Res'::bpchar AND 'now'::text::date >= pa.effectivedate AND 'now'::text::date <= pa.enddate AND now() >= pa.createts AND now() <= pa.endts
	left join person_phone_contacts ppch ON ppch.personid = pe.personid AND ppch.phonecontacttype = 'Home'::bpchar AND 'now'::text::date >= ppch.effectivedate AND 'now'::text::date <= ppch.enddate AND now() >= ppch.createts AND now() <= ppch.endts
	left join person_phone_contacts ppcm ON ppcm.personid = pe.personid AND ppcm.phonecontacttype = 'Mobile'::bpchar AND 'now'::text::date >= ppcm.effectivedate AND 'now'::text::date <= ppcm.enddate AND now() >= ppcm.createts AND now() <= ppcm.endts
	left join person_phone_contacts ppcw ON ppcw.personid = pe.personid AND ppcw.phonecontacttype = 'Work'::bpchar AND 'now'::text::date >= ppcw.effectivedate AND 'now'::text::date <= ppcw.enddate AND now() >= ppcw.createts AND now() <= ppcw.endts
	left join person_locations pl ON pl.personid = pe.personid AND pl.personlocationtype = 'P'::bpchar AND 'now'::text::date >= pl.effectivedate AND 'now'::text::date <= pl.enddate AND now() >= pl.createts AND now() <= pl.endts
	left join location_codes lc on lc.locationid = pl.locationid AND 'now'::text::date >= lc.effectivedate AND 'now'::text::date <= lc.enddate AND now() >= lc.createts AND now() <= lc.endts
	left join location_address la on pl.locationid = la.locationid AND 'now'::text::date >= la.effectivedate AND 'now'::text::date <= la.enddate AND now() >= la.createts AND now() <= la.endts
	left join person_net_contacts pnc ON pnc.personid = pe.personid AND pnc.netcontacttype = 'WRK'::bpchar AND 'now'::text::date >= pnc.effectivedate AND 'now'::text::date <= pnc.enddate AND now() >= pnc.createts AND now() <= pnc.endts
	left join pers_pos pp ON pe.personid = pp.personid AND 'now'::text::date >= pp.effectivedate AND 'now'::text::date <= pp.enddate AND now() >= pp.createts AND now() <= pp.endts
	left join position_desc pd ON pp.positionid = pd.positionid AND 'now'::text::date >= pd.effectivedate AND 'now'::text::date <= pd.enddate AND now() >= pd.createts AND now() <= pd.endts
	left join person_compensation pc ON pe.personid = pc.personid and pc.earningscode in ('Regular','ExcHrly', 'RegHrly') AND 'now'::text::date >= pc.effectivedate AND 'now'::text::date <= pc.enddate AND now() >= pc.createts AND now() <= pc.endts
	left join person_payroll ppl ON pe.personid = ppl.personid AND 'now'::text::date >= ppl.effectivedate AND 'now'::text::date <= ppl.enddate AND now() >= ppl.createts AND now() <= ppl.endts
	left join pay_unit pu on pu.payunitid = ppl.payunitid
	left join frequency_codes fc on pc.frequencycode = fc.frequencycode
	left join person_identity pip on pip.personid = pe.personid and pip.identitytype = 'PSPID' and current_timestamp between pip.createts and pip.endts

	left join edi.etl_employment_term_data eetd on eetd.personid = pe.personid 
	left join frequency_codes fct on eetd.frequencycode = fct.frequencycode

	
--	left join pay_schedule_period psp on psp.payunitid = pu.payunitid and psp.periodpaydate = coalesce(?::DATE, ?::date - (7 || 'days')::interval)

/*	left join (select distinct individual_key ,sum(etype_hours) as hours
				from pspay_payment_detail
				where	etv_code = 'EE' and
						check_date = ?::DATE and
						check_number <> 'INIT REC'
				group by individual_key
			) earnings
	on earnings.individual_key = pip.identity
*/


LEFT JOIN (select individual_key, sum(ppdx.etype_hours) as hours
			from pspay_payment_detail ppdx 
               left JOIN (select substring(individual_key,1,5) as paygroup, max(check_date) as last_check_date from pspay_payment_header group by 1) lastchk2 ON  lastchk2.paygroup = substring(ppdx.individual_key,1,5)
			where ppdx.etv_id IN ('E01', 'E02')
			and ppdx.check_number <> 'INIT REC'
			and ppdx.check_date = lastchk2.last_check_date
			group by ppdx.individual_key) earnings on earnings.individual_key = pip.identity


left join (
	select payunitid, max(periodstartdate) as periodstartdate, max(periodenddate) as periodenddate
	from pay_schedule_period
	where periodpaydate < current_date
	group by payunitid) psp on psp.payunitid = pu.payunitid

where
	(((pe.emplstatus in ('A', 'L') and pe.emplclass = 'F' and pe.employmenttype = 'P' and 'now'::text::date >= pe.effectivedate AND 'now'::text::date <= pe.enddate AND now() >= pe.createts AND now() <= pe.endts) or
	 (pe.emplstatus in ('T', 'R', 'D') and 'now'::text::date >= pe.effectivedate AND 'now'::text::date <= pe.enddate AND now() >= pe.createts AND now() <= pe.endts and 'now'::text::date < pe.effectivedate::date + ( 30 || ' days')::interval) or
	 (pe.emplevent like 'FullPart%' and 'now'::text::date >= pe.effectivedate AND 'now'::text::date <= pe.enddate AND now() >= pe.createts AND now() <= pe.endts and 'now'::text::date < pe.effectivedate::date + ( 30 || ' days')::interval))) and
	not (pu.payunitxid = '05' and now() < pe.emplhiredate::date + '1 year'::interval) and
	not (pu.payunitxid != '05' and now () < date_trunc('month',(pe.emplhiredate::date + '60 days'::interval)::date + '1 month'::interval))

--order by pu.payunitxid
--order by scheduledhours
ORDER BY pn.lname

/*
Augusta union employees (payunitxid = 05) have a 1 year waiting period from date of hire before they can file a STD claim.  
All other employees have a benefits eligibility waiting period of first of the month after 60 days.  
Once their benefits effective date hits, they can file for STD.  
*/
