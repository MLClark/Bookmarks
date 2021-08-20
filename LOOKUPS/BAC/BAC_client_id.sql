
INSERT INTO edi.lookup_schema (lookupid, keycoldesc1, valcoldesc1, lookupname, lookupdesc)
VALUES (1,'Client','Client ID','BAC_Benefitfocus_Demographic_Export','key=lookupname');

INSERT INTO edi.lookup (lookupid,key1,value1) VALUES (1,'BAC','25432391');

INSERT INTO edi.lookup_schema (lookupid, keycoldesc1, keycoldesc2, keycoldesc3, keycoldesc4, valcoldesc1, lookupname, lookupdesc)
                              VALUES (1,'PayGroup','paycode','pay_code_desc','active_ind','pay_type');

select * from edi.lookup_schema where keycoldesc1 = 'payunitxid';
select * from edi.lookup where lookupid = '6';
--delete from edi.lookup_schema where keycoldesc1 = 'payunitxid'
--delete from edi.lookup;




                              

INSERT INTO edi.lookup_schema (lookupid, keycoldesc1, valcoldesc1, valcoldesc2, valcoldesc3, lookupname, lookupdesc)
VALUES (10,'payunitxid','cust_cat_value2','cust_cat_value5', 'cust_cat_value5', 'BAC_Benefitfocus_Demographic_Export', 'key=keycoldesc1');


select * from edi.lookup;

INSERT INTO edi.lookup (lookupid,key1,value1,value2,value3) VALUES (10,'00','AUGUSTA AND EMPORIA SAL','NON UNION','Thermal Ceramics Inc.' );
INSERT INTO edi.lookup (lookupid,key1,value1,value2,value3) VALUES (10,'05','AUGUSTA UNION','UNION','Thermal Ceramics Inc.' );
INSERT INTO edi.lookup (lookupid,key1,value1,value2,value3) VALUES (10,'10','AUGUSTA AND EMPORIA SAL','NON UNION','Thermal Ceramics Inc.' );
INSERT INTO edi.lookup (lookupid,key1,value1,value2,value3) VALUES (10,'15','EMPORIA UNION','UNION','Thermal Ceramics Inc.' );
INSERT INTO edi.lookup (lookupid,key1,value1,value2,value3) VALUES (10,'20','GIRARD','NON UNION','Thermal Ceramics Inc.' );
INSERT INTO edi.lookup (lookupid,key1,value1,value2,value3) VALUES (10,'25','ELKHART','NON UNION','Thermal Ceramics Inc.' );
INSERT INTO edi.lookup (lookupid,key1,value1,value2,value3) VALUES (10,'28','MOLTEN MATERIALS','NON UNION','Morganite Crucible Inc.' );
INSERT INTO edi.lookup (lookupid,key1,value1,value2,value3) VALUES (10,'29','MORGANITE INDUSTRIES','NON UNION','Morganite Industries' );

update 

select * from edi.lookup  where lookupid = 10 and key1 = '29'

update edi.lookup set value1 = 'Morganite Industries Inc' where lookupid = 10 and key1 = '29';
update edi.lookup set value3 = 'Morganite Industries Inc.' where lookupid = 10 and key1 = '29';

select * from edi.lookup_schema where lookupid = 10;


join ( select lkup.lookupid,lkup.key1,lkup.value1,lkup.value2,lkup.value3
         from edi.lookup lkup
         join edi.lookup_schema lkups
           on lkups.lookupid = lkup.lookupid
          and current_date between lkups.effectivedate and lkups.enddate
        where current_date between lkup.effectivedate and lkup.enddate
          and lkups.lookupname = 'BAC_Benefitfocus_Demographic_Export'
      ) lu on 1 = 1

            

--8/7/19 Add BAC28 = Molten Materials
,case when pu.payunitxid = '00' then 'AUGUSTA AND EMPORIA SAL'
      when pu.payunitxid = '05' then 'AUGUSTA UNION'
      when pu.payunitxid = '10' then 'AUGUSTA AND EMPORIA SAL'
      when pu.payunitxid = '15' then 'EMPORIA UNION'
      when pu.payunitxid = '20' then 'GIRARD'
      when pu.payunitxid = '25' then 'ELKHART'
      when pu.payunitxid = '28' then 'MOLTEN MATERIALS'
      when pu.payunitxid = '29' then 'MORGANITE INDUSTRIES' ----- mlc 12/19 - adding pay group bac29
      END ::varchar(50) as cust_cat_value2 --BC55    

,case when pu.payunitxid in ('00','10','20','25','28','29') then 'NON UNION' ----- mlc 12/19 - adding pay group bac29
      when pu.payunitxid in ('05','15') then 'UNION' END ::varchar(50) as cust_cat_value6            

,case when pu.payunitxid = '28' then 'Morganite Crucible Inc.'
      when pu.payunitxid = '29' then 'Morganite Industries' ----- mlc 12/19 - adding pay group bac29   
      else 'Thermal Ceramics Inc.' end ::varchar(50) as cust_cat_value5                          