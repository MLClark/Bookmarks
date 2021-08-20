select * from edi.lookup_schema where lookupid = 6;
select * from edi.lookup where lookupid = 6;
select * from pspay_group_earnings where etv_id like 'E%';
delete from edi.lookup_schema where lookupid = 6;
delete from edi.lookup where lookupid = 6;

INSERT INTO edi.lookup_schema (lookupid, keycoldesc1, valcoldesc1, lookupname, lookupdesc)
VALUES (6,'Client','ETVID','Novatime Import Lookup','key=lookupname');
INSERT INTO edi.lookup (lookupid,key1,value1,value2) VALUES (6,'SLE','E01','REG     ');

INSERT INTO edi.lookup (lookupid,key1,value1,value2) VALUES (6,'SLE','E02','OT      ');

INSERT INTO edi.lookup (lookupid,key1,value1,value2) VALUES (6,'SLE','E16','SICK    ');

INSERT INTO edi.lookup (lookupid,key1,value1,value2) VALUES (6,'SLE','E20','PERS    ');

INSERT INTO edi.lookup (lookupid,key1,value1,value2) VALUES (6,'SLE','E15','VAC     ');







;;;;VAC     ;







select min(psp.periodenddate) as EFFECTIVEDATE, 1 as lookup_constant, lkup.lookupid, lkup.key1 as lkup_client, lkup.value1 ::char(3) as lkup_etvid, rpad(lkup.value2,8,' ') ::char(8) as lkup_desc
  from pay_schedule_period psp
  join edi.lookup_schema lkups on lkups.lookupname = 'Novatime Import Lookup'
   and current_date between lkups.effectivedate and lkups.enddate and current_date between lkups.effectivedate and lkups.enddate
  join edi.lookup lkup on lkup.lookupid = lkups.lookupid and lkup.key1 = ?
where periodpaydate > ?::DATE and payrolltypeid = 1 
group by 2,3,4,5,6
order by 6








delete from edi.lookup_schema where lookupid = 7;
delete from edi.lookup where lookupid = 7;



INSERT INTO edi.lookup_schema (lookupid, keycoldesc1, keycoldesc2, valcoldesc1, lookupname, lookupdesc)
VALUES (7,'Client','ETVID','EARNING_NAME','Novatime Import Lookup','key=lookupname');

INSERT INTO edi.lookup (lookupid,key1,key2,value1,value2) 
select 7, 'SLE', upper(earning_name), etv_id, 'xxxxxxxx' from pspay_group_earnings where etv_id like 'E%' and group_key <> '$$$$$' and earning_name <> ''
and current_timestamp between createts and endts


( select lkup.lookupid,lkup.key1,lkup.value1,value2
         from edi.lookup lkup
         join edi.lookup_schema lkups
           on lkups.lookupid = lkup.lookupid
          and current_date between lkups.effectivedate and lkups.enddate
        where current_date between lkup.effectivedate and lkup.enddate
          and lkups.lookupname = 'Novatime Import Lookup' order by 4
      )

;
select min(psp.periodenddate) as EFFECTIVEDATE, 1 as lookup_constant, lkup.lookupid, lkup.key1 as lkup_client, lkup.value1 ::char(3) as lkup_etvid, rpad(lkup.value2,8,' ') ::char(4) as lkup_desc
  from pay_schedule_period psp
  join edi.lookup_schema lkups on lkups.lookupname = 'Novatime Import Lookup'
   and current_date between lkups.effectivedate and lkups.enddate and current_date between lkups.effectivedate and lkups.enddate
  join edi.lookup lkup on lkup.lookupid = lkups.lookupid and lkup.key1 = ?
where periodpaydate > ?::DATE and payrolltypeid = 1 
group by 2,3,4,5,6
order by 6