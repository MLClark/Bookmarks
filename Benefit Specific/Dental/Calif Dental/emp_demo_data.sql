select distinct
 pi.personid 
,'1' ::CHAR(1) AS sortseq
,pi.identity ::char(9) as member_ssn 
,pi.identity ::char(9) as person_ssn 

,'EMP' ::CHAR(3) AS relationship

,pne.lname ::char(20) as member_lname
,pne.fname ::char(12) as member_fname
,pne.mname ::char(1)  as member_mi

,to_char(pve.birthdate, 'YYYYMMDD')::char(8) as member_dob
,pve.gendercode ::char(1) as member_gender

,pae.streetaddress ::char(32) as eaddr
,pae.city ::char(21) as ecity
,pae.stateprovincecode ::char(2) as estate
,replace(pae.postalcode,'-','') ::char(9) as ezip
,to_char(pe.effectivedate,'YYYYMMDD') ::char(8) as emp_doh
,to_char(pbe.effectivedate,'YYYYMMDD')::char(8) as effective_date
,case when pe.emplstatus = 'T' then to_char(pe.effectivedate,'YYYYMMDD') end ::char(8) as term_date

,bcd.benefitcoveragedesc
,case when bcd.benefitcoverageid in ('1')  then 'EE'
      when bcd.benefitcoverageid in ('10') then 'EC'
      when bcd.benefitcoverageid in ('11','12','13','14','15','16','17') then 'E1'
      when bcd.benefitcoverageid in ('2') then 'ES'
      when bcd.benefitcoverageid in ('3') then 'EC'
      when bcd.benefitcoverageid in ('5') then 'EF'
      else 'EE' end ::char(2) as tier
,' ' ::char(1) as officenbr
,case when pbe.effectivedate::date = pbe.createts::date then 'A' else 'C' end ::char(1) as change_code
,'002976' ::char(6) as groupnbr
,'DHMO' ::char(4) as plan


from person_identity pi

join edi.edi_last_update elu 
  on elu.feedid = 'ASP_CalDental_Dental_Export'

left join person_identity pie
  on pie.personid = pi.personid
 and pie.identitytype = 'EmpNo'
 and current_timestamp between pie.createts and pie.endts

left join person_names pne
  on pne.personid = pi.personid
 and pne.nametype = 'Legal'
 and current_date between pne.effectivedate and pne.enddate
 and current_timestamp between pne.createts and pne.endts

left join person_vitals pve
  on pve.personid = pi.personid
 and current_date between pve.effectivedate and pve.enddate
 and current_timestamp between pve.createts and pve.endts

left join person_maritalstatus pmse
  on pmse.personid = pi.personid
 and current_date between pmse.effectivedate and pmse.enddate
 and current_timestamp between pmse.createts and pmse.endts
 
LEFT JOIN person_employment pe 
  ON pe.personid = pi.personid 
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts
 
left join person_address pae 
  on pae.personid = pi.personid
 and current_date between pae.effectivedate and pae.enddate
 and current_timestamp between pae.createts and pae.endts
 
join person_bene_election pbe
  on pbe.personid = pi.personid
 and pbe.benefitsubclass in ('11')
 and pbe.benefitplanid in ('27')
 and current_date between pbe.effectivedate and pbe.enddate
 and current_timestamp between pbe.createts and pbe.endts
 and pbe.benefitelection = 'E'
 and pbe.selectedoption = 'Y'
 --and pbe.effectivedate >= elu.lastupdatets


left JOIN benefit_coverage_desc bcd 
  ON bcd.benefitcoverageid = pbe.benefitcoverageid
 AND current_date between bcd.effectivedate and bcd.enddate
 and current_timestamp between bcd.createts and bcd.endts

 
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts


  --nd pi.personid in ('1266','1205','719','998')
  --and pi.personid in ('4705')
  order by 1
  ;
  
  