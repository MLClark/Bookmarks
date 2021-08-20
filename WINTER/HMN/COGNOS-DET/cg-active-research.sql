select * from person_names where lname like 'Harr%';

select * from person_user_field_vals where personid = '62958';
select * from person_user_field_vals where personid = '62958'
and current_timestamp between createts and endts;

(select personid, max(percomppid) as percomppid
             from person_compensation 
             LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'HMN_PS_CogDetGet_Export'
             where effectivedate <= elu.lastupdatets::DATE and current_timestamp between createts and endts 
             and enddate > current_date and personid = '63910'
             group by 1 
             ) ;
             
             2020/11/30 23:59:59.999000000

select * from person_compensation where personid ='63258';
select * from person_compensation where percomppid in ('552851','553548');
select * from edi.edi_last_update ;
update edi.edi_last_update  set lastupdatets = '2020-12-31 23:59:59' where feedid = 'HMN_PS_CogDetGet_Export' ---2020-12-31 23:59:59
(select distinct pe.personid, pes.amount
       ,case when pes.amount <> 0 then to_char(pes.amount/100,'00D9999') 
             when pes.amount =  0 then coalesce(to_char(round(((ppd05.shift_dif_amt / pp.scheduledhours) * pp.scheduledhours)/(pc.compamount/24),2),'00D9999'),'0.00') end ::char(12) as f17_O12_shift_differential_rate  
       ,case when pp.scheduledhours = 86.67 and pes.amount <> 0 then ((pes.amount / pp.scheduledhours) * (pp.scheduledhours * 24) + pc.compamount)
             when pp.scheduledhours = 86.67 and pes.amount  = 0 then ((ppd05.shift_dif_amt / pp.scheduledhours) * (pp.scheduledhours * 24) + pc.compamount) else null end as f18_o13_ee_annual_salary 
   from person_employment pe
   join person_compensation pc 
     on pc.personid = pe.personid
    and current_date between pc.effectivedate and pc.enddate
    and current_timestamp between pc.createts and pc.endts
   join pers_pos pp
     on pp.personid = pe.personid
    and current_date between pp.effectivedate and pp.enddate
    and current_timestamp between pp.createts and pp.endts 

   join (select personid, sum(etv_amount) as shift_dif_amt from pspay_payment_detail ppd where paymentheaderid in 
        (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay join edi.edi_last_update elu on elu.feedid = 'HMN_PS_CogDetGet_Export' and elu.lastupdatets <= ppay.statusdate
                             where ppay.pspaypayrollstatusid = 4 )))  and ppd.etv_id  in  ('E05')
                             group by personid) as ppd05 on ppd05.personid = pe.personid
   
  left join person_earning_setup pes 
    on pes.personid = pe.personid 
   and pes.etvid = 'E05'
   and current_date between pes.effectivedate and pes.enddate 
   and current_timestamp between pes.createts and pes.endts    
                 
  where pe.emplstatus = 'A'
    and current_date between pe.effectivedate and pe.enddate
    and current_timestamp between pe.createts and pe.endts
   order by personid 
) 
select * from person_earning_setup where personid = '63258';
;
(select distinct pe.personid, pes.amount
       ,case when pes.amount <> 0 then to_char(pes.amount/100,'00D9999') 
             when pes.amount =  0 then coalesce(to_char(round(((ppd05.shift_dif_amt / pp.scheduledhours) * pp.scheduledhours)/(pc.compamount/24),2),'00D9999'),'0.00') end ::char(12) as f17_O12_shift_differential_rate  
       ,case when pp.scheduledhours = 86.67 and pes.amount <> 0 then ((pes.amount / pp.scheduledhours) * (pp.scheduledhours * 24) + pc.compamount)
             when pp.scheduledhours = 86.67 and pes.amount  = 0 then ((ppd05.shift_dif_amt / pp.scheduledhours) * (pp.scheduledhours * 24) + pc.compamount) else null end as f18_o13_ee_annual_salary 
   from person_employment pe
   join person_compensation pc 
     on pc.personid = pe.personid
    and current_date between pc.effectivedate and pc.enddate
    and current_timestamp between pc.createts and pc.endts
   join pers_pos pp
     on pp.personid = pe.personid
    and current_date between pp.effectivedate and pp.enddate
    and current_timestamp between pp.createts and pp.endts 

   join (select personid, sum(etv_amount) as shift_dif_amt from pspay_payment_detail ppd where paymentheaderid in 
        (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay join edi.edi_last_update elu on elu.feedid = 'HMN_PS_CogDetGet_Export' and elu.lastupdatets <= ppay.statusdate
                             where ppay.pspaypayrollstatusid = 4 )))  and ppd.etv_id  in  ('E05')
                             group by personid) as ppd05 on ppd05.personid = pe.personid
   
  left join person_earning_setup pes 
    on pes.personid = pe.personid 
   and pes.etvid = 'E05'
   and current_date between pes.effectivedate and pes.enddate 
   and current_timestamp between pes.createts and pes.endts    
                 
  where pe.emplstatus = 'A'
    and current_date between pe.effectivedate and pe.enddate
    and current_timestamp between pe.createts and pe.endts
    and pe.personid = '63258'
   order by personid 
) 
;
(select distinct pe.personid, pes.amount
       ,case when pes.amount <> 0 then to_char(pes.amount/100,'00D9999') 
             when pes.amount =  0 then coalesce(to_char(round(((ppd05.shift_dif_amt / pp.scheduledhours) * pp.scheduledhours)/(pc.compamount/24),2),'00D9999'),'0.00') end ::char(12) as f17_O12_shift_differential_rate  
       ,case when pp.scheduledhours = 86.67 and pes.amount <> 0 then ((pes.amount / pp.scheduledhours) * (pp.scheduledhours * 24) + pc.compamount)
             when pp.scheduledhours = 86.67 and pes.amount  = 0 then ((ppd05.shift_dif_amt / pp.scheduledhours) * (pp.scheduledhours * 24) + pc.compamount) else null end as f18_o13_ee_annual_salary 
   from person_employment pe
   join (select personid, compamount, frequencycode, earningscode, compevent, increaseamount, createts, effectivedate, enddate, RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_compensation LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'HMN_PS_CogDetGet_Export'
            WHERE enddate > effectivedate 
              AND current_timestamp BETWEEN createts AND endts
              and effectivedate <= elu.lastupdatets::DATE ---and compevent not in ('BaseHr')
            group by personid, compamount, frequencycode, earningscode, compevent, increaseamount, createts, effectivedate, enddate) pc on pc.personid = pe.personid and pc.rank = 1 
   join pers_pos pp
     on pp.personid = pe.personid
    and current_date between pp.effectivedate and pp.enddate
    and current_timestamp between pp.createts and pp.endts 

   join (select personid, sum(etv_amount) as shift_dif_amt from pspay_payment_detail ppd where paymentheaderid in 
        (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay join edi.edi_last_update elu on elu.feedid = 'HMN_PS_CogDetGet_Export' and elu.lastupdatets <= ppay.statusdate
                             where ppay.pspaypayrollstatusid = 4 )))  and ppd.etv_id  in  ('E05')
                             group by personid) as ppd05 on ppd05.personid = pe.personid
   
  left join person_earning_setup pes 
    on pes.personid = pe.personid 
   and pes.etvid = 'E05'
   and current_date between pes.effectivedate and pes.enddate 
   and current_timestamp between pes.createts and pes.endts    
                 
  where pe.emplstatus = 'A'
    and current_date between pe.effectivedate and pe.enddate
    and current_timestamp between pe.createts and pe.endts
        and pe.personid = '63258'
   order by personid 
) 

