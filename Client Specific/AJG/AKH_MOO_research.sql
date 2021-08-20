


select 
 plan.personid
,plan.punit_group 

,plan.medical
,case when plan.medical = 'true' and plan.punit_group = 'AKH00' then 'A001'
      when plan.medical is null  and plan.punit_group = 'AKH00' then 'A002'
      when plan.medical = 'true' and plan.punit_group = 'AKH05' then 'A003'
      when plan.medical is null  and plan.punit_group = 'AKH05' then 'A004'      
      when plan.medical = 'true' and plan.punit_group = 'AKH15' then 'A003'
      when plan.medical is null  and plan.punit_group = 'AKH15' then 'A004'         
      else ' ' end as classid
,plan.person_name      
from 

(
select distinct
 pi.personid as personid
,pi.identity::char(5) as group_key
,pn.name as person_name
,pbestd.benefitsubclass = '32' as std
,pbeltd.benefitsubclass = '31' as ltd
,pbeadd.benefitsubclass = '22'  as ad_d
,pbeblife.benefitsubclass = '20' as life
,pbebeevlife.benefitsubclass = '21' as eevolife
,pbebSPvlife.benefitsubclass = '2Z' as spvolife
,pbebDPvlife.benefitsubclass = '25' as dpvolife
,pbemed.benefitsubclass = '10' as medical
,pu.payunitdesc as punit_group

from person_identity pi

join person_bene_election pbe
   on pbe.personid = pi.personid
  and pbe.effectivedate is not null
  and pbe.benefitelection in ('E')
  and pbe.benefitsubclass in ('32','31','22','20','21','2Z','25','10')
  and pbe.selectedoption = 'Y' 
  and current_date between pbe.effectivedate and pbe.enddate
  and current_timestamp between pbe.createts and pbe.endts 
  and pbe.personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts 
                         and benefitsubclass in ('32','31','22','20','21','2Z','25','10') and benefitelection = 'E' and selectedoption = 'Y')      

left join (select distinct personid,benefitelection,benefitsubclass,
  case when benefitsubclass = '10' and benefitelection = 'E' then 'Y' else 'N' end as medical_enrolled_flag
  from person_bene_election
 where benefitsubclass in ('10')
   and current_date between effectivedate and enddate
   and current_timestamp between createts and endts
   and benefitelection = 'E'
   order by 1 ) as mef on mef.personid = pbe.personid 

left join person_bene_election pbestd
  on pbestd.personid = pbe.personid
 and pbestd.benefitsubclass in ('32')
 and pbestd.benefitelection in ('E','T')
 and pbestd.selectedoption = 'Y' 
 and current_date between pbestd.effectivedate and pbestd.enddate
 and current_timestamp between pbestd.createts and pbestd.endts  
 
left join person_bene_election pbeltd
  on pbeltd.personid = pbe.personid
 and pbeltd.benefitsubclass in ('31')
 and pbeltd.benefitelection in ('E','T')
 and pbeltd.selectedoption = 'Y' 
 and current_date between pbeltd.effectivedate and pbeltd.enddate
 and current_timestamp between pbeltd.createts and pbeltd.endts  
 
left join person_bene_election pbeadd
  on pbeadd.personid = pbe.personid
 and pbeadd.benefitsubclass in ('22')
 and pbeadd.benefitelection in ('E','T')
 and pbeadd.selectedoption = 'Y' 
 and current_date between pbeadd.effectivedate and pbeadd.enddate
 and current_timestamp between pbeadd.createts and pbeadd.endts   
 
left join person_bene_election pbeblife
  on pbeblife.personid = pbe.personid
 and pbeblife.benefitsubclass in ('20')
 and pbeblife.benefitelection in ('E','T')
 and pbeblife.selectedoption = 'Y' 
 and current_date between pbeblife.effectivedate and pbeblife.enddate
 and current_timestamp between pbeblife.createts and pbeblife.endts  
  
