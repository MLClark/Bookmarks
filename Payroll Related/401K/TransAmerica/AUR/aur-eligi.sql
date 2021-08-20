 select

pi.personid
,pe.effectivedate
,els.lastupdatets
,pe.createts
,pip.identity as pspid
,pe.emplcategory
,pu.payunitdesc
,pu.payunitxid 
,'02' as sort_seq
,'02' ::char(2) as recordtype
,'ELIGIBLE EE'   ::varchar(50) as qsource
,lc.locationdescription ::char(5) as location -- use business unit (org structure)
,' ' ::char(5) as sub_company_nbr
,' ' ::char(5) as group_code
,pi.identity ::char(9) as ssn
,'' ::char(5) as title
,pn.fname ::char(15) as fname
,' ' ::char(5) as fillers
,pn.mname ::char(1) as mname
,pn.lname ::char(20) as lname 
,'' ::char(4) as suffix         -- check this
,cast(0.00 as dec(10,2)) as EEPreTax
,cast(0.00 as dec(10,2)) as EEPreTaxCatch_up
,cast(0.00 as dec(10,2)) as EERoth
,cast(0.00 as dec(10,2)) as EERothCatch_up
,'00000000.00' ::char(11) as EEPostTax
,'00000000.00' ::char(11) as EEMandatoryAfterTax
,cast(0.00 as dec(10,2)) as ERMatch
,'00000000.00' ::char(11) as ERNonMatch
,'00000000.00' ::char(11) as ERSafeHarborMatch
,'00000000.00' ::char(11) as ERSafeHarborNonMatch
,'00000000.00' ::char(11) as ERMoneyPurchase
,'00000000.00' ::char(11) as ERFullyVestedMoneyPurchase
,'00000000.00' ::char(11) as ERPrevailingWage
,'00000000.00' ::char(11) as QMAC
,'00000000.00' ::char(11) as QNEC
,cast(0.00 as dec(10,2)) as LoanRepayments
,cast(0.00 as dec(10,2)) as CompensationYTD
,'00000000.00' ::char(11) as ExcludedCompensationYTD
,'0000' ::char(4) as HoursWorkedYTD

,case when pa.countrycode = 'US' then '1' else '0' end ::char(1) as IsUSAddress
,'"'||pa.streetaddress||'"' ::char(33) as addr1
,'"'||pa.streetaddress2||'"' ::char(33) as addr2
,pa.city ::char(25) as city
,pa.stateprovincecode ::char(2) as state
,pa.postalcode ::char(5) as zip
,' ' ::char(25) as INTLCityProvice
,' ' ::char(10) as INTLZipPostalCode
,' ' ::char(20) as INTLCountry
,to_char(pv.birthdate,'YYYYMMDD')::char(8) as dob
,to_char(least(pe.effectivedate,pe.emplservicedate,pe.emplhiredate),'YYYYMMDD') ::char(8) as doh
,case when pe.emplstatus = 'T' then to_char(pe.effectivedate,'YYYYMMDD') else ' ' end ::char(8) as dot
,case when pe.emplevent = 'Rehire' then to_char(pe.empllasthiredate,'YYYYMMDD') else ' ' end ::char(8) as dor
,'00000000.00' ::char(11) as ERQACANon_Elective
,'00000000.00' ::char(11) as ERQACAMatch
,'00000000.00' ::char(11) as ERALTMatch
,'00000000.00' ::char(11) as ERALTProfitSharing
,'00000000.00' ::char(11) as ERALTMoneyPurchase
,coalesce(pncw.url,pnch.url) ::char(60) as work_email
,cast(0.00 as dec(10,2)) as total_payroll_amount

,'01' ::char(2) as hdr_recordtype
,'PeopleStrategy' ::char(30) as hdr_vendorname 
,to_char(current_timestamp,'YYYYMMDDhhmmss')::char(14) as hdr_file_create_dt
,'517540' ::char(9) as hdr_contractid
,'00000' ::char(5) as hdr_subid
,'0' ::char(1) as hdr_ismep
,'Kumho Tire Georgia' ::char(40) as hdr_company_name
,to_char(psp.periodpaydate::date,'yyyymmdd') ::char(8) as hdr_check_date            --test
,'0' ::char(1) as hdr_deposit_method
,' ' ::char(26) as hdr_ach_number
,'' ::char(8) as hdr_mode --- VALIDATE for test blank for prod

-- Errors

, 'Negative Contributions on the 401K Contributions file. Contact vendor.' as error1
,els.lastupdatets

from person_identity pi

join edi.edi_last_update els on els.feedid = 'AUR_TransAmerica_401k_Contributions_Export_mlc'       

join person_identity pip
  on pip.personid = pi.personid
 and pip.identitytype = 'PSPID'
 and current_timestamp between pip.createts and pip.endts                           

join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts	

join person_names pn
  on pn.personid = pi.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts

join person_address pa 
  on pa.personid = pi.personid
 and pa.addresstype = 'Res'
 and current_date between pa.effectivedate and pa.enddate
 and current_timestamp between pa.createts and pa.endts

