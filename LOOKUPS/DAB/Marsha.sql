INSERT INTO edi.lookup_schema (lookupid, keycoldesc1, valcoldesc1, lookupname, lookupdesc)
select nextval('edi.lookup_id_seq'),'Client','DAB','DAB_OneAmerica_401K_Export', 'OneAmerica Client Specific Values';

INSERT INTO edi.lookup (lookupid,key1,value1) select lkups.lookupid,'Contract_Number','G38024' from edi.lookup_schema  lkups where lkups.lookupname  in ('DAB_OneAmerica_401K_Export');
INSERT INTO edi.lookup (lookupid,key1,key2,value1) select lkups.lookupid,'DivNbr','00','SAR1'  from edi.lookup_schema  lkups where lkups.lookupname  in ('DAB_OneAmerica_401K_Export');
INSERT INTO edi.lookup (lookupid,key1,key2,value1) select lkups.lookupid,'DivNbr','05','SHC1'  from edi.lookup_schema  lkups where lkups.lookupname  in ('DAB_OneAmerica_401K_Export');
INSERT INTO edi.lookup (lookupid,key1,key2,value1) select lkups.lookupid,'DivNbr','20','SHC1'  from edi.lookup_schema  lkups where lkups.lookupname  in ('DAB_OneAmerica_401K_Export');
INSERT INTO edi.lookup (lookupid,key1,key2,value1) select lkups.lookupid,'DivNbr','25','SHC1'  from edi.lookup_schema  lkups where lkups.lookupname  in ('DAB_OneAmerica_401K_Export');
INSERT INTO edi.lookup (lookupid,key1,key2,value1) select lkups.lookupid,'DivNbr','10','SHT1'  from edi.lookup_schema  lkups where lkups.lookupname  in ('DAB_OneAmerica_401K_Export');
INSERT INTO edi.lookup (lookupid,key1,key2,value1) select lkups.lookupid,'DivNbr','15','SHC1'  from edi.lookup_schema  lkups where lkups.lookupname  in ('DAB_OneAmerica_401K_Export');


 ( select lkups.lookupname, lkups.lookupid,lkup.lookupid,lkup.key1,lkup.value1,lkup.key2
         from edi.lookup lkup
         join edi.lookup_schema lkups
           on lkups.lookupid = lkup.lookupid
          and current_date between lkups.effectivedate and lkups.enddate
        where current_date between lkup.effectivedate and lkup.enddate and lkups.lookupname  in ('DAB_OneAmerica_401K_Export')
      ) 
      ;

select * from edi.lookup_schema where lookupname  in ('DAB_OneAmerica_401K_Export');
select * from edi.lookup  where lookupid   in (select lookupid from edi.lookup_schema where lookupname = 'DAB_OneAmerica_401K_Export');
/*

"Based on Pay Unit:
SAR1 - for DAB00 Standlee AG
SHC1 - for DAB05, DAB15, DAB20 & DAB25 Standlee Hay & Trading
SHT1 - for DAB10 Standlee Hay Trucking
* Use table to make it easy to add Pay Units"

*/