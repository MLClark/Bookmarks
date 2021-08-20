select distinct
---- active current compensation had either position change or comp change after month end 
pi.personid
,'1'::CHAR(1) AS SORTSEQ
,pip.identity
,pp.effectivedate 
,to_char(elu.lastupdatets,'yyyy') as f1_curyy
,to_char(elu.lastupdatets,'mm') as f2_cur_mm 
,occc.orgcode as f3_accounting_unit
,pie.identity as f4_empnbr 
,pn.lname||', '||pn.fname||' '||COALESCE(pn.mname,'') ::varchar(60) as f5_emp_name 

,jd.jobcode as f6_job_title_cd
,pd.positiontitle as f7_position_title
,sg.salarygradedesc as f8_job_family_code
,case when pd.flsacode = 'E' then 'Exempt' else 'Non-Exempt' END ::CHAR(10) as f9_flsa_code
          
,case when pe.emplclass = 'F' then 'Full Time' else 'Part Time' end ::char(10) as f10_o46_emp_class
,case when pe.emplpermanency = 'P' then 'Permanent' else 'Temporary' end ::char(10) as f11_o47_emp_type
,pp.scheduledhours as f12_o49_scheduled_hours
,case when lc.locationcode = 'HO' then lc.locationcode  else 'FIELD' end as f13_o10_location
,lc.locationcode as f14_o50_location_desc
,' ' ::char(1) as f15_o51_remote_ind

,case when lc.locationcode = 'HO' then 'A'
      when lc.locationcode = 'Area A' then 'A'
      when lc.locationcode = 'Raleigh' then 'A' 
      when lc.locationcode = 'Dallas' then 'A' 
      when lc.locationcode = 'Area B' then 'B'
      when lc.locationcode = 'Area C' then 'C'
      when lc.locationcode = 'Area D' then 'D'
       end ::char(1) as f16_o11_sgr_cognos_code
       
,CASE WHEN pc.frequencycode = 'A' and pc.compamount IS NOT NULL then coalesce(to_char(trunc (sdrate.shift_dif_amt / ((pc.compamount/2080) * pp.scheduledhours),4),'99D9999'),'00.0000')  
      WHEN pc.frequencycode = 'H' and pc.compamount IS NOT NULL then coalesce(to_char(trunc (sdrate.shift_dif_amt / (pc.compamount * pp.scheduledhours),4),'99D9999'),'00.0000') 
      else '00.0000' END AS f17_O12_shift_differential_rate

,to_char(pc.compamount,'00000000d00') as f18_o13_ee_annual_salary   
--,to_char(least(pc.compamount,prevpc.compamount),'00000000d00') as f18_o13_ee_annual_salary   
 
,vpcpira.percent_in_range as f19_o14_pct_in_range
,to_char(least(pc.effectivedate,prevpc.effectivedate),'mm/dd/yy') as f20_o15_sal_change_date
--,to_char(pc.effectivedate,'mm/dd/yy') as f20_o15_sal_change_date
,case when (pc.compamount - pc.increaseamount) <> 0 then round((pc.increaseamount / (pc.compamount - pc.increaseamount)) * 100, 2 ) 
      else 0 end as f21_o18_current_comp_chg_pct
      
