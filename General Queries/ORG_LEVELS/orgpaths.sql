----- path to get to job desc
select * from pers_pos where personid = '6338';
select * from position_job where positionid = '3385';
select * from job_desc where jobid in ('558','1027');

select * from pos_org_rel where positionid = '3429'
  and current_date between effectivedate and enddate
  and current_timestamp between createts and endts
  and enddate > current_date;
select * from pos_org_rel 
where organizationid in ('821') and positionid = '3429'
and current_date between effectivedate and enddate
and current_timestamp between createts and endts;

-----

select * from position_desc where positionid = '3263';

select * from rpt_orgstructure where org2id = '713' ;
select * from org_rel where memberoforgid = '713';

select * from organization_code;
select * from organization_code where organizationid in ('713');
select * from organization_code where organizationtype = 'Div' and organizationid in ('713');
select * from organization_code where organizationpid = '1';


select * from organization_code where organizationtype = 'Dept' and organizationid = '719';
select * from organization_code where organizationid in ('714');


select * from position_desc where positionid = '3221';
select * from rpt_orgstructure where org1id = '713';

select * from tjorgcode where memberoforgid = '828';
select * from positiondetails where positionid = '3223';
select * from positionorgreldetail where positionid = '3223';
select * from positionorgrelupdt where positionid = '3223';
select * from positionorgrelhist where positionid = '3223';
select * from rpt_orgstructure where org2id = '788' ;

select * from dxpersonposition where personid = '6244';
select * from dxpersposorg  where  positionid = '3263' and asofddate = current_date;
select * from dxpersposoccupies where personid = '6244';
select * from dxpersposchartinner where personid = '6244' and asofdate = current_date;
select * from dxpersposchart where personid = '6244' and asofdate = current_date;

select * from organization_code where organizationtype = 'Dept' and organizationid = '719';
select * from dxpersonposition where personid = '6244';
select * from rpt_orgstructure where org2id = '821' ;
select * from rpt_orgstructure where org1type = 'Dept' and org1id = '826';
select * from rpt_orgstructure where org3type = 'Div' and org2id = '828';


select * from tjpositionlist where positionid = '3263';
select * from person_names where personid = '6264';


select * from org_rel where memberoforgid = '821';
select * from pers_pos where personid = '6178';
select * from position_desc where positionid = '3429';
select * from position_job where positionid = '3429';
select * from pos_org_rel where positionid = '3429';
select * from job_desc where jobid = '560';