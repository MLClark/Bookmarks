-------------------------
-- Debits --
-------------------------

select
--Position 1-2
'P1' ::char(2) as output_source_code
,'DEBIT' ::char(5) as type
--Position 3-6
,'0510' ::char(4) as output_lawson_company
--Position 7-12
,substring(gl.acctnum,0,7) ::char(6) as acct_part_1
--Position 13-16
,'0000' ::char(4) as output_account_4zero
--Filler Spaces 17-31
--Position 32-35
,'0510' ::char(4) as output_dept_law_comp
--Position 36-41
,substring(gl.acctnum,8,7) ::char(6) as acct_part_2
--Filler Spaces 42-66
,'CYCLE DATE ' ::char(11) as cycle_date
--Position 67-96 (need to add filler)
,to_char(ppay.statusdate,'MM/dd/yyyy') ::char(10) as hold_date
--Position 97-104
,to_char(ppay.statusdate,'YYYYMMDD') ::char(8) as post_date
--Position 105-119
,ltrim(to_char(ABS(gl.amount *100),'000000000000000')) ::char(15) as output_amount
--(either blank or negative sign) position 120

------------------------------
--Debits are true to their DB value (i.e. Positive value is positive and vice versa) 
, case when gl.amount < 0 then '-' else ' ' end ::char(1) as output_amount_sign 
------------------------------

--Filler Spaces 121-145
--Position 146-148
,substring(gl.acctnum,15,3) ::char(3) as acct_part_3
--Position 149
,'N' ::char(1) as output_par_nonpar
--Position 150
,'N' ::char(1) as output_qual_nonqual
--Filler Spaces 151-250
,'1' as sort_seq
,'1' as intra_sort
,gl.acctnum as acctnum
,elu.lastupdatets

from pspay_payroll ppay

join (select pspaypayrollid,acctnum,creditdebitind, sum(case when creditdebitind = 'D' then amount end) as amount from public.cognos_gl_detail_results_released_mv group by 2,1,3 order by 2) gl on gl.pspaypayrollid = ppay.pspaypayrollid

join edi.edi_last_update elu on elu.feedid = 'HMN_GL_Export' 
join gl_execute_job gej on gej.pspaypayrollid = ppay.pspaypayrollid
where elu.lastupdatets <= ppay.statusdate 
  and gej.executestatus = 1
  and gl.amount is not null
  and ppay.pspaypayrollstatusid = '4'

-----------------------------------------------------------------------------------------------
union 
-----------------------------------------------------------------------------------------------

------------------
-- Credits ------
------------------

select
--Position 1-2
'P1' ::char(2) as output_source_code
,'CREDIT' ::char(6) as type
--Position 3-6
,'0510' ::char(4) as output_lawson_company
--Position 7-12
,substring(gl.acctnum,0,7) ::char(6) as acct_part_1
--Position 13-16
,'0000' ::char(4) as output_account_4zero
--Filler Spaces 17-31
--Position 32-35
,'0510' ::char(4) as output_dept_law_comp
--Position 36-41
,substring(gl.acctnum,8,7) ::char(6) as acct_part_2
--Filler Spaces 42-66
,'CYCLE DATE ' ::char(11) as cycle_date
--Position 67-96 (need to add filler)
,to_char(ppay.statusdate,'MM/dd/yyyy') ::char(10) as hold_date
--Position 97-104
,to_char(ppay.statusdate,'YYYYMMDD') ::char(8) as post_date
--Position 105-119
,ltrim(to_char(ABS(gl.amount *100),'000000000000000')) ::char(15) as output_amount
--(either blank or negative sign) position 120

------------------------------
-- Credits are opposite of their DB value (i.e. Positive value is negative and vice versa) 
,case when gl.amount < 0 then ' ' else '-' end ::char(1) as output_amount_sign 
------------------------------

--Filler Spaces 121-145
--Position 146-148
,substring(gl.acctnum,15,3) ::char(3) as acct_part_3
--Position 149
,'N' ::char(1) as output_par_nonpar
--Position 150
,'N' ::char(1) as output_qual_nonqual
--Filler Spaces 151-250
,'1' as sort_seq
,'2' as intra_sort
,gl.acctnum as acctnum
,elu.lastupdatets

from pspay_payroll ppay

join (select pspaypayrollid,acctnum,creditdebitind, sum(case when creditdebitind = 'C' then amount end) as amount from public.cognos_gl_detail_results_released_mv group by 2,1,3 order by 2) gl on gl.pspaypayrollid = ppay.pspaypayrollid

join edi.edi_last_update elu on elu.feedid = 'HMN_GL_Export' 
join gl_execute_job gej on gej.pspaypayrollid = ppay.pspaypayrollid
where elu.lastupdatets <= ppay.statusdate 
  and gej.executestatus = 1
  and gl.amount is not null
  and ppay.pspaypayrollstatusid = '4'

order by acctnum,intra_sort