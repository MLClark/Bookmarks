select DISTINCT

 pi.personid
--,ytdfica.fica
--,ytdss.social_security
,pip.identity
--,ytdmc.medicare
--,ytdab.ALL_bonus
--- use the personids to find out where an EE's values are coming 
,GRADECURR.personid as curr
,GRADE.personid as grade
,GRADEPRIOR.personid as prior
,GRADERT.personid as rt
,GRADETRM.personid as trm

,GRADELOA.personid as loa
,GRADETRMP.personid as trmp
,GRADEU.personid as gradeu
,GRADECURR1.personid as curr1
,to_char(?::date,'yyyy') as f1_curyy
,to_char(?::date,'mm') as f2_cur_mm 

---- Note giving GRADEU.orgcode highest priority for f3_accounting_unit to correct Deanna Abrams accounting unit
,coalesce(coalesce(GRADECURR.orgcode,GRADECURR1.orgcode,GRADE.orgcode,GRADELOA.orgcode,GRADEPRIOR.orgcode),
          coalesce(GRADEU.orgcode,GRADETRM.orgcode,GRADETRMP.orgcode,GRADERT.orgcode)) as f3_accounting_unit

,pie.identity as f4_empnbr 
,pn.lname||', '||pn.fname||' '||COALESCE(pn.mname,'') ::varchar(60) as f5_emp_name 


,coalesce(coalesce(GRADECURR.jobcode,GRADECURR1.jobcode,GRADE.jobcode,GRADELOA.jobcode,GRADEPRIOR.jobcode),
          coalesce(GRADEU.jobcode,GRADETRM.jobcode,GRADETRMP.jobcode,GRADERT.jobcode)) as f6_job_title_cd


,coalesce(coalesce(GRADECURR.positiontitle,GRADECURR1.positiontitle,GRADE.positiontitle,GRADELOA.positiontitle,GRADEPRIOR.positiontitle),
          coalesce(GRADEU.positiontitle,GRADETRM.positiontitle,GRADETRMP.positiontitle,GRADERT.positiontitle)) as f7_position_title

,coalesce(coalesce(GRADECURR.salarygradedesc,GRADECURR1.salarygradedesc,GRADE.salarygradedesc,GRADELOA.salarygradedesc,GRADEPRIOR.salarygradedesc),
          coalesce(GRADEU.salarygradedesc,GRADETRM.salarygradedesc,GRADETRMP.salarygradedesc,GRADERT.salarygradedesc)) as f8_job_family_code

--,case when pd.flsacode = 'E' then 'Exempt' else 'Non-Exempt' END ::CHAR(10) as f9_flsa_code
,case when coalesce (GRADECURR.flsacode,GRADECURR1.flsacode,GRADEU.flsacode,GRADETRM.flsacode,GRADETRMP.flsacode,GRADE.flsacode,GRADELOA.flsacode,GRADEPRIOR.flsacode,GRADERT.flsacode) = 'E' then 'Exempt' 
      else 'Non-Exempt' END ::CHAR(10) as f9_flsa_code
,case when pe.emplclass = 'F' then 'Full Time' else 'Part Time' end ::char(10) as f10_o46_emp_class
,case when pe.emplpermanency = 'P' then 'Permanent' else 'Temporary' end ::char(10) as f11_o47_emp_type

,coalesce(pp.scheduledhours,GRADETRM.scheduledhours) as f12_o49_scheduled_hours
--,GRADECURR.locationCode
,case when GRADECURR.locationCode  = 'HO' then GRADECURR.locationCode
      when GRADECURR1.locationCode = 'HO' then GRADECURR1.locationCode
      when GRADEU.locationCode  = 'HO' then GRADEU.locationCode  
      when GRADETRM.locationCode   = 'HO' then GRADETRM.locationCode 
      when GRADE.locationCode      = 'HO' then GRADE.locationCode
      when GRADELOA.locationCode   = 'HO' then GRADELOA.locationCode 
      when GRADEPRIOR.locationCode = 'HO' then GRADEPRIOR.locationCode 
      when GRADERT.locationCode    = 'HO' then GRADERT.locationCode 
      else 'FIELD' end as f13_o10_location
      
,coalesce(coalesce(GRADECURR.locationcode,GRADECURR1.locationcode,GRADE.locationcode,GRADELOA.locationcode,GRADEPRIOR.locationcode),
          coalesce(GRADEU.locationcode,GRADETRM.locationcode,GRADETRMP.locationcode,GRADERT.locationcode))  as f14_o50_location_desc

,' ' ::char(1) as f15_o51_remote_ind



,case when coalesce(GRADECURR.locationcode,GRADECURR1.locationcode,GRADEU.locationcode,GRADETRM.locationcode,GRADETRMP.locationcode,GRADE.locationcode,GRADELOA.locationcode,GRADEPRIOR.locationcode,GRADERT.locationcode) = 'HO' then 'A'
      when coalesce(GRADECURR.locationcode,GRADECURR1.locationcode,GRADEU.locationcode,GRADETRM.locationcode,GRADETRMP.locationcode,GRADE.locationcode,GRADELOA.locationcode,GRADEPRIOR.locationcode,GRADERT.locationcode) = 'Area A' then 'A'
      when coalesce(GRADECURR.locationcode,GRADECURR1.locationcode,GRADEU.locationcode,GRADETRM.locationcode,GRADETRMP.locationcode,GRADE.locationcode,GRADELOA.locationcode,GRADEPRIOR.locationcode,GRADERT.locationcode) = 'Raleigh' then 'A' 
      when coalesce(GRADECURR.locationcode,GRADECURR1.locationcode,GRADEU.locationcode,GRADETRM.locationcode,GRADETRMP.locationcode,GRADE.locationcode,GRADELOA.locationcode,GRADEPRIOR.locationcode,GRADERT.locationcode) = 'Dallas' then 'A' 
      when coalesce(GRADECURR.locationcode,GRADECURR1.locationcode,GRADEU.locationcode,GRADETRM.locationcode,GRADETRMP.locationcode,GRADE.locationcode,GRADELOA.locationcode,GRADEPRIOR.locationcode,GRADERT.locationcode) = 'Area B' then 'B'
      when coalesce(GRADECURR.locationcode,GRADECURR1.locationcode,GRADEU.locationcode,GRADETRM.locationcode,GRADETRMP.locationcode,GRADE.locationcode,GRADELOA.locationcode,GRADEPRIOR.locationcode,GRADERT.locationcode) = 'Area C' then 'C'
      when coalesce(GRADECURR.locationcode,GRADECURR1.locationcode,GRADEU.locationcode,GRADETRM.locationcode,GRADETRMP.locationcode,GRADE.locationcode,GRADELOA.locationcode,GRADEPRIOR.locationcode,GRADERT.locationcode) = 'Area D' then 'D'
           
      end ::char(1) as f16_o11_sgr_cognos_code
      

--- HOURLY RATE * HOURS * DIF RATE .07 = SHIFT DIF AMT
-- I NEED TO SHIFT DIF AMT / HOURS * HOURLY RATE?
--,sdrate.shift_dif_amt 
--,GRADETRM.hourly_rate
--,GRADETRM.scheduledhours
,CASE WHEN GRADECURR.hourly_rate IS NOT NULL THEN 
      coalesce(to_char(trunc (sdrate.shift_dif_amt / (GRADECURR.hourly_rate * pp.scheduledhours),4),'99D9999'),'00.0000')
      WHEN GRADECURR1.hourly_rate IS NOT NULL THEN 
      coalesce(to_char(trunc (sdrate.shift_dif_amt / (GRADECURR1.hourly_rate * pp.scheduledhours),4),'99D9999'),'00.0000')      
      WHEN GRADEU.hourly_rate IS NOT NULL THEN 
      coalesce(to_char(trunc (sdrate.shift_dif_amt / (GRADEU.hourly_rate * pp.scheduledhours),4),'99D9999'),'00.0000')      
      WHEN GRADETRM.hourly_rate IS NOT NULL THEN 
      coalesce(to_char(trunc (sdrate.shift_dif_amt / (GRADETRM.hourly_rate * GRADETRM.scheduledhours),4),'99D9999'),'00.0000')
      WHEN GRADETRMP.hourly_rate IS NOT NULL THEN 
      coalesce(to_char(trunc (sdrate.shift_dif_amt / (GRADETRMP.hourly_rate * pp.scheduledhours),4),'99D9999'),'00.0000')
      WHEN GRADE.hourly_rate IS NOT NULL THEN 
      coalesce(to_char(trunc (sdrate.shift_dif_amt / (GRADE.hourly_rate * pp.scheduledhours),4),'99D9999'),'00.0000')
      WHEN GRADELOA.hourly_rate IS NOT NULL THEN 
      coalesce(to_char(trunc (sdrate.shift_dif_amt / (GRADELOA.hourly_rate * pp.scheduledhours),4),'99D9999'),'00.0000')
      WHEN GRADEPRIOR.hourly_rate IS NOT NULL THEN 
      coalesce(to_char(trunc (sdrate.shift_dif_amt / (GRADEPRIOR.hourly_rate * pp.scheduledhours),4),'99D9999'),'00.0000')
      WHEN GRADERT.hourly_rate IS NOT NULL THEN 
      coalesce(to_char(trunc (sdrate.shift_dif_amt / (GRADERT.hourly_rate * pp.scheduledhours),4),'99D9999'),'00.0000')      
       
      else '00.0000' END AS f17_O12_shift_differential_rate


,case when pc.effectivedate = '2018-01-01' then 
      to_char(coalesce((GRADECURR.compamount - GRADECURR.increaseamount),(GRADECURR1.compamount - GRADECURR1.increaseamount),(GRADE.compamount - GRADE.increaseamount),(GRADELOA.compamount  - GRADELOA.increaseamount),(GRADEPRIOR.compamount- GRADEPRIOR.increaseamount),
              coalesce((GRADEU.compamount - GRADEU.increaseamount),(GRADETRM.compamount  - GRADETRM.increaseamount),(GRADERT.compamount   - GRADERT.increaseamount))),'00000000d00')                      
      else 
      to_char(coalesce(GRADECURR.compamount,GRADECURR1.compamount,coalesce(GRADEU.compamount,GRADETRM.compamount,GRADETRMP.compamount,GRADERT.compamount),GRADE.compamount,GRADELOA.compamount,GRADEPRIOR.compamount),'00000000d00') end as f18_o13_ee_annual_salary



,trunc(coalesce(coalesce(GRADECURR.percent_in_range,GRADECURR1.percent_in_range,GRADE.percent_in_range,GRADELOA.percent_in_range,GRADEPRIOR.percent_in_range),
                coalesce(GRADEU.percent_in_range,GRADETRM.percent_in_range,GRADETRMP.percent_in_range,GRADERT.percent_in_range)),4) 
                as f19_o14_pct_in_range


,to_char(coalesce(coalesce(GRADECURR.effectivedate,GRADECURR1.effectivedate,GRADELOA.effectivedate,GRADE.effectivedate,GRADEPRIOR.effectivedate),
                  coalesce(GRADEU.effectivedate,GRADERT.effectivedate,GRADETRM.effectivedate,GRADETRMP.effectivedate)),'mm/dd/yy') 
                  as f20_o15_sal_change_date


,case when GRADECURR.increaseamount <> 0 and GRADECURR.prev_compamount <> 0 then round((GRADECURR.increaseamount / GRADECURR.prev_compamount) * 100, 2 )
      when GRADECURR1.increaseamount <> 0 and GRADECURR1.prev_compamount <> 0 then round((GRADECURR1.increaseamount / GRADECURR1.prev_compamount) * 100, 2 )
      when GRADEU.increaseamount <> 0 and GRADEU.prev_compamount <> 0 then round((GRADEU.increaseamount / GRADEU.prev_compamount)* 100, 2 )
      when GRADETRM.increaseamount <> 0 and GRADETRM.prev_compamount <> 0 then round((GRADETRM.increaseamount / GRADETRM.prev_compamount)* 100, 2 )
      when GRADETRMP.increaseamount <> 0 and GRADETRMP.prev_compamount <> 0 then round((GRADETRMP.increaseamount / GRADETRMP.prev_compamount)* 100, 2 )      
      when GRADE.increaseamount <> 0 and GRADE.prev_compamount <> 0 then round((GRADE.increaseamount / GRADE.prev_compamount)* 100, 2 )
      when GRADELOA.increaseamount <> 0 and GRADELOA.prev_compamount <> 0 then round((GRADELOA.increaseamount / GRADELOA.prev_compamount)* 100, 2 )
      when GRADEPRIOR.increaseamount <> 0 and GRADEPRIOR.prev_compamount <> 0 then round((GRADEPRIOR.increaseamount / GRADEPRIOR.prev_compamount)* 100, 2 )      
      when GRADERT.increaseamount <> 0 and GRADERT.prev_compamount <> 0 then round((GRADERT.increaseamount / GRADERT.prev_compamount)* 100, 2 )      
      else 0 end as f21_o18_current_comp_chg_pct

,to_char(coalesce(coalesce(GRADECURR.increaseamount,GRADECURR1.increaseamount,GRADE.increaseamount,GRADELOA.increaseamount,GRADEPRIOR.increaseamount),
                  coalesce(GRADEU.increaseamount,GRADETRM.increaseamount,GRADETRMP.increaseamount,GRADERT.increaseamount),0),'00000009d00') 
                  as f22_o19_comp_change_amount


,coalesce(coalesce(GRADECURR.compevent,GRADECURR1.compevent,GRADE.compevent,GRADELOA.compevent,GRADEPRIOR.compevent),
          coalesce(GRADEU.compevent,GRADETRM.compevent,GRADETRMP.compevent,GRADERT.compevent),' ') as f23_o20_cognos_comp_code


,to_char(coalesce(coalesce(GRADECURR.prev_compamount,GRADECURR1.prev_compamount,GRADE.prev_compamount,GRADELOA.prev_compamount,GRADEPRIOR.prev_compamount),
                  coalesce(GRADEU.prev_compamount,GRADETRM.prev_compamount,GRADETRMP.prev_compamount,GRADERT.prev_compamount),0),'00000009d00')  
                  as f24_o21_prev_annual_salary   

