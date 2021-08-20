/*


View changes:
1. Include legislationid 5, remove currentdate between logic when joining to company_tax_setup table to bring in current data as well as historical data
2. Add new paycodes to ETV list EEC,EED,EEE
3. Add the following 3 columns
EE Medicare Security Wages on Sick/ FMLA
ER Social Security tax on Sick/FMLA
Imported

*/

 select * from covid_credit_detail;
 select * from cognos_covid_credit_detail;
 
 