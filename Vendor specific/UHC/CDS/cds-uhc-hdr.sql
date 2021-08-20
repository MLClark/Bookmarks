select 
 ' ' ::char(48) as hdr1_filler
,'HEADER RECORD' ::char(13) as record_type
,' ' ::char(1) as hdr3_filler
,lkups.value1 ::char(8) as client_job_nbr  ----????
,' ' ::char(1) as hdr5_filler
,to_char(current_date,'YYYYMMDD') ::char(8) as file_create_date
,' ' ::char(355) as hd7_filler
,'000000000' ::char(9) as hdr_personid
,'A' ::char(1) as sort_seq
,'*' ::char(1) as count_seq

from 
( select lkups.lookupname, lkups.lookupid,lkup.lookupid,lkup.key1,lkup.value1
         from edi.lookup lkup
         join edi.lookup_schema lkups
           on lkups.lookupid = lkup.lookupid
          and current_date between lkups.effectivedate and lkups.enddate
        where current_date between lkup.effectivedate and lkup.enddate
          and lkups.lookupname in ('CDS_UHC_Life_ADD_Export')
      ) lkups