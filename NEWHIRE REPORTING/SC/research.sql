select * from pay_unit;

(select lp.lookupid, lp.key1 as lfein, value1 as CmpAddress, value2 as Cmpaddress2, value3 as CmpCity, value4 as CmpState, value5 as CmpZipCode, value7 as CmpName
from edi.lookup lp
join edi.lookup_schema els on lp.lookupid = els.lookupid and els.lookupname = 'SC Newhire Company Address' 
 );
 
 
 
 AXU06 - BiWeekly 81-1821818       
 
 86-3095682 SPRING HOUSE HOSPITALITY MANAGEMENT LLC  
 57-0278880 The Beach Company              
 
 	Marsha Clark
Please update the employer details for the new pay unit to:
Employer Identification Number: 81-1821818
Kiawah River Investment LLC
JOHN C DARBY MBR
211 King ST STE 300
CHARLESTON, SC 29401
 
You still have the old details for Spring House Hospitality...  They provided updated documentation which was posted to this ticket on 5/19/2021
     
 
 select * from edi.lookup_schema where lookupname = 'SC Newhire Company Address' ;
 
 SELECT * FROM  edi.edi_last_update;
 update edi.edi_last_update set lastupdatets = '2021-07-01 06:41:40' where feedid = 'NewHireReporting_SC'; --2021-07-01 06:41:40
 
delete from edi.lookup where lookupid in (select lookupid from edi.lookup_schema where lookupname = 'SC Newhire Company Address' ) and id = '258';
 select * from edi.lookup where lookupid in (select lookupid from edi.lookup_schema where lookupname = 'SC Newhire Company Address' );
 
  select * from edi.lookup where lookupid = 2;
  
 select * from person_address 
 insert into edi.lookup (lookupid,key1,value1,value2,value3,value4,value5,value6,value7) 
 select lkups.lookupid,'81-1821818','211 King ST','STE 300','CHARLESTON','SC','29401','US','Kiawah River Investment LLC' from edi.lookup_schema lkups where lookupname = 'SC Newhire Company Address';

