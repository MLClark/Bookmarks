select distinct
 pi.personid
,'TERMED EE' ::varchar(30) as qsource 
,1 AS SORTSEQ
,left(pi.identity,3)||'-'||substring(pi.identity,4,2)||'-'||right(pi.identity,4) ::char(11) as essn
,'EMPLOYEE' ::varchar(15) as relation
,pn.fname ::varchar(30) as fname
,pn.lname ::varchar(50) as lname
,pn.mname ::char(1) as mname
,pv.gendercode ::char(1) as gender
,to_char(pv.birthdate,'mm/dd/yyyy')::char(10) as dob
,to_char(pe.emplhiredate,'mm/dd/yyyy')::char(10) as doh

,case when substring(pip.identity,1,5) = 'DAB00' then '120000A460'
      when substring(pip.identity,1,5) = 'DAB05' then '120000C460'
      when substring(pip.identity,1,5) = 'DAB10' then '1200000460'
      when substring(pip.identity,1,5) = 'DAB15' then '120000B460'
      else '1200000460' end ::char(11) as group_id

,cast(pp.scheduledhours / 2 as dec (18,2)) as hourspw   
,case when pc.frequencycode = 'H' then cast((pc.compamount * pp.scheduledhours) * 26 as dec(18,2)) 
      else cast(pc.compamount as dec(18,2)) end as annual_salary   

,pv.smoker ::char(1) as smoker_flag
,pa.streetaddress ::varchar(30) as addr1
,pa.streetaddress2 ::varchar(30) as addr2 
,pa.city ::varchar(30) as city
,pa.stateprovincecode ::char(2) as state
,pa.postalcode ::char(5) as zip
,ppcw.phoneno ::char(15) as workphone
,coalesce(pnc.url,pnch.url) ::varchar(100) AS email
,null as bene_rel
,null as bene_pct
,'Term' ::char(4) as status_chg      

,to_char(greatest(pbeac.enddate,pbecie.enddate,pbehi.enddate),'mm/dd/yyyy')::char(10) as edoc
,null as comp_state_question
----- accident (13) 
,case when pbeac.benefitsubclass = '13' then 'Accident' else null end ::varchar(30) as ae_plan_type
,case when bcdac.benefitcoveragedesc = 'Employee Only' then 'Employee'
      when bcdac.benefitcoveragedesc = 'Employee + Spouse' then 'Employee + Spouse'
      when bcdac.benefitcoveragedesc = 'Family' then 'Employee + Family'
      else bcdac.benefitcoveragedesc end ::varchar(30) as ae_insured_option
,cast(pbeac.monthlyamount/2 as dec(18,2)) as ae_prem_amt          
,to_char(pbeac.effectivedate,'mm/dd/yyyy')::char(10) as ae_edoi -- issue date
,to_char(pbeac.effectivedate,'mm/dd/yyyy')::char(10) as ae_edos -- signed date
,case when pbeac.benefitsubclass = '13' and pbeac.benefitelection = 'T' then to_char(pbeac.effectivedate,'mm/dd/yyyy')
      when pbeac.benefitsubclass = '13' and pe.emplstatus = 'T' then to_char(pe.effectivedate,'mm/dd/yyyy')
      else ' ' end ::char(10) as ae_edot
-----       
,null as di_plan_type
,null as di_benefit_amt
,null as di_prem_amt
,null as di_edoi
,null as di_edos
,null as di_edot
----- critical illness ('1W','1S')
,case when pbecie.benefitsubclass = '1W' then 'Critical Illness' 
      else null end ::varchar(30) as ci_plan_type
,case when bcdcie.benefitcoveragedesc = 'Employee Only' then 'Employee'
      when bcdcie.benefitcoveragedesc = 'Employee + Spouse' then 'Employee + Spouse'
      when bcdcie.benefitcoveragedesc = 'Family' then 'Employee + Family'
      else bcdcie.benefitcoveragedesc end ::varchar(30) as ci_insured_option
,case when pbecie.benefitsubclass = '1W' then 10000.00
      else null end as ci_bene_amt     
,case when pbecie.benefitsubclass = '1W' then pbecie.monthlyamount else null end as ci_prem_amt      
,to_char(pbecie.effectivedate,'mm/dd/yyyy')::char(10) as ci_edoi -- issue date
,to_char(pbecie.effectivedate,'mm/dd/yyyy')::char(10) as ci_edos -- signed date
,case when pbecie.benefitsubclass = '1W' and pbecie.benefitelection = 'T' then to_char(pbecie.effectivedate,'mm/dd/yyyy')
      when pbecie.benefitsubclass = '1W' and pe.emplstatus = 'T' then to_char(pe.effectivedate,'mm/dd/yyyy')
      else ' ' end ::char(10) as ci_edot


