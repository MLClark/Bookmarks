select * from cognos_person_tax_elections where current_date between effectivedate and enddate and current_timestamp between createts and endts;

select * from person_tax_elections where current_date between effectivedate and enddate and current_timestamp between createts and endts;
select * from cognos_person_tax_elections where current_date between effectivedate and enddate and current_timestamp between createts and endts;

select * from tax_form_header ;
select * from tax_form_detail ;


select * from person_tax_elections where personid = '1071';

select * from tax;

select * from tax_filing_status ;


select * from taxelection;
select * from person_names where lname like 'Rod%';
select * from person_tax_elections where current_date between effectivedate and enddate and current_timestamp between createts and endts
and personid = '20146' and date_part('year',effectivedate) = '2020';
select * from cognos_person_tax_elections where current_date between effectivedate and enddate and current_timestamp between createts and endts
and personid = '20146' and date_part('year',effectivedate) = '2020';

select * from person_names where personid in ('230');

select * from person_names where lname like 'Beam%';