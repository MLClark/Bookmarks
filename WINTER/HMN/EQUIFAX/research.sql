select * from cognos_pspay_etv_names_mv  where  etv_id like ('%E%');













select * from pspay_payment_detail  where personid = '66904' and etv_id in ('E61','E63','E64','EA1','EA2','EA9','EAK','EAO','EAS','EAT','EAU','EB3','EBD','EBE','EBG','EBH','EBI','EC0','EC1','EC3','EC6','EC7','ECD','ECE','E26','E23')
and check_date = '2020-09-30';
 select * from person_employment where personid = '63005' ;
(select personid, emplevent, emplstatus, emplclass, emplpermanency, benefitstatus, emplhiredate, empllasthiredate, effectivedate, enddate, createts, endts, paythroughdate, empleventdetcode, emplservicedate, rank() over (partition by personid order by effectivedate , createts ) as rank  
        from person_employment where personid = '63005' and (current_date between effectivedate and enddate or (effectivedate > current_date and enddate > effectivedate)) and current_timestamp between createts and endts 
        )

;

select * from 
select * from person_employment where personid = '67922';
select * from pers_pos where personid = '67922';      
(select personid, positionid, scheduledhours, schedulefrequency, max(effectivedate) as effectivedate, RANK() OVER (PARTITION BY personid ORDER BY max(effectivedate) DESC) AS RANK
             from pers_pos where personid = '67922' and effectivedate < enddate and current_timestamp between createts and endts
            group by personid, positionid, scheduledhours, schedulefrequency)
            ;
select * from position_desc where positionid = '391763';        
 
(select positionid, grade, positiontitle, flsacode, max(effectivedate) as effectivedate, RANK() OVER (PARTITION BY positionid ORDER BY max(effectivedate) DESC) AS RANK
             from position_desc where positionid = '391763' and effectivedate < enddate and current_timestamp between createts and endts 
            group by positionid, grade, positiontitle, flsacode)
            ;
             
select * from person_names where lname like 'Davis%';
select * from person_identity where personid = '67922';
(select eemax.personid,  
  eemax.check_date AS check_date, psp.periodstartdate, psp.periodenddate, pu.payunitid, pu.payunitxid, pu.frequencycode, pu.employertaxid
        FROM (select dpmax.personid as personid, MAX(dpmax.check_date)  AS check_date
        	from cognos_payment_earnings_by_check_date dpmax 
       		where dpmax.check_date in (
     		( SELECT periodpaydate FROM pay_schedule_period
        		 WHERE periodpaydate < ?::DATE        		 
        		   AND payrolltypeid = 1
     		ORDER BY periodpaydate desc)) GROUP BY dpmax.personid ) AS eemax
        join person_payroll pp on eemax.personid = pp.personid and current_date between pp.effectivedate and pp.enddate and current_timestamp between pp.createts and pp.endts
        LEFT JOIN pay_unit pu ON pu.payunitid = pp.payunitid 
 join pay_schedule_period psp on psp.payunitid = pu.payunitid and psp.periodpaydate = eemax.check_date AND payrolltypeid = 1
) ;

(select eemax.personid,  
  eemax.check_date AS check_date, psp.periodstartdate, psp.periodenddate, pu.payunitid, pu.payunitxid, pu.frequencycode, pu.employertaxid, eemax.etv_amount
        FROM (select dpmax.personid as personid, MAX(dpmax.check_date) AS check_date,  sum(dpmax.etv_amount) as etv_amount
        	from pspay_payment_detail dpmax 
       		where dpmax.personid = '65551' and dpmax.check_date in (
     		( SELECT periodpaydate FROM pay_schedule_period
        		 WHERE periodpaydate < ?::DATE        		 
        		   AND payrolltypeid = 1
     		ORDER BY periodpaydate desc)) GROUP BY dpmax.personid  having sum(etv_amount) > 1 ) AS eemax
        join person_payroll pp on eemax.personid = pp.personid and current_date between pp.effectivedate and pp.enddate and current_timestamp between pp.createts and pp.endts
        LEFT JOIN pay_unit pu ON pu.payunitid = pp.payunitid 
 join pay_schedule_period psp on psp.payunitid = pu.payunitid and psp.periodpaydate = eemax.check_date AND payrolltypeid = 1
) ;


