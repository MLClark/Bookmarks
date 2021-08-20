select distinct

--- note this has a union to determine deletes
 pi.personid
,case when pe.effectivedate <= elu.lastupdatets and greatest(pbemed.effectivedate,pbeden.effectivedate,pbevsn.effectivedate) >= elu.lastupdatets then 'C' 
      when pe.effectivedate >= elu.lastupdatets and greatest(pbemed.effectivedate,pbeden.effectivedate,pbevsn.effectivedate) >= elu.lastupdatets then 'A' 
      end ::char(1) as transaction_code
,'E' as emp_or_dep_code
,to_char(pe.effectivedate, 'MMDDYYYY') as transaction_eff_date
,left(pi.identity,3)||'-'||substring(pi.identity,4,2)||'-'||substring(pi.identity,6,4)  as emp_ssn
,rtrim(pn.lname)::varchar(50) as last_name
,rtrim(ltrim(pn.fname))::varchar(50) as first_name
,rtrim(ltrim(pn.mname))::char(1)  as middle_name
,pv.gendercode ::char(1) as gender
,left(pi.identity,3)||'-'||substring(pi.identity,4,2)||'-'||substring(pi.identity,6,4)  as ssn
,to_char(pv.birthdate,'MMDDYYYY') ::char(8)  as dob
,to_char(pe.emplhiredate,'MMDDYYYY')::char(8)  as emp_doh
,rtrim(ltrim(pa.streetaddress))::varchar(50)  as emp_address
,rtrim(ltrim(pa.city))::varchar(50)  as emp_city
,rtrim(ltrim(pa.stateprovincecode))::char(2) as emp_state
,rtrim(ltrim(pa.postalcode))::char(9) as emp_zip
,rtrim(ltrim(ppch.phoneno,''))::varchar(10) as emp_phone

,case when pbemed.benefitsubclass = '10' then 'QVIMED' end ::varchar(10) as med_plan
,case when bcdmed.benefitcoveragedesc = 'Employee Only' then 'EE' 
      when bcdmed.benefitcoveragedesc = 'Employee + Spouse' then 'EE+SP' 
      when bcdmed.benefitcoveragedesc = 'Employee + Children' then 'EE+CH'
      when bcdmed.benefitcoveragedesc = 'Family' then 'FAM'
       end ::varchar(10) as med_coverage
,to_char(pbemed.effectivedate,'MMDDYYYY')::char(8) as med_effective_date       

,case when pbeden.benefitsubclass = '11' then 'QVIDENT' end ::varchar(10) as dent_plan
,case when bcdden.benefitcoveragedesc = 'Employee Only' then 'EE' 
      when bcdden.benefitcoveragedesc = 'Employee + Spouse' then 'EE+SP' 
      when bcdden.benefitcoveragedesc = 'Employee + Children' then 'EE+CH'
      when bcdden.benefitcoveragedesc = 'Family' then 'FAM'
       end ::varchar(10) as dent_coverage       
,to_char(pbeden.effectivedate,'MMDDYYYY')::char(8) as dent_effective_date         
         
,case when pbevsn.benefitsubclass = '14' then 'QVIVIS' end ::varchar(10) as vision_plan
,case when bcdvsn.benefitcoveragedesc = 'Employee Only' then 'EE' 
      when bcdvsn.benefitcoveragedesc = 'Employee + Spouse' then 'EE+SP' 
      when bcdvsn.benefitcoveragedesc = 'Employee + Children' then 'EE+CH'
      when bcdvsn.benefitcoveragedesc = 'Family' then 'FAM'
       end ::varchar(10) as vision_coverage  
,to_char(pbevsn.effectivedate,'MMDDYYYY')::char(8) as vision_effective_date        
         
,coalesce(pbemed.benefitelection,pbeden.benefitelection,pbevsn.benefitelection,pe.emplstatus) ::char(1) as reason

         
from person_identity pi

left join edi.edi_last_update elu on feedid = 'BCE_med_den_vision_QVI_Benefits'

LEFT JOIN person_employment pe
  ON pe.personid = pi.personid
 AND current_date BETWEEN pe.effectivedate AND pe.enddate
 AND current_timestamp BETWEEN pe.createts AND pe.endts

LEFT JOIN person_names pn 
  ON pn.personid = pi.personid 
 AND pn.nametype = 'Legal'::bpchar 
 AND current_date between pn.effectivedate and pn.enddate
 AND current_timestamp between pn.createts and pn.endts

LEFT JOIN person_vitals pv 
  on pv.personid = pi.personid
 AND current_date between pv.effectivedate and pv.enddate
 AND current_timestamp between pv.createts and pv.endts

LEFT JOIN person_address pa
  ON pa.personid = pi.personid 
 and pa.addresstype = 'Res'
 and current_date between pa.effectivedate and pa.enddate
 and current_timestamp between pa.createts and pa.endts
 
LEFT JOIN person_phone_contacts ppch
  ON ppch.personid = pi.personid 
 AND ppch.phonecontacttype = 'Home' 
 and current_date between ppch.effectivedate and ppch.enddate
 and current_timestamp between ppch.createts and ppch.endts
 
