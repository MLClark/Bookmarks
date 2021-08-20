--Add etvid lookup schema
insert into edi.lookup_schema (lookupid, lookupname, lookupdesc, keycoldesc1)
select nextval('edi.lookup_schema_id_seq'), 'TASC_FSA_Exports', 'TASC Client Specific Values','Lookup Data For TASC FSA';

INSERT INTO edi.lookup_schema (lookupid, keycoldesc1,valcoldesc1,lookupname,lookupdesc)
select nextval('edi.lookup_schema_id_seq'),'Benefit Type', 'Benefit Subclass', 'Unum_VolLifeADD_Export', 'Configurable Benefit Subclasses';



insert into edi.lookup (lookupid, key1, value1)  select lkups.lookupid, 'EEVLIFE', '21' from edi.lookup_schema lkups where lookupname = 'Unum_VolLifeADD_Export';
insert into edi.lookup (lookupid, key1, value1)  select lkups.lookupid, 'EEADD  ', '22' from edi.lookup_schema lkups where lookupname = 'Unum_VolLifeADD_Export';
insert into edi.lookup (lookupid, key1, value1)  select lkups.lookupid, 'DEPADD ', '24' from edi.lookup_schema lkups where lookupname = 'Unum_VolLifeADD_Export';
insert into edi.lookup (lookupid, key1, value1)  select lkups.lookupid, 'CHVLIFE', '25' from edi.lookup_schema lkups where lookupname = 'Unum_VolLifeADD_Export';
insert into edi.lookup (lookupid, key1, value1)  select lkups.lookupid, 'SPADD  ', '27' from edi.lookup_schema lkups where lookupname = 'Unum_VolLifeADD_Export';
insert into edi.lookup (lookupid, key1, value1)  select lkups.lookupid, 'SPVLIFE', '2Z' from edi.lookup_schema lkups where lookupname = 'Unum_VolLifeADD_Export';

select * from edi.lookup_schema where lookupname = 'Unum_VolLifeADD_Export';
select * from edi.lookup where lookupid in (select lookupid from edi.lookup_schema where lookupname = 'Unum_VolLifeADD_Export');


( select lkup.value1 as benefitsubclass, lkup.key1 as desc
         from edi.lookup lkup
         join edi.lookup_schema lkups
           on lkups.lookupid = lkup.lookupid
          and current_date between lkups.effectivedate and lkups.enddate
          and current_timestamp between lkups.createts and lkups.endts
          and lkups.lookupname = 'Unum_VolLifeADD_Export' 
   )
   
delete from edi.lookup where lookupid = '242';



select * from benefit_plan_desc where benefitsubclass in ('21','22','24','25','27','2Z');


select * from person_names where lname like 'Akhu%';
select * from pay_unit;
select * from pers_pos where personid = '40';
select * from positiondetails where positionid = '1242';
select * from positiondetails where companyofficer = 'Y';
(select * from positiondetails where companyofficer = 'Y');
select * from person_names where personid in (select personid from pers_pos where positionid in (select positionid from positiondetails where companyofficer = 'Y'));

select * from pos_org_rel;
select * from person_bene_election where current_date between effectivedate and enddate and current_timestamp between createts and endts
and benefitelection = 'E' and selectedoption = 'Y' and personid = '128'
and benefitsubclass in ('21','22','24','25','27','2Z');

insert into edi.edi_last_update (feedid,lastupdatets) values ('Unum_VolLifeADD_Export','2021-01-01 00:00:00');
insert into edi.edi_last_update (feedid,lastupdatets) values ('Unum_Export_Effective_Date','2021-06-15 00:00:00');

update edi.edi_last_update set lastupdatets = '2021-01-01 00:00:00' where feedid = 'Unum_VolLifeADD_Export'

select * from edi.edi_last_update;
select * from person_names where lname like 'Akers%';

(select personid,  count(*) from pers_pos where effectivedate < enddate and current_timestamp between createts and endts group by 1 having count(*) > 1);


select * from pers_pos where personid in ('34','60','146','147','132','214','22','112','49');

select * from benefit_plan_desc where current_date between effectivedate and enddate and current_timestamp between createts and endts





(select positionid from pers_pos where personid in ('34','60','146','147','132','214','22','112','49') and  effectivedate < enddate and current_timestamp between createts and endts group by 1 )