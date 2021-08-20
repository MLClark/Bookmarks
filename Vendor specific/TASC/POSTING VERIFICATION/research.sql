select * from edi.edi_last_update where feedid = 'TASC_FSA_Posting_Verification_File_Export';
update edi.edi_last_update set lastupdatets = '2021-02-26 11:03:14' where feedid = 'TASC_FSA_Posting_Verification_File_Export';
select * from company_parameters where companyparametername = 'PInt'; 
select * from person_deduction_setup where etvid like 'V%';
select * from cognos_pspay_etv_names_mv  where  etv_id like ('V%');