,to_char(pc.increaseamount,'00000009d00')  as f22_o19_comp_change_amount
,pc.compevent as f23_o20_cognos_comp_code
,to_char((pc.compamount - pc.increaseamount),'00000000d00') as f24_o21_prev_annual_salary   
,pufv3.ufvalue as f25_o16_perf_review_desc
,case when pufv2.ufvalue in ('Y','Regular','Combined') then ' ' else pufv2.ufvalue end as f26_o17_perf_review_rating
,pe.emplstatus as f27_o26_emp_status
--,ytdsev.severance_pay
,case when pe.emplstatus =  'A' then 'Acti'
      when pe.emplstatus =  'L' then 'LOA'
      when pe.emplstatus =  'T' and pe.emplevent = 'Retire' and ytdsev.severance_pay <> 0 then 'RWS' --RWOS if the Employment Event is Retirement and the employee has YTD Severance Pay zero (E30)
      when pe.emplstatus =  'T' and pe.emplevent = 'InvTerm' and ytdsev.severance_pay <> 0 then 'TWS' --RWOS if the Employment Event is Retirement and the employee has YTD Severance Pay zero (E30)
      when pe.emplstatus =  'T' and pe.emplevent = 'Retire' and ytdsev.severance_pay IS NULL  then 'RWOS' --RWOS if the Employment Event is Retirement and the employee has YTD Severance Pay zero (E30)
      when pe.emplstatus <> 'R' and pe.emplevent = 'Term' and ytdsev.severance_pay <> 0 then 'TWS' --TWS if the Employment Event is not Retirement and the employee has YTD Severance Pay not = zero  
      when pe.emplstatus =  'T' then 'TWOS' --TWOS if the Employment Event is not Retirement and the employee has YTD Severance Pay zero
      end ::char(4) as f28_o27_cognos_status
      
,to_char(pe.emplhiredate,'mm/dd/yy') ::char(8) as f29_o28_adj_hire_date ---- use service date
      
,case when pe.emplstatus = 'T' then 
           cast(date_part('year',age(pe.effectivedate,pe.emplhiredate)) + (date_part('month',age(pe.effectivedate,pe.emplhiredate)) * .10) as dec (18,2))
      else cast(date_part('year',age(current_date,pe.emplhiredate)) + (date_part('month',age(current_date,pe.emplhiredate)) * .10) as dec (18,2)) end 
      as f30_o29_years_of_service  
            
,to_char(pe.paythroughdate,'mm/dd/yy') ::char(8) as f31_pay_through_date 


,case when pe.emplstatus = 'T' then to_char(pe.effectivedate,'mm/dd/yy') else null end ::char(8) as f32_o32_term_date
,case when pe.emplstatus = 'L' then to_char(pe.effectivedate,'mm/dd/yy') else null end ::char(8) as f33_o34_loa_begin_date
,case when pe.emplstatus = 'L' and pe.enddate < '2199-12-31' then to_char(pe.enddate,'mm/dd/yy') else null end ::char(8) as f34_o35_loa_end_date
,case when pe.emplstatus IN ('L') then pe.emplstatus else null end ::char(1) as f35_leave_event_code    
,to_char(pp.effectivedate,'mm/dd/yy')::char(8) as f36_o33_position_effective_date
,to_char(coalesce(ytdcomp.taxable_wage,0),'00000009d00') as f37_o23_ytd_cognos_gross_pay

,to_char(coalesce(ytdhb.hiring_bonus,0),'00000009d00') as f38_052_ytd_hiring_bonus

,to_char(coalesce(ytdls.lump_sum,0),'00000009d00') as f39_o45_ytd_lump_sum


,coalesce(TRUNC((ytdAb.ALL_bonus * .0620)+(ytdAb.ALL_bonus * .0145),2),0) as f40_o24_ytd_fica_on_ytd_bonus_pay  
,coalesce(TRUNC(ytdfica.fica -((ytdAb.ALL_bonus * .0620)+(ytdAb.ALL_bonus * .0145)),2),ytdfica.fica,0) as f41_o25_ytd_fica_less_ytd_fica_bonus_fica_sev
,case when occc.orgcode  = '515110' then 'Y'
      when pe.emplstatus =  'T' and ytdsev.severance_pay <> 0 then 'Y'
      else 'N' end as f42_o30_sev_ind
 



,ytdsev.severance_pay as f43_o40_ytd_cognos_sev_amt     
,TRUNC((ytdsev.severance_pay * .0620)+(ytdsev.severance_pay * .0145),2)  as f44_o41_ytd_fica_on_sev_pay
,' ' as f45_o31_ltip_bonus_pgm_ind
  
,case when fjc.federaljobcode < '049' then 'OF'
      when fjc.federaljobcode in ('049','050','051') then 'DR'
      else 'CAP' end as f46_o36_officer_code  

