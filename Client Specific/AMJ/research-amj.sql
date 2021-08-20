
select * from position_desc where positionid in ('1315','1634');
select * from pos_org_rel where positionid = '1327';
select * from organization_code where organizationid in ('6') and current_date between effectivedate and enddate and current_timestamp between createts and endts and effectivedate < enddate;

select * from person_compensation where personid = '1007';
select * from pers_pos where personid = '1000';

select * from personemploymentupdt where personid = '2165';
select * from person_employment limit 100;
select empleventdetcode from person_employment group by 1;



left join position_comp_plan pcp on pcp.positionid = pp.positionid
	and current_date between pcp.effectivedate and pcp.enddate
	and current_timestamp between pcp.createts and pcp.endts
left join comp_plan_desc cpd on cpd.compplanid = pcp.compplanid
	and current_date between cpd.effectivedate and cpd.enddate
	and current_timestamp between cpd.createts and cpd.endts 
 
,cpd.compplandesc 
 
