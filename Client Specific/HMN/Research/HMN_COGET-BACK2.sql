select DISTINCT

 pi.personid

,pip.identity

,to_char(current_date,'yyyy') as f1_curyy
,to_char(current_date,'mm') as f2_cur_mm 
--- field 3 loaded into lookup table 
,coalesce(orgcode_lookup.value3,orgcode_lookup.value6,oc_cc.orgcode,GRADETRM.orgcode) as f3_accounting_unit   --field 003          ---- cost center
,pie.identity as f4_empnbr 
,pn.lname||', '||pn.fname||' '||COALESCE(pn.mname,'') ::varchar(60) as f5_emp_name 

,coalesce(GRADEPRIOR.jobcode,GRADECURR.jobcode,GRADETRM.jobcode,jd.jobcode) as f6_job_title_cd

,replace(coalesce(GRADEPRIOR.positiontitle,GRADECURR.positiontitle,GRADETRM.positiontitle,jd.jobdesc),'            ','') as f7_position_title

,coalesce(GRADEPRIOR.salarygradedesc,GRADECURR.salarygradedesc,GRADETRM.salarygradedesc,GRADE.salarygradedesc) as f8_job_family_code

,case when pd.flsacode = 'E' then 'Exempt' else 'Non-Exempt' END ::CHAR(10) as f9_flsa_code
,case when pe.emplclass = 'F' then 'Full Time' else 'Part Time' end ::char(10) as f10_o46_emp_class
,case when pe.emplpermanency = 'P' then 'Permanent' else 'Temporary' end ::char(10) as f11_o47_emp_type


,coalesce(pp.scheduledhours,GRADETRM.scheduledhours) as f12_o49_scheduled_hours


,case when lc.locationCode = 'HO' then lc.locationCode else 'FIELD' end as f13_o10_location
,lc.locationdescription  as f14_location_desc
,' ' ::char(1) as f15_o51_remote_ind

,case when GRADEPRIOR.salarygraderegion = '3' then 'A'
      when GRADEPRIOR.salarygraderegion = '4' then 'B'
      when GRADEPRIOR.salarygraderegion = '5' then 'C'
      when GRADEPRIOR.salarygraderegion = '6' then 'D'
      when GRADEPRIOR.salarygraderegion = '7' then 'E'
      
      when GRADECURR.salarygraderegion = '3' then 'A'
      when GRADECURR.salarygraderegion = '4' then 'B'
      when GRADECURR.salarygraderegion = '5' then 'C'
      when GRADECURR.salarygraderegion = '6' then 'D'
      when GRADECURR.salarygraderegion = '7' then 'E' 
            
      when GRADETRM.salarygraderegion = '3' then 'A'
      when GRADETRM.salarygraderegion = '4' then 'B'
      when GRADETRM.salarygraderegion = '5' then 'C'
      when GRADETRM.salarygraderegion = '6' then 'D'
      when GRADETRM.salarygraderegion = '7' then 'E'      
      end ::char(1) as f16_o11_sgr_cognos_code
      
  
      
--,GRADE.hourly_rate,GRADECURR.hourly_rate,GRADEPRIOR.hourly_rate,GRADETRM.hourly_rate
--- HOURLY RATE * HOURS * DIF RATE .07 = SHIFT DIF AMT
-- I NEED TO SHIFT DIF AMT / HOURS * HOURLY RATE?
--,sdrate.shift_dif_amt
,CASE WHEN GRADECURR.hourly_rate IS NOT NULL THEN 
      trunc (sdrate.shift_dif_amt / (GRADECURR.hourly_rate * pp.scheduledhours),2) 
      WHEN GRADE.hourly_rate IS NOT NULL THEN 
      trunc (sdrate.shift_dif_amt / (GRADE.hourly_rate * pp.scheduledhours),2) 
      WHEN GRADETRM.hourly_rate IS NOT NULL THEN 
      trunc (sdrate.shift_dif_amt / (GRADETRM.hourly_rate * pp.scheduledhours),2)
      WHEN GRADEPRIOR.hourly_rate IS NOT NULL THEN 
      trunc (sdrate.shift_dif_amt / (GRADEPRIOR.hourly_rate * pp.scheduledhours),2)          
      END AS f17_O12_shift_differential_rate
--,'?' as f17_O12_shift_differential_rate
,to_char(coalesce(pc.compamount,gradetrm.compamount),'00000000d00') as f18_o13_ee_annual_salary

,coalesce(GRADECURR.percent_in_range,GRADEPRIOR.percent_in_range,GRADETRM.percent_in_range) as f19_o14_pct_in_range

,case when GRADEPRIOR.increaseamount > 0 then to_char(GRADEPRIOR.effectivedate,'mm/dd/yy')
      when GRADECURR.increaseamount > 0 then to_char(GRADECURR.effectivedate,'mm/dd/yy') 
      when GRADETRM.increaseamount  > 0 then to_char(GRADETRM.effectivedate,'mm/dd/yy')  
      else null end as f20_o15_sal_change_date

,case when GRADECURR.increaseamount <> 0 and GRADECURR.compamount <> 0 then round((GRADECURR.increaseamount / GRADECURR.compamount), 2 )
      when GRADEPRIOR.increaseamount <> 0 and GRADEPRIOR.compamount <> 0 then round((GRADEPRIOR.increaseamount / GRADEPRIOR.compamount), 2 )
      when GRADETRM.increaseamount <> 0 and GRADETRM.compamount <> 0 then round((GRADETRM.increaseamount / GRADETRM.compamount), 2 )
      else 0 end as f21_o18_current_comp_chg_pct

,to_char(coalesce(GRADECURR.increaseamount,GRADEPRIOR.increaseamount,GRADETRM.increaseamount),'00000000d00') as f22_o19_comp_change_amount


,coalesce(GRADEPRIOR.compevent,GRADECURR.compevent,GRADETRM.compevent,' ') as f23_o20_cognos_comp_code

,to_char(coalesce(GRADECURR.prev_compamount,GRADEPRIOR.prev_compamount,GRADETRM.prev_compamount),'00000000d00')  as f24_o21_prev_annual_salary   

,pufv3.ufvalue as f25_o16_perf_review_desc
,pufv2.ufvalue as f26_o17_perf_review_rating

