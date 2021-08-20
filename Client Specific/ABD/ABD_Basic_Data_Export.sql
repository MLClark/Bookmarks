select distinct
 pi.personid
,pbe.effectivedate
,pid.personid as dependentid
,pid.personid ::char(4) as depseqnbr
--,pbe.createts,pbe.updatets
,case when pbe.createts::date = pbe.effectivedate::date then 'A' else 'C'  end ::char(1) transtype
--,CASE pbe.benefitelection when 'E' then 'A' else 'C' end ::char(1) transtype
,'10646' ::char(9) as brmsGroupNbr

,pi.identity ::char(9) as eeSSN
,pid.identity ::char(9) as dSSN
,pne.fname ::char(30) as empfirstname
,pne.mname ::char(30) as empmiddlename
,pne.lname ::char(50) as emplastname
,pnd.fname ::char(30) as depfirstname
,pnd.mname ::char(30) as depmiddlename
,pnd.lname ::char(50) as deplastname
,to_char(pve.birthdate, 'yyyymmdd')::char(8) as empdob
,to_char(pvd.birthdate, 'yyyymmdd')::char(8) as depdob

,pve.gendercode ::char(1) as empgender
,pvd.gendercode ::char(1) as depgender
,case pmse.maritalstatus when 'M' then 'M' else 'S' end ::char(1) as maritalstatus
,to_char(pe.effectivedate,'yyyymmdd')::char(8) as doh
,case pdr.dependentrelationship when 'SP' then 'S' else 'C' end ::char(1) as relationship
--,RANK() over (PARTITION BY pi.personid ORDER BY pid.identity asc ) as depseqnbr
,pmse.effectivedate
,to_char(pvd.birthdate, 'yyyymmdd')::char(8) as depAsofDate
,dd.student::char(1) as student
,case when dd.dependentstatus = 'D' then 'Y' else 'N' end ::char(1) as disabled
,'A' ::char(1) as empstatus ----If you won’t be reporting COBRA or Retiree participants to us then you should always send A.
,pe.peremplpid::char(50) as employeenbr
,pd.positiontitle::char(50) as title
,' ' ::char(8) as empTermDate
,' ' ::char(1) as empTermRsn
,' ' ::char(10) as payrollGrpCd
,' ' ::char(8) as paygrpeffdt
,' ' ::char(1) as salaryType
,' ' ::char(9) as salaryamt
,' ' ::char(8) as saleffdt
,' ' ::char(9) as estAnnualBonus
,' ' ::char(8) as filler01
,' ' ::char(9) as estAnnualCommition
,' ' ::char(8) as filler02
,pae.streetaddress ::char(50) as phyAddr
,pae.city ::char(50) as phyCity
,pae.stateprovincecode ::char(02) as phyState
,pae.postalcode ::char(9) as phyZip
,to_char(pae.effectivedate,'yyyymmdd') ::char(8) as phyAddrEffDt
,pae.streetaddress ::char(50) as mailAddr
,pae.city ::char(50) as mailCity
,pae.stateprovincecode ::char(02) as mailState
,pae.postalcode ::char(9) as mailZip
,to_char(pae.effectivedate,'yyyymmdd') ::char(8) as mailAddrEffDt
--,epi.locationdescription
,case lc.locationdescription
   when 'Bangor'        then 'BNGR'
   when 'Biddeford'     then 'BDFD'
   when 'Rockport'      then 'ROCK' 
   when 'Sanford'	      then 'SNFD'
   when 'Scarborough'   then 'SCAR'
   when 'Topsham'	      then 'TPSM'
   when 'Paratransit'   then 'PARA'
   when 'Brunswick'     then 'BRNS'   
   else ' '  ---- Brunswick and nulls are showing up as UNKN and NEMS does have a service location in Brunswick
 END ::char(10) as benefitGroupCd
 
