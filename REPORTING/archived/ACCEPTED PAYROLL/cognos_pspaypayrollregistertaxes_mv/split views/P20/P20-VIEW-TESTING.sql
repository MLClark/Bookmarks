
select personid, paymentheaderid, sum(amount) from payroll.payment_detail where taxid in (select taxid from tax group by 1) group by personid, paymentheaderid order by personid, paymentheaderid;


select personid, sum(amount) from payroll.payment_detail where taxid in (select taxid from tax group by 1) group by personid order by personid;