,coalesce(dpc1.current_dedn_amount * -2,dpc.etv_amount * -2,0)  as f47_o22_dep_care_monthly_ded_amt
,coalesce(med1.current_dedn_amount * -2,med.etv_amount * -2,0)  as f48_o37_medical_monthly_ded_amt
,coalesce(dnt1.current_dedn_amount * -2,dnt.etv_amount * -2,0)  as f49_o38_dental_monthly_ded_amt
,coalesce(fsa1.current_dedn_amount * -2,fsa.etv_amount * -2,0)  as f50_o39_fsa_monthly_ded_amt
,coalesce(vsn1.current_dedn_amount * -2,vsn.etv_amount * -2,0)  as f51_o42_vision_monthly_ded_amt
,coalesce(hsa1.current_dedn_amount * -2,hsa.etv_amount * -2,0)  as f52_o43_hsa_monthly_ded_amt
,coalesce(hcu1.current_dedn_amount * -2,hcu.etv_amount * -2,0)  as f53_o44_hsa_cu_monthly_ded_amt

  

from person_identity pi

LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'HMN_PS_CogDetGet_Export'

join person_identity pip
  on pip.personid = pi.personid
 and pip.identitytype = 'PSPID'
 and current_timestamp between pip.createts and pip.endts

join (select personid, max(perspospid) as perspospid
        from pers_pos 
        LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'HMN_PS_CogDetGet_Export'
        where current_timestamp between createts and endts 
         and effectivedate <= elu.lastupdatets
       group by 1 ) prevpp on prevpp.personid = pi.personid

join pers_pos pp 
  on pp.personid = prevpp.personid 
 and current_timestamp between pp.createts and pp.endts
 and pp.perspospid = prevpp.perspospid 

join pos_org_rel porb 
  ON porb.positionid = PP.positionid 
 AND porb.posorgreltype = 'Budget' 
 and current_date between porb.effectivedate and porb.enddate
 and current_timestamp between porb.createts and porb.endts

join organization_code occc
  ON occc.organizationid = porb.organizationid
 AND occc.organizationtype = 'CC'
 and current_date between occc.effectivedate and occc.enddate
 and current_timestamp between occc.createts and occc.endts 
   
left join personcomppercentinrangeasof vpcpira
  on vpcpira.personid = pp.personid        
 and vpcpira.asofdate = current_date                     
                                    
join (select personid, max(compamount) as compamount, max(effectivedate) as effectivedate, max(percomppid) as percomppid
        from person_compensation 
        LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'HMN_PS_CogDetGet_Export'
       where  current_timestamp between createts and endts
         and effectivedate <= elu.lastupdatets
       group by 1 ) prevpc on prevpc.personid = pi.personid 

join person_compensation pc
  on pc.personid = prevpc.personid
 and pc.percomppid = prevpc.percomppid
 and current_timestamp between pc.createts and pc.endts
        
join person_identity pie
  on pie.personid = pi.personid
 and pie.identitytype = 'EmpNo'
 and current_timestamp between pie.createts and pie.endts 

join person_names pn
  on pn.personid = pi.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts 
  
join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts 
 and pe.effectivedate <= elu.lastupdatets  

join position_desc pd
  on pd.positionid = pp.positionid
 --and current_date between pd.effectivedate and pd.enddate
 and current_timestamp between pd.createts and pd.endts 

join salary_grade sg
  on sg.grade = pd.grade
 and current_date between sg.effectivedate and sg.enddate
 and current_timestamp between sg.createts and sg.endts
   
join person_locations pl
  on pl.personid = pp.personid
 and current_date between pl.effectivedate and pl.enddate
 and current_timestamp between pl.createts and pl.endts   

join (select personid, max(locationid) as locationid, max(perlocpid) as perlocpid
  from person_locations 
 where current_date between effectivedate and enddate 
   and current_timestamp between createts and endts
   group by 1) maxlc on maxlc.personid = pp.personid

