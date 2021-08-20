select 
 '3' ::char(1) as sort_seq
,'T' ::char(1) as record_indicator
,to_char(count(distinct pe.personid)+2 ,'FM0000000000') ::char(10) as record_count -- must include hdr and trl in counts

from person_identity pi

join edi.edi_last_update elu on elu.feedid = 'BEK_PayFlex_HSA_Eligibility_Export'
  
join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts
 and pe.emplstatus in ('T','A')

join person_bene_election pbemed
  on pbemed.personid = pe.personid
 and current_date between pbemed.effectivedate and pbemed.enddate
 and current_timestamp between pbemed.createts and pbemed.endts
 and pbemed.benefitelection = 'E'
 and pbemed.selectedoption = 'Y'   
 and pbemed.benefitsubclass in ('10')
 and pbemed.benefitplanid in ('9')
 and (pbemed.effectivedate >= elu.lastupdatets::DATE 
  or (pbemed.createts > elu.lastupdatets and pbemed.effectivedate < coalesce(elu.lastupdatets, '2017-01-01')) ) 
 
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts 
  
group by 1