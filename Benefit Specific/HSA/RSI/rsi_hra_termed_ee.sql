select distinct
 pi.personid
,'0' ::char(1) as sort_seq
,'TERMED EE' ::varchar(30) as qsource 
,replace(pu.employertaxid,'-','')::varchar(20) as client_federal_id
,'0'::char(1) as plan_year_id
,pi.identity ::varchar(20) as participant_id
,'1'::char(1) as participant_id_type
,' ' ::varchar(20) as dependent_id
,pn.fname::varchar(30) as fname
,pn.mname::varchar(1) as mname
,ltrim(pn.lname)::varchar(30) as lname
,to_char(pv.birthdate,'mmddyyyy')::char(8) as dob
,coalesce(ppch.phoneno,ppcw.phoneno,ppcm.phoneno,ppcb.phoneno) ::varchar(16) AS phone
,pa.streetaddress ::varchar(30) as addr1
,pa.streetaddress2 ::varchar(30) as addr2
,pa.city ::varchar(30) as city
,pa.stateprovincecode ::char(2) as state
,pa.postalcode ::varchar(16) as zip
,coalesce(pncw.url,pnch.url) ::char(50) AS email
,case when bpdhra.benefitsubclass = '1Y' then 'HRA' else 'MED' end ::char(30) as enrollee_plan_type

,case when pbehra.benefitsubclass = '1Y' and bcdhra.benefitcoveragedescshort = 'Empl Only' then 'Single'
      when pbehra.benefitsubclass = '1Y' and bcdhra.benefitcoveragedescshort = 'Family' then 'Family'
      when pbehra.benefitsubclass = '1Y' and bcdhra.benefitcoveragedescshort = 'EE + 2 DP' then 'EE+2'
      when pbehra.benefitsubclass = '1Y' and bcdhra.benefitcoveragedescshort = 'Empl+Spous' then 'EE+SP'
      when pbemed.benefitsubclass = '10' and bcdmed.benefitcoveragedescshort = 'Empl Only' then 'Single'
      when pbemed.benefitsubclass = '10' and bcdmed.benefitcoveragedescshort = 'Family' then 'Family'
      when pbemed.benefitsubclass = '10' and bcdmed.benefitcoveragedescshort = 'EE + 2 DP' then 'EE+2'
      when pbemed.benefitsubclass = '10' and bcdmed.benefitcoveragedescshort = 'Empl+Spous' then 'EE+SP'
      else 'EE+1' end ::varchar(30) as enroll_cvg_type_id
,to_char(coalesce(pbehra.effectivedate,pbemed.effectivedate),'mmddyyyy')::char(8) as effectivedate
,to_char(coalesce(pbehra.enddate,pbemed.enddate),'mmddyyyy')::char(8) as term_date
,null as cobra_effective_date
,null as cobra_term_date


,null as other_id
,replace(ro.org2desc,',','')::varchar(30) as location
,null as AddPostingCode
,null as AddPostingDescription
,null as AddPostingAmount
,null as AddPostingEffectiveDate
,'0'::char(1) as DebitCardEnrollment
,'0'::char(1) as AutoReimbursement
,'0'::char(1) as MedicareEligible
,null as ESRD
,pv.gendercode::char(1) as Gender
,'0' ::char(1) as Relationship
,null as HICNumber
,'0'::char(1) as cob
,case when pe.emplstatus = 'T' then '1'
      when pe.emplstatus = 'R' then '2' end ::char(1) as TerminationReason
      
      
from person_identity pi

left join edi.edi_last_update elu on elu.feedid = 'RSI_DBS_HRA_Enrollment'

join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts

left join person_names pn
  on pn.personid = pe.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts

join person_bene_election pbe
  on pbe.personid = pe.personid
 and pbe.benefitelection <> 'W'
 and pbe.selectedoption = 'Y'
 and pbe.benefitsubclass in ('10','1Y')
 and current_date between pbe.effectivedate and pbe.enddate
 and current_timestamp between pbe.createts and pbe.endts
 and pbe.personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts 
                         and benefitsubclass in ('10','1Y') and benefitelection = 'E' and selectedoption = 'Y' and effectivedate < enddate) 

                         
 
left join 
      (SELECT personid, benefitsubclass, benefitplanid, benefitcoverageid, benefitelection, MAX(effectivedate) AS effectivedate, enddate,
       RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
              FROM person_bene_election 
              join edi.edi_last_update elu on elu.feedid = 'RSI_DBS_HRA_Enrollment'
             WHERE enddate > effectivedate AND current_timestamp BETWEEN createts AND endts
               and benefitelection = 'E' and selectedoption = 'Y' and benefitsubclass = '10'
               and effectivedate >= elu.lastupdatets::DATE 
             GROUP BY personid, benefitsubclass, benefitplanid, enddate, benefitcoverageid, benefitelection ) pbemed on pbemed.personid = pbe.personid and pbemed.rank = 1                          