join location_codes lc
  on lc.locationid = maxlc.locationid
 and current_date between lc.effectivedate and lc.enddate
 and current_timestamp between lc.createts and lc.endts    

left join position_job pj
  on pj.positionid = PP.positionid
 and current_date between pj.effectivedate and pj.enddate
 and current_timestamp between pj.createts and pj.endts
 
left join job_desc jd
  on jd.jobid = pj.jobid
 and current_date between jd.effectivedate and jd.enddate
 and current_timestamp between jd.createts and jd.endts
 
left join federal_job_code fjc
  on fjc.federaljobcodeid = jd.federaljobcodeid
	
left join person_user_field_vals pufv1
  on pufv1.personid = pi.personid
 and pufv1.persufpid = '1'
 
left join person_user_field_vals pufv2
  on pufv2.personid = pi.personid
 and pufv2.persufpid = '2'
 
left join person_user_field_vals pufv3
  on pufv3.personid = pi.personid
 and pufv3.persufpid = '3'	

LEFT JOIN (SELECT personid
                  ,'Y' as eligible_flag 
                 ,coalesce(sum(etv_amount),0) as taxable_wage
             FROM pspay_payment_detail            
            WHERE etv_id in ('E01','E64','EB5','E05','EB8','E15','E16','E17','E18','E19','E20','ECA','EAJ','EAR','EB4','EAK')           
              AND date_part('year', check_date) = date_part('year',current_date)
         GROUP BY personid,eligible_flag
          ) ytdcomp
  ON ytdcomp.personid = pi.personid  

LEFT JOIN (SELECT personid
                 ,sum(etv_amount) as fica
             FROM pspay_payment_detail            
            WHERE etv_id in  ('T01','T13')           
              and date_part('year', check_date) = date_part('year',current_date)
              --and check_number = 'DIRDEP'
         GROUP BY personid
          ) ytdfica
  ON ytdfica.personid = pi.personid  
  
left join ( 
      select personid, individual_key, sum(etv_amount) as shift_dif_amt 
      from pspay_payment_detail 
      where etv_id = 'E05'  
        and date_part('year', check_date) = date_part('year',current_date)
        and etv_amount > 0
        group by 1,2
     ) sdrate 
  on sdrate.individual_key = pip.identity  

LEFT JOIN (SELECT personid
                 ,date_part('year',check_date)
                 ,coalesce(sum(etv_amount),0) as hiring_bonus
             FROM pspay_payment_detail            
            WHERE etv_id in  ('E64')           
              AND date_part('year', check_date) = date_part('year',current_date)
            GROUP BY 1,2
          ) ytdhb
  ON ytdhb.personid = pi.personid     

LEFT JOIN (SELECT personid
                 ,date_part('year',check_date)
                 ,coalesce(sum(etv_amount),0) as lump_sum
             FROM pspay_payment_detail            
            WHERE etv_id in  ('ECA')           
              AND date_part('year', check_date) = date_part('year',current_date)
            GROUP BY 1,2
          ) ytdls
  ON ytdls.personid = pi.personid   

LEFT JOIN (SELECT personid
                 ,date_part('year',check_date)
                 ,coalesce(sum(etv_amount),0) as severance_pay
             FROM pspay_payment_detail            
            WHERE etv_id in  ('E30')           
              AND date_part('year', check_date) = date_part('year',current_date)         
            GROUP BY 1,2
          ) ytdsev
  ON ytdsev.personid = pi.personid  

LEFT JOIN (SELECT personid
                 ,date_part('year',check_date)
                 ,coalesce(sum(etv_amount),0) as ALL_bonus
             FROM pspay_payment_detail            
            WHERE etv_id in  ('E61','EA1','EB1','EBE','EBH','EA2','EBI')          
              AND date_part('year', check_date) = date_part('year',current_date)
            GROUP BY 1,2
          ) ytdAb
  ON ytdAb.personid = pi.personid    

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