,pe.emplstatus as f27_o26_emp_status
,case when pe.emplstatus =  'A' then 'Acti'
      when pe.emplstatus =  'L' then 'LOA'
      when pe.emplstatus =  'T' and pe.emplevent = 'Retire' and ytdsev.severance_pay <> 0 then 'RWS' --RWOS if the Employment Event is Retirement and the employee has YTD Severance Pay zero (E30)
      when pe.emplstatus =  'R' and pe.emplevent = 'Retire' and ytdsev.severance_pay = 0  then 'RWOS' --RWOS if the Employment Event is Retirement and the employee has YTD Severance Pay zero (E30)
      when pe.emplstatus <> 'R' and pe.emplevent = 'Term' and ytdsev.severance_pay <> 0 then 'TWS' --TWS if the Employment Event is not Retirement and the employee has YTD Severance Pay not = zero  
      when pe.emplstatus <> 'R' and pe.emplevent = 'Term' and ytdsev.severance_pay = 0  then 'TWOS' --TWOS if the Employment Event is not Retirement and the employee has YTD Severance Pay zero
      end ::char(4) as f28_o27_cognos_status
      
,to_char(pe.emplhiredate,'mm/dd/yy') ::char(8) as f29_o28_adj_hire_date ---- use service date

,case when date_part('month',current_date) = 1 
      then to_char(cast (DATE_PART('year',current_date - interval '1 year') - DATE_PART('year',pe.effectivedate::date) as dec (18,2)),'00d99')
      else to_char(cast (DATE_PART('year',current_date ::date) - DATE_PART('year',pe.effectivedate::date) as dec (18,2)),'00d99') end as f30_o29_years_of_service  
      
,to_char(pe.paythroughdate,'mm/dd/yy') ::char(8) as f31_pay_through_date 

,case when pe.emplstatus = 'T' then to_char(pe.effectivedate,'mm/dd/yy') else null end ::char(8) as f32_o32_term_date

,case when pe.emplstatus = 'L' then to_char(pe.effectivedate,'mm/dd/yy') else null end ::char(8) as f33_o34_loa_begin_date

,case when pe.emplstatus = 'L' and pe.enddate < '2199-12-31' then to_char(pe.enddate,'mm/dd/yy') else null end ::char(8) as f34_o35_loa_end_date

,case when pe.emplstatus = 'L' then pe.emplstatus else null end ::char(1) as f35_leave_event_code

,to_char(coalesce(GRADEPRIOR.position_effectivedate,GRADECURR.position_effectivedate,GRADETRM.position_effectivedate),'mm/dd/yy')::char(8) as f36_o33_position_effective_date

,ytdcomp.taxable_wage as f37_o23_ytd_cognos_gross_pay

,ytdhb.hiring_bonus as f38_052_ytd_hiring_bonus

,ytdls.lump_sum as f39_o45_ytd_lump_sum


-- YTD FICA on bonus pay - is the sum of all bonus's (except hiring bonus) multiplied by Soc Sec 1.45 rate and Medicare 6.20 Rate

--,ytdAb.ALL_bonus
,TRUNC((ytdAb.ALL_bonus * .0620)+(ytdAb.ALL_bonus * .0145),2) as f40_o24_ytd_fica_on_ytd_bonus_pay
--,ytdfica.fica
--,ytdss.social_security
--,ytdmc.medicare
--,(ytdmc.medicare + ytdss.social_security) -  ((ytdAb.ALL_bonus * .0620)+(ytdAb.ALL_bonus * .0145))  - ((ytdsev.severance_pay * .0620)+(ytdsev.severance_pay * .0145)) as f41_o25_ytd_fica_less_ytd_fica_bonus_fica_sev
--,'?' as f41_o25_ytd_fica_less_ytd_fica_bonus_fica_sev

,coalesce(TRUNC(ytdfica.fica -((ytdAb.ALL_bonus * .0620)+(ytdAb.ALL_bonus * .0145)),2),ytdfica.fica) as f41_o25_ytd_fica_less_ytd_fica_bonus_fica_sev



,case when oc_cc.orgcode = '515110' then 'Y'
      when pe.emplstatus =  'T' and ytdsev.severance_pay <> 0 then 'Y'
      else 'N' end as f42_o30_sev_ind
 
 
,ytdsev.severance_pay as f43_o40_ytd_cognos_sev_amt     
,TRUNC((ytdsev.severance_pay * .0620)+(ytdsev.severance_pay * .0145),2)  as f44_o41_ytd_fica_on_sev_pay
,'N' as f45_o31_ltip_bonus_pgm_ind


,case when fjc.federaljobcode < '049' then 'OF'
      when fjc.federaljobcode in ('049','050','051') then 'DR'
      else 'CAP' end as f46_o36_officer_code

,coalesce(dpc.etv_amount * -2,0)  as f47_o22_dep_care_monthly_ded_amt
,coalesce(med.etv_amount * -2,0)  as f48_o37_medical_monthly_ded_amt
,coalesce(dnt.etv_amount * -2,0)  as f49_o38_dental_monthly_ded_amt
,coalesce(fsa.etv_amount * -2,0)  as f50_o39_fsa_monthly_ded_amt
,coalesce(vsn.etv_amount * -2,0)  as f51_o42_vision_monthly_ded_amt
,coalesce(hsa.etv_amount * -2,0)  as f52_o43_hsa_monthly_ded_amt
,coalesce(hsa.etv_amount * -2,0)  as f53_o44_hsa_cu_monthly_ded_amt




from person_identity pi 

join person_identity pie
  on pie.personid = pi.personid
 and pie.identitytype = 'EmpNo'
 and current_timestamp between pie.createts and pie.endts

join person_identity pip
  on pip.personid = pi.personid
 and pip.identitytype = 'PSPID'
 and current_timestamp between pip.createts and pip.endts 

JOIN person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts
-- and pe.emplstatus = 'A'

join person_compensation pc
  on pc.personid = pi.personid
 and current_date between pc.effectivedate and pc.enddate
 and current_timestamp between pc.createts and pc.endts
 
join person_compensation prev_pc
  on prev_pc.personid = pi.personid
 and prev_pc.percomppid = pc.percomppid - 1
 
join person_names pn
  on pn.personid = pi.personid
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts
 and pn.nametype = 'Legal'

 
	

LEFT JOIN (SELECT personid
                  ,'Y' as eligible_flag 
                 --,sum(etype_hours) AS ytdhours
                 ,sum(etv_amount) as taxable_wage
             FROM pspay_payment_detail            
            WHERE etv_id in  ('E01','E64','EB5','E05','EB8','E15','E16','E17','E18','E19','E20',
                 'ECA','EAJ','EAR','EB4','EAK','E30','EBF','E61','EA1','EB1','EBE',
                 'EBH','EA2','VBB','VBC','VBD','VBA','VBE','VEH','VEJ')         
              AND date_part('year', check_date) = '2017'
              --and check_number = 'DIRDEP'
         GROUP BY personid,eligible_flag
          ) ytdcomp
  ON ytdcomp.personid = pi.personid  
  

