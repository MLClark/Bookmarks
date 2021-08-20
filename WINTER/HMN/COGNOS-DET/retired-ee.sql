select distinct
 pi.personid
,'WINTER RETIRED EES' ::CHAR(20) as sourceseq 
, coalesce(ytdcomp.taxable_wage,0) + coalesce(ytdhb.hiring_bonus,0) + coalesce(ytdls.lump_sum,0) + coalesce(ytdAb.ALL_bonus,0) + coalesce(ytdsev.severance_pay,0) + coalesce(ytdfica.fica,0) as exempt_criteria
,to_char(elu.lastupdatets,'yyyy') ::char(4) as f1_curyy
,to_char(elu.lastupdatets,'mm') ::char(2) as f2_cur_mm  
,occc.orgcode as f3_accounting_unit
,pie.identity as f4_empnbr 

,pn.lname||', '||pn.fname||', '||COALESCE(left(pn.mname,1),'') ::char(30) as f5_emp_name 

,jd.jobcode as f6_job_title_cd
,pd.positiontitle as f7_position_title
,sg.salarygradedesc as f8_job_family_code
,case when pd.flsacode = 'E' then 'Exempt' else 'Non-Exempt' END ::CHAR(10) as f9_flsa_code

-----“Emp Class” for Temp Employees to change from Part-Time to Temporary  (f10_o46_emp_class)  
,case when pe.emplclass = 'F' then 'Full Time' else 'Part Time' end ::char(10) as f10_o46_emp_class
-----“Emp Type” change from Permanent to Regular
,case when pe.emplpermanency = 'P' then 'Permanent' else 'Temporary' end ::char(10) as f11_o47_emp_type
-----Temp Employees "Sch Hrs " should be zero, 
,case when pc.compevent = 'Temp' then '00.00' else to_char(pp.scheduledhours,'00.00') end as f12_o49_scheduled_hours

,case when lc.locationcode = 'HO' then lc.locationcode  else 'FIELD' end ::varchar(10) as f13_o10_location
,lc.locationcode as f14_o50_location_desc
,' ' ::char(1) as f15_o51_remote_ind

,case when lc.salarygraderegion = '3' then 'A'   
      when lc.salarygraderegion = '4' then 'B'    
      when lc.salarygraderegion = '5' then 'C'  
      when lc.salarygraderegion = '6' then 'D'  
      when lc.salarygraderegion = '7' then 'E' 
       end ::char(1) as f16_o11_sgr_cognos_code 

,case when pc.compevent in ('Temp') then '00000000d00' 
      when sdr.f17_O12_shift_differential_rate is not null then sdr.f17_O12_shift_differential_rate else '0' end as f17_O12_shift_differential_rate         
----- f18_o13_ee_annual_salary   Temp Employees annual salary should be 0.  
----- shift workers annual salary will not necessarily match compensation shown in application. see sdr join for calculation                     
,case when pc.compevent = 'Temp' then '00000000d00' 
      when sdr.f18_o13_ee_annual_salary is not null then to_char(sdr.f18_o13_ee_annual_salary,'00000000d00') 
      else to_char(pc.compamount,'00000000d00')  end ::char(12) as f18_o13_ee_annual_salary 
----- f19_o14_pct_in_range comes from view personcomppercentinrange      
,case when pc.compevent in ('Temp') then '0.0000' 
      else to_char(round(coalesce(vpcpira.percent_in_range,0),4),'0d0000') end as f19_o14_pct_in_range
----- f20_o15_sal_change_date Use the last Compensation Effective Date where the increase amount is greater than zero
,case when pc.compevent in ('Temp') then ' ' 
      when pc.increaseamount <> 0 then to_char(pc.effectivedate,'mm/dd/yy') end ::char(8) as f20_o15_sal_change_date 
----- f21_o18_current_comp_chg_pct For Employees with a compensation event code of Hire or Rehire or Temp Conversion populate with .00
--,case when pc.compevent in ('TempConv','Temp','Hire','ReHire') then '0'
,case when pc.compevent in ('Temp') then ' '
      when (pc.compamount - pc.increaseamount) <> 0 then to_char(round((pc.increaseamount / (pc.compamount - pc.increaseamount)) * 100, 2 ),'0000.00') else '0'
      end as f21_o18_current_comp_chg_pct
