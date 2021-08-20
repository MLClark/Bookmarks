--- ANK Demographic Header
select distinct
 pi.personid
,pip.identity
,'DEMO' ::char(4) as recordType4
,'0001' ::char(4) as recordVersionNbr4
,'061654' ::char(6) as masterContactNbr6
,'941051349' ::char(12) as sein12
,'TBD' ::char(8) as locationCode8
,'1' ::char(12) as subsetCode12
,pi.identity ::char(9) as ssn9
,pn.title ::char(4) as prefixName4
,pn.fname ::char(15) as firstName15
,pn.mname ::char(10) as mi10
,pn.lname ::char(20) as lastName20
,' ' ::char(8) as suffixName8
,pa.streetaddress ::char(35) as addr135
,pa.streetaddress2 ::char(35) as addr235
,' ' ::char(35) as filler0135
,pa.city ::char(35) as city35
,pa.stateprovincecode ::char(2) as state2
,pa.postalcode||'-0000' ::char(10) as zip10
,pa.countrycode ::char(2) as country2
,ppcW.phoneno ::char(12) as workphone12
,' ' ::char(12) as filler0212
,pncw.url ::char(100) as WorkEmail100
,to_char(pv.birthdate,'YYYYMMDD')::char(8) as dob8
,to_char(pe.emplhiredate,'YYYYMMDD')::char(8) as doh8
,pv.gendercode ::char(1) as gender1
,plp.languagecode ::char(2) as languagePref2
,pm.maritalstatus ::char(1) as maritalstatus1
,cast(EXTRACT(YEAR from AGE(pv.birthdate)) as int) as age_na
,case when cast(EXTRACT(YEAR from AGE(pv.birthdate)) as int) > 18 then 'PLAN1E' else 'PLAN1N' end ::char(8) as employmentclass8
,case when pe.emplstatus = 'A' then 'Active'
      when pe.emplstatus = 'T' then 'Termed'
      when pe.emplstatus = 'L' then 'Leave'
      else 'Unknown' end ::char(8) as emplstatus8
,to_char(pe.effectivedate,'YYYYMMDD') ::char(8) as emplEffDate8
,case when jd.eeocode = '11' then 'Y' else 'N' end ::char(1) as keyEmpInd1
,'N' ::char(1) as ownStock_16BInd1
,pe.emplclass ::char(1) as payrollStatus1
,pc.frequencycode ::char(1) as payrollfreq1

,elu.feedid as feedid
,elu.lastupdatets as lastupdatets

from person_identity pi
join edi.edi_last_update elu on elu.feedid = 'ANK_MM_401k_Demo_HDR_Export'

left join person_names pn
  on pn.personid = pi.personid
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts
 and pn.nametype = 'Legal'

left join person_address pa
  on pa.personid = pi.personid
 and current_date between pa.effectivedate and pa.enddate
 and current_timestamp between pa.createts and pa.endts
 and pa.addresstype = 'Res' 

left join person_phone_contacts ppcw ON ppcw.personid = pi.personid
 and current_date between ppcw.effectivedate and ppcw.enddate
 and current_timestamp between ppcw.createts and ppcw.endts 
 and ppcw.phonecontacttype = 'Work'  
 
left join person_net_contacts pncw ON pncw.personid = pi.personid 
 and pncw.netcontacttype = 'WRK'::bpchar 
 and current_date between pncw.effectivedate and pncw.enddate
 and current_timestamp between pncw.createts and pncw.enddate  
 
left join person_vitals pv
  on pv.personid = pi.personid
 and current_date between pv.effectivedate and pv.enddate
 and current_timestamp between pv.createts and pv.endts  

left join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts 
 
left join person_language_preference plp
  on plp.personid = pi.personid
   
left join person_maritalstatus pm
  on pm.personid = pi.personid
 and current_date between pm.effectivedate and pm.enddate
 and current_timestamp between pm.createts and pm.endts
 
left join pers_pos ppos
  on ppos.personid = pi.personid
 and current_date between ppos.effectivedate and ppos.enddate
 and current_timestamp between ppos.createts and ppos.endts
 
left join position_job posj
  on posj.positionid = ppos.positionid
 and current_date between posj.effectivedate and posj.enddate
 and current_timestamp between posj.createts and posj.endts

left join job_desc jd
  on jd.jobid = posj.jobid
 and current_date between jd.effectivedate and jd.enddate
 and current_timestamp between jd.createts and jd.endts
 
left join person_compensation pc
  on pc.personid = pi.personid 
 and current_date between pc.effectivedate and pc.enddate
 and current_timestamp between pc.createts and pc.endts 

join person_identity piP 
  on piP.personid = pi.personid
 and current_timestamp between piP.createts and piP.endts
 and piP.identitytype = 'PSPID' 
 
join pspay_payment_detail ppd
  on ppd.etv_id IN ('VB1','VB2','VB3','VB4','VB5','V25','V65', 'VCQ')
 AND ppd.check_date = ?::DATE
 and ppd.individual_key = piP.identity 
     
where current_date between pi.createts and pi.endts 
  and pi.identitytype = 'SSN'
  and pi.personid = '243'
;

