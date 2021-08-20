

select * from edi.edi_last_update;
update edi.edi_last_update set lastupdatets = '2019-10-08 23:59:34' where feedid = 'HMN_401k_Census_File_Export'; --- '2019-10-08 22:59:59'

select * from person_names where lname like 'Woe%';
select * from person_employment where personid = '68476';
select * from pers_pos where personid = '68476';
select * from position_desc where positionid in ('406011','404953');
select * from person_compensation where personid = '68476';

select * from person_names where lname like 'Hill%';
select * from person_identity where personid = '68498';

select * from person_employment where personid = '68498';
select * from pers_pos where personid = '68498';
select * from position_desc where positionid in ('406011','404953');
select * from person_compensation where personid = '68498';



select * from pspay_payment_detail where personid = '68498' and check_date = '2019-10-15' and etv_id like 'V%';
select * from pspay_payment_detail where personid = '68498' and check_date = '2019-09-30' and etv_id like 'V%';
select * from pspay_payment_detail where personid = '68498' and check_date = '2019-09-13' and etv_id like 'V%';
select * from pspay_payment_detail where personid = '68498' and check_date = '2019-08-30' and etv_id like 'V%';