;




----------------------------------------------------- 
,case when pc.compevent in ('Temp') then '0' 
      else to_char(pc.increaseamount,'00000009d00') end ::char(12) as f22_o19_comp_change_amount
----- Last compensation date and increase amount
----- f12_o49_scheduled_hours
----- f21_o18_current_comp_chg_pct      
----- f20_o15_sal_change_date 
----- f22_o19_comp_change_amount
----- f23_o20_cognos_comp_code
----- f24_o21_prev_annual_salary
----- f25_o16_perf_review_desc
----------------------------------------------------- 
left join
 (select personid, compamount, frequencycode, earningscode, compevent, increaseamount, createts, effectivedate, enddate, RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_compensation LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'HMN_PS_CogDetGet_Export'
            WHERE enddate > effectivedate 
              AND current_timestamp BETWEEN createts AND endts and compevent not in ('BaseHr')
              and effectivedate <= elu.lastupdatets::DATE and personid = '63003'
            group by personid, compamount, frequencycode, earningscode, compevent, increaseamount, createts, effectivedate, enddate)
;
select * from person_compensation where personid = '63003' ;


select locationid, salarygraderegion as "Salary Grade Region Code", locationcode, locationdescription from location_codes where current_date between effectivedate and enddate and current_timestamp between createts and endts and salarygraderegion is not null
order by salarygraderegion;

