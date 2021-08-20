delete from edi.lookup where lookupid in (select lookupid from edi.lookup_schema where lookupname = 'MD FEIN Address');
delete from edi.lookup_schema where lookupname = 'MD FEIN Address';
select * from edi.lookup_schema where lookupname = 'MD FEIN Address';
select * from edi.lookup where lookupid in (select lookupid from edi.lookup_schema where lookupname = 'MD FEIN Address' );

        

select * from edi.edi_last_update;
update edi.edi_last_update set lastupdatets = '2021-01-01 00:00:00' where feedid = 'NewHireReporting_MD';




select * from pay_unit;

select * from edi.lookup_schema where lookupname = 'MD FEIN Address';
select * from edi.lookup where lookupid in (select lookupid from edi.lookup_schema where lookupname = 'MD FEIN Address' );


select key1, replace(key1,'-',''):: char(9) as lufein
from edi.lookup l
join edi.lookup_schema ls on l.lookupid = ls.lookupid and ls.lookupname = 'MD FEIN Address' 
