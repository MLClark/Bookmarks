select distinct
 pi.personid
,'ACTIVE PARTICIPANTS' ::varchar(40) as qsource
,'B' ::char(1) as record_type
,'859' ::char(9) as er_grp_nbr
,case when pe.emplstatus <> 'T' then '1' else '' end ::char(1) as status_field
,pi.identity ::char(9) as essn
,pne.fname ::char(18) as efname
,pne.mname ::char(1) as emname
,pne.lname ::char(18) as elname
,pae.streetaddress ::varchar(30) as eaddr1
,pae.streetaddress2 ::varchar(20) as eaddr2
,pae.city ::char(22) as ecity
,pae.stateprovincecode ::char(2) as estate
,pae.postalcode ::char(5) as ezip5
,'0000' ::char(4) as ezip4
,to_char(pve.birthdate,'YYYYMMDD')::char(8) as emp_dob
,coalesce(ppcM.phoneno,ppcH.phoneno) ::char(10) as homephone
,ppcW.phoneno ::char(10) as workphone
,coalesce(pncw.url,pnch.url,pnco.url) ::varchar(60)  AS EMPLOYEE_EMAIL
,''::char(17) as employeenbr
,''::char(6) as filler6

,case when bpd.benefitplancode = 'HSAEE' then 'I' 
      when bpd.benefitplancode = 'HSAFAM'then 'F' else '' end ::char(1) as cov_type

,to_char(pbe1.effectivedate,'YYYYMMDD') ::char(8) as HDHP_start_date
,'' ::char(8) as termdate
,'Y' ::char(1) as HSA_affirmation
,pae1.streetaddress ::varchar(30) as mailing_addr1
,pae1.streetaddress2 ::varchar(20) as mailing_addr2
,pae1.city ::char(22) as mailing_city
,pae1.stateprovincecode ::char(2) as mailing_state
,pae1.postalcode ::char(5) as mailing_zip5
,case when pae1.postalcode isnull then ''  else '0000'  end ::char(4) as mailing_zip4
,'MC ' ::char(3) as card_type
,' ' ::char(206) as filler206
,'N' ::char(1) as wet_signature
,'Y' ::char(1) as e_sign_id
,' ' ::char(10) as verif_id
,' ' ::char(17) as sub_grp_id
,' ' ::char(9) as filler9
,' ' ::char(8) as filler7
,'1' as sort_seq 
,?::date

from person_identity pi

JOIN edi.edi_last_update elu
  ON elu.feedid = 'CDE_Optum_HSA_Changes'

left join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts

left join person_identity piE
  on piE.personid = pi.personid
 and current_timestamp between piE.createts and piE.endts
 and piE.identitytype = 'EmpNo'  
 
join person_bene_election pbe
  on pbe.personid = pi.personid
 and pbe.benefitsubclass in ('6Z') --look only at HSAEE or HSAFF; HSACU will be allowed only if ee has either HSAEE or HSAFF
 and pbe.benefitelection = 'E' 
 and pbe.selectedoption = 'Y' 
 and current_date between pbe.effectivedate and pbe.enddate
 and current_timestamp between pbe.createts and pbe.endts 

JOIN person_bene_election pbe1  
  ON pbe1.personid = pI.personid
 and pbe1.selectedoption = 'Y' 
 AND pbe1.benefitsubclass in ('10')
 AND pbe1.benefitelection IN ('E')  
 AND current_date BETWEEN pbe1.effectivedate AND pbe1.enddate 
 AND current_timestamp BETWEEN pbe1.createts AND pbe1.endts

left join person_names pne
  on pne.personid = pi.personid
 and pne.nametype = 'Legal'  
 and current_date between pne.effectivedate and pne.enddate
 and current_timestamp between pne.createts and pne.endts

--home address
left join person_address pae
  on pae.personid = pi.personid
 and current_date between pae.effectivedate and pae.enddate
 and current_timestamp between pae.createts and pae.endts
 and pae.addresstype = 'Res'   

--mailing address
left join person_address pae1
  on pae1.personid = pi.personid
 and current_date between pae1.effectivedate and pae1.enddate
 and current_timestamp between pae1.createts and pae1.endts
 and pae1.addresstype = 'Mail'   

left join person_vitals pve
  on pve.personid = pi.personid
 and current_date between pve.effectivedate and pve.enddate
 and current_timestamp between pve.createts and pve.endts

