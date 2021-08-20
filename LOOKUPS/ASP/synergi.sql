INSERT INTO edi.lookup_schema (lookupid, keycoldesc1, valcoldesc1, lookupname, lookupdesc)
select coalesce(max(lookupid) + 1, 1),'Client','Client ID','ASP_Synergi_WOTC_Export','key=lookupname'
from edi.lookup_schema;

select * from edi.lookup_schema where lookupname = 'ASP_Synergi_WOTC_Export';

INSERT INTO edi.lookup (lookupid,key1,value1) select coalesce(max(lookupid), 1), 'ASP','1004868' from edi.lookup_schema;
      
select * from edi.lookup where lookupid in (select lookupid from edi.lookup_schema where lookupname = 'ASP_Synergi_WOTC_Export') and value1 = '1004868';


 ( select lkup.lookupid,lkup.key1,lkup.value1,lkup.value2,lkup.value3
         from edi.lookup lkup
         join edi.lookup_schema lkups
           on lkups.lookupid = lkup.lookupid
          and current_date between lkups.effectivedate and lkups.enddate
        where current_date between lkup.effectivedate and lkup.enddate
          and lkups.lookupname = 'ASP_Synergi_WOTC_Export'
      ) 
      
      
      ;
      
      
      delete from edi.lookup where lookupid in (select lookupid from edi.lookup_schema where lookupname = 'ASP_Synergi_WOTC_Export') and value1 = '1004868';

      delete from edi.lookup_schema where lookupname = 'ASP_Synergi_WOTC_Export';