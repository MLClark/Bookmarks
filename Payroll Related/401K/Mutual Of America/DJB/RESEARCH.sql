--select * from company_parameters where companyparametername = 'PInt'; 

--insert into edi.edi_last_update (feedid,lastupdatets) values ('CCB_Alerus_401K_Export','2020-11-06 06:00:17');

select * from edi.edi_last_update;

update edi.edi_last_update set lastupdatets = '2021-01-22 00:00:00'  where feedid = 'Mutual_Of_America';

select * from payroll.payment_detail where check_date >= '2020-12-31' and paycode like 'VB%'		and personid = '1142';

(select lp.lookupid, key1 as etvid, value1, value2 from edi.lookup lp
    		join edi.lookup_schema els on lp.lookupid = els.lookupid and els.lookupname = 'ETV IDs' 
			where current_date between lp.effectivedate and lp.enddate and current_timestamp between lp.createts and lp.endts
    		)
    		;
(SELECT 
			ppd.personid
			,sum(ppd.units) AS hours
			,sum(ppd.amount) as taxable_wage
            FROM PAYROLL.payment_detail ppd
	   		join PAYROLL.payment_header pph on ppd.paymentheaderid = pph.paymentheaderid
	   		join pspay_payroll_pay_sch_periods ppsp on ppsp.payscheduleperiodid = pph.payscheduleperiodid
	   		join pspay_payroll ppay on ppay.pspaypayrollid = ppsp.pspaypayrollid and ppay.pspaypayrollstatusid = 4 and ppay.statusdate is not null
            WHERE ppd.paycode in (select a.paycode from payroll.pay_code_relationships a where a.paycoderelationshiptype in ('401kWg') and current_date between a.effectivedate and a.enddate and current_timestamp between a.createts and a.endts group by paycode)
            AND date_part('year', ppd.check_date) = date_part('year',current_date::DATE)
            GROUP BY 1)
            ;
select * from PAYROLL.payment_header where personid = '784' and check_date = '2021-01-22';   
select * from PAYROLL.payment_detail where personid = '1142' and check_date = '2021-02-05';   


(SELECT 
			ppd.personid
			,ppd.check_date
			,ppd.units AS hours
			,ppd.amount as taxable_wage
            FROM PAYROLL.payment_detail ppd
	   		join PAYROLL.payment_header pph on ppd.paymentheaderid = pph.paymentheaderid
	   		join pspay_payroll_pay_sch_periods ppsp on ppsp.payscheduleperiodid = pph.payscheduleperiodid
	   		join pspay_payroll ppay on ppay.pspaypayrollid = ppsp.pspaypayrollid and ppay.pspaypayrollstatusid = 4 and ppay.statusdate is not null
            WHERE ppd.paycode in (select a.paycode from payroll.pay_code_relationships a where a.paycoderelationshiptype in ('401kWg') and current_date between a.effectivedate and a.enddate and current_timestamp between a.createts and a.endts group by paycode)
            AND date_part('year', ppd.check_date) = date_part('year',current_date::DATE) and ppd.personid = '982'
            )
            ;
            



(SELECT 
			ppd.personid
			,ppd.paycode
			,amount_ytd
			,ppd.units AS hours
			,ppd.amount as taxable_wage
            FROM PAYROLL.payment_detail ppd
               join edi.edi_last_update elu  on elu.feedid =  'Mutual_Of_America' 
	   		join PAYROLL.payment_header pph on ppd.paymentheaderid = pph.paymentheaderid
	   		join pspay_payroll_pay_sch_periods ppsp on ppsp.payscheduleperiodid = pph.payscheduleperiodid
	   		join pspay_payroll ppay on ppay.pspaypayrollid = ppsp.pspaypayrollid and ppay.pspaypayrollstatusid = 4 and ppay.statusdate is not null
            WHERE ppd.paycode in (select a.paycode from payroll.pay_code_relationships a where a.paycoderelationshiptype in ('401kWg') and current_date between a.effectivedate and a.enddate and current_timestamp between a.createts and a.endts group by paycode)
	    	    and coalesce(?::timestamp,elu.lastupdatets) <= ppay.statusdate
	    	    and ppd.personid = '784'
            )
            
select distinct personid, check_date, sum(amount) from payroll.payment_detail where check_date >= '2021-01-01' and paycode = 'E12' group by 1,2;
            ;            