select * from location_codes where current_date between effectivedate and enddate and current_timestamp between createts and endts and salarygraderegion is not null order by salarygraderegion;

,case when lc.locationcode in ('HO','Area A','Raleigh','Dallas')     then 'A'
      when lc.locationcode = 'Area B'  then 'B'
      when lc.locationcode = 'Area C'  then 'C'
      when lc.locationcode = 'Area D'  then 'D'
      when lc.locationcode = 'Area E'  then 'E'
       end ::char(1) as f16_o11_sgr_cognos_code
,case when lc.salarygraderegion = '3' then 'A'   
      when lc.salarygraderegion = '4' then 'B'    
      when lc.salarygraderegion = '5' then 'C'  
      when lc.salarygraderegion = '6' then 'D'  
      when lc.salarygraderegion = '7' then 'E' 
       end ::char(1) as f16_o11_sgr_cognos_code 


select * from person_names where lname like 'Heppard%';

select * from person_employment where personid = '68400';

select * from person_compensation where personid = '65910';

(select personid, compamount, frequencycode, earningscode, compevent, increaseamount, createts, effectivedate, enddate, RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_compensation LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'HMN_PS_CogDetGet_Export'
            WHERE enddate > effectivedate AND current_timestamp BETWEEN createts AND endts and effectivedate <= elu.lastupdatets::DATE and personid = '65910'
            group by personid, compamount, frequencycode, earningscode, compevent, increaseamount, createts, effectivedate, enddate) ;

(select personid, compamount, frequencycode, earningscode, compevent, increaseamount, createts, effectivedate, enddate, RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_compensation LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'HMN_PS_CogDetGet_Export'
            WHERE enddate > effectivedate 
              AND current_timestamp BETWEEN createts AND endts
              and effectivedate <= elu.lastupdatets::DATE  and personid = '65910'
            group by personid, compamount, frequencycode, earningscode, compevent, increaseamount, createts, effectivedate, enddate)










        

(select personid, compamount, frequencycode, earningscode, compevent, increaseamount, createts, effectivedate, enddate, RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_compensation LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'HMN_PS_CogDetGet_Export'
            WHERE enddate > effectivedate AND current_timestamp BETWEEN createts AND endts and effectivedate <= elu.lastupdatets::DATE and personid = '65588'
            group by personid, compamount, frequencycode, earningscode, compevent, increaseamount, createts, effectivedate, enddate);





select * from person_earning_setup where personid in ('68421', '63185', '65915','65711','68349','66074','68438','65947','67855');
select * from person_earning_setup where etvid = 'E05' and amount > 0;
select * from edi.edi_last_update;
update edi.edi_last_update set lastupdatets = '2020-02-29 22:59:59' where feedid = 'HMN_PS_CogDetGet_Export';
select * from pspay_deduction_accumulators;
--- YTD COMP
LEFT JOIN (SELECT personid
                  ,'Y' as eligible_flag 
                 ,coalesce(sum(etv_amount),0) as taxable_wage
             FROM pspay_payment_detail  
             LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'HMN_PS_CogDetGet_Export'          
            WHERE etv_id in ('EBD','E01','E64','EB5','E05','EB8','E15','E16','E17','E18','E19','E20','ECA','EAJ','EAR','EB4','EAK','ECH','E27','ECJ') --3/16/2020 added last 3 etv codes for pto         
              AND date_part('year', check_date) = date_part('year',elu.lastupdatets::DATE) ---- 1/4/2019 changed current_date to elu.lastupdatets::DATE
              and check_date <= elu.lastupdatets::DATE 
         GROUP BY personid,eligible_flag
          ) ytdcomp
  ON ytdcomp.personid = pi.personid  


