select * from payroll.payment_detail limit 100;
select * from payroll.payment_header limit 100;
select * from payroll.personperiodpayments;
select * from payroll.payment_types; ---JOIN payroll.payment_types pt ON pt.paymenttype = ppp.paymenttype

select * from person_employment 
 

/*

Work State NOTE:  

If the position a person is tied to is a Remote position, then the worked in state is their home state.  Otherwise it is the state associated with the person_location record

Group Key NOTE:  use group key from following query

       use the groupkey view - same as proposed payroll view.

 */