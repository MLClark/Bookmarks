select distinct
 pi.personid
,'SP Data' as source_seq
,'C' ::char(1) as sort_seq
,pie.identity ::char(9) as subscriber_id --dt1 
,'01' ::char(2) as member_indicator --dt2
,pnd.lname ::char(35) as lname --dt3
,pnd.fname ::char(15) as fname --dt4
,'SP' ::char(2) as mbr_rel --dt5
,pnd.mname ::char(1) as mname --dt6
,pad.streetaddress ::char(40) as addr1 --dt7
,pad.streetaddress2::char(40) as addr2 --dt8
,pad.city ::char(19) as city --dt9
,pad.stateprovincecode ::char(2) as state --dt10
,replace(pad.postalcode,'-','') ::char(9) as zip_split_me --dt11 & dt12
,coalesce(ppcM.phoneno,ppcH.phoneno) ::char(12) as homephone --dt13
,coalesce(ppcW.phoneno,ppcB.phoneno) ::char(12) as workphone --dt14
,pvd.gendercode ::char(1) as gender --dt15
,to_char(pvd.birthdate,'YYYYMMDD')::char(8) as dob --dt16

,'FACETS308016' ::char(30) as group_policy_nbr --dt17
,'2001' ::char(30) as subgrp_policy_nbr --dt18

,case when pe.effectivedate::date >= '2020-10-01' then to_char(date_trunc('MONTH',pe.effectivedate) + interval '1 MONTH','YYYYMMDD')  
      when pe.effectivedate::date <  '2020-10-01' then '20201001' end ::char(8) as emp_subgrp_eff_date --dt19

,'LE000188' ::char(10) as plan_code --dt20-- Basic Life AD&D 
      
,case when pe.effectivedate::date >= '2020-10-01' then to_char(date_trunc('MONTH',pe.effectivedate) + interval '1 MONTH','YYYYMMDD')  
      when pe.effectivedate::date <  '2020-10-01' then '20201001' end ::char(8) as plan_code_eff_date --dt21
      
,'C' ::char(1) as tier_code --dt22

,case when pe.effectivedate::date >= '2020-10-01' then to_char(date_trunc('MONTH',pe.effectivedate) + interval '1 MONTH','YYYYMMDD')  
      when pe.effectivedate::date <  '2020-10-01' then '20201001' end ::char(8) as mbr_orig_eff_date --dt23
      
,case when pbe.benefitelection = 'T' then to_char(pbe.effectivedate,'YYYYMMDD') 
      when pe.emplstatus in ('R','T') and pbe.benefitelection in ('E') then to_char(pe.effectivedate,'YYYYMMDD')
      else ' ' end ::char(8) as term_date --dt24

,' ' ::char(9) as alt_id --dt25
,' ' ::char(1) as student_status--dt26
,' ' ::char(1) as handicapped --dt27
,' ' ::char(3) as written_pref_lang--dt28
,' ' ::char(8) as written_pref_eff_date --dt29
,' ' ::char(3) as spoken_pref_lang --dt30
,' ' ::char(8) as spoken_pref_eff_date --dt31
,'N' ::char(1) as calap_elig_ind --dt32
,to_char(pe.effectivedate,'YYYYMMDD')::char(8) as doh --dt33

,case when pu.payunitxid = '00' then '2001'
      when pu.payunitxid = '03' then '2002'
      when pu.payunitxid = '04' then '2003' 
      when pu.payunitxid = '05' then '2004'
      when pu.payunitxid = '06' then '2005'
      when pu.payunitxid = '07' then '2006'
      when pu.payunitxid = '09' then '2007'
      when pu.payunitxid = '10' then '2008'
      when pu.payunitxid = '11' then '2009' end ::char(4) as sub_class_id --dt34
      
,case when pe.effectivedate::date >= '2020-10-01' then to_char(date_trunc('MONTH',pe.effectivedate) + interval '1 MONTH','YYYYMMDD')  
      when pe.effectivedate::date <  '2020-10-01' then '20201001' end ::char(8) as sub_class_eff_date --dt35
      
,'A'::char(1) as salary_type --dt36

,case when pc.frequencycode = 'H' then to_char(pc.compamount * 2080 ,'FM0000000D00') 
      when pc.compamount > 100000.00 then to_char(pc.compamount ,'FM0000000D00')
      when pc.frequencycode = 'A' then to_char(pc.compamount ,'FM0000000D00')
      else to_char(pc.compamount ,'FM0000000D00') end ::char(10) as salary_amount --dt37
      
,case when pe.effectivedate::date >= '2020-10-01' then to_char(date_trunc('MONTH',pe.effectivedate) + interval '1 MONTH','YYYYMMDD')  
      when pe.effectivedate::date <  '2020-10-01' then '20201001' end ::char(8) as salary_eff_date   --dt38
      
,to_char(pbe.coverageamount, 'FM0000000000') ::char(10) as plan_coverage_amount --dt39
,to_char(pbe.effectivedate,'YYYYMMDD') ::char(8) as plan_coverage_eff_date --dt40
,' ' ::char(8) as student_status_eff_date --dt41
,' ' ::char(8) as student_status_term_date --dt42
,' ' ::char(8) as handicap_eff_date --dt43
,' ' ::char(8) as handicap_term_date --dt44
,' ' ::char(1) as email_address --dt46

from person_identity pi

left join person_identity pie
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
 and pbe.effectivedate < pbe.enddate
 and current_timestamp between pbe.createts and pbe.endts
 and pbe.selectedoption = 'Y'
 
left join benefit_coverage_desc bcd 
  on bcd.benefitcoverageid = pbe.benefitcoverageid
 and current_date between bcd.effectivedate and bcd.enddate
 and current_timestamp between bcd.createts and bcd.endts 

left join benefit_plan_desc bpd 
  on bpd.benefitplanid = pbe.benefitplanid
 and current_date between bpd.effectivedate and bpd.enddate
 and current_timestamp between bpd.createts and bpd.endts         

left join person_payroll pp
  on pp.personid = pi.personid
 and current_date between pp.effectivedate and pp.enddate
 and current_timestamp between pp.createts and pp.endts

left join pay_unit pu
  on pu.payunitid = pp.payunitid
 and current_timestamp between pu.createts and pu.endts      

----- dependent data

join person_dependent_relationship pdr
  on pdr.personid = pi.personid
 and pdr.dependentrelationship in ('SP')
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

left join person_address pad 
  on pad.personid = pi.personid
 and current_date between pad.effectivedate and pad.enddate
 and current_timestamp between pad.createts and pad.endts 
 
LEFT JOIN dependent_desc dd 
  ON dd.dependentid = pdr.dependentid 
 AND dd.effectivedate <= dd.enddate 
 AND current_timestamp between dd.createts and dd.endts
 
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  and pbe.benefitsubclass in ('2S','23')

  order by 1
  ;
 