left JOIN person_phone_contacts ppch 
  ON ppch.personid = pi.personid
 AND current_date between ppch.effectivedate and ppch.enddate
 AND current_timestamp between ppch.createts and ppch.endts 
 AND ppch.phonecontacttype = 'Home'

left JOIN person_phone_contacts ppcw 
  ON ppcw.personid = pi.personid
 AND current_date between ppcw.effectivedate and ppcw.enddate
 AND current_timestamp between ppcw.createts and ppcw.endts 
 AND ppcw.phonecontacttype = 'Work'
   
left JOIN person_phone_contacts ppcb 
  ON ppcb.personid = pi.personid
 AND current_date between ppcb.effectivedate and ppcb.enddate
 AND current_timestamp between ppcb.createts and ppcb.endts 
 AND ppcb.phonecontacttype = 'BUSN'  
    
left JOIN person_phone_contacts ppcm 
  ON ppcm.personid = pi.personid
 AND current_date between ppcm.effectivedate and ppcm.enddate
 AND current_timestamp between ppcm.createts and ppcm.endts 
 AND ppcm.phonecontacttype = 'Mobile'   

left join person_net_contacts pncw 
  on pncw.personid = pi.personid 
 and pncw.netcontacttype = 'WRK'::bpchar 
 and current_date between pncw.effectivedate and pncw.enddate
 and current_timestamp between pncw.createts and pncw.enddate 

left join person_net_contacts pnch 
  on pnch.personid = pi.personid 
 and pnch.netcontacttype = 'HomeEmail'::bpchar 
 and current_date between pnch.effectivedate and pnch.enddate
 and current_timestamp between pnch.createts and pnch.enddate   
   
LEFT JOIN person_net_contacts pnco 
  ON pnco.personid = pi.personid 
 AND pnco.netcontacttype = 'OtherEmail'::bpchar 
 AND current_date between pnco.effectivedate and pnco.enddate
 AND current_timestamp between pnco.createts and pnco.enddate 
 
left join benefit_plan_desc bpd
  on bpd.benefitsubclass = pbe.benefitsubclass
  and bpd.benefitplanid = pbe.benefitplanid
 and current_date between bpd.effectivedate and bpd.enddate
 and current_timestamp between bpd.createts and bpd.endts
 
where pi.identitytype = 'SSN' 
  and current_timestamp between pi.createts and pi.endts
  and pe.emplstatus <> 'T'
  and case when ?::date = current_date then --- using case statement to control if active participants added to file. 
  --- this will not be executed during OE.
     ((pbe1.effectivedate  >= coalesce(elu.lastupdatets,'2018-01-01') or pbe1.createts > elu.lastupdatets)
   or (pbe.effectivedate   >= coalesce(elu.lastupdatets,'2018-01-01') or pbe.createts  > elu.lastupdatets)
   or (pe.effectivedate    >= coalesce(elu.lastupdatets,'2018-01-01') or pe.createts   > elu.lastupdatets)
   or (pne.effectivedate   >= coalesce(elu.lastupdatets,'2018-01-01') or pne.createts  > elu.lastupdatets)
   or (pae.effectivedate   >= coalesce(elu.lastupdatets,'2018-01-01') or pae.createts  > elu.lastupdatets)
   or (pae1.effectivedate  >= coalesce(elu.lastupdatets,'2018-01-01') or pae1.createts > elu.lastupdatets)
   or (pve.effectivedate   >= coalesce(elu.lastupdatets,'2018-01-01') or pve.createts  > elu.lastupdatets)
   or (ppch.effectivedate  >= coalesce(elu.lastupdatets,'2018-01-01') or ppch.createts > elu.lastupdatets)
   or (ppcw.effectivedate  >= coalesce(elu.lastupdatets,'2018-01-01') or ppcw.createts > elu.lastupdatets)
   or (ppcb.effectivedate  >= coalesce(elu.lastupdatets,'2018-01-01') or ppcb.createts > elu.lastupdatets)
   or (ppcm.effectivedate  >= coalesce(elu.lastupdatets,'2018-01-01') or ppcm.createts > elu.lastupdatets)
   or (pncw.effectivedate  >= coalesce(elu.lastupdatets,'2018-01-01') or pncw.createts > elu.lastupdatets)
   or (pnch.effectivedate  >= coalesce(elu.lastupdatets,'2018-01-01') or pnch.createts > elu.lastupdatets)
   or (pnco.effectivedate  >= coalesce(elu.lastupdatets,'2018-01-01') or pnco.createts > elu.lastupdatets)
   or (bpd.effectivedate   >= coalesce(elu.lastupdatets,'2018-01-01') or bpd.createts  > elu.lastupdatets)) end

        UNION
        
