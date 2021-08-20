select distinct
 pi.personid
,'D' ::char(1) as sort_seq
,'*' ::char(1) as count_seq
,pi.identity ::char(9) as subscriber_id 
,to_char(row_number() over (PARTITION BY pi.personid ORDER BY pnD.personid asc ),'FM01') as member_indicator
,prd.persondeprelpid as member_indicator
,pnD.lname ::char(35) as lname
,pnD.fname ::char(15) as fname
,'CH' ::char(2) as mbr_rel
,pnD.mname ::char(1) as mname
,pas.streetaddress ::char(40) as addr1
,pas.streetaddress2::char(40) as addr2
,pas.city ::char(19) as city
,pas.stateprovincecode ::char(2) as state
,replace(pas.postalcode,'-','') ::char(9) as zip_split_me
,coalesce(ppcM.phoneno,ppcH.phoneno) ::char(12) as homephone
,coalesce(ppcW.phoneno,ppcB.phoneno) ::char(12) as workphone
,pvD.gendercode ::char(1) as gender
,to_char(pvD.birthdate,'YYYYMMDD')::char(8) as dob
,lkups.value2 ::char(30) as group_policy_nbr --dt17
,lkups.value3 ::char(30) as subgrp_policy_nbr --dt18
,case when pe.effectivedate::date > '2017-09-01' and pc.frequencycode = 'A' 
      then TO_CHAR(date_trunc('MONTH',pe.effectivedate) + interval '1 MONTH','YYYYMMDD')  
      when pe.effectivedate::date > '2017-09-01' and pc.frequencycode = 'H' 
      then TO_CHAR(date_trunc('MONTH',pe.effectivedate) + interval '3 MONTHS','YYYYMMDD') 
      when pe.effectivedate::date <= '2017-09-01' then '20170901' end ::char(8) as emp_subgrp_eff_date
,case when pbe.benefitsubclass in ('25','26') then 'LE000009'
      end ::char(10) as plan_code
,case when pe.effectivedate::date > '2017-09-01' and pc.frequencycode = 'A' 
      then TO_CHAR(date_trunc('MONTH',pe.effectivedate) + interval '1 MONTH','YYYYMMDD') 
      when pe.effectivedate::date > '2017-09-01' and pc.frequencycode = 'H' 
      then TO_CHAR(date_trunc('MONTH',pe.effectivedate) + interval '3 MONTHS','YYYYMMDD') 
      when pe.effectivedate::date <= '2017-09-01' then '20170901' end ::char(8) as plan_code_eff_date  
,case when pbe.benefitsubclass in ('25','26') then 'G' end ::char(2) as tier_code
,case when pe.effectivedate::date > '2017-09-01' and pc.frequencycode = 'A' 
      then TO_CHAR(date_trunc('MONTH',pe.effectivedate) + interval '1 MONTH','YYYYMMDD') 
      when pe.effectivedate::date > '2017-09-01' and pc.frequencycode = 'H' 
      then TO_CHAR(date_trunc('MONTH',pe.effectivedate) + interval '3 MONTHS','YYYYMMDD') 
      when pe.effectivedate::date <= '2017-09-01' then '20170901' end ::char(8) as eff_date
,case when pbe.benefitelection = 'T' then to_char(pbe.effectivedate,'YYYYMMDD') else ' ' end ::char(8) as term_date
,' ' ::char(9) as alt_id --dt25
,' ' ::char(1) as student_status--dt26
,case when dd.dependentstatus = 'D' then 'Y' else ' ' end as handicapped --dt27
,' ' ::char(3) as written_pref_lang--dt28
,' ' ::char(8) as written_pref_eff_date --dt29
,' ' ::char(3) as spoken_pref_lang --dt30
,' ' ::char(8) as spoken_pref_eff_date --dt31
,'N' ::char(1) as calap_elig_ind --dt32