LEFT JOIN (SELECT personid
                 ,sum(etv_amount) as social_security
             FROM pspay_payment_detail            
            WHERE etv_id in  ('T01')           
              AND date_part('year', check_date) = '2017'
              --and check_number = 'DIRDEP'
         GROUP BY personid
          ) ytdss
  ON ytdss.personid = pi.personid  
--select * from pspay_tax_accumulators where individual_key = 'HMN00000021932' and etv_id in  ('T01','T13')  and year = '2017'  ;    

LEFT JOIN (SELECT personid
                 ,sum(etv_amount) as medicare
             FROM pspay_payment_detail            
            WHERE etv_id in  ('T13')           
              AND date_part('year', check_date) = '2017'
              and check_number = 'DIRDEP'
         GROUP BY personid
          ) ytdmc
  ON ytdmc.personid = pi.personid  
      

LEFT JOIN (SELECT personid
                 ,sum(etv_amount) as fica
             FROM pspay_payment_detail            
            WHERE etv_id in  ('T01','T13')           
              AND date_part('year', check_date) = '2017'
              --and check_number = 'DIRDEP'
         GROUP BY personid
          ) ytdfica
  ON ytdfica.personid = pi.personid  
      

left join ( 
      select personid, individual_key, etv_amount as shift_dif_amt 
      from pspay_payment_detail 
      where etv_id = 'E05' and check_date = ?::date

   
     ) sdrate 
  on sdrate.individual_key = pip.identity



join pers_pos pp
  on pp.personid = pi.personid
 and current_date between pp.effectivedate and pp.enddate
 and current_timestamp between pp.createts and pp.endts

----- current budget positions 
left join pos_org_rel porb
  ON porb.positionid = PP.positionid 
 AND porb.posorgreltype = 'Budget' 
 --and porb.posorgrelevent = 'NewPos'
 and current_date between porb.effectivedate and porb.enddate
 and current_timestamp between porb.createts and porb.endts
 
left join organization_code oc_cc
  ON oc_cc.organizationid = porb.organizationid
 AND oc_cc.organizationtype = 'CC'
 and current_date between oc_cc.effectivedate and oc_cc.enddate 
 and current_timestamp between oc_cc.createts and oc_cc.endts 
 
left join pos_org_rel porm
  ON porm.positionid = PP.positionid 
 AND porm.posorgreltype = 'Member' 
 --and porb.posorgrelevent = 'NewPos'
 and current_date between porm.effectivedate and porm.enddate
 and current_timestamp between porm.createts and porm.endts 

left join organization_code oc_dept
  ON oc_dept.organizationid = porm.organizationid
 AND oc_dept.organizationtype = 'Dept'
 and current_date between oc_dept.effectivedate and oc_dept.enddate 
 and current_timestamp between oc_dept.createts and oc_dept.endts 

left join edi.lookup orgcode_lookup
  on orgcode_lookup.key1 = pi.personid
 and orgcode_lookup.lookupid = 1


left join organization_code oc
  on current_date between oc.effectivedate and oc.enddate 
 and current_timestamp between oc.createts AND oc.endts 
 and oc.organizationxid = oc_cc.organizationxid
   
LEFT JOIN position_desc pd 
  ON pd.positionid = PP.positionid 
 AND current_date between pd.effectivedate AND pd.enddate 
 AND current_timestamp between pd.createts and pd.endts
 
left join position_location pl 
  ON pl.positionid = PP.positionid
 and current_date between pl.effectivedate and pl.enddate 
 and current_timestamp between pl.createts and pl.endts 
 and pl.effectivedate - interval '1 day' <> pl.enddate

left join location_codes lc 
  ON lc.locationid = pl.locationid
 and current_date between lc.effectivedate and lc.enddate 
 and current_timestamp between lc.createts and lc.endts 
 and lc.effectivedate - interval '1 day' <> lc.enddate   
 
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
                 ,date_part('year',check_date)
                 ,coalesce(sum(etv_amount),0) as severance_pay
             FROM pspay_payment_detail            
            WHERE etv_id in  ('E30')           
              AND date_part('year', check_date)  = '2017'
              and check_number = 'DIRDEP'
            GROUP BY 1,2
          ) ytdsev
  ON ytdsev.personid = pi.personid         

              
LEFT JOIN (SELECT personid
                 ,date_part('year',check_date)
                 ,coalesce(sum(etv_amount),0) as lump_sum
             FROM pspay_payment_detail            
            WHERE etv_id in  ('ECA')           
              AND date_part('year', check_date)  = '2017'
              and check_number = 'DIRDEP'
            GROUP BY 1,2
          ) ytdls
  ON ytdls.personid = pi.personid    

           
LEFT JOIN (SELECT personid
                 ,date_part('year',check_date)
                 ,coalesce(sum(etv_amount),0) as hiring_bonus
             FROM pspay_payment_detail            
            WHERE etv_id in  ('E61')           
              AND date_part('year', check_date) = '2017'
              and check_number = 'DIRDEP'
            GROUP BY 1,2
          ) ytdhb
  ON ytdhb.personid = pi.personid    
 
LEFT JOIN (SELECT personid
                 ,date_part('year',check_date)
                 ,coalesce(sum(etv_amount),0) as CAP_bonus
             FROM pspay_payment_detail            
            WHERE etv_id in  ('EA1')           
              AND date_part('year', check_date) = '2017'
              and check_number = 'DIRDEP'
            GROUP BY 1,2
          ) ytdcapb
  ON ytdcapb.personid = pi.personid    

LEFT JOIN (SELECT personid
                 ,date_part('year',check_date)
                 ,coalesce(sum(etv_amount),0) as industry_bonus
             FROM pspay_payment_detail            
            WHERE etv_id in  ('EB1')           
              AND date_part('year', check_date) = '2017'
              and check_number = 'DIRDEP'
            GROUP BY 1,2
          ) ytdindb
  ON ytdindb.personid = pi.personid   
  
LEFT JOIN (SELECT personid
                 ,date_part('year',check_date)
                 ,coalesce(sum(etv_amount),0) as manager_bonus
             FROM pspay_payment_detail            
            WHERE etv_id in  ('EBE')           
              AND date_part('year', check_date) = '2017'
              and check_number = 'DIRDEP'
            GROUP BY 1,2
          ) ytdmgrb
  ON ytdmgrb.personid = pi.personid    

