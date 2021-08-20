select 
 pi.personid
,'D' ::char(1) as id
,pi.identity ::char(15) as ssn
,to_char(current_date,'mm-dd-yyyy')::char(10) as process_date

,case when dedamt.etv_id = 'VB1' then '11BTCT1'
      when dedamt.etv_id = 'VBU' then '63MTCH3'
      when dedamt.etv_id = 'VB2' then '31CTCHP'
      when dedamt.etv_id = 'V65' then '41LOAN1'
      when dedamt.etv_id = 'VBT' then '51LOAN2'
      when dedamt.etv_id = 'VB5' then '21MTCH2'
      when dedamt.etv_id = 'VB3' then '71RTCT1'
      when dedamt.etv_id = 'VB4' then '81RTCHP' end ::char(7) as sort_contrib_code 
      
      
,to_char(psp.periodstartdate,'YYYYMMDD')::char(8) as pp_begin_date
,to_char(psp.periodenddate,'YYYYMMDD')::char(8) as pp_end_date
,dedamt.etv_id
,dedamt.check_date
,cast(100 as dec(3,0)) as times_factor --- used by totals in kettle script
,case when dedamt.etv_id = 'VB1' then '1BTCT1'-- Pre Taxed 401(k)
      when dedamt.etv_id = 'VBU' then '3MTCH3'-- 401 (k) 3MTCH3
      when dedamt.etv_id = 'VB2' then '1CTCHP'-- Pre Taxed 401(k) Catch Up
      when dedamt.etv_id = 'V65' then '1LOAN1'-- 401(k) Loan
      when dedamt.etv_id = 'VBT' then '1LOAN2'-- 401(k) Loan 2
      when dedamt.etv_id = 'VB5' then '1MTCH2'-- 401(k) Company
      when dedamt.etv_id = 'VB3' then '1RTCT1'-- Roth
      when dedamt.etv_id = 'VB4' then '1RTCHP'-- Roth Catch Up 
      end ::char(6) as contrib_code
      
       

,case when dedamt.etv_id = 'VB1' then cast(dedamt.vb1_amount as dec(18,2))
      when dedamt.etv_id = 'VBU' then cast(dedamt.vbu_amount as dec(18,2))
      when dedamt.etv_id = 'VB2' then cast(dedamt.vb2_amount as dec(18,2))
      when dedamt.etv_id = 'V65' then cast(dedamt.v65_amount as dec(18,2))
      when dedamt.etv_id = 'VBT' then cast(dedamt.vbt_amount as dec(18,2))
      when dedamt.etv_id = 'VB5' then cast(dedamt.vb5_amount as dec(18,2))
      when dedamt.etv_id = 'VB3' then cast(dedamt.vb3_amount as dec(18,2))
      when dedamt.etv_id = 'VB4' then cast(dedamt.vb4_amount as dec(18,2)) end  as contrib_amt
      
,case when dedamt.etv_id = 'VB1' then to_char(dedamt.vb1_amount,'0000000000009v99') 
      when dedamt.etv_id = 'VBU' then to_char(dedamt.vbu_amount,'0000000000009v99')
      when dedamt.etv_id = 'VB2' then to_char(dedamt.vb2_amount,'0000000000009v99') 
      when dedamt.etv_id = 'V65' then to_char(dedamt.v65_amount,'0000000000009v99')
      when dedamt.etv_id = 'VBT' then to_char(dedamt.vbt_amount,'0000000000009v99')
      when dedamt.etv_id = 'VB5' then to_char(dedamt.vb5_amount,'0000000000009v99')
      when dedamt.etv_id = 'VB3' then to_char(dedamt.vb3_amount,'0000000000009v99')
      when dedamt.etv_id = 'VB4' then to_char(dedamt.vb4_amount,'0000000000009v99') end  ::char(16) as contrib_amt_alpha

,case when dedamt.etv_id = 'VB1' and dedamt.vb1_amount < 0 then 'N' 
      when dedamt.etv_id = 'VBU' and dedamt.vbu_amount < 0 then 'N' 
      when dedamt.etv_id = 'VB2' and dedamt.vb2_amount < 0 then 'N' 
      when dedamt.etv_id = 'V65' and dedamt.v65_amount < 0 then 'N' 
      when dedamt.etv_id = 'VBT' and dedamt.vbt_amount < 0 then 'N' 
      when dedamt.etv_id = 'VB5' and dedamt.vb5_amount < 0 then 'N' 
      when dedamt.etv_id = 'VB3' and dedamt.vb3_amount < 0 then 'N' 
      when dedamt.etv_id = 'VB4' and dedamt.vb4_amount < 0 then 'N' else 'P' end  as contrib_amt_sign   
      