,to_char(pe.effectivedate,'YYYYMMDD')::char(8) as doh
,case when pbe.benefitsubclass = '26' and pbe.benefitplanid = '285' then '2002'
      when pbe.benefitsubclass = '26' and pbe.benefitplanid = '296' then '2002'
      else '2001' end ::char(4) as subscriber_class_id
,case when pe.effectivedate::date > '2017-09-01' and pc.frequencycode = 'A' 
      then TO_CHAR(date_trunc('MONTH',pe.effectivedate) + interval '1 MONTH','YYYYMMDD')  
      when pe.effectivedate::date > '2017-09-01' and pc.frequencycode = 'H' 
      then TO_CHAR(date_trunc('MONTH',pe.effectivedate) + interval '3 MONTHS','YYYYMMDD') 
      when pe.effectivedate::date <= '2017-09-01' then '20170901' end ::char(8) as subscriber_eff_date
,'A'::char(1) as salary_type
,case when pc.frequencycode = 'H' then to_char(pc.compamount * 2080 ,'FM0000000D00') 
      when pc.compamount > 100000.00 then to_char(pc.compamount ,'FM0000000D00')
      when pc.frequencycode = 'A' then to_char(pc.compamount ,'FM0000000D00')
      else to_char(pc.compamount ,'FM0000000D00') end ::char(10) as salary_amount
,case when pe.effectivedate::date > '2017-09-01' and pc.frequencycode = 'A' 
      then TO_CHAR(date_trunc('MONTH',pe.effectivedate) + interval '1 MONTH','YYYYMMDD')  
      when pe.effectivedate::date > '2017-09-01' and pc.frequencycode = 'H' 
      then TO_CHAR(date_trunc('MONTH',pe.effectivedate) + interval '3 MONTHS','YYYYMMDD')
      when pe.effectivedate::date <= '2017-09-01' then '20170901' end ::char(8) as salary_eff_date 
,case when pbe.coverageamount > 0 then to_char(pbe.coverageamount, 'FM0000000000') 
      when bpd.benefitplandesc like ('07.5K%') then '7500'
      when bpd.benefitplandesc like ('10K%') then '10000'
      when bpd.benefitplandesc like ('12.5K%') then '12500'
      when bpd.benefitplandesc like ('15K%') then '15000'
      when bpd.benefitplandesc like ('17.5K%') then '17500'
      when bpd.benefitplandesc like ('2.5K%') then '2500'
      when bpd.benefitplandesc like ('20K%') then '20000'
      when bpd.benefitplandesc like ('22.5K%') then '22500'
      when bpd.benefitplandesc like ('25K%') then '25000'
      when bpd.benefitplandesc like ('30K%') then '30000'
      when bpd.benefitplandesc like ('35K%') then '35000'
      when bpd.benefitplandesc like ('40K%') then '40000'
      when bpd.benefitplandesc like ('45K%') then '45000'
      when bpd.benefitplandesc like ('50K%') then '50000'
      when bpd.benefitplandesc like ('7500%') then '7500'
      when bpd.benefitplancode like ('5K%') then '5000'
      when bpd.benefitplancode like ('2500S%') then '2500'
      when bpd.benefitplancode like ('5000C%') then '5000'
      else ' ' end ::char(10) as plan_coverage_amount
      
--,to_char(pbe.effectivedate,'YYYYMMDD')  ::char(8) as rating_prem_ovrd_eff_date
,case when pe.effectivedate::date > '2017-09-01' and pc.frequencycode = 'A' 
      then TO_CHAR(date_trunc('MONTH',pe.effectivedate) + interval '1 MONTH','YYYYMMDD') 
      when pe.effectivedate::date > '2017-09-01' and pc.frequencycode = 'H' 
      then TO_CHAR(date_trunc('MONTH',pe.effectivedate) + interval '3 MONTHS','YYYYMMDD') 
      when pe.effectivedate::date <= '2017-09-01' then '20170901'  end ::char(8) as rating_prem_ovrd_eff_date  