,pufv3.ufvalue as f25_o16_perf_review_desc
,case when pufv2.ufvalue in ('Y','Regular','Combined') then ' ' else pufv2.ufvalue end as f26_o17_perf_review_rating
--,pe.emplevent
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

,to_char(coalesce(GRADECURR.position_effectivedate,coalesce(GRADEU.position_effectivedate,GRADETRM.position_effectivedate,GRADETRMP.position_effectivedate),GRADE.position_effectivedate,GRADELOA.position_effectivedate,GRADEPRIOR.position_effectivedate),'mm/dd/yy')::char(8) 
      as f36_o33_position_effective_date

,to_char(coalesce(ytdcomp.taxable_wage,0),'00000009d00') as f37_o23_ytd_cognos_gross_pay

,to_char(coalesce(ytdhb.hiring_bonus,0),'00000009d00') as f38_052_ytd_hiring_bonus

,to_char(coalesce(ytdls.lump_sum,0),'00000009d00') as f39_o45_ytd_lump_sum


-- YTD FICA on bonus pay - is the sum of all bonus's (except hiring bonus) multiplied by Soc Sec 1.45 rate and Medicare 6.20 Rate

--,ytdAb.ALL_bonus
,coalesce(TRUNC((ytdAb.ALL_bonus * .0620)+(ytdAb.ALL_bonus * .0145),2),0) as f40_o24_ytd_fica_on_ytd_bonus_pay
--,ytdfica.fica
--,ytdss.social_security
--,ytdmc.medicare
--,(ytdmc.medicare + ytdss.social_security) -  ((ytdAb.ALL_bonus * .0620)+(ytdAb.ALL_bonus * .0145))  - ((ytdsev.severance_pay * .0620)+(ytdsev.severance_pay * .0145)) as f41_o25_ytd_fica_less_ytd_fica_bonus_fica_sev
--,'?' as f41_o25_ytd_fica_less_ytd_fica_bonus_fica_sev

,coalesce(TRUNC(ytdfica.fica -((ytdAb.ALL_bonus * .0620)+(ytdAb.ALL_bonus * .0145)),2),ytdfica.fica,0) as f41_o25_ytd_fica_less_ytd_fica_bonus_fica_sev



--,case when oc_cc.orgcode = '515110' then 'Y'
--      when pe.emplstatus =  'T' and ytdsev.severance_pay <> 0 then 'Y'
  --    else 'N' end as f42_o30_sev_ind
 
 
,case when coalesce(coalesce(GRADECURR.orgcode,GRADECURR1.orgcode,GRADE.orgcode,GRADELOA.orgcode,GRADEPRIOR.orgcode),
          coalesce(GRADEU.orgcode,GRADETRM.orgcode,GRADETRMP.orgcode,GRADERT.orgcode)) = '515110' then 'Y'
      when pe.emplstatus =  'T' and ytdsev.severance_pay <> 0 then 'Y'
      else 'N' end as f42_o30_sev_ind
 
,ytdsev.severance_pay as f43_o40_ytd_cognos_sev_amt     
,TRUNC((ytdsev.severance_pay * .0620)+(ytdsev.severance_pay * .0145),2)  as f44_o41_ytd_fica_on_sev_pay
,' ' as f45_o31_ltip_bonus_pgm_ind


,case when fjc.federaljobcode < '049' then 'OF'
      when fjc.federaljobcode in ('049','050','051') then 'DR'
      else 'CAP' end as f46_o36_officer_code


  ---- if any deductions not taken in a given month use pspay_deduction_accumulators table
  -- not ready to commit to only using this table due to the volitivity of the data 

,vsn.etv_amount
,vsn1.current_dedn_amount
,coalesce(dpc1.current_dedn_amount * -2,dpc.etv_amount  * -2,0)  as f47_o22_dep_care_monthly_ded_amt
,coalesce(med1.current_dedn_amount * -2,med.etv_amount  * -2,0)  as f48_o37_medical_monthly_ded_amt
,coalesce(dnt.etv_amount * -2, dnt1.current_dedn_amount * -2,0)  as f49_o38_dental_monthly_ded_amt
,coalesce(fsa.etv_amount * -2, fsa1.current_dedn_amount * -2,0)  as f50_o39_fsa_monthly_ded_amt
,coalesce(vsn.etv_amount * -2, vsn1.current_dedn_amount * -2,0)  as f51_o42_vision_monthly_ded_amt
,coalesce(hsa.etv_amount * -2, hsa1.current_dedn_amount * -2,0)  as f52_o43_hsa_monthly_ded_amt
,coalesce(hcu.etv_amount * -2, hcu1.current_dedn_amount * -2,0)  as f53_o44_hsa_cu_monthly_ded_amt

--,coalesce(dpc.etv_amount * -2,0)  as f47_o22_dep_care_monthly_ded_amt
--,coalesce(med.etv_amount * -2,0)  as f48_o37_medical_monthly_ded_amt
--,coalesce(dnt.etv_amount * -2,0)  as f49_o38_dental_monthly_ded_amt
--,coalesce(fsa.etv_amount * -2,0)  as f50_o39_fsa_monthly_ded_amt
--,coalesce(vsn.etv_amount * -2,0)  as f51_o42_vision_monthly_ded_amt
--,coalesce(hsa.etv_amount * -2,0)  as f52_o43_hsa_monthly_ded_amt
--,coalesce(hsa.etv_amount * -2,0)  as f53_o44_hsa_cu_monthly_ded_amt




from person_identity pi 

LEFT join person_identity pie
  on pie.personid = pi.personid
 and pie.identitytype = 'EmpNo'
 and current_timestamp between pie.createts and pie.endts

LEFT join person_identity pip
  on pip.personid = pi.personid
 and pip.identitytype = 'PSPID'
 and current_timestamp between pip.createts and pip.endts 

LEFT JOIN person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts
-- and pe.emplstatus = 'A'

LEFT join person_compensation pc
  on pc.personid = pi.personid
 and current_date between pc.effectivedate and pc.enddate
 and current_timestamp between pc.createts and pc.endts
  
LEFT join person_compensation prev_pc
  on prev_pc.personid = pi.personid
 and prev_pc.percomppid = pc.percomppid - 1
 
LEFT join person_names pn
  on pn.personid = pi.personid
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts
 and pn.nametype = 'Legal'

 
----GTX Table -  for YTD Cognos Gross Pay (W003) see column 34 of GTX Table  - Earnings as of 2017-03-01:	

LEFT JOIN (SELECT personid
                  ,'Y' as eligible_flag 
                 --,sum(etype_hours) AS ytdhours
                 ,coalesce(sum(etv_amount),0) as taxable_wage
             FROM pspay_payment_detail            
            WHERE etv_id in ('E01','E64','EB5','E05','EB8','E15','E16','E17','E18','E19','E20','ECA','EAJ','EAR','EB4','EAK')           
              AND date_part('year', check_date) = date_part('year',current_date)
              --and check_number = 'DIRDEP'
         GROUP BY personid,eligible_flag
          ) ytdcomp
  ON ytdcomp.personid = pi.personid  

LEFT JOIN (SELECT personid
                 ,sum(etv_amount) as social_security
             FROM pspay_payment_detail            
            WHERE etv_id in  ('T01')           
              AND date_part('year', check_date) = date_part('year',current_date)
              --and check_number = 'DIRDEP'
         GROUP BY personid
          ) ytdss
  ON ytdss.personid = pi.personid  
--select * from pspay_tax_accumulators where individual_key = 'HMN00000021932' and etv_id in  ('T01','T13')  and year = '2017'  ;    

LEFT JOIN (SELECT personid
                 ,sum(etv_amount) as medicare
             FROM pspay_payment_detail            
            WHERE etv_id in  ('T13')           
              and date_part('year', check_date) = date_part('year',current_date)
              --and check_number = 'DIRDEP'
         GROUP BY personid
          ) ytdmc
  ON ytdmc.personid = pi.personid  
      

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



LEFT join pers_pos pp
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
              AND date_part('year', check_date) = date_part('year',current_date)         
            GROUP BY 1,2
          ) ytdsev
  ON ytdsev.personid = pi.personid         

              
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
                 ,coalesce(sum(etv_amount),0) as hiring_bonus
             FROM pspay_payment_detail            
            WHERE etv_id in  ('E64')           
              AND date_part('year', check_date) = date_part('year',current_date)

            GROUP BY 1,2
          ) ytdhb
  ON ytdhb.personid = pi.personid    
 
LEFT JOIN (SELECT personid
                 ,date_part('year',check_date)
                 ,coalesce(sum(etv_amount),0) as CAP_bonus
             FROM pspay_payment_detail            
            WHERE etv_id in  ('EA1')           
              AND date_part('year', check_date) = date_part('year',current_date)

            GROUP BY 1,2
          ) ytdcapb
  ON ytdcapb.personid = pi.personid    

LEFT JOIN (SELECT personid
                 ,date_part('year',check_date)
                 ,coalesce(sum(etv_amount),0) as industry_bonus
             FROM pspay_payment_detail            
            WHERE etv_id in  ('EB1')           
              AND date_part('year', check_date) = date_part('year',current_date)

            GROUP BY 1,2
          ) ytdindb
  ON ytdindb.personid = pi.personid   
  
LEFT JOIN (SELECT personid
                 ,date_part('year',check_date)
                 ,coalesce(sum(etv_amount),0) as manager_bonus
             FROM pspay_payment_detail            
            WHERE etv_id in  ('EBE')           
              AND date_part('year', check_date) = date_part('year',current_date)

            GROUP BY 1,2
          ) ytdmgrb
  ON ytdmgrb.personid = pi.personid    

LEFT JOIN (SELECT personid
                 ,date_part('year',check_date)
                 ,coalesce(sum(etv_amount),0) as multiline_bonus
             FROM pspay_payment_detail            
            WHERE etv_id in  ('EBH')           
              AND date_part('year', check_date) = date_part('year',current_date)

            GROUP BY 1,2
          ) ytdmlnb
  ON ytdmlnb.personid = pi.personid    
  
LEFT JOIN (SELECT personid
                 ,date_part('year',check_date)
                 ,coalesce(sum(etv_amount),0) as officer_bonus
             FROM pspay_payment_detail            
            WHERE etv_id in  ('EA2')           
              AND date_part('year', check_date) = date_part('year',current_date)

            GROUP BY 1,2
          ) ytdoffb
  ON ytdoffb.personid = pi.personid    

LEFT JOIN (SELECT personid
                 ,date_part('year',check_date)
                 ,coalesce(sum(etv_amount),0) as bonus
             FROM pspay_payment_detail            
            WHERE etv_id in  ('E61')           
              AND date_part('year', check_date) = date_part('year',current_date)

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
              AND date_part('year', check_date) = date_part('year',current_date)

            GROUP BY 1,2
          ) ytdAb
  ON ytdAb.personid = pi.personid    
--- dependent care
left join 
      (select individual_key, etv_amount, etv_id
         from  pspay_payment_detail 
        where etv_id = 'VBB'
          AND check_date = ?::DATE
       
      ) dpc
  on dpc.individual_key = pip.identity 
  

left join 
      (select individual_key, current_dedn_amount, etv_id
         from pspay_deduction_accumulators 
        where etv_id = 'VBB'
          and mtd_dedn_amount > 0

      ) dpc1
  on dpc1.individual_key = pip.identity 
  
  /*
  
  
  */
  
  
    
--- medical  
left join 
      (select individual_key, etv_amount, etv_id
         from  pspay_payment_detail 
        where etv_id = 'VBC'
          AND check_date = ?::DATE
          
      ) med
  on med.individual_key = pip.identity  
  
left join 
      (select individual_key, current_dedn_amount, etv_id
         from  pspay_deduction_accumulators 
        where etv_id = 'VBC'
          and mtd_dedn_amount > 0
          --and mtd_dedn_amount > current_dedn_amount       
      ) med1
  on med1.individual_key = pip.identity 
     
--- dental
left join 
      (select individual_key, etv_amount, etv_id
         from  pspay_payment_detail 
        where etv_id = 'VBD'
          AND check_date = ?::DATE
        
      ) dnt
  on dnt.individual_key = pip.identity    
  
left join 
      (select individual_key, current_dedn_amount, etv_id
         from  pspay_deduction_accumulators 
        where etv_id = 'VBD'
          and mtd_dedn_amount > 0
       
      ) dnt1
  on dnt1.individual_key = pip.identity 
        
--- fsa 
left join 
      (select individual_key, etv_amount, etv_id
         from  pspay_payment_detail 
        where etv_id = 'VBA'
          AND check_date = ?::DATE
        
      ) fsa
  on fsa.individual_key = pip.identity  
  
left join 
      (select individual_key, current_dedn_amount, etv_id
         from  pspay_deduction_accumulators 
        where etv_id = 'VBA'
          and mtd_dedn_amount > 0
      
       
      ) fsa1
  on fsa1.individual_key = pip.identity 
  
           
--- vision    
left join 
      (select individual_key, etv_amount, etv_id
         from  pspay_payment_detail 
        where etv_id = 'VBE'
          AND check_date = ?::DATE
         
      ) vsn
  on vsn.individual_key = pip.identity       
  
left join 
      (select individual_key, current_dedn_amount, etv_id
         from  pspay_deduction_accumulators 
        where etv_id = 'VBE'
          and mtd_dedn_amount > 0
          
       
      ) vsn1
  on vsn1.individual_key = pip.identity 
  
    
--- hsa
left join 
      (select individual_key, etv_amount, etv_id
         from  pspay_payment_detail 
        where etv_id = 'VEH'
          AND check_date = ?::DATE
     
      ) hsa
  on hsa.individual_key = pip.identity   

left join 
      (select individual_key, current_dedn_amount, etv_id
         from  pspay_deduction_accumulators 
        where etv_id = 'VEH'
          and mtd_dedn_amount > 0
     
      ) hsa1
  on hsa1.individual_key = pip.identity 
  
