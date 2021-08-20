CREATE VIEW 
        acaemployeeofferofcoverage
(
         apl.personid
        ,identity 
        ,employeename
        ,emplstatus
        ,emplclass
        ,payunitid
        ,reportyear
        ,jan14
        ,feb14
        ,mar14
        ,apr14
        ,may14
        ,jun14
        ,jul14
        ,aug14
        ,sept14
        ,oct14
        ,nov14
        ,dec14
        ,allmonths14
        ,jan16
        ,feb16
        ,mar16
        ,apr16
        ,may16
        ,jun16
        ,jul16
        ,aug16
        ,sept16
        ,oct16
        ,nov16
        ,dec16
        ,allmonths16

) AS 
select
 apl.personid
,pi.identity 
,apl.employeename
,apl.emplstatus
,apl.emplclass
,pp.payunitid
,ael16.reportyear
,ael1415.jan14 as jan14
,ael1415.feb14 as feb14
,ael1415.mar14 as mar14
,ael1415.apr14 as apr14
,ael1415.may14 as may14
,ael1415.jun14 as jun14
,ael1415.jul14 as jul14
,ael1415.aug14 as aug14
,ael1415.sept14 as sept14
,ael1415.oct14 as oct14
,ael1415.nov14 as nov14
,ael1415.dec14 as dec14
,ael1415.allmonths14 as allmonths14
,ael16.jan16 as jan16
,ael16.feb16 as feb16
,ael16.mar16 as mar16
,ael16.apr16 as apr16
,ael16.may16 as may16
,ael16.jun16 as jun16
,ael16.jul16 as jul16
,ael16.aug16 as aug16
,ael16.sept16 as sept16
,ael16.oct16 as oct16
,ael16.nov16 as nov16
,ael16.dec16 as dec16
,ael16.allmonths16 as allmonths16
from acaemployeeline16 ael16

join acapreviewlist apl on apl.personid = ael16.personid and apl.reportyear = ael16.reportyear
join acaemployeeline14and15 ael1415 on ael1415.personid = apl.personid and apl.reportyear = ael1415.reportyear
left join person_payroll pp on pp.personid = ael16.personid
 and current_date between pp.effectivedate and pp.enddate
 and current_timestamp between pp.createts and pp.endts
Left join person_identity pi on pp.personid = pi.personid
 and current_timestamp between pi.createts and pi.endts
 and pi.identitytype = 'PSPID'
order by employeename
;
