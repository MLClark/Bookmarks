select distinct
 pi.personid
,pe.empllasthiredate
,pie.identity
,pbe.benefitsubclass
,pbe.benefitelection
,pbe.effectivedate
,pbe.enddate
,'EE Data' as source_seq
,'B' ::char(1) as sort_seq
,pi.identity ::char(9) as subscriber_id --dt1 
,'00' ::char(2) as member_indicator --dt2
,pne.lname ::char(35) as lname --dt3
,pne.fname ::char(15) as fname --dt4
,'EE' ::char(2) as mbr_rel --dt5
,pne.mname ::char(1) as mname --dt6
,pae.streetaddress ::char(40) as addr1 --dt7
,pae.streetaddress2::char(40) as addr2 --dt8
,pae.city ::char(19) as city --dt9
,pae.stateprovincecode ::char(2) as state --dt10
,replace(pae.postalcode,'-','') ::char(9) as zip_split_me --dt11 & dt12
,coalesce(ppcM.phoneno,ppcH.phoneno) ::char(12) as homephone --dt13
,coalesce(ppcW.phoneno,ppcB.phoneno) ::char(12) as workphone --dt14
,pve.gendercode ::char(1) as gender --dt15
,to_char(pve.birthdate,'YYYYMMDD')::char(8) as dob --dt16

,'FACETS308016' ::char(30) as group_policy_nbr --dt17
,'2001' ::char(30) as subgrp_policy_nbr --dt18

,case when pe.empllasthiredate > '2020-10-01' and pd.positiontitle ilike '%Sale%' then to_char(pe.empllasthiredate + interval '6 month' + interval '1 day','YYYYMMDD')
      when pe.empllasthiredate > '2020-10-01' and pd.positiontitle NOT ilike '%Sale%' then to_char(pe.empllasthiredate + interval '3 month' + interval '1 day','YYYYMMDD')    
      when pe.empllasthiredate::date <  '2020-10-01' then '20201001' end ::char(8) as emp_subgrp_eff_date --dt19

,'LE000187' ::char(10) as plan_code_187 --dt20-- Basic Life AD&D 
,'LE000188' ::char(10) as plan_code_188 --dt20-- Basic Life AD&D 
      
,case when pe.empllasthiredate > '2020-10-01' and pd.positiontitle ilike '%Sale%' then to_char(pe.empllasthiredate + interval '6 month' + interval '1 day','YYYYMMDD')
      when pe.empllasthiredate > '2020-10-01' and pd.positiontitle NOT ilike '%Sale%' then to_char(pe.empllasthiredate + interval '3 month' + interval '1 day','YYYYMMDD')    
      when pe.empllasthiredate::date <  '2020-10-01' then '20201001' end ::char(8) as plan_code_eff_date --dt21
      
,'C ' ::char(2) as tier_code --dt22

,case when pe.empllasthiredate > '2020-10-01' and pd.positiontitle ilike '%Sale%' then to_char(pe.empllasthiredate + interval '6 month' + interval '1 day','YYYYMMDD')
      when pe.empllasthiredate > '2020-10-01' and pd.positiontitle NOT ilike '%Sale%' then to_char(pe.empllasthiredate + interval '3 month' + interval '1 day','YYYYMMDD')    
      when pe.empllasthiredate::date <  '2020-10-01' then '20201001' end ::char(8) as mbr_orig_eff_date --dt23
      
,case when ((pbe.benefitelection = 'T') or (pe.emplstatus in ('R','T'))) then to_char(pbe.enddate,'YYYYMMDD')
      else ' ' end ::char(8) as term_date --dt24

,' ' ::char(9) as alt_id --dt25
,' ' ::char(1) as student_status--dt26
,' ' ::char(1) as handicapped --dt27
,' ' ::char(3) as written_pref_lang--dt28
,' ' ::char(8) as written_pref_eff_date --dt29
,' ' ::char(3) as spoken_pref_lang --dt30
,' ' ::char(8) as spoken_pref_eff_date --dt31
,'N' ::char(1) as calap_elig_ind --dt32
,to_char(pe.empllasthiredate,'YYYYMMDD')::char(8) as doh --dt33

,case when pu.payunitxid = '00' then '2001'
      when pu.payunitxid = '03' then '2002'
      when pu.payunitxid = '04' then '2003' 
      when pu.payunitxid = '05' then '2004'
      when pu.payunitxid = '06' then '2005'
      when pu.payunitxid = '07' then '2006'
      when pu.payunitxid = '09' then '2007'
      when pu.payunitxid = '10' then '2008'
      when pu.payunitxid = '11' then '2009' end ::char(4) as sub_class_id --dt34
      
,case when pe.effectivedate::date >= '2020-10-01' then to_char(pe.effectivedate,'YYYYMMDD')    
      when pe.effectivedate::date <  '2020-10-01' then '20201001' end ::char(8) as sub_class_eff_date --dt35
      
,'A'::char(1) as salary_type --dt36