--- hsa cu
left join 
      (select individual_key, etv_amount, etv_id
         from  pspay_payment_detail 
        where etv_id = 'VEJ'
          AND check_date = ?::DATE

      ) hcu
  on hcu.individual_key = pip.identity    

left join 
      (select individual_key, current_dedn_amount, etv_id
         from  pspay_deduction_accumulators 
        where etv_id = 'VEJ'
          and mtd_dedn_amount > 0
      
      ) hcu1
  on hcu1.individual_key = pip.identity    


---- Picks up termed or retired note not all terms play well with this join see gradetrmp or GRADEU 
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
        ,sgrtrm.locationdescription
        ,sgrtrm.locationCode
        ,sgrtrm.flsacode
        ,sgrtrm.pct_in_range
              
         FROM ( 
                SELECT distinct            
                  pi.personid
                 ,pc.compevent
                 ,case when pc.compamount < 50 then 0 else pc.compamount end as compamount
                 ,pc.increaseamount
                 ,pc.earningscode  
                 ,pc.effectivedate                                                  
                 ,pc.enddate
                 ,pc.createts
                 ,pc.endts                           
                 ,coalesce(prev_pc.compamount,pc.compamount) as prev_compamount
                 ,case when pc.frequencycode = 'A' then pc.compamount / 2080 else pc.compamount end as hourly_rate                     
                 ,pp.positionid
                 ,pp.scheduledhours
                 ,pp.effectivedate as position_effectivedate        
                 ,porb.orgcode
                 ,porb.organizationid
                 ,pd.positiontitle   
                 ,jd.jobcode  
                 ,sg.salarygradedesc
                 ,sg.grade
                 ,sgr.salarygraderegion
                 ,lc.locationdescription
                 ,lc.locationCode
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
                 ,pd.flsacode       
                 ,vpir.percent_in_range as pct_in_range 
                                            
                 from person_identity pi
                 
                 join person_employment pe
                   on pe.personid = pi.personid
                  and current_date between pe.effectivedate and pe.enddate
                  and current_timestamp between pe.createts and pe.endts
                  and pe.emplstatus = 'T'

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
                          join person_employment pe
                            on pe.personid = pi.personid
                           and current_date between pe.effectivedate and pe.enddate
                           and current_timestamp between pe.createts and pe.endts
                           and pe.emplstatus in ('T','R')                         
    
                        where pi.identitytype = 'SSN'
                          and current_timestamp between pi.createts and pi.endts
                     --     and pi.personid in ('66231')
                       ) pc
                   on pc.personid = pi.personid
 
                 left JOIN pers_pos pp 
                   ON pp.personid = pi.personid
                  and pp.updatets is not null
                 
                 JOIN person_locations pl 
                   ON pl.personid = pi.personid 
                  --AND pl.locationid = lc.locationid              
                  AND current_date between pl.effectivedate AND pl.enddate 
                  AND current_timestamp between pl.createts AND pl.endts                   

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
                      AND CURRENT_TIMESTAMP BETWEEN PP.CREATETS AND PP.ENDTS 

                    

                     join pos_org_rel porb 
                       ON porb.positionid = PP.positionid 
                      AND porb.posorgreltype = 'Budget' 
                      and current_timestamp between porb.createts and porb.endts
                      and porb.posorgrelevent = 'NewPos'
                        
                     join organization_code oc_cc
                       ON oc_cc.organizationid = porb.organizationid
                      AND oc_cc.organizationtype = 'CC'

                      --and current_timestamp between oc_cc.createts and oc_cc.endts 
                      --and oc_cc.effectivedate - interval '1 day' <> oc_cc.enddate 
                      
                      join person_employment pe
                       on pe.personid = pi.personid
                      and current_date between pe.effectivedate and pe.enddate
                      and current_timestamp between pe.createts and pe.endts
                      and pe.emplstatus in ('T','R')                      
                      
                     where pi.identitytype = 'SSN'
                       and current_timestamp between pi.createts and pi.endts
                      -- and pi.personid in ('66231')
                  
                  
                  ) porb 
                    on porb.personid = pi.personid
                  
                 JOIN position_desc pd 
                   ON pd.positionid = pp.positionid
                  --AND current_date between pd.effectivedate AND pd.enddate 
                  AND current_timestamp between pd.createts AND pd.endts

                 left join dcperscompensationdet vpir
                   on vpir.personid = pp.personid 
                  and current_date between vpir.effectivedate and vpir.enddate
                  and current_timestamp between vpir.createts and vpir.endts   

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
                  --and current_date between jd.effectivedate and jd.enddate
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
                  and PPD.etv_id in  ('E01','E64','EB5','E05','EB8','E15','E16','E17','E18','E19','E20','ECA','EAJ','EAR','EB4','EAK'
                                     ,'E30','EBF','E61','EA1','EB1','EBE',
                                      'EBH','EA2','VBB','VBC','VBD','VBA','VBE','VEH','VEJ','EB7') 
                  --and ppd.check_number = 'DIRDEP'
             
            where pi.identitytype = 'SSN'
              and current_timestamp between pi.createts and pi.endts
              and sgr.frequencycode = pc.frequencycode
            --  and pp.personid = '66231'  
       ) sgrtrm
     
     ) GRADETRM on GRADETRM.personid = pi.personid and current_timestamp between GRADETRM.createts and GRADETRM.endts  
   -- and GRADETRM.personid not in ('66266','66162','65966','65852')  
  

--- some people on loa don't play well with term logic giving them their own join 

left join 
(
           SELECT distinct 
         sgrloa.personid
        ,sgrloa.positionid
        ,sgrloa.scheduledhours
        ,sgrloa.earningscode
        ,sgrloa.salarygradedesc
        ,sgrloa.grade
        ,sgrloa.salarygraderegion
        ,sgrloa.compamount
        ,sgrloa.orgcode
        ,sgrloa.organizationid
        ,CASE
               WHEN sgrloa.midpoint IS NOT NULL AND sgrloa.midpoint > 0::numeric AND (sgrloa.annualsalarymax - sgrloa.annualsalarymin) > 0::numeric THEN
               CASE
                   WHEN sgrloa.companyparametervalue IS NOT NULL 
                   THEN ((sgrloa.annualcompensation / sgrloa.partialpercent - sgrloa.annualsalarymin)::numeric(15,3) / (sgrloa.annualsalarymax - sgrloa.annualsalarymin)::numeric(15,3))::numeric(15,3)
                   ELSE (sgrloa.annualcompensation / sgrloa.partialpercent / sgrloa.midpoint)::numeric(15,3)
               END
               ELSE 0.00000        
         END AS percent_in_range           
        ,sgrloa.effectivedate
        ,sgrloa.enddate
        ,sgrloa.createts
        ,sgrloa.endts          
        ,sgrloa.increaseamount
        ,sgrloa.compevent
        ,sgrloa.prev_compamount    
        ,sgrloa.position_effectivedate     
        ,sgrloa.jobcode   
        ,sgrloa.positiontitle   
        ,TRUNC(sgrloa.hourly_rate,2) AS HOURLY_RATE
        ,sgrloa.locationdescription
        ,sgrloa.locationCode
        ,sgrloa.flsacode
              
         FROM ( 
                SELECT distinct            
                  pi.personid
                 ,pc.compevent
                 ,case when pc.compamount < 50 then 0 else pc.compamount end as compamount
                 ,pc.increaseamount
                 ,pc.earningscode  
                 ,pc.effectivedate                                                  
                 ,pc.enddate
                 ,pc.createts
                 ,pc.endts                           
                 ,coalesce(prev_pc.compamount,pc.compamount) as prev_compamount
                 ,case when pc.frequencycode = 'A' then pc.compamount / 2080 else pc.compamount end as hourly_rate                     
                 ,pp.positionid
                 ,pp.scheduledhours
                 ,pp.effectivedate as position_effectivedate        
                 ,porb.orgcode
                 ,porb.organizationid
                 ,pd.positiontitle   
                 ,jd.jobcode  
                 ,sg.salarygradedesc
                 ,sg.grade
                 ,sgr.salarygraderegion
                 ,(sgr.salaryminimum * fcsg.annualfactor)::numeric(15,4) AS annualsalarymin
                 ,(sgr.salarymaximum * fcsg.annualfactor)::numeric(15,4) AS annualsalarymax
                 ,(sgr.salaryminimum * fcsg.annualfactor)::numeric(15,4) + (((sgr.salarymaximum * fcsg.annualfactor)::numeric(15,4) - (sgr.salaryminimum * fcsg.annualfactor)::numeric(15,4)) / 2.0000)::numeric(15,4) AS midpoint
                 ,cp.companyparametervalue
                 ,lc.locationdescription
                 ,lc.locationCode
                 ,CASE WHEN pc.frequencycode = 'H'::bpchar THEN pc.compamount * (pp.scheduledhours * fcpos.annualfactor)
                       ELSE (pc.compamount * fcc.annualfactor)::numeric(15,4)
                       END AS annualcompensation
                 ,CASE WHEN pp.partialpercent > 0::numeric THEN pp.partialpercent / 100.000000
                       ELSE 1::numeric
                       END AS partialpercent 
                 ,pd.flsacode                                  
                 from person_identity pi
                 
                 join person_employment pe
                   on pe.personid = pi.personid
                  and current_date between pe.effectivedate and pe.enddate
                  and current_timestamp between pe.createts and pe.endts
                  and pe.emplstatus in ('L')

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
                          join person_employment pe
                            on pe.personid = pi.personid
                           and current_date between pe.effectivedate and pe.enddate
                           and current_timestamp between pe.createts and pe.endts
                           and pe.emplstatus in ('L')                           
    
                        where pi.identitytype = 'SSN'
                          and current_timestamp between pi.createts and pi.endts
                         -- and pi.personid in  ('66231','64567')
                       ) pc
                   on pc.personid = pi.personid
 
                 JOIN pers_pos pp 
                   ON pp.personid = pi.personid
                  and current_date between pp.effectivedate and pp.enddate
                  and current_timestamp between pp.createts and pp.endts
                  -- select * from pers_pos where personid = '64567';
                 
                 JOIN person_locations pl 
                   ON pl.personid = pi.personid 
                  --AND pl.locationid = lc.locationid              
                  AND current_date between pl.effectivedate AND pl.enddate 
                  AND current_timestamp between pl.createts AND pl.endts                   

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
                      and pe.emplstatus in ('L')                      
                     -- select * from person_employment where personid = '64567';
                     where pi.identitytype = 'SSN'
                       and current_timestamp between pi.createts and pi.endts
                      -- and pi.personid in ('66231','64567')
                  
                  
                  ) porb 
                    on porb.personid = pi.personid
                  
                 JOIN position_desc pd 
                   ON pd.positionid = pp.positionid
                  AND current_date between pd.effectivedate AND pd.enddate 
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
                  --and current_date between jd.effectivedate and jd.enddate
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
                  and PPD.etv_id in  ('E01','E64','EB5','E05','EB8','E15','E16','E17','E18','E19','E20','ECA','EAJ','EAR','EB4','EAK'
                                     ,'E30','EBF','E61','EA1','EB1','EBE',
                                      'EBH','EA2','VBB','VBC','VBD','VBA','VBE','VEH','VEJ','EB7')  
                  --and ppd.check_number = 'DIRDEP'
             
            where pi.identitytype = 'SSN'
              and current_timestamp between pi.createts and pi.endts
              and sgr.frequencycode = pc.frequencycode
             -- and pp.personid in  ('66231','64567')
       ) sgrloa

     ) GRADELOA on GRADELOA.personid = pi.personid
   --  and GRADELOA.personid not in ('66162')