-----       
,null as ce_plan_type
,null as ce_benefit_amt
,null as ce_prem_amt
,null as ce_edoi
,null as ce_edos
,null as ce_edot

----- Hospital Indemnity ('1I')

,case when pbehi.benefitsubclass = '1I' and pbehi.benefitplanid in ('125','128','131','137','140','146') then 'Hospital Indemnity - Low (A)'
      when pbehi.benefitsubclass = '1I' and pbehi.benefitplanid in ('149','155','158','161','164','167') then 'Hospital Indemnity - High (B)'
      else null end ::varchar(30) as hi_plan_type
,case when bcdhi.benefitcoveragedesc = 'Employee Only' then 'Employee'
      when bcdhi.benefitcoveragedesc = 'Employee + Spouse' then 'Employee + Spouse'
      when bcdhi.benefitcoveragedesc = 'Family' then 'Employee + Family'
      else bcdhi.benefitcoveragedesc end ::varchar(30) as hi_insured_option 
,null as hi_benefit_amt
--,ppdhi.etv_amount as hi_benefit_amt
,case when pbehi.benefitsubclass = '1I' then pbehi.monthlyamount else null end as hi_prem_amt        
,to_char(pbehi.effectivedate,'mm/dd/yyyy')::char(10) as hi_edoi -- issue date
,to_char(pbehi.effectivedate,'mm/dd/yyyy')::char(10) as hi_edos -- signed date
,case when pbehi.benefitsubclass = '1I'and pbehi.benefitelection = 'T' then to_char(pbehi.effectivedate,'mm/dd/yyyy')
      when pbehi.benefitsubclass = '1I'and pe.emplstatus = 'T' then to_char(pe.effectivedate,'mm/dd/yyyy')
      else ' ' end ::char(10) as hi_edot      

-----       
,null as lf_plan_type
,null as lf_cert_amt
,null as lf_insured_option
,null as lf_prem_amt
,null as lf_edoi
,null as lf_edos
-----
,null as lti_rider
,null as lti_rider_amt
,null as sti_rider
,null as sti_rider_amt
,null as cti_rider
,null as cti_rider_amt
,null as lf_edot              

from person_identity pi

left join edi.edi_last_update elu on elu.feedid = 'DAB_Assurity_CI_HI_Accident_Export'

join person_identity pip
  on pip.personid = pi.personid
 and pip.identitytype = 'PSPID'
 and current_timestamp between pip.createts and pip.endts
 
join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts
 
join person_names pn
  on pn.personid = pe.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts 

join person_vitals pv
  on pv.personid = pe.personid
 and current_date between pv.effectivedate and pv.enddate
 and current_timestamp between pv.createts and pv.endts 

left join (select personid, max(perspospid) as perspospid 
             from pers_pos 
             LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'DAB_Assurity_CI_HI_Accident_Export'
             where current_timestamp between createts and endts 
            group by 1) as maxpos on maxpos.personid = pe.personid 

left join pers_pos pp 
  on pp.personid = maxpos.personid
 and pp.perspospid = maxpos.perspospid
 and current_timestamp between pp.createts and pp.endts 

left join (select personid, max(percomppid) as percomppid
             from person_compensation 
             LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'DAB_Assurity_CI_HI_Accident_Export'
              and effectivedate <= elu.lastupdatets::DATE 
             group by 1 ) as maxpc on maxpc.personid = pe.personid
 
left join person_compensation pc
  on pc.personid = maxpc.personid
 and pc.percomppid = maxpc.percomppid
 and current_timestamp between pc.createts and pc.endts 

left join person_address pa
  on pa.personid = pe.personid
 and pa.addresstype = 'Res'
 and current_date between pa.effectivedate and pa.enddate
 and current_timestamp between pa.createts and pa.endts 

left join person_net_contacts pnc 
  on pnc.personid = pi.personid 
 and pnc.netcontacttype = 'WRK'::bpchar 
 and current_date between pnc.effectivedate and pnc.enddate
 and current_timestamp between pnc.createts and pnc.enddate 