----- f22_o19_comp_change_amount  For Employees with a compensation event code of Hire or Rehire or Temp Conversion populate with .00
--,case when pc.compevent in ('TempConv','Temp','Hire','ReHire') then '0'
,case when pc.compevent in ('Temp') then '0'
      else to_char(pc.increaseamount,'00000009d00') end ::char(12) as f22_o19_comp_change_amount

,case when pc.compevent = 'Add' then ' ' 
      when pc.compevent ilike ('%Adjust%') then 'AJ'
      when pc.compevent = 'Merit' then 'ME'
      when pc.compevent = 'BaseHr' then 'BH'
      when pc.compevent = 'Demo' then 'DM'
      when pc.compevent = 'Hire' then 'NH'
      when pc.compevent ilike ('%Rehire%') then 'RH'
      when pc.compevent ilike ('%Promo%') then 'PR'
      when pc.compevent = 'SalDec' then 'SE'
      when pc.compevent = 'Transfer' then 'TR'
      when pc.compevent = 'Actuarial' then 'AE'
      when pc.compevent ilike ('%Temp%') then 'TC'
      else pc.compevent end  as f23_o20_cognos_comp_code

----- f24_o21_prev_annual_salary For Employees with a compensation event code of Hire or Rehire or Temp Conversion populate with .00
--,case when pc.compevent in ('TempConv','Temp','Hire','ReHire') then '0'
,case when pc.compevent in ('Temp') then '0' 
      else to_char(coalesce((pc.compamount - pc.increaseamount),0),'00000000d00') end ::char(12)  as f24_o21_prev_annual_salary 

,case when pc.compevent in ('Temp') then ' ' else pufv3.ufvalue end as f25_o16_perf_review_desc
,case when pc.compevent in ('Temp') then ' ' 
      when pufv2.ufvalue in ('Y','Regular','Combined') then ' ' 
      when pufv2.ufvalue in ('1') then 'DE' 
      when pufv2.ufvalue in ('2') then 'GE' 
      when pufv2.ufvalue in ('3') then 'MS' 
      when pufv2.ufvalue in ('4') then 'EE' 
      when pufv2.ufvalue in ('5') then 'FE'    
      else pufv2.ufvalue end as f26_o17_perf_review_rating
      
,pe.emplstatus as f27_o26_emp_status   
,case when pe.emplstatus =  'A' then 'Acti'
      when pe.emplstatus =  'L' then 'LOA'
      when pe.emplstatus =  'T' and pe.emplevent = 'Retire' and ytdsev.severance_pay <> 0 then 'RWS' --RWOS if the Employment Event is Retirement and the employee has YTD Severance Pay zero (E30)
      when pe.emplstatus =  'T' and pe.emplevent = 'InvTerm' and ytdsev.severance_pay <> 0 then 'TWS' --RWOS if the Employment Event is Retirement and the employee has YTD Severance Pay zero (E30)
      when pe.emplstatus =  'T' and pe.emplevent = 'Retire' and ytdsev.severance_pay IS NULL  then 'RWOS' --RWOS if the Employment Event is Retirement and the employee has YTD Severance Pay zero (E30)
      when pe.emplstatus <> 'R' and pe.emplevent = 'Term' and ytdsev.severance_pay <> 0 then 'TWS' --TWS if the Employment Event is not Retirement and the employee has YTD Severance Pay not = zero  
      when pe.emplstatus =  'T' then 'TWOS' --TWOS if the Employment Event is not Retirement and the employee has YTD Severance Pay zero
      end ::char(4) as f28_o27_cognos_status
      
,to_char(pe.emplservicedate,'mm/dd/yy') ::char(8) as f29_o28_adj_hire_date ---- use service date
,case when pe.emplstatus = 'T' then to_char(cast(date_part('year',age(pe.emplservicedate,pe.effectivedate)) + (date_part('month',age(pe.emplservicedate,pe.effectivedate)) * .10) as dec (18,2))*-1,'00.0')
      else to_char(cast(date_part('year',age(current_date,pe.emplservicedate)) + (date_part('month',age(current_date,pe.emplservicedate)) * .10) as dec (18,2)),'00.0') end as f30_o29_years_of_service  
      