,case when dedamt.vb1_amount > 0 and substring(dedamt.svb1_amount from 16 for 1) = '0' then overlay(dedamt.svb1_amount placing '{' from 16 for 1)
      when dedamt.vbu_amount > 0 and substring(dedamt.svbu_amount from 16 for 1) = '0' then overlay(dedamt.svbu_amount placing '{' from 16 for 1)
      when dedamt.vb2_amount > 0 and substring(dedamt.svb2_amount from 16 for 1) = '0' then overlay(dedamt.svb2_amount placing '{' from 16 for 1)
      when dedamt.v65_amount > 0 and substring(dedamt.sv65_amount from 16 for 1) = '0' then overlay(dedamt.sv65_amount placing '{' from 16 for 1)
      when dedamt.vbt_amount > 0 and substring(dedamt.svbt_amount from 16 for 1) = '0' then overlay(dedamt.svbt_amount placing '{' from 16 for 1)
      when dedamt.vb5_amount > 0 and substring(dedamt.svb5_amount from 16 for 1) = '0' then overlay(dedamt.svb5_amount placing '{' from 16 for 1)
      when dedamt.vb3_amount > 0 and substring(dedamt.svb3_amount from 16 for 1) = '0' then overlay(dedamt.svb3_amount placing '{' from 16 for 1)
      when dedamt.vb4_amount > 0 and substring(dedamt.svb4_amount from 16 for 1) = '0' then overlay(dedamt.svb4_amount placing '{' from 16 for 1)
  
      when dedamt.vb1_amount < 0 and substring(dedamt.svb1_amount from 16 for 1) = '0' then overlay(dedamt.svb1_amount placing '}' from 16 for 1)
      when dedamt.vbu_amount < 0 and substring(dedamt.svbu_amount from 16 for 1) = '0' then overlay(dedamt.svbu_amount placing '}' from 16 for 1)
      when dedamt.vb2_amount < 0 and substring(dedamt.svb2_amount from 16 for 1) = '0' then overlay(dedamt.svb2_amount placing '}' from 16 for 1) 
      when dedamt.v65_amount < 0 and substring(dedamt.sv65_amount from 16 for 1) = '0' then overlay(dedamt.sv65_amount placing '}' from 16 for 1) 
      when dedamt.vbt_amount < 0 and substring(dedamt.svbt_amount from 16 for 1) = '0' then overlay(dedamt.svbt_amount placing '}' from 16 for 1)    
      when dedamt.vb5_amount < 0 and substring(dedamt.svb5_amount from 16 for 1) = '0' then overlay(dedamt.svb5_amount placing '}' from 16 for 1)
      when dedamt.vb3_amount < 0 and substring(dedamt.svb3_amount from 16 for 1) = '0' then overlay(dedamt.svb3_amount placing '}' from 16 for 1)
      when dedamt.vb4_amount < 0 and substring(dedamt.svb4_amount from 16 for 1) = '0' then overlay(dedamt.svb4_amount placing '}' from 16 for 1)
      
      when dedamt.vb1_amount > 0 and substring(dedamt.svb1_amount from 16 for 1) = '1' then overlay(dedamt.svb1_amount placing 'A' from 16 for 1)
      when dedamt.vbu_amount > 0 and substring(dedamt.svbu_amount from 16 for 1) = '1' then overlay(dedamt.svbu_amount placing 'A' from 16 for 1)
      when dedamt.vb2_amount > 0 and substring(dedamt.svb2_amount from 16 for 1) = '1' then overlay(dedamt.svb2_amount placing 'A' from 16 for 1)
      when dedamt.v65_amount > 0 and substring(dedamt.sv65_amount from 16 for 1) = '1' then overlay(dedamt.sv65_amount placing 'A' from 16 for 1)
      when dedamt.vbt_amount > 0 and substring(dedamt.svbt_amount from 16 for 1) = '1' then overlay(dedamt.svbt_amount placing 'A' from 16 for 1)
      when dedamt.vb5_amount > 0 and substring(dedamt.svb5_amount from 16 for 1) = '1' then overlay(dedamt.svb5_amount placing 'A' from 16 for 1)
      when dedamt.vb3_amount > 0 and substring(dedamt.svb3_amount from 16 for 1) = '1' then overlay(dedamt.svb3_amount placing 'A' from 16 for 1)
      when dedamt.vb4_amount > 0 and substring(dedamt.svb4_amount from 16 for 1) = '1' then overlay(dedamt.svb4_amount placing 'A' from 16 for 1)
  
      when dedamt.vb1_amount < 0 and substring(dedamt.svb1_amount from 16 for 1) = '1' then overlay(dedamt.svb1_amount placing 'J' from 16 for 1)
      when dedamt.vbu_amount < 0 and substring(dedamt.svbu_amount from 16 for 1) = '1' then overlay(dedamt.svbu_amount placing 'J' from 16 for 1)
      when dedamt.vb2_amount < 0 and substring(dedamt.svb2_amount from 16 for 1) = '1' then overlay(dedamt.svb2_amount placing 'J' from 16 for 1) 
      when dedamt.v65_amount < 0 and substring(dedamt.sv65_amount from 16 for 1) = '1' then overlay(dedamt.sv65_amount placing 'J' from 16 for 1) 
      when dedamt.vbt_amount < 0 and substring(dedamt.svbt_amount from 16 for 1) = '1' then overlay(dedamt.svbt_amount placing 'J' from 16 for 1)    
      when dedamt.vb5_amount < 0 and substring(dedamt.svb5_amount from 16 for 1) = '1' then overlay(dedamt.svb5_amount placing 'J' from 16 for 1)
      when dedamt.vb3_amount < 0 and substring(dedamt.svb3_amount from 16 for 1) = '1' then overlay(dedamt.svb3_amount placing 'J' from 16 for 1)
      when dedamt.vb4_amount < 0 and substring(dedamt.svb4_amount from 16 for 1) = '1' then overlay(dedamt.svb4_amount placing 'J' from 16 for 1) 
 
      when dedamt.vb1_amount > 0 and substring(dedamt.svb1_amount from 16 for 1) = '2' then overlay(dedamt.svb1_amount placing 'B' from 16 for 1)
      when dedamt.vbu_amount > 0 and substring(dedamt.svbu_amount from 16 for 1) = '2' then overlay(dedamt.svbu_amount placing 'B' from 16 for 1)
      when dedamt.vb2_amount > 0 and substring(dedamt.svb2_amount from 16 for 1) = '2' then overlay(dedamt.svb2_amount placing 'B' from 16 for 1)
      when dedamt.v65_amount > 0 and substring(dedamt.sv65_amount from 16 for 1) = '2' then overlay(dedamt.sv65_amount placing 'B' from 16 for 1)
      when dedamt.vbt_amount > 0 and substring(dedamt.svbt_amount from 16 for 1) = '2' then overlay(dedamt.svbt_amount placing 'B' from 16 for 1)
      when dedamt.vb5_amount > 0 and substring(dedamt.svb5_amount from 16 for 1) = '2' then overlay(dedamt.svb5_amount placing 'B' from 16 for 1)
      when dedamt.vb3_amount > 0 and substring(dedamt.svb3_amount from 16 for 1) = '2' then overlay(dedamt.svb3_amount placing 'B' from 16 for 1)
      when dedamt.vb4_amount > 0 and substring(dedamt.svb4_amount from 16 for 1) = '2' then overlay(dedamt.svb4_amount placing 'B' from 16 for 1)
  
      when dedamt.vb1_amount < 0 and substring(dedamt.svb1_amount from 16 for 1) = '2' then overlay(dedamt.svb1_amount placing 'K' from 16 for 1)
      when dedamt.vbu_amount < 0 and substring(dedamt.svbu_amount from 16 for 1) = '2' then overlay(dedamt.svbu_amount placing 'K' from 16 for 1)
      when dedamt.vb2_amount < 0 and substring(dedamt.svb2_amount from 16 for 1) = '2' then overlay(dedamt.svb2_amount placing 'K' from 16 for 1) 
      when dedamt.v65_amount < 0 and substring(dedamt.sv65_amount from 16 for 1) = '2' then overlay(dedamt.sv65_amount placing 'K' from 16 for 1) 
      when dedamt.vbt_amount < 0 and substring(dedamt.svbt_amount from 16 for 1) = '2' then overlay(dedamt.svbt_amount placing 'K' from 16 for 1)    
      when dedamt.vb5_amount < 0 and substring(dedamt.svb5_amount from 16 for 1) = '2' then overlay(dedamt.svb5_amount placing 'K' from 16 for 1)
      when dedamt.vb3_amount < 0 and substring(dedamt.svb3_amount from 16 for 1) = '2' then overlay(dedamt.svb3_amount placing 'K' from 16 for 1)
      when dedamt.vb4_amount < 0 and substring(dedamt.svb4_amount from 16 for 1) = '2' then overlay(dedamt.svb4_amount placing 'K' from 16 for 1)  
 
      when dedamt.vb1_amount > 0 and substring(dedamt.svb1_amount from 16 for 1) = '3' then overlay(dedamt.svb1_amount placing 'C' from 16 for 1)
      when dedamt.vbu_amount > 0 and substring(dedamt.svbu_amount from 16 for 1) = '3' then overlay(dedamt.svbu_amount placing 'C' from 16 for 1)
      when dedamt.vb2_amount > 0 and substring(dedamt.svb2_amount from 16 for 1) = '3' then overlay(dedamt.svb2_amount placing 'C' from 16 for 1)
      when dedamt.v65_amount > 0 and substring(dedamt.sv65_amount from 16 for 1) = '3' then overlay(dedamt.sv65_amount placing 'C' from 16 for 1)
      when dedamt.vbt_amount > 0 and substring(dedamt.svbt_amount from 16 for 1) = '3' then overlay(dedamt.svbt_amount placing 'C' from 16 for 1)
      when dedamt.vb5_amount > 0 and substring(dedamt.svb5_amount from 16 for 1) = '3' then overlay(dedamt.svb5_amount placing 'C' from 16 for 1)
      when dedamt.vb3_amount > 0 and substring(dedamt.svb3_amount from 16 for 1) = '3' then overlay(dedamt.svb3_amount placing 'C' from 16 for 1)
      when dedamt.vb4_amount > 0 and substring(dedamt.svb4_amount from 16 for 1) = '3' then overlay(dedamt.svb4_amount placing 'C' from 16 for 1)
  
      when dedamt.vb1_amount < 0 and substring(dedamt.svb1_amount from 16 for 1) = '3' then overlay(dedamt.svb1_amount placing 'L' from 16 for 1)
      when dedamt.vbu_amount < 0 and substring(dedamt.svbu_amount from 16 for 1) = '3' then overlay(dedamt.svbu_amount placing 'L' from 16 for 1)
      when dedamt.vb2_amount < 0 and substring(dedamt.svb2_amount from 16 for 1) = '3' then overlay(dedamt.svb2_amount placing 'L' from 16 for 1) 
      when dedamt.v65_amount < 0 and substring(dedamt.sv65_amount from 16 for 1) = '3' then overlay(dedamt.sv65_amount placing 'L' from 16 for 1) 
      when dedamt.vbt_amount < 0 and substring(dedamt.svbt_amount from 16 for 1) = '3' then overlay(dedamt.svbt_amount placing 'L' from 16 for 1)    
      when dedamt.vb5_amount < 0 and substring(dedamt.svb5_amount from 16 for 1) = '3' then overlay(dedamt.svb5_amount placing 'L' from 16 for 1)
      when dedamt.vb3_amount < 0 and substring(dedamt.svb3_amount from 16 for 1) = '3' then overlay(dedamt.svb3_amount placing 'L' from 16 for 1)
      when dedamt.vb4_amount < 0 and substring(dedamt.svb4_amount from 16 for 1) = '3' then overlay(dedamt.svb4_amount placing 'L' from 16 for 1)   
 
      when dedamt.vb1_amount > 0 and substring(dedamt.svb1_amount from 16 for 1) = '4' then overlay(dedamt.svb1_amount placing 'D' from 16 for 1)
      when dedamt.vbu_amount > 0 and substring(dedamt.svbu_amount from 16 for 1) = '4' then overlay(dedamt.svbu_amount placing 'D' from 16 for 1)
      when dedamt.vb2_amount > 0 and substring(dedamt.svb2_amount from 16 for 1) = '4' then overlay(dedamt.svb2_amount placing 'D' from 16 for 1)
      when dedamt.v65_amount > 0 and substring(dedamt.sv65_amount from 16 for 1) = '4' then overlay(dedamt.sv65_amount placing 'D' from 16 for 1)
      when dedamt.vbt_amount > 0 and substring(dedamt.svbt_amount from 16 for 1) = '4' then overlay(dedamt.svbt_amount placing 'D' from 16 for 1)
      when dedamt.vb5_amount > 0 and substring(dedamt.svb5_amount from 16 for 1) = '4' then overlay(dedamt.svb5_amount placing 'D' from 16 for 1)
      when dedamt.vb3_amount > 0 and substring(dedamt.svb3_amount from 16 for 1) = '4' then overlay(dedamt.svb3_amount placing 'D' from 16 for 1)
      when dedamt.vb4_amount > 0 and substring(dedamt.svb4_amount from 16 for 1) = '4' then overlay(dedamt.svb4_amount placing 'D' from 16 for 1)
  
      when dedamt.vb1_amount < 0 and substring(dedamt.svb1_amount from 16 for 1) = '4' then overlay(dedamt.svb1_amount placing 'M' from 16 for 1)
      when dedamt.vbu_amount < 0 and substring(dedamt.svbu_amount from 16 for 1) = '4' then overlay(dedamt.svbu_amount placing 'M' from 16 for 1)
      when dedamt.vb2_amount < 0 and substring(dedamt.svb2_amount from 16 for 1) = '4' then overlay(dedamt.svb2_amount placing 'M' from 16 for 1) 
      when dedamt.v65_amount < 0 and substring(dedamt.sv65_amount from 16 for 1) = '4' then overlay(dedamt.sv65_amount placing 'M' from 16 for 1) 
      when dedamt.vbt_amount < 0 and substring(dedamt.svbt_amount from 16 for 1) = '4' then overlay(dedamt.svbt_amount placing 'M' from 16 for 1)    
      when dedamt.vb5_amount < 0 and substring(dedamt.svb5_amount from 16 for 1) = '4' then overlay(dedamt.svb5_amount placing 'M' from 16 for 1)
      when dedamt.vb3_amount < 0 and substring(dedamt.svb3_amount from 16 for 1) = '4' then overlay(dedamt.svb3_amount placing 'M' from 16 for 1)
      when dedamt.vb4_amount < 0 and substring(dedamt.svb4_amount from 16 for 1) = '4' then overlay(dedamt.svb4_amount placing 'M' from 16 for 1)   
 
      when dedamt.vb1_amount > 0 and substring(dedamt.svb1_amount from 16 for 1) = '5' then overlay(dedamt.svb1_amount placing 'E' from 16 for 1)
      when dedamt.vbu_amount > 0 and substring(dedamt.svbu_amount from 16 for 1) = '5' then overlay(dedamt.svbu_amount placing 'E' from 16 for 1)
      when dedamt.vb2_amount > 0 and substring(dedamt.svb2_amount from 16 for 1) = '5' then overlay(dedamt.svb2_amount placing 'E' from 16 for 1)
      when dedamt.v65_amount > 0 and substring(dedamt.sv65_amount from 16 for 1) = '5' then overlay(dedamt.sv65_amount placing 'E' from 16 for 1)
      when dedamt.vbt_amount > 0 and substring(dedamt.svbt_amount from 16 for 1) = '5' then overlay(dedamt.svbt_amount placing 'E' from 16 for 1)
      when dedamt.vb5_amount > 0 and substring(dedamt.svb5_amount from 16 for 1) = '5' then overlay(dedamt.svb5_amount placing 'E' from 16 for 1)
      when dedamt.vb3_amount > 0 and substring(dedamt.svb3_amount from 16 for 1) = '5' then overlay(dedamt.svb3_amount placing 'E' from 16 for 1)
      when dedamt.vb4_amount > 0 and substring(dedamt.svb4_amount from 16 for 1) = '5' then overlay(dedamt.svb4_amount placing 'E' from 16 for 1)
  
      when dedamt.vb1_amount < 0 and substring(dedamt.svb1_amount from 16 for 1) = '5' then overlay(dedamt.svb1_amount placing 'N' from 16 for 1)
      when dedamt.vbu_amount < 0 and substring(dedamt.svbu_amount from 16 for 1) = '5' then overlay(dedamt.svbu_amount placing 'N' from 16 for 1)
      when dedamt.vb2_amount < 0 and substring(dedamt.svb2_amount from 16 for 1) = '5' then overlay(dedamt.svb2_amount placing 'N' from 16 for 1) 
      when dedamt.v65_amount < 0 and substring(dedamt.sv65_amount from 16 for 1) = '5' then overlay(dedamt.sv65_amount placing 'N' from 16 for 1) 
      when dedamt.vbt_amount < 0 and substring(dedamt.svbt_amount from 16 for 1) = '5' then overlay(dedamt.svbt_amount placing 'N' from 16 for 1)    
      when dedamt.vb5_amount < 0 and substring(dedamt.svb5_amount from 16 for 1) = '5' then overlay(dedamt.svb5_amount placing 'N' from 16 for 1)
      when dedamt.vb3_amount < 0 and substring(dedamt.svb3_amount from 16 for 1) = '5' then overlay(dedamt.svb3_amount placing 'N' from 16 for 1)
      when dedamt.vb4_amount < 0 and substring(dedamt.svb4_amount from 16 for 1) = '5' then overlay(dedamt.svb4_amount placing 'N' from 16 for 1)  
 
      when dedamt.vb1_amount > 0 and substring(dedamt.svb1_amount from 16 for 1) = '6' then overlay(dedamt.svb1_amount placing 'F' from 16 for 1)
      when dedamt.vbu_amount > 0 and substring(dedamt.svbu_amount from 16 for 1) = '6' then overlay(dedamt.svbu_amount placing 'F' from 16 for 1)
      when dedamt.vb2_amount > 0 and substring(dedamt.svb2_amount from 16 for 1) = '6' then overlay(dedamt.svb2_amount placing 'F' from 16 for 1)
      when dedamt.v65_amount > 0 and substring(dedamt.sv65_amount from 16 for 1) = '6' then overlay(dedamt.sv65_amount placing 'F' from 16 for 1)
      when dedamt.vbt_amount > 0 and substring(dedamt.svbt_amount from 16 for 1) = '6' then overlay(dedamt.svbt_amount placing 'F' from 16 for 1)
      when dedamt.vb5_amount > 0 and substring(dedamt.svb5_amount from 16 for 1) = '6' then overlay(dedamt.svb5_amount placing 'F' from 16 for 1)
      when dedamt.vb3_amount > 0 and substring(dedamt.svb3_amount from 16 for 1) = '6' then overlay(dedamt.svb3_amount placing 'F' from 16 for 1)
      when dedamt.vb4_amount > 0 and substring(dedamt.svb4_amount from 16 for 1) = '6' then overlay(dedamt.svb4_amount placing 'F' from 16 for 1)
  
      when dedamt.vb1_amount < 0 and substring(dedamt.svb1_amount from 16 for 1) = '6' then overlay(dedamt.svb1_amount placing 'O' from 16 for 1)
      when dedamt.vbu_amount < 0 and substring(dedamt.svbu_amount from 16 for 1) = '6' then overlay(dedamt.svbu_amount placing 'O' from 16 for 1)
      when dedamt.vb2_amount < 0 and substring(dedamt.svb2_amount from 16 for 1) = '6' then overlay(dedamt.svb2_amount placing 'O' from 16 for 1) 
      when dedamt.v65_amount < 0 and substring(dedamt.sv65_amount from 16 for 1) = '6' then overlay(dedamt.sv65_amount placing 'O' from 16 for 1) 
      when dedamt.vbt_amount < 0 and substring(dedamt.svbt_amount from 16 for 1) = '6' then overlay(dedamt.svbt_amount placing 'O' from 16 for 1)    
      when dedamt.vb5_amount < 0 and substring(dedamt.svb5_amount from 16 for 1) = '6' then overlay(dedamt.svb5_amount placing 'O' from 16 for 1)
      when dedamt.vb3_amount < 0 and substring(dedamt.svb3_amount from 16 for 1) = '6' then overlay(dedamt.svb3_amount placing 'O' from 16 for 1)
      when dedamt.vb4_amount < 0 and substring(dedamt.svb4_amount from 16 for 1) = '6' then overlay(dedamt.svb4_amount placing 'O' from 16 for 1)  
      
      when dedamt.vb1_amount > 0 and substring(dedamt.svb1_amount from 16 for 1) = '7' then overlay(dedamt.svb1_amount placing 'G' from 16 for 1)
      when dedamt.vbu_amount > 0 and substring(dedamt.svbu_amount from 16 for 1) = '7' then overlay(dedamt.svbu_amount placing 'G' from 16 for 1)
      when dedamt.vb2_amount > 0 and substring(dedamt.svb2_amount from 16 for 1) = '7' then overlay(dedamt.svb2_amount placing 'G' from 16 for 1)
      when dedamt.v65_amount > 0 and substring(dedamt.sv65_amount from 16 for 1) = '7' then overlay(dedamt.sv65_amount placing 'G' from 16 for 1)
      when dedamt.vbt_amount > 0 and substring(dedamt.svbt_amount from 16 for 1) = '7' then overlay(dedamt.svbt_amount placing 'G' from 16 for 1)
      when dedamt.vb5_amount > 0 and substring(dedamt.svb5_amount from 16 for 1) = '7' then overlay(dedamt.svb5_amount placing 'G' from 16 for 1)
      when dedamt.vb3_amount > 0 and substring(dedamt.svb3_amount from 16 for 1) = '7' then overlay(dedamt.svb3_amount placing 'G' from 16 for 1)
      when dedamt.vb4_amount > 0 and substring(dedamt.svb4_amount from 16 for 1) = '7' then overlay(dedamt.svb4_amount placing 'G' from 16 for 1)
  
      when dedamt.vb1_amount < 0 and substring(dedamt.svb1_amount from 16 for 1) = '7' then overlay(dedamt.svb1_amount placing 'P' from 16 for 1)
      when dedamt.vbu_amount < 0 and substring(dedamt.svbu_amount from 16 for 1) = '7' then overlay(dedamt.svbu_amount placing 'P' from 16 for 1)
      when dedamt.vb2_amount < 0 and substring(dedamt.svb2_amount from 16 for 1) = '7' then overlay(dedamt.svb2_amount placing 'P' from 16 for 1) 
      when dedamt.v65_amount < 0 and substring(dedamt.sv65_amount from 16 for 1) = '7' then overlay(dedamt.sv65_amount placing 'P' from 16 for 1) 
      when dedamt.vbt_amount < 0 and substring(dedamt.svbt_amount from 16 for 1) = '7' then overlay(dedamt.svbt_amount placing 'P' from 16 for 1)    
      when dedamt.vb5_amount < 0 and substring(dedamt.svb5_amount from 16 for 1) = '7' then overlay(dedamt.svb5_amount placing 'P' from 16 for 1)
      when dedamt.vb3_amount < 0 and substring(dedamt.svb3_amount from 16 for 1) = '7' then overlay(dedamt.svb3_amount placing 'P' from 16 for 1)
      when dedamt.vb4_amount < 0 and substring(dedamt.svb4_amount from 16 for 1) = '7' then overlay(dedamt.svb4_amount placing 'P' from 16 for 1)        
      
      when dedamt.vb1_amount > 0 and substring(dedamt.svb1_amount from 16 for 1) = '8' then overlay(dedamt.svb1_amount placing 'H' from 16 for 1)
      when dedamt.vbu_amount > 0 and substring(dedamt.svbu_amount from 16 for 1) = '8' then overlay(dedamt.svbu_amount placing 'H' from 16 for 1)
      when dedamt.vb2_amount > 0 and substring(dedamt.svb2_amount from 16 for 1) = '8' then overlay(dedamt.svb2_amount placing 'H' from 16 for 1)
      when dedamt.v65_amount > 0 and substring(dedamt.sv65_amount from 16 for 1) = '8' then overlay(dedamt.sv65_amount placing 'H' from 16 for 1)
      when dedamt.vbt_amount > 0 and substring(dedamt.svbt_amount from 16 for 1) = '8' then overlay(dedamt.svbt_amount placing 'H' from 16 for 1)
      when dedamt.vb5_amount > 0 and substring(dedamt.svb5_amount from 16 for 1) = '8' then overlay(dedamt.svb5_amount placing 'H' from 16 for 1)
      when dedamt.vb3_amount > 0 and substring(dedamt.svb3_amount from 16 for 1) = '8' then overlay(dedamt.svb3_amount placing 'H' from 16 for 1)
      when dedamt.vb4_amount > 0 and substring(dedamt.svb4_amount from 16 for 1) = '8' then overlay(dedamt.svb4_amount placing 'H' from 16 for 1)
  
      when dedamt.vb1_amount < 0 and substring(dedamt.svb1_amount from 16 for 1) = '8' then overlay(dedamt.svb1_amount placing 'Q' from 16 for 1)
      when dedamt.vbu_amount < 0 and substring(dedamt.svbu_amount from 16 for 1) = '8' then overlay(dedamt.svbu_amount placing 'Q' from 16 for 1)
      when dedamt.vb2_amount < 0 and substring(dedamt.svb2_amount from 16 for 1) = '8' then overlay(dedamt.svb2_amount placing 'Q' from 16 for 1) 
      when dedamt.v65_amount < 0 and substring(dedamt.sv65_amount from 16 for 1) = '8' then overlay(dedamt.sv65_amount placing 'Q' from 16 for 1) 
      when dedamt.vbt_amount < 0 and substring(dedamt.svbt_amount from 16 for 1) = '8' then overlay(dedamt.svbt_amount placing 'Q' from 16 for 1)    
      when dedamt.vb5_amount < 0 and substring(dedamt.svb5_amount from 16 for 1) = '8' then overlay(dedamt.svb5_amount placing 'Q' from 16 for 1)
      when dedamt.vb3_amount < 0 and substring(dedamt.svb3_amount from 16 for 1) = '8' then overlay(dedamt.svb3_amount placing 'Q' from 16 for 1)
      when dedamt.vb4_amount < 0 and substring(dedamt.svb4_amount from 16 for 1) = '8' then overlay(dedamt.svb4_amount placing 'Q' from 16 for 1)        
 
      when dedamt.vb1_amount > 0 and substring(dedamt.svb1_amount from 16 for 1) = '9' then overlay(dedamt.svb1_amount placing 'I' from 16 for 1)
      when dedamt.vbu_amount > 0 and substring(dedamt.svbu_amount from 16 for 1) = '9' then overlay(dedamt.svbu_amount placing 'I' from 16 for 1)
      when dedamt.vb2_amount > 0 and substring(dedamt.svb2_amount from 16 for 1) = '9' then overlay(dedamt.svb2_amount placing 'I' from 16 for 1)
      when dedamt.v65_amount > 0 and substring(dedamt.sv65_amount from 16 for 1) = '9' then overlay(dedamt.sv65_amount placing 'I' from 16 for 1)
      when dedamt.vbt_amount > 0 and substring(dedamt.svbt_amount from 16 for 1) = '9' then overlay(dedamt.svbt_amount placing 'I' from 16 for 1)
      when dedamt.vb5_amount > 0 and substring(dedamt.svb5_amount from 16 for 1) = '9' then overlay(dedamt.svb5_amount placing 'I' from 16 for 1)
      when dedamt.vb3_amount > 0 and substring(dedamt.svb3_amount from 16 for 1) = '9' then overlay(dedamt.svb3_amount placing 'I' from 16 for 1)
      when dedamt.vb4_amount > 0 and substring(dedamt.svb4_amount from 16 for 1) = '9' then overlay(dedamt.svb4_amount placing 'I' from 16 for 1)
  
      when dedamt.vb1_amount < 0 and substring(dedamt.svb1_amount from 16 for 1) = '9' then overlay(dedamt.svb1_amount placing 'R' from 16 for 1)
      when dedamt.vbu_amount < 0 and substring(dedamt.svbu_amount from 16 for 1) = '9' then overlay(dedamt.svbu_amount placing 'R' from 16 for 1)
      when dedamt.vb2_amount < 0 and substring(dedamt.svb2_amount from 16 for 1) = '9' then overlay(dedamt.svb2_amount placing 'R' from 16 for 1) 
      when dedamt.v65_amount < 0 and substring(dedamt.sv65_amount from 16 for 1) = '9' then overlay(dedamt.sv65_amount placing 'R' from 16 for 1) 
      when dedamt.vbt_amount < 0 and substring(dedamt.svbt_amount from 16 for 1) = '9' then overlay(dedamt.svbt_amount placing 'R' from 16 for 1)    
      when dedamt.vb5_amount < 0 and substring(dedamt.svb5_amount from 16 for 1) = '9' then overlay(dedamt.svb5_amount placing 'R' from 16 for 1)
      when dedamt.vb3_amount < 0 and substring(dedamt.svb3_amount from 16 for 1) = '9' then overlay(dedamt.svb3_amount placing 'R' from 16 for 1)
      when dedamt.vb4_amount < 0 and substring(dedamt.svb4_amount from 16 for 1) = '9' then overlay(dedamt.svb4_amount placing 'R' from 16 for 1)  

      end ::char(16) as converted_contrib_amount
            