-- select * from person_net_contacts
left join person_net_contacts pnch 
  on pnch.personid = pi.personid 
 and pnch.netcontacttype = 'HomeEmail'::bpchar 
 and current_date between pnch.effectivedate and pnch.enddate
 and current_timestamp between pnch.createts and pnch.enddate  

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
  on ppch.personid = pi.personid
 and current_date between ppcm.effectivedate and ppcm.enddate
 and current_timestamp between ppcm.createts and ppcm.endts 
 and ppcm.phonecontacttype = 'Mobile'           
    
JOIN person_bene_election pbe 
  on pbe.personid = pi.personid 
 and pbe.selectedoption = 'Y' 
 and pbe.benefitelection in ('T','E')
 and pbe.benefitsubclass in  ('1W','1S','1I','13')
 --AND current_date between pbe.effectivedate AND pbe.enddate 
 AND current_timestamp between pbe.createts AND pbe.endts
  -- to be qualified for cobra the emp must have participated in employer's health care plan  
 and pbe.personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts 
                         and benefitsubclass in  ('1W','1S','1I','13') and benefitelection = 'E' and selectedoption = 'Y' and effectivedate < enddate) 


left join person_bene_election pbeac
  on pbeac.personid = pbe.personid 
 and pbeac.benefitsubclass = '13'
 and pbeac.benefitelection = 'E'
 and pbeac.selectedoption = 'Y'
 --and current_date between pbeac.effectivedate and pbeac.enddate
 and current_timestamp between pbeac.createts and pbeac.endts

left join person_bene_election pbecie
  on pbecie.personid = pbe.personid 
 and pbecie.benefitsubclass = '1W'
 and pbecie.benefitelection = 'E'
 and pbecie.selectedoption = 'Y'
 --and current_date between pbecie.effectivedate and pbecie.enddate
 and current_timestamp between pbecie.createts and pbecie.endts

left join person_bene_election pbecis
  on pbecis.personid = pbe.personid 
 and pbecis.benefitsubclass = '1S'
 and pbecis.benefitelection = 'E'
 and pbecis.selectedoption = 'Y'
 --and current_date between pbecis.effectivedate and pbecis.enddate
 and current_timestamp between pbecis.createts and pbecis.endts 

left join person_bene_election pbehi
  on pbehi.personid = pbe.personid 
 and pbehi.benefitsubclass = '1I'
 and pbehi.benefitelection = 'E'
 and pbehi.selectedoption = 'Y'
 --and current_date between pbehi.effectivedate and pbehi.enddate
 and current_timestamp between pbehi.createts and pbehi.endts    

left join benefit_coverage_desc bcd
  on bcd.benefitcoverageid = pbe.benefitcoverageid
 and current_date between bcd.effectivedate and bcd.enddate
 and current_timestamp between bcd.createts and bcd.endts   
 
left join benefit_coverage_desc bcdac
  on bcdac.benefitcoverageid = pbeac.benefitcoverageid
 and current_date between bcdac.effectivedate and bcdac.enddate
 and current_timestamp between bcdac.createts and bcdac.endts  

left join benefit_coverage_desc bcdcie
  on bcdcie.benefitcoverageid = pbecie.benefitcoverageid
 and current_date between bcdcie.effectivedate and bcdcie.enddate
 and current_timestamp between bcdcie.createts and bcdcie.endts  
 
left join benefit_coverage_desc bcdcis
  on bcdcis.benefitcoverageid = pbecis.benefitcoverageid
 and current_date between bcdcis.effectivedate and bcdcis.enddate
 and current_timestamp between bcdcis.createts and bcdcis.endts  

left join benefit_coverage_desc bcdhi
  on bcdhi.benefitcoverageid = pbehi.benefitcoverageid
 and current_date between bcdhi.effectivedate and bcdhi.enddate
 and current_timestamp between bcdhi.createts and bcdhi.endts    
 
left join benefit_plan_desc bpdhi
  on bpdhi.benefitsubclass = pbehi.benefitsubclass
 and current_date between bpdhi.effectivedate and bpdhi.enddate
 and current_timestamp between bpdhi.createts and bpdhi.endts                             
                         
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  and pe.emplstatus in ('T')
  and (pe.effectivedate >= elu.lastupdatets::DATE 
   or (pe.createts > elu.lastupdatets and pe.effectivedate < coalesce(elu.lastupdatets, '2017-01-01')) ) 
   and pe.personid = '2669'
 