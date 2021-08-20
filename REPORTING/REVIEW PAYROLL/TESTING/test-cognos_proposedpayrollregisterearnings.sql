select x.etv_id as etv_id
    --,pn.name
    --,x.personid as personid
    --,x.paymentheaderid 
    ,sum(x.amount) as amount
    ,sum(x.hours) as hours
    ,sum(x.rate) as rate
    ,sum(x.net_pay) as net_pay
    ,sum(x.gross_pay) as gross_pay
    ,sum(x.ytd_hrs) as ytd_hours
    ,sum(x.ytd_amount) as ytd_amount
    ,sum(x.ytd_wage) as ytd_wage
    from payroll.cognos_proposedpayrollregisterearnings x
    join person_names pn on pn.nametype = 'Legal' and current_date between pn.effectivedate and pn.enddate and current_timestamp between pn.createts and pn.endts and pn.personid = x.personid
    join payroll.staged_transaction st on st.personid = x.personid and st.paycode = x.etv_id
     and st.asofdate = '2021-04-02' and st.paymenttype = x.paymenttype
     and st.payscheduleperiodid = x.payscheduleperiodid 
    --where etv_id not in ('V82', 'V39', 'VBD-ER','VBE-ER' )
    --where etv_id in ('V39-ER') and personid = '1267'
    WHERE X.PAYMENTHEADERID IS NULL
    group by 1--,2,3
    --having sum(amount + ytd_amount + ytd_wage) <> 0 
    order by 1
  ;