LEFT JOIN (SELECT personid
                 ,date_part('year',check_date)
                 ,coalesce(sum(etv_amount),0) as multiline_bonus
             FROM pspay_payment_detail            
            WHERE etv_id in  ('EBH')           
              AND date_part('year', check_date) = '2017'
              and check_number = 'DIRDEP'
            GROUP BY 1,2
          ) ytdmlnb
  ON ytdmlnb.personid = pi.personid    
  
LEFT JOIN (SELECT personid
                 ,date_part('year',check_date)
                 ,coalesce(sum(etv_amount),0) as officer_bonus
             FROM pspay_payment_detail            
            WHERE etv_id in  ('EA2')           
              AND date_part('year', check_date) = '2017'
              and check_number = 'DIRDEP'
            GROUP BY 1,2
          ) ytdoffb
  ON ytdoffb.personid = pi.personid    

LEFT JOIN (SELECT personid
                 ,date_part('year',check_date)
                 ,coalesce(sum(etv_amount),0) as bonus
             FROM pspay_payment_detail            
            WHERE etv_id in  ('E61')           
              AND date_part('year', check_date) = '2017'
              and check_number = 'DIRDEP'
            GROUP BY 1,2
          ) ytdb
  ON ytdb.personid = pi.personid    
--- all_bonus is used to calculate ytd fica on bonus
/*
LEFT JOIN (SELECT individual_key
                 ,ytd_earn_amount as ALL_bonus
             FROM pspay_earning_accumulators            
            WHERE etv_id in ('E61','EA1','EB1','EBE','EBH','EA2','EBI')   
              AND year = '2017'
              and current_payroll_status = 'P'
          ) ytdAb1
  ON ytdAb1.individual_key = pip.identity   
*/  
  
  --- not ,'E64' hiring bonus - this is considered an earnings and is added to the gross

LEFT JOIN (SELECT personid
                 ,date_part('year',check_date)
                 ,coalesce(sum(etv_amount),0) as ALL_bonus
             FROM pspay_payment_detail            
            WHERE etv_id in  ('E61','EA1','EB1','EBE','EBH','EA2','EBI')          
              AND date_part('year', check_date) = '2017'
              --and check_number = 'DIRDEP'
            GROUP BY 1,2
          ) ytdAb
  ON ytdAb.personid = pi.personid    
--- dependent care
left join 
      (select individual_key, etv_amount, etv_id
         from  pspay_payment_detail 
        where etv_id = 'VBB'
          AND check_date = ?::DATE
          and check_number = 'DIRDEP'          
      ) dpc
  on dpc.individual_key = pip.identity 
--- medical  
left join 
      (select individual_key, etv_amount, etv_id
         from  pspay_payment_detail 
        where etv_id = 'VBC'
          AND check_date = ?::DATE
          and check_number = 'DIRDEP'          
      ) med
  on med.individual_key = pip.identity     
--- dental
left join 
      (select individual_key, etv_amount, etv_id
         from  pspay_payment_detail 
        where etv_id = 'VBD'
          AND check_date = ?::DATE
          and check_number = 'DIRDEP'          
      ) dnt
  on dnt.individual_key = pip.identity        
--- fsa 
left join 
      (select individual_key, etv_amount, etv_id
         from  pspay_payment_detail 
        where etv_id = 'VBA'
          AND check_date = ?::DATE
          and check_number = 'DIRDEP'          
      ) fsa
  on fsa.individual_key = pip.identity         
--- vision    
left join 
      (select individual_key, etv_amount, etv_id
         from  pspay_payment_detail 
        where etv_id = 'VBE'
          AND check_date = ?::DATE
          and check_number = 'DIRDEP'          
      ) vsn
  on vsn.individual_key = pip.identity       
--- hsa
left join 
      (select individual_key, etv_amount, etv_id
         from  pspay_payment_detail 
        where etv_id = 'VEH'
          AND check_date = ?::DATE
          and check_number = 'DIRDEP'          
      ) hsa
  on hsa.individual_key = pip.identity   
--- hsa cu
left join 
      (select individual_key, etv_amount, etv_id
         from  pspay_payment_detail 
        where etv_id = 'VEJ'
          AND check_date = ?::DATE
          and check_number = 'DIRDEP'
      ) hcu
  on hcu.individual_key = pip.identity     
