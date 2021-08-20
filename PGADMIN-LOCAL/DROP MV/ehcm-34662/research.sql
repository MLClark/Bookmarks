/*
Logic to determine the work state:

 If the position a person is tied to is a Remote position, then the worked in state is their home state.  Otherwise it is the state associated with the person_location record

This will need to be done 'as of' the payperiodenddate for the employee.
*/

select * from pers_pos where positionid in (select positionid from position_desc where current_date between effectivedate and enddate and current_timestamp between createts and endts and remoteemployee <> 'N') 
and current_date between effectivedate and enddate and current_timestamp between createts and endts;
select * from position_desc where remoteemployee <> 'N';
select * from person_locations;


select 
 pa.personid
,pa.stateprovincecode
from person_address pa
join pers_pos pp on pp.personid = pa.personid and current_date between pp.effectivedate and pp.enddate and current_timestamp between pp.createts and pp.endts

where pa.addresstype = 'Res'
  and current_date between pa.effectivedate and pa.enddate
  and current_timestamp between pa.createts and pa.endts
  and pp.positionid in (select positionid from position_desc where current_date between effectivedate and enddate and current_timestamp between createts and endts and remoteemployee <> 'N')
  ;