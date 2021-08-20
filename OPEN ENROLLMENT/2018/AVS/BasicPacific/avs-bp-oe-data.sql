select distinct

 pi.personid

,'ACTIVE EES' ::varchar(40) as qsource
,'CBA' ::char(3) as tpa_code
,'VDG' ::char(3) as co_code
,upper(left(pn.lname,2)||'VDG'||right(pi.identity,4)) ::char(10) as employee_identifier
,pie.identity ::varchar(10) as er_ee_id

,pn.lname ::varchar(50) as lname
,pn.mname ::char(1) as mname
,pn.fname ::varchar(50) as fname

,pi.identity ::char(9) as ssn 
,pa.streetaddress ::varchar(50) as addr1
,pa.streetaddress2 ::varchar(50) as addr2
,pa.city ::varchar(50) as city
,pa.stateprovincecode ::char(2) as state
,pa.postalcode ::char(5) as zip
,pa.countrycode ::char(2) as country
,upper(left(pn.lname,2)||date_part('year',pv.birthdate)||right(pi.identity,4)) ::char(10) as username
,'PASSWORD' ::char(8) as password
,rtrim(ltrim(pncw.url)) ::varchar(100) as work_email 
,left(ppch.phoneno,3) ::char(3) as areacode_h
,right(ppch.phoneno,7) ::char(7) as phone_h
,left(ppcw.phoneno,3) ::char(3) as areacode_w
,right(ppcw.phoneno,7) ::char(7) as phone_w
,' ' ::char(1) as ext_w
,to_char(pv.birthdate,'mm/dd/yyyy')::char(10) as dob
,pm.maritalstatus ::char(1) as maritalstatus
,pv.gendercode ::char(1) as gender 
,null as maiden_name
,case when lc.locationid = '14' then 'Lexus Monterey Peninsula'
      when lc.locationid = '13' then 'Lexus Monterey Peninsula'
      when lc.locationid = '16' then 'Mid Bay Ford Lincoln'
      when lc.locationid = '15' then 'Monterey Bay Chrysler Dodge Jeep Ram'
      when lc.locationid = '17' then 'Lexus Monterey Peninsula'
      when lc.locationid = '18' then 'Victory Toyota'
      when lc.locationid = '10' then 'Victory Toyota' else null end ::varchar(50) as divsions 
,case when pe.emplstatus = 'T' then 'Terminated'
      when pe.emplstatus = 'A' then 'Active'
      when pe.emplstatus = 'L' then 'LOA'
      when pe.emplstatus = 'P' then 'LOA'      
      else ' ' end ::varchar(15) as status
,'ALL' ::char(3) as empl_class
,case when pu.frequencycode = 'S' then 'S24-15/EOM'
      when pu.frequencycode = 'M' then 'M12-5' 
      end ::varchar(10) as payroll_freq
,to_char(pe.emplhiredate,'mm/dd/yyyy')::char(10) as pfreq_eff_date --- date of hire for new part / plan year start date for OE   
,to_char(pe.emplhiredate,'mm/dd/yyyy')::char(10) as hiredate
,trunc(pp.scheduledhours * 24 / 52) as hrsweek
,'2018 Full Plan Year' ::varchar(20) as planyearname
,case when pbe.benefitsubclass = '60' then 'MEDFSA18CO'
      when pbe.benefitsubclass = '61' then 'DCFSA18' 
      end ::varchar(15) as planname
,coalesce(pbe.coverageamount,0) as electionamount   
,cast(pboc.employeerate as dec(18,2)) as perpay_electionamount
,to_char(dfpd.first_check_date,'mm/dd/yyyy') ::char(10) as fstpay_ded_dte
,' ' ::char(10) as termdate
,' ' ::char(10) as final_pay_dte
---- note I can't always provide the final pay amount on a change / only weekly feed. If the ee termed the same week they
---- paid then I can provide the amount - no guarantee that this amount will coincide with a final pay deduction
,0 as final_payroll_ded_amt
,'None' ::char(4) as er_contrib_level
,'0' ::char(1) as er_contrib_amt
,to_char(pbe.effectivedate,'mm/dd/yyyy')::char(10) as effectivedate
,' ' ::char(1) as beneficiary
,'Debit Card' ::char(10) as reimb_method
,'Direct Deposit' ::char(15) as alt_reimb_method
,null as bankname
,null as accttype
,null as routnbr
,null as acctnbr
,'Direct Deposit' ::char(15) as dep_type
,'N' ::char(1) as auto_health_care
,'N' ::char(1) as email_y_n
,to_char(pbe.effectivedate,'mm/dd/yyyy') ::char(10) as change_date
,'New' ::varchar(30) as change_rsn


