select * from person_vitals where personid = '2001';
select 
 birthdate
,to_char(extract(year from age(current_date,birthdate)),'99') as age 
,case when to_char(extract(year from age(current_date,birthdate)),'99') between '30' and'39' then '15.20' end as premium
from person_vitals where personid = '2001';


       when pbe.benefitplanid = '112' and pbe.coverageamount = '10000.00'
        and to_char(extract(year from age(current_date,pve.birthdate)),'99') between '18' and'29' then '19.50'
       when pbe.benefitplanid = '112' and pbe.coverageamount = '10000.00'
        and to_char(extract(year from age(current_date,pve.birthdate)),'99') between '30' and'39' then '15.20'
       when pbe.benefitplanid = '112' and pbe.coverageamount = '10000.00'
        and to_char(extract(year from age(current_date,pve.birthdate)),'99') between '40' and'49' then '36.60'
       when pbe.benefitplanid = '148' and pbe.coverageamount = '10000.00'
        and to_char(extract(year from age(current_date,pve.birthdate)),'99') between '50' and'59' then '66.90'
       when pbe.benefitplanid = '148' and pbe.coverageamount = '10000.00'
        and to_char(extract(year from age(current_date,pve.birthdate)),'99') between '60' and'64' then '122.90'                        

       when pbe.benefitplanid = '148' and pbe.coverageamount = '15000.00'
        and to_char(extract(year from age(current_date,pve.birthdate)),'99') between '18' and'29' then '19.50'
       when pbe.benefitplanid = '148' and pbe.coverageamount = '15000.00'
        and to_char(extract(year from age(current_date,pve.birthdate)),'99') between '30' and'39' then '15.20'
       when pbe.benefitplanid = '148' and pbe.coverageamount = '15000.00'
        and to_char(extract(year from age(current_date,pve.birthdate)),'99') between '40' and'49' then '36.60'
       when pbe.benefitplanid = '148' and pbe.coverageamount = '15000.00'
        and to_char(extract(year from age(current_date,pve.birthdate)),'99') between '50' and'59' then '66.90'
       when pbe.benefitplanid = '148' and pbe.coverageamount = '15000.00'
        and to_char(extract(year from age(current_date,pve.birthdate)),'99') between '60' and'64' then '122.90'    
        
       when pbe.benefitplanid = '148' and pbe.coverageamount = '20000.00'
        and to_char(extract(year from age(current_date,pve.birthdate)),'99') between '18' and'29' then '19.50'
       when pbe.benefitplanid = '148' and pbe.coverageamount = '20000.00'
        and to_char(extract(year from age(current_date,pve.birthdate)),'99') between '30' and'39' then '15.20'
       when pbe.benefitplanid = '148' and pbe.coverageamount = '20000.00'
        and to_char(extract(year from age(current_date,pve.birthdate)),'99') between '40' and'49' then '36.60'
       when pbe.benefitplanid = '148' and pbe.coverageamount = '20000.00'
        and to_char(extract(year from age(current_date,pve.birthdate)),'99') between '50' and'59' then '66.90'
       when pbe.benefitplanid = '148' and pbe.coverageamount = '20000.00'
        and to_char(extract(year from age(current_date,pve.birthdate)),'99') between '60' and'64' then '122.90'   