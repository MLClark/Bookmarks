

,pufv3.ufvalue as f25_o16_perf_review_desc
,case when pufv2.ufvalue in ('Y','Regular','Combined') then ' ' else pufv2.ufvalue end as f26_o17_perf_review_rating

--,ytdsev.severance_pay
,case when pe.emplstatus =  'A' then 'Acti'
      when pe.emplstatus =  'L' then 'LOA'
      when pe.emplstatus =  'T' and pe.emplevent = 'Retire' and ytdsev.severance_pay <> 0 then 'RWS' --RWOS if the Employment Event is Retirement and the employee has YTD Severance Pay zero (E30)
      when pe.emplstatus =  'T' and pe.emplevent = 'InvTerm' and ytdsev.severance_pay <> 0 then 'TWS' --RWOS if the Employment Event is Retirement and the employee has YTD Severance Pay zero (E30)
      when pe.emplstatus =  'T' and pe.emplevent = 'Retire' and ytdsev.severance_pay IS NULL  then 'RWOS' --RWOS if the Employment Event is Retirement and the employee has YTD Severance Pay zero (E30)
      when pe.emplstatus <> 'R' and pe.emplevent = 'Term' and ytdsev.severance_pay <> 0 then 'TWS' --TWS if the Employment Event is not Retirement and the employee has YTD Severance Pay not = zero  
      when pe.emplstatus =  'T' then 'TWOS' --TWOS if the Employment Event is not Retirement and the employee has YTD Severance Pay zero
      end ::char(4) as f28_o27_cognos_status
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

,coalesce(dpc1.current_dedn_amount * -2,dpc.etv_amount * -2,0)  as f47_o22_dep_care_monthly_ded_amt
,coalesce(med1.current_dedn_amount * -2,med.etv_amount * -2,0)  as f48_o37_medical_monthly_ded_amt
,coalesce(dnt1.current_dedn_amount * -2,dnt.etv_amount * -2,0)  as f49_o38_dental_monthly_ded_amt
,coalesce(fsa1.current_dedn_amount * -2,fsa.etv_amount * -2,0)  as f50_o39_fsa_monthly_ded_amt
,coalesce(vsn1.current_dedn_amount * -2,vsn.etv_amount * -2,0)  as f51_o42_vision_monthly_ded_amt
,coalesce(hsa1.current_dedn_amount * -2,hsa.etv_amount * -2,0)  as f52_o43_hsa_monthly_ded_amt
,coalesce(hcu1.current_dedn_amount * -2,hcu.etv_amount * -2,0)  as f53_o44_hsa_cu_monthly_ded_amt            