;

select * from pspay_payment_detail where personid = '63041' and etv_id in ('EBD','E01','E64','EB5','E05','EB8','E15','E16','E17','E18','E19','E20','ECA','EAJ','EAR','EB4','EAK','ECH','E27','ECJ') and date_part('year',check_date)='2020';


(select personid, 'Y' as eligible_flag, coalesce(sum(etv_amount),0) as taxable_wage      
   from pspay_payment_detail ppd 
   join edi.edi_last_update elu on elu.feedid = 'HMN_PS_CogDetGet_Export'
   where personid = '63041' and paymentheaderid in 
        (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay
                             where ppay.pspaypayrollstatusid = 4 )))  and ppd.etv_id  in  ('EBD','E01','E64','EB5','E05','EB8','E15','E16','E17','E18','E19','E20','ECA','EAJ','EAR','EB4','EAK','ECH','E27','ECJ') --3/16/2020 added last 3 etv codes for pto  
                               AND date_part('year', check_date) = date_part('year',elu.lastupdatets::DATE) 
                             group by personid, eligible_flag)    
;

;
--- SEVERENCE PAY
 (SELECT personid
                 ,date_part('year',check_date)
                 ,coalesce(sum(etv_amount),0) as severance_pay
             FROM pspay_payment_detail   
             LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'HMN_PS_CogDetGet_Export'         
            WHERE etv_id in  ('E30')           
              AND date_part('year', check_date) = date_part('year',elu.lastupdatets::DATE) ---- 1/4/2019 changed current_date to elu.lastupdatets::DATE
              and check_date <= elu.lastupdatets::DATE        
            GROUP BY 1,2
          ) 
          
;          
(select personid, coalesce(sum(etv_amount),0) as severance_pay
   from pspay_payment_detail ppd 
   join edi.edi_last_update elu on elu.feedid = 'HMN_PS_CogDetGet_Export' and check_date <= elu.lastupdatets::DATE 
   where paymentheaderid in 
        (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay
                             where ppay.pspaypayrollstatusid = 4 )))  and ppd.etv_id  in  ('E30') --3/16/2020 added last 3 etv codes for pto  
                               AND date_part('year', check_date) = date_part('year',elu.lastupdatets::DATE) 
                             group by personid)    


;

--- HIRING BONUS
(SELECT personid
                 ,date_part('year',check_date)
                 ,coalesce(sum(etv_amount),0) as hiring_bonus
             FROM pspay_payment_detail    
             LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'HMN_PS_CogDetGet_Export'        
            WHERE etv_id in  ('E64')           
              AND date_part('year', check_date) = date_part('year',elu.lastupdatets::DATE) ---- 1/4/2019 changed current_date to elu.lastupdatets::DATE
              and check_date <= elu.lastupdatets::DATE 
            GROUP BY 1,2
          )

;
(select personid, coalesce(sum(etv_amount),0) as hiring_bonus
   from pspay_payment_detail ppd 
   join edi.edi_last_update elu on elu.feedid = 'HMN_PS_CogDetGet_Export' and check_date <= elu.lastupdatets::DATE 
   where paymentheaderid in 
        (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay
                             where ppay.pspaypayrollstatusid = 4 )))  and ppd.etv_id  in  ('E64') 
                               AND date_part('year', check_date) = date_part('year',elu.lastupdatets::DATE) ---- 1/4/2019 changed current_date to elu.lastupdatets::DATE
                             group by personid)    


