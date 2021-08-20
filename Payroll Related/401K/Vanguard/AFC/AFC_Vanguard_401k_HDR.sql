select 
 '00000000000'::char(11) as hdrZeroes
,'HDR'::char(3) as hdrIndicator
,'SFF'::char(8) as hdrFormat
,'097408'::char(6) as hdrPlanNumber
,to_char(current_date,'YYYYMMDD')::char(8) as createDate
,to_char(current_timestamp,'HHMMSS')::char(6) as createTime
,' '::char(7) as planandseqnbr
,' '::char(31) as filler