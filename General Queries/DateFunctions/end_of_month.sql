
select 

personid
,effectivedate
,empllasthiredate
,age(effectivedate,empllasthiredate)

,extract(month from age(effectivedate,empllasthiredate))
,extract(day from age(effectivedate,empllasthiredate))
from person_employment

limit 10

;

----- used in abd brms ongoing benefit changes
----- This is used to determine the end of month
select distinct
----#3 
 pi.personid
,pbe_eff_cov.enddate
,CASE when pbe_eff_cov.enddate != '2199-12-31' then to_char(DATE_TRUNC('month', pbe_eff_cov.enddate) + interval '1 month' - interval '1 day','yyyymmdd') else null end ::char(8) end_of_current_month

,CASE when pbe_eff_cov.enddate != '2199-12-31' then to_char(DATE_TRUNC('month', pbe_eff_cov.enddate) + interval '1 month' ,'yyyymmdd') else null end ::char(8) day1_next_month


from person_identity pi

JOIN edi.edi_last_update elu
  ON elu.feedid = 'ABD_BRMS_Ongoing_Beneft_Changes'

LEFT JOIN person_bene_election pbe  
  ON pbe.personid = pI.personid
 AND pbe.benefitsubclass = '10'
 AND pbe.benefitelection IN ('E')
 AND CURRENT_DATE BETWEEN pbe.effectivedate AND pbe.enddate 
 AND CURRENT_TIMESTAMP BETWEEN pbe.createts AND pbe.endts
 and pbe.effectivedate >= elu.lastupdatets 
 
---- pbe_eff_cov gets effective date of coverage prior to termination

LEFT JOIN person_bene_election pbe_eff_cov  
  ON pbe_eff_cov.personid = pI.personid
 AND pbe_eff_cov.benefitsubclass = '10'
 AND pbe_eff_cov.benefitelection IN ('E')
 AND DATE_PART('YEAR',pbe_eff_cov.enddate) = DATE_PART('YEAR',current_date)
 
 and pbe_eff_cov.enddate < '2199-12-30'
 and pbe_eff_cov.effectivedate < pbe_eff_cov.enddate
 and pbe_eff_cov.enddate <= current_date

 

JOIN benefit_plan_desc bpd 
  ON bpd.benefitsubclass = pbe_eff_cov.benefitsubclass 
 AND bpd.enddate = '2199-12-31' 
 AND bpd.benefitplanid = pbe_eff_cov.benefitplanid

JOIN person_employment pe
  ON pe.personid = pi.personid
 AND CURRENT_DATE BETWEEN pe.effectivedate AND pe.enddate
 AND CURRENT_TIMESTAMP BETWEEN pe.createts AND pe.endts
    
LEFT JOIN person_names pne 
  ON pne.personid = pi.personid
 AND CURRENT_DATE BETWEEN pne.effectivedate AND pne.enddate
 AND CURRENT_TIMESTAMP BETWEEN pne.createts AND pne.endts      

JOIN person_vitals pve 
  ON pve.personid = pi.personid 
 AND CURRENT_DATE BETWEEN pve.effectivedate AND pve.enddate
 AND CURRENT_TIMESTAMP BETWEEN pve.createts AND pve.endts    



 
where pi.identitytype = 'SSN'
  AND current_timestamp between pi.createts and pi.endts
  AND pbe_eff_cov.effectivedate >= elu.lastupdatets
  and pbe.benefitsubclass is not null
  AND pbe.benefitplanid = pbe_eff_cov.benefitplanid 