---- GRADEPRIOR - attempt to get prior job position data - should not contain current.    
left join 
     (
       SELECT distinct 
         sgr.personid
        ,sgr.earningscode
        ,sgr.positionid
     --   ,sgr.edtcode
        ,sgr.salarygraderegion
     --   ,sgr.grade
        ,sgr.salarygradedesc
        ,sgr.positiontitle
        ,sgr.jobcode
        ,sgr.compamount
        ,sgr.midpoint 
        ,sgr.annualsalarymax
        ,sgr.annualsalarymin
        ,CASE
               WHEN sgr.midpoint IS NOT NULL AND sgr.midpoint > 0::numeric AND (sgr.annualsalarymax - sgr.annualsalarymin) > 0::numeric THEN
               CASE
                   WHEN sgr.companyparametervalue IS NOT NULL 
                   THEN ((sgr.annualcompensation / sgr.partialpercent - sgr.annualsalarymin)::numeric(15,4) / (sgr.annualsalarymax - sgr.annualsalarymin)::numeric(15,4))::numeric(15,4)
                   ELSE (sgr.annualcompensation / sgr.partialpercent / sgr.midpoint)::numeric(15,4)
               END
               ELSE 0.00000
           END AS percent_in_range  
         ,sgr.effectivedate      
         ,sgr.increaseamount   
         ,sgr.compevent     
         ,sgr.prev_compamount 
         ,sgr.position_effectivedate
         ,TRUNC(sgr.hourly_rate,2) AS HOURLY_RATE
          
         FROM ( SELECT distinct 
                   sgr.edtcode
                  ,pc.earningscode
                  ,sgr.salarygraderegion
                  ,sgr.grade
                  ,sg.salarygradedesc
                  ,pp.personid
                  ,pp.positionid
                  ,pd.positiontitle
                  ,jd.jobcode
                  ,pc.compamount
                  ,(sgr.salaryminimum * fcsg.annualfactor)::numeric(15,4) AS annualsalarymin
                  ,(sgr.salarymaximum * fcsg.annualfactor)::numeric(15,4) AS annualsalarymax
                  ,(sgr.salaryminimum * fcsg.annualfactor)::numeric(15,4) + (((sgr.salarymaximum * fcsg.annualfactor)::numeric(15,4) - (sgr.salaryminimum * fcsg.annualfactor)::numeric(15,4)) / 2.0000)::numeric(15,4) AS midpoint
                  ,cp.companyparametervalue
                  ,CASE WHEN pc.frequencycode = 'H'::bpchar THEN pc.compamount * (pp.scheduledhours * fcpos.annualfactor)
                        ELSE (pc.compamount * fcc.annualfactor)::numeric(15,4)
                        END AS annualcompensation
                  ,CASE WHEN pp.partialpercent > 0::numeric THEN pp.partialpercent / 100.000000
                        ELSE 1::numeric
                        END AS partialpercent  
                  ,pc.effectivedate
                  ,pc.increaseamount
                  ,pc.compevent    
                  ,coalesce(prev_pc.compamount,pc.compamount) as prev_compamount 
                  ,pp.effectivedate as position_effectivedate
                  ,case when pc.frequencycode = 'A' then pc.compamount / 2080 else pc.compamount end as hourly_rate


                                                 
                 FROM salary_grade_ranges sgr
                 join salary_grade sg
                   on sg.grade = sgr.grade
                  and current_date between sg.effectivedate and sg.enddate
                  and current_timestamp between sg.createts and sg.endts
                 JOIN position_desc pd 
                   ON pd.grade = sgr.grade 
                  AND current_date between pd.effectivedate AND pd.enddate 
                  AND current_timestamp between pd.createts AND pd.endts
                 JOIN location_codes lc 
                   ON lc.salarygraderegion = sgr.salarygraderegion 
                  AND current_date between lc.effectivedate AND lc.enddate 
                  AND current_timestamp between lc.createts AND lc.endts
                 JOIN pers_pos pp 
                   ON pp.positionid = pd.positionid 
                  and current_timestamp between pp.createts and pp.endts
                  and pp.updatets is not null
                  and pp.enddate < '2199-12-31'  

                 JOIN person_locations pl 
                   ON pl.personid = pp.personid 
                  AND pl.locationid = lc.locationid              
                  AND current_date between pl.effectivedate AND pl.enddate 
                  AND current_timestamp between pl.createts AND pl.endts 

                 left join person_compensation pc 
                   on pc.personid = pp.personid
                  and current_timestamp between pc.createts and pc.endts 
                  and pc.updatets is not null
                  and pc.enddate < '2199-12-31'                                 
                 left join position_job pj
                   on pj.positionid = PP.positionid
                  and current_date between pj.effectivedate and pj.enddate
                  and current_timestamp between pj.createts and pj.endts
                 left join job_desc jd
                   on jd.jobid = pj.jobid
                  and current_date between jd.effectivedate and jd.enddate
                  and current_timestamp between jd.createts and jd.endts
                 JOIN frequency_codes fcc 
                   ON fcc.frequencycode = pc.frequencycode
                 JOIN frequency_codes fcpos 
                   ON fcpos.frequencycode = pp.schedulefrequency
                 JOIN frequency_codes fcsg 
                   ON fcsg.frequencycode = pc.frequencycode

                 LEFT JOIN company_parameters cp 
                   ON cp.companyparametername = 'PIRB'::bpchar 
                  AND cp.companyparametervalue::text = 'MIN'::text
                                    
                 left join person_compensation prev_pc
                   on prev_pc.personid = pc.personid
                  and prev_pc.percomppid = pc.percomppid - 1                     
                                      
            where pc.earningscode = sgr.edtcode 
             -- and pp.personid in ('63066', '62958','63258','66371','63071','63613','63032','63402','63064','65527','66127','63239')
          --  and pp.personid = '65527'               

        ) sgr
     ) GRADEPRIOR on GRADEPRIOR.personid = pi.personid 