;
--- LUMP SUM

(SELECT personid
                 ,date_part('year',check_date)
                 ,coalesce(sum(etv_amount),0) as lump_sum
             FROM pspay_payment_detail  
             LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'HMN_PS_CogDetGet_Export'          
            WHERE etv_id in  ('ECA')           
              AND date_part('year', check_date) = date_part('year',elu.lastupdatets::DATE) ---- 1/4/2019 changed current_date to elu.lastupdatets::DATE
              and check_date <= elu.lastupdatets::DATE 
            GROUP BY 1,2
          )
;
(select personid, coalesce(sum(etv_amount),0) as lump_sum
   from pspay_payment_detail ppd 
   join edi.edi_last_update elu on elu.feedid = 'HMN_PS_CogDetGet_Export' and check_date <= elu.lastupdatets::DATE 
   where paymentheaderid in 
        (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay
                             where ppay.pspaypayrollstatusid = 4 )))  and ppd.etv_id  in  ('ECA') 
                               AND date_part('year', check_date) = date_part('year',elu.lastupdatets::DATE) ---- 1/4/2019 changed current_date to elu.lastupdatets::DATE
                             group by personid)    


;

--- ALL BONUS
(SELECT personid
                 ,date_part('year',check_date)
                 ,coalesce(sum(etv_amount),0) as ALL_bonus
             FROM pspay_payment_detail     
             LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'HMN_PS_CogDetGet_Export'       
            WHERE etv_id in  ('E61','EA1','EB1','EBE','EBH','EA2','EBI')          
              AND date_part('year', check_date) = date_part('year',elu.lastupdatets::DATE) ---- 1/4/2019 changed current_date to elu.lastupdatets::DATE
              and check_date <= elu.lastupdatets::DATE 
            GROUP BY 1,2
          )
;
(select personid, coalesce(sum(etv_amount),0) as ALL_bonus
   from pspay_payment_detail ppd 
   join edi.edi_last_update elu on elu.feedid = 'HMN_PS_CogDetGet_Export' and check_date <= elu.lastupdatets::DATE 
   where paymentheaderid in 
        (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay
                             where ppay.pspaypayrollstatusid = 4 )))  and ppd.etv_id  in  ('E61','EA1','EB1','EBE','EBH','EA2','EBI')  
                               AND date_part('year', check_date) = date_part('year',elu.lastupdatets::DATE) ---- 1/4/2019 changed current_date to elu.lastupdatets::DATE
                             group by personid)    
;
--- YTD FICA
(SELECT personid
                 ,sum(etv_amount) as fica
             FROM pspay_payment_detail  
             LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'HMN_PS_CogDetGet_Export'          
            WHERE etv_id in  ('T01','T13')           
              and date_part('year', check_date) = date_part('year',elu.lastupdatets::DATE) ---- 1/4/2019 changed current_date to elu.lastupdatets::DATE
              and check_date <= elu.lastupdatets::DATE 
              --and check_number = 'DIRDEP'
         GROUP BY personid
          )

;
(select personid, coalesce(sum(etv_amount),0) as fica
   from pspay_payment_detail ppd 
   join edi.edi_last_update elu on elu.feedid = 'HMN_PS_CogDetGet_Export' and check_date <= elu.lastupdatets::DATE 
   where paymentheaderid in 
        (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay
                             where ppay.pspaypayrollstatusid = 4 )))  and ppd.etv_id  in ('T01','T13')    
                               AND date_part('year', check_date) = date_part('year',elu.lastupdatets::DATE) ---- 1/4/2019 changed current_date to elu.lastupdatets::DATE
                             group by personid)    
;
--- dependent care
(select personid, etv_id, current_dedn_amount, sum(etv_amount) as etv_amount
         from pspay_payment_detail 
         LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'HMN_PS_CogDetGet_Export'
        where etv_id = 'VBB'
          AND date_part('year',check_date) = date_part('year',elu.lastupdatets)
          and date_part('month',check_date) = date_part('month',elu.lastupdatets)
          group by 1,2
      )
