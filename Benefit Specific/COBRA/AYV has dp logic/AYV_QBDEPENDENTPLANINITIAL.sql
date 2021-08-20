SELECT distinct  
 pi.personid
,pbe.benefitsubclass
,pbe.benefitplanid
,pn.name
,pnd.name
,pdr.dependentid
,pdr.dependentrelationship
,'[QBDEPENDENTPLANINITIAL]' :: varchar(35) as recordtype
,replace(pi.identity,'-','') :: char(9) as emp_ssn
,case when pbe.benefitsubclass in ('11','16') and pbe.benefitplanid in ('53','287') then '"Dental - High Plan"'
      when pbe.benefitsubclass in ('11','16') and pbe.benefitplanid in ('56','290') then '"Dental - Low Plan"'
      when pbe.benefitsubclass in ('10','15') and pbe.benefitplanid in ('311','350') then '"Medical - BB-WW MOD (2V) HSA"'
      when pbe.benefitsubclass in ('10','15') and pbe.benefitplanid in ('314','347') then '"Medical - BB-1C MOD 529"'
      when pbe.benefitsubclass in ('10','15') and pbe.benefitplanid in ('26','38') then '"Medical - AR-1L (2017 Choice Plus Adv)Rx 5U Medium"'
      when pbe.benefitsubclass in ('10','15') and pbe.benefitplanid in ('23','41') then '"Medical - AR-1M (2017 Choice Plus Adv) Rx 5U Low"'
      when pbe.benefitsubclass in ('10','15') and pbe.benefitplanid in ('135','35') then '"Medical - AR-YS (2017 Balanced) Rx 5U High"'
      when pbe.benefitsubclass in ('14','17') then '"Vision - Guardian"'
      end  ::varchar(100) as plan_name  

,'4A'||pdr.dependentid||'B' ::char(10) as sort_seq

FROM person_identity pi

LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'AYV_SHDR_COBRA_QB_Export'

JOIN person_employment pe 
  ON pe.personid = pi.personid 
 AND current_date between pe.effectivedate AND pe.enddate 
 AND current_timestamp between pe.createts AND pe.endts

join person_names pn
  on pn.personid = pe.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts 

JOIN person_bene_election pbe 
  on pbe.personid = pi.personid 
 and pbe.selectedoption = 'Y' 
 and pbe.benefitcoverageid > '1'
 and pbe.benefitsubclass in ('10','11','14','15','16','17')  --- 15,16,17 for domestic partner benefits
 AND current_date between pbe.effectivedate AND pbe.enddate 
 AND current_timestamp between pbe.createts AND pbe.endts
  -- to be qualified for cobra the emp must have participated in employer's health care plan  
 and pbe.personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts and date_part('year',deductionstartdate)>=date_part('year',current_date)
                         and benefitsubclass in ('10','11','14','15','16','17') and benefitelection = 'E' and selectedoption = 'Y' and effectivedate < enddate) 

join person_dependent_relationship pdr
  on pdr.personid = pbe.personid
 and current_date between pdr.effectivedate and pdr.enddate
 and current_timestamp between pdr.createts and pdr.endts

join person_names pnd
  on pnd.personid = pdr.dependentid
 and pnd.nametype = 'Dep'
 and current_date between pnd.effectivedate and pnd.enddate
 and current_timestamp between pnd.createts and pnd.endts 

JOIN dependent_enrollment de
  on de.personid = pdr.personid
 and de.dependentid = pdr.dependentid
 AND de.selectedoption = 'Y'
 and de.benefitplanid = pbe.benefitplanid
 and de.benefitsubclass = pbe.benefitsubclass
 and current_date >= de.effectivedate 
 and current_timestamp between de.createts and de.endts

LEFT JOIN person_identity pid
  ON pid.personid = pdr.dependentid
 AND pid.identitytype = 'SSN'::bpchar 
 and current_timestamp between pid.createts and pid.endts

JOIN benefit_plan_desc bpd  
  on bpd.benefitsubclass = pbe.benefitsubclass
 and bpd.benefitplanid = pbe.benefitplanid
 AND current_date between bpd.effectivedate and bpd.enddate
 AND current_timestamp between bpd.createts and bpd.endts 

WHERE pi.identitytype = 'SSN' 
  and current_timestamp between pi.createts and pi.endts
  and (pe.effectivedate >= elu.lastupdatets::DATE 
   or (pe.createts > elu.lastupdatets and pe.effectivedate < coalesce(elu.lastupdatets, '2017-01-01')) ) 
  and pe.emplstatus in ('R','T')

order by pi.personid