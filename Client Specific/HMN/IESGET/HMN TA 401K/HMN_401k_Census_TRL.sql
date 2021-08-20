select 
'T' as ID
,to_char(count(distinct pi.personid),'000000000') ::char(10) as record_count
,'09878' as client_id
,'999999999' ::char(9) as ssn


 
from person_identity pi

join edi.edi_last_update elu on elu.feedid = 'HMN_401k_Census_File_Export'

join person_identity pip
  on pip.personid = pi.personid
 and pip.identitytype = 'PSPID'
 and current_timestamp between pip.createts and pip.endts
 
join person_names pn
  on pn.personid = pi.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts 

join person_address pa
  on pa.personid = pi.personid
 and pa.addresstype = 'Res'
 and current_date between pa.effectivedate and pa.enddate
 and current_timestamp between pa.createts and pa.endts

join person_vitals pv
  on pv.personid = pi.personid
 and current_date between pv.effectivedate and pv.enddate
 and current_timestamp between pv.createts and pv.endts 
 
join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts 
-- and pe.emplstatus = 'A'
 --and pe.emplevent = 'Hire'

left JOIN pers_pos pp 
  ON pp.personid = pi.personid 
 and current_date between pp.effectivedate and pp.enddate  
 AND current_timestamp between pp.createts AND pp.endts 
 AND pp.persposrel = 'Occupies'::bpchar

left join (select periodstartdate, periodenddate, periodpaydate from pay_schedule_period) pspdate
  on pspdate.periodpaydate = ?::date

where pi.identitytype = 'SSN'
  and current_date between pi.createts and pi.endts
  and pe.emplclass <> 'T'
  and 
  
(      
exists (select 1 
          from person_identity pi1
         where pi1.personid     = pi.personid
           and pi1.identitytype = 'SSN' 
           and current_timestamp between pi1.createts and pi1.endts
           and pi1.createts >= elu.lastupdatets)
           -- select * from person_identity where personid = '63379' and createts >= '2018-01-01';
or
exists (select 1 
          from person_identity pip1
         where pip1.personid     = pi.personid
           and pip1.identitytype = 'PSPID' 
           and current_timestamp between pip1.createts and pip1.endts
           and pip1.createts >= elu.lastupdatets)        
or
exists (select 1 
          from person_names pn1
         where pn1.personid = pi.personid
           and pn1.nametype = 'Legal' 
           and current_date      between pn1.effectivedate and pn1.enddate
           and current_timestamp between pn1.createts      and pn1.endts
           and (pn1.effectivedate >= elu.lastupdatets::DATE 
            or (pn1.createts > elu.lastupdatets and pn1.effectivedate < coalesce(elu.lastupdatets, '2017-01-01')) ))
or
exists (select 1 
          from person_address pa1
         where pa1.personid = pi.personid
           and pa1.addresstype = 'Res' 
           and current_date      between pa1.effectivedate and pa1.enddate
           and current_timestamp between pa1.createts      and pa1.endts
           and (pa1.effectivedate >= elu.lastupdatets::DATE 
            or (pa1.createts > elu.lastupdatets and pa1.effectivedate < coalesce(elu.lastupdatets, '2017-01-01')) ))   
or
exists (select 1 
          from person_vitals pv1
         where pv1.personid = pi.personid
           and current_date      between pv1.effectivedate and pv1.enddate
           and current_timestamp between pv1.createts      and pv1.endts
           and (pv1.effectivedate >= elu.lastupdatets::DATE 
            or (pv1.createts > elu.lastupdatets and pv1.effectivedate < coalesce(elu.lastupdatets, '2017-01-01')) ))
or
exists (select 1 
          from person_employment pe1
         where pe1.personid = pi.personid
           and current_date      between pe1.effectivedate and pe1.enddate
           and current_timestamp between pe1.createts      and pe1.endts
           and (pe1.effectivedate >= elu.lastupdatets::DATE 
            or (pe1.createts > elu.lastupdatets and pe1.effectivedate < coalesce(elu.lastupdatets, '2017-01-01')) ))
or
exists (select 1 
          from person_compensation pc1
         where pc1.personid = pi.personid
           and current_date      between pc1.effectivedate and pc1.enddate
           and current_timestamp between pc1.createts      and pc1.endts
           and (pc1.effectivedate >= elu.lastupdatets::DATE 
            or (pc1.createts > elu.lastupdatets and pc1.effectivedate < coalesce(elu.lastupdatets, '2017-01-01')) ))
or
exists (select 1 
          from pers_pos pp1
         where pp1.personid = pi.personid
           and current_date      between pp1.effectivedate and pp1.enddate
           and current_timestamp between pp1.createts      and pp1.endts
           and (pp1.effectivedate >= elu.lastupdatets::DATE 
            or (pp1.createts > elu.lastupdatets and pp1.effectivedate < coalesce(elu.lastupdatets, '2017-01-01')) ))            
                              
) ;