,' ' ::char(8) as student_status_eff_date
,' ' ::char(8) as student_status_term_date
,case when dd.dependentstatus = 'D' then to_char(dd.effectivedate,'YYYYMMDD') else ' ' end ::char(8) as handicap_eff_date
,case when dd.dependentstatus = 'D' then to_char(dd.enddate,'YYYYMMDD') else ' ' end ::char(8) as handicap_term_date

from person_identity pi

join person_identity pie
  on pie.personid = pi.personid
 and pie.identitytype = 'EmpNo'
 and current_timestamp between pie.createts and pie.endts

left join person_employment pe 
  on pe.personid = pi.personid 
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts

join 
( select lkups.lookupname, lkups.lookupid, lkup.lookupid, lkup.key1, lkup.value1, lkup.key2, lkup.value2, lkup.key3, lkup.value3, lkup.key4, lkup.value4, lkup.key5, lkup.value5
         from edi.lookup lkup
         join edi.lookup_schema lkups
           on lkups.lookupid = lkup.lookupid
          and current_date between lkups.effectivedate and lkups.enddate
        where current_date between lkup.effectivedate and lkup.enddate
      ) lkups on lkups.lookupname = ('CDS_UHC_Life_ADD_Export')

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
  on ppcm.personid = pi.personid
 and current_date between ppcm.effectivedate and ppcm.enddate
 and current_timestamp between ppcm.createts and ppcm.endts 
 and ppcm.phonecontacttype = 'Mobile'    

left join person_compensation pc
  on pc.personid = pi.personid
 and current_date between pc.effectivedate and pc.enddate
 and current_timestamp between pc.createts and pc.endts 


left join person_bene_election pbe
  on pbe.personid = pi.personid
 and current_date between pbe.effectivedate and pbe.enddate
 and current_timestamp between pbe.createts and pbe.endts

left JOIN benefit_coverage_desc bcd 
  ON bcd.benefitcoverageid = pbe.benefitcoverageid
 AND current_date between bcd.effectivedate and bcd.enddate
 and current_timestamp between bcd.createts and bcd.endts 

left JOIN benefit_plan_desc bpd 
  ON bpd.benefitplanid = pbe.benefitplanid
 AND current_date between bpd.effectivedate and bpd.enddate
 and current_timestamp between bpd.createts and bpd.endts  

        
 

----- dependent data

left join person_dependent_relationship pdr
  on pdr.personid = pi.personid
 and pdr.dependentrelationship in ('D','C','DP')
 and current_date between pdr.effectivedate and pdr.enddate
 and current_timestamp between pdr.createts and pdr.endts

 
left join person_identity piD
  on piD.personid = pdr.dependentid
 and piD.identitytype = 'SSN'
 and current_timestamp between piD.createts and piD.endts 
 
left join person_names pnd
  on pnD.personid = pdr.dependentid
 and current_date between pnD.effectivedate and pnD.enddate
 and current_timestamp between pnD.createts and pnD.endts
 and pnD.nametype = 'Dep'
 
left join person_vitals pvD
  on pvD.personid = piD.personid
 and current_date between pvD.effectivedate and pvD.enddate
 and current_timestamp between pvD.createts and pvD.endts  

left join person_maritalstatus pmsd
  on pmsd.personid = pdr.dependentid
 and current_date between pmsd.effectivedate and pmsd.enddate
 and current_timestamp between pmsd.createts and pmsd.endts

left join person_address pas 
  on pas.personid = pi.personid
 and current_date between pas.effectivedate and pas.enddate
 and current_timestamp between pas.createts and pas.endts 
 
LEFT JOIN dependent_desc dd 
  ON dd.dependentid = pdr.dependentid 
 AND dd.effectivedate <= dd.enddate 
 AND now() <= dd.enddate AND now() >= dd.createts AND now() <= dd.endts 
 
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  and pdr.dependentid is not null
  and pbe.benefitplanid in ('36')
  and pbe.benefitelection = 'E'
  and pbe.selectedoption = 'Y'  
  and pe.emplstatus = 'A'
 
  order by 1
  ;
 