,to_char(pbe.effectivedate,'yyyymmdd') ::char(8) as benefitGroupEffDt
,' ' ::char(10) as insuredCatCd1
,' ' ::char(8) as insuredCatCdEffDt1
,' ' ::char(10) as insuredCatCd2
,' ' ::char(8) as insuredCatCdEffDt2
,' ' ::char(10) as insuredCatCd3
,' ' ::char(8) as insuredCatCdEffDt3
,' ' ::char(10) as insuredCatCd4
,' ' ::char(8) as insuredCatCdEffDt4

,case lc.locationdescription
   when 'Bangor'        then 'BNGR'
   when 'Biddeford'     then 'BDFD'
   when 'Rockport'      then 'ROCK' 
   when 'Sanford'	      then 'SNFD'
   when 'Scarborough'   then 'SCAR'
   when 'Topsham'	      then 'TPSM'
   when 'Paratransit'   then 'PARA'
   when 'Brunswick'     then 'BRNS'
   else ' ' 
 END ::char(10) as insuredCatCd5
 
,to_char(pbe.effectivedate,'yyyymmdd') ::char(8) as insuredCatCdEffDt5
,ppch.phoneno ::char(10) as homephone
,ppcw.phoneno ::char(10) as workphone
,' ' ::char(15) as vbasUserSignIn
,pncw.url ::char(50) as emailAddr
,' ' ::char(8) as filler3
,' ' ::char(1) as vipInd
,' ' ::char(50) as workAddr
,' ' ::char(50) as workCity
,' ' ::char(02) as workState
,' ' ::char(5) as workZip
,' ' ::char(8) as workAddrEffDt




from person_identity pi

JOIN edi.edi_last_update elu
  ON elu.feedid = 'ABD-BRMS Carrier Feed'

join person_bene_election pbe  
  ON pbe.personid = pI.personid
 AND pbe.benefitsubclass = '10'
 AND pbe.benefitelection IN ('T','E','W')
 AND pbe.enddate = '2199-12-31' 
 AND CURRENT_DATE BETWEEN pbe.effectivedate AND pbe.enddate 
 AND CURRENT_TIMESTAMP BETWEEN pbe.createts AND pbe.endts
 and pbe.effectivedate >= elu.lastupdatets
 
left join person_names pne 
  ON pne.personid = pi.personid
 AND CURRENT_DATE BETWEEN pne.effectivedate AND pne.enddate
 AND CURRENT_TIMESTAMP BETWEEN pne.createts AND pne.endts      

left join person_employment pe
  ON pe.personid = pi.personid
 AND CURRENT_DATE BETWEEN pe.effectivedate AND pe.enddate
 AND CURRENT_TIMESTAMP BETWEEN pe.createts AND pe.endts
 
left join pers_pos pp
  on pp.personid = pi.personid
 and current_date between pp.effectivedate and pp.enddate
 and current_timestamp between pp.createts and pp.endts
 
left join position_desc pd
  on pd.positionid = pp.positionid  
 and current_date between pd.effectivedate and pd.enddate
 and current_timestamp between pd.createts and pd.endts   

left join person_locations pl 
  ON pl.personid = pi.personid 
 AND pl.personlocationtype = 'P'::bpchar 
 AND current_date between pl.effectivedate AND pl.enddate 
 AND current_timestamp between pl.createts AND pl.endts
 
LEFT JOIN location_codes lc 
  ON lc.locationid = pl.locationid 
 AND current_date between lc.effectivedate AND lc.enddate 
 AND current_timestamp between lc.createts AND lc.endts 
  
left join person_vitals pve 
  ON pve.personid = pi.personid 
 AND CURRENT_DATE BETWEEN pve.effectivedate AND pve.enddate
 AND CURRENT_TIMESTAMP BETWEEN pve.createts AND pve.endts     
 
left join person_maritalstatus pmse
  on pmse.personid = pi.personid
 and current_date between pmse.effectivedate and pmse.enddate
 and current_timestamp between pmse.createts and pmse.endts
 