---- Picks up termed or retired
left join 
     (

       SELECT distinct 
         sgrtrm.personid
        ,sgrtrm.positionid
        ,sgrtrm.scheduledhours
        ,sgrtrm.earningscode
        ,sgrtrm.salarygradedesc
        ,sgrtrm.grade
        ,sgrtrm.salarygraderegion
        ,sgrtrm.compamount
        ,sgrtrm.orgcode
        ,sgrtrm.organizationid
        ,CASE
               WHEN sgrtrm.midpoint IS NOT NULL AND sgrtrm.midpoint > 0::numeric AND (sgrtrm.annualsalarymax - sgrtrm.annualsalarymin) > 0::numeric THEN
               CASE
                   WHEN sgrtrm.companyparametervalue IS NOT NULL 
                   THEN ((sgrtrm.annualcompensation / sgrtrm.partialpercent - sgrtrm.annualsalarymin)::numeric(15,3) / (sgrtrm.annualsalarymax - sgrtrm.annualsalarymin)::numeric(15,3))::numeric(15,3)
                   ELSE (sgrtrm.annualcompensation / sgrtrm.partialpercent / sgrtrm.midpoint)::numeric(15,3)
               END
               ELSE 0.00000        
         END AS percent_in_range           
        ,sgrtrm.effectivedate
        ,sgrtrm.enddate
        ,sgrtrm.createts
        ,sgrtrm.endts          
        ,sgrtrm.increaseamount
        ,sgrtrm.compevent
        ,sgrtrm.prev_compamount    
        ,sgrtrm.position_effectivedate     
        ,sgrtrm.jobcode   
        ,sgrtrm.positiontitle   
        ,TRUNC(sgrtrm.hourly_rate,2) AS HOURLY_RATE
              
         FROM ( 
                SELECT distinct            
                  pi.personid
                 ,pp.positionid
                 ,pp.scheduledhours
                 ,pc.earningscode
                 ,sg.salarygradedesc
                 ,sg.grade
                 ,sgr.salarygraderegion
                 ,pc.compamount
                 ,pc.increaseamount
                 ,pc.effectivedate
                 ,coalesce(pc.compamount,prev_pc.compamount) as prev_compamount
                 ,pc.compevent
                 ,porb.orgcode
                 ,porb.organizationid
                 ,(sgr.salaryminimum * fcsg.annualfactor)::numeric(15,4) AS annualsalarymin
                 ,(sgr.salarymaximum * fcsg.annualfactor)::numeric(15,4) AS annualsalarymax
                 ,(sgr.salaryminimum * fcsg.annualfactor)::numeric(15,4) + (((sgr.salarymaximum * fcsg.annualfactor)::numeric(15,4) - (sgr.salaryminimum * fcsg.annualfactor)::numeric(15,4)) / 2.0000)::numeric(15,4) AS midpoint
                 ,cp.companyparametervalue
                 ,CASE WHEN pc.frequencycode = 'H'::bpchar THEN pc.compamount * (pp.scheduledhours * fcpos.annualfactor)
                       ELSE (pc.compamount * fcc.annualfactor)::numeric(15,4)
                       END AS annualcompensation
                 ,CASE WHEN pp.partialpercent > 0::numeric THEN pp.partialpercent / 100.000000
                       ELSE 1::numeric
                       END AS partialpercent 
                                      
                 ,pc.enddate
                 ,pc.createts
                 ,pc.endts        
                 ,pp.effectivedate as position_effectivedate
                 ,jd.jobcode                 
                 ,pd.positiontitle  
                 ,case when pc.frequencycode = 'A' then pc.compamount / 2080 else pc.compamount end as hourly_rate                      
                 
                 from person_identity pi
                 
                 join person_employment pe
                   on pe.personid = pi.personid
                  and current_date between pe.effectivedate and pe.enddate
                  and current_timestamp between pe.createts and pe.endts
                  and pe.emplstatus = 'T'
                  --select * from person_employment where personid in ('63064','63066') and current_date between effectivedate and enddate and current_timestamp between createts and endts

                 join ( 
                        select
                            pi.personid
                           ,comp.percomppid
                           ,comp.compamount
                           ,comp.earningscode
                           ,comp.increaseamount
                           ,comp.effectivedate
                           ,comp.compevent
                           ,COMP.frequencycode
                           ,comp.enddate
                           ,comp.createts
                           ,comp.endts
    
                         from person_identity pi
    
                         join (select personid,  max(percomppid) as max_percomppid from person_compensation where current_timestamp between createts and endts group by 1) maxid
                           on maxid.personid = pi.personid
                         join (select personid, compamount, earningscode, percomppid,increaseamount,effectivedate,compevent,frequencycode,
                                      enddate,createts,endts
                                 from person_compensation where current_timestamp between createts and endts) comp 
                           on comp.personid = pi.personid
                          and comp.percomppid  = maxid.max_percomppid  
    
                        where pi.identitytype = 'SSN'
                          and current_timestamp between pi.createts and pi.endts
                          --and pi.personid in ('63064','63066')
                       ) pc
                   on pc.personid = pi.personid
                  
              

                 left JOIN pers_pos pp 
                   ON pp.personid = pi.personid
                  and pp.updatets is not null
                  --AND current_timestamp between pp.createts AND pp.endts
                  --select * from pers_pos where personid in ('63064','63066') and current_date between effectivedate and enddate and current_timestamp between createts and endts
                 
                 JOIN person_locations pl 
                   ON pl.personid = pi.personid 
                  --AND pl.locationid = lc.locationid              
                  AND current_date between pl.effectivedate AND pl.enddate 
                  AND current_timestamp between pl.createts AND pl.endts                   
                  --select * from person_locations where current_date between effectivedate and enddate and current_timestamp between createts and endts and personid in ('63064','63066')

                  join 
                  (
                    select distinct
                          pi.personid
                         ,PP.positionid 
                         ,PP.EFFECTIVEDATE
                         ,PP.ENDDATE
                         ,porb.organizationid
                         ,porb.posorgrelevent
                         ,porb.effectivedate
                         ,porb.enddate      
                         ,oc_cc.orgcode   
                         ,oc_cc.organizationxid    
                                                                                              
                     from person_identity pi
                     
                     JOIN pers_pos pp 
                       ON pp.personid = pi.personid
                      and pp.updatets is not null     
                      and pp.persposevent in ('Promo')
                      --and current_date between pp.effectivedate and pp.enddate
                      AND CURRENT_TIMESTAMP BETWEEN PP.CREATETS AND PP.ENDTS  

                     join pos_org_rel porb 
                       ON porb.positionid = PP.positionid 
                      AND porb.posorgreltype = 'Budget' 
                      and current_timestamp between porb.createts and porb.endts
                      and porb.posorgrelevent = 'NewPos'
                        
                     join organization_code oc_cc
                       ON oc_cc.organizationid = porb.organizationid
                      AND oc_cc.organizationtype = 'CC'

                      and current_timestamp between oc_cc.createts and oc_cc.endts 
                      and oc_cc.effectivedate - interval '1 day' <> oc_cc.enddate 
                      
                      join person_employment pe
                       on pe.personid = pi.personid
                      and current_date between pe.effectivedate and pe.enddate
                      and current_timestamp between pe.createts and pe.endts
                      --and pe.emplstatus in ('T','R')                      
                      
                     where pi.identitytype = 'SSN'
                       and current_timestamp between pi.createts and pi.endts
                       --and pi.personid in ('66266')
                  
                  
                  ) porb 
                    on porb.personid = pi.personid
                  
                 left join organization_code oc
                   on current_date between oc.effectivedate and oc.enddate 
                  and current_timestamp between oc.createts AND oc.endts 
                  and oc.organizationxid = porb.organizationxid

                 JOIN position_desc pd 
                   ON pd.positionid = pp.positionid
                  --AND current_date between pd.effectivedate AND pd.enddate 
                  AND current_timestamp between pd.createts AND pd.endts

                 join salary_grade sg
                   on sg.grade = pd.grade
                  and current_date between sg.effectivedate and sg.enddate
                  and current_timestamp between sg.createts and sg.endts

                 JOIN location_codes lc 
                   ON lc.locationid = pl.locationid 
                  AND current_date between lc.effectivedate AND lc.enddate 
                  AND current_timestamp between lc.createts AND lc.endts
                  
                 join salary_grade_ranges sgr
                   on sgr.grade = sg.grade 
                  and sgr.salarygraderegion = lc.salarygraderegion 
                  and current_date between sgr.effectivedate and sgr.enddate
                  and current_timestamp between sgr.createts and sgr.endts        
                  
                 left join person_compensation prev_pc
                   on prev_pc.personid = pc.personid
                  and prev_pc.percomppid = pc.percomppid - 1  
                 
                 LEFT JOIN company_parameters cp 
                   ON cp.companyparametername = 'PIRB'::bpchar 
                  AND cp.companyparametervalue::text = 'MIN'::text

                 left join position_job pj
                   on pj.positionid = PP.positionid
                  and current_date between pj.effectivedate and pj.enddate
                  and current_timestamp between pj.createts and pj.endts                  
                 left join job_desc jd
                   on jd.jobid = pj.jobid
                  and current_date between jd.effectivedate and jd.enddate
                  and current_timestamp between jd.createts and jd.endts                     
                  
                 JOIN frequency_codes fcc 
                   ON fcc.frequencycode = pc.frequencycode
                 JOIN frequency_codes fcpos 
                   ON fcpos.frequencycode = pp.schedulefrequency
                 JOIN frequency_codes fcsg 
                   ON fcsg.frequencycode = pc.frequencycode
                                        
                 join pspay_payment_detail ppd
                   on ppd.personid = pp.personid
                  and date_part('year',ppd.check_date)=date_part('year',current_date - interval '1 year')  
                  and PPD.etv_id in  ('E01','E64','EB5','E05','EB8','E15','E16','E17','E18','E19','E20',
                                      'ECA','EAJ','EAR','EB4','EAK','E30','EBF','E61','EA1','EB1','EBE',
                                      'EBH','EA2','VBB','VBC','VBD','VBA','VBE','VEH','VEJ') 
                  and ppd.check_number = 'DIRDEP'
             
            where pi.identitytype = 'SSN'
              and current_timestamp between pi.createts and pi.endts
              --and pi.personid in ('63066', '63064')
               --and pp.personid in ('63066', '62958','63258','66371','63071','63613','63032','63402','63064','65527','66127','63239')
              --and pp.personid = '65527'  
       ) sgrtrm
     
     ) GRADETRM on GRADETRM.personid = pi.personid and current_timestamp between GRADETRM.createts and GRADETRM.endts    
  