where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  --and pd.positiontitle not in ('Agent','Acct Rep')
  --and pi.personid = '66029'
  and pi.personid in 
  ( 
   select distinct pp.personid 
     from pers_pos  pp
     LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'HMN_PS_CogDetGet_Export'
    where current_date between pp.effectivedate and pp.enddate
      and current_timestamp between pp.createts and pp.endts
      and pp.effectivedate > elu.lastupdatets
     
  group by 1
  union 
  select distinct pc.personid
      from person_compensation pc
      LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'HMN_PS_CogDetGet_Export'
     where current_date between pc.effectivedate and pc.enddate
       and current_timestamp between pc.createts and pc.endts
       and pc.effectivedate > elu.lastupdatets

   group by 1 
  )
UNION
select distinct

pi.personid
,'2'::CHAR(1) AS SORTSEQ
,pip.identity
,pp.effectivedate 
,to_char(elu.lastupdatets,'yyyy') as f1_curyy
,to_char(elu.lastupdatets,'mm') as f2_cur_mm 
,occc.orgcode as f3_accounting_unit
,pie.identity as f4_empnbr 
,pn.lname||', '||pn.fname||' '||COALESCE(pn.mname,'') ::varchar(60) as f5_emp_name 

,jd.jobcode as f6_job_title_cd
,pd.positiontitle as f7_position_title
,sg.salarygradedesc as f8_job_family_code
,case when pd.flsacode = 'E' then 'Exempt' else 'Non-Exempt' END ::CHAR(10) as f9_flsa_code
          
,case when pe.emplclass = 'F' then 'Full Time' else 'Part Time' end ::char(10) as f10_o46_emp_class
,case when pe.emplpermanency = 'P' then 'Permanent' else 'Temporary' end ::char(10) as f11_o47_emp_type
,pp.scheduledhours as f12_o49_scheduled_hours
,case when lc.locationcode = 'HO' then lc.locationcode  else 'FIELD' end as f13_o10_location
,lc.locationcode as f14_o50_location_desc
,' ' ::char(1) as f15_o51_remote_ind

,case when lc.locationcode = 'HO' then 'A'
      when lc.locationcode = 'Area A' then 'A'
      when lc.locationcode = 'Raleigh' then 'A' 
      when lc.locationcode = 'Dallas' then 'A' 
      when lc.locationcode = 'Area B' then 'B'
      when lc.locationcode = 'Area C' then 'C'
      when lc.locationcode = 'Area D' then 'D'
       end ::char(1) as f16_o11_sgr_cognos_code
       
,CASE WHEN pc.frequencycode = 'A' and pc.compamount IS NOT NULL then coalesce(to_char(trunc (sdrate.shift_dif_amt / ((pc.compamount/2080) * pp.scheduledhours),4),'99D9999'),'00.0000')  
      WHEN pc.frequencycode = 'H' and pc.compamount IS NOT NULL then coalesce(to_char(trunc (sdrate.shift_dif_amt / (pc.compamount * pp.scheduledhours),4),'99D9999'),'00.0000') 
      else '00.0000' END AS f17_O12_shift_differential_rate

,to_char(pc.compamount,'00000000d00') as f18_o13_ee_annual_salary   
 
,vpcpira.percent_in_range as f19_o14_pct_in_range
,to_char(pc.effectivedate,'mm/dd/yy') as f20_o15_sal_change_date
,case when (pc.compamount - pc.increaseamount) <> 0 then round((pc.increaseamount / (pc.compamount - pc.increaseamount)) * 100, 2 ) 
      else 0 end as f21_o18_current_comp_chg_pct
      
