
INSERT INTO edi.lookup_schema (lookupid, keycoldesc1,valcoldesc1, valcoldesc2, valcoldesc3, valcoldesc4, lookupname, lookupdesc)
VALUES (1,'ETV_ID', 'PAYRCORD','GP_DESC','PAYTYPE','INACTIVE','SLC_PAYCODE_LOOKUP','"keys=etv_id values=payrcord,gpdesc,paytype"');

select * from edi.lookup_schema where   lookupname = 'SLC_PAYCODE_LOOKUP';
select * from edi.lookup where 

                           
delete from edi.lookup_schema where   lookupname = 'SLC_PAYCODE_LOOKUP';
delete from edi.lookup where id = 91 and key1 = 'E01';
                           
update edi.lookup_schema set keycoldesc1 = 'ETV_ID' where id = 11 and lookupname = 'SLC_PAYCODE_LOOKUP';

INSERT INTO edi.lookup 
select distinct cast(floor(random() * (900-850+1))+850 as dec(4,0)),1 as lookupid,
 ETV_ID ::char(3) as key1 
,case when ETV_ID = 'E01' then 'E01H' else etv_id end ::VARCHAR(5) as value1
,case when ETV_ID = 'E01' then 'Hourly'
      when ETV_ID = 'E02' then 'Overtime'
      when ETV_ID = 'E03' then 'Double Time'
      when ETV_ID = 'E15' then 'Vacation'
      when ETV_ID = 'E16' then 'Sick'
      when ETV_ID = 'E17' then 'Holiday'
      when ETV_ID = 'E18' then 'Other'
      when ETV_ID = 'E19' then 'Other'
      when ETV_ID = 'E21' then 'Other'
      when ETV_ID = 'ECH' then 'Holiday'
      when ETV_ID = 'ECI' then 'Holiday'
      when ETV_ID = 'ECK' then 'Vacation'
      else 'Other' end as value2


,'0' ::char(1) as value3
,case when ETV_ID = 'E01' then '1'
      when ETV_ID = 'E02' then '6'
      when ETV_ID = 'E03' then '7'
      when ETV_ID = 'E15' then '8'
      when ETV_ID = 'E16' then '9'
      when ETV_ID = 'E17' then '10'
      when ETV_ID = 'E18' then '12'
      when ETV_ID = 'E19' then '12'
      when ETV_ID = 'E21' then '12'
      when ETV_ID = 'ECH' then '10'
      when ETV_ID = 'ECI' then '10'
      when ETV_ID = 'ECK' then '8'
      else '12' end as value4
--,case when group_key = 'AYV25' then 'CaneBay' else 'InfoTel' end as payunit


from pspay_group_earnings 
where group_key <> '$$$$$'
  and earning_name <> 'Reserved'
  and earning_name <> '' 
  and current_timestamp between createts and endts 
  and group_key in ('AYV20') 
  AND ETV_ID IN ('E01','E02','E03','E17','ECI','E15','E16','ECK','E19','E18','ECH','E21')

union 
select distinct cast(floor(random() * (900-850+1))+850 as dec(4,0)),1 as lookupid,
 ETV_ID ::char(3) as key1
,'E01S' ::VARCHAR(5) as value1
--,earning_desc ::varchar(100) as ps_desc
,'Salary' ::varchar(100) as value2
,'0' ::char(1) as value3
,'2' as value4
--,case when group_key = 'AYV25' then 'CaneBay' else 'InfoTel' end as payunit

from pspay_group_earnings 
where group_key <> '$$$$$'
  and earning_name <> 'Reserved'
  and earning_name <> '' 
  and current_timestamp between createts and endts 
  and group_key in ('AYV20') 
  AND ETV_ID IN ('E01')  
  
  ORDER BY 4
  
  