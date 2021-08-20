-- *********************************************************
-- Insert values for Fidelity Contribution Loan (Record 19)
-- *********************************************************

INSERT INTO edi.lookup_schema (lookupid, lookupname, lookupdesc)
select max(lookupid) + 1, 'FinFit_Demographic_File', 'FinFit Go Live Date - used for preventing terms sent on first file'
from edi.lookup_schema;


INSERT INTO edi.lookup (lookupid,key1, value1)
select lookupid, 'GoLiveDate', '09/22/2020'
from edi.lookup_schema where lookupname = 'FinFit_Demographic_File';

( select lkups.lookupname, lkups.lookupid,lkup.lookupid,lkup.key1,lkup.value1
         from edi.lookup lkup
         join edi.lookup_schema lkups
           on lkups.lookupid = lkup.lookupid
          and current_date between lkups.effectivedate and lkups.enddate
        where current_date between lkup.effectivedate and lkup.enddate
          and lkups.lookupname in ('FinFit_Demographic_File')
      )

;

update edi.lookup set value1 = '09/22/2020' where lookupid = 6