WITH perschkdt AS
(select eemax.personid,  
  eemax.check_date AS check_date, psp.periodstartdate, psp.periodenddate, pu.payunitid, pu.payunitxid, pu.frequencycode, pu.employertaxid
        FROM (select dpmax.personid as personid, MAX(dpmax.check_date)  AS check_date
        	from cognos_payment_earnings_by_check_date dpmax 
       		where dpmax.check_date in (
     		( SELECT periodpaydate FROM pay_schedule_period
        		 WHERE periodpaydate < ?::DATE        		 
        		   AND payrolltypeid = 1
     		ORDER BY periodpaydate desc)) GROUP BY dpmax.personid ) AS eemax
        join person_payroll pp on eemax.personid = pp.personid and current_date between pp.effectivedate and pp.enddate and current_timestamp between pp.createts and pp.endts
        LEFT JOIN pay_unit pu ON pu.payunitid = pp.payunitid 
 join pay_schedule_period psp on psp.payunitid = pu.payunitid and psp.periodpaydate = eemax.check_date AND payrolltypeid = 1
) 
(select ppdx.personid
           -- hours year
	           , sum(case when ppdx.etv_id IN ('E01','E05','E18','E19','E20','EAJ','ECA','E02','E29','E15','E16','E17','EAR','E30','E12','E62','EB9','EBA','EBB','E71','EA6','EA8','EAI','EB5','EC5'
                                           ,'E61','E63','E64','EA1','EA2','EA9','EAK','EAO','EAS','EAT','EAU','EB3','EBD','EBE','EBG','EBH','EBI','EC0','EC1','EC3','EC6','EC7','ECD','ECE','ECH','ECI','E27','E25','E26')  then ppdx.etype_hours else 0 end) as hoursYear
           -- gross base year
                , sum(case when ppdx.etv_id IN ('E01','E05','E18','E19','E20','EAJ','ECA','E15','E16','E17','EAR','E30','EB9','EAR','ECH','ECI','E27','ECJ','E26','E08') then ppdx.etv_amount else 0 end) as grossbaseyear
           -- gross overtime
                , sum(case when ppdx.etv_id IN ('E02','E29') then ppdx.etv_amount else 0 end) as grossoveryear
           -- gross bonus year
                , sum(case when ppdx.etv_id IN ('E61','E63','E64','EA1','EA2','EA9','EAK','EAO','EAS','EAT','EAU','EB3','EBD','EBE','EBG','EBH','EBI','EC0','EC1','EC3','EC6','EC7','ECD','ECE','E26','E23', 'E24')  then ppdx.etv_amount else 0 end) as grossbonusyear
           -- gross commission year
                , sum(case when ppdx.etv_id IN ('E12','E62','EB9','EBA','EBB','E25') then ppdx.etv_amount else 0 end) as grosscommissyear
           -- gross other pay year
                , sum(case when ppdx.etv_id IN ('E71','EA6','EA8','EAI','EB5','EC5','EBC','EB7') then ppdx.etv_amount else 0 end) as grossotheryear                                          
            from perschkdt 
            join pspay_payment_detail ppdx on perschkdt.personid = ppdx.personid
            where ppdx.check_date between (extract(year from current_date) ||'-01-01')::date and perschkdt.check_date --and perschkdt.personid = '65551'

            group by ppdx.personid)
            
            ;
select * from pay_schedule_period where periodpaydate < '2020-09-30' and payrolltypeid = 1;

select * from cognos_payment_earnings_by_check_date where personid = '67922' limit 10;
select * from pspay_payment_detail where personid = '67922';
select * from person_payroll where personid = '64567';

select * from person_employment where emplstatus = 'T' and personid in (select personid from pspay_payment_detail where check_date >= current_date - interval '1 year' group by 1)
and date_part('year',effectivedate) = '2020';