;
(select personid, coalesce(sum(etv_amount),0) as etv_amount
   from pspay_payment_detail ppd 
   join edi.edi_last_update elu on elu.feedid = 'HMN_PS_CogDetGet_Export' and date_part('year', check_date) = date_part('year',elu.lastupdatets::DATE) and date_part('month',check_date) = date_part('month',elu.lastupdatets::date)
   where paymentheaderid in 
        (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay
                             where ppay.pspaypayrollstatusid = 4 )))  and ppd.etv_id  in ('VBB')    
                               AND date_part('year', check_date) = date_part('year',elu.lastupdatets::DATE) 
                               and date_part('month',check_date) = date_part('month',elu.lastupdatets::date) ---- 1/4/2019 changed current_date to elu.lastupdatets::DATE
                             group by personid) 
;                             
      (select individual_key, current_dedn_amount, etv_id
         from pspay_deduction_accumulators 
         LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'HMN_PS_CogDetGet_Export'
        where etv_id = 'VBB'
          and mtd_dedn_amount > 0   
          AND date_part('year',last_updt_dt) = date_part('year',elu.lastupdatets)
          and date_part('month',last_updt_dt) = date_part('month',elu.lastupdatets)
      )
      ;

(select individual_key, current_dedn_amount, etv_id
   from from pspay_deduction_accumulators 

--- med

(select individual_key, etv_id, sum(etv_amount) as etv_amount
         from pspay_payment_detail 
         LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'HMN_PS_CogDetGet_Export'
        where etv_id = 'VBC'
          AND date_part('year',check_date) = date_part('year',elu.lastupdatets)
          and date_part('month',check_date) = date_part('month',elu.lastupdatets)
          group by 1,2
      )
            
;
(select personid, coalesce(sum(etv_amount),0) as etv_amount
   from pspay_payment_detail ppd 
   join edi.edi_last_update elu on elu.feedid = 'HMN_PS_CogDetGet_Export' and date_part('year', check_date) = date_part('year',elu.lastupdatets::DATE) and date_part('month',check_date) = date_part('month',elu.lastupdatets::date)
   where paymentheaderid in 
        (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay
                             where ppay.pspaypayrollstatusid = 4 )))  and ppd.etv_id  in ('VBC')    
                               AND date_part('year', check_date) = date_part('year',elu.lastupdatets::DATE) 
                               and date_part('month',check_date) = date_part('month',elu.lastupdatets::date) ---- 1/4/2019 changed current_date to elu.lastupdatets::DATE
                             group by personid) 
;  


--- dnt
 (select personid, etv_id, sum(etv_amount) as etv_amount
         from pspay_payment_detail 
         LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'HMN_PS_CogDetGet_Export'
        where etv_id = 'VBD'
          AND date_part('year',check_date) = date_part('year',elu.lastupdatets)
          and date_part('month',check_date) = date_part('month',elu.lastupdatets)
          group by 1,2
      );

--- fsa
      (select personid, etv_id, sum(etv_amount) as etv_amount
         from pspay_payment_detail 
         LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'HMN_PS_CogDetGet_Export'
        where etv_id = 'VBA'
          AND date_part('year',check_date) = date_part('year',elu.lastupdatets)
          and date_part('month',check_date) = date_part('month',elu.lastupdatets)
          group by 1,2
      );

--- vsn
 (select individual_key, etv_id, sum(etv_amount) as etv_amount
         from pspay_payment_detail 
         LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'HMN_PS_CogDetGet_Export'
        where etv_id = 'VBE'
          AND date_part('year',check_date) = date_part('year',elu.lastupdatets)
          and date_part('month',check_date) = date_part('month',elu.lastupdatets)
          group by 1,2
      );


