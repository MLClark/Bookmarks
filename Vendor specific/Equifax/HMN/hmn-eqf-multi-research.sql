select * from pspay_etv_list;
select * from edi.edi_last_update;
select * from pspay_payment_detail where etv_id = 'EB8';



select * from pay_schedule_period where date_part('year',periodpaydate)='2019'and date_part('month',periodpaydate)='07';
(select ppdx.personid, ppdx.group_key, ppdx.etv_id
        -- ALL hours for pay period
                , sum(case when ppdx.etv_id IN ('E01','E05','E18','E19','E20','EAJ','ECA','E02','E29','E15','E16','E17','EAR','E30','E12','E62','EB9','EBA','EBB','E71','EA6','EA8','EAI','EB5','EC5'
                                                ,'E61','E63','E64','EA1','EA2','EA9','EAK','EAO','EAS','EAT','EAU','EB3','EBD','EBE','EBG','EBH','EBI','EC0','EC1','EC3','EC6','EC7','ECD','ECE') then ppdx.etype_hours else 0 end) as hoursA

        --REGULAR hours & pay for pay period - R ----- ETV_ID in ('E01')                      -----
                , sum(case when ppdx.etv_id IN ('E01','E05','E18','E19','E20','EAJ','ECA') then ppdx.etype_hours else 0 end) as hoursR
				, sum(case when ppdx.etv_id IN ('E01','E05','E18','E19','E20','EAJ','ECA') then ppdx.etv_amount else 0 end) as grosspayR

	--OVERTIME hours & pay for pay period - O ----- ETV_ID in ('E02','E03')               -----
                , sum(case when ppdx.etv_id IN ('E02','E29') then ppdx.etype_hours else 0 end) as hoursO
				, sum(case when ppdx.etv_id IN ('E02','E29') then ppdx.etv_amount else 0 end) as grosspayO

	--VACATION hours & pay for pay period - V ----- ETV_ID in ('E15')                     -----
                , sum(case when ppdx.etv_id IN ('E15') then ppdx.etype_hours else 0 end) as hoursV
				, sum(case when ppdx.etv_id IN ('E15') then ppdx.etv_amount else 0 end) as grosspayV

	--SICK hours & pay for pay period - S ----- ETV_ID in ('E16')                     -----
                , sum(case when ppdx.etv_id IN ('E16') then ppdx.etype_hours else 0 end) as hoursS
				, sum(case when ppdx.etv_id IN ('E16') then ppdx.etv_amount else 0 end) as grosspayS

	--HOLIDAY hours & pay for pay period - H ----- ETV_ID in ('E17')                     -----		
                , sum(case when ppdx.etv_id IN ('E17','EAR') then ppdx.etype_hours else 0 end) as hoursH
				, sum(case when ppdx.etv_id IN ('E17','EAR') then ppdx.etv_amount else 0 end) as grosspayH

	--BONUS hours & pay for pay period - B	----- ETV_ID in ('E61')                     -----	
                , sum(case when ppdx.etv_id IN ('E61','E63','E64','EA1','EA2','EA9','EAK','EAO','EAS','EAT','EAU','EB3','EBD','EBE','EBG','EBH','EBI','EC0','EC1','EC3','EC6','EC7','ECD','ECE') then ppdx.etype_hours else 0 end) as hoursB
				, sum(case when ppdx.etv_id IN ('E61','E63','E64','EA1','EA2','EA9','EAK','EAO','EAS','EAT','EAU','EB3','EBD','EBE','EBG','EBH','EBI','EC0','EC1','EC3','EC6','EC7','ECD','ECE') then ppdx.etv_amount else 0 end) as grosspayB

	--SEVERANCE hours & pay for pay period - E ----- ETV_ID in ('E30')                     -----		
                , sum(case when ppdx.etv_id IN ('E30') then ppdx.etype_hours else 0 end) as hoursE
				, sum(case when ppdx.etv_id IN ('E30') then ppdx.etv_amount else 0 end) as grosspayE

	--COMMISSION hours & pay for pay period - C ----- ETV_ID in ('E62')                     -----
                , sum(case when ppdx.etv_id in ('E12','E62','EB9','EBA','EBB') then ppdx.etype_hours else 0 end) as hoursC
				, sum(case when ppdx.etv_id in ('E12','E62','EB9','EBA','EBB')  then ppdx.etv_amount else 0 end) as grosspayC

	--MISC hours & pay for pay period - M
		, sum(case when ppdx.etv_id IN ('E71','EA6','EA8','EAI','EB5','EC5') then ppdx.etype_hours else 0 end) as hoursM
	 	, sum(case when ppdx.etv_id IN ('E71','EA6','EA8','EAI','EB5','EC5') then ppdx.etv_amount else 0 end) as grosspayM
		from person_identity  pi
		join pspay_payment_detail ppdx on ppdx.check_date = '2019-07-15' and pi.personid = ppdx.personid
		where pi.personid = '66027' and pi.identitytype = 'SSN' and current_timestamp between pi.createts and pi.endts
	       group by ppdx.personid, ppdx.group_key, ppdx.etv_id)
	       ;


