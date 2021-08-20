select * from edi.lookup_schema ;
select * from edi.lookup ;
--delete from edi.lookup_schema where ID IN (2,3,4)
--delete from edi.lookup;
select * from dxpersonpositiondet where ((positiontitle in ('Agent')) or (positiontitle ilike ('%Financial Advisor%')) or (positiontitle ilike '%Acct Rep%' ))

INSERT INTO edi.lookup_schema (lookupid, keycoldesc1, lookupname, lookupdesc)
VALUES (1,'PositionTitle','HMN_BenefitFocus_Census_File_Export','key=lookupname');

INSERT INTO edi.lookup (lookupid, key1, value1, value2)
                              VALUES (1,'PositionTitle','Agent','COMMISSION BASED POSITIONS');
INSERT INTO edi.lookup (lookupid, key1, value1, value2)
                              VALUES (1,'PositionTitle','Financial Advisor','COMMISSION BASED POSITIONS');                              
INSERT INTO edi.lookup (lookupid, key1, value1, value2)
                              VALUES (1,'PositionTitle','Acct Rep','COMMISSION BASED POSITIONS');     
INSERT INTO edi.lookup (lookupid, key1, value1, value2)
                              VALUES (1,'PositionTitle','Senior Financial Advisor','COMMISSION BASED POSITIONS');    
INSERT INTO edi.lookup (lookupid, key1, value1, value2)
                              VALUES (1,'PositionTitle','Sr Financial Advisor','COMMISSION BASED POSITIONS');                                                              



join ( select lkup.lookupid,lkup.key1,lkup.value1,lkup.value2,lkup.value3
         from edi.lookup lkup
         join edi.lookup_schema lkups
           on lkups.lookupid = lkup.lookupid
          and current_date between lkups.effectivedate and lkups.enddate
        where current_date between lkup.effectivedate and lkup.enddate
          and lkups.lookupname = 'HMN_BenefitFocus_Census_File_Export'
      ) lu on 1 = 1