select distinct
 pi.personid
,'FUTURE DATED' ::varchar(40) as qsource
,'B' ::char(1) as record_type
,'859' ::char(9) as er_grp_nbr

,case when pe.emplstatus <> 'T' then '1' else '' end ::char(1) as status_field
,pi.identity ::char(9) as essn
,pne.fname ::char(18) as efname
,pne.mname ::char(1) as emname
,pne.lname ::char(18) as elname
,pae.streetaddress ::varchar(30) as eaddr1
,pae.streetaddress2 ::varchar(20) as eaddr2
,pae.city ::char(22) as ecity
,pae.stateprovincecode ::char(2) as estate
,pae.postalcode ::char(5) as ezip5
,'0000' ::char(4) as ezip4
,to_char(pve.birthdate,'YYYYMMDD')::char(8) as emp_dob
,coalesce(ppcM.phoneno,ppcH.phoneno) ::char(10) as homephone
,ppcW.phoneno ::char(10) as workphone
,coalesce(pncw.url,pnch.url,pnco.url) ::varchar(60)  AS EMPLOYEE_EMAIL

,''::char(17) as employeenbr
,''::char(6) as filler6

 
,case when bpd.benefitplancode = 'HSAEE' then 'I' 
      when bpd.benefitplancode = 'HSAFAM'then 'F' else ''  end ::char(1) as cov_type

,to_char(pbemed.effectivedate,'YYYYMMDD') ::char(8) as HDHP_start_date

,'' ::char(8) as termdate
,'Y' ::char(1) as HSA_affirmation
,pae1.streetaddress ::varchar(30) as mailing_addr1
,pae1.streetaddress2 ::varchar(20) as mailing_addr2
,pae1.city ::char(22) as mailing_city
,pae1.stateprovincecode ::char(2) as mailing_state
,pae1.postalcode ::char(5) as mailing_zip5
,case when pae1.postalcode isnull then '' else '0000'  end ::char(4) as mailing_zip4
,'MC ' ::char(3) as card_type
,' ' ::char(206) as filler206
,'N' ::char(1) as wet_signature
,'Y' ::char(1) as e_sign_id
,' ' ::char(10) as verif_id
,' ' ::char(17) as sub_grp_id
,' ' ::char(9) as filler9
,' ' ::char(8) as filler7
,'1' as sort_seq 
,?::date

from person_identity pi

join edi.edi_last_update elu
  on elu.feedid = 'CDE_Optum_HSA_Changes'

left join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts
/*
join person_bene_election pbe
  on pbe.personid = pi.personid
 and pbe.benefitsubclass in ('6Z') --look only at HSAEE or HSAFF; HSACU will be allowed only if ee has either HSAEE or HSAFF
 and pbe.benefitelection = 'E' 
 and pbe.selectedoption = 'Y' 
 and pbe.effectivedate < pbe.enddate
 and pbe.effectivedate > current_date
 and current_timestamp between pbe.createts and pbe.endts 



join person_bene_election pbemed  
  on pbemed.personid = pI.personid
 and pbemed.selectedoption = 'Y' 
 and pbemed.benefitsubclass in ('10')
 and pbemed.benefitelection IN ('E')  
 and pbemed.effectivedate < pbemed.enddate
 and pbemed.effectivedate > current_date
 and current_timestamp between pbemed.createts and pbemed.endts 
*/ 

--- hsa look only at HSAEE or HSAFF; HSACU will be allowed only if ee has either HSAEE or HSAFF
join (select personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid, pbe.compplanid, max(effectivedate) as effectivedate, max(enddate) as enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election pbe 
             left join comp_plan_plan_year cppy on cppy.compplanid = pbe.compplanid and cppy.compplanplanyeartype = 'Bene' 
                   and ?::date between cppy.planyearstart::date and cppy.planyearend::date			-- Checks for planYearStartDate parameter for OE and uses current_date for non-OE when planYearStartDate parameter is null
            where benefitsubclass = '6Z' and benefitelection = 'E' and selectedoption = 'Y' and current_timestamp between pbe.createts and pbe.endts 
              and case when ?::date > current_date then pbe.effectivedate >= cppy.planyearstart::date 
                       else pbe.effectivedate < pbe.enddate and pbe.effectivedate > current_date and current_timestamp between pbe.createts and pbe.endts end

            group by personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid, pbe.compplanid) pbe on pbe.personid = pi.personid and pbe.rank = 1         