(select ppdx.personid, pi.identity, ppdx.etv_id 
           -- hours year
	        , sum(case when ppdx.etv_id IN ('E01','E05','E18','E19','E20','EAJ','ECA','E02','E29','E15','E16','E17','EAR','E30','E12','E62','EB9','EBA','EBB','E71','EA6','EA8','EAI','EB5','EC5'
                                                ,'E61','E63','E64','EA1','EA2','EA9','EAK','EAO','EAS','EAT','EAU','EB3','EBD','EBE','EBG','EBH','EBI','EC0','EC1','EC3','EC6','EC7','ECD','ECE') then ppdx.etype_hours else 0 end) as hoursYear
           -- gross base year
                , sum(case when ppdx.etv_id in ('E01','E05','E18','E19','E20','EAJ','ECA','E15','E16','E17','EAR','E30','EB9','EAR')  then ppdx.etv_amount else 0 end) as grossbaseyear
           -- gross overtime
                , sum(case when ppdx.etv_id IN ('E02','E29') then ppdx.etv_amount else 0 end) as grossoveryear
           -- gross bonus year
                , sum(case when ppdx.etv_id IN ('E61','E63','E64','EA1','EA2','EA9','EAK','EAO','EAS','EAT','EAU','EB3','EBD','EBE','EBG','EBH','EBI','EC0','EC1','EC3','EC6','EC7','ECD','ECE') then ppdx.etv_amount else 0 end) as grossbonusyear
           -- gross commission year
                , sum(case when ppdx.etv_id in ('E12','E62','EB9','EBA','EBB') then ppdx.etv_amount else 0 end) as grosscommissyear
           -- gross other pay year
                , sum(case when ppdx.etv_id IN ('E71','EA6','EA8','EAI','EB5','EC5') then ppdx.etv_amount else 0 end) as grossotheryear                                          
            from person_identity  pi
            join pspay_payment_detail ppdx on PI.personid = ppdx.personid
            where ppdx.check_date between (extract(year from current_date) ||'-01-01')::date and '2019-06-28' ---AND pi.personid = '63062'
		  	  and ppdx.check_number <> 'INIT REC'
		  	  and ppdx.check_number <> 'GrsUpNp'
            group by ppdx.personid, pi.identity, ppdx.etv_id )
            ;

select * from benefit_plan_desc;
select * from pay_schedule_period limit 10;
select * from pay_schedule_period where date_part('year',periodpaydate) = '2019' and date_part('month',periodpaydate)='05';
select * from person_compensation where personid = '67691';
select * from person_payroll where personid = '67691';
select * from person_employment where personid = '64086';
select * from person_names where lname like 'Kelly%';
select * from tax_form_header where personid = '66578';
select * from tax where taxiddesc like '%SUI%';
select * from personpayunittaxidsetup where personid = '66578';
select * from pers_pos where personid = '66578';
select * from pspay_stx_list;

select * from empl_status;

select * from pspay_etv_operators;          
select * from pspay_group_earnings;
select * from cognos_pspay_etv_names_mv ;
select * from tax_lookup_aggregators ;
select * from batchdetailtotal;
select * from csvetvoprtlist; 

