select 
 GROUP_KEY ::CHAR(5) as group_key
,ETV_ID ::VARCHAR(5) as payrcord
,earning_desc ::varchar(100) as description
,'0' ::char(1) as inactive
,null as paytype
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
  ;
  
  select * from pspay_group_earnings where group_key <> '$$$$$' and earning_name <> 'Reserved'
            and earning_name <> '' and current_timestamp between createts and endts 
            and group_key in ('AYV20','AYV25') ;