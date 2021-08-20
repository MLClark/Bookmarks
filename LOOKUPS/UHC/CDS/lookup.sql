
INSERT INTO edi.lookup_schema (lookupid, lookupname, lookupdesc)
select max(lookupid) + 1, 'CDS_UHC_Life_ADD_Export', 'UHC client data'
from edi.lookup_schema;

INSERT INTO edi.lookup (lookupid,key1, value1)
select lookupid, 'ClientJobNumber', '**TBD **'
from edi.lookup_schema where lookupname = 'CDS_UHC_Life_ADD_Export';


update edi.lookup set key2 = 'GroupPolicyNbr', value2 = 'FACETS308016' where lookupid in 
(select lookupid from edi.lookup_schema where lookupname = 'CDS_UHC_Life_ADD_Export');

update edi.lookup set key3 = 'SubGroupPolicyNbr', value3 = '2001' where lookupid in 
(select lookupid from edi.lookup_schema where lookupname = 'CDS_UHC_Life_ADD_Export');

update edi.lookup set key4 = 'BasicLifePlanCode', value4 = 'LE000187' where lookupid in 
(select lookupid from edi.lookup_schema where lookupname = 'CDS_UHC_Life_ADD_Export');

update edi.lookup set key5 = 'BasicLifeAD&DPlanCode', value5 = 'LE000188' where lookupid in 
(select lookupid from edi.lookup_schema where lookupname = 'CDS_UHC_Life_ADD_Export');


--delete from edi.lookup lkup where lookupid in (select lookupid from edi.lookup_schema where lookupname in ('CDS_UHC_Life_ADD_Export'));
--delete from edi.lookup_schema where lookupname in ('CDS_UHC_Life_ADD_Export');

--

( select lkups.lookupname, lkups.lookupid,lkup.lookupid,lkup.key1,lkup.value1,lkup.key2,lkup.value2,lkup.key3,lkup.value3,lkup.key4,lkup.value4,lkup.key5,lkup.value5
         from edi.lookup lkup
         join edi.lookup_schema lkups
           on lkups.lookupid = lkup.lookupid
          and current_date between lkups.effectivedate and lkups.enddate
        where current_date between lkup.effectivedate and lkup.enddate
          and lkups.lookupname in ('CDS_UHC_Life_ADD_Export')
      )

;

update edi.lookup set value1 = '09/22/2020' where lookupid = 6
