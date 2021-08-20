 select * from edi.lookup_schema where lookupname like 'NY%';
 select * from edi.lookup where lookupid in (select lookupid from edi.lookup_schema where lookupname like 'NY%');
 select * from edi.edi_last_update;
 
 Marsha Clark  Please write the update statements to remove the lookup rows associated with FEIN '45-3670186 '.
 
select * from  edi.lookup where id in (select id from edi.lookup where (value1 = '45-3670186' or key1 = '45-3670186'));
delete from  edi.lookup where id in (select id from edi.lookup where (value1 = '45-3670186' or key1 = '45-3670186'));
 
insert into edi.lookup (lookupid,value1) select lkups.lookupid,'45-3670186' from edi.lookup_schema lkups where lookupname = 'NY FEIN';
insert into edi.lookup (lookupid,key1,value1,value2,value3,value4,value5,value6) select lkups.lookupid,'45-3670186'
,'1095 Avenue of the Americas','New York','NY','10036','US','CCB International Overseas USA Inc' from edi.lookup_schema lkups where lookupname = 'NY FEIN Address';

insert into edi.lookup (lookupid,value1) select lkups.lookupid,'32-0273004' from edi.lookup_schema lkups where lookupname = 'NY FEIN';
insert into edi.lookup (lookupid,key1,value1,value2,value3,value4,value5,value6) select lkups.lookupid,'32-0273004'
,'1095 Avenue of the Americas','New York','NY','10036','US','China Construction Bank' from edi.lookup_schema lkups where lookupname = 'NY FEIN Address';


 select * from edi.lookup_schema where lookupname like 'NY%';
 select * from edi.lookup where lookupid in (select lookupid from edi.lookup_schema where lookupname like 'NY%');
 select * from edi.edi_last_update where feedid = 'NewHireReporting_NY';
 select * from pay_unit;
 select * from person_employment where emplstatus = 'A' and date_part('year',effectivedate) = '2020';