,to_char(pc.increaseamount,'00000009d00')  as f22_o19_comp_change_amount
,pc.compevent as f23_o20_cognos_comp_code
,to_char((pc.compamount - pc.increaseamount),'00000000d00') as f24_o21_prev_annual_salary   
,pufv3.ufvalue as f25_o16_perf_review_desc
,case when pufv2.ufvalue in ('Y','Regular','Combined') then ' ' else pufv2.ufvalue end as f26_o17_perf_review_rating
,pe.emplstatus as f27_o26_emp_status
--,ytdsev.severance_pay
,case when pe.emplstatus =  'A' then 'Acti'
      when pe.emplstatus =  'L' then 'LOA'
      when pe.emplstatus =  'T' and pe.emplevent = 'Retire' and ytdsev.severance_pay <> 0 then 'RWS' --RWOS if the Employment Event is Retirement and the employee has YTD Severance Pay zero (E30)
      when pe.emplstatus =  'T' and pe.emplevent = 'InvTerm' and ytdsev.severance_pay <> 0 then 'TWS' --RWOS if the Employment Event is Retirement and the employee has YTD Severance Pay zero (E30)
      when pe.emplstatus =  'T' and pe.emplevent = 'Retire' and ytdsev.severance_pay IS NULL  then 'RWOS' --RWOS if the Employment Event is Retirement and the employee has YTD Severance Pay zero (E30)
      when pe.emplstatus <> 'R' and pe.emplevent = 'Term' and ytdsev.severance_pay <> 0 then 'TWS' --TWS if the Employment Event is not Retirement and the employee has YTD Severance Pay not = zero  
      when pe.emplstatus =  'T' then 'TWOS' --TWOS if the Employment Event is not Retirement and the employee has YTD Severance Pay zero
      end ::char(4) as f28_o27_cognos_status
      
,to_char(pe.emplhiredate,'mm/dd/yy') ::char(8) as f29_o28_adj_hire_date ---- use service date
      
,case when pe.emplstatus = 'T' then 
           cast(date_part('year',age(pe.effectivedate,pe.emplhiredate)) + (date_part('month',age(pe.effectivedate,pe.emplhiredate)) * .10) as dec (18,2))
      else cast(date_part('year',age(current_date,pe.emplhiredate)) + (date_part('month',age(current_date,pe.emplhiredate)) * .10) as dec (18,2)) end 
      as f30_o29_years_of_service  
            
,to_char(pe.paythroughdate,'mm/dd/yy') ::char(8) as f31_pay_through_date 


,case when pe.emplstatus = 'T' then to_char(pe.effectivedate,'mm/dd/yy') else null end ::char(8) as f32_o32_term_date
,case when pe.emplstatus = 'L' then to_char(pe.effectivedate,'mm/dd/yy') else null end ::char(8) as f33_o34_loa_begin_date
,case when pe.emplstatus = 'L' and pe.enddate < '2199-12-31' then to_char(pe.enddate,'mm/dd/yy') else null end ::char(8) as f34_o35_loa_end_date
,case when pe.emplstatus IN ('L') then pe.emplstatus else null end ::char(1) as f35_leave_event_code    
,to_char(pp.effectivedate,'mm/dd/yy')::char(8) as f36_o33_position_effective_date
,to_char(coalesce(ytdcomp.taxable_wage,0),'00000009d00') as f37_o23_ytd_cognos_gross_pay

,to_char(coalesce(ytdhb.hiring_bonus,0),'00000009d00') as f38_052_ytd_hiring_bonus

,to_char(coalesce(ytdls.lump_sum,0),'00000009d00') as f39_o45_ytd_lump_sum


,coalesce(TRUNC((ytdAb.ALL_bonus * .0620)+(ytdAb.ALL_bonus * .0145),2),0) as f40_o24_ytd_fica_on_ytd_bonus_pay  
,coalesce(TRUNC(ytdfica.fica -((ytdAb.ALL_bonus * .0620)+(ytdAb.ALL_bonus * .0145)),2),ytdfica.fica,0) as f41_o25_ytd_fica_less_ytd_fica_bonus_fica_sev
,case when occc.orgcode  = '515110' then 'Y'
      when pe.emplstatus =  'T' and ytdsev.severance_pay <> 0 then 'Y'
      else 'N' end as f42_o30_sev_ind
 



,ytdsev.severance_pay as f43_o40_ytd_cognos_sev_amt     
,TRUNC((ytdsev.severance_pay * .0620)+(ytdsev.severance_pay * .0145),2)  as f44_o41_ytd_fica_on_sev_pay
,' ' as f45_o31_ltip_bonus_pgm_ind
  