left join 
      (SELECT personid, benefitsubclass, benefitplanid, benefitcoverageid, benefitelection, MAX(effectivedate) AS effectivedate, enddate,
       RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
              FROM person_bene_election 
              join edi.edi_last_update elu on elu.feedid = 'RSI_DBS_HRA_Enrollment'
             WHERE enddate > effectivedate AND current_timestamp BETWEEN createts AND endts
               and benefitelection = 'E' and selectedoption = 'Y' and benefitsubclass = '1Y'
               and effectivedate >= elu.lastupdatets::DATE 
             GROUP BY personid, benefitsubclass, benefitplanid, enddate, benefitcoverageid, benefitelection ) pbehra on pbehra.personid = pbe.personid and pbehra.rank = 1    

left join benefit_plan_desc bpdhra
  on bpdhra.benefitsubclass = pbehra.benefitsubclass
 and bpdhra.benefitplanid = pbehra.benefitplanid
 and current_date between bpdhra.effectivedate and bpdhra.enddate
 and current_timestamp between bpdhra.createts and bpdhra.endts     
 
left join benefit_plan_desc bpdmed
  on bpdmed.benefitsubclass = pbemed.benefitsubclass
 and bpdmed.benefitplanid = pbemed.benefitplanid
 and current_date between bpdmed.effectivedate and bpdmed.enddate
 and current_timestamp between bpdmed.createts and bpdmed.endts                               
 
left join benefit_coverage_desc bcdhra
  on bcdhra.benefitcoverageid = pbehra.benefitcoverageid 
 and current_date between bcdhra.effectivedate and bcdhra.enddate
 and current_timestamp between bcdhra.createts and bcdhra.endts 
 
left join benefit_coverage_desc bcdmed
  on bcdmed.benefitcoverageid = pbemed.benefitcoverageid 
 and current_date between bcdmed.effectivedate and bcdmed.enddate
 and current_timestamp between bcdmed.createts and bcdmed.endts 
  
left join person_vitals pv
  on pv.personid = pe.personid
 and current_date between pv.effectivedate and pv.enddate
 and current_timestamp between pv.createts and pv.endts
 
left join person_address pa
  on pa.personid = pe.personid
 and pa.addresstype = 'Res'
 and current_date between pa.effectivedate and pa.enddate
 and current_timestamp between pa.createts and pa.endts 
 
left join person_phone_contacts ppch 
  on ppch.personid = pe.personid
 and current_date between ppch.effectivedate and ppch.enddate
 and current_timestamp between ppch.createts and ppch.endts 
 and ppch.phonecontacttype = 'Home'
        
left join person_phone_contacts ppcm
  on ppch.personid = pe.personid
 and current_date between ppcm.effectivedate and ppcm.enddate
 and current_timestamp between ppcm.createts and ppcm.endts 
 and ppcm.phonecontacttype = 'Mobile' 
 
left join person_phone_contacts ppcb
  on ppcb.personid = pe.personid
 and current_date between ppcb.effectivedate and ppcb.enddate
 and current_timestamp between ppcb.createts and ppcb.endts 
 and ppcb.phonecontacttype = 'BUSN'    
  
left join person_phone_contacts ppcw
  on ppcw.personid = pe.personid
 and current_date between ppcw.effectivedate and ppcw.enddate
 and current_timestamp between ppcw.createts and ppcw.endts  
 and ppcw.phonecontacttype = 'Work'   
    
left join person_net_contacts pncw 
  on pncw.personid = pe.personid 
 and pncw.netcontacttype = 'WRK'::bpchar 
 and current_date between pncw.effectivedate and pncw.enddate
 and current_timestamp between pncw.createts and pncw.enddate 

left join person_net_contacts pnch 
  on pnch.personid = pe.personid 
 and pnch.netcontacttype = 'HomeEmail'::bpchar 
 and current_date between pnch.effectivedate and pnch.enddate
 and current_timestamp between pnch.createts and pnch.enddate   

left join person_payroll ppay
  on ppay.personid = pe.personid
 and current_date between ppay.effectivedate and ppay.enddate
 and current_timestamp between ppay.createts and ppay.endts

left join (SELECT personid, positionid, MAX(effectivedate) AS effectivedate, 
                  RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             FROM pers_pos WHERE enddate > effectivedate AND current_timestamp BETWEEN createts AND endts
            GROUP BY personid, positionid ) pp on pp.personid = pe.personid and pp.rank = 1
 
LEFT JOIN pos_org_rel por
  on por.positionid = pp.positionid
 AND current_date between por.effectivedate AND por.enddate
 AND current_timestamp between por.createts AND por.endts
 AND por.posorgreltype = 'Member'

LEFT JOIN cognos_orgstructure ro
  ON ro.org1id = por.organizationid  
    
left join pay_unit pu on pu.payunitid = ppay.payunitid 
  
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  and pe.emplstatus in ('T','R')
  and (pe.effectivedate >= elu.lastupdatets::DATE 
   or (pe.createts > elu.lastupdatets and pe.effectivedate < coalesce(elu.lastupdatets, '2017-01-01')) ) 