----////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
--- provides current job salary position data - I give gradecurr highest priority in the coalesces this provides correct 
--- results for current people     
left join
(
       SELECT distinct 
         sgrcurr1.personid
        ,sgrcurr1.earningscode
        ,sgrcurr1.positionid
    --    ,sgr.edtcode
        ,sgrcurr1.salarygraderegion
     --   ,sgr.grade
        ,sgrcurr1.salarygradedesc
        ,sgrcurr1.positiontitle
        ,sgrcurr1.jobcode
        ,sgrcurr1.compamount
        ,sgrcurr1.midpoint 
        ,sgrcurr1.annualsalarymax
        ,sgrcurr1.annualsalarymin
        ,sgrcurr1.locationdescription
        ,sgrcurr1.locationCode
        /*
        ,CASE
               WHEN sgrcurr.midpoint IS NOT NULL AND sgrcurr.midpoint > 0::numeric AND (sgrcurr.annualsalarymax - sgrcurr.annualsalarymin) > 0::numeric THEN
               CASE
                   WHEN sgrcurr.companyparametervalue IS NOT NULL 
                   THEN ((sgrcurr.annualcompensation / sgrcurr.partialpercent - sgrcurr.annualsalarymin)::numeric(15,4) / (sgrcurr.annualsalarymax - sgrcurr.annualsalarymin)::numeric(15,4))::numeric(15,4)
                   ELSE (sgrcurr.annualcompensation / sgrcurr.partialpercent / sgrcurr.midpoint)::numeric(15,4)
               END
               ELSE 0.00000
           END AS percent_in_range  
           */ 
         ,sgrcurr1.effectivedate    
         ,sgrcurr1.increaseamount
         ,sgrcurr1.compevent
         ,sgrcurr1.prev_compamount   
         ,sgrcurr1.position_effectivedate  
         ,TRUNC(sgrcurr1.hourly_rate,2) AS HOURLY_RATE
         ,sgrcurr1.orgcode
         ,sgrcurr1.organizationid    
         ,sgrcurr1.flsacode
         ,sgrcurr1.pct_in_range
         ,sgrcurr1.vpcpira_pct_in_range as percent_in_range 
         from (
               select 
                pp.personid
               ,pp.positionid
               ,pp.effectivedate as position_effectivedate 
               ,vpd.positiontitle
               ,vpd.grade
               ,vpd.shiftcode
               ,pc.earningscode
               ,pc.compevent 
               ,case when pc.compamount < 50 then 0 else pc.compamount end as compamount
               ,pc.increaseamount
               ,pc.effectivedate
               ,pc.enddate
               ,pc.createts
               ,pc.endts      
               ,case when pc.frequencycode = 'A' then pc.compamount / 2080 else pc.compamount end as hourly_rate 
               ,coalesce(prev_pc.compamount,pc.compamount) as prev_compamount  
               ,sg.salarygradedesc 
               ,sgr.grade
               ,sgr.edtcode
               ,sgr.salarygraderegion
               ,sgr.enddate
               ,jd.jobcode
               ,lc.locationdescription   
               ,lc.locationCode  
               
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
               ,porb.orgcode
               ,porb.organizationid      
               ,pd.flsacode    
               ,vpir.percent_in_range as pct_in_range  
               ,vpcpira.percent_in_range as vpcpira_pct_in_range        
                 
               from pers_pos pp
               
               join person_compensation pc
                 on pc.personid = pp.personid
                and current_date between pc.effectivedate and pc.enddate
                and current_timestamp between pc.createts and pc.endts
                and pc.effectivedate <= ?::date                
               
               left join dcperscompensationdet vpir
                 on vpir.personid = pp.personid 
                and current_date between vpir.effectivedate and vpir.enddate
                and current_timestamp between vpir.createts and vpir.endts
               
               left join personcomppercentinrangeasof vpcpira
                 on vpcpira.personid = pp.personid        
                and current_date = vpcpira.asofdate  
                
               left join person_compensation prev_pc
                 on prev_pc.personid = pc.personid
                and prev_pc.percomppid = pc.percomppid - 1    
               
               join positiondetails vpd
                 on vpd.positionid = pp.positionid
               
               join salary_grade sg
                 on sg.grade = vpd.grade
                and current_date between sg.effectivedate and sg.enddate
                and current_timestamp between sg.createts and sg.endts 
               
               join salary_grade_ranges sgr
                 on sgr.grade = vpd.grade
                and sgr.edtcode = pc.earningscode
                and current_date between sgr.effectivedate and sgr.enddate
                and current_timestamp between sgr.createts and sgr.endts
                and sgr.salarygraderangepid in 
                    (select max(salarygraderangepid) from salary_grade_ranges x
                      where current_date between x.effectivedate and x.enddate
                        and current_timestamp between x.createts and x.endts
                        and x.edtcode = pc.earningscode
                        and x.grade = vpd.grade)
                    
               left join position_job pj
                 on pj.positionid = PP.positionid
                and current_date between pj.effectivedate and pj.enddate
                and current_timestamp between pj.createts and pj.endts
               
               left join job_desc jd
                 on jd.jobid = pj.jobid
                and current_date between jd.effectivedate and jd.enddate
                and current_timestamp between jd.createts and jd.endts   
               
               join person_locations pl
                 on pl.personid = pp.personid
                and current_date between pl.effectivedate and pl.enddate
                and current_timestamp between pl.createts and pl.endts
               
               JOIN location_codes lc 
                 ON lc.locationid = pl.locationid
                AND current_date between lc.effectivedate AND lc.enddate 
                AND current_timestamp between lc.createts AND lc.endts  
                -- select * from location_codes 
               
               LEFT JOIN company_parameters cp 
                 ON cp.companyparametername = 'PIRB'::bpchar 
                AND cp.companyparametervalue::text = 'MIN'::text  
               
         
               JOIN position_desc pd 
                 ON pd.positionid = pp.positionid
            --AND current_date between pd.effectivedate AND pd.enddate 
                AND current_timestamp between pd.createts AND pd.endts         
                                
                                      
               JOIN frequency_codes fcc 
                 ON fcc.frequencycode = pc.frequencycode
               JOIN frequency_codes fcpos 
                 ON fcpos.frequencycode = pp.schedulefrequency
               JOIN frequency_codes fcsg 
                 ON fcsg.frequencycode = pc.frequencycode
             
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
                   and current_date between pp.effectivedate and pp.enddate
                   AND CURRENT_TIMESTAMP BETWEEN PP.CREATETS AND PP.ENDTS  
                   --select * from pers_pos where personid = '64831';
                  join pos_org_rel porb 
                    ON porb.positionid = PP.positionid 
                   AND porb.posorgreltype = 'Budget' 
                   and current_date between porb.effectivedate and porb.enddate
                   and current_timestamp between porb.createts and porb.endts
         
                   -- select * from pos_org_rel where positionid = '389427'
         
                  
                  join organization_code oc_cc
                    ON oc_cc.organizationid = porb.organizationid
                   AND oc_cc.organizationtype = 'CC'
                   and current_timestamp between oc_cc.createts and oc_cc.endts 
                   and oc_cc.effectivedate - interval '1 day' <> oc_cc.enddate                       
                   --- select * from organization_code where organizationid = '1363'                 
                   
                   join person_employment pe
                    on pe.personid = pi.personid
                   and current_date between pe.effectivedate and pe.enddate
                   and current_timestamp between pe.createts and pe.endts
                   and pe.emplstatus = 'A'   
                                    
                   
                  where pi.identitytype = 'SSN'
                    and current_timestamp between pi.createts and pi.endts                      
                    --and pi.personid in ('66002')
               ) porb 
                on porb.personid = pp.personid
               and porb.positionid = pp.positionid
                                 
               where current_date between pp.effectivedate and pp.enddate
               and current_timestamp between pp.createts and pp.endts
     
      
     -- and pp.personid = '63747'
     ) sgrcurr1
     ) GRADECURR1 on GRADECURR1.personid = pi.personid  
      and GRADECURR1.personid not in ('63747','66600','67830','66504','65993','63786','65734','66182','65773','63090','66583','66460'
      ,'66468')

----->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>          
       
left join 
     (

       SELECT distinct 
         sgrcurr.personid
        ,sgrcurr.earningscode
        ,sgrcurr.positionid
    --    ,sgr.edtcode
        ,sgrcurr.salarygraderegion
     --   ,sgr.grade
        ,sgrcurr.salarygradedesc
        ,sgrcurr.positiontitle
        ,sgrcurr.jobcode
        ,sgrcurr.compamount
        ,sgrcurr.midpoint 
        ,sgrcurr.annualsalarymax
        ,sgrcurr.annualsalarymin
        ,sgrcurr.locationdescription
        ,sgrcurr.locationCode
        /*
        ,CASE
               WHEN sgrcurr.midpoint IS NOT NULL AND sgrcurr.midpoint > 0::numeric AND (sgrcurr.annualsalarymax - sgrcurr.annualsalarymin) > 0::numeric THEN
               CASE
                   WHEN sgrcurr.companyparametervalue IS NOT NULL 
                   THEN ((sgrcurr.annualcompensation / sgrcurr.partialpercent - sgrcurr.annualsalarymin)::numeric(15,4) / (sgrcurr.annualsalarymax - sgrcurr.annualsalarymin)::numeric(15,4))::numeric(15,4)
                   ELSE (sgrcurr.annualcompensation / sgrcurr.partialpercent / sgrcurr.midpoint)::numeric(15,4)
               END
               ELSE 0.00000
           END AS percent_in_range  
           */ 
         ,sgrcurr.effectivedate    
         ,sgrcurr.increaseamount
         ,sgrcurr.compevent
         ,sgrcurr.prev_compamount   
         ,sgrcurr.position_effectivedate  
         ,TRUNC(sgrcurr.hourly_rate,2) AS HOURLY_RATE
         ,sgrcurr.orgcode
         ,sgrcurr.organizationid    
         ,sgrcurr.flsacode
         ,sgrcurr.pct_in_range
         ,sgrcurr.vpcpira_pct_in_range as percent_in_range 
         from (
               select 
                pp.personid
               ,pp.positionid
               ,pp.effectivedate as position_effectivedate 
               ,vpd.positiontitle
               ,vpd.grade
               ,vpd.shiftcode
               ,pc.earningscode
               ,pc.compevent 
               ,case when pc.compamount < 50 then 0 else pc.compamount end as compamount
               ,pc.increaseamount
               ,pc.effectivedate
               ,pc.enddate
               ,pc.createts
               ,pc.endts      
               ,case when pc.frequencycode = 'A' then pc.compamount / 2080 else pc.compamount end as hourly_rate 
               ,coalesce(prev_pc.compamount,pc.compamount) as prev_compamount  
               ,sg.salarygradedesc 
               ,sgr.grade
               ,sgr.edtcode
               ,sgr.salarygraderegion
               ,sgr.enddate
               ,jd.jobcode
               ,lc.locationdescription   
               ,lc.locationCode  
               
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
               ,porb.orgcode
               ,porb.organizationid      
               ,pd.flsacode    
               ,vpir.percent_in_range as pct_in_range  
               ,vpcpira.percent_in_range as vpcpira_pct_in_range        
                 
               from pers_pos pp
               --- this pc join insures I don't pull compensation details from future.
               join 
(
select 
 allpc.personid
,allpc.percomppid
,allpc.compamount
,allpc.increaseamount
,allpc.effectivedate
,allpc.enddate
,allpc.createts
,allpc.endts
,allpc.earningscode
,allpc.compevent
,allpc.frequencycode
from 


(
select personid,percomppid,compamount,effectivedate,enddate,createts,endts,increaseamount,earningscode,compevent,frequencycode
  from person_compensation
 where current_timestamp between createts and endts

)allpc
join 
(
select personid,max(percomppid) as percomppid
       from person_compensation
       where effectivedate <= ?::date
       and current_timestamp between createts and endts
       group by 1
) maxpc on maxpc.personid = allpc.personid and maxpc.percomppid = allpc.percomppid     
) pc    on pc.personid = pp.personid           
               
                           
               
               left join dcperscompensationdet vpir
                 on vpir.personid = pp.personid 
                and current_date between vpir.effectivedate and vpir.enddate
                and current_timestamp between vpir.createts and vpir.endts
               
               left join personcomppercentinrangeasof vpcpira
                 on vpcpira.personid = pp.personid        
                and current_date = vpcpira.asofdate  
                
               left join person_compensation prev_pc
                 on prev_pc.personid = pc.personid
                and prev_pc.percomppid = pc.percomppid - 1    
               
               join positiondetails vpd
                 on vpd.positionid = pp.positionid
               
               join salary_grade sg
                 on sg.grade = vpd.grade
                and current_date between sg.effectivedate and sg.enddate
                and current_timestamp between sg.createts and sg.endts 
               
               join salary_grade_ranges sgr
                 on sgr.grade = vpd.grade
                and sgr.edtcode = pc.earningscode
                and current_date between sgr.effectivedate and sgr.enddate
                and current_timestamp between sgr.createts and sgr.endts
                and sgr.salarygraderangepid in 
                    (select max(salarygraderangepid) from salary_grade_ranges x
                      where current_date between x.effectivedate and x.enddate
                        and current_timestamp between x.createts and x.endts
                        and x.edtcode = pc.earningscode
                        and x.grade = vpd.grade)
                    
               left join position_job pj
                 on pj.positionid = PP.positionid
                and current_date between pj.effectivedate and pj.enddate
                and current_timestamp between pj.createts and pj.endts
               
               left join job_desc jd
                 on jd.jobid = pj.jobid
                and current_date between jd.effectivedate and jd.enddate
                and current_timestamp between jd.createts and jd.endts   
               
               join person_locations pl
                 on pl.personid = pp.personid
                and current_date between pl.effectivedate and pl.enddate
                and current_timestamp between pl.createts and pl.endts
               
               JOIN location_codes lc 
                 ON lc.locationid = pl.locationid
                AND current_date between lc.effectivedate AND lc.enddate 
                AND current_timestamp between lc.createts AND lc.endts  
                -- select * from location_codes 
               
               LEFT JOIN company_parameters cp 
                 ON cp.companyparametername = 'PIRB'::bpchar 
                AND cp.companyparametervalue::text = 'MIN'::text  
               
         
               JOIN position_desc pd 
                 ON pd.positionid = pp.positionid
            --AND current_date between pd.effectivedate AND pd.enddate 
                AND current_timestamp between pd.createts AND pd.endts         
                                
                                      
               JOIN frequency_codes fcc 
                 ON fcc.frequencycode = pc.frequencycode
               JOIN frequency_codes fcpos 
                 ON fcpos.frequencycode = pp.schedulefrequency
               JOIN frequency_codes fcsg 
                 ON fcsg.frequencycode = pc.frequencycode
             
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
                   and current_date between pp.effectivedate and pp.enddate
                   AND CURRENT_TIMESTAMP BETWEEN PP.CREATETS AND PP.ENDTS  
                   --select * from pers_pos where personid = '64831';
                  join pos_org_rel porb 
                    ON porb.positionid = PP.positionid 
                   AND porb.posorgreltype = 'Budget' 
                   and current_timestamp between porb.createts and porb.endts
         
                   -- select * from pos_org_rel where positionid = '389427'
         
                  
                  join organization_code oc_cc
                    ON oc_cc.organizationid = porb.organizationid
                   AND oc_cc.organizationtype = 'CC'
                   and current_timestamp between oc_cc.createts and oc_cc.endts 
                   and oc_cc.effectivedate - interval '1 day' <> oc_cc.enddate                       
                   --- select * from organization_code where organizationid = '1363'                 
                   
                   join person_employment pe
                    on pe.personid = pi.personid
                   and current_date between pe.effectivedate and pe.enddate
                   and current_timestamp between pe.createts and pe.endts
                   and pe.emplstatus = 'A'   
                                    
                   
                  where pi.identitytype = 'SSN'
                    and current_timestamp between pi.createts and pi.endts                      
                    --and pi.personid in ('66504')
               ) porb 
                on porb.personid = pp.personid
               and porb.positionid = pp.positionid
                                 
               where current_date between pp.effectivedate and pp.enddate
               and current_timestamp between pp.createts and pp.endts
     
      
     -- and pp.personid = '63185'
     ) sgrcurr
             
     ) GRADECURR on GRADECURR.personid = pi.personid 
     and GRADECURR.personid not in ('63747','66600','67830','66381','66044','66002','66504','65993','63786','65734','66182'
     ,'65773','63090','66224','66348','65810','66583','66460','66468') 