,case when fjc.federaljobcode < '049' then 'OF'
      when fjc.federaljobcode in ('049','050','051') then 'DR'
      else 'CAP' end as f46_o36_officer_code  

,coalesce(dpc1.current_dedn_amount * -2,dpc.etv_amount * -2,0)  as f47_o22_dep_care_monthly_ded_amt
,coalesce(med1.current_dedn_amount * -2,med.etv_amount * -2,0)  as f48_o37_medical_monthly_ded_amt
,coalesce(dnt1.current_dedn_amount * -2,dnt.etv_amount * -2,0)  as f49_o38_dental_monthly_ded_amt
,coalesce(fsa1.current_dedn_amount * -2,fsa.etv_amount * -2,0)  as f50_o39_fsa_monthly_ded_amt
,coalesce(vsn1.current_dedn_amount * -2,vsn.etv_amount * -2,0)  as f51_o42_vision_monthly_ded_amt
,coalesce(hsa1.current_dedn_amount * -2,hsa.etv_amount * -2,0)  as f52_o43_hsa_monthly_ded_amt
,coalesce(hcu1.current_dedn_amount * -2,hcu.etv_amount * -2,0)  as f53_o44_hsa_cu_monthly_ded_amt

  

from person_identity pi

LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'HMN_PS_CogDetGet_Export'

join person_identity pip
  on pip.personid = pi.personid
 and pip.identitytype = 'PSPID'
 and current_timestamp between pip.createts and pip.endts
--- note PP is the main join that drives this sql for job location org codes
join pers_pos pp 
  on pp.personid = pi.personid 
 and current_date between pp.effectivedate and pp.enddate
 and current_timestamp between pp.createts and pp.endts
 and pp.effectivedate <= elu.lastupdatets

join pos_org_rel porb 
  ON porb.positionid = PP.positionid 
 AND porb.posorgreltype = 'Budget' 
 and current_date between porb.effectivedate and porb.enddate
 and current_timestamp between porb.createts and porb.endts

join organization_code occc
  ON occc.organizationid = porb.organizationid
 AND occc.organizationtype = 'CC'
 and current_date between occc.effectivedate and occc.enddate
 and current_timestamp between occc.createts and occc.endts 
   
left join personcomppercentinrangeasof vpcpira
  on vpcpira.personid = pp.personid        
 and vpcpira.asofdate = current_date                     
                                    
join person_compensation pc
  on pc.personid = pi.personid
 and current_date between pc.effectivedate and pc.enddate
 and current_timestamp between pc.createts and pc.endts

join person_identity pie
  on pie.personid = pi.personid
 and pie.identitytype = 'EmpNo'
 and current_timestamp between pie.createts and pie.endts 

join person_names pn
  on pn.personid = pi.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts 
  
join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts 
 and pe.effectivedate <= elu.lastupdatets 

join position_desc pd
  on pd.positionid = pp.positionid
 and current_date between pd.effectivedate and pd.enddate
 and current_timestamp between pd.createts and pd.endts 

join salary_grade sg
  on sg.grade = pd.grade
 and current_date between sg.effectivedate and sg.enddate
 and current_timestamp between sg.createts and sg.endts
   
join person_locations pl
  on pl.personid = pp.personid
 and current_date between pl.effectivedate and pl.enddate
 and current_timestamp between pl.createts and pl.endts   

join (select personid, max(locationid) as locationid, max(perlocpid) as perlocpid
  from person_locations 
 where current_date between effectivedate and enddate 
   and current_timestamp between createts and endts
   group by 1) maxlc on maxlc.personid = pp.personid

join location_codes lc
  on lc.locationid = maxlc.locationid
 and current_date between lc.effectivedate and lc.enddate
 and current_timestamp between lc.createts and lc.endts    

left join position_job pj
  on pj.positionid = PP.positionid
 and current_date between pj.effectivedate and pj.enddate
 and current_timestamp between pj.createts and pj.endts
 