,to_char(pe.paythroughdate,'mm/dd/yy') ::char(8) as f31_pay_through_date 
,case when pe.emplstatus = 'T' then to_char(pe.effectivedate,'mm/dd/yy') else null end ::char(8) as f32_o32_term_date

,case when pe.emplstatus = 'L' then to_char(pe.effectivedate,'mm/dd/yy') 
      when leavest.emplstatus = 'L' then to_char(leavest.effectivedate,'mm/dd/yy') else null end ::char(8) as f33_o34_loa_begin_date
,case when pe.emplstatus = 'L' then null
      when  leavest.emplstatus = 'L' then to_char(leavest.enddate,'mm/dd/yy') else null end ::char(8) as f34_o35_loa_end_date
,case when leavest.emplstatus = 'L' then leavest.empleventdetcode else null end ::char(5) as f35_leave_event_code  
  
,to_char(pp.effectivedate,'mm/dd/yy')::char(8) as f36_o33_position_effective_date

,to_char(coalesce(ytdcomp.taxable_wage,0),'00000009d00') ::char(12) as f37_o23_ytd_cognos_gross_pay
,to_char(coalesce(ytdhb.hiring_bonus,0),'00000009d00') ::char(12) as f38_052_ytd_hiring_bonus
,to_char(coalesce(ytdls.lump_sum,0),'00000009d00') ::char(12) as f39_o45_ytd_lump_sum

,to_char(coalesce(TRUNC((ytdAb.ALL_bonus * .0620)+(ytdAb.ALL_bonus * .0145),2),0),'00000009d00') ::char(12) as f40_o24_ytd_fica_on_ytd_bonus_pay  
,to_char(cast(coalesce(TRUNC(ytdfica.fica -((ytdAb.ALL_bonus * .0620)+(ytdAb.ALL_bonus * .0145)),2),ytdfica.fica,0) as dec(10,2)),'00000009d00')
        ::char(12) as f41_o25_ytd_fica_less_ytd_fica_bonus_fica_sev
  
,case when pe.emplstatus =  'T' and pe.emplevent = 'Retire' and ytdsev.severance_pay is null then 'N'
      when pe.emplstatus =  'T' and pe.emplevent = 'Retire' and ytdsev.severance_pay > 0 then 'Y'
      when occc.orgcode  = '515110' then 'Y' else 'N' end ::char(1) as f42_o30_sev_ind

,to_char(ytdsev.severance_pay,'00000009d00') ::char(12) as f43_o40_ytd_cognos_sev_amt   
,to_char(TRUNC((ytdsev.severance_pay * .0620)+(ytdsev.severance_pay * .0145),2) ,'00000009d00') ::char(12) as f44_o41_ytd_fica_on_sev_pay
,'N' ::char(1) as f45_o31_ltip_bonus_pgm_ind    
,case when fjc.federaljobcode < '049' then 'OF'
      when fjc.federaljobcode in ('049','050','051') then 'DR'
      else 'CAP' end ::char(3) as f46_o36_officer_code     

,to_char(dpc.etv_amount *-1,'00000009d00') ::char(12) as f47_o22_dep_care_monthly_ded_amt
,to_char(med.etv_amount *-1,'00000009d00') ::char(12) as f48_o37_medical_monthly_ded_amt
,to_char(dnt.etv_amount *-1,'00000009d00') ::char(12) as f49_o38_dental_monthly_ded_amt
,to_char(fsa.etv_amount *-1,'00000009d00') ::char(12) as f50_o39_fsa_monthly_ded_amt
,to_char(vsn.etv_amount *-1,'00000009d00') ::char(12) as f51_o42_vision_monthly_ded_amt
,to_char(hsa.etv_amount *-1,'00000009d00') ::char(12) as f52_o43_hsa_monthly_ded_amt
,to_char(hcu.etv_amount *-1,'00000009d00') ::char(12) as f53_o44_hsa_cu_monthly_ded_amt

