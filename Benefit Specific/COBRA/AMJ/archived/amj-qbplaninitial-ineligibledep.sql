
SELECT  distinct
 pi.personid
,'ACTIVE EE TERMED DEP' ::varchar(30) as qsource 
,'2' ::char(1) as qsource
,'[QBPLANINITIAL]' :: varchar(35) as recordtype
--select * from benefit_plan_desc where current_timestamp between createts and endts and benefitsubclass = '14' and current_date between effectivedate and enddate
,case when bpd.benefitplancode in ('MEDFSA','DCFSA','HFSA') then 'EBC FSA'
      when bpd.benefitplancode in ('DenBase','DBDP') then 'CIGNA DENTAL BASE'
      when bpd.benefitplancode in ('DenBuyup','DBUDP') then 'CIGNA DENTAL BUY UP'
      when bpd.benefitplancode in ('MBHSA') THEN 'CIGNA MEDICAL BRONZE HSA'
      when bpd.benefitplancode in ('MGOLD') THEN 'CIGNA MEDICAL GOLD HSA'
      when bpd.benefitplancode in ('MSHSA') then 'CIGNA MEDICAL SILVER HSA'  
      when bpd.benefitplancode in ('VisBuyup','VBUYUP','VBUDP') then 'VSP VISION BUY UP'
      when bpd.benefitplancode in ('VisBase','VBDP') then 'VSP VISION BASE'
      else bpd.benefitplancode end :: varchar(50) as plan_name    

,case when bcd.benefitcoveragedesc in ('Employee Only') then 'EE'
      when bcd.benefitcoveragedesc in ('Employee + Spouse') then ('EE+SPOUSE')
      when bcd.benefitcoveragedesc in ('Employee + Children','EE & 1 Dep') then ('EE+CHILDREN')
      when bcd.benefitcoveragedesc in ('EE&Child(ren) + DP Adult&DP Ch') then ('EE+FAMILY')
	  when bcd.benefitcoveragedesc in ('Family') then ('EE+FAMILY')
      else null end :: varchar(15) as coverage_level

,'' ::char(1) as numberofunits
,'3'||pi.personid ::char(10) as sort_seq



FROM person_identity pi

LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'AMJ_COBRA_EBC_QB'

JOIN person_employment pe 
  ON pe.personid = pi.personid 
 AND current_date between pe.effectivedate AND pe.enddate 
 AND current_timestamp between pe.createts AND pe.endts

JOIN person_bene_election pbe 
  on pbe.personid = pi.personid 
 and pbe.selectedoption = 'Y' 
 and pbe.benefitelection <> 'W'
 and pbe.benefitsubclass in ('10','11','14','15','16','17','60','61')
 AND current_date between pbe.effectivedate AND pbe.enddate 
 AND current_timestamp between pbe.createts AND pbe.endts
 and pbe.effectivedate < pbe.enddate 
  and pbe.personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts 
                         and benefitsubclass in ('10','11','14','15','16','17','60','61') and benefitelection = 'E' and selectedoption = 'Y' and effectivedate < enddate) 
 ----------------------------------------------------------------------
 ---- Don't look for pe.effectivedate - 1 day when dealing with ID ----
 ----------------------------------------------------------------------

JOIN benefit_plan_desc bpd  
  on bpd.benefitsubclass = pbe.benefitsubclass
 and bpd.benefitplanid = pbe.benefitplanid
 AND current_date between bpd.effectivedate and bpd.enddate
 AND current_timestamp between bpd.createts and bpd.endts 
 and bpd.effectivedate < bpd.enddate

left JOIN benefit_coverage_desc bcd 
  on bcd.benefitcoverageid = pbe.benefitcoverageid 
 and current_date between bcd.effectivedate and bcd.enddate
 and current_timestamp between bcd.createts and bcd.endts 
 and bcd.effectivedate < bcd.enddate

join person_dependent_relationship pdr
  on pdr.personid = pbe.personid
 and current_date between pdr.effectivedate and pdr.enddate
 and current_timestamp between pdr.createts and pdr.endts
 and pdr.effectivedate < pdr.enddate

join dependent_enrollment de
  on de.dependentid = pdr.dependentid
 and de.benefitsubclass = pbe.benefitsubclass
 and de.personid = pi.personid
 and current_timestamp between de.createts and de.endts
 and de.dependentid in 
 ( select distinct de.dependentid as dependentid
    from dependent_enrollment de 
    join person_names pne
      on pne.personid = de.personid
     and pne.nametype = 'Legal'
     and current_date between pne.effectivedate and pne.enddate
     and current_timestamp between pne.createts and pne.endts
     and de.effectivedate < de.enddate
    join person_names pnd
      on pnd.personid = de.dependentid
     and pnd.nametype = 'Dep'
     and current_date between pnd.effectivedate and pnd.enddate
     and current_timestamp between pnd.createts and pnd.endts   
     and pnd.effectivedate < pnd.enddate 
    join person_vitals pvd
      on pvd.personid = de.dependentid
     and current_date between pvd.effectivedate and pvd.enddate
     and current_timestamp between pvd.createts and pvd.endts 
     and pvd.effectivedate < pvd.enddate
    join person_dependent_relationship pdr
      on pdr.personid = de.personid
     and pdr.dependentid = de.dependentid
     and current_date between pdr.effectivedate and pdr.enddate
     and current_timestamp between pdr.createts and pdr.endts
     and pdr.effectivedate < pdr.enddate
    join person_employment pe
      on pe.personid = de.personid
     and current_date between pe.effectivedate and pe.enddate
     and current_timestamp between pe.createts and pe.endts
     and pe.effectivedate < pe.enddate
    join person_bene_election pbe
      on pbe.personid = de.personid
     and pbe.benefitsubclass in ('10','11','14','15','16','17','60','61')
     and pbe.selectedoption = 'Y'
     and current_date between pbe.effectivedate and pbe.enddate
     and current_timestamp between pbe.createts and pbe.endts
     and pbe.effectivedate < pbe.enddate     
   where current_timestamp between de.createts and de.endts
    and de.benefitsubclass in ('10','11','14','15','16','17','60','61')
    and pe.emplstatus = 'A'
    and pbe.benefitelection <> 'W'
    and date_part('year',de.enddate)=date_part('year',current_date)    
    and de.dependentid not in 
   (select distinct de.dependentid from dependent_enrollment de
      join person_dependent_relationship pdr
        on pdr.personid = de.personid
       and pdr.dependentid = de.dependentid
       and current_date between pdr.effectivedate and pdr.enddate
       and current_timestamp between pdr.createts and pdr.endts
       and pdr.effectivedate < pdr.enddate
     where current_date between de.effectivedate and de.enddate
       and current_timestamp between de.createts and de.endts
       and de.benefitsubclass in ('10','11','14','15','16','17','60','61')
   )
)  
 
left join person_maritalstatus pm
  on pm.personid = pi.personid
 and current_date between pm.effectivedate and pm.enddate
 and current_timestamp between pm.createts and pm.endts 
 and pm.effectivedate < pm.enddate

WHERE pi.identitytype = 'SSN' 
  and current_timestamp between pi.createts and pi.endts
  and pe.emplstatus = 'A' and pm.maritalstatus = 'D' and pm.effectivedate >= elu.lastupdatets::DATE 
