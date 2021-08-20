 select 
 enrolled.personid
,enrolled.enrolled_counts
,enrolled.dep_count
,enrolled.sp_count
,case when enrolled.sp_count > 0 and enrolled.dep_count is null then 'E+S'
      when enrolled.sp_count > 0 and enrolled.dep_count > 0 then 'F'
      when enrolled.sp_count is null and enrolled.dep_count > 0 then 'E+C' 
      when enrolled.enrolled_counts is null then 'EE' end as family_tier_indicator
 
 from ( select 
  pbe.personid 
 ,dpcnt.dep_count
 ,spcnt.sp_count
 ,sum(dpcnt.dep_count+spcnt.sp_count) as enrolled_counts
 from person_bene_election pbe
 
 left join (select  spcnt.personid,count(spcnt.dependentrelationship) as sp_count
         from (select distinct  pi.personid,pdr.dependentrelationship 
                 from person_identity pi
                 join person_bene_election pbe
                   on pbe.personid = pi.personid
                  and pbe.benefitsubclass = '26'
                  --and pbe.benefitplanid = '338'
                  and current_date between pbe.effectivedate and pbe.enddate
                  and current_timestamp between pbe.createts and pbe.endts
                
                 join person_dependent_relationship pdr
                   on pdr.personid = pbe.personid 
                  and current_date between pdr.effectivedate and pdr.enddate
                  and current_timestamp between pdr.createts and pdr.endts
                 
                 where pi.identitytype = 'SSN'
                   and current_timestamp between pi.createts and pi.endts
                   and pdr.dependentrelationship in ('SP','DP','NA')) spcnt
                  
                 group by 1  ) spcnt on spcnt.personid = pbe.personid

 
left join (select  dpcnt.personid,count(dpcnt.dependentrelationship) as dep_count
         from (select distinct  pi.personid,pdr.dependentrelationship 
                 from person_identity pi
                 join person_bene_election pbe
                   on pbe.personid = pi.personid
                  and pbe.benefitsubclass = '26'
                  --and pbe.benefitplanid = '338'
                  and current_date between pbe.effectivedate and pbe.enddate
                  and current_timestamp between pbe.createts and pbe.endts
                
                 join person_dependent_relationship pdr
                   on pdr.personid = pbe.personid 
                  and current_date between pdr.effectivedate and pdr.enddate
                  and current_timestamp between pdr.createts and pdr.endts
                 
                 where pi.identitytype = 'SSN'
                   and current_timestamp between pi.createts and pi.endts
                   and pdr.dependentrelationship in ('S','D','C','NS','ND','NC')) dpcnt
                  
                 group by 1  ) dpcnt on dpcnt.personid = pbe.personid
  
  
where pbe.benefitsubclass in ('26') 
  --and pbe.benefitplanid in ('338')
  and pbe.selectedoption = 'Y'
  and pbe.benefitelection = 'E'
  and current_date between pbe.effectivedate and pbe.enddate
  and current_timestamp between pbe.createts and pbe.endts  
  
  
  group by 1,2,3 ) enrolled
  
  