--- provides current job salary position data          
left join 
     (

       SELECT distinct 
         sgrcurr.personid
        ,sgrcurr.earningscode
        ,sgrcurr.positionid
        ,sgrcurr.edtcode
        ,sgrcurr.salarygraderegion
        ,sgrcurr.grade
        ,sgrcurr.salarygradedesc
        ,sgrcurr.positiontitle
        ,sgrcurr.jobcode
        ,sgrcurr.compamount
        ,CASE
               WHEN sgrcurr.midpoint IS NOT NULL AND sgrcurr.midpoint > 0::numeric AND (sgrcurr.annualsalarymax - sgrcurr.annualsalarymin) > 0::numeric THEN
               CASE
                   WHEN sgrcurr.companyparametervalue IS NOT NULL 
                   THEN ((sgrcurr.annualcompensation / sgrcurr.partialpercent - sgrcurr.annualsalarymin)::numeric(15,4) / (sgrcurr.annualsalarymax - sgrcurr.annualsalarymin)::numeric(15,4))::numeric(15,4)
                   ELSE (sgrcurr.annualcompensation / sgrcurr.partialpercent / sgrcurr.midpoint)::numeric(15,4)
               END
               ELSE 0.00000
           END AS percent_in_range    
         ,sgrcurr.effectivedate    
         ,sgrcurr.increaseamount
         ,sgrcurr.compevent
         ,sgrcurr.prev_compamount   
         ,sgrcurr.position_effectivedate  
         ,TRUNC(sgrcurr.hourly_rate,2) AS HOURLY_RATE
         
               
         FROM ( SELECT distinct 
                   sgr.edtcode
                  ,pc.earningscode
                  ,sgr.salarygraderegion
                  ,sgr.grade
                  ,sg.salarygradedesc
                  ,pp.personid
                  ,pp.positionid
                  ,pd.positiontitle
                  ,jd.jobcode
                  ,pc.compamount
                  ,pc.effectivedate
                  ,pc.enddate
                  ,pc.createts
                  ,pc.endts                
                  
                  ,(sgr.salaryminimum * fcsg.annualfactor)::numeric(15,4) AS annualsalarymin
                  ,(sgr.salarymaximum * fcsg.annualfactor)::numeric(15,4) AS annualsalarymax
                  ,(sgr.salaryminimum * fcsg.annualfactor)::numeric(15,4) + (((sgr.salarymaximum * fcsg.annualfactor)::numeric(15,4) - (sgr.salaryminimum * fcsg.annualfactor)::numeric(15,4)) / 2.0000)::numeric(15,5) AS midpoint
                  ,cp.companyparametervalue
                  ,CASE WHEN pc.frequencycode = 'H'::bpchar THEN pc.compamount * (pp.scheduledhours * fcpos.annualfactor)
                        ELSE (pc.compamount * fcc.annualfactor)::numeric(15,4)
                        END AS annualcompensation
                 ,CASE WHEN pp.partialpercent > 0::numeric THEN pp.partialpercent / 100.000000
                       ELSE 1::numeric
                       END AS partialpercent   
                 ,pc.increaseamount   
                 ,pc.compevent        
                 ,coalesce(prev_pc.compamount,pc.compamount) as prev_compamount   
                 ,pp.effectivedate as position_effectivedate       
                 ,case when pc.frequencycode = 'A' then pc.compamount / 2080 else pc.compamount end as hourly_rate                       
                                    
                 FROM salary_grade_ranges sgr
                 join salary_grade sg
                   on sg.grade = sgr.grade
                  and current_date between sg.effectivedate and sg.enddate
                  and current_timestamp between sg.createts and sg.endts
                 JOIN position_desc pd 
                   ON pd.grade = sgr.grade 
                  AND current_date between pd.effectivedate AND pd.enddate 
                  AND current_timestamp between pd.createts AND pd.endts
                 JOIN location_codes lc 
                   ON lc.salarygraderegion = sgr.salarygraderegion 
                  AND current_date between lc.effectivedate AND lc.enddate 
                  AND current_timestamp between lc.createts AND lc.endts
                 JOIN pers_pos pp 
                   ON pp.positionid = pd.positionid 
                  and current_date between pp.effectivedate and pp.enddate
                  and current_timestamp between pp.createts and pp.endts
                  --and pp.updatets is null  
                 JOIN person_locations pl 
                   ON pl.personid = pp.personid 
                  AND pl.locationid = lc.locationid              
                  AND current_date between pl.effectivedate AND pl.enddate 
                  AND current_timestamp between pl.createts AND pl.endts 
                 LEFT JOIN company_parameters cp 
                   ON cp.companyparametername = 'PIRB'::bpchar 
                  AND cp.companyparametervalue::text = 'MIN'::text
                 left join person_compensation pc 
                   on pc.personid = pp.personid
                  and current_date between pc.effectivedate and pc.enddate
                  and current_timestamp between pc.createts and pc.endts
                  and pc.effectivedate < '2018-01-01'  -- can't include anyone that's had a raise in jan.                  
                 left join position_job pj
                   on pj.positionid = PP.positionid
                  and current_date between pj.effectivedate and pj.enddate
                  and current_timestamp between pj.createts and pj.endts
                 left join job_desc jd
                   on jd.jobid = pj.jobid
                  and current_date between jd.effectivedate and jd.enddate
                  and current_timestamp between jd.createts and jd.endts
                 JOIN frequency_codes fcc 
                   ON fcc.frequencycode = pc.frequencycode
                 JOIN frequency_codes fcpos 
                   ON fcpos.frequencycode = pp.schedulefrequency
                 JOIN frequency_codes fcsg 
                   ON fcsg.frequencycode = pc.frequencycode
                                                        
                   
                 left join person_compensation prev_pc
                   on prev_pc.personid = pc.personid
                  and prev_pc.percomppid = pc.percomppid - 1                       
                  
            where pc.earningscode = sgr.edtcode 
              --and pp.personid in ('63066', '62958','63258','66371','63071','63613','63032','63402','63064','65527','66127','63239')
            --and pp.personid = '63071'
        ) sgrcurr
             
     ) GRADECURR on GRADECURR.personid = pi.personid          
 
 
