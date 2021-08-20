-- Summary
SELECT DISTINCT 
public."data_deductions_by_check_date_wide"."checkdate" AS "Check Date"
, SUM(public."data_deductions_by_check_date_wide"."vb1amt") AS "Sum(Pre Taxed 401(k) Amount)"
, SUM(public."data_deductions_by_check_date_wide"."vb2amt") AS "Sum(Pre Taxed 401(k) Catch Up "
, SUM(public."data_deductions_by_check_date_wide"."vb3amt") AS "Sum(Roth Amount)"
, SUM(public."data_deductions_by_check_date_wide"."vb4amt") AS "Sum(Roth Catch Up Amount)"
, SUM(public."data_deductions_by_check_date_wide"."v65amt") AS "Sum(401(k) Loan Amount)"
FROM public."rpt_currentperson"
INNER JOIN public."data_deductions_by_check_date_wide" 
   ON public."data_deductions_by_check_date_wide"."pspid"=public."rpt_currentperson"."eepspid"
WHERE  (public."data_deductions_by_check_date_wide"."checkdate" 
BETWEEN TO_DATE('2017-06-09 00:00:00', 'YYYY-MM-DD HH24:MI:SS') 
 AND TO_DATE('2017-06-09 23:59:59', 'YYYY-MM-DD HH24:MI:SS')) 
GROUP BY public."data_deductions_by_check_date_wide"."checkdate" LIMIT 100000;
-- Detail
SELECT DISTINCT 
public."rpt_currentperson"."eessn" AS "Employee SSN"
, public."rpt_currentperson"."eelname" AS "Last Name"
, public."rpt_currentperson"."eefname" AS "First Name"
, public."rpt_currentperson"."eemname" AS "Middle Name"
, public."rpt_currentperson"."eebirthdate" AS "Birth date"
, public."rpt_currentperson"."eegender" AS "Gender"
, public."rpt_currentperson"."eemaritalstatus" AS "Marital Status"
, public."rpt_currentperson"."eeaddr" AS "Address Line 1"
, public."rpt_currentperson"."eeaddr2" AS "Address Line 2"
, public."rpt_currentperson"."eeadrcity" AS "Address City"
, public."rpt_currentperson"."eeadrstate" AS "Address State"
, public."rpt_currentperson"."eeadrzip" AS "Address Zip"
, public."rpt_currentperson"."eehomephone" AS "Home Phone"
, public."rpt_currentperson"."eeworkphone" AS "Work Phone"
, public."rpt_currentperson"."eehiredt" AS "Hire Date"
, public."rpt_currentperson"."eelasthiredt" AS "Last Hire Date"
, public."rpt_currentperson"."eetrmdt" AS "Termination date"
, public."rpt_currentperson"."eerehireind" AS "Rehire Ind"
, public."rpt_currentperson"."eesenioritydt" AS "Seniority Date"
, public."rpt_currentperson"."eeservicedt" AS "Service date"
, public."data_deductions_by_check_date_wide"."checkdate" AS "Check Date"
, public."data_deductions_by_check_date_wide"."vb1amt" AS "Employee Deferral"
, public."data_deductions_by_check_date_wide"."vb2amt" AS "Employee Catch Up"
, public."data_deductions_by_check_date_wide"."vb3amt" AS "Employee Roth"
, public."data_deductions_by_check_date_wide"."vb4amt" AS "Employee Roth CatchUp"
, public."data_deductions_by_check_date_wide"."v65amt" AS "Loan Payment"
FROM public."rpt_currentperson"
INNER JOIN public."data_deductions_by_check_date_wide" 
   ON public."data_deductions_by_check_date_wide"."pspid"=public."rpt_currentperson"."eepspid"
WHERE  (public."data_deductions_by_check_date_wide"."checkdate" 
BETWEEN TO_DATE('2017-06-09 00:00:00', 'YYYY-MM-DD HH24:MI:SS') 
 AND TO_DATE('2017-06-09 23:59:59', 'YYYY-MM-DD HH24:MI:SS')) 
 --and public."rpt_currentperson"."eessn" = '462895308'
ORDER BY public."rpt_currentperson"."eelname" ASC LIMIT 100000;