(select personid, positionid, scheduledhours, schedulefrequency, max(effectivedate) as effectivedate, RANK() OVER (PARTITION BY personid ORDER BY max(effectivedate) DESC) AS RANK
             from pers_pos where (effectivedate < enddate) and current_timestamp between createts and endts
              and personid = '63031'
            group by personid, positionid, scheduledhours, schedulefrequency)
            ;
(select personid, compamount, increaseamount, compevent, frequencycode, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate, RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_compensation where (current_date between effectivedate and enddate or (effectivedate > current_date and enddate > effectivedate)) and current_timestamp between createts and endts
            group by personid, compamount, increaseamount, compevent, frequencycode )
            ;            

(select distinct a.personid,pto.takehours,sum(a.total_hours) as total_hours,cast(sum(a.total_hours) - pto.takehours as dec(18,2)) as reghours
             from (select distinct  pe.personid
                         ,case when pe.emplstatus in ('P','L') then extract (days from (least(pe.enddate,current_date)) - (greatest(pe.effectivedate - interval '1 day' ,current_date - interval '1 year'))) else null end as leave_days  
                         ,case when pe.emplstatus = 'A' then extract (days from (least(pe.enddate,current_date)) - (greatest(pe.effectivedate - interval '1 day' ,current_date - interval '1 year'))) else 0 end as active_days  
                         ,case when pe.enddate > current_date then extract(days from current_date::date - greatest(pe.effectivedate,current_date::date - interval '1 year'))+1
                               when pe.effectivedate > (current_date::date - interval '1 year') and pe.enddate < current_date::date then  pe.enddate - pe.effectivedate+1
                               else extract(days from least(pe.enddate,current_date::date) - (current_date::date - interval '1 year')) end as numdays   
                         ,cast(fc.annualfactor * pp.scheduledhours * 
                              ((case when pe.enddate > current_date then extract(days from current_date::date - greatest(pe.effectivedate ,current_date::date - interval '1 year'))+1 
                                     when pe.effectivedate > (current_date::date - interval '1 year') and pe.enddate < current_date::date then  pe.enddate - pe.effectivedate + 1
                                     else extract(days from least(pe.enddate,current_date::date) - (current_date::date - interval '1 year')) end ) /365::numeric) as dec(18,2)) as total_hours
                      from person_employment pe
                      left join pers_pos pp on pe.personid = pp.personid and current_timestamp between pp.createts and pp.endts and pp.effectivedate < pp.enddate and (pp.effectivedate, pp.enddate) overlaps (pe.effectivedate, pe.enddate)
                      left join person_payroll ppl on ppl.personid = pe.personid and current_date between ppl.effectivedate and ppl.enddate and current_timestamp between ppl.createts and ppl.endts
                      left join pay_unit pu on pu.payunitid = ppl.payunitid
                      left join frequency_codes fc on fc.frequencycode = pu.frequencycode  
                     where current_timestamp between pe.createts and pe.endts and (pe.effectivedate, pe.enddate) overlaps (current_date::date, current_date::date - interval '1 year' ) and pe.effectivedate < pe.enddate and pe.emplstatus = 'A'
                   ) a
            left join (select distinct personid, sum(takehours) as takehours from person_pto_activity_request 
                where ((effectivedate, enddate) overlaps (current_date::date , current_date::date - interval '1 year' )) and reasoncode = 'REQ'
                  and effectivedate >= current_date - interval '1 year' and current_timestamp between createts and endts and effectivedate < enddate group by 1)
               pto on pto.personid = a.personid
           group by 1,2) ;

(select distinct personid, sum(takehours) as takehours from person_pto_activity_request 
                where ((effectivedate, enddate) overlaps (current_date::date , current_date::date - interval '1 year' )) and reasoncode = 'REQ'
                  and effectivedate >= current_date - interval '1 year' and current_timestamp between createts and endts and effectivedate < enddate group by 1)
                  ;    
                  
select * from person_pto_activity_request where personid ='62958' and reasoncode = 'REQ';      
select * from person_pto_plans where personid ='62958';    
select * from pto_plan_desc where ptoplanid in (select distinct ptoplanid from person_pto_activity_request where personid = '62958' and reasoncode = 'REQ');


