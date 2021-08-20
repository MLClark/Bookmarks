select * from (select
			pi2.identity as employeeid,
            pdd.personid,
            pu.payunitdesc as paygroup,
            pdd.depositpriority as sequence,
            pdd.bankroutingcode as transit,
            pdd.bankaccountnumber as account,
            case when pdd.bankaccounttype = 'C' or pdd.bankaccounttype = 'A'  then 'C'
            else 'S'
            end as checking,
            case when pdd.depositnetpercent > 0   then '%'
            when pdd.depositamount > 0 then 'Flat'
            when pdd.depositnetpercent = 0 and pdd.depositamount = 0 then '%'
            else ''
            end as amountcode,
            case when pdd.depositnetpercent > 0   then pdd.depositnetpercent
                 when pdd.depositamount > 0 then pdd.depositamount
                 when pdd.depositnetpercent = 0 and pdd.depositamount = 0 then 100
                 else 0
                 end as amount,
            (pn.fname || ' ' || pn.lname) as nameonaccount,
            pdd.effectivedate as startDate,
            pdd.enddate,
            pdd.createts as lastChange,
            case when pdd.enddate > now() then 1
                 when pdd.enddate < NOW() and pdd.depositamount = (select distinct depositamount from person_direct_deposits where 
                      createts > pdd.createts 
                      and bankroutingcode = pdd.bankroutingcode and bankaccountnumber = pdd.bankaccountnumber and 
                      depositnetpercent = pdd.depositnetpercent and depositamount = pdd.depositamount and personid = pdd.personid) then 0
                when pdd.enddate < NOW() then 1
                else 0 end as doShow
            from person_direct_deposits pdd

     JOIN person_names pn ON pdd.personid = pn.personid AND pn.nametype = 'Legal'::bpchar AND 'now'::text::date >= pn.effectivedate AND 'now'::text::date <= pn.enddate AND now() >= pn.createts AND now() <= pn.endts

/*  This view was changed which broke this query.  It appears that this view was only called to obtain the person's name
    so I joined to person_names instead (3/1/2018)
            left outer join companystafflist csl
            on(pdd.personid = csl.personid)*/

			left outer join person_identity pi2
		      on (pdd.personid = pi2.personid
        	     and pi2.identitytype = 'EmpNo' and pi2.endts > NOW())
            left join PERSONPAYROLLPAGE ppp on 
 			(
				ppp.personid = pdd.personid
				and current_date between  ppp.effectivedate and  ppp.enddate
 			)
			left join pay_unit pu on (
				ppp.payunitid = pu.payunitid
					 
			)
			where ((pdd.enddate > NOW()) OR (pdd.enddate >= current_date - interval '30 days'))
            )as dirdep where doShow = 1 order by lastchange