,elu.lastupdatets

from person_identity pi

LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'HMN_PS_CogDetGet_Export'

join person_identity pie
  on pie.personid = pi.personid
 and pie.identitytype = 'EmpNo'
 and current_timestamp between pie.createts and pie.endts
 
join person_identity pip
  on pip.personid = pi.personid
 and pip.identitytype = 'PSPID'
 and current_timestamp between pip.createts and pip.endts
  
join person_employment pe
  on pe.personid = pi.personid
 and elu.lastupdatets::DATE between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts
 and pe.effectivedate <= elu.lastupdatets::DATE 
 
join person_names pn
  on pn.personid = pe.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts 

left join (SELECT personid, emplstatus, emplevent,  empleventdetcode, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate, RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
            FROM person_employment pe1
           WHERE enddate > effectivedate AND current_timestamp BETWEEN createts AND endts and emplstatus = 'L'  and enddate <= current_date
           GROUP BY personid, emplstatus, emplevent, empleventdetcode ) leavest on leavest.rank = 1 and leavest.personid = pe.personid


----- Last compensation date and increase amount
left join (SELECT personid, compamount, increaseamount, compevent, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate, RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             FROM person_compensation pc1  LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'HMN_PS_CogDetGet_Export'
            WHERE enddate > effectivedate AND current_timestamp BETWEEN createts AND endts and increaseamount <> 0 and effectivedate <= elu.lastupdatets::DATE
            GROUP BY personid, compamount, increaseamount, compevent ) as lastcompdt on lastcompdt.personid = pe.personid and lastcompdt.rank = 1    

----------------------------------------------------- 
----- Last compensation date and increase amount
----- f12_o49_scheduled_hours
----- f21_o18_current_comp_chg_pct      
----- f20_o15_sal_change_date 
----- f22_o19_comp_change_amount
----- f23_o20_cognos_comp_code
----- f24_o21_prev_annual_salary
----- f25_o16_perf_review_desc
----------------------------------------------------- 
left join (select personid, compamount, frequencycode, earningscode, compevent, increaseamount, createts, effectivedate, enddate, RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_compensation LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'HMN_PS_CogDetGet_Export'
            WHERE enddate > effectivedate AND current_timestamp BETWEEN createts AND endts and effectivedate <= elu.lastupdatets::DATE ---and compevent not in ('BaseHr')
            group by personid, compamount, frequencycode, earningscode, compevent, increaseamount, createts, effectivedate, enddate) pc on pc.personid = pe.personid and pc.rank = 1 
----------------------------------------------------- 
----- Percent In Range 
----- f19_o14_pct_in_range
----------------------------------------------------- 
left join (select a.*
            from personcomppercentinrangeasof a
            join person_employment pe 
              on pe.personid = a.personid
             and pe.emplstatus = 'T' 
           where asofdate = pe.effectivedate - interval '1 day') as vpcpira on vpcpira.personid = pc.personid and vpcpira.earningscode = pc.earningscode

----- Position Organization Joins
left join  (select personid, positionid, scheduledhours, schedulefrequency, max(effectivedate) as effectivedate, RANK() OVER (PARTITION BY personid ORDER BY max(effectivedate) DESC) AS RANK
              from pers_pos where effectivedate < enddate and current_timestamp between createts and endts
             group by personid, positionid, scheduledhours, schedulefrequency) pp on pp.personid = pe.personid and pp.rank = 1

left join pos_org_rel porb 
  ON porb.positionid = pp.positionid 
 AND porb.posorgreltype = 'Budget' 
 and current_date between porb.effectivedate and porb.enddate
 and current_timestamp between porb.createts and porb.endts

left join organization_code occc
  ON occc.organizationid = porb.organizationid
 AND occc.organizationtype = 'CC'
 and current_date between occc.effectivedate and occc.enddate
 and current_timestamp between occc.createts and occc.endts   

