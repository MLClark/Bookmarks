select distinct
 pi.personid
,pp.schedulefrequency 
,case pp.schedulefrequency 
      when 'B' then 'BiWeekly'
      when 'W' then 'Weekly'
      end ::char(10) as frequency
                           



from person_identity pi

join pers_pos pp
  on pp.personid = pi.personid
 and current_date between pp.effectivedate and pp.enddate
 and current_timestamp between pp.createts and pp.endts
  
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts;
  
  select * from benefit_calc_type