select * from edi.lookup_schema where lookupname = 'FidelityContributionLoan';
select * from edi.lookup where lookupid = 8;
select * from edi.lookup_schema where lookupname = 'Fidelity_Deferral_Feedback_Import';
select * from edi.lookup where lookupid = 10;
select * from edi.lookup_schema where lookupname = 'FidelityPlanNumber';
select * from edi.lookup where lookupid = 1;
select * from edi.lookup_schema where lookupname = 'FidelityLoanETVIdMap';
select * from edi.lookup where lookupid = 11;
--- mirrored atq
--delete from edi.lookup where lookupid = 8 and value1 in ('08','10');
--delete from edi.lookup where lookupid = 10;

--delete from edi.lookup where lookupid = 10 and id in ('260','261');

( select lkups.lookupname, lkups.lookupid,lkup.lookupid,lkup.key1,lkup.value1,lkup.value2,lkup.value3
         from edi.lookup lkup
         join edi.lookup_schema lkups
           on lkups.lookupid = lkup.lookupid
          and current_date between lkups.effectivedate and lkups.enddate
        where current_date between lkup.effectivedate and lkup.enddate
          and lkups.lookupname in ('Fidelity_Deferral_Feedback_Import','FidelityContributionLoan','FidelityPlanNumber')
      )

;
-- *********************************************************
-- Insert values for Fidelity Contribution Loan (Record 19)
-- *********************************************************
/* already inserted
INSERT INTO edi.lookup_schema (lookupid, lookupname, lookupdesc)
select max(lookupid) + 1, 'FidelityContributionLoan', 'Fidelity Contribution Loan for Record 19'
from edi.lookup_schema;
*/
---- Note Roth inserted into prod in Sept still need to insert After tax.
INSERT INTO edi.lookup (lookupid,key1, value1)
select lookupid, 'Roth', '08'
from edi.lookup_schema where lookupname = 'FidelityContributionLoan';

INSERT INTO edi.lookup (lookupid,key1, value1)
select lookupid, 'After-Tax', '10'
from edi.lookup_schema where lookupname = 'FidelityContributionLoan';

-- Map Employee/Employer/Roth

INSERT INTO edi.lookup (lookupid,key1, value1)
select lookupid, 'Employee', '01'
from edi.lookup_schema where lookupname = 'FidelityContributionLoan';

INSERT INTO edi.lookup (lookupid,key1, value1)
select lookupid, 'Employer', '07'
from edi.lookup_schema where lookupname = 'FidelityContributionLoan';

----- CSD-29826 Beach & CO 401k Deduction Setup for Roth

INSERT INTO edi.lookup (lookupid,key1, value1)
select lookupid, '401K', '40'
from edi.lookup_schema where lookupname = 'Fidelity_Deferral_Feedback_Import';



INSERT INTO edi.lookup (lookupid,key1, value1)
select lookupid, 'After-Tax', '10'
from edi.lookup_schema where lookupname = 'Fidelity_Deferral_Feedback_Import';

select * from edi.lookup_schema where lookupname = 'Fidelity_Deferral_Feedback_Import';

(
			select	lkup.value1 as Rcode, lkup.key1
			from	edi.lookup_schema ls
			join	edi.lookup lkup on lkup.lookupid = ls.lookupid
				and lkup.active = 1
				and current_date between lkup.effectivedate and lkup.enddate
			where	ls.lookupname = 'FidelityContributionLoan'
				and current_date between ls.effectivedate and ls.enddate
				and ls.active = 1)

----- Contribution, Loan, Roth, ER match Export Lookups

----- ALL possible etv_ids for loans 'V15','V31','V57','V58','V60','V61','V62','V63','V64',V66','V73','V75','VCJ','VFP','VFQ','VFR','VFS','VFT'
UPDATE edi.lookup set value4 = 'V66' where lookupid in (select lookupid from edi.lookup_schema where lookupname = 'FidelityLoanETVIdMap');



----- EE contribution 'VB1', 'VB2'
----- ALL possible etv_ids for EE contributions 'VB1','VB2','VB6','VBF'
INSERT INTO edi.lookup_schema (lookupid, lookupname, lookupdesc)
select max(lookupid) + 1, 'FidelityEEContribETVIdMap', 'List of ETV Ids for EE Contribution'
from edi.lookup_schema;

insert into edi.lookup (lookupid, key1, value1, value2, value3)
select lookupid,'ETVList','VB1','VB2','VB6'
  from edi.lookup_schema where lookupname = 'FidelityEEContribETVIdMap';
  


----- Roth contributions 'VB3', 'VB4', 'V25'
----- ALL possible etv_ids for Roth contributions 'VB3', 'VB4', 'V25', 'VAJ'
INSERT INTO edi.lookup_schema (lookupid, lookupname, lookupdesc)
select max(lookupid) + 1, 'FidelityRothContribETVIdMap', 'List of ETV Ids for Roth'
from edi.lookup_schema;

insert into edi.lookup (lookupid, key1, value1, value2, value3)
select lookupid,'ETVList','VB3','VB4','V25'
  from edi.lookup_schema where lookupname = 'FidelityRothContribETVIdMap';
  

----- ER Match contributions 'VB5'
----- ALL possible etv_ids for ER Match contributions 'VB5'
INSERT INTO edi.lookup_schema (lookupid, lookupname, lookupdesc)
select max(lookupid) + 1, 'FidelityERMatchContribETVIdMap', 'List of ETV Ids for Er Match'
from edi.lookup_schema;

insert into edi.lookup (lookupid, key1, value1)
select lookupid,'ETVList','VB5' 
  from edi.lookup_schema where lookupname = 'FidelityERMatchContribETVIdMap';

select * from edi.lookup_schema where lookupname = 'FidelityLoanETVIdMap';
select * from edi.lookup where lookupid in (select lookupid from edi.lookup_schema where lookupname = 'FidelityLoanETVIdMap');
select * from edi.lookup_schema where lookupname = 'FidelityEEContribETVIdMap';
select * from edi.lookup where lookupid in (select lookupid from edi.lookup_schema where lookupname = 'FidelityEEContribETVIdMap');
select * from edi.lookup_schema where lookupname = 'FidelityRothContribETVIdMap';  
select * from edi.lookup where lookupid in (select lookupid from edi.lookup_schema where lookupname = 'FidelityRothContribETVIdMap');
select * from edi.lookup_schema where lookupname = 'FidelityERMatchContribETVIdMap';    
select * from edi.lookup where lookupid in (select lookupid from edi.lookup_schema where lookupname = 'FidelityERMatchContribETVIdMap');