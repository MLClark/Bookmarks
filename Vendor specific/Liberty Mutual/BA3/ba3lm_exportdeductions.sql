SELECT DISTINCT
--  epi.employeessn
'000000000'::varchar(20) as employeessn
, epi.trankey

, pit.effectivedate, psp.periodstartdate, psp.periodenddate

, upper(epi.lastname)::char (20) as lastname
, upper(epi.firstname)::char(20) as firstname
, epi.middlename::char(1)
, epi.employeeid
, eit.feedid
, pp.payunitid
, eit.trackingcode
, ediemp.emplstatus::char(1) as employmentstatuscode
, to_char(ppd.check_date, 'YYYYMMdd')::varchar(8) as chkdate
, to_char(ediemp.empleffectivedate, 'YYYYMMdd')::varchar(8) as statuseffdate
-- change to use payunitxid
, CASE WHEN pu.payunitxid = '00' THEN '52'
     WHEN pu.payunitxid = '05' THEN '26'
	 WHEN pu.payunitxid = '15' THEN '26'
	  END::varchar(2) AS payrollfreq
, ppd.etv_amount::numeric as deductionamtSUM
, ppd.etv_amount::varchar(20) as ds1
, pu.payunitdesc::varchar(50)
, pit.tran_data::numeric
, pp.personid
, now() as updatets

FROM edi.edi_import_tracking eit

--FROM pspay_payment_detail ppd

left join edi.etl_personal_info epi on epi.personid = eit.personid

left JOIN pspay_payment_detail ppd on ppd.personid = eit.personid
 and ppd.etv_id in ('VCO')
 and ppd.etv_amount IS NOT NULL
 and ppd.check_date = ?

left JOIN pspay_payment_header pph on epi.trankey = pph.individual_key
 and pph.check_date = ppd.check_date
 and pph.payment_number = ppd.payment_number

--left JOIN (select substring(individual_key,1,5) paygroup, payment_number , '2017-05-13'::date as last_check_date
--              from pspay_payment_header group by 1,2) lstchk on ppd.check_date = lstchk.last_check_date 
--				and substring(ppd.individual_key,1,5) = lstchk.paygroup 
--				AND lstchk.payment_number =  ppd.payment_number

--				and individual_key = epi.trankey

-- join (select substring(individual_key,1,5) paygroup, max(check_date) as last_check_date 
--              from pspay_payment_header group by 1) lstchk on ppd.check_date = lstchk.last_check_date and substring(ppd.individual_key,1,5) = lstchk.paygroup

JOIN edi.etl_employment_data ediemp ON epi.personid = ediemp.personid

LEFT JOIN person_payroll pp ON epi.personid = pp.personid
     AND current_date between pp.effectivedate and pp.enddate
     AND current_timestamp between pp.createts and pp.endts

LEFT JOIN pay_unit pu ON pu.payunitid = pp.payunitid
     AND current_date between pp.effectivedate and pp.enddate
     AND current_timestamp between pp.createts and pp.endts

LEFT JOIN pspay_etv_list pel on ppd.etv_id = pel.etv_id
	and pel.group_key = ppd.group_key   

left join pay_schedule_period psp on psp.periodpaydate = ?
	and psp.payunitid = pu.payunitid

left join person_identity pi on pi.personid = eit.personid
	AND current_timestamp between pi.createts and pi.endts
	and identitytype = 'PSPID'

left join pspay_input_transaction pit on pit.individual_key = pi.identity
	and pit.effectivedate between psp.periodstartdate and psp.periodenddate
--	and pit.effectivedate between pph.period_begin_date and pph.period_end_date
	and substring(pit.primary_key_idd_name from 3 for 2) = 'CO'

--where ppd.etv_id in ('VCO')
--  and ppd.etv_amount IS NOT NULL
--  and eit.trackingcode is not null
where eit.trackingcode is not null
  and eit.feedid = 'BA3LM_ImportBilling'
  and eit.responsesentts is null
  and eit.trackingdate < ?

order by eit.trackingcode,
		 payrollfreq,
		 chkdate