left join (select positionid, grade, positiontitle, flsacode, max(effectivedate) as effectivedate, RANK() OVER (PARTITION BY positionid ORDER BY max(effectivedate) DESC) AS RANK
             from position_desc where effectivedate < enddate and current_timestamp between createts and endts 
            group by positionid, grade, positiontitle,flsacode) pd on pd.positionid = pp.positionid and pd.rank = 1

left join salary_grade sg
  on sg.grade = pd.grade
 and current_date between sg.effectivedate and sg.enddate
 and current_timestamp between sg.createts and sg.endts 

left join position_job pj
  on pj.positionid = pd.positionid
 and pj.effectivedate < pj.enddate
 and current_timestamp between pj.createts and pj.endts
 
left join job_desc jd
  on jd.jobid = pj.jobid
 and jd.effectivedate < jd.enddate 
 and current_timestamp between jd.createts and jd.endts 

left join federal_job_code fjc
  on fjc.federaljobcodeid = jd.federaljobcodeid
 
left join person_locations pl
  on pl.personid = pp.personid
 and current_date between pl.effectivedate and pl.enddate
 and current_timestamp between pl.createts and pl.endts 

left join location_codes lc
  on lc.locationid = pl.locationid
 and current_date between lc.effectivedate and lc.enddate
 and current_timestamp between lc.createts and lc.endts    
  	
left join person_user_field_vals pufv2
  on pufv2.personid = pe.personid
-- and pufv2.persufpid = '2'
 and char_length(pufv2.ufvalue) = 1  
 and pufv2.ufvalue not in ('Y','N',' ')
 and current_date between pufv2.effectivedate and pufv2.enddate
 and current_timestamp between pufv2.createts and pufv2.endts
  
left join person_user_field_vals pufv3
  on pufv3.personid = pe.personid
 --and pufv3.persufpid = '3'
 and char_length(pufv3.ufvalue) > 10 
 and current_date between pufv3.effectivedate and pufv3.enddate
 and current_timestamp between pufv3.createts and pufv3.endts 
 
-----------------------------------------
----- Shift diff rates         
----- f17_O12_shift_differential_rate 
----- f18_o13_ee_annual_salary 
-----------------------------------------       

left join 
(select distinct pe.personid, pes.amount as pes_rate, ppd05.shift_dif_amt 
       ,case when pes.amount <> 0 then to_char(pes.amount/100,'00D9999') 
             when pes.amount =  0 then coalesce(to_char(round(((ppd05.shift_dif_amt / pp.scheduledhours) * pp.scheduledhours)/(pc.compamount/24),2),'00D9999'),'0.00') end ::char(12) as f17_O12_shift_differential_rate  
       ,case when pp.scheduledhours = 86.67 and pes.amount <> 0 then (((pes.amount/100) * pc.compamount ) + pc.compamount)
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
                        (select pspaypayrollid from pspay_payroll ppay join edi.edi_last_update elu on elu.feedid = 'HMN_PS_CogDetGet_Export' 
                                                                        ------and elu.lastupdatets <= ppay.statusdate
                               AND date_part('year', ppay.statusdate) = date_part('year', elu.lastupdatets::DATE) 
                               and date_part('month',ppay.statusdate) = date_part('month',elu.lastupdatets::date) 
                                                                        
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
) sdr on sdr.personid = pe.personid   

-----------------------------------------
----- Payrolll Joins 
----------------------------------------- 
----- YTD COMP 
----- f37_o23_ytd_cognos_gross_pay
----- Note on YTD - on the 1/1/2021 the lastupdatets will be 12/31/2020 
----------------------------------------- 
LEFT JOIN (select personid, 'Y' as eligible_flag, coalesce(sum(etv_amount),0) as taxable_wage      
   from pspay_payment_detail ppd 
   join edi.edi_last_update elu on elu.feedid = 'HMN_PS_CogDetGet_Export'
   where paymentheaderid in 
        (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay
                             where ppay.pspaypayrollstatusid = 4 )))  and ppd.etv_id  in  
                                 ('EBD','E01','E64','EB5','E05','EB8','E15','E16','E17','E18','E19','E20'
                                 ,'ECA','EAJ','EAR','EB4','EAK','ECH','E27','ECJ','E08','ECI') --- 12/3/2020 add ECI parental leave--10/13/2020 added E08 RetroPay 
                               AND date_part('year', check_date) = date_part('year',elu.lastupdatets::DATE) ---- 1/4/2019 changed current_date to elu.lastupdatets::DATE
                             group by personid, eligible_flag)  ytdcomp  ON ytdcomp.personid = pi.personid  
