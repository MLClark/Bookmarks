select 

 ETV_ID ::char(3) as etv_id 
,case when ETV_ID = 'E01' then 'E01H' else etv_id end ::VARCHAR(5) as payrcord

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
      else 'Other' end as description


,0 as inactive
,case when ETV_ID = 'E01' then 1
      when ETV_ID = 'E02' then 6
      when ETV_ID = 'E03' then 7
      when ETV_ID = 'E15' then 8
      when ETV_ID = 'E16' then 9
      when ETV_ID = 'E17' then 10
      when ETV_ID = 'E18' then 12
      when ETV_ID = 'E19' then 12
      when ETV_ID = 'E21' then 12
      when ETV_ID = 'ECH' then 10
      when ETV_ID = 'ECI' then 10
      when ETV_ID = 'ECK' then 8
      else 12 end as paytype

,null as bspayrcd
,null as payrtamt
,null as payunit
,null as payunper
,null as payperod
,null as mxpypper
,null as tiptype
,null as payadvnc
,null as rptaswgs
,null as w2bxnmbr
,null as w2bxlabl
,null as w2bxnmbr2
,null as w2bxlabl2
,null as w2bxnmbr3
,null as w2bxlabl3
,null as w2bxnmbr4
,null as w2bxlabl4
,null as sbjtfdtx
,null as sbjtssec
,null as sbjtmcar
,null as sbjtsttx
,null as sbjtltax
,null as sbjtfuta
,null as sbjtsuta
,null as ffedtxrt
,null as flsttxrt
,null as acruvacn
,null as acrustim
,null as dataentdflt
,null as shftcode
,null as payfactr
,null as updateifexists
,null as requestertrx
,null as usrdefnd1
,null as usrdefnd2
,null as usrdefnd3
,null as usrdefnd4
,null as usrdefnd5

from pspay_group_earnings 
where group_key <> '$$$$$'
  and earning_name <> 'Reserved'
  and earning_name <> '' 
  and current_timestamp between createts and endts 
  and group_key in ('AYV20','AYV25') 
  AND ETV_ID IN ('E01','E02','E03','E17','ECI','E15','E16','ECK','E19','E18','ECH','E21')

union 
select distinct

 ETV_ID ::char(3) as etv_id 
,'E01S' ::VARCHAR(5) as payrcord
,'Salary' ::varchar(100) as description
,0 as inactive
,2 as paytype

,null as bspayrcd
,null as payrtamt
,null as payunit
,null as payunper
,null as payperod
,null as mxpypper
,null as tiptype
,null as payadvnc
,null as rptaswgs
,null as w2bxnmbr
,null as w2bxlabl
,null as w2bxnmbr2
,null as w2bxlabl2
,null as w2bxnmbr3
,null as w2bxlabl3
,null as w2bxnmbr4
,null as w2bxlabl4
,null as sbjtfdtx
,null as sbjtssec
,null as sbjtmcar
,null as sbjtsttx
,null as sbjtltax
,null as sbjtfuta
,null as sbjtsuta
,null as ffedtxrt
,null as flsttxrt
,null as acruvacn
,null as acrustim
,null as dataentdflt
,null as shftcode
,null as payfactr
,null as updateifexists
,null as requestertrx
,null as usrdefnd1
,null as usrdefnd2
,null as usrdefnd3
,null as usrdefnd4
,null as usrdefnd5

from pspay_group_earnings 
where group_key <> '$$$$$'
  and earning_name <> 'Reserved'
  and earning_name <> '' 
  and current_timestamp between createts and endts 
  and group_key in ('AYV20','AYV25') 
  AND ETV_ID IN ('E01')  
  
  ORDER BY 2
  ;
  