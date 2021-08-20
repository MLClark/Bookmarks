INSERT INTO edi.lookup_schema (lookupid, keycoldesc1, valcoldesc1, lookupname, lookupdesc)
VALUES (7,'PS_Location','EBC_Division_Code','AMJ HSA/FSA Eligibility Feed','key=lookupname');


/*
,CASE lc.locationcode
   WHEN 'ATL'  THEN 'ATL'
   WHEN 'BET'  THEN 'DC'   
   WHEN 'COR'  THEN 'COR'
   WHEN 'DAL'  THEN 'DAL'
   WHEN 'SFR'  THEN 'SF'
   WHEN 'REM'  THEN 'REM'
   WHEN 'PHI'  THEN 'PHI'
   WHEN 'BAL'  THEN 'BAL'        
   WHEN 'HOU'  THEN 'HOU'
   WHEN 'CHI'  THEN 'CHI'   
   WHEN 'PHO'  THEN 'PHX'   
   WHEN 'DEN'  THEN 'DEN'
   WHEN 'EBA'  THEN 'EB'   
   WHEN 'MIA'  THEN 'MIA'  
   WHEN 'SDG'  THEN 'SD'   
   WHEN 'BGL'  THEN 'BGL'   
   WHEN 'CHA'  THEN 'CHAR'   
   WHEN 'CON'  THEN 'CMG' 
   WHEN 'KAN'  THEN 'KC'  
   WHEN 'MAD'  THEN 'MAD'   
   WHEN 'NJY'  THEN 'NJY'   
   WHEN 'NYC'  THEN 'NYC' 
   WHEN 'WAS'  THEN 'DC'   
   WHEN 'CCG'  THEN 'CCG'   
   ELSE lc.locationcode END ::varchar(50) AS DivisionCode
   --ELSE ' ' END ::varchar(50) AS division

*/

INSERT INTO edi.lookup (lookupid,key1,value1) VALUES (7,'ATL','ATL');--WHEN 'ATL'  THEN 'ATL'
INSERT INTO edi.lookup (lookupid,key1,value1) VALUES (7,'BET','DC ');--WHEN 'BET'  THEN 'DC' 
INSERT INTO edi.lookup (lookupid,key1,value1) VALUES (7,'COR','COR');--WHEN 'COR'  THEN 'COR'
INSERT INTO edi.lookup (lookupid,key1,value1) VALUES (7,'DAL','DAL');--WHEN 'DAL'  THEN 'DAL'
INSERT INTO edi.lookup (lookupid,key1,value1) VALUES (7,'SFR','SF ');--WHEN 'SFR'  THEN 'SF'
INSERT INTO edi.lookup (lookupid,key1,value1) VALUES (7,'REM','REM');--WHEN 'REM'  THEN 'REM'
INSERT INTO edi.lookup (lookupid,key1,value1) VALUES (7,'PHI','PHI');--WHEN 'PHI'  THEN 'PHI'
INSERT INTO edi.lookup (lookupid,key1,value1) VALUES (7,'BAL','BAL');--WHEN 'BAL'  THEN 'BAL'
INSERT INTO edi.lookup (lookupid,key1,value1) VALUES (7,'HOU','HOU');--WHEN 'HOU'  THEN 'HOU'
INSERT INTO edi.lookup (lookupid,key1,value1) VALUES (7,'CHI','CHI');--WHEN 'CHI'  THEN 'CHI'
INSERT INTO edi.lookup (lookupid,key1,value1) VALUES (7,'PHO','PHX');--WHEN 'PHO'  THEN 'PHX' 
INSERT INTO edi.lookup (lookupid,key1,value1) VALUES (7,'DEN','DEN');--WHEN 'DEN'  THEN 'DEN'
INSERT INTO edi.lookup (lookupid,key1,value1) VALUES (7,'EBA','EB ');--WHEN 'EBA'  THEN 'EB'   
INSERT INTO edi.lookup (lookupid,key1,value1) VALUES (7,'MIA','MIA');--WHEN 'MIA'  THEN 'MIA'  
INSERT INTO edi.lookup (lookupid,key1,value1) VALUES (7,'SDG','SD ');--WHEN 'SDG'  THEN 'SD'   
INSERT INTO edi.lookup (lookupid,key1,value1) VALUES (7,'BGL','BGL');--WHEN 'BGL'  THEN 'BGL'   
INSERT INTO edi.lookup (lookupid,key1,value1) VALUES (7,'CHA','CHAR');--WHEN 'CHA'  THEN 'CHAR' 
INSERT INTO edi.lookup (lookupid,key1,value1) VALUES (7,'CON','CMG');--WHEN 'CON'  THEN 'CMG' 
INSERT INTO edi.lookup (lookupid,key1,value1) VALUES (7,'KAN','KC ');--WHEN 'KAN'  THEN 'KC'  
INSERT INTO edi.lookup (lookupid,key1,value1) VALUES (7,'MAD','MAD');--WHEN 'MAD'  THEN 'MAD'   
INSERT INTO edi.lookup (lookupid,key1,value1) VALUES (7,'NJY','NJY');--WHEN 'NJY'  THEN 'NJY'  
INSERT INTO edi.lookup (lookupid,key1,value1) VALUES (7,'NYC','NYC');--WHEN 'NYC'  THEN 'NYC' 
INSERT INTO edi.lookup (lookupid,key1,value1) VALUES (7,'WAS','DC');--WHEN 'WAS'  THEN 'DC'   
INSERT INTO edi.lookup (lookupid,key1,value1) VALUES (7,'CCG','CCG');--WHEN 'CCG'  THEN 'CCG'  

INSERT INTO edi.lookup (lookupid,key1,value1) VALUES (7,'OMA','OMA');-- no mapping
INSERT INTO edi.lookup (lookupid,key1,value1) VALUES (7,'FTL','FTL');-- no mapping
INSERT INTO edi.lookup (lookupid,key1,value1) VALUES (7,'RAL','RAL');-- no mapping
INSERT INTO edi.lookup (lookupid,key1,value1) VALUES (7,'GPS','GPS');-- no mapping
INSERT INTO edi.lookup (lookupid,key1,value1) VALUES (7,'CLA','CLA');-- no mapping
INSERT INTO edi.lookup (lookupid,key1,value1) VALUES (7,'GPS-Tech','GPS-Tech');-- no mapping

select * from edi.lookup_schema where lookupid = '7';
select * from edi.lookup where lookupid = '7';

delete from edi.lookup_schema where lookupid = '7';
delete from edi.lookup where lookupid = '7';


left join ( select lkup.lookupid,lkup.key1,lkup.value1 
         from edi.lookup lkup
         join edi.lookup_schema lkups
           on lkups.lookupid = lkup.lookupid
          and current_date between lkups.effectivedate and lkups.enddate
        where current_date between lkup.effectivedate and lkup.enddate
          and lkups.lookupname = 'AMJ HSA/FSA Eligibility Feed'
      ) lu on 1 = 1  and lc.locationcode = lu.key1  