----------------------------------------- 
----- YTD SEVERENCE PAY
----- f43_o40_ytd_cognos_sev_amt 
----- f44_o41_ytd_fica_on_sev_pay
----------------------------------------- 
LEFT JOIN (select personid, coalesce(sum(etv_amount),0) as severance_pay
   from pspay_payment_detail ppd 
   join edi.edi_last_update elu on elu.feedid = 'HMN_PS_CogDetGet_Export' and date_part('year', check_date) = date_part('year',elu.lastupdatets::DATE)
   where paymentheaderid in 
        (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay
                             where ppay.pspaypayrollstatusid = 4 )))  and ppd.etv_id  in  ('E30')
                               AND date_part('year', check_date) = date_part('year',elu.lastupdatets::DATE) ---- 1/4/2019 changed current_date to elu.lastupdatets::DATE
                             group by personid)  ytdsev ON ytdsev.personid = pi.personid  
--------------------------------
----- YTD HIRING BONUS 
----- f38_052_ytd_hiring_bonus
--------------------------------
LEFT JOIN (select personid, coalesce(sum(etv_amount),0) as hiring_bonus
   from pspay_payment_detail ppd 
   join edi.edi_last_update elu on elu.feedid = 'HMN_PS_CogDetGet_Export' and date_part('year', check_date) = date_part('year',elu.lastupdatets::DATE)
   where paymentheaderid in 
        (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay
                             where ppay.pspaypayrollstatusid = 4 )))  and ppd.etv_id  in  ('E64') 
                               AND date_part('year', check_date) = date_part('year',elu.lastupdatets::DATE) ---- 1/4/2019 changed current_date to elu.lastupdatets::DATE
                             group by personid)  ytdhb  ON ytdhb.personid = pi.personid    
---------------------------------
----- YTD LUMP SUM
----- f39_o45_ytd_lump_sum
---------------------------------
LEFT JOIN (select personid, coalesce(sum(etv_amount),0) as lump_sum
   from pspay_payment_detail ppd 
   join edi.edi_last_update elu on elu.feedid = 'HMN_PS_CogDetGet_Export' and date_part('year', check_date) = date_part('year',elu.lastupdatets::DATE)
   where paymentheaderid in 
        (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay
                             where ppay.pspaypayrollstatusid = 4 )))  and ppd.etv_id  in  ('ECA') 
                               AND date_part('year', check_date) = date_part('year',elu.lastupdatets::DATE) ---- 1/4/2019 changed current_date to elu.lastupdatets::DATE
                             group by personid) ytdls ON ytdls.personid = pi.personid               
-----------------------------------------
----- YTD ALL BONUS
----- f40_o24_ytd_fica_on_ytd_bonus_pay  
-----------------------------------------
LEFT JOIN (select personid, coalesce(sum(etv_amount),0) as ALL_bonus
   from pspay_payment_detail ppd 
   join edi.edi_last_update elu on elu.feedid = 'HMN_PS_CogDetGet_Export' and date_part('year', check_date) = date_part('year',elu.lastupdatets::DATE)
   where paymentheaderid in 
        (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay
                             where ppay.pspaypayrollstatusid = 4 )))  and ppd.etv_id  in  ('E61','EA1','EB1','EBE','EBH','EA2','EBI')  
                               AND date_part('year', check_date) = date_part('year',elu.lastupdatets::DATE) ---- 1/4/2019 changed current_date to elu.lastupdatets::DATE
                             group by personid) ytdAb ON ytdAb.personid = pi.personid            
