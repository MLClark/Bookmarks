INSERT INTO edi.lookup_schema (lookupid, lookupname, lookupdesc)
select nextval('edi.lookup_id_seq'), 'Empower_401k_Export', 'Empower Client Specific Values'
;

INSERT INTO edi.lookup (lookupid,key1, value1,value2)
select lookupid, 'PlanNumber', '333478-01','Vendor to provide'
from edi.lookup_schema where lookupname = 'Empower_401k_Export';


( select lkups.lookupname, lkups.lookupid,lkup.lookupid,lkup.key1,lkup.value1
         from edi.lookup lkup
         join edi.lookup_schema lkups
           on lkups.lookupid = lkup.lookupid
          and current_date between lkups.effectivedate and lkups.enddate
        where current_date between lkup.effectivedate and lkup.enddate
          and lkups.lookupname in ('Empower_401k_Export')
      )

;