--- med 
join (select personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid, pbe.compplanid, max(effectivedate) as effectivedate, max(enddate) as enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election pbe 
             left join comp_plan_plan_year cppy on cppy.compplanid = pbe.compplanid and cppy.compplanplanyeartype = 'Bene' 
                   and ?::date between cppy.planyearstart and cppy.planyearend			-- Checks for planYearStartDate parameter for OE and uses current_date for non-OE when planYearStartDate parameter is null
            where benefitsubclass = '10' and benefitelection = 'E' and selectedoption = 'Y' and current_timestamp between pbe.createts and pbe.endts --and personid = '305'
              and case when ?::date > current_date then pbe.effectivedate >= cppy.planyearstart::date 
                       else pbe.effectivedate < pbe.enddate and pbe.effectivedate > current_date and current_timestamp between pbe.createts and pbe.endts end
            group by personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid, pbe.compplanid) pbemed on pbemed.personid = pi.personid and pbemed.rank = 1         
 

left join person_names pne
  on pne.personid = pi.personid
 and pne.nametype = 'Legal'  
 and current_date between pne.effectivedate and pne.enddate
 and current_timestamp between pne.createts and pne.endts

--home address
left join person_address pae
  on pae.personid = pi.personid
 and current_date between pae.effectivedate and pae.enddate
 and current_timestamp between pae.createts and pae.endts
 and pae.addresstype = 'Res'   

--mailing address
left join person_address pae1
  on pae1.personid = pi.personid
 and current_date between pae1.effectivedate and pae1.enddate
 and current_timestamp between pae1.createts and pae1.endts
 and pae1.addresstype = 'Mail'   

left join person_vitals pve
  on pve.personid = pi.personid
 and current_date between pve.effectivedate and pve.enddate
 and current_timestamp between pve.createts and pve.endts

left join person_phone_contacts ppch 
  on ppch.personid = pi.personid
 and current_date between ppch.effectivedate and ppch.enddate
 and current_timestamp between ppch.createts and ppch.endts 
 and ppch.phonecontacttype = 'Home'

left join person_phone_contacts ppcw 
  on ppcw.personid = pi.personid
 and current_date between ppcw.effectivedate and ppcw.enddate
 and current_timestamp between ppcw.createts and ppcw.endts 
 and ppcw.phonecontacttype = 'Work'
   
left join person_phone_contacts ppcb 
  on ppcb.personid = pi.personid
 and current_date between ppcb.effectivedate and ppcb.enddate
 and current_timestamp between ppcb.createts and ppcb.endts 
 and ppcb.phonecontacttype = 'BUSN'  
    
left join person_phone_contacts ppcm 
  ON ppcm.personid = pi.personid
 and current_date between ppcm.effectivedate and ppcm.enddate
 and current_timestamp between ppcm.createts and ppcm.endts 
 and ppcm.phonecontacttype = 'Mobile'   

left join person_net_contacts pncw 
  on pncw.personid = pi.personid 
 and pncw.netcontacttype = 'WRK'::bpchar 
 and current_date between pncw.effectivedate and pncw.enddate
 and current_timestamp between pncw.createts and pncw.enddate 

left join person_net_contacts pnch 
  on pnch.personid = pi.personid 
 and pnch.netcontacttype = 'HomeEmail'::bpchar 
 and current_date between pnch.effectivedate and pnch.enddate
 and current_timestamp between pnch.createts and pnch.enddate   
   
left join person_net_contacts pnco 
  on pnco.personid = pi.personid 
 and pnco.netcontacttype = 'OtherEmail'::bpchar 
 and current_date between pnco.effectivedate and pnco.enddate
 and current_timestamp between pnco.createts and pnco.enddate 
 
left join benefit_plan_desc bpd
  on bpd.benefitsubclass = pbe.benefitsubclass
 and bpd.benefitplanid = pbe.benefitplanid
 and current_date between bpd.effectivedate and bpd.enddate
 and current_timestamp between bpd.createts and bpd.endts

where pi.identitytype = 'SSN' 
  and current_timestamp between pi.createts and pi.endts

        
