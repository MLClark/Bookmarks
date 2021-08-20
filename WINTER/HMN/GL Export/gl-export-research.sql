
 select pspaypayrollid,creditdebitind, sum(amount) as amount
 from public.cognos_gl_detail_results_released_mv where pspaypayrollid = 126
 --and acctnum in ('736040-542210-000','281530-999999-000')
group by 1,2 order by 2
;

select * from cognos_gl_detail_results_released_mv where periodpaydate = '2021-02-22' and processfinaldate is not null;

select * from edi.edi_last_update;

update edi.edi_last_update set lastupdatets = '2021-06-23 11:53:41' where feedid = 'HMN_GL_Export' ---2021-06-24 22:56:45