left join 
(
       SELECT distinct 
         sgr.personid
        ,sgr.earningscode
        ,sgr.positionid
    --    ,sgr.edtcode
        ,sgr.salarygraderegion
     --   ,sgr.grade
        ,sgr.salarygradedesc
        ,sgr.positiontitle
        ,sgr.jobcode
        ,sgr.compamount
        ,sgr.midpoint 
        ,sgr.annualsalarymax
        ,sgr.annualsalarymin
        ,CASE
               WHEN sgr.midpoint IS NOT NULL AND sgr.midpoint > 0::numeric AND (sgr.annualsalarymax - sgr.annualsalarymin) > 0::numeric THEN
               CASE
                   WHEN sgr.companyparametervalue IS NOT NULL 
                   THEN ((sgr.annualcompensation / sgr.partialpercent - sgr.annualsalarymin)::numeric(15,4) / (sgr.annualsalarymax - sgr.annualsalarymin)::numeric(15,4))::numeric(15,4)
                   ELSE (sgr.annualcompensation / sgr.partialpercent / sgr.midpoint)::numeric(15,4)
               END
               ELSE 0.00000
           END AS percent_in_range  
         ,sgr.effectivedate      
         ,sgr.increaseamount   
         ,sgr.compevent     
         ,sgr.prev_compamount 
         ,sgr.position_effectivedate
         ,TRUNC(sgr.hourly_rate,2) AS HOURLY_RATE
          
         FROM ( SELECT distinct 
                 --  sgr.edtcode
                   pc.earningscode
                  ,sgr.salarygraderegion
                  --,sgr.grade
                  ,sg.salarygradedesc
                  ,pp.personid
                  ,pp.positionid
                  ,pd.positiontitle
                  ,jd.jobcode
                  ,pc.compamount
                  ,(sgr.salaryminimum * fcsg.annualfactor)::numeric(15,4) AS annualsalarymin
                  ,(sgr.salarymaximum * fcsg.annualfactor)::numeric(15,4) AS annualsalarymax
                  ,(sgr.salaryminimum * fcsg.annualfactor)::numeric(15,4) + (((sgr.salarymaximum * fcsg.annualfactor)::numeric(15,4) - (sgr.salaryminimum * fcsg.annualfactor)::numeric(15,4)) / 2.0000)::numeric(15,4) AS midpoint
                  ,cp.companyparametervalue
                  ,CASE WHEN pc.frequencycode = 'H'::bpchar THEN pc.compamount * (pp.scheduledhours * fcpos.annualfactor)
                        ELSE (pc.compamount * fcc.annualfactor)::numeric(15,4)
                        END AS annualcompensation
                  ,CASE WHEN pp.partialpercent > 0::numeric THEN pp.partialpercent / 100.000000
                        ELSE 1::numeric
                        END AS partialpercent  
                  ,pc.effectivedate
                  ,pc.increaseamount
                  ,pc.compevent    
                  ,coalesce(prev_pc.compamount,pc.compamount) as prev_compamount 
                  ,pp.effectivedate as position_effectivedate
                  ,case when pc.frequencycode = 'A' then pc.compamount / 2080 else pc.compamount end as hourly_rate


                                                 
                 FROM salary_grade_ranges sgr
                 
                 join salary_grade sg
                   on sg.grade = sgr.grade
                  and current_date between sg.effectivedate and sg.enddate
                  and current_timestamp between sg.createts and sg.endts
                             
                 JOIN position_desc pd 
                   ON pd.grade = sgr.grade 
                 -- AND current_date between pd.effectivedate AND pd.enddate 
                  AND current_timestamp between pd.createts AND pd.endts   

                 JOIN location_codes lc 
                   ON lc.salarygraderegion = sgr.salarygraderegion 
                  AND current_date between lc.effectivedate AND lc.enddate 
                  AND current_timestamp between lc.createts AND lc.endts
                  
                 JOIN pers_pos pp 
                   ON pp.positionid = pd.positionid 
                  --and current_timestamp between pp.createts and pp.endts
                  --and pp.updatets is not null
                  --and pp.effectivedate <> '2018-01-01'  
                 JOIN person_locations pl 
                   ON pl.personid = pp.personid 
                  AND pl.locationid = lc.locationid              
                  AND current_date between pl.effectivedate AND pl.enddate 
                  AND current_timestamp between pl.createts AND pl.endts 

                 left join person_compensation pc 
                   on pc.personid = pp.personid
                  and current_timestamp between pc.createts and pc.endts 
                  and pc.updatets is not null
                  and pc.effectivedate <> '2018-01-01'                                      
 
                  left join position_job pj
                   on pj.positionid = PP.positionid
                  --and current_date between pj.effectivedate and pj.enddate
                  and current_timestamp between pj.createts and pj.endts
                  
                 left join job_desc jd
                   on jd.jobid = pj.jobid
                  and current_date between jd.effectivedate and jd.enddate
                  and current_timestamp between jd.createts and jd.endts         

                 JOIN frequency_codes fcc 
                   ON fcc.frequencycode = pc.frequencycode
                 JOIN frequency_codes fcpos 
                   ON fcpos.frequencycode = pp.schedulefrequency
                 JOIN frequency_codes fcsg 
                   ON fcsg.frequencycode = pc.frequencycode

                 LEFT JOIN company_parameters cp 
                   ON cp.companyparametername = 'PIRB'::bpchar 
                  AND cp.companyparametervalue::text = 'MIN'::text
                                    
                 left join person_compensation prev_pc
                   on prev_pc.personid = pc.personid
                  and prev_pc.percomppid = pc.percomppid - 1                                                                                     
                  
                  where sgr.frequencycode = pc.frequencycode  -- pd.positionid in ('401113')
           --  and pp.personid = '65993'               

        ) sgr 
 
     ) GRADE on GRADE.personid = pi.personid          
 

 
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts


 -- and f3_accounting_unit is not null
  --and pi.personid in ('63066', '62958','63258','66371','63071','63613','63032','63402','63064','65527','66127','63239')
  --and pi.personid = '63066'
 --AND PI.PERSONID = '66002'

  --
  order by f5_emp_name