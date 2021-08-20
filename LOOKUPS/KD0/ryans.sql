insert into edi.edi_last_update (feedid,lastupdatets) values('KD0_LincolnFinancial_403B_Contributions','2020-05-01 00:00:00');

select * from edi.edi_last_update;

update edi.edi_last_update set lastupdatets = '2020-05-01 00:00:00' where feedid = 'KD0_LincolnFinancial_403B_Contributions';