left join person_bene_election pbebeevlife
  on pbebeevlife.personid = pbe.personid
 and pbebeevlife.benefitsubclass in ('21')
 and pbebeevlife.benefitelection in ('E','T')
 and pbebeevlife.selectedoption = 'Y' 
 and current_date between pbebeevlife.effectivedate and pbebeevlife.enddate
 and current_timestamp between pbebeevlife.createts and pbebeevlife.endts 
 
left join person_bene_election pbebSPvlife
  on pbebSPvlife.personid = pbe.personid
 and pbebSPvlife.benefitsubclass in ('2Z')
 and pbebSPvlife.benefitelection in ('E','T')
 and pbebSPvlife.selectedoption = 'Y' 
 and current_date between pbebSPvlife.effectivedate and pbebSPvlife.enddate
 and current_timestamp between pbebSPvlife.createts and pbebSPvlife.endts  
 
left join person_bene_election pbebDPvlife
  on pbebDPvlife.personid = pbe.personid
 and pbebDPvlife.benefitsubclass in ('25')
 and pbebDPvlife.benefitelection in ('E','T')
 and pbebDPvlife.selectedoption = 'Y' 
 and current_date between pbebDPvlife.effectivedate and pbebDPvlife.enddate
 and current_timestamp between pbebDPvlife.createts and pbebDPvlife.endts      

left join person_bene_election pbemed
  on pbemed.personid = pbe.personid
 and pbemed.benefitsubclass in ('10')
 and pbemed.benefitelection in ('E','T')
 and pbemed.selectedoption = 'Y' 
 and current_date between pbemed.effectivedate and pbemed.enddate
 and current_timestamp between pbemed.createts and pbemed.endts  
  
left join person_names pn
  on pn.personid = pi.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts  

LEFT JOIN person_payroll ppay
  ON ppay.personid = pi.personid
 AND current_date BETWEEN ppay.effectivedate AND ppay.enddate
 AND current_timestamp BETWEEN ppay.createts AND ppay.endts      

LEFT JOIN pay_unit pu
  ON pu.payunitid = ppay.payunitid

                            
where pi.identitytype = 'PSPID'
  and current_date between pi.createts and pi.endts
) plan   



;
select distinct personid,benefitelection,benefitsubclass,
  case when benefitsubclass = '10' and benefitelection = 'E' then 'Y' else 'N' end as medical_enrolled_flag
  from person_bene_election
 where benefitsubclass in ('10')
   and current_date between effectivedate and enddate
   and current_timestamp between createts and endts
   and benefitelection = 'E'
   order by 1

select * from person_names where lname like 'Blaiss%';

select * from benefit_plan_desc
where current_timestamp between createts and endts
  and current_date between effectivedate and enddate
  and benefitsubclass in ('1HY')
  ;
select * from eligibility_rule_desc;  
select * from person_bene_election
where current_timestamp between createts and endts
  and current_date between effectivedate and enddate
  and benefitsubclass in ('25')
  and personid = '7408'
  ;
select * from dependent_enrollment
where current_timestamp between createts and endts
  and current_date between effectivedate and enddate
  and personid = '7408'
  ;  

select personid from person_bene_election 
where current_timestamp between createts and endts
  and current_date between effectivedate and enddate
  and benefitelection in ('E')
  and selectedoption = 'Y' 
  and benefitsubclass in ('2Z')
  and personid not in (select personid from dependent_enrollment where current_timestamp between createts and endts and current_date between effectivedate and enddate
  and benefitsubclass in ('2Z') 
  group by 1)
  ;
select * from person_bene_election
where current_timestamp between createts and endts
  and current_date between effectivedate and enddate
  --and benefitsubclass in ('25')
  and personid = '8494'
    and benefitelection in ('E')
  and selectedoption = 'Y' 
  ;  
select * from person_employment where personid in ('8764','8450');
select * from pers_pos where personid in ('8764','8450');
select * from person_compensation where personid in ('8764','8450');
select earningscode from person_compensation group by 1;
select * from positiondetails where positionid in('20901');
select * from position_desc where positionid in ('20901');