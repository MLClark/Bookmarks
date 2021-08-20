--- ANK Demographic Header
select distinct
 'HDR ' ::char(4) as recordType4
,'0001' ::char(4) as recordVersionNbr4
,'061654' ::char(6) as masterContactNbr6
,'Wente Vineyards Comp File' ::char(30) as fileDesc30
---- this feed is expected to run every wed - the following determines wed date
,to_char(current_date - cast(extract(dow from current_date) as int) + 3,'YYYYMMDD') ::char(8) as scheduledTransDate8
,to_char(current_date,'YYYYMMDD') ::char(8) as actualTransDate8
,cast(date_part('hour', current_timestamp) as char(2))||cast(date_part('minute',current_timestamp) as char(2)) ::char(4) as actualTransTime4
,cast(date_part('seconds',elu.lastupdatets)+01 as char(2)) as actualTranNbr2
,elu.feedid as feedid
,elu.lastupdatets + interval '1 second' as lastupdatets
from edi.edi_last_update elu where elu.feedid = 'ANK_MM_401k_Demo_HDR_Export'

;