LEFT JOIN person_address pae 
  ON pae.personid = pi.personid
 AND CURRENT_DATE BETWEEN pae.effectivedate AND pae.enddate
 AND CURRENT_TIMESTAMP BETWEEN pae.createts AND pae.endts    
 
left join person_phone_contacts ppch 
  ON ppch.personid = pi.personid
 AND current_date between ppch.effectivedate and ppch.enddate
 AND current_timestamp between ppch.createts and ppch.endts 
 AND ppch.phonecontacttype = 'Home'
 
left join person_phone_contacts ppcw 
  ON ppcw.personid = pi.personid
 AND current_date between ppcw.effectivedate and ppcw.enddate
 AND current_timestamp between ppcw.createts and ppcw.endts 
 AND ppcw.phonecontacttype = 'Work' 
   
left join person_phone_contacts ppcb 
  ON ppcb.personid = pi.personid
 AND current_date between ppcb.effectivedate and ppcb.enddate
 AND current_timestamp between ppcb.createts and ppcb.endts 
 AND ppcb.phonecontacttype = 'BUSN'   
    
left join person_phone_contacts ppcm 
  ON ppcm.personid = pi.personid
 AND current_date between ppcm.effectivedate and ppcm.enddate
 AND current_timestamp between ppcm.createts and ppcm.endts 
 AND ppcm.phonecontacttype = 'Mobile'   

left join person_net_contacts pncw 
  ON pncw.personid = pi.personid 
 AND pncw.netcontacttype = 'WRK'::bpchar 
 AND current_date between pncw.effectivedate and pncw.enddate
 AND current_timestamp between pncw.createts and pncw.enddate 
 
left join person_net_contacts pnch 
  ON pnch.personid = pi.personid 
 AND pnch.netcontacttype = 'HomeEmail'::bpchar 
 AND current_date between pnch.effectivedate and pnch.enddate
 AND current_timestamp between pnch.createts and pnch.enddate  
       
left join person_net_contacts pnco 
  ON pnco.personid = pi.personid 
 AND pnco.netcontacttype = 'OtherEmail'::bpchar 
 AND current_date between pnco.effectivedate and pnco.enddate
 AND current_timestamp between pnco.createts and pnco.enddate        


------- Dependents


left join person_dependent_relationship pdr 
  on pdr.personid = pi.personid
 AND CURRENT_DATE BETWEEN pdr.effectivedate AND pdr.enddate 
 AND CURRENT_TIMESTAMP BETWEEN pdr.createts AND pdr.endts
 
left join person_identity pid 
  ON pid.personid = pdr.dependentid 
 AND pid.identitytype = 'SSN'::bpchar 
 AND CURRENT_TIMESTAMP BETWEEN pid.createts AND pid.endts  

left join dependent_enrollment de 
  on de.dependentid = pdr.dependentid 
 AND de.benefitsubclass = pbe.benefitsubclass
 AND CURRENT_DATE BETWEEN de.effectivedate AND de.enddate 
 AND CURRENT_TIMESTAMP BETWEEN de.createts AND de.endts 

left join person_names pnd 
  ON pnd.personid = pid.personid
 AND CURRENT_DATE BETWEEN pnd.effectivedate AND pnd.enddate
 AND CURRENT_TIMESTAMP BETWEEN pnd.createts AND pnd.endts    
 
left join person_vitals pvd 
  ON pvd.personid = pid.personid
 AND CURRENT_DATE BETWEEN pvd.effectivedate AND pvd.enddate
 AND CURRENT_TIMESTAMP BETWEEN pvd.createts AND pvd.endts  
 
left join dependent_desc dd
  on dd.dependentid = pdr.dependentid
 and current_date between dd.effectivedate and dd.enddate
 and current_timestamp between dd.createts and dd.endts 
 
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  and pi.personid = '3257'
order by dssn asc 