left join job_desc jd
  on jd.jobid = pj.jobid
 and current_date between jd.effectivedate and jd.enddate
 and current_timestamp between jd.createts and jd.endts
 
left join federal_job_code fjc
  on fjc.federaljobcodeid = jd.federaljobcodeid
	
left join person_user_field_vals pufv1
  on pufv1.personid = pi.personid
 and pufv1.persufpid = '1'
 
left join person_user_field_vals pufv2
  on pufv2.personid = pi.personid
 and pufv2.persufpid = '2'
 
left join person_user_field_vals pufv3
  on pufv3.personid = pi.personid
 and pufv3.persufpid = '3'	

LEFT JOIN (SELECT personid
                  ,'Y' as eligible_flag 
                 ,coalesce(sum(etv_amount),0) as taxable_wage
             FROM pspay_payment_detail            
            WHERE etv_id in ('E01','E64','EB5','E05','EB8','E15','E16','E17','E18','E19','E20','ECA','EAJ','EAR','EB4','EAK')           
              AND date_part('year', check_date) = date_part('year',current_date)
         GROUP BY personid,eligible_flag
          ) ytdcomp
  ON ytdcomp.personid = pi.personid  

LEFT JOIN (SELECT personid
                 ,sum(etv_amount) as fica
             FROM pspay_payment_detail            
            WHERE etv_id in  ('T01','T13')           
              and date_part('year', check_date) = date_part('year',current_date)
              --and check_number = 'DIRDEP'
         GROUP BY personid
          ) ytdfica
  ON ytdfica.personid = pi.personid  
  
left join ( 
      select personid, individual_key, sum(etv_amount) as shift_dif_amt 
      from pspay_payment_detail 
      where etv_id = 'E05'  
        and date_part('year', check_date) = date_part('year',current_date)
        and etv_amount > 0
        group by 1,2
     ) sdrate 
  on sdrate.individual_key = pip.identity  

LEFT JOIN (SELECT personid
                 ,date_part('year',check_date)
                 ,coalesce(sum(etv_amount),0) as hiring_bonus
             FROM pspay_payment_detail            
            WHERE etv_id in  ('E64')           
              AND date_part('year', check_date) = date_part('year',current_date)
            GROUP BY 1,2
          ) ytdhb
  ON ytdhb.personid = pi.personid     

LEFT JOIN (SELECT personid
                 ,date_part('year',check_date)
                 ,coalesce(sum(etv_amount),0) as lump_sum
             FROM pspay_payment_detail            
            WHERE etv_id in  ('ECA')           
              AND date_part('year', check_date) = date_part('year',current_date)
            GROUP BY 1,2
          ) ytdls
  ON ytdls.personid = pi.personid   

LEFT JOIN (SELECT personid
                 ,date_part('year',check_date)
                 ,coalesce(sum(etv_amount),0) as severance_pay
             FROM pspay_payment_detail            
            WHERE etv_id in  ('E30')           
              AND date_part('year', check_date) = date_part('year',current_date)         
            GROUP BY 1,2
          ) ytdsev
  ON ytdsev.personid = pi.personid  

LEFT JOIN (SELECT personid
                 ,date_part('year',check_date)
                 ,coalesce(sum(etv_amount),0) as ALL_bonus
             FROM pspay_payment_detail            
            WHERE etv_id in  ('E61','EA1','EB1','EBE','EBH','EA2','EBI')          
              AND date_part('year', check_date) = date_part('year',current_date)
            GROUP BY 1,2
          ) ytdAb
  ON ytdAb.personid = pi.personid    

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
  
  
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  and pd.positiontitle not in ('Agent','Acct Rep')
  and pe.emplstatus = 'A'
  --and pi.personid = '66029'
  -- no changes on or after processing date
  and (pe.effectivedate <= elu.lastupdatets
   or  pp.effectivedate <= elu.lastupdatets
   or  pc.effectivedate <= elu.lastupdatets)
  order by 1