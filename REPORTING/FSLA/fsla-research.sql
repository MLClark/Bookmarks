select * from person_names where lname like 'Beal%';--66216


select  * from position_desc where positionid in (select positionid from pers_pos where personid = '66216');
select * from pers_pos where personid = '66216';

(select personid, positionid, effectivedate, enddate, createts, endts, updatets, RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) desc) AS RANK
            from pers_pos 
           where current_timestamp between createts and endts and effectivedate <  enddate    
             and personid = '66216'             
           group by personid, positionid, effectivedate, enddate, createts, endts, updatets )
           ;


select * from cur_person_tax_elections;           