select * from person_names where personid = '63015';


select * from edi.edi_last_update;
select * from pers_pos where personid = '68780';
select * from person_compensation where personid = '68780';
select * from person_employment where personid = '68778' and current_date between effectivedate and enddate and current_timestamp between createts and endts;
select * from person_identity where identity = '466760754';
select identity from person_identity where identitytype = 'SSN' and personid in 
(select distinct personid from pspay_payment_detail where  etv_id in ('ECH','ECI','E27','E25','E26') and check_date = '2020-02-28') 

select * from person_names where lname like 'Alv%';

select * from pspay_payment_detail where personid = '63518' and check_date between '2020-01-01' and '2020-02-29' and etv_id like 'E%';

select * from pspay_payment_detail where check_date between '2020-01-01' and '2020-02-29' and etv_id = 'E08';

select * from 
select * from edi.edi_last_update;
update edi.edi_last_update set lastupdatets = '2020-02-10 00:00:00' where feedid = 'HMN_MetLife_DisabilityEligibility';
(select personid, positionid, scheduledhours, schedulefrequency, max(effectivedate) as effectivedate, RANK() OVER (PARTITION BY personid ORDER BY max(effectivedate) DESC) AS RANK
             from pers_pos where effectivedate < enddate and current_timestamp between createts and endts and personid = '68779' 
            group by personid, positionid, scheduledhours, schedulefrequency);

(select positionid, grade, positiontitle, flsacode, max(effectivedate) as effectivedate, RANK() OVER (PARTITION BY positionid ORDER BY max(effectivedate) DESC) AS RANK
             from position_desc where effectivedate < enddate and current_timestamp between createts and endts and personid = '68779' 
            group by positionid, grade, positiontitle, flsacode) ;
            
left join (select personid, compamount, increaseamount, compevent, frequencycode, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate, RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_compensation where (current_date between effectivedate and enddate or (effectivedate > current_date and enddate > effectivedate)) and current_timestamp between createts and endts
            group by personid, compamount, increaseamount, compevent, frequencycode ) --as pc on pc.personid = pe.personid and pc.rank = 1  

--- termed ee
 (select personid, compamount, increaseamount, compevent, frequencycode, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate, RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_compensation where effectivedate < enddate and current_timestamp between createts and endts and personid = '68778' 
            group by personid, compamount, increaseamount, compevent, frequencycode )            ;
            select * from person_compensation where personid = '68779';
            
select * from cognos_pspay_etv_names_mv  where  etv_id like ('%ECJ');          
select * from cognos_pspay_etv_names_mv  where  etv_id  in ('E15','ECH','ECI','E27','ECJ');
select * from pspay_payment_detail where  etv_id in  ('E01','E05','E18','E19','E20','EAJ','ECA','E15','E16','E17','EAR','E30','EB9','EAR','ECH','ECI','E27') and personid = '68536' and check_date between '2020-01-01' and '2020-02-28';      

select sum(etv_amount) from pspay_payment_detail where  etv_id in  ('E01','E05','E18','E19','E20','EAJ','ECA','E15','E16','E17','EAR','E30','EB9','EAR','ECH','ECI','E27') and personid = '68536' and check_date between '2020-01-01' and '2020-02-29';  
select sum(etv_amount) from pspay_payment_detail where  etv_id in  ('E01','E05','E18','E19','E20','EAJ','ECA','E15','E16','E17','EAR','E30','EB9','EAR','ECH','ECI','E27', 'ECJ','E26','E61','E02') and personid = '68536' and check_date between '2020-01-01' and '2020-02-29';  
select etv_id, sum(etv_amount) from pspay_payment_detail where  etv_id  like ('E%') and personid = '68536' and check_date between '2020-01-01' and '2020-02-29' group by 1;

select * from pspay_payment_detail where  etv_id in ('ECH','ECI','E27','E25','E26') and check_date = '2020-02-28' and personid  in    
(select personid from person_identity where identity = '449591568'            )