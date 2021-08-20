select * from edi.lookup_schema where lookupname = 'YourCause_EmployeeDemographic';
select * from edi.lookup where lookupid in (select lookupid from edi.lookup_schema where lookupname = 'YourCause_EmployeeDemographic');

insert into edi.lookup_schema (lookupid, keycoldesc1, valcoldesc1, lookupname, lookupdesc)
select nextval('edi.lookup_id_seq'),'Client','HMN','YourCause_EmployeeDemographic', 'YourCause Client Specific Values';


insert into edi.lookup (lookupid,key1,value1) select lkups.lookupid,'TempPassword','hmn@2020$$' from edi.lookup_schema lkups where lkups.lookupname  in ('YourCause_EmployeeDemographic');

 ( select lkups.lookupname, lkups.lookupid,lkup.lookupid,lkup.key1,lkup.value1
         from edi.lookup lkup
         join edi.lookup_schema lkups
           on lkups.lookupid = lkup.lookupid
          and current_date between lkups.effectivedate and lkups.enddate
        where current_date between lkup.effectivedate and lkup.enddate and lkups.lookupname  in ('YourCause_EmployeeDemographic')
      ) 
      ;