join person_vitals pv
  on pv.personid = pi.personid
 and current_date between pv.effectivedate and pv.enddate
 and current_timestamp between pv.createts and pv.endts

left join ( select personid, url, max(effectivedate) as effectivedate,  RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
              from person_net_contacts where netcontacttype = 'HomeEmail' and current_date between effectivedate and enddate and current_timestamp between createts and endts
             group by personid, url) pnch on pnch.personid = pe.personid and pnch.rank = 1 

left join ( select personid, url, max(effectivedate) as effectivedate,  RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
              from person_net_contacts where netcontacttype = 'WRK' and current_date between effectivedate and enddate and current_timestamp between createts and endts
             group by personid, url) pncw on pncw.personid = pe.personid and pncw.rank = 1   
   
LEFT JOIN person_payroll pp 
  on pp.personid = pi.personid 
 and CURRENT_DATE BETWEEN pp.effectivedate AND pp.enddate 
 and CURRENT_TIMESTAMP BETWEEN pp.createts AND pp.endts

left join person_locations pl
  on pl.personid = pi.personid
 and current_date between pl.effectivedate and pl.enddate
 and current_timestamp between pl.createts and pl.endts

left join location_codes lc
  on lc.locationid = pl.locationid
and current_date between lc.effectivedate and lc.enddate
and current_timestamp between lc.createts and lc.endts  

LEFT JOIN pay_unit pu 
  ON pu.payunitid = pp.payunitid
 AND current_timestamp between pu.createts and pu.endts
 
join pay_schedule_period psp 
  on psp.payrolltypeid in (1,2)  
 and psp.processfinaldate is not null
 and psp.periodpaydate >= els.lastupdatets	
 and psp.payunitid = pu.payunitid 

/*     
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  and (pe.emplcategory not in ('KBSP','KBSO') or pe.emplcategory is null)
  and pe.emplstatus not in ('R','T') 
  and (pe.emplevent in ('Hire','Rehire','PartFull') or pe.empleventdetcode in ('BAC','BC'))
  and pe.emplclass = 'F' 

  and (pe.effectivedate >= els.lastupdatets::DATE or (pe.createts > els.lastupdatets and pe.effectivedate < coalesce(els.lastupdatets, '2017-01-01')) )
  and (pe.personid not in (select personid from person_deduction_setup where current_date between effectivedate and enddate and current_timestamp between createts and endts and etvid  in  ('V73','V65','VB1','VB2','VB3','VB4','VB5') )
  and  pe.personid in (select ppd.personid from pspay_payment_detail ppd where ppd.paymentheaderid in (select paymentheaderid from pspay_payment_header where payscheduleperiodid in  (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in (select pspaypayrollid from pspay_payroll ppay join edi.edi_last_update elu on elu.feedid = 'AUR_TransAmerica_401k_Contributions_Export_mlc' and elu.lastupdatets <= ppay.statusdate where ppay.pspaypayrollstatusid = 4 )))) )
  
 
  (select ppd.personid from pspay_payment_detail ppd 
		   join pspay_payment_header pph on ppd.paymentheaderid = pph.paymentheaderid
		   join pay_schedule_period psp on psp.payscheduleperiodid = pph.payscheduleperiodid
		   where ppd.paymentheaderid in 
			(select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
			(select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay 
		           join edi.edi_last_update elu on elu.feedid = 'AUR_TransAmerica_401k_Contributions_Export_mlc' and elu.lastupdatets <= ppay.statusdate
                          where ppay.pspaypayrollstatusid = 4 )))      
		   and ppd.etv_id in ('V73','V65','VB1','VB2','VB3','VB4','VB5') group by 1)
		   
*/		   
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  and (pe.emplcategory not in ('KBSP','KBSO') or pe.emplcategory is null)
  and pe.emplstatus not in ('R','T') 
  and (pe.emplevent in ('Hire','Rehire','PartFull') or pe.empleventdetcode in ('BAC','BC'))
  and pe.emplclass = 'F' 
  and pe.personid not in 
  (select ppd.personid from pspay_payment_detail ppd 
		   join pspay_payment_header pph on ppd.paymentheaderid = pph.paymentheaderid
		   join pay_schedule_period psp on psp.payscheduleperiodid = pph.payscheduleperiodid
		   where ppd.paymentheaderid in 
			(select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
			(select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay 
		           join edi.edi_last_update elu on elu.feedid = 'AUR_TransAmerica_401k_Contributions_Export_mlc' and elu.lastupdatets <= ppay.statusdate
                          where ppay.pspaypayrollstatusid = 4 )))      
		   and ppd.etv_id in ('V73','V65','VB1','VB2','VB3','VB4','VB5') group by 1)
 and (pe.effectivedate >= els.lastupdatets::DATE
  or (pe.createts > els.lastupdatets and pe.effectivedate < coalesce(els.lastupdatets, '2017-01-01')) )
  order by 8,1,2,hdr_check_date

  
  