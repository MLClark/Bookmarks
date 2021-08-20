 SELECT distinct  
 pi.personid
,'eligibility'::char(11) as record_type
,'19 ACTIVE EE' ::varchar(30) as qsource 
,'PeopleStrategy' :: varchar(50) as PartnerID
,replace(pi.identity,'-','') :: varchar(255) as InsuredID
,replace(pi.identity,'-','')||'01' :: varchar(255) as MemberID
,'18' ::char(2) as relation
,rtrim(pn.lname) :: varchar(50) as emp_last_name
,rtrim(ltrim(pn.fname)) :: varchar(50) as emp_first_name
,rtrim(ltrim(pn.mname)) :: varchar(50) as emp_middle_initial
,case when substring(pi.identity from 4 for 1) = '-' then pi.identity 
      else left(pi.identity,3)||'-'||substring(pi.identity,4,2)||'-'||substring(pi.identity,6,4)::char(11) end as  emp_ssn
,'C98599' ::varchar(25) as  GroupID
,'C98599 Flexible Compensation Plan'::varchar(100) as group_name
,rtrim(ltrim(pa.streetaddress)) ::varchar(255) as address1
,rtrim(ltrim(pa.streetaddress2)) ::varchar(255) as address2
,rtrim(ltrim(pa.city)) ::varchar(50) as city
,rtrim(ltrim(pa.stateprovincecode)) ::char(2) as state
,replace(pa.postalcode,'-','')   ::char(10) as zip_code
,to_char(pv.birthdate, 'yyyy-mm-dd')::char(10) as emp_dob
,to_char(pe.emplhiredate,'yyyy-mm-dd') ::char(10) as emp_doh
,replace(ppcw.phoneno,'-','') ::char(10) as w_phone
,null ::char(5) as w_phone_ext
,replace(ppch.phoneno,'-','') ::char(10) as h_phone
,null ::char(5) as h_phone_ext
,replace(ppcm.phoneno,'-','') ::char(10) as c_phone
,null ::char(10) as fax
,rtrim(ltrim(pncw.url)) ::varchar(100) as w_email
,rtrim(ltrim(pnch.url))::varchar(100) as p_email
,case when pncw.url is not null then '1'
      when pncw.url is null then '0' end ::char(1) as use_work_email
,to_char(pbe.effectivedate,'yyyy-mm-dd') ::char(10) as eff_date
,to_char(pbe.planyearenddate,'yyyy-mm-dd') ::char(10) as end_date
,case when pbe.benefitsubclass = '60' then 'MED'
      when pbe.benefitsubclass = '61' then 'DEP'
      end ::varchar(20) as plan_type
,case when pbe.coverageamount != 0 then to_char(coalesce(pbe.coverageamount,0),'999999.99')
      when pbe.coverageamount  = 0 then to_char(coalesce(greatest(pocmfsa.employeerate,pocdfsa.employeerate),0),'999999.99') end as election
,to_char(coalesce(pbe.monthlyemployeramount,0),'999999.99') as er_contribution
,case when pu.frequencycode = 'B' then 'BW26' else null end ::char(50) as payroll_Schedule

,lc.locationcode
,lu.value1 ::varchar(50) AS division
,null ::char(50) as alt_id
,pv.gendercode ::char(1) as gender
,null as hicn     

from person_identity pi

LEFT join edi.edi_last_update elu on elu.feedid = 'AMJ_EBC_FSA_Eligibility'

join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts

join person_bene_election pbe
  on pbe.personid = pe.personid
 and pbe.benefitsubclass in ('60','61')
 and pbe.benefitelection = 'E'
 and pbe.selectedoption = 'Y'
 and pbe.enddate >= '2199-12-30'
 and current_date between pbe.effectivedate and pbe.enddate
 and current_timestamp between pbe.createts and pbe.endts
 
