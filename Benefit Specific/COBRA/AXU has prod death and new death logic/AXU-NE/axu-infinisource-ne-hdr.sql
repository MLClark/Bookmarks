select
  '00000' ::char(9) as personid
,'0' ::char(9) as dependentid
,'1' ::char(10) as sort_seq
,'NE.TXT'::char(25) as file_format
,'4.0' ::char(3) as file_version
,'4A1032' ::char(15) as company_no
,'PEdiTeam' ::char(20) as userid
,'E245GP2M' ::char(20) as pwd
,to_char(current_date,'yyyy-mm-dd') ::char(10) as submission_date
,'EDINotification@peoplestrategy.com;Lori.mccann@peoplestrategy.com' ::char(65) as response_email ---remove lori when live
,' ' ::char(12) as response_fax
,'TRUE' ::char(5) as send_notices
,'TRUE' ::char(5) as validate_only --- blank when live


