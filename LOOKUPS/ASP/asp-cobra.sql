
update edi.edi_last_update 
set lastupdatets = '2020-03-11 00:00:00'
where feedid = 'ASP_SHDR_COBRA_QB_Export'






insert into edi.lookup(lookupid,key1,value1,createts)
values
(1,307,'Dental - DHMO','2020-01-27 00:00:00'),
(1,334,'Dental - DHMO','2020-01-27 00:00:00'),
(1,308,'Dental - DPPO','2020-01-27 00:00:00'),
(1,333,'Dental - DPPO','2020-01-27 00:00:00'),
(1,204,'Flex - Optum','2020-01-27 00:00:00'),
(1,339,'Med - MediExcel Cross Border HMO (ValPlan10)','2020-01-27 00:00:00'),
(1,298,'Medical - PPO','2020-01-27 00:00:00'),
(1,329,'Medical - PPO','2020-01-27 00:00:00'),
(1,297,'Medical - PPO','2020-01-27 00:00:00'),
(1,330,'Medical - PPO','2020-01-27 00:00:00'),
(1,299,'Medical - PPO w/H.S.A.','2020-01-27 00:00:00'),
(1,332,'Medical - PPO w/H.S.A.','2020-01-27 00:00:00'),
(1,300,'Medical - PPO w/H.S.A.','2020-01-27 00:00:00'),
(1,337,'Medical - PPO w/H.S.A.','2020-01-27 00:00:00'),
(1,291,'Medical - Priority Select HMO','2020-01-27 00:00:00'),
(1,338,'Medical - Priority Select HMO','2020-01-27 00:00:00'),
(1,296,'Medical - Traditional (Full Network HMO)','2020-01-27 00:00:00'),
(1,327,'Medical - Traditional (Full Network HMO)','2020-01-27 00:00:00'),
(1,311,'Vision - The Standard','2020-01-27 00:00:00'),
(1,335,'Vision - The Standard','2020-01-27 00:00:00');


update edi.lookup_schema
set lookupdesc = '1=403b/401k & Catch-up, 2=Roth & Catch-up, 3=ER Contrib, 4=Excl. Earnings, 5=Loans, 6=ER Contrib'
where lookupid = 3;

 

insert into edi.lookup(lookupid,key1,value1)
values(3,'VB6',6);