------------------------------------------------------
----- YTD FICA
----- f41_o25_ytd_fica_less_ytd_fica_bonus_fica_sev
------------------------------------------------------
LEFT JOIN (select personid, coalesce(sum(etv_amount),0) as fica
   from pspay_payment_detail ppd 
   join edi.edi_last_update elu on elu.feedid = 'HMN_PS_CogDetGet_Export' and date_part('year', check_date) = date_part('year',elu.lastupdatets::DATE)
   where paymentheaderid in 
        (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay
                             where ppay.pspaypayrollstatusid = 4 )))  and ppd.etv_id  in ('T01','T13')    
                               AND date_part('year', check_date) = date_part('year',elu.lastupdatets::DATE) ---- 1/4/2019 changed current_date to elu.lastupdatets::DATE
                             group by personid) ytdfica ON ytdfica.personid = pi.personid  
-----------------------------------------
----- MTD dependent care
----- f47_o22_dep_care_monthly_ded_amt
-----------------------------------------
left join
(select personid, etv_id, coalesce(sum(etv_amount),0) as etv_amount
   from pspay_payment_detail ppd 
   join edi.edi_last_update elu on elu.feedid = 'HMN_PS_CogDetGet_Export' and date_part('year', check_date) = date_part('year',elu.lastupdatets::DATE) and date_part('month',check_date) = date_part('month',elu.lastupdatets::date)
   where paymentheaderid in 
        (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay
                             where ppay.pspaypayrollstatusid = 4 )))  and ppd.etv_id  in ('VBB')    
                               AND date_part('year', check_date) = date_part('year', elu.lastupdatets::DATE) 
                               and date_part('month',check_date) = date_part('month',elu.lastupdatets::date) ---- 1/4/2019 changed current_date to elu.lastupdatets::DATE
                             group by personid, etv_id) dpc on dpc.personid = pi.personid
----------------------------------------------------     
----- MTD med
----- f48_o37_medical_monthly_ded_amt
----------------------------------------------------
left join
(select personid, etv_id, coalesce(sum(etv_amount),0) as etv_amount
   from pspay_payment_detail ppd 
   join edi.edi_last_update elu on elu.feedid = 'HMN_PS_CogDetGet_Export' and date_part('year', check_date) = date_part('year',elu.lastupdatets::DATE) and date_part('month',check_date) = date_part('month',elu.lastupdatets::date)
   where paymentheaderid in 
        (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay
                             where ppay.pspaypayrollstatusid = 4 )))  and ppd.etv_id  in ('VBC')    
                               AND date_part('year', check_date) = date_part('year', elu.lastupdatets::DATE) 
                               and date_part('month',check_date) = date_part('month',elu.lastupdatets::date) ---- 1/4/2019 changed current_date to elu.lastupdatets::DATE
                             group by personid, etv_id) med on med.personid = pi.personid  
----------------------------------------------------
----- MTD dental
----- f49_o38_dental_monthly_ded_amt
----------------------------------------------------
left join
(select personid, etv_id, coalesce(sum(etv_amount),0) as etv_amount
   from pspay_payment_detail ppd 
   join edi.edi_last_update elu on elu.feedid = 'HMN_PS_CogDetGet_Export' and date_part('year', check_date) = date_part('year',elu.lastupdatets::DATE) and date_part('month',check_date) = date_part('month',elu.lastupdatets::date)
   where paymentheaderid in 
        (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay
                             where ppay.pspaypayrollstatusid = 4 )))  and ppd.etv_id  in ('VBD')    
                               AND date_part('year', check_date) = date_part('year', elu.lastupdatets::DATE) 
                               and date_part('month',check_date) = date_part('month',elu.lastupdatets::date) ---- 1/4/2019 changed current_date to elu.lastupdatets::DATE
                             group by personid, etv_id) dnt  on dnt.personid = pi.personid    
----------------------------------------------------
----- MTD fsa 
----- f50_o39_fsa_monthly_ded_amt
----------------------------------------------------
left join
(select personid, etv_id, coalesce(sum(etv_amount),0) as etv_amount
   from pspay_payment_detail ppd 
   join edi.edi_last_update elu on elu.feedid = 'HMN_PS_CogDetGet_Export' and date_part('year', check_date) = date_part('year',elu.lastupdatets::DATE) and date_part('month',check_date) = date_part('month',elu.lastupdatets::date)
   where paymentheaderid in 
        (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay
                             where ppay.pspaypayrollstatusid = 4 )))  and ppd.etv_id  in ('VBA')    
                               AND date_part('year', check_date) = date_part('year', elu.lastupdatets::DATE) 
                               and date_part('month',check_date) = date_part('month',elu.lastupdatets::date) ---- 1/4/2019 changed current_date to elu.lastupdatets::DATE
                             group by personid, etv_id) fsa on fsa.personid = pi.personid
----------------------------------------------------
----- MTD vision    
----- f51_o42_vision_monthly_ded_amt
----------------------------------------------------
left join
(select personid, etv_id, coalesce(sum(etv_amount),0) as etv_amount
   from pspay_payment_detail ppd 
   join edi.edi_last_update elu on elu.feedid = 'HMN_PS_CogDetGet_Export' and date_part('year', check_date) = date_part('year',elu.lastupdatets::DATE) and date_part('month',check_date) = date_part('month',elu.lastupdatets::date)
   where paymentheaderid in 
        (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay
                             where ppay.pspaypayrollstatusid = 4 )))  and ppd.etv_id  in ('VBE')    
                               AND date_part('year', check_date) = date_part('year', elu.lastupdatets::DATE) 
                               and date_part('month',check_date) = date_part('month',elu.lastupdatets::date) ---- 1/4/2019 changed current_date to elu.lastupdatets::DATE
                             group by personid, etv_id) vsn  on vsn.personid = pi.personid       
----------------------------------------------------  
----- MTD hsa
----- f52_o43_hsa_monthly_ded_amt
----------------------------------------------------
left join
(select personid, etv_id, coalesce(sum(etv_amount),0) as etv_amount
   from pspay_payment_detail ppd 
   join edi.edi_last_update elu on elu.feedid = 'HMN_PS_CogDetGet_Export' and date_part('year', check_date) = date_part('year',elu.lastupdatets::DATE) and date_part('month',check_date) = date_part('month',elu.lastupdatets::date)
   where paymentheaderid in 
        (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay
                             where ppay.pspaypayrollstatusid = 4 )))  and ppd.etv_id  in ('VEH')    
                               AND date_part('year', check_date) = date_part('year', elu.lastupdatets::DATE) 
                               and date_part('month',check_date) = date_part('month',elu.lastupdatets::date) ---- 1/4/2019 changed current_date to elu.lastupdatets::DATE
                             group by personid, etv_id) hsa on hsa.personid = pi.personid
----------------------------------------------------  
----- MTD hsa cu
----- f53_o44_hsa_cu_monthly_ded_amt
----------------------------------------------------
left join (select personid, coalesce(sum(etv_amount),0) as etv_amount
   from pspay_payment_detail ppd 
   join edi.edi_last_update elu on elu.feedid = 'HMN_PS_CogDetGet_Export' and date_part('year', check_date) = date_part('year',elu.lastupdatets::DATE) and date_part('month',check_date) = date_part('month',elu.lastupdatets::date)
   where paymentheaderid in 
        (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay
                             where ppay.pspaypayrollstatusid = 4 )))  and ppd.etv_id  in ('VEJ')    
                               AND date_part('year', check_date) = date_part('year', elu.lastupdatets::DATE) 
                               and date_part('month',check_date) = date_part('month',elu.lastupdatets::date) ---- 1/4/2019 changed current_date to elu.lastupdatets::DATE
                             group by personid)  hcu on hcu.personid = pi.personid   
 	
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  and pe.emplstatus = 'T' 
  and pe.emplevent = 'Retire'
  and pd.positiontitle <> ('Agent')  
  
  And (date_part('year',pe.effectivedate) >= date_part('year',current_date - interval '1 year') OR
         coalesce(ytdcomp.taxable_wage,0) + coalesce(ytdhb.hiring_bonus,0) + coalesce(ytdls.lump_sum,0) + coalesce(ytdAb.ALL_bonus,0) + coalesce(ytdsev.severance_pay,0) + coalesce(ytdfica.fica,0) > 0
          )
  --and pe.personid = '62986'
