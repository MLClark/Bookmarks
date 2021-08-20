select distinct

 pi.personid 
,'0' ::CHAR(1) as sort_seq
,'NEW ENROLLMENT EE' ::varchar(40) as qsource
,'1' ::char(1) as change_type
,pn.fname ::varchar(30) as fname
,pn.lname ::varchar(30) as lname
,pn.mname ::char(1) as mname
,pi.identity ::char(9) as ssn
,pa.streetaddress ::varchar(40) as addr1
,pa.streetaddress2 ::varchar(40) as addr2
,pa.city ::varchar(40) as city
,pa.stateprovincecode ::char(2) as state
,pa.postalcode ::char(5) as zip
,to_char(pv.birthdate,'yyyy-mm-dd')::char(10) as dob
,to_char(pe.emplhiredate,'yyyy-mm-dd')::char(10) as doh
,pv.gendercode ::char(1) as gender
,to_char(pbe.effectivedate,'yyyy-mm-dd')::char(10) as coverage_eff_date
,null as sp_name
,null as sp_fname
,null as sp_lname
,null as sp_mname
,null as sp_ssn
,null as sp_dob
,null as dp_name
,null as dp_fname
,null as dp_lname
,null as dp_mname
,null as dp_dob
,case when pbe.benefitsubclass in ('10','12') then 'Medical'
      when pbe.benefitsubclass in ('11','1H') then 'Dental'
      when pbe.benefitsubclass in ('14','1V') then 'Vision'
      end ::varchar(15) as coverage_type
      
,case when bcd.benefitcoveragedesc in ('Employee Only') then 'EE'
      when bcd.benefitcoveragedesc in ('Employee + Spouse') then ('EE+SPOUSE')
      when bcd.benefitcoveragedesc in ('Employee + Children','EE & 1 Dep','EE & Child') then ('EE+CHILDREN')
      when bcd.benefitcoveragedesc in ('EE&Child(ren) + DP Adult&DP Ch') then ('EE+FAMILY')
      when bcd.benefitcoveragedesc in ('Family') then ('EE+FAMILY')
      when pbe.benefitsubclass = '60' and pbe.benefitplanid = '66' then 'EE'
      when pbe.benefitsubclass = '61' and pbe.benefitplanid = '30' then 'EE+CHILDREN'
      else 'EE' end :: varchar(15) as coverage_level         

from person_identity pi

left join edi.edi_last_update elu on elu.feedid = 'DAB_EBenefits_Cobra_Export'

join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts

join (select effcovdate.personid,effcovdate.benefitsubclass,effcovdate.min_effectivedate,effcovdate.createts
        from (select pbe.personid,pbe.benefitsubclass, min(pbe.createts) as createts, min(pbe.effectivedate) as min_effectivedate,max(pbe.effectivedate) as max_effectivedate
                from person_bene_election pbe
               where pbe.benefitsubclass in ('10','11','12','14','1H','1V')
                 and pbe.selectedoption = 'Y' and pbe.benefitelection = 'E' 
               group by 1,2) effcovdate
       left join edi.edi_last_update elu on elu.feedid = 'DAB_EBenefits_Cobra_Export'
         
      where effcovdate.min_effectivedate = effcovdate.max_effectivedate
        and effcovdate.min_effectivedate >= elu.lastupdatets
         or effcovdate.createts >= elu.lastupdatets)  pbene on pbene.personid = pe.personid
        
join person_bene_election pbe 
  on pbe.personid = pbene.personid
 and pbe.benefitsubclass = pbene.benefitsubclass
 and pbe.selectedoption = 'Y'
 and pbe.benefitelection = 'E'
 and current_date between pbe.effectivedate and pbe.enddate
 and current_timestamp between pbe.createts and pbe.endts
 and pbe.effectivedate >= elu.lastupdatets
  
left join person_names pn
  on pn.personid = pe.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts
 
left join person_address pa
  on pa.personid = pe.personid
 and pa.addresstype = 'Res'
 and current_date between pa.effectivedate and pa.enddate
 and current_timestamp between pa.createts and pa.endts
 
left join person_vitals pv 
  on pv.personid = pe.personid
 and current_date between pv.effectivedate and pv.enddate
 and current_timestamp between pv.createts and pv.endts   
 
left JOIN benefit_coverage_desc bcd 
  on bcd.benefitcoverageid = pbe.benefitcoverageid 
 and current_date between bcd.effectivedate and bcd.enddate
 and current_timestamp between bcd.createts and bcd.endts 
 and bcd.effectivedate < bcd.enddate

where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  and pe.emplstatus = 'A' 
  and (pbe.effectivedate >= elu.lastupdatets::DATE 
   or (pbe.createts > elu.lastupdatets and pbe.effectivedate < coalesce(elu.lastupdatets, '2017-01-01')) )  