left join person_bene_election pbemfsa
  on pbemfsa.personid = pbe.personid
 and pbemfsa.benefitsubclass in ('60')
 and pbemfsa.benefitelection = 'E'
 and pbemfsa.selectedoption = 'Y'
 and pbemfsa.enddate >= '2199-12-30'
 and current_date between pbemfsa.effectivedate and pbemfsa.enddate
 and current_timestamp between pbemfsa.createts and pbemfsa.endts
 
left join person_bene_election pbedfsa
  on pbedfsa.personid = pbe.personid
 and pbedfsa.benefitsubclass in ('61')
 and pbedfsa.benefitelection = 'E'
 and pbedfsa.selectedoption = 'Y'
 and pbedfsa.enddate >= '2199-12-30'
 and current_date between pbedfsa.effectivedate and pbedfsa.enddate
 and current_timestamp between pbedfsa.createts and pbedfsa.endts 
 
left join personbenoptioncostl pocmfsa
  on pocmfsa.personid = pbemfsa.personid
 and pocmfsa.benefitelection = 'E'
 and pocmfsa.personbeneelectionpid = pbemfsa.personbeneelectionpid
 and pocmfsa.costsby = 'A'
 
left join personbenoptioncostl pocdfsa
  on pocdfsa.personid = pbedfsa.personid
 and pocdfsa.benefitelection = 'E'
 and pocdfsa.personbeneelectionpid = pbedfsa.personbeneelectionpid
 and pocdfsa.costsby = 'A'

left join person_names pn 
  on pn.personid = pe.personid 
 and pn.nametype = 'Legal'::bpchar 
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts

left join person_address pa 
  on pa.personid = pe.personid 
 and pa.addresstype = 'Res'::bpchar 
 and current_date between pa.effectivedate and pa.enddate
 and current_timestamp between pa.createts and pa.endts

left join person_vitals pv 
  on pv.personid = pe.personid 
 and current_date between pv.effectivedate and pv.enddate
 and current_timestamp between pv.createts and pv.endts 

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
 
left join person_net_contacts pnch
  on pnch.personid = pe.personid
 and pnch.netcontacttype = 'HomeEmail'
 and current_date between pnch.effectivedate and pnch.enddate
 and current_timestamp between pnch.createts and pnch.endts
 
left join person_net_contacts pncw
  on pncw.personid = pe.personid
 and pncw.netcontacttype = 'WRK'
 and current_date between pncw.effectivedate and pncw.enddate
 and current_timestamp between pncw.createts and pncw.endts

left join person_net_contacts pnco
  on pnco.personid = pe.personid
 and pnco.netcontacttype = 'OtherEmail'
 and current_date between pnco.effectivedate and pnco.enddate
 and current_timestamp between pnco.createts and pnco.endts

left join benefit_plan_desc bpd 
  on bpd.benefitplanid = pbe.benefitplanid 
 and current_date between bpd.effectivedate and bpd.enddate
 and current_timestamp between bpd.createts and bpd.endts 

left join person_payroll pp 
  on pp.personid = pi.personid 
 and current_date between pp.effectivedate and pp.enddate 
 and current_timestamp between pp.createts and pp.endts

left join pay_unit pu on pu.payunitid = pp.payunitid  
 
left join person_locations pl
  on pl.personid = pe.personid 
 and pl.personlocationtype = 'P'::bpchar 
 and current_date between pl.effectivedate and pl.enddate
 and current_timestamp between pl.createts and pl.endts

left join location_codes lc 
  on lc.locationid = pl.locationid  
 and current_date between lc.effectivedate and lc.enddate
 and current_timestamp between lc.createts and lc.endts  

left join ( select lkup.lookupid,lkup.key1,lkup.value1 
         from edi.lookup lkup
         join edi.lookup_schema lkups
           on lkups.lookupid = lkup.lookupid
          and current_date between lkups.effectivedate and lkups.enddate
        where current_date between lkup.effectivedate and lkup.enddate
          and lkups.lookupname = 'AMJ HSA/FSA Eligibility Feed'
      ) lu on 1 = 1  and lc.locationcode = lu.key1  
      

where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  and pe.emplstatus in ('A','L') 
  and pe.personid in ('2685')