(select
 vsn.personid
,vsn.etv_amount
,vsn.individual_key
,vsn1.current_dedn_amount
from
(select personid, individual_key, etv_id, coalesce(sum(etv_amount),0) as etv_amount
   from pspay_payment_detail ppd 
   join edi.edi_last_update elu on elu.feedid = 'HMN_PS_CogDetGet_Export' and date_part('year', check_date) = date_part('year',elu.lastupdatets::DATE) and date_part('month',check_date) = date_part('month',elu.lastupdatets::date)
   where paymentheaderid in 
        (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay
                             where ppay.pspaypayrollstatusid = 4 )))  and ppd.etv_id  in ('VBE')    
                               AND date_part('year', check_date) = date_part('year',elu.lastupdatets::DATE) 
                               and date_part('month',check_date) = date_part('month',elu.lastupdatets::date) ---- 1/4/2019 changed current_date to elu.lastupdatets::DATE
                             group by personid, individual_key, etv_id) vsn 
  left join (select individual_key, current_dedn_amount, etv_id 
               from pspay_deduction_accumulators LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'HMN_PS_CogDetGet_Export'
              where etv_id = 'VBE' and mtd_dedn_amount > 0 AND date_part('year',last_updt_dt) = date_part('year',elu.lastupdatets) and date_part('month',last_updt_dt) = date_part('month',elu.lastupdatets)) vsn1 on vsn1.individual_key = vsn.individual_key and vsn1.etv_id = vsn.etv_id  
 ) 








(SELECT personid, compamount, increaseamount, compevent, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate, 
            RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
            FROM person_compensation pc1
            LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'HMN_PS_CogDetGet_Export'
            WHERE enddate > effectivedate 
              AND current_timestamp BETWEEN createts AND endts
              and increaseamount <> 0
              and effectivedate <= elu.lastupdatets::DATE
              and personid = '65711'
            GROUP BY personid, compamount, increaseamount, compevent )
            -- as lastcompdt on lastcompdt.personid = pe.personid and lastcompdt.rank = 1    
            ;
            
( 
      select personid, individual_key, sum(etv_amount) as shift_dif_amt 
      from pspay_payment_detail 
      LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'HMN_PS_CogDetGet_Export'
      where etv_id = 'E05'  
        --and date_part('year', check_date) = date_part('year',current_date)
        and check_date = ?::date
        --and etv_amount > 0
        group by 1,2
     )
 ;    
(select personid, individual_key, sum(etv_amount) as shift_dif_amt      
   from pspay_payment_detail ppd where paymentheaderid in 
        (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay join edi.edi_last_update elu 
                             on elu.feedid = 'HMN_PS_CogDetGet_Export' and elu.lastupdatets <= ppay.statusdate
                             where ppay.pspaypayrollstatusid = 4 )))  and ppd.etv_id  in  ('E05')
                             group by personid)    
                             ;


(select personid, sum(etv_amount) as shift_dif_amt from pspay_payment_detail ppd where paymentheaderid in 
        (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay join edi.edi_last_update elu on elu.feedid = 'HMN_PS_CogDetGet_Export' and elu.lastupdatets <= ppay.statusdate
                             where ppay.pspaypayrollstatusid = 4 )))  and ppd.etv_id  in  ('E05')
                             group by personid)
                             ;
(select personid, sum(etv_amount) as shift_dif_amt 
        from pspay_payment_detail where etv_id = 'E05' and check_date = ?::date  and etv_amount > 0 group by 1)
        ;                             
        
(select personid, etype_hours, etv_amount, max(check_date) as check_date, RANK() OVER (PARTITION BY personid ORDER BY MAX(check_date) DESC) AS RANK from pspay_payment_detail ppd where paymentheaderid in 
        (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay join edi.edi_last_update elu on elu.feedid = 'HMN_PS_CogDetGet_Export' and elu.lastupdatets <= ppay.statusdate
                             where ppay.pspaypayrollstatusid = 4 )))  and ppd.etv_id  in  ('E01')
                             group by personid, etype_hours, etv_amount)        
                             ;
(select personid, etype_hours, etv_amount, max(check_date) as check_date, RANK() OVER (PARTITION BY personid ORDER BY MAX(check_date) DESC) AS RANK
        from pspay_payment_detail where etv_id = 'E01' and etype_hours <> 0 group by 1,2,3)
        ;