JOIN person_bene_election pbemed 
  on pbemed.personid = pi.personid 
 and pbemed.benefitelection = 'E' 
 and pbemed.selectedoption  = 'Y' 
 and pbemed.benefitsubclass = '10'
 and current_date between pbemed.effectivedate and pbemed.enddate
 and current_timestamp between pbemed.createts and pbemed.endts
 
LEFT JOIN benefit_plan_desc bpdmed 
  on bpdmed.benefitsubclass = '10'
 AND current_date between bpdmed.effectivedate and bpdmed.enddate
 AND current_timestamp between bpdmed.createts and bpdmed.endts
 
LEFT JOIN benefit_coverage_desc bcdmed 
  on bcdmed.benefitcoverageid = pbemed.benefitcoverageid 
 AND current_date between bcdmed.effectivedate and bcdmed.enddate
 AND current_timestamp between bcdmed.createts and bcdmed.endts
 
JOIN person_bene_election pbeden 
  on pbeden.personid = pi.personid 
 and pbeden.benefitelection = 'E'
 and pbeden.selectedoption  = 'Y' 
 and pbeden.benefitsubclass = '11' 
 and current_date between pbeden.effectivedate and pbeden.enddate
 and current_timestamp between pbeden.createts and pbeden.endts

LEFT JOIN benefit_plan_desc bpdden  
  on bpdden.benefitsubclass = '11'
 AND current_date between bpdden.effectivedate and bpdden.enddate
 AND current_timestamp between bpdden.createts and bpdden.endts

LEFT JOIN benefit_coverage_desc bcdden 
  on bcdden.benefitcoverageid = pbeden.benefitcoverageid 
 AND current_date between bcdden.effectivedate and bcdden.enddate
 AND current_timestamp between bcdden.createts and bcdden.endts

JOIN person_bene_election pbevsn
  on pbevsn.personid = pi.personid 
 and pbevsn.benefitelection = 'E' 
 and pbevsn.selectedoption  = 'Y' 
 and pbevsn.benefitsubclass = '14' 
 and current_date between pbevsn.effectivedate and pbevsn.enddate
 and current_timestamp between pbevsn.createts and pbevsn.endts

LEFT JOIN benefit_plan_desc bpdvsn 
  on bpdvsn.benefitsubclass = '14'
 AND current_date between bpdvsn.effectivedate and bpdvsn.enddate
 AND current_timestamp between bpdvsn.createts and bpdvsn.endts

LEFT JOIN benefit_coverage_desc bcdvsn
  on bcdvsn.benefitcoverageid = pbevsn.benefitcoverageid 
 AND current_date between bcdvsn.effectivedate and bcdvsn.enddate
 AND current_timestamp between bcdvsn.createts and bcdvsn.endts


WHERE pi.identitytype = 'SSN'
  AND CURRENT_TIMESTAMP BETWEEN pi.createts and pi.endts 

  and 
  -- checks for name change
exists (select 1 
          from person_names pn1
         where pn1.personid = pi.personid
           and pn1.nametype = 'Legal' 
           and current_date      between pn1.effectivedate and pn1.enddate
           and current_timestamp between pn1.createts      and pn1.endts
           and greatest(pn1.effectivedate,pn1.createts) > elu.lastupdatets               
        )  
or
-- vitals change
exists (select 1 
          from person_vitals pv1
         where pv1.personid = pi.personid
           and current_date      between pv1.effectivedate and pv1.enddate
           and current_timestamp between pv1.createts      and pv1.endts
           and greatest(pv1.effectivedate,pv1.createts) > elu.lastupdatets    
        )        
or 
--- benefit changes
(        
exists (select 1
          from person_bene_election pbemed1
         where pbemed1.personid = pbemed.personid
           and current_date      between pbemed1.effectivedate and pbemed1.enddate
           and current_timestamp between pbemed1.createts      and pbemed1.endts
           and greatest(pbemed1.effectivedate,pbemed1.createts) > elu.lastupdatets           
           and pbemed1.benefitplanid in ('10')     
        )       
or
exists (select 1 
          from person_bene_election pbeden1
         where pbeden1.personid = pbeden.personid
           and current_date      between pbeden1.effectivedate and pbeden1.enddate
           and current_timestamp between pbeden1.createts      and pbeden1.endts
           and greatest(pbeden1.effectivedate,pbeden1.createts) > elu.lastupdatets           
           and pbeden1.benefitplanid in ('11')     
        ) 
or
exists (select 1
          from person_bene_election pbevsn1
         where pbevsn1.personid = pbevsn.personid
           and current_date      between pbevsn1.effectivedate and pbevsn1.enddate
           and current_timestamp between pbevsn1.createts      and pbevsn1.endts
           and greatest(pbevsn1.effectivedate,pbevsn1.createts) > elu.lastupdatets           
           and pbevsn1.benefitplanid in ('14')     
        )            

)             