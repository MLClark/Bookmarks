On Billingsley, the issue is with the transfer from one pay group to another on 2/3/20. 
TaiJiara Billingsley

select * from person_names where lname like 'Billing%';
select emplevent from person_employment group by 1;
select * from person_employment where emplevent = 'Rehire';
select * from person_employment where personid = '1101';
select * from person_locations where personid = '2814';
select * from location_address where locationid = '31';
select * from pay_unit;

select * from edi.lookup_schema;
select * from edi.lookup where lookupid = '10';

select * from person_payroll where personid = '2867';

update edi.edi_last_update set lastupdatets = '2020-03-24 00:00:00' where feedid = 'BAC_BF_pay_unit_start_date';
select * from edi.edi_last_update;

insert into edi.edi_last_update (feedid,lastupdatets) values ('BAC_BF_pay_unit_start_date','2020-01-01 00:00:00');

(select ppay.personid, ppay.payunitid, ppay.effectivedate, rank() over (partition by personid order by effectivedate asc) as rank
   from person_payroll ppay where ppay.effectivedate < ppay.enddate and current_timestamp between ppay.createts and ppay.endts)
  
(select personid, compamount, frequencycode, createts, rank() over (partition by personid order by max(createts) desc) as rank
             from person_compensation where earningscode <> 'BenBase' and current_date between effectivedate and enddate and current_timestamp between createts and endts and personid = '1724'
            group by personid, compamount, frequencycode, createts)   