-----------------------------------------         
----- f17_O12_shift_differential_rate 
----- f18_o13_ee_annual_salary 
-----------------------------------------       
left join 
(select distinct pe.personid, pn.lname||', '||pn.fname||','||COALESCE(left(pn.mname,1),'') ::char(30) as f5_emp_name 
       ,coalesce(to_char(round(((ppd05.shift_dif_amt / pp.scheduledhours) * pp.scheduledhours)/(pc.compamount/24),2),'00D9999'),'0.00')::char(12) as f17_O12_shift_differential_rate  
       ,case when pp.scheduledhours = 86.67 then to_char(((ppd05.shift_dif_amt / pp.scheduledhours) * (pp.scheduledhours * 24)) + pc.compamount,'00000000d00') else null end ::char(12) as f18_o13_ee_annual_salary 
   from person_employment pe
   join person_compensation pc 
     on pc.personid = pe.personid
    and current_date between pc.effectivedate and pc.enddate
    and current_timestamp between pc.createts and pc.endts
   join pers_pos pp
     on pp.personid = pe.personid
    and current_date between pp.effectivedate and pp.enddate
    and current_timestamp between pp.createts and pp.endts 

--- SHIFT DIF RATE
   left join (select personid, sum(etv_amount) as shift_dif_amt from pspay_payment_detail ppd where paymentheaderid in 
        (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay join edi.edi_last_update elu on elu.feedid = 'HMN_PS_CogDetGet_Export' and elu.lastupdatets <= ppay.statusdate
                             where ppay.pspaypayrollstatusid = 4 )))  and ppd.etv_id  in  ('E05')
                             group by personid) as ppd05 on ppd05.personid = pe.personid
join person_names pn
  on pn.personid = pe.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts
         
where pe.emplstatus = 'A'
  and current_date between pe.effectivedate and pe.enddate
  and current_timestamp between pe.createts and pe.endts
  order by f5_emp_name 
) sdr on sdr.personid = pe.personid                             


left join ( 
select distinct 
 pe.personid
,coalesce(to_char(round(((ppd05.shift_dif_amt / pp.scheduledhours) * ppd01.etype_hours)/(pc.compamount/24),2),'00D9999'),'0.00')::char(12) as f17_O12_shift_differential_rate 
,case when pp.scheduledhours = 86.67 then to_char(((ppd05.shift_dif_amt / pp.scheduledhours) * (pp.scheduledhours * 24)) + pc.compamount,'00000000d00') 
      else to_char(ppd05.shift_dif_amt / ppd01.etype_hours * pp.scheduledhours * 24 + pc.compamount,'00000000d00') end ::char(12) as f18_o13_ee_annual_salary 



,pn.lname||', '||pn.fname||','||COALESCE(left(pn.mname,1),'') ::char(30) as f5_emp_name 
from person_employment pe
join person_compensation pc 
  on pc.personid = pe.personid
 and current_date between pc.effectivedate and pc.enddate
 and current_timestamp between pc.createts and pc.endts
join pers_pos pp
  on pp.personid = pe.personid
 and current_date between pp.effectivedate and pp.enddate
 and current_timestamp between pp.createts and pp.endts 
join (select personid, etype_hours, etv_amount, max(check_date) as check_date, RANK() OVER (PARTITION BY personid ORDER BY MAX(check_date) DESC) AS RANK
        from pspay_payment_detail where etv_id = 'E01' and etype_hours <> 0 group by 1,2,3) as ppd01 on ppd01.personid = pe.personid and ppd01.rank = 1
--- SHIFT DIF RATE
join (select personid, sum(etv_amount) as shift_dif_amt 
        from pspay_payment_detail where etv_id = 'E05' and check_date = ?::date  and etv_amount > 0 group by 1) as ppd05 on  ppd05.personid = pe.personid
join person_names pn
  on pn.personid = pe.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts        
where pe.emplstatus = 'A'
  and current_date between pe.effectivedate and pe.enddate
  and current_timestamp between pe.createts and pe.endts
  --and pe.personid = '64831'
  order by f5_emp_name 
) sdr on sdr.personid = pe.personid