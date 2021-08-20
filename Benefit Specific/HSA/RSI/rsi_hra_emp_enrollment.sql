--==================================================================================
/* 
   PARTICIPANTS
*/
--==================================================================================

SELECT distinct
 pi.personid
,replace(pu.employertaxid,'-','')       AS "Client Federal Id"
,'0'                      		AS "Plan Year Id"
,pi.identity ::        		AS "Participant Id"

from person_identity pi

join edi.edi_last_update elu on elu.feedid = 'RSI_DBS_HRA_Enrollment'
join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts

join person_bene_election pbe 
  on pbe.personid = pe.personid
 and current_date between pbe.effectivedate and pbe.enddate 
 and current_timestamp between pbe.createts and pbe.endts
 and pbe.benefitsubclass in ('10', '1Y') 
 and pbe.selectedoption = 'Y'
 and pbe.benefitelection in ('E','T') 

LEFT JOIN person_payroll pp
  ON pp.personid = pi.personid
 and current_date between pp.effectivedate and pp.enddate
 and current_timestamp between pp.createts and pp.endts
 
LEFT JOIN pay_unit pu 
  ON pu.payunitid = pp.payunitid 

where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  and pbe.effectivedate >= elu.lastupdatets
  
