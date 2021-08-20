select * from payroll.staged_transaction where personid = '1267' and paycode = 'V39-ER';

 ( SELECT staged_transaction.personid,
                    staged_transaction.sequencenumber,
                    staged_transaction.payscheduleperiodid,
                    staged_transaction.asofdate,
                    staged_transaction.paycode,
                    staged_transaction.units_ytd,
                    staged_transaction.amount_ytd,
                    max(staged_transaction.paymentseq) AS paymentseq,
                    rank() OVER (PARTITION BY staged_transaction.personid, staged_transaction.paycode ORDER BY (max(staged_transaction.paymentseq)) DESC) AS rank
                   FROM payroll.staged_transaction
                  WHERE staged_transaction.amount_ytd <> 0::numeric and personid = '1267' and paycode = 'V39-ER'
                  GROUP BY staged_transaction.personid, staged_transaction.sequencenumber, staged_transaction.payscheduleperiodid, staged_transaction.asofdate, staged_transaction.paycode, staged_transaction.units_ytd, staged_transaction.amount_ytd, staged_transaction.subject_wages_ytd
                  )