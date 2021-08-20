select * from company_communications;
select * from company_communications_recipients;
select * from company_communications_recipients where  companycommunicationsid = '19'; --personid in ('1042') and

select * from person_names where lname like 'Hall-%';

--update company_communications_recipients set acknowledgerecpt = 'N' where personid = '948';
--update company_communications_recipients set timeviewed = '2199-12-30 23:00:00' where personid = '948';