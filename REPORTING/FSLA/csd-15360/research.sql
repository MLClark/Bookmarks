select * from person_names where lname like 'Beam%';
select * from pers_pos where personid = '63570';
select * from position_desc where positionid in (select positionid from pers_pos where personid = '63570');