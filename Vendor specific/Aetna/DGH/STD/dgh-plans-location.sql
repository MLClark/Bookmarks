select * from person_employment;
select * from person_compensation;
select * from person_payroll;

select personid,emplclass from person_employment where current_date between effectivedate and enddate and current_timestamp between createts and endts and emplclass = 'F' group by 1;

left join pers_pos pp
  on pp.personid = pe.personid 
 and current_date between pp.effectivedate and pp.enddate
 and current_timestamp between pp.createts and pp.endts

left join position_desc pd 
  on pd.positionid = pp.positionid 
 and current_date between pd.effectivedate and pd.enddate
 and current_timestamp between pd.createts and pd.endts

left join salary_grade sg
  on sg.grade = pd.grade
 and current_date between sg.effectivedate and sg.enddate
 and current_timestamp between sg.createts and sg.endts 
 
 select * from pers_pos pp where personid = '18542' ;
 select * from position_desc where positionid in ('49807','50105') ;
 
(select personid, positionid, scheduledhours, schedulefrequency, max(effectivedate) as effectivedate, RANK() OVER (PARTITION BY personid ORDER BY max(effectivedate) DESC) AS RANK
             from pers_pos where effectivedate < enddate and current_timestamp between createts and endts and personid = '18542' 
            group by personid, positionid, scheduledhours, schedulefrequency)  ;

(select positionid, grade, positiontitle, flsacode, max(effectivedate) as effectivedate, RANK() OVER (PARTITION BY positionid ORDER BY max(effectivedate) DESC) AS RANK
             from position_desc where effectivedate < enddate and current_timestamp between createts and endts 
            group by positionid, grade, positiontitle, flsacode)   ;            
            