,case when pc.frequencycode = 'H' then to_char(pc.compamount * 2080 ,'FM0000000D00') 
      when pc.compamount > 100000.00 then to_char(pc.compamount ,'FM0000000D00')
      when pc.frequencycode = 'A' then to_char(pc.compamount ,'FM0000000D00')
      else to_char(pc.compamount ,'FM0000000D00') end ::char(10) as salary_amount --dt37
      
,case when pe.empllasthiredate > '2020-10-01' and pd.positiontitle ilike '%Sale%' then to_char(pe.empllasthiredate + interval '6 month' + interval '1 day','YYYYMMDD')
      when pe.empllasthiredate > '2020-10-01' and pd.positiontitle NOT ilike '%Sale%' then to_char(pe.empllasthiredate + interval '3 month' + interval '1 day','YYYYMMDD')    
      when pe.empllasthiredate::date <  '2020-10-01' then '20201001' end ::char(8) as salary_eff_date   --dt38
      
,to_char(pbe.coverageamount, 'FM0000000000') ::char(10) as plan_coverage_amount --dt39

,case when pe.empllasthiredate > '2020-10-01' and pd.positiontitle ilike '%Sale%' then to_char(pe.empllasthiredate + interval '6 month' + interval '1 day','YYYYMMDD')
      when pe.empllasthiredate > '2020-10-01' and pd.positiontitle NOT ilike '%Sale%' then to_char(pe.empllasthiredate + interval '3 month' + interval '1 day','YYYYMMDD')    
      when pe.empllasthiredate::date <  '2020-10-01' then '20201001' end ::char(8) as plan_coverage_eff_date --dt40
,' ' ::char(8) as student_status_eff_date --dt41
,' ' ::char(8) as student_status_term_date --dt42
,' ' ::char(8) as handicap_eff_date --dt43
,' ' ::char(8) as handicap_term_date --dt44
,' ' ::char(11) as alt_member_ind --dt45
,' ' ::char(1) as email_address --dt46
,elu.lastupdatets

from person_identity pi

left join edi.edi_last_update elu on elu.feedid = 'CDS_UHC_Life_ADD_Export'

left join person_identity pie
  on pie.personid = pi.personid
 and pie.identitytype = 'EmpNo'
 and current_timestamp between pie.createts and pie.endts

join 
( select lkups.lookupname, lkups.lookupid, lkup.lookupid, lkup.key1, lkup.value1, lkup.key2, lkup.value2, lkup.key3, lkup.value3, lkup.key4, lkup.value4, lkup.key5, lkup.value5
         from edi.lookup lkup
         join edi.lookup_schema lkups
           on lkups.lookupid = lkup.lookupid
          and current_date between lkups.effectivedate and lkups.enddate
        where current_date between lkup.effectivedate and lkup.enddate
      ) lkups on lkups.lookupname = ('CDS_UHC_Life_ADD_Export')

join person_names pne
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
 
left join person_employment pe 
  on pe.personid = pi.personid 
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts
 
 
left join person_address pae 
  on pae.personid = pi.personid
 and current_date between pae.effectivedate and pae.enddate
 and current_timestamp between pae.createts and pae.endts

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
 
left join (select pbe.personid, pbe.benefitelection, pbe.benefitcoverageid, pbe.benefitsubclass, pbe.benefitplanid, pbe.coverageamount, pbe.eventdate, max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate,RANK() OVER (PARTITION BY pbe.personid ORDER BY MAX(pbe.effectivedate) DESC) AS RANK
             from person_bene_election pbe
            where pbe.benefitsubclass = '23' and pbe.benefitelection = 'E' and pbe.selectedoption = 'Y' and pbe.effectivedate < pbe.enddate and current_timestamp between pbe.createts and pbe.endts -- and ppe.eventdate >= cppy.planyearstart
              and pbe.personid not in (select personid from person_employment 
                                         join edi.edi_last_update elu on elu.feedid = 'CDS_UHC_Life_ADD_Export'
                                        where current_date between effectivedate and enddate and current_timestamp between createts and endts and emplstatus in ('R','T') and effectivedate <= elu.lastupdatets)
            group by pbe.personid, pbe.benefitelection, pbe.benefitcoverageid, pbe.benefitsubclass, pbe.benefitplanid, pbe.coverageamount, pbe.eventdate) pbe on pbe.personid = pi.personid and pbe.rank = 1

left join person_payroll pp
  on pp.personid = pi.personid
 and current_date between pp.effectivedate and pp.enddate
 and current_timestamp between pp.createts and pp.endts

left join pay_unit pu
  on pu.payunitid = pp.payunitid
 and current_timestamp between pu.createts and pu.endts      
 
left join pers_pos pos 
  on pos.personid = pi.personid
 and current_date between pos.effectivedate and pos.enddate
 and current_timestamp between pos.createts and pos.endts
 
left join position_desc pd
  on pd.positionid = pos.positionid
 and current_date between pd.effectivedate and pd.enddate
 and current_timestamp between pd.createts and pd.endts  
 
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  and pbe.benefitsubclass in ('23')
  and ((pe.emplstatus in ('R','T') and pe.effectivedate >= elu.lastupdatets) 
   or  (pe.emplstatus not in ('R','T')))

  
  order by pie.identity