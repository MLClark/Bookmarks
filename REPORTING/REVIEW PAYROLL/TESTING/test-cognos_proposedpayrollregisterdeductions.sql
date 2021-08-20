--select * from payroll.cognos_proposedpayrollregisterdeductions limit 10;

select x.etv_id as etv_id
    --,pn.name
    --,x.personid as personid
    --,x.paymentheaderid 
    ,sum(amount) as amount
    ,sum(hours) as hours
    ,sum(rate) as rate
    ,sum(net_pay) as net_pay
    ,sum(gross_pay) as gross_pay
    
    ,sum(ytd_amount) as ytd_amount
    ,sum(ytd_wage) as ytd_wage
    from payroll.cognos_proposedpayrollregisterdeductions x
    join person_names pn on pn.nametype = 'Legal' and current_date between pn.effectivedate and pn.enddate and current_timestamp between pn.createts and pn.endts and pn.personid = x.personid
    
    --where etv_id not in ('V82', 'V39', 'VBD-ER','VBE-ER' )
    --where etv_id in ('V39-ER') and personid = '1267'
    WHERE X.PAYMENTHEADERID IS NULL
    group by 1--,2,3
    --having sum(amount + ytd_amount + ytd_wage) <> 0 
    order by 1
  ;