,pip.identity ::char(15) as tran_key
,'09878' ::char(5) as client_id   
      
from person_identity pi

join person_identity pip
  on pip.personid = pi.personid
 and pip.identitytype = 'PSPID'
 and current_timestamp between pip.createts and pip.endts
 
join pay_schedule_period psp on 1=1

join 
(select 
 x.personid
,x.check_date
,x.etv_id
,x.vb1_amount as vb1_amount
,x.vbu_amount as vbu_amount
,x.vb2_amount as vb2_amount
,x.v65_amount as v65_amount
,x.vbt_amount as vbt_amount
,x.vb5_amount as vb5_amount
,x.vb3_amount as vb3_amount
,x.vb4_amount as vb4_amount


,x.svb1_amount as svb1_amount
,x.svbu_amount as svbu_amount
,x.svb2_amount as svb2_amount
,x.sv65_amount as sv65_amount
,x.svbt_amount as svbt_amount
,x.svb5_amount as svb5_amount
,x.svb3_amount as svb3_amount
,x.svb4_amount as svb4_amount

from

(select 
 ppd.personid
,ppd.check_date
,ppd.etv_id
,case when ppd.etv_id = 'VB1' then etv_amount  else 0 end as vb1_amount
,case when ppd.etv_id = 'VBU' then etv_amount  else 0 end as vbu_amount
,case when ppd.etv_id = 'VB2' then etv_amount  else 0 end as vb2_amount
,case when ppd.etv_id = 'V65' then etv_amount  else 0 end as v65_amount
,case when ppd.etv_id = 'VBT' then etv_amount  else 0 end as vbt_amount
,case when ppd.etv_id = 'VB5' then etv_amount  else 0 end as vb5_amount
,case when ppd.etv_id = 'VB3' then etv_amount  else 0 end as vb3_amount
,case when ppd.etv_id = 'VB4' then etv_amount  else 0 end as vb4_amount

,case when ppd.etv_id = 'VB1' and ppd.etv_amount <  0 then to_char(etv_amount*-1,'0000000000009v99') 
      when ppd.etv_id = 'VB1' and ppd.etv_amount >= 0 then to_char(etv_amount* 1,'0000000000009v99') end ::char(16) as svb1_amount
,case when ppd.etv_id = 'VBU' and ppd.etv_amount <  0 then to_char(etv_amount*-1,'0000000000009v99') 
      when ppd.etv_id = 'VBU' and ppd.etv_amount >= 0 then to_char(etv_amount* 1,'0000000000009v99') end ::char(16) as svbu_amount
,case when ppd.etv_id = 'VB2' and ppd.etv_amount <  0 then to_char(etv_amount*-1,'0000000000009v99') 
      when ppd.etv_id = 'VB2' and ppd.etv_amount >= 0 then to_char(etv_amount* 1,'0000000000009v99') end ::char(16) as svb2_amount
,case when ppd.etv_id = 'V65' and ppd.etv_amount <  0 then to_char(etv_amount*-1,'0000000000009v99') 
      when ppd.etv_id = 'V65' and ppd.etv_amount >= 0 then to_char(etv_amount* 1,'0000000000009v99') end ::char(16) as sv65_amount
,case when ppd.etv_id = 'VBT' and ppd.etv_amount <  0 then to_char(etv_amount*-1,'0000000000009v99') 
      when ppd.etv_id = 'VBT' and ppd.etv_amount >= 0 then to_char(etv_amount* 1,'0000000000009v99') end ::char(16) as svbt_amount
,case when ppd.etv_id = 'VB5' and ppd.etv_amount <  0 then to_char(etv_amount*-1,'0000000000009v99') 
      when ppd.etv_id = 'VB5' and ppd.etv_amount >= 0 then to_char(etv_amount* 1,'0000000000009v99') end ::char(16) as svb5_amount
,case when ppd.etv_id = 'VB3' and ppd.etv_amount <  0 then to_char(etv_amount*-1,'0000000000009v99') 
      when ppd.etv_id = 'VB3' and ppd.etv_amount >= 0 then to_char(etv_amount* 1,'0000000000009v99') end ::char(16) as svb3_amount
,case when ppd.etv_id = 'VB4' and ppd.etv_amount <  0 then to_char(etv_amount*-1,'0000000000009v99') 
      when ppd.etv_id = 'VB4' and ppd.etv_amount >= 0 then to_char(etv_amount* 1,'0000000000009v99') end ::char(16) as svb4_amount



,psp.periodpaydate
,ppd.paymentheaderid

from person_identity pi

join pay_schedule_period psp 
  on psp.payrolltypeid in (1,2)
 and psp.processfinaldate is not null
 and psp.periodpaydate = ?::date

join pspay_payment_header pph
  on pph.check_date = psp.periodpaydate
 and pph.payscheduleperiodid = psp.payscheduleperiodid 
 
join pspay_payment_detail ppd 
  on ppd.personid = pi.personid
 and ppd.check_date = psp.periodpaydate
 and pph.paymentheaderid = ppd.paymentheaderid

where pi.identitytype = 'SSN'::bpchar 
  AND current_timestamp between pi.createts and pi.endts and ppd.etv_id  in  ('VB1','VBU','VB2','V65','VBT','VB5','VB3','VB4')) x )
  --group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19
  --having sum(x.vb1_amount + x.vbu_amount + x.vb2_amount + x.v65_amount + x.vbt_amount + x.vb5_amount + x.vb3_amount + x.vb4_amount) <> 0) 
  dedamt on dedamt.personid = pi.personid and dedamt.check_date = psp.periodpaydate

where pi.identitytype = 'SSN'
  and current_date between pi.createts and pi.endts
  and psp.periodpaydate = ?::date
  --and pi.personid = '63839'
  
  order by ssn, sort_contrib_code