
--delete  from edi.lookup where lookupid in (select lookupid from edi.lookup_schema where lookupname in ('Empower 401k Plan Number Lookup'))
--delete from edi.lookup_schema where lookupname in  ('Empower 401k Plan Number Lookup') ;
 

select * from edi.lookup_schema where lookupname in  ('Empower 401k Plan Number Lookup') ;
select * from edi.lookup where lookupid in (select lookupid from edi.lookup_schema where lookupname in ('Empower 401k Plan Number Lookup'));
--- For UEU

INSERT INTO edi.lookup_schema (lookupid, keycoldesc1, valcoldesc1, lookupname, lookupdesc)
select nextval('edi.lookup_id_seq'),'Client','UEU','Empower 401k Plan Number Lookup', 'Empower Client Specific Values';

INSERT INTO edi.lookup (lookupid,key1,value1) select lkups.lookupid,'PlanNumber','######-##' from edi.lookup_schema  lkups where lkups.lookupname  in ('Empower 401k Plan Number Lookup');
INSERT INTO edi.lookup (lookupid,key1,key2,value1) select lkups.lookupid,'DivNbr','00','?0'  from edi.lookup_schema  lkups where lkups.lookupname  in ('Empower 401k Plan Number Lookup');
INSERT INTO edi.lookup (lookupid,key1,key2,value1) select lkups.lookupid,'DivNbr','05','?5'  from edi.lookup_schema  lkups where lkups.lookupname  in ('Empower 401k Plan Number Lookup');


--For EAS
--select * from pay_unit;


INSERT INTO edi.lookup_schema (lookupid, keycoldesc1, valcoldesc1, lookupname, lookupdesc)
select nextval('edi.lookup_id_seq'),'Client','EAS','Empower 401k Plan Number Lookup', 'Empower Client Specific Values';

INSERT INTO edi.lookup (lookupid,key1,value1) select lkups.lookupid,'PlanNumber','######-##' from edi.lookup_schema  lkups where lkups.lookupname  in ('Empower 401k Plan Number Lookup');
INSERT INTO edi.lookup (lookupid,key1,key2,value1) select lkups.lookupid,'DivNbr','00','?0'  from edi.lookup_schema  lkups where lkups.lookupname  in ('Empower 401k Plan Number Lookup');
INSERT INTO edi.lookup (lookupid,key1,key2,value1) select lkups.lookupid,'DivNbr','01','?1'  from edi.lookup_schema  lkups where lkups.lookupname  in ('Empower 401k Plan Number Lookup');
INSERT INTO edi.lookup (lookupid,key1,key2,value1) select lkups.lookupid,'DivNbr','02','?2'  from edi.lookup_schema  lkups where lkups.lookupname  in ('Empower 401k Plan Number Lookup');
INSERT INTO edi.lookup (lookupid,key1,key2,value1) select lkups.lookupid,'DivNbr','03','?3'  from edi.lookup_schema  lkups where lkups.lookupname  in ('Empower 401k Plan Number Lookup');
INSERT INTO edi.lookup (lookupid,key1,key2,value1) select lkups.lookupid,'DivNbr','04','?4'  from edi.lookup_schema  lkups where lkups.lookupname  in ('Empower 401k Plan Number Lookup');
INSERT INTO edi.lookup (lookupid,key1,key2,value1) select lkups.lookupid,'DivNbr','10','?A'  from edi.lookup_schema  lkups where lkups.lookupname  in ('Empower 401k Plan Number Lookup');


 ( select lkups.lookupname, lkups.lookupid,lkup.lookupid,lkup.key1,lkup.value1
         from edi.lookup lkup
         join edi.lookup_schema lkups
           on lkups.lookupid = lkup.lookupid
          and current_date between lkups.effectivedate and lkups.enddate
        where current_date between lkup.effectivedate and lkup.enddate and lkups.lookupname  in ('Empower 401k Plan Number Lookup')
      ) 
      ;
/*

Plan number is derived from edi.lookup and edi.lookup_schema tables.
For AMJ:
INSERT INTO edi.lookup_schema (lookupid, keycoldesc1, valcoldesc1, lookupname, lookupdesc)
VALUES (6,'Client','Plan Number','Empower 401k Plan Number Lookup','key=lookupname');

INSERT INTO edi.lookup (lookupid,key1,value1) VALUES (6,'AMJ','502939-01');

For AVS
INSERT INTO edi.lookup_schema (lookupid, keycoldesc1, valcoldesc1, lookupname, lookupdesc)
VALUES (6,'Client','Plan Number','Empower 401k Plan Number Lookup','key=lookupname');

INSERT INTO edi.lookup (lookupid,key1,value1) VALUES (6,'AVS','462062-01');

For PS1
[?3/?1/?2018 1:29 PM]  Debbie Flynn:  
PS Plan number  - 502989-1      
 */