---((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((     
---- GRADEPRIOR - attempt to get prior job position data - should not contain current.    
left join 
     (
       SELECT distinct 
         sgrprior.personid
        ,sgrprior.positionid
        ,sgrprior.scheduledhours
        ,sgrprior.earningscode
        ,sgrprior.salarygradedesc
        ,sgrprior.grade
        ,sgrprior.salarygraderegion
        ,sgrprior.compamount
        ,sgrprior.orgcode
        ,sgrprior.organizationid
        ,CASE
               WHEN sgrprior.midpoint IS NOT NULL AND sgrprior.midpoint > 0::numeric AND (sgrprior.annualsalarymax - sgrprior.annualsalarymin) > 0::numeric THEN
               CASE
                   WHEN sgrprior.companyparametervalue IS NOT NULL 
                   THEN ((sgrprior.annualcompensation / sgrprior.partialpercent - sgrprior.annualsalarymin)::numeric(15,3) / (sgrprior.annualsalarymax - sgrprior.annualsalarymin)::numeric(15,3))::numeric(15,3)
                   ELSE (sgrprior.annualcompensation / sgrprior.partialpercent / sgrprior.midpoint)::numeric(15,3)
               END
               ELSE 0.00000        
         END AS percent_in_range           
        ,sgrprior.effectivedate
        ,sgrprior.enddate
        ,sgrprior.createts
        ,sgrprior.endts          
        ,sgrprior.increaseamount
        ,sgrprior.compevent
        ,sgrprior.prev_compamount    
        ,sgrprior.position_effectivedate     
        ,sgrprior.jobcode   
        ,sgrprior.positiontitle   
        ,TRUNC(sgrprior.hourly_rate,2) AS HOURLY_RATE
        ,sgrprior.locationdescription
        ,sgrprior.locationCode
        ,sgrprior.flsacode
              
         FROM ( 
                SELECT distinct            
                  pi.personid
                 ,pc.compevent
                 ,pc.compamount
                 ,pc.increaseamount
                 ,pc.earningscode  
                 ,pc.effectivedate                                                  
                 ,pc.enddate
                 ,pc.createts
                 ,pc.endts                           
                 ,coalesce(prev_pc.compamount,pc.compamount) as prev_compamount
                 ,case when pc.frequencycode = 'A' then pc.compamount / 2080 else pc.compamount end as hourly_rate                     
                 ,pp.positionid
                 ,pp.scheduledhours
                 ,pp.effectivedate as position_effectivedate        
                 ,porb.orgcode
                 ,porb.organizationid
                 ,pd.positiontitle   
                 ,jd.jobcode  
                 ,sg.salarygradedesc
                 ,sg.grade
                 ,sgr.salarygraderegion
                 ,lc.locationdescription
                 ,lc.locationCode
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
                 ,pd.flsacode                                  
                 from person_identity pi
                 
                 join person_employment pe
                   on pe.personid = pi.personid
                  and current_date between pe.effectivedate and pe.enddate
                  and current_timestamp between pe.createts and pe.endts
                  and pe.emplstatus = 'T'

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
                          join person_employment pe
                            on pe.personid = pi.personid
                           and current_date between pe.effectivedate and pe.enddate
                           and current_timestamp between pe.createts and pe.endts
                           and pe.emplstatus in ('T','R')                         
    
                        where pi.identitytype = 'SSN'
                          and current_timestamp between pi.createts and pi.endts
                     --     and pi.personid in ('66231')
                       ) pc
                   on pc.personid = pi.personid
 
                 left JOIN pers_pos pp 
                   ON pp.personid = pi.personid
                  and pp.updatets is not null
                 
                 JOIN person_locations pl 
                   ON pl.personid = pi.personid 
                  --AND pl.locationid = lc.locationid              
                  AND current_date between pl.effectivedate AND pl.enddate 
                  AND current_timestamp between pl.createts AND pl.endts                   

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
                      AND CURRENT_TIMESTAMP BETWEEN PP.CREATETS AND PP.ENDTS  

                     join pos_org_rel porb 
                       ON porb.positionid = PP.positionid 
                      AND porb.posorgreltype = 'Budget' 
                      and current_timestamp between porb.createts and porb.endts
                      and porb.posorgrelevent = 'NewPos'
                        
                     join organization_code oc_cc
                       ON oc_cc.organizationid = porb.organizationid
                      AND oc_cc.organizationtype = 'CC'

                      --and current_timestamp between oc_cc.createts and oc_cc.endts 
                      --and oc_cc.effectivedate - interval '1 day' <> oc_cc.enddate 
                      
                      join person_employment pe
                       on pe.personid = pi.personid
                      and current_date between pe.effectivedate and pe.enddate
                      and current_timestamp between pe.createts and pe.endts
                      and pe.emplstatus in ('T','R')                      
                      
                     where pi.identitytype = 'SSN'
                       and current_timestamp between pi.createts and pi.endts
                      -- and pi.personid in ('66231')
                  
                  
                  ) porb 
                    on porb.personid = pi.personid
                  
                 JOIN position_desc pd 
                   ON pd.positionid = pp.positionid
                  AND current_date between pd.effectivedate AND pd.enddate 
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
                  --and current_date between jd.effectivedate and jd.enddate
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
                  and PPD.etv_id in  ('E01','E64','EB5','E05','EB8','E15','E16','E17','E18','E19','E20','ECA','EAJ','EAR','EB4','EAK'
                                     ,'E30','EBF','E61','EA1','EB1','EBE',
                                      'EBH','EA2','VBB','VBC','VBD','VBA','VBE','VEH','VEJ','EB7') 
                  --and ppd.check_number = 'DIRDEP'
             
            where pi.identitytype = 'SSN'
              and current_timestamp between pi.createts and pi.endts
              and sgr.frequencycode = pc.frequencycode
              --and pp.personid = '65966'             

        ) sgrprior
     ) GRADEPRIOR on GRADEPRIOR.personid = pi.personid 
     /*
     and GRADEPRIOR.personid not in ('66326','65318','64535','65915','63676','65382','65162','66537','66279','65489','65253','66564'
     ,'65734','66541','66384', '66223','64007','63747','66356','64956','63833','66343','65699','63511','66266','66628','66073','63402'
     ,'66039','63526','66600','66208','65550','64695','66162', '65104', '63529','66419','65861','65906','66580','66408','65720'
     ,'65055','67830','64715','66291','65872','66503','63900','66277','66381')    
     */
----&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&     
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
        ,sgr.locationdescription
        ,sgr.locationCode
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
         ,sgr.orgcode
         ,sgr.organizationid
         ,sgr.flsacode
          
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
                  ,case when pc.compamount < 50 then 0 else pc.compamount end as compamount
                  ,lc.locationdescription
                  ,lc.locationCode
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
                  ,porb.orgcode
                  ,porb.organizationid
                  ,pd.flsacode

                                                 
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
                  and pc.effectivedate <= ?::date                                    
 
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
                      and pp.persposevent in ('Promo','NewAssgmnt')
                      --and current_date between pp.effectivedate and pp.enddate
                      AND CURRENT_TIMESTAMP BETWEEN PP.CREATETS AND PP.ENDTS  
                      --select * from pers_pos where personid = '66231';

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
                      and pe.emplstatus = 'A'                    
                      
                     JOIN position_desc pd 
                       ON pd.positionid = pp.positionid
                     --AND current_date between pd.effectivedate AND pd.enddate 
                       AND current_timestamp between pd.createts AND pd.endts
       
                  AND current_timestamp between pd.createts AND pd.endts
                     where pi.identitytype = 'SSN'
                       and current_timestamp between pi.createts and pi.endts
                       and date_part('year',pp.effectivedate) < date_part('year',current_date)
                       and date_part('month',pp.effectivedate) <> date_part('month',current_date)                       
                       --and pi.personid in ('65527')
                  
                  
                  ) porb 
                    on porb.personid = pp.personid
                   and porb.positionid = pp.positionid
                                                                                                                          
                  
                  where sgr.frequencycode = pc.frequencycode  -- pd.positionid in ('401113')
                    --and pp.personid = '65527'               

        ) sgr 
 
     ) GRADE on GRADE.personid = pi.personid  
     
       and grade.personid not in ('66600','66381')      
       
 
---- looks back in time for terminated - these don't work with trm logic
LEFT JOIN 

(

       SELECT distinct 
         sgrtrmp.personid
        ,sgrtrmp.positionid
        ,sgrtrmp.scheduledhours
        ,sgrtrmp.earningscode
        ,sgrtrmp.salarygradedesc
        ,sgrtrmp.grade
        ,sgrtrmp.salarygraderegion
        ,sgrtrmp.compamount
        ,sgrtrmp.orgcode
        ,sgrtrmp.organizationid
        ,CASE
               WHEN sgrtrmp.midpoint IS NOT NULL AND sgrtrmp.midpoint > 0::numeric AND (sgrtrmp.annualsalarymax - sgrtrmp.annualsalarymin) > 0::numeric THEN
               CASE
                   WHEN sgrtrmp.companyparametervalue IS NOT NULL 
                   THEN ((sgrtrmp.annualcompensation / sgrtrmp.partialpercent - sgrtrmp.annualsalarymin)::numeric(15,3) / (sgrtrmp.annualsalarymax - sgrtrmp.annualsalarymin)::numeric(15,3))::numeric(15,3)
                   ELSE (sgrtrmp.annualcompensation / sgrtrmp.partialpercent / sgrtrmp.midpoint)::numeric(15,3)
               END
               ELSE 0.00000        
         END AS percent_in_range           
        ,sgrtrmp.effectivedate
        ,sgrtrmp.enddate
        ,sgrtrmp.createts
        ,sgrtrmp.endts          
        ,sgrtrmp.increaseamount
        ,sgrtrmp.compevent
        ,sgrtrmp.prev_compamount    
        ,sgrtrmp.position_effectivedate     
        ,sgrtrmp.jobcode   
        ,sgrtrmp.positiontitle   
        ,TRUNC(sgrtrmp.hourly_rate,2) AS HOURLY_RATE
        ,sgrtrmp.locationdescription
        ,sgrtrmp.locationCode
        ,sgrtrmp.flsacode
              
         FROM (                 
                
                
                
                SELECT distinct            
                  pi.personid
     
                 ,porb.orgcode
                 ,porb.organizationid
                 ,pp.positionid
                 ,pc.frequencycode
                 ,pc.earningscode  
                 ,pc.effectivedate                                                  
                 ,pc.enddate
                 ,pc.createts
                 ,pc.endts
                 ,case when pc.compamount < 50 then 0 else pc.compamount end as compamount
                 ,pc.compevent                 
                 ,pc.increaseamount
                 ,coalesce(prev_pc.compamount,pc.compamount) as prev_compamount
                 ,case when pc.frequencycode = 'A' then pc.compamount / 2080 else pc.compamount end as hourly_rate                   
                 ,pp.scheduledhours
                 ,pp.effectivedate as position_effectivedate
                 ,jd.jobcode   
                 ,pd.positiontitle  
                 ,lc.locationdescription
                 ,lc.locationCode                                                                    

                 --,vdxp.grade
                               
                 ,sg.salarygradedesc
                 ,sg.grade 
                 ,sgr.salarygraderegion 


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
                 ,pd.flsacode  
                       
                                                                        
                 from person_identity pi
                 
                 join person_employment pe
                   on pe.personid = pi.personid
                  and current_date between pe.effectivedate and pe.enddate
                  and current_timestamp between pe.createts and pe.endts
                  and pe.emplstatus = 'T'

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
                          join person_employment pe
                            on pe.personid = pi.personid
                           and current_date between pe.effectivedate and pe.enddate
                           and current_timestamp between pe.createts and pe.endts
                           and pe.emplstatus in ('T','R')                         
    
                        where pi.identitytype = 'SSN'
                          and current_timestamp between pi.createts and pi.endts
                     --     and pi.personid in ('66231')
                       ) pc
                   on pc.personid = pi.personid

                 left JOIN pers_pos pp 
                   ON pp.personid = pi.personid
                  and pp.positionid = 
                      (select max(positionid) as maxpos 
                         from pers_pos x
                         where current_date between x.effectivedate and x.enddate
                           and current_timestamp between x.createts and x.endts
                           and x.personid = pi.personid)
                           
                 JOIN person_locations pl 
                   ON pl.personid = pi.personid 
                  --AND pl.locationid = lc.locationid              
                  AND current_date between pl.effectivedate AND pl.enddate 
                  AND current_timestamp between pl.createts AND pl.endts                      
             

                  join 
                  (
                    select distinct
                          pi.personid
                         ,pp.positionid
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

                     
                     join pos_org_rel porb                      
                       on porb.positionid = pp.positionid
                      and porb.organizationid is not null

                     join organization_code oc_cc
                       ON oc_cc.organizationid = porb.organizationid 
                      and oc_cc.organizationxid is not null
                                         
                      
                      join person_employment pe
                       on pe.personid = pi.personid
                      and current_date between pe.effectivedate and pe.enddate
                      and current_timestamp between pe.createts and pe.endts
                      and pe.emplstatus in ('T','R')   
                                            
                     where pi.identitytype = 'SSN'
                       and current_timestamp between pi.createts and pi.endts
                  --     and pi.personid in ('65623')
                  
                  
                  ) porb 
                    on porb.personid = pi.personid
 
                 JOIN position_desc pd 
                   ON pd.positionid = pp.positionid
                  --AND current_date between pd.effectivedate AND pd.enddate 
                  AND current_timestamp between pd.createts AND pd.endts
                  
                  join positionhistory vph
                    on vph.positionid = pp.positionid
                  
                  join dxpersonpositiondet vdxp
                    on vdxp.personid = pp.personid
                   and vdxp.grade is not null 
 
                  join salary_grade sg
                   on sg.grade = vdxp.grade
                  and current_date between sg.effectivedate and sg.enddate
                  and current_timestamp between sg.createts and sg.endts                                  

                 LEFT JOIN company_parameters cp 
                   ON cp.companyparametername = 'PIRB'::bpchar 
                  AND cp.companyparametervalue::text = 'MIN'::text
                  
                 JOIN frequency_codes fcc 
                   ON fcc.frequencycode = pc.frequencycode
                 JOIN frequency_codes fcpos 
                   ON fcpos.frequencycode = pp.schedulefrequency
                 JOIN frequency_codes fcsg 
                   ON fcsg.frequencycode = pc.frequencycode 
                   

                 JOIN location_codes lc 
                   ON lc.locationid = pl.locationid 
                  AND current_date between lc.effectivedate AND lc.enddate 
                  AND current_timestamp between lc.createts AND lc.endts                   
                 join salary_grade_ranges sgr
                   on sgr.grade = sg.grade 
                  and sgr.salarygraderegion = lc.salarygraderegion 
                  and sgr.edtcode = pc.earningscode
                  and current_date between sgr.effectivedate and sgr.enddate
                  and current_timestamp between sgr.createts and sgr.endts  

                 left join position_job pj
                   on pj.positionid = PP.positionid
                  and current_date between pj.effectivedate and pj.enddate
                  and current_timestamp between pj.createts and pj.endts 
                  -- select * from pers_pos where personid = '65623';select * from position_job where jobid  = '70383';    select * from jobcodedetail where jobid = '70383';  --- this should be '333739'            
                 left join job_desc jd
                   on jd.jobid = pj.jobid
                  --and current_date between jd.effectivedate and jd.enddate
                  and current_timestamp between jd.createts and jd.endts     
                  
                  --select * from jobcodedetail where jobid = '70383';
                                      
 
                 left join person_compensation prev_pc
                   on prev_pc.personid = pc.personid
                  and prev_pc.percomppid = pc.percomppid - 1   
             
                 join pspay_payment_detail ppd
                   on ppd.personid = pp.personid
                  and date_part('year',ppd.check_date)=date_part('year',current_date - interval '1 year')  
                  and PPD.etv_id in  ('E01','E64','EB5','E05','EB8','E15','E16','E17','E18','E19','E20','ECA','EAJ','EAR','EB4','EAK'
                                     ,'E30','EBF','E61','EA1','EB1','EBE',
                                      'EBH','EA2','VBB','VBC','VBD','VBA','VBE','VEH','VEJ','EB7') 
                  --and ppd.check_number = 'DIRDEP'
             
            where pi.identitytype = 'SSN'
              and current_timestamp between pi.createts and pi.endts

             -- and pi.personid = '65623'  
       ) sgrtrmp 

     ) GRADETRMP on GRADETRMP.personid = pi.personid   
       --and  GRADETRMP.personid not in ('64407','65289','66906')
 
--#####################################################################      
--- WAGENS,THE ESTATE OF BENJAMAN                                    
--- LEACH,PEGGY                                                      
--- RENNER,RICKEY                                                    
--- WASHINGTON,CYNTHIA                                               
--- 4 people who also didn't want to play well with the other terms  

LEFT JOIN 

(
       
       SELECT distinct 
         sgrretire.personid
        ,sgrretire.positionid
        ,sgrretire.scheduledhours
        ,sgrretire.earningscode
        ,sgrretire.salarygradedesc
        ,sgrretire.grade
        ,sgrretire.salarygraderegion
        ,sgrretire.compamount
        ,sgrretire.orgcode
        ,sgrretire.organizationid
        ,CASE
               WHEN sgrretire.midpoint IS NOT NULL AND sgrretire.midpoint > 0::numeric AND (sgrretire.annualsalarymax - sgrretire.annualsalarymin) > 0::numeric THEN
               CASE
                   WHEN sgrretire.companyparametervalue IS NOT NULL 
                   THEN ((sgrretire.annualcompensation / sgrretire.partialpercent - sgrretire.annualsalarymin)::numeric(15,3) / (sgrretire.annualsalarymax - sgrretire.annualsalarymin)::numeric(15,3))::numeric(15,3)
                   ELSE (sgrretire.annualcompensation / sgrretire.partialpercent / sgrretire.midpoint)::numeric(15,3)
               END
               ELSE 0.00000        
         END AS percent_in_range           
        ,sgrretire.effectivedate
        ,sgrretire.enddate
        ,sgrretire.createts
        ,sgrretire.endts          
        ,sgrretire.increaseamount
        ,sgrretire.compevent
        ,sgrretire.prev_compamount    
        ,sgrretire.position_effectivedate     
        ,sgrretire.jobcode   
        ,sgrretire.positiontitle   
        ,TRUNC(sgrretire.hourly_rate,2) AS HOURLY_RATE
        ,sgrretire.locationdescription
        ,sgrretire.locationCode
        ,sgrretire.flsacode
        ,sgrretire.pct_in_range
              
         FROM ( 
                SELECT distinct            
                  pi.personid
                 ,pc.compevent
                 ,case when pc.compamount < 50 then 0 else pc.compamount end as compamount
                 ,pc.increaseamount
                 ,pc.earningscode  
                 ,pc.effectivedate                                                  
                 ,pc.enddate
                 ,pc.createts
                 ,pc.endts                           
                 ,coalesce(prev_pc.compamount,pc.compamount) as prev_compamount
                 ,case when pc.frequencycode = 'A' then pc.compamount / 2080 else pc.compamount end as hourly_rate                     
                 ,pp.positionid
                 ,pp.scheduledhours
                 ,pp.effectivedate as position_effectivedate        
                 ,porb.orgcode
                 ,porb.organizationid
                 ,pd.positiontitle   
                 ,jd.jobcode  
                 ,sg.salarygradedesc
                 ,sg.grade
                 ,sgr.salarygraderegion
                 ,lc.locationdescription
                 ,lc.locationCode
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
                 ,pd.flsacode       
                 ,vpir.percent_in_range as pct_in_range 
                                            
                 from person_identity pi
                 
                 join person_employment pe
                   on pe.personid = pi.personid
                  and current_date between pe.effectivedate and pe.enddate
                  and current_timestamp between pe.createts and pe.endts
                  and pe.emplstatus = 'T'

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
                          join person_employment pe
                            on pe.personid = pi.personid
                           and current_date between pe.effectivedate and pe.enddate
                           and current_timestamp between pe.createts and pe.endts
                           and pe.emplstatus in ('T','R')                         
    
                        where pi.identitytype = 'SSN'
                          and current_timestamp between pi.createts and pi.endts
                        --  and pi.personid in ('63675')
                       ) pc
                   on pc.personid = pi.personid
 
                 left JOIN pers_pos pp 
                   ON pp.personid = pi.personid
                  and pp.updatets is not null
                 
                 JOIN person_locations pl 
                   ON pl.personid = pi.personid 
                  --AND pl.locationid = lc.locationid              
                  AND current_date between pl.effectivedate AND pl.enddate 
                  AND current_timestamp between pl.createts AND pl.endts                   

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
                      AND CURRENT_TIMESTAMP BETWEEN PP.CREATETS AND PP.ENDTS 

                    

                     join pos_org_rel porb 
                       ON porb.positionid = PP.positionid 
                      AND porb.posorgreltype = 'Budget' 
                      and current_timestamp between porb.createts and porb.endts
                      and porb.posorgrelevent = 'NewPos'
                        
                     join organization_code oc_cc
                       ON oc_cc.organizationid = porb.organizationid
                      AND oc_cc.organizationtype = 'CC'

                      --and current_timestamp between oc_cc.createts and oc_cc.endts 
                      --and oc_cc.effectivedate - interval '1 day' <> oc_cc.enddate 
                      
                      join person_employment pe
                       on pe.personid = pi.personid
                      and current_date between pe.effectivedate and pe.enddate
                      and current_timestamp between pe.createts and pe.endts
                      and pe.emplstatus in ('T','R')                      
                      
                     where pi.identitytype = 'SSN'
                       and current_timestamp between pi.createts and pi.endts
                      -- and pi.personid in ('63675')
                  
                  
                  ) porb 
                    on porb.personid = pi.personid
                  
                 JOIN position_desc pd 
                   ON pd.positionid = pp.positionid
                  --AND current_date between pd.effectivedate AND pd.enddate 
                  --AND current_timestamp between pd.createts AND pd.endts

                 left join dcperscompensationdet vpir
                   on vpir.personid = pp.personid 
                  and current_date between vpir.effectivedate and vpir.enddate
                  and current_timestamp between vpir.createts and vpir.endts   

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
                  --and current_date between jd.effectivedate and jd.enddate
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
                  and PPD.etv_id in  ('E01','E64','EB5','E05','EB8','E15','E16','E17','E18','E19','E20','ECA','EAJ','EAR','EB4','EAK'
                                     ,'E30','EBF','E61','EA1','EB1','EBE',
                                      'EBH','EA2','VBB','VBC','VBD','VBA','VBE','VEH','VEJ','EB7') 
                  --and ppd.check_number = 'DIRDEP'
             
            where pi.identitytype = 'SSN'
              and current_timestamp between pi.createts and pi.endts
              and sgr.frequencycode = pc.frequencycode
          and pp.PERSONID in( '63675', '63460','63841','65260')
       ) sgrretire

     ) GRADERT on GRADERT.personid = pi.personid    

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
---EE's where I could not get f3_accounting_unit work with term logic -note this is a union  
left join 
     (
       SELECT distinct 
         sgrcurr.personid
        ,sgrcurr.earningscode
        ,sgrcurr.positionid
        ,sgrcurr.salarygraderegion
        ,sgrcurr.salarygradedesc
        ,sgrcurr.positiontitle
        ,sgrcurr.jobcode
        ,sgrcurr.compamount
        ,sgrcurr.locationdescription
        ,sgrcurr.locationCode
         ,sgrcurr.vpcpira_pct_in_range as percent_in_range 
         ,sgrcurr.effectivedate    
         ,sgrcurr.increaseamount
         ,sgrcurr.compevent
         ,sgrcurr.prev_compamount   
         ,sgrcurr.position_effectivedate  
         ,TRUNC(sgrcurr.hourly_rate,2) AS HOURLY_RATE
         ,sgrcurr.orgcode
         ,sgrcurr.organizationid    
         ,sgrcurr.flsacode
         from (
               select 
                pp.personid
               ,pp.positionid
               ,pp.effectivedate as position_effectivedate 
               ,vpd.positiontitle
               ,vpd.grade
               ,vpd.shiftcode
               ,pc.earningscode
               ,pc.compevent 
               ,case when pc.compamount < 50 then 0 else pc.compamount end as compamount
               ,pc.increaseamount
               ,pc.effectivedate
               ,pc.enddate
               ,pc.createts
               ,pc.endts      
               ,case when pc.frequencycode = 'A' then pc.compamount / 2080 else pc.compamount end as hourly_rate 
               ,coalesce(prev_pc.compamount,pc.compamount) as prev_compamount  
               ,sg.salarygradedesc 
               ,sgr.grade
               ,sgr.edtcode
               ,sgr.salarygraderegion
               ,sgr.enddate
               ,jd.jobcode
               ,lc.locationdescription   
               ,lc.locationCode  
               
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
               ,porb.orgcode
               ,porb.organizationid      
               ,pd.flsacode    
               ,vpir.percent_in_range as pct_in_range  
               ,vpcpira.percent_in_range as vpcpira_pct_in_range        
                 
               from pers_pos pp
               
               join person_compensation pc
                 on pc.personid = pp.personid
                and current_date between pc.effectivedate and pc.enddate
                and current_timestamp between pc.createts and pc.endts
                and pc.effectivedate <= ?::date 
               
               left join dcperscompensationdet vpir
                 on vpir.personid = pp.personid 
                and current_date between vpir.effectivedate and vpir.enddate
                and current_timestamp between vpir.createts and vpir.endts
               
               left join personcomppercentinrangeasof vpcpira
                 on vpcpira.personid = pp.personid        
                and current_date = vpcpira.asofdate  
                
               left join person_compensation prev_pc
                 on prev_pc.personid = pc.personid
                and prev_pc.percomppid = pc.percomppid - 1    
               
               join positiondetails vpd
                 on vpd.positionid = pp.positionid
               
               join salary_grade sg
                 on sg.grade = vpd.grade
                and current_date between sg.effectivedate and sg.enddate
                and current_timestamp between sg.createts and sg.endts 
               
               join salary_grade_ranges sgr
                 on sgr.grade = vpd.grade
                and sgr.edtcode = pc.earningscode
                and current_date between sgr.effectivedate and sgr.enddate
                and current_timestamp between sgr.createts and sgr.endts
                and sgr.salarygraderangepid in 
                    (select max(salarygraderangepid) from salary_grade_ranges x
                      where current_date between x.effectivedate and x.enddate
                        and current_timestamp between x.createts and x.endts
                        and x.edtcode = pc.earningscode
                        and x.grade = vpd.grade)
                    
               left join position_job pj
                 on pj.positionid = PP.positionid
                and current_date between pj.effectivedate and pj.enddate
                and current_timestamp between pj.createts and pj.endts
               
               left join job_desc jd
                 on jd.jobid = pj.jobid
                and current_date between jd.effectivedate and jd.enddate
                and current_timestamp between jd.createts and jd.endts   
               
               join person_locations pl
                 on pl.personid = pp.personid
                and current_date between pl.effectivedate and pl.enddate
                and current_timestamp between pl.createts and pl.endts
               
               JOIN location_codes lc 
                 ON lc.locationid = pl.locationid
                AND current_date between lc.effectivedate AND lc.enddate 
                AND current_timestamp between lc.createts AND lc.endts  
                -- select * from location_codes 
               
               LEFT JOIN company_parameters cp 
                 ON cp.companyparametername = 'PIRB'::bpchar 
                AND cp.companyparametervalue::text = 'MIN'::text  
               
         
               JOIN position_desc pd 
                 ON pd.positionid = pp.positionid
                AND current_date between pd.effectivedate AND pd.enddate 
                AND current_timestamp between pd.createts AND pd.endts         
                                
                                      
               JOIN frequency_codes fcc 
                 ON fcc.frequencycode = pc.frequencycode
               JOIN frequency_codes fcpos 
                 ON fcpos.frequencycode = pp.schedulefrequency
               JOIN frequency_codes fcsg 
                 ON fcsg.frequencycode = pc.frequencycode
             
               join 
               (
                  select distinct
                       pi.personid
                      ,PP.positionid 
                      ,PP.EFFECTIVEDATE
                      ,PP.ENDDATE
                    --  ,porb.budget_organization as organizationid
                    --,porb.posorgrelevent
                      ,porb.effectivedate
                      ,porb.enddate   
                      ,porb1.organizationid    
                      ,porb1.effectivedate
                      ,porb1.enddate     
                      ,oc_cc.orgcode   
                      ,oc_cc.organizationxid                                             
                                                                                           
                  from person_identity pi
                  
                  JOIN pers_pos pp 
                    ON pp.personid = pi.personid
                   and current_date between pp.effectivedate and pp.enddate
                   AND CURRENT_TIMESTAMP BETWEEN PP.CREATETS AND PP.ENDTS  

                  join person_employment pe
                    on pe.personid = pi.personid
                   and current_date between pe.effectivedate and pe.enddate
                   and current_timestamp between pe.createts and pe.endts
                   and pe.emplstatus = 'A'                      

                  join dxpersonpositiondet porb
                    ON porb.personid = pi.personid
                   and porb.positionid = pp.positionid


                  join pos_org_rel porb1
                    ON porb1.positionid = porb.positionid 
                   AND porb1.posorgreltype = 'Budget' 
                   and current_timestamp between porb1.createts and porb1.endts                   
                   
                  join organization_code oc_cc
                    ON oc_cc.organizationid = porb1.organizationid
                   AND oc_cc.organizationtype = 'CC'
                   and current_date between oc_cc.effectivedate and oc_cc.enddate
                   and current_timestamp between oc_cc.createts and oc_cc.endts 
                   and oc_cc.effectivedate - interval '1 day' <> oc_cc.enddate                       
                   --- select * from organization_code where organizationid = '642'  
                                    
                   
                  where pi.identitytype = 'SSN'
                    and current_timestamp between pi.createts and pi.endts                      
                    --and pi.personid in ('66231', '66600','67830')
                 ) porb 
                on porb.personid = pp.personid
               and porb.positionid = pp.positionid
                                 
               where current_date between pp.effectivedate and pp.enddate
               and current_timestamp between pp.createts and pp.endts
     
      
      and pp.personid in ('66231', '66600','67830','63747','66381','66044','66504')
     ) sgrcurr
     union 
            SELECT distinct 
         sgrtrm.personid
        ,sgrtrm.earningscode         
        ,sgrtrm.positionid
        --,sgrtrm.scheduledhours
        ,sgrtrm.salarygraderegion
        ,sgrtrm.salarygradedesc
        ,sgrtrm.positiontitle 
        ,sgrtrm.jobcode         
        ,sgrtrm.compamount               
        ,sgrtrm.locationdescription 
        ,sgrtrm.locationCode        
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
        ,sgrtrm.increaseamount
        ,sgrtrm.compevent
        ,sgrtrm.prev_compamount    
        ,sgrtrm.position_effectivedate
        ,TRUNC(sgrtrm.hourly_rate,2) AS HOURLY_RATE        
        ,sgrtrm.orgcode
        ,sgrtrm.organizationid
        ,sgrtrm.flsacode
              
         FROM ( 
                SELECT distinct            
                  pi.personid
                 ,pc.compevent
                 ,case when pc.compamount < 50 then 0 else pc.compamount end as compamount
                 ,pc.increaseamount
                 ,pc.earningscode  
                 ,pc.effectivedate                                                  
                 ,pc.enddate
                 ,pc.createts
                 ,pc.endts                           
                 ,coalesce(prev_pc.compamount,pc.compamount) as prev_compamount
                 ,case when pc.frequencycode = 'A' then pc.compamount / 2080 else pc.compamount end as hourly_rate                     
                 ,pp.positionid
                 ,pp.scheduledhours
                 ,pp.effectivedate as position_effectivedate        
                 ,porb.orgcode
                 ,porb.organizationid
                 ,pd.positiontitle   
                 ,jd.jobcode  
                 ,sg.salarygradedesc
                 ,sg.grade
                 ,sgr.salarygraderegion
                 ,lc.locationdescription
                 ,lc.locationCode
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
                 ,pd.flsacode       
                 ,vpir.percent_in_range as pct_in_range 
                                            
                 from person_identity pi
                 
                 join person_employment pe
                   on pe.personid = pi.personid
                  and current_date between pe.effectivedate and pe.enddate
                  and current_timestamp between pe.createts and pe.endts
                  and pe.emplstatus = 'T'

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
                          join person_employment pe
                            on pe.personid = pi.personid
                           and current_date between pe.effectivedate and pe.enddate
                           and current_timestamp between pe.createts and pe.endts
                           and pe.emplstatus in ('T','R')                         
    
                        where pi.identitytype = 'SSN'
                          and current_timestamp between pi.createts and pi.endts
                          and pi.personid in ('66231')
                       ) pc
                   on pc.personid = pi.personid
 
                 left JOIN pers_pos pp 
                   ON pp.personid = pi.personid
                  and pp.updatets is not null
                 
                 JOIN person_locations pl 
                   ON pl.personid = pi.personid 
                  --AND pl.locationid = lc.locationid              
                  AND current_date between pl.effectivedate AND pl.enddate 
                  AND current_timestamp between pl.createts AND pl.endts                   

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
                      AND CURRENT_TIMESTAMP BETWEEN PP.CREATETS AND PP.ENDTS 

                     join pos_org_rel porb 
                       ON porb.positionid = PP.positionid 
                      AND porb.posorgreltype = 'Budget' 
                      AND CURRENT_DATE BETWEEN PORB.EFFECTIVEDATE AND PORB.ENDDATE
                      and current_timestamp between porb.createts and porb.endts

                     join organization_code oc_cc
                       ON oc_cc.organizationid = porb.organizationid
                      AND oc_cc.organizationtype = 'CC'
                      
                      join person_employment pe
                       on pe.personid = pi.personid
                      and current_date between pe.effectivedate and pe.enddate
                      and current_timestamp between pe.createts and pe.endts
                      and pe.emplstatus in ('T','R')                      
                      
                     where pi.identitytype = 'SSN'
                       and current_timestamp between pi.createts and pi.endts
                       and pi.personid in ('66231')
                  
                  
                  ) porb 
                    on porb.personid = pi.personid
                  
                 JOIN position_desc pd 
                   ON pd.positionid = pp.positionid
                  --AND current_date between pd.effectivedate AND pd.enddate 
                  AND current_timestamp between pd.createts AND pd.endts

                 left join dcperscompensationdet vpir
                   on vpir.personid = pp.personid 
                  and current_date between vpir.effectivedate and vpir.enddate
                  and current_timestamp between vpir.createts and vpir.endts   

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
                  --and current_date between jd.effectivedate and jd.enddate
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
                  and PPD.etv_id in  ('E01','E64','EB5','E05','EB8','E15','E16','E17','E18','E19','E20','ECA','EAJ','EAR','EB4','EAK'
                                     ,'E30','EBF','E61','EA1','EB1','EBE',
                                      'EBH','EA2','VBB','VBC','VBD','VBA','VBE','VEH','VEJ','EB7') 
                  --and ppd.check_number = 'DIRDEP'
             
            where pi.identitytype = 'SSN'
              and current_timestamp between pi.createts and pi.endts
              and sgr.frequencycode = pc.frequencycode
              and pp.personid = '66231'  
       ) sgrtrm     

union 
       SELECT distinct 
         sgrprior.personid
        ,sgrprior.earningscode
        ,sgrprior.positionid
        ,sgrprior.salarygraderegion
        ,sgrprior.salarygradedesc
        ,sgrprior.positiontitle
        ,sgrprior.jobcode
        ,sgrprior.compamount
        ,sgrprior.locationdescription
        ,sgrprior.locationCode
        ,sgrprior.vpcpira_pct_in_range as percent_in_range         
        ,sgrprior.effectivedate    
        ,sgrprior.increaseamount
        ,sgrprior.compevent
        ,sgrprior.prev_compamount   
        ,sgrprior.position_effectivedate  
        ,TRUNC(sgrprior.hourly_rate,2) AS HOURLY_RATE
        ,sgrprior.orgcode
        ,sgrprior.organizationid    
        ,sgrprior.flsacode
         from (
               select 
                pp.personid
               ,pp.positionid
               ,pp.effectivedate as position_effectivedate 
               ,vpd.positiontitle
               ,vpd.grade
               ,vpd.shiftcode
               ,pc.earningscode
               ,pc.compevent 
               ,pc.compamount
               ,pc.increaseamount
               ,pp.effectivedate
               ,pc.enddate
               ,pc.createts
               ,pc.endts      
               ,case when pc.frequencycode = 'A' then pc.compamount / 2080 else pc.compamount end as hourly_rate 
               ,coalesce(prev_pc.compamount,pc.compamount) as prev_compamount  
               ,sg.salarygradedesc 
               ,sgr.grade
               ,sgr.edtcode
               ,sgr.salarygraderegion
               ,sgr.enddate
               ,jd.jobcode
               ,lc.locationdescription   
               ,lc.locationCode  
               
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
               ,porb.orgcode
               ,porb.organizationid      
               ,pd.flsacode    
               ,vpir.percent_in_range as pct_in_range  
               ,vpcpira.percent_in_range as vpcpira_pct_in_range        
                 
               from pers_pos pp
               
               join person_compensation pc
                 on pc.personid = pp.personid
                and current_date between pc.effectivedate and pc.enddate
                and current_timestamp between pc.createts and pc.endts
               
               left join dcperscompensationdet vpir
                 on vpir.personid = pp.personid 
                and current_date between vpir.effectivedate and vpir.enddate
                and current_timestamp between vpir.createts and vpir.endts
               
               left join personcomppercentinrangeasof vpcpira
                 on vpcpira.personid = pp.personid        
                and current_date = vpcpira.asofdate  
                
               left join person_compensation prev_pc
                 on prev_pc.personid = pc.personid
                and prev_pc.percomppid = pc.percomppid - 1    
               
               join positiondetails vpd
                 on vpd.positionid = pp.positionid
               
               join salary_grade sg
                 on sg.grade = vpd.grade
                and current_date between sg.effectivedate and sg.enddate
                and current_timestamp between sg.createts and sg.endts 
               
               join salary_grade_ranges sgr
                 on sgr.grade = vpd.grade
                and sgr.edtcode = pc.earningscode
                and current_date between sgr.effectivedate and sgr.enddate
                and current_timestamp between sgr.createts and sgr.endts
                and sgr.salarygraderangepid in 
                    (select max(salarygraderangepid) from salary_grade_ranges x
                      where current_date between x.effectivedate and x.enddate
                        and current_timestamp between x.createts and x.endts
                        and x.edtcode = pc.earningscode
                        and x.grade = vpd.grade)
                    
               left join position_job pj
                 on pj.positionid = PP.positionid
                and current_date between pj.effectivedate and pj.enddate
                and current_timestamp between pj.createts and pj.endts
               
               left join job_desc jd
                 on jd.jobid = pj.jobid
                and current_date between jd.effectivedate and jd.enddate
                and current_timestamp between jd.createts and jd.endts   
               
               join person_locations pl
                 on pl.personid = pp.personid
                and current_date between pl.effectivedate and pl.enddate
                and current_timestamp between pl.createts and pl.endts
               
               JOIN location_codes lc 
                 ON lc.locationid = pl.locationid
                AND current_date between lc.effectivedate AND lc.enddate 
                AND current_timestamp between lc.createts AND lc.endts  
                -- select * from location_codes 
               
               LEFT JOIN company_parameters cp 
                 ON cp.companyparametername = 'PIRB'::bpchar 
                AND cp.companyparametervalue::text = 'MIN'::text  
               
         
               JOIN position_desc pd 
                 ON pd.positionid = pp.positionid
            --AND current_date between pd.effectivedate AND pd.enddate 
                AND current_timestamp between pd.createts AND pd.endts         
                                
                                      
               JOIN frequency_codes fcc 
                 ON fcc.frequencycode = pc.frequencycode
               JOIN frequency_codes fcpos 
                 ON fcpos.frequencycode = pp.schedulefrequency
               JOIN frequency_codes fcsg 
                 ON fcsg.frequencycode = pc.frequencycode
             
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
                   and pp.effectivedate <= '2017-12-29'
                   AND CURRENT_TIMESTAMP BETWEEN PP.CREATETS AND PP.ENDTS  
                   --select * from pers_pos where personid = '64831';
                  join pos_org_rel porb 
                    ON porb.positionid = PP.positionid 
                   AND porb.posorgreltype = 'Budget' 
                   and current_timestamp between porb.createts and porb.endts
         
                   -- select * from pos_org_rel where positionid = '389427'
         
                  
                  join organization_code oc_cc
                    ON oc_cc.organizationid = porb.organizationid
                   AND oc_cc.organizationtype = 'CC'
                   and current_timestamp between oc_cc.createts and oc_cc.endts 
                   and oc_cc.effectivedate - interval '1 day' <> oc_cc.enddate                       
                   --- select * from organization_code where organizationid = '1363'                 
                   
                   join person_employment pe
                    on pe.personid = pi.personid
                   and current_date between pe.effectivedate and pe.enddate
                   and current_timestamp between pe.createts and pe.endts
                   and pe.emplstatus = 'A'   
                                    
                   
                  where pi.identitytype = 'SSN'
                    and current_timestamp between pi.createts and pi.endts                      
                    and pi.personid in ('63786', '65993','65734','66182','65773','63090','66224','66348','65810','66468')
               ) porb 
                on porb.personid = pp.personid
               and porb.positionid = pp.positionid
                                 
               where pp.effectivedate <= '2017-12-29'
               and current_timestamp between pp.createts and pp.endts
     
      
     and pp.personid in('63786', '65993','65734','66182','65773','63090','66224','66348','65810','66468')
     ) sgrprior

union 
        SELECT distinct 
         sgrgokwtd.personid
        ,sgrgokwtd.earningscode
        ,sgrgokwtd.positionid
        ,sgrgokwtd.salarygraderegion
        ,sgrgokwtd.salarygradedesc
        ,sgrgokwtd.positiontitle
        ,sgrgokwtd.jobcode
        ,sgrgokwtd.compamount
        ,sgrgokwtd.locationdescription
        ,sgrgokwtd.locationCode
        ,sgrgokwtd.vpcpira_pct_in_range as percent_in_range         
        ,sgrgokwtd.effectivedate    
        ,sgrgokwtd.increaseamount
        ,sgrgokwtd.compevent
        ,sgrgokwtd.prev_compamount   
        ,sgrgokwtd.position_effectivedate  
        ,TRUNC(sgrgokwtd.hourly_rate,2) AS HOURLY_RATE
        ,sgrgokwtd.orgcode
        ,sgrgokwtd.organizationid    
        ,sgrgokwtd.flsacode
         from (
 
               select  distinct
                pp.personid
               ,pp.positionid
               ,pp.effectivedate as position_effectivedate 
               ,vpd.positiontitle
               ,vpd.grade
               ,vpd.shiftcode
               ,pc.earningscode
               ,pc.compevent 
               ,pc.compamount
               ,pc.increaseamount
               ,pp.effectivedate
               ,pc.enddate
               ,pc.createts
               ,pc.endts      
               ,case when pc.frequencycode = 'A' then pc.compamount / 2080 else pc.compamount end as hourly_rate 
               ,coalesce(prev_pc.compamount,pc.compamount) as prev_compamount  
               ,sg.salarygradedesc 
               ,sgr.grade
               ,sgr.edtcode
               ,sgr.salarygraderegion
               ,sgr.enddate
               ,jd.jobcode
               ,lc.locationdescription   
               ,lc.locationCode  
               
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
               ,porb.orgcode
               ,porb.organizationid      
               ,pd.flsacode    
               ,vpir.percent_in_range as pct_in_range  
               ,vpcpira.percent_in_range as vpcpira_pct_in_range        
                 
               from pers_pos pp
               
               join person_compensation pc
                 on pc.personid = pp.personid
                and current_date between pc.effectivedate and pc.enddate
                and current_timestamp between pc.createts and pc.endts
               
               left join dcperscompensationdet vpir
                 on vpir.personid = pp.personid 
                and current_date between vpir.effectivedate and vpir.enddate
                and current_timestamp between vpir.createts and vpir.endts
               
               left join personcomppercentinrangeasof vpcpira
                 on vpcpira.personid = pp.personid        
                and current_date = vpcpira.asofdate  
                
               left join person_compensation prev_pc
                 on prev_pc.personid = pc.personid
                and prev_pc.percomppid = pc.percomppid - 1    
               
               join positiondetails vpd
                 on vpd.positionid = pp.positionid
               
               join salary_grade sg
                 on sg.grade = vpd.grade
                and current_date between sg.effectivedate and sg.enddate
                and current_timestamp between sg.createts and sg.endts 
               
               join salary_grade_ranges sgr
                 on sgr.grade = vpd.grade
                and sgr.edtcode = pc.earningscode
                and current_date between sgr.effectivedate and sgr.enddate
                and current_timestamp between sgr.createts and sgr.endts
                and sgr.salarygraderangepid in 
                    (select max(salarygraderangepid) from salary_grade_ranges x
                      where current_date between x.effectivedate and x.enddate
                        and current_timestamp between x.createts and x.endts
                        and x.edtcode = pc.earningscode
                        and x.grade = vpd.grade)
                    
               left join position_job pj
                 on pj.positionid = PP.positionid
                and current_date between pj.effectivedate and pj.enddate
                and current_timestamp between pj.createts and pj.endts
               
               left join job_desc jd
                 on jd.jobid = pj.jobid
                and current_date between jd.effectivedate and jd.enddate
                and current_timestamp between jd.createts and jd.endts   
               
               join person_locations pl
                 on pl.personid = pp.personid
                and current_date between pl.effectivedate and pl.enddate
                and current_timestamp between pl.createts and pl.endts
               
               JOIN location_codes lc 
                 ON lc.locationid = pl.locationid
                AND current_date between lc.effectivedate AND lc.enddate 
                AND current_timestamp between lc.createts AND lc.endts  
                -- select * from location_codes 
               
               LEFT JOIN company_parameters cp 
                 ON cp.companyparametername = 'PIRB'::bpchar 
                AND cp.companyparametervalue::text = 'MIN'::text  
               
         
               JOIN position_desc pd 
                 ON pd.positionid = pp.positionid
            --AND current_date between pd.effectivedate AND pd.enddate 
                AND current_timestamp between pd.createts AND pd.endts         
                                
                                      
               JOIN frequency_codes fcc 
                 ON fcc.frequencycode = pc.frequencycode
               JOIN frequency_codes fcpos 
                 ON fcpos.frequencycode = pp.schedulefrequency
               JOIN frequency_codes fcsg 
                 ON fcsg.frequencycode = pc.frequencycode
             
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
                   and pp.effectivedate <= '2017-12-29'
                   AND CURRENT_TIMESTAMP BETWEEN PP.CREATETS AND PP.ENDTS  
                   and pp.effectivedate - interval '1 day' <> pp.enddate
                   --select * from pers_pos where personid = '66583';
                  join pos_org_rel porb 
                    ON porb.positionid = PP.positionid 
                   AND porb.posorgreltype = 'Budget' 
                   and current_timestamp between porb.createts and porb.endts
         
                   -- select * from pos_org_rel where positionid = '402549'
         
                  
                  join organization_code oc_cc
                    ON oc_cc.organizationid = porb.organizationid
                   AND oc_cc.organizationtype = 'CC'
                   and current_timestamp between oc_cc.createts and oc_cc.endts 
                   and oc_cc.effectivedate - interval '1 day' <> oc_cc.enddate                       
                   --- select * from organization_code where organizationid = '1363'                 
                   
                   join person_employment pe
                    on pe.personid = pi.personid
                   and current_date between pe.effectivedate and pe.enddate
                   and current_timestamp between pe.createts and pe.endts
                   and pe.emplstatus = 'A'   
                                    
                   
                  where pi.identitytype = 'SSN'
                    and current_timestamp between pi.createts and pi.endts                      
                    and pi.personid in ('66583')
                    and oc_cc.orgcode = '562110'
               ) porb 
                on porb.personid = pp.personid
               and porb.positionid = pp.positionid
                                 
               where pp.effectivedate <= '2017-12-29'
               and current_timestamp between pp.createts and pp.endts
               and pp.enddate <= '2017-12-29'
     
      
     and pp.personid in('66583')
     ) sgrgokwtd     
     
union 

        SELECT distinct 
         sgrmcmt.personid
        ,sgrmcmt.earningscode
        ,sgrmcmt.positionid
        ,sgrmcmt.salarygraderegion
        ,sgrmcmt.salarygradedesc
        ,sgrmcmt.positiontitle
        ,sgrmcmt.jobcode
        ,sgrmcmt.compamount
        ,sgrmcmt.locationdescription
        ,sgrmcmt.locationCode
        ,sgrmcmt.vpcpira_pct_in_range as percent_in_range         
        ,sgrmcmt.effectivedate    
        ,sgrmcmt.increaseamount
        ,sgrmcmt.compevent
        ,sgrmcmt.prev_compamount   
        ,sgrmcmt.position_effectivedate  
        ,TRUNC(sgrmcmt.hourly_rate,2) AS HOURLY_RATE
        ,sgrmcmt.orgcode
        ,sgrmcmt.organizationid    
        ,sgrmcmt.flsacode
         from (
 
               select  distinct
                pp.personid
               ,pp.positionid
               ,pp.effectivedate as position_effectivedate 
               ,vpd.positiontitle
               ,vpd.grade
               ,vpd.shiftcode
               ,pc.earningscode
               ,pc.compevent 
               ,pc.compamount
               ,pc.increaseamount
               ,pp.effectivedate
               ,pc.enddate
               ,pc.createts
               ,pc.endts      
               ,case when pc.frequencycode = 'A' then pc.compamount / 2080 else pc.compamount end as hourly_rate 
               ,coalesce(prev_pc.compamount,pc.compamount) as prev_compamount  
               ,sg.salarygradedesc 
               ,sgr.grade
               ,sgr.edtcode
               ,sgr.salarygraderegion
               ,sgr.enddate
               ,jd.jobcode
               ,lc.locationdescription   
               ,lc.locationCode  
               
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
               ,porb.orgcode
               ,porb.organizationid      
               ,pd.flsacode    
               ,vpir.percent_in_range as pct_in_range  
               ,vpcpira.percent_in_range as vpcpira_pct_in_range        
                 
               from pers_pos pp
               
               join person_compensation pc
                 on pc.personid = pp.personid
                and current_date between pc.effectivedate and pc.enddate
                and current_timestamp between pc.createts and pc.endts
               
               left join dcperscompensationdet vpir
                 on vpir.personid = pp.personid 
                and current_date between vpir.effectivedate and vpir.enddate
                and current_timestamp between vpir.createts and vpir.endts
               
               left join personcomppercentinrangeasof vpcpira
                 on vpcpira.personid = pp.personid        
                and current_date = vpcpira.asofdate  
                
               left join person_compensation prev_pc
                 on prev_pc.personid = pc.personid
                and prev_pc.percomppid = pc.percomppid - 1    
               
               join positiondetails vpd
                 on vpd.positionid = pp.positionid
               
               join salary_grade sg
                 on sg.grade = vpd.grade
                and current_date between sg.effectivedate and sg.enddate
                and current_timestamp between sg.createts and sg.endts 
               
               join salary_grade_ranges sgr
                 on sgr.grade = vpd.grade
                and sgr.edtcode = pc.earningscode
                and current_date between sgr.effectivedate and sgr.enddate
                and current_timestamp between sgr.createts and sgr.endts
                and sgr.salarygraderangepid in 
                    (select max(salarygraderangepid) from salary_grade_ranges x
                      where current_date between x.effectivedate and x.enddate
                        and current_timestamp between x.createts and x.endts
                        and x.edtcode = pc.earningscode
                        and x.grade = vpd.grade)
                    
               left join position_job pj
                 on pj.positionid = PP.positionid
                and current_date between pj.effectivedate and pj.enddate
                and current_timestamp between pj.createts and pj.endts
               
               left join job_desc jd
                 on jd.jobid = pj.jobid
                and current_date between jd.effectivedate and jd.enddate
                and current_timestamp between jd.createts and jd.endts   
               
               join person_locations pl
                 on pl.personid = pp.personid
                and current_date between pl.effectivedate and pl.enddate
                and current_timestamp between pl.createts and pl.endts
               
               JOIN location_codes lc 
                 ON lc.locationid = pl.locationid
                AND current_date between lc.effectivedate AND lc.enddate 
                AND current_timestamp between lc.createts AND lc.endts  
                -- select * from location_codes 
               
               LEFT JOIN company_parameters cp 
                 ON cp.companyparametername = 'PIRB'::bpchar 
                AND cp.companyparametervalue::text = 'MIN'::text  
               
         
               JOIN position_desc pd 
                 ON pd.positionid = pp.positionid
            --AND current_date between pd.effectivedate AND pd.enddate 
                AND current_timestamp between pd.createts AND pd.endts         
                                
                                      
               JOIN frequency_codes fcc 
                 ON fcc.frequencycode = pc.frequencycode
               JOIN frequency_codes fcpos 
                 ON fcpos.frequencycode = pp.schedulefrequency
               JOIN frequency_codes fcsg 
                 ON fcsg.frequencycode = pc.frequencycode
             
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
                   and pp.effectivedate <= '2017-12-29'
                   AND CURRENT_TIMESTAMP BETWEEN PP.CREATETS AND PP.ENDTS  
                   and pp.effectivedate - interval '1 day' <> pp.enddate
                   --select * from pers_pos where personid = '66583';
                  join pos_org_rel porb 
                    ON porb.positionid = PP.positionid 
                   AND porb.posorgreltype = 'Budget' 
                   and current_timestamp between porb.createts and porb.endts
         
                   -- select * from pos_org_rel where positionid = '402549'
         
                  
                  join organization_code oc_cc
                    ON oc_cc.organizationid = porb.organizationid
                   AND oc_cc.organizationtype = 'CC'
                   and current_timestamp between oc_cc.createts and oc_cc.endts 
                   and oc_cc.effectivedate - interval '1 day' <> oc_cc.enddate                       
                   --- select * from organization_code where organizationid = '1363'                 
                   
                   join person_employment pe
                    on pe.personid = pi.personid
                   and current_date between pe.effectivedate and pe.enddate
                   and current_timestamp between pe.createts and pe.endts
                   and pe.emplstatus = 'A'   
                                    
                   
                  where pi.identitytype = 'SSN'
                    and current_timestamp between pi.createts and pi.endts                      
                    and pi.personid in ('66460')
                    --and oc_cc.orgcode = '562110'
               ) porb 
                on porb.personid = pp.personid
               and porb.positionid = pp.positionid
                                 
               where pp.effectivedate <= '2017-12-29'
               and current_timestamp between pp.createts and pp.endts
             --  and pp.enddate <= '2017-12-29'
     
      
     and pp.personid in('66460')
     ) sgrmcmt
          
     ) GRADEU on GRADEU.personid = pi.personid  
         
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts

  --- this is needed to eliminate either current or terminated agents

  and pi.personid not in 
     (select personid from dxpersonpositiondet x
       where ((positiontitle in ('Agent','Acct Rep')
         and current_date between effectivedate and enddate
         and pe.emplstatus = 'A')
          or (positiontitle in ('Agent','Acct Rep') and pe.emplstatus = 'T'))
            
       group by 1) 
  and ((ytdcomp.taxable_wage > 0) or (ytdsev.severance_pay > 0) or (ytdfica.fica > 0) or (ytdab.ALL_bonus > 0))
 
-- AND PI.PERSONID in( '64166')
--
  order by f5_emp_name