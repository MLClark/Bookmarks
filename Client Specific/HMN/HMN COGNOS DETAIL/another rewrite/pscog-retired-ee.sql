select distinct
 pi.personid
,'60 RETIRED EES' ::CHAR(20) as sourceseq 
--,pp.positionid
--,maxpos.perspospid
--,maxpd.positiondescpid


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

-----Temp Employees “Sch Hrs “ should be zero, 
,case when pc.compevent = 'Temp' then '00.00' else to_char(pp.scheduledhours,'00.00') end as f12_o49_scheduled_hours

,case when lc.locationcode = 'HO' then lc.locationcode  else 'FIELD' end ::varchar(10) as f13_o10_location
,lc.locationcode ::varchar(10) as f14_o50_location_desc
,' ' ::char(1) as f15_o51_remote_ind
,case when lc.locationcode = 'HO'      then 'A'
      when lc.locationcode = 'Area A'  then 'A'
      when lc.locationcode = 'Raleigh' then 'A' 
      when lc.locationcode = 'Dallas'  then 'A' 
      when lc.locationcode = 'Area B'  then 'B'
      when lc.locationcode = 'Area C'  then 'C'
      when lc.locationcode = 'Area D'  then 'D'
       end ::char(1) as f16_o11_sgr_cognos_code


,case when pc.compevent = 'Temp' then '00000000d00' 
      when sdr.f17_O12_shift_differential_rate is not null then sdr.f17_O12_shift_differential_rate else '0' end as f17_O12_shift_differential_rate         
-----Temp Employees annual salary appears to be showing (guessing) the hourly rate, this should be 0, .  (f18_o13_ee_annual_salary).                   
,case when pc.compevent = 'Temp' then '00000000d00' 
      when sdr.f18_o13_ee_annual_salary is not null then sdr.f18_o13_ee_annual_salary 
      else to_char(pc.compamount,'00000000d00')  end ::char(12) as f18_o13_ee_annual_salary 
,case when pc.compevent = 'Temp' then '0.0000' else to_char(round(coalesce(vpcpira.percent_in_range,0),4),'0d0000') end as f19_o14_pct_in_range

--,to_char(pc.effectivedate,'mm/dd/yy') as f20_o15_sal_change_date 
,to_char(lastcompdt.effectivedate,'mm/dd/yy') ::char(8) as f20_o15_sal_change_date 

,case when pc.compevent in ('Temp') then '0' 
      when (pc.compamount - pc.increaseamount) <> 0 
      then to_char(round((pc.increaseamount / (pc.compamount - pc.increaseamount)) * 100, 2 ),'0000.00')
      end as f21_o18_current_comp_chg_pct

,case when pc.compevent in ('Temp') then '0' else to_char(lastcompdt.increaseamount,'00000009d00') end ::char(12) as f22_o19_comp_change_amount

,case when pc.compevent = 'Add' then ' ' 
      when pc.compevent = 'Merit' then 'ME'
      when pc.compevent = 'Adjustment' then 'AJ'
      when pc.compevent = 'Adjust' then 'AJ'
      when pc.compevent = 'BaseHr' then 'BH'
      when pc.compevent = 'Demo' then 'DM'
      when pc.compevent = 'Hire' then 'NH'
      when pc.compevent = 'Rehire' then 'RH'
      when pc.compevent = 'ReHire' then 'RH'
      when pc.compevent = 'Promo' then 'PR'
      when pc.compevent = 'PROMO' then 'PR'
      when pc.compevent = 'SalDec' then 'SE'
      when pc.compevent = 'Transfer' then 'TR'
      when pc.compevent = 'Actuarial' then 'AE'
      when pc.compevent = 'Temp' then 'TC'
      else pc.compevent end  as f23_o20_cognos_comp_code

,case when pc.compevent in ('Temp') then '0' 
      else to_char(coalesce((pc.compamount - lastcompdt.increaseamount),0),'00000000d00') end ::char(12) as f24_o21_prev_annual_salary 

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
,case when pe.emplstatus = 'T' then 
           to_char(cast(date_part('year',age(pe.emplservicedate,pe.effectivedate)) + (date_part('month',age(pe.emplservicedate,pe.effectivedate)) * .10) as dec (18,2))*-1,'00.0')
      else to_char(cast(date_part('year',age(current_date,pe.emplservicedate)) + (date_part('month',age(current_date,pe.emplservicedate)) * .10) as dec (18,2)),'00.0') end 
      as f30_o29_years_of_service  
      
,to_char(pe.paythroughdate,'mm/dd/yy') ::char(8) as f31_pay_through_date 
,case when pe.emplstatus = 'T' then to_char(pe.effectivedate,'mm/dd/yy') else null end ::char(8) as f32_o32_term_date

,case when pe.emplstatus = 'L' then to_char(pe.effectivedate,'mm/dd/yy') 
      when leavest.emplstatus = 'L' then to_char(leavest.effectivedate,'mm/dd/yy') else null end ::char(8) as f33_o34_loa_begin_date
,case when pe.emplstatus = 'L' then null
      when  leavest.emplstatus = 'L' then to_char(leavest.enddate,'mm/dd/yy') else null end ::char(8) as f34_o35_loa_end_date
,case when leavest.emplstatus = 'L' then leavest.empleventdetcode else null end ::char(5) as f35_leave_event_code  

--,case when pe.emplstatus = 'L' then to_char(pe.effectivedate,'mm/dd/yy') else null end ::char(8) as f33_o34_loa_begin_date
--,case when pe.emplstatus = 'L' and pe.enddate < '2199-12-31' then to_char(pe.enddate,'mm/dd/yy') else null end ::char(8) as f34_o35_loa_end_date
--,case when pe.emplstatus IN ('L') then pe.emplstatus else null end ::char(1) as f35_leave_event_code    
,to_char(pp.effectivedate,'mm/dd/yy')::char(8) as f36_o33_position_effective_date

,to_char(coalesce(ytdcomp.taxable_wage,0),'00000009d00') ::char(12) as f37_o23_ytd_cognos_gross_pay
,to_char(coalesce(ytdhb.hiring_bonus,0),'00000009d00') ::char(12) as f38_052_ytd_hiring_bonus
,to_char(coalesce(ytdls.lump_sum,0),'00000009d00') ::char(12) as f39_o45_ytd_lump_sum

,to_char(coalesce(TRUNC((ytdAb.ALL_bonus * .0620)+(ytdAb.ALL_bonus * .0145),2),0),'00000009d00') ::char(12) as f40_o24_ytd_fica_on_ytd_bonus_pay  
,to_char(cast(coalesce(TRUNC(ytdfica.fica -((ytdAb.ALL_bonus * .0620)+(ytdAb.ALL_bonus * .0145)),2),ytdfica.fica,0) as dec(10,2)),'00000009d00')
        ::char(12) as f41_o25_ytd_fica_less_ytd_fica_bonus_fica_sev
        
  
,case 
      when pe.emplstatus =  'T' and pe.emplevent = 'Retire' and ytdsev.severance_pay is null then 'N'
      when pe.emplstatus =  'T' and pe.emplevent = 'Retire' and ytdsev.severance_pay > 0 then 'Y'
      when occc.orgcode  = '515110' then 'Y'
      else 'N' end ::char(1) as f42_o30_sev_ind

,to_char(ytdsev.severance_pay,'00000009d00') ::char(12) as f43_o40_ytd_cognos_sev_amt   
,to_char(TRUNC((ytdsev.severance_pay * .0620)+(ytdsev.severance_pay * .0145),2) ,'00000009d00') ::char(12) as f44_o41_ytd_fica_on_sev_pay
,'N' ::char(1) as f45_o31_ltip_bonus_pgm_ind    
,case when fjc.federaljobcode < '049' then 'OF'
      when fjc.federaljobcode in ('049','050','051') then 'DR'
      else 'CAP' end ::char(3) as f46_o36_officer_code     

,to_char(coalesce(dpc1.current_dedn_amount ,dpc.etv_amount )*-1 ,'00000009d00') ::char(12) as f47_o22_dep_care_monthly_ded_amt
,to_char(coalesce(med1.current_dedn_amount ,med.etv_amount )*-1 ,'00000009d00') ::char(12) as f48_o37_medical_monthly_ded_amt
,to_char(coalesce(dnt1.current_dedn_amount ,dnt.etv_amount )*-1 ,'00000009d00') ::char(12) as f49_o38_dental_monthly_ded_amt
,to_char(coalesce(fsa1.current_dedn_amount ,fsa.etv_amount )*-1 ,'00000009d00') ::char(12) as f50_o39_fsa_monthly_ded_amt
,to_char(coalesce(vsn1.current_dedn_amount ,vsn.etv_amount )*-1 ,'00000009d00') ::char(12) as f51_o42_vision_monthly_ded_amt
,to_char(coalesce(hsa1.current_dedn_amount ,hsa.etv_amount )*-1 ,'00000009d00') ::char(12) as f52_o43_hsa_monthly_ded_amt
,to_char(coalesce(hcu1.current_dedn_amount ,hcu.etv_amount )*-1 ,'00000009d00') ::char(12) as f53_o44_hsa_cu_monthly_ded_amt

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
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts
 and pe.effectivedate <= elu.lastupdatets::DATE  

left join (select personid, max(percomppid) as percomppid
             from person_compensation 
             LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'HMN_PS_CogDetGet_Export'
             where effectivedate <= elu.lastupdatets::DATE
             group by 1 ) as maxpc on maxpc.personid = pe.personid

left join (SELECT personid, emplstatus, emplevent,  empleventdetcode, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate, 
            RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
            FROM person_employment pe1
            WHERE enddate > effectivedate 
                   AND current_timestamp BETWEEN createts AND endts
                   and emplstatus = 'L'
                   and enddate <= current_date
            GROUP BY personid, emplstatus, emplevent, empleventdetcode ) leavest on leavest.rank = 1 and leavest.personid = pe.personid


----- Last compensation date and increase amount
left join 

(SELECT personid, compamount, increaseamount, compevent, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate, 
            RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
            FROM person_compensation pc1
            LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'HMN_PS_CogDetGet_Export'
            WHERE enddate > effectivedate 
              AND current_timestamp BETWEEN createts AND endts
              and increaseamount <> 0
              and effectivedate <= elu.lastupdatets::DATE
            GROUP BY personid, compamount, increaseamount, compevent ) as lastcompdt on lastcompdt.personid = pe.personid and lastcompdt.rank = 1    

left join person_compensation pc
  on pc.personid = maxpc.personid
 and pc.percomppid = maxpc.percomppid
 --and current_date between pc.effectivedate and pc.enddate
 and current_timestamp between pc.createts and pc.endts 
 and pc.effectivedate <= elu.lastupdatets::DATE
   
join person_names pn
  on pn.personid = pe.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts

left join (select personid, max(perspospid) as perspospid 
             from pers_pos
             LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'HMN_PS_CogDetGet_Export' 
             where current_timestamp between createts and endts
             and effectivedate <= elu.lastupdatets::DATE
             --and personid = '63840'
            group by 1) as maxpos on maxpos.personid = pe.personid

left join pers_pos pp 
  on pp.personid = maxpos.personid
 and pp.perspospid = maxpos.perspospid
 --and current_date between pp.effectivedate and pp.enddate
 and current_timestamp between pp.createts and pp.endts 
 and pp.effectivedate <= elu.lastupdatets::DATE

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

left join (select a.*
            from personcomppercentinrangeasof a
            join person_employment pe 
              on pe.personid = a.personid
             and pe.emplstatus = 'T' 
           where asofdate = pe.effectivedate - interval '1 day') as vpcpira on vpcpira.personid = pc.personid and vpcpira.earningscode = pc.earningscode

left join (select positionid, max(positiondescpid) as positiondescpid
             from position_desc 
            --where current_timestamp between createts and endts
            group by 1) maxpd on maxpd.positionid = pp.positionid          

left join position_desc pd
  on pd.positionid = maxpd.positionid
 and pd.positiondescpid = maxpd.positiondescpid
 --and current_date between pd.effectivedate and pd.enddate
 --and current_timestamp between pd.createts and pd.endts  
 
 left join salary_grade sg
  on sg.grade = pd.grade
 and current_date between sg.effectivedate and sg.enddate
 and current_timestamp between sg.createts and sg.endts 

left join position_job pj
  on pj.positionid = maxpd.positionid
 --and current_date between pj.effectivedate and pj.enddate
 and current_timestamp between pj.createts and pj.endts
 and pj.effectivedate < pj.enddate
 
left join job_desc jd
  on jd.jobid = pj.jobid
 --and current_date between jd.effectivedate and jd.enddate
 and current_timestamp between jd.createts and jd.endts 
 and jd.effectivedate < jd.enddate 

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
 
--- SHIFT DIF RATE
/* left join ( 
      select personid, individual_key, sum(etv_amount) as shift_dif_amt 
      from pspay_payment_detail 
      LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'HMN_PS_CogDetGet_Export'
      where etv_id = 'E05'  
        --and date_part('year', check_date) = date_part('year',current_date)
        and check_date = ?::date
        and etv_amount > 0
        group by 1,2
     ) sdrate 
  on sdrate.individual_key = pip.identity  */
  
--- SHIFT DIF RATE
left join (   
select personid, etv_amount as shift_dif_amt, max(check_date) as check_date,
RANK() OVER (PARTITION BY personid ORDER BY MAX(check_date) DESC) AS RANK   
from pspay_payment_detail where etv_id = 'E05' group by 1,2 ) sdrate on sdrate.personid = pi.personid and sdrate.rank = 1

--- YTD COMP
LEFT JOIN (SELECT personid
                  ,'Y' as eligible_flag 
                 ,coalesce(sum(etv_amount),0) as taxable_wage
             FROM pspay_payment_detail  
             LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'HMN_PS_CogDetGet_Export'          
            WHERE etv_id in ('E01','E64','EB5','E05','EB8','E15','E16','E17','E18','E19','E20','ECA','EAJ','EAR','EB4','EAK')           
              AND date_part('year', check_date) = date_part('year',elu.lastupdatets::DATE) ---- 1/4/2019 changed current_date to elu.lastupdatets::DATE
              and check_date <= elu.lastupdatets::DATE 
         GROUP BY personid,eligible_flag
          ) ytdcomp
  ON ytdcomp.personid = pi.personid  
--- SEVERENCE PAY
LEFT JOIN (SELECT personid
                 ,date_part('year',check_date)
                 ,coalesce(sum(etv_amount),0) as severance_pay
             FROM pspay_payment_detail  
             LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'HMN_PS_CogDetGet_Export'          
            WHERE etv_id in  ('E30')           
              AND date_part('year', check_date) = date_part('year',elu.lastupdatets::DATE) ---- 1/4/2019 changed current_date to elu.lastupdatets::DATE
              and check_date <= elu.lastupdatets::DATE        
            GROUP BY 1,2
          ) ytdsev
  ON ytdsev.personid = pi.personid  
--- HIRING BONUS
LEFT JOIN (SELECT personid
                 ,date_part('year',check_date)
                 ,coalesce(sum(etv_amount),0) as hiring_bonus
             FROM pspay_payment_detail    
             LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'HMN_PS_CogDetGet_Export'        
            WHERE etv_id in  ('E64')           
              AND date_part('year', check_date) = date_part('year',elu.lastupdatets::DATE) ---- 1/4/2019 changed current_date to elu.lastupdatets::DATE
              and check_date <= elu.lastupdatets::DATE 
            GROUP BY 1,2
          ) ytdhb
  ON ytdhb.personid = pi.personid  
--- LUMP SUM
LEFT JOIN (SELECT personid
                 ,date_part('year',check_date)
                 ,coalesce(sum(etv_amount),0) as lump_sum
             FROM pspay_payment_detail  
             LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'HMN_PS_CogDetGet_Export'          
            WHERE etv_id in  ('ECA')           
              AND date_part('year', check_date) = date_part('year',elu.lastupdatets::DATE) ---- 1/4/2019 changed current_date to elu.lastupdatets::DATE
              and check_date <= elu.lastupdatets::DATE 
            GROUP BY 1,2
          ) ytdls
  ON ytdls.personid = pi.personid   	
--- ALL BONUS
LEFT JOIN (SELECT personid
                 ,date_part('year',check_date)
                 ,coalesce(sum(etv_amount),0) as ALL_bonus
             FROM pspay_payment_detail        
             LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'HMN_PS_CogDetGet_Export'    
            WHERE etv_id in  ('E61','EA1','EB1','EBE','EBH','EA2','EBI')          
              AND date_part('year', check_date) = date_part('year',elu.lastupdatets::DATE) ---- 1/4/2019 changed current_date to elu.lastupdatets::DATE
              and check_date <= elu.lastupdatets::DATE 
            GROUP BY 1,2
          ) ytdAb
  ON ytdAb.personid = pi.personid  	
--- YTD FICA
LEFT JOIN (SELECT personid
                 ,sum(etv_amount) as fica
             FROM pspay_payment_detail   
             LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'HMN_PS_CogDetGet_Export'         
            WHERE etv_id in  ('T01','T13')           
              and date_part('year', check_date) = date_part('year',elu.lastupdatets::DATE) ---- 1/4/2019 changed current_date to elu.lastupdatets::DATE
              and check_date <= elu.lastupdatets::DATE 
              --and check_number = 'DIRDEP'
         GROUP BY personid
          ) ytdfica
  ON ytdfica.personid = pi.personid  
--- dependent care
left join 
      (select individual_key, etv_id, sum(etv_amount) as etv_amount
         from pspay_payment_detail 
         LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'HMN_PS_CogDetGet_Export'
        where etv_id = 'VBB'
          AND date_part('year',check_date) = date_part('year',elu.lastupdatets)
          and date_part('month',check_date) = date_part('month',elu.lastupdatets)
          group by 1,2
      ) dpc
  on dpc.individual_key = pip.identity 
  
left join 
      (select individual_key, current_dedn_amount, etv_id
         from pspay_deduction_accumulators 
         LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'HMN_PS_CogDetGet_Export'
        where etv_id = 'VBB'
          and mtd_dedn_amount > 0   
          AND date_part('year',last_updt_dt) = date_part('year',elu.lastupdatets)
          and date_part('month',last_updt_dt) = date_part('month',elu.lastupdatets)
      ) dpc1
  on dpc1.individual_key = pip.identity    
-- med
left join 
      (select individual_key, etv_id, sum(etv_amount) as etv_amount
         from pspay_payment_detail 
         LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'HMN_PS_CogDetGet_Export'
        where etv_id = 'VBC'
          AND date_part('year',check_date) = date_part('year',elu.lastupdatets)
          and date_part('month',check_date) = date_part('month',elu.lastupdatets)
          group by 1,2
      ) med
  on med.individual_key = pip.identity  

left join 
      (select individual_key, current_dedn_amount, etv_id
         from pspay_deduction_accumulators 
         LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'HMN_PS_CogDetGet_Export'
        where etv_id = 'VBC'
          and mtd_dedn_amount > 0   
          AND date_part('year',last_updt_dt) = date_part('year',elu.lastupdatets)
          and date_part('month',last_updt_dt) = date_part('month',elu.lastupdatets)
      ) med1
  on med1.individual_key = pip.identity 
--- dental
left join 
      (select individual_key, etv_id, sum(etv_amount) as etv_amount
         from pspay_payment_detail 
         LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'HMN_PS_CogDetGet_Export'
        where etv_id = 'VBD'
          AND date_part('year',check_date) = date_part('year',elu.lastupdatets)
          and date_part('month',check_date) = date_part('month',elu.lastupdatets)
          group by 1,2
      ) dnt
  on dnt.individual_key = pip.identity    
  
left join 
      (select individual_key, current_dedn_amount, etv_id
         from pspay_deduction_accumulators 
         LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'HMN_PS_CogDetGet_Export'
        where etv_id = 'VBD'
          and mtd_dedn_amount > 0   
          AND date_part('year',last_updt_dt) = date_part('year',elu.lastupdatets)
          and date_part('month',last_updt_dt) = date_part('month',elu.lastupdatets)
      ) dnt1
  on dnt1.individual_key = pip.identity   
--- fsa 
left join 
      (select individual_key, etv_id, sum(etv_amount) as etv_amount
         from pspay_payment_detail 
         LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'HMN_PS_CogDetGet_Export'
        where etv_id = 'VBA'
          AND date_part('year',check_date) = date_part('year',elu.lastupdatets)
          and date_part('month',check_date) = date_part('month',elu.lastupdatets)
          group by 1,2
      ) fsa
  on fsa.individual_key = pip.identity  
  
left join 
      (select individual_key, current_dedn_amount, etv_id
         from pspay_deduction_accumulators 
         LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'HMN_PS_CogDetGet_Export'
        where etv_id = 'VBA'
          and mtd_dedn_amount > 0   
          AND date_part('year',last_updt_dt) = date_part('year',elu.lastupdatets)
          and date_part('month',last_updt_dt) = date_part('month',elu.lastupdatets)
      ) fsa1
  on fsa1.individual_key = pip.identity 
--- vision    
left join 
      (select individual_key, etv_id, sum(etv_amount) as etv_amount
         from pspay_payment_detail 
         LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'HMN_PS_CogDetGet_Export'
        where etv_id = 'VBE'
          AND date_part('year',check_date) = date_part('year',elu.lastupdatets)
          and date_part('month',check_date) = date_part('month',elu.lastupdatets)
          group by 1,2
      ) vsn
  on vsn.individual_key = pip.identity       
  
left join 
      (select individual_key, current_dedn_amount, etv_id
         from pspay_deduction_accumulators 
         LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'HMN_PS_CogDetGet_Export'
        where etv_id = 'VBE'
          and mtd_dedn_amount > 0   
          AND date_part('year',last_updt_dt) = date_part('year',elu.lastupdatets)
          and date_part('month',last_updt_dt) = date_part('month',elu.lastupdatets)
      ) vsn1
  on vsn1.individual_key = pip.identity     
--- hsa
left join 
      (select individual_key, etv_id, sum(etv_amount) as etv_amount
         from pspay_payment_detail 
         LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'HMN_PS_CogDetGet_Export'
        where etv_id = 'VEH'
          AND date_part('year',check_date) = date_part('year',elu.lastupdatets)
          and date_part('month',check_date) = date_part('month',elu.lastupdatets)
          group by 1,2
      ) hsa
  on hsa.individual_key = pip.identity   

left join 
      (select individual_key, current_dedn_amount, etv_id
         from pspay_deduction_accumulators 
         LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'HMN_PS_CogDetGet_Export'
        where etv_id = 'VEH'
          and mtd_dedn_amount > 0   
          AND date_part('year',last_updt_dt) = date_part('year',elu.lastupdatets)
          and date_part('month',last_updt_dt) = date_part('month',elu.lastupdatets)
      ) hsa1
  on hsa1.individual_key = pip.identity 
--- hsa cu
left join 
      (select individual_key, etv_id, sum(etv_amount) as etv_amount
         from pspay_payment_detail 
         LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'HMN_PS_CogDetGet_Export'
        where etv_id = 'VEJ'
          AND date_part('year',check_date) = date_part('year',elu.lastupdatets)
          and date_part('month',check_date) = date_part('month',elu.lastupdatets)
          group by 1,2
      ) hcu
  on hcu.individual_key = pip.identity    

left join 
      (select individual_key, current_dedn_amount, etv_id
         from pspay_deduction_accumulators 
         LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'HMN_PS_CogDetGet_Export'
        where etv_id = 'VEJ'
          and mtd_dedn_amount > 0   
          AND date_part('year',last_updt_dt) = date_part('year',elu.lastupdatets)
          and date_part('month',last_updt_dt) = date_part('month',elu.lastupdatets)
      ) hcu1
  on hcu1.individual_key = pip.identity     

left join ( 
select distinct 
 pe.personid

--,coalesce(to_char(round(((ppd05.shift_dif_amt / ppd01.etype_hours) * pp.scheduledhours)/(pc.compamount/24),2),'00D9999'),'0.00') ::char(12) as f17_O12_shift_differential_rate_debbie  
--,to_char(ppd05.shift_dif_amt / ppd01.etype_hours * pp.scheduledhours * 24 + pc.compamount,'00000000d00') ::char(12) as f18_o13_ee_annual_salary_debbie

,case when pp.scheduledhours = 86.67 then coalesce(to_char(round(((ppd05.shift_dif_amt / ppd01.etype_hours) * pp.scheduledhours)/(pc.compamount/24),2),'00D9999'),'0.00')
      else coalesce(to_char(round(((ppd05.shift_dif_amt / ppd01.etype_hours) * pp.scheduledhours)/(pc.compamount/24),2),'00D9999'),'0.00') end ::char(12) as f17_O12_shift_differential_rate  
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
where pe.emplstatus = 'T' and pe.emplevent = 'Retire'
  and current_date between pe.effectivedate and pe.enddate
  and current_timestamp between pe.createts and pe.endts
  --and pe.personid = '64831'
  order by f5_emp_name 
) sdr on sdr.personid = pe.personid
  	
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  and pe.emplstatus = 'T' 
  and pe.emplevent = 'Retire'
  and pd.positiontitle <> ('Agent')  
  
  And (date_part('year',pe.effectivedate) >= date_part('year',current_date - interval '1 year') OR
         coalesce(ytdcomp.taxable_wage,0) + coalesce(ytdhb.hiring_bonus,0) + coalesce(ytdls.lump_sum,0) + coalesce(ytdAb.ALL_bonus,0) + coalesce(ytdsev.severance_pay,0) + coalesce(ytdfica.fica,0) > 0
          )
  --and pe.personid = '62986'
