
select * from edi.lookup_schema where lookupname = 'TASC_FSA_Exports';
select * from edi.lookup where lookupid in (select lookupid from edi.lookup_schema where lookupname = 'TASC_FSA_Exports');

insert into edi.lookup (lookupid,key1,key2,value1,value2) 
select lkups.lookupid,'OE START DATE','OE END DATE',null,null from edi.lookup_schema lkups where lkups.lookupname  in ('TASC_FSA_Exports');

select * from person_compensation limit 10;

select * from edi.lookup where lookupid in (select lookupid from edi.lookup_schema where lookupname = 'TASC_FSA_Exports');

select * from person_bene_election where benefitsubclass = '60' and effectivedate >'2021-01-01';
select * from person_names where personid = '431';

delete from edi.lookup where id = 38 and key1 = 'FSA OE START DATE'

select * from edi.edi_last_update;
update edi.lookup set value1 = null where key1 like 'OE%' and lookupid in (select lookupid from edi.lookup_schema where lookupname = 'TASC_FSA_Exports');

update edi.lookup set value1 = '2021-03-01' where key1 like 'OE%' and lookupid in (select lookupid from edi.lookup_schema where lookupname = 'TASC_FSA_Exports');
update edi.edi_last_update set lastupdatets = '2021-06-08 00:00:00' where feedid = 'TASC_FSA_Enrollment_File_Export';

select * from edi.lookup where lookupid in (select lookupid from edi.lookup_schema where lookupname = 'TASC_FSA_Exports');
   ( select lkup.value1 as benefitsubclass 
         from edi.lookup lkup
         join edi.lookup_schema lkups
           on lkups.lookupid = lkup.lookupid
          and current_date between lkups.effectivedate and lkups.enddate
          and current_timestamp between lkups.createts and lkups.endts
          and lkups.lookupname = 'TASC_FSA_Exports' 
   )
   ;
(select personid, benefitsubclass, benefitelection,  personbeneelectionpid, coverageamount, effectivedate, enddate, eventdate, deductionstartdate, planyearenddate
,monthlyamount
  from person_bene_election
  join edi.edi_last_update elu on elu.feedid = 'TASC_FSA_Enrollment_File_Export'
 where benefitsubclass in  
   ( select lkup.value1 as benefitsubclass 
         from edi.lookup lkup
         join edi.lookup_schema lkups
           on lkups.lookupid = lkup.lookupid
          and current_date between lkups.effectivedate and lkups.enddate
          and current_timestamp between lkups.createts and lkups.endts
          and lkups.lookupname = 'TASC_FSA_Exports' 
   )  
   and benefitelection in ('E','T') and selectedoption = 'Y' 
   and current_timestamp between createts and endts 
   and current_date between effectivedate and enddate
   and effectivedate >= elu.lastupdatets 
   and personid = '431'
   );