select distinct
---- only required for medical plans
 pi.personid
,'[NPMHIPAADATA]' :: varchar(35) as recordtype
,case when bcd.benefitcoveragedesc in ('Employee Only') then 'EE'
      when bcd.benefitcoveragedesc in ('Employee + Spouse') then ('EE+SPOUSE')
      when bcd.benefitcoveragedesc in ('Employee + Children','EE & 1 Dep') then ('EE+CHILDREN')
      when bcd.benefitcoveragedesc in ('EE&Child(ren) + DP Adult&DP Ch') then ('EE+FAMILY')
      when bcd.benefitcoveragedesc in ('Family') then ('EE+FAMILY')
      else null end :: varchar(15) as coverage_level
,to_char(pbe.effectivedate,'MM/DD/YYYY')::CHAR(10) as original_enroll_date
,to_char(pbe.planyearenddate,'MM/DD/YYYY') ::char(10) last_day_cvg
,bpd.benefitplandesc ::varchar(50) as plan_name
,'2'::char(10) as sort_seq


from person_identity pi

JOIN person_employment pe 
  ON pe.personid = pi.personid 
 AND current_date between pe.effectivedate AND pe.enddate 
 AND current_timestamp between pe.createts AND pe.endts

join person_bene_election pbe
  on pbe.personid = pi.personid
 and current_date between pbe.effectivedate and pbe.enddate 
 and current_timestamp between pbe.createts and pbe.endts
 and pbe.benefitsubclass in ('10','11','14')
 and pbe.benefitelection in ('E')

JOIN benefit_plan_desc bpd  
  on bpd.benefitsubclass = pbe.benefitsubclass
 and bpd.benefitplanid = pbe.benefitplanid
 AND current_date between bpd.effectivedate and bpd.enddate
 AND current_timestamp between bpd.createts and bpd.endts  

left JOIN benefit_coverage_desc bcd 
  on bcd.benefitcoverageid = pbe.benefitcoverageid 
 and current_date between bcd.effectivedate and bcd.enddate
 and current_timestamp between bcd.createts and bcd.endts 
 
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  and pe.emplstatus = 'A'
  and pi.personid = '5170'
  order by 1;
  
  