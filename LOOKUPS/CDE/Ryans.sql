
update edi.edi_last_update set lastupdatets = '2020-04-11 00:00:00' where feedid = 'CDE_InnovativeHealthServices_FSA_Deduction_Export';

[1:29 PM] Ryan Ferdon
    insert into edi.edi_last_update (feedid,lastupdatets)
values('CDE_InnovativeHealthServices_FSA_Deduction_Export','2020-03-17 00:00:00');