from person_employment pe
left join edi.edi_last_update elu ON elu.feedid = 'AVS_BasicPacific_FSA_DDC_Export'

join person_identity pi
  on pi.personid = pe.personid
 and pi.identitytype = 'SSN'
 and current_timestamp between pi.createts and pi.endts

left join person_identity pie
  on pie.personid = pe.personid
 and pie.identitytype = 'EmpNo'
 and current_timestamp between pie.createts and pie.endts
 
left join person_identity pip
  on pip.personid = pe.personid
 and pip.identitytype = 'PSPID'
 and current_timestamp between pip.createts and pip.endts  

join person_bene_election pbe 
  on pbe.personid = pe.personid 
 and pbe.benefitsubclass in ('60','61')
 and pbe.selectedoption = 'Y'
 and pbe.benefitelection = 'E'
 and pbe.effectivedate < pbe.enddate
 --and current_timestamp between pbe.createts and pbe.endts
 
left join personbenoptioncostl pboc
  on pboc.personid = pbe.personid
 and pboc.personbeneelectionpid = pbe.personbeneelectionpid
 and pboc.costsby = 'P' 
  
left join person_names pn
  on pn.personid = pe.personid 
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts 
 
left join person_address pa
  on pa.personid = pe.personid 
 and pa.addresstype = 'Res'
 and current_date between pa.effectivedate and pa.enddate
 and current_timestamp between pa.createts and pa.endts
 
left join person_vitals pv
  on pv.personid = pe.personid
 and current_date between pv.effectivedate and pv.enddate
 and current_timestamp between pv.createts and pv.endts   
 
left join person_net_contacts pncw 
  ON pncw.personid = pe.personid 
 AND pncw.netcontacttype = 'WRK'::bpchar 
 AND current_date between pncw.effectivedate and pncw.enddate
 AND current_timestamp between pncw.createts and pncw.endts 
 
left join person_phone_contacts ppch 
  on ppch.personid = pe.personid
 and ppch.phonecontacttype = 'Home'  
 and current_date between ppch.effectivedate and ppch.enddate
 and current_timestamp between ppch.createts and ppch.endts 

left join person_phone_contacts ppcw 
  on ppcw.personid = pe.personid
 and ppcw.phonecontacttype = 'Work'     
 and current_date between ppcw.effectivedate and ppcw.enddate
 and current_timestamp between ppcw.createts and ppcw.endts  

left join person_phone_contacts ppcm 
  on ppcm.personid = pe.personid
 and ppcm.phonecontacttype = 'Mobile'     
 and current_date between ppcm.effectivedate and ppcm.enddate
 and current_timestamp between ppcm.createts and ppcm.endts 
  
left join person_phone_contacts ppcb 
  on ppcb.personid = pe.personid
 and ppcb.phonecontacttype = 'BUSN'    
 and current_date between ppcb.effectivedate and ppcb.enddate
 and current_timestamp between ppcb.createts and ppcb.endts

left join person_maritalstatus pm
  on pm.personid = pe.personid
 and current_date between pm.effectivedate and pm.enddate
 and current_timestamp between pm.createts and pm.endts      

left join person_locations pl 
  on pl.personid = pe.personid
 and current_date between pl.effectivedate and pl.enddate
 and current_timestamp between pl.createts and pl.endts

left join locationcodeslist lc
  on lc.locationid = pl.locationid
 and lc.companyid = '1'
 and current_date between lc.effectivedate and lc.enddate
 and current_timestamp between lc.createts and lc.endts   

left join pay_unit pu
  on left(pu.payunitdesc,5) = left(pip.identity,5)
 and current_timestamp between pu.createts and pu.endts  

left join pers_pos pp
  on pp.personid = pi.personid
 and current_date between pp.effectivedate and pp.enddate
 and current_timestamp between pp.createts and pp.endts

left join ( select min(periodpaydate) as first_check_date from pay_schedule_period where date_part('year',periodpaydate)='2019') dfpd on 1=1

where current_date between pe.effectivedate and pe.enddate
  and current_timestamp between pe.createts and pe.endts
  and pe.emplstatus = 'A'
  and pbe.effectivedate >= date_trunc('year', current_date + interval '1 year') 
  
  order by lname


  
  
    
