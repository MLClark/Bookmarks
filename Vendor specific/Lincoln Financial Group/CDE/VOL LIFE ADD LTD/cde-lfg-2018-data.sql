select distinct 

 pi.personid
,'ACTIVE EE' ::varchar(30) as qsource 
,pi.identity ::char(9) as ssn 
,to_char(current_date,'YYYY-MM-DD')::char(10) as change_date
,null as dep_change_date
,case when pe.emplstatus = 'T' then to_char(pe.effectivedate,'YYYY-MM-DD') else ' ' end ::char(10) as term_date
,pn.fname ::varchar(30) as fname
,pn.lname ::varchar(50) as lname
,pn.mname ::char(1) as mname
,pi.identity ::char(9) as member_ssn 
,pv.gendercode ::char(1) as gender
,to_char(pv.birthdate,'YYYY-MM-DD')::char(10) as dob
,to_char(greatest(
 pbebeevlife.effectivedate
,pbegtl.effectivedate
,pbebDPvlife.effectivedate
,pbebSPvlife.effectivedate
,pbeacd.effectivedate
,pbeltd.effectivedate
,pbeltc.effectivedate),'YYYY-MM-DD')::char(10) as app_sign_date 
,pd.positiontitle ::varchar(50) as position_title
,case when pp.scheduledhours <= 80 and pp.scheduledhours > 40 then pp.scheduledhours / 2 
      when pp.scheduledhours > 80 then pp.scheduledhours / 4 
      else pp.scheduledhours end as hours_per_week
,lpad(coalesce(CASE when pc.frequencycode = 'A'::bpchar THEN cast(round(pc.compamount, 2)*100 as bigint)
                    when pc.frequencycode = 'H'::bpchar THEN cast(round(pc.compamount * pp.scheduledhours * fc1.annualfactor, 2)*100 as bigint)
                    ELSE 0::numeric END,0)::text,9,'0') AS annualsalary
,'A' ::char(1) as salary_code
,to_char(pc.effectivedate,'YYYY-MM-DD')::char(10) as salary_eff_date
,pa.streetaddress ::varchar(50) as addr1
,pa.streetaddress2::varchar(50) as addr2
,pa.city ::varchar(50) as city
,pa.stateprovincecode ::char(2) as state
,pa.postalcode ::char(5) as zip
,' '::char(4) as zip4
,ppch.phoneno ::char(14) as homephone
,ppcw.phoneno ::char(15) as workphone
,' ' ::char(1) as extension
,coalesce(pncw.url,pnch.url) ::varchar(100) AS email
,to_char(pe.emplhiredate,'YYYY-MM-DD')::char(10) as bene_elig_date
,to_char(pe.empllasthiredate,'YYYY-MM-DD')::char(10) as sub_date_of_elig
--,',,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,' ::char(90) as ac_thru_do
,null as c_ac
,null as c_ad
,null as c_ae
,null as c_af
,null as c_ag
,null as c_ah
,null as c_ai
,null as c_aj
,null as c_ak
,null as c_al
,null as c_am
,null as c_an
,null as c_ao
,null as c_ap
,null as c_aq
,null as c_ar
,null as c_as
,null as c_at
,null as c_au
,null as c_av
,null as c_aw
,null as c_ax
,null as c_ay
,null as c_az

,null as c_ba
,null as c_bb
,null as c_bc
,null as c_bd
,null as c_be
,null as c_bf
,null as c_bg
,null as c_bh
,null as c_bi
,null as c_bj
,null as c_bk
,null as c_bl
,null as c_bm
,null as c_bn
,null as c_bo
,null as c_bp
,null as c_bq
,null as c_br
,null as c_bs
,null as c_bt
,null as c_bu
,null as c_bv
,null as c_bw
,null as c_bx
,null as c_by
,null as c_bz

,null as c_ca
,null as c_cb
,null as c_cc
,null as c_cd
,null as c_ce
,null as c_cf
,null as c_cg
,null as c_ch
,null as c_ci
,null as c_cj
,null as c_ck
,null as c_cl
,null as c_cm
,null as c_cn
,null as c_co
,null as c_cp
,null as c_cq
,null as c_cr
,null as c_cs
,null as c_ct
,null as c_cu
,null as c_cv
,null as c_cw
,null as c_cx
,null as c_cy
,null as c_cz

,null as c_da
,null as c_db
,null as c_dc
,null as c_dd
,null as c_de
,null as c_df
,null as c_dg
,null as c_dh
,null as c_di
,null as c_dj
,null as c_dk
,null as c_dl
,null as c_dm
,null as c_dn





-- BASIC LIFE (21) DO - DX
,'000010006102-00000' ::char(19) as life_policy_nbr
,'269163' ::char(7) as life_bill_loc_ac_nbr
,' ' ::char(1) as life_sort_group
,to_char(pbelife.effectivedate,'YYYY-MM-DD')::char(10) as life_eff_date
,'1' ::char(1) as life_plan_code
,'1' ::char(1) as life_class_code
,'LI-1' ::char(4) as li_cvgs
,case when pe.emplstatus = 'T' then to_char(pbelife.effectivedate,'YYYY-MM-DD') else ' ' end ::char(10) as life_term_date
,'AD-1' ::char(4) as ad_cvgs
,case when pe.emplstatus = 'T' then to_char(pbeacd.effectivedate,'YYYY-MM-DD') else ' ' end ::char(10) as add_term_date
--,',,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,' ::char(34) as dy_thru_ff

,null as c_dy
,null as c_dz

,null as c_ea
,null as c_eb
,null as c_ec
,null as c_ed
,null as c_ee
,null as c_ef
,null as c_eg
,null as c_eh
,null as c_ei
,null as c_ej
,null as c_ek
,null as c_el
,null as c_em
,null as c_en
,null as c_eo
,null as c_ep
,null as c_eq
,null as c_er
,null as c_es
,null as c_et
,null as c_eu
,null as c_ev
,null as c_ew
,null as c_ex
,null as c_ey
,null as c_ez

,null as c_fa
,null as c_fb
,null as c_fc
,null as c_fd
,null as c_fe
,null as c_ff

-- LTD (30) FG - FN
,'000010006103-00000' ::char(19) as ltd_policy_nbr
,'269163' ::char(7) as ltd_bill_loc_ac_nbr
,' ' ::char(1) as ltd_sort_group
,to_char(pbeltd.effectivedate,'YYYY-MM-DD')::char(10) as ltd_eff_date
,'1' ::char(1) as ltd_plan_code
,case when pd.positiontitle = 'President' then '1' else '2' end ::char(1) as ltd_class_code
,'LTD-1' ::char(5) as ltd_cvgs
,case when pe.emplstatus = 'T' then to_char(pbeltd.effectivedate,'YYYY-MM-DD') else ' ' end ::char(10) as ltd_term_date

--,',,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,' ::char(57) as fo_thru_gt

,null as c_fo
,null as c_fp
,null as c_fq
,null as c_fr
,null as c_fs
,null as c_ft
,null as c_fu
,null as c_fv
,null as c_fw
,null as c_fx
,null as c_fy
,null as c_fz

,null as c_ga
,null as c_gb
,null as c_gc
,null as c_gd
,null as c_ge
,null as c_gf
,null as c_gg
,null as c_gh
,null as c_gi
,null as c_gj
,null as c_gk
,null as c_gl
,null as c_gm
,null as c_gn
,null as c_go
,null as c_gp
,null as c_gq
,null as c_gr
,null as c_gs
,null as c_gt
,null as c_gu
,null as c_gv
,null as c_gw
,null as c_gx
,null as c_gy
,null as c_gz

,null as c_ha
,null as c_hb
,null as c_hc
,null as c_hd
,null as c_he
,null as c_hf
,null as c_hg
,null as c_hh
,null as c_hi
,null as c_hj
,null as c_hk
,null as c_hl
,null as c_hm
,null as c_hn
,null as c_ho
,null as c_hp
,null as c_hq
,null as c_hr
,null as c_hs
,null as c_ht



-- VOL LIFE EE (21) HU - IB
,'00040FF01000-00009' ::char(19) as vlif_policy_nbr
,'269163' ::char(7) as vlif_bill_loc_ac_nbr
,' ' ::char(1) as vlif_sort_group
,to_char(pbebeevlife.effectivedate,'YYYY-MM-DD')::char(10) as vlif_eff_date
,'1' ::char(1) as vlif_plan_code
,'1' ::char(1) as vlif_class_code
,pbebeevlife.coverageamount as vlif_cvgs
,case when pe.emplstatus = 'T' then to_char(pbebeevlife.effectivedate,'YYYY-MM-DD') else ' ' end ::char(10) as vlif_term_date

,null as c_ic
,null as c_id

,pbebSPvlife.coverageamount as vslif_cvgs
,case when pe.emplstatus = 'T' then to_char(pbebSPvlife.effectivedate,'YYYY-MM-DD') else ' ' end ::char(10) as vslif_term_date

,null as c_ig
,null as c_ih

,pbebDPvlife.coverageamount as vclif_cvgs
,case when pe.emplstatus = 'T' then to_char(pbebDPvlife.effectivedate,'YYYY-MM-DD') else ' ' end ::char(10) as vclif_term_date
--,',,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,' ::char(49) as ik_thru_kg

,null as c_ik
,null as c_il
,null as c_im
,null as c_in
,null as c_io
,null as c_ip
,null as c_iq
,null as c_ir
,null as c_is
,null as c_it
,null as c_iu
,null as c_iv
,null as c_iw
,null as c_ix
,null as c_iy
,null as c_iz
,null as c_ja
,null as c_jb
,null as c_jc
,null as c_jd
,null as c_je
,null as c_jf
,null as c_jg
,null as c_jh
,null as c_ji
,null as c_jj
,null as c_jk
,null as c_jl
,null as c_jm
,null as c_jn
,null as c_jo
,null as c_jp
,null as c_jq
,null as c_jr
,null as c_js
,null as c_jt
,null as c_ju
,null as c_jv
,null as c_jw
,null as c_jx
,null as c_jy
,null as c_jz
,null as c_ka
,null as c_kb
,null as c_kc
,null as c_kd
,null as c_ke
,null as c_kf
,null as c_kg



from person_identity pi

left join edi.edi_last_update elu on elu.feedid = 'CDE_Lincoln_Financial_Group_VolLife_ADD_LTD_Export'

join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts

left join person_names pn
  on pn.personid = pe.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts
 
left join person_vitals pv
  on pv.personid = pe.personid
 and current_date between pv.effectivedate and pv.enddate
 and current_timestamp between pv.createts and pv.endts 
 
left join person_address pa
  on pa.personid = pe.personid
 and pa.addresstype = 'Res'
 and current_date between pa.effectivedate and pa.enddate
 and current_timestamp between pa.createts and pa.endts 

join person_bene_election pbe
  on pbe.personid = pe.personid
 and pbe.benefitsubclass in ('20','21','23','25','2Z','13','32','31')
 and pbe.selectedoption = 'Y'
 and pbe.benefitelection = 'E'
 and current_date between pbe.effectivedate and pbe.enddate
 and current_timestamp between pbe.createts and pbe.endts  

--- basic life
left join person_bene_election pbelife
  on pbelife.personid = pi.personid
 and pbelife.benefitsubclass in ('20')
 and pbelife.benefitelection in ('E')
 and pbelife.selectedoption = 'Y' 
 and current_date between pbelife.effectivedate and pbelife.enddate
 and current_timestamp between pbelife.createts and pbelife.endts    
 
--- vol life
left join person_bene_election pbebeevlife
  on pbebeevlife.personid = pbe.personid
 and pbebeevlife.benefitsubclass in ('21')
 and pbebeevlife.selectedoption = 'Y'
 and pbebeevlife.benefitelection = 'E'
 and current_date between pbebeevlife.effectivedate and pbebeevlife.enddate
 and current_timestamp between pbebeevlife.createts and pbebeevlife.endts    

--- group term life
left join person_bene_election pbegtl
  on pbegtl.personid = pbe.personid
 and pbegtl.benefitsubclass in ('23')
 and pbegtl.selectedoption = 'Y'
 and pbegtl.benefitelection = 'E'
 and current_date between pbegtl.effectivedate and pbegtl.enddate
 and current_timestamp between pbegtl.createts and pbegtl.endts    
 
--- dependent vol life
left join person_bene_election pbebDPvlife
  on pbebDPvlife.personid = pbe.personid
 and pbebDPvlife.benefitsubclass in ('25')
 and pbebDPvlife.selectedoption = 'Y'
 and pbebDPvlife.benefitelection = 'E'
 and current_date between pbebDPvlife.effectivedate and pbebDPvlife.enddate
 and current_timestamp between pbebDPvlife.createts and pbebDPvlife.endts     

--- spouse vol life
left join person_bene_election pbebSPvlife
  on pbebSPvlife.personid = pbe.personid
 and pbebSPvlife.benefitsubclass in ('2Z')
 and pbebSPvlife.selectedoption = 'Y'
 and pbebSPvlife.benefitelection = 'E'
 and current_date between pbebSPvlife.effectivedate and pbebSPvlife.enddate
 and current_timestamp between pbebSPvlife.createts and pbebSPvlife.endts   

--- accident
left join person_bene_election pbeacd
  on pbeacd.personid = pbe.personid
 and pbeacd.benefitsubclass in ('13')
 and pbeacd.selectedoption = 'Y'
 and pbeacd.benefitelection = 'E'
 and current_date between pbeacd.effectivedate and pbeacd.enddate
 and current_timestamp between pbeacd.createts and pbeacd.endts    

--- ltd
left join person_bene_election pbeltd
  on pbeltd.personid = pbe.personid
 and pbeltd.benefitsubclass in ('31')
 and pbeltd.selectedoption = 'Y'
 and pbeltd.benefitelection = 'E'
 and current_date between pbeltd.effectivedate and pbeltd.enddate
 and current_timestamp between pbeltd.createts and pbeltd.endts    
 
--- ltc
left join person_bene_election pbeltc
  on pbeltc.personid = pbe.personid
 and pbeltc.benefitsubclass in ('32')
 and pbeltc.selectedoption = 'Y'
 and pbeltc.benefitelection = 'E'
 and current_date between pbeltc.effectivedate and pbeltc.enddate
 and current_timestamp between pbeltc.createts and pbeltc.endts    

left join person_phone_contacts ppch 
  on ppch.personid = pi.personid
 and current_date between ppch.effectivedate and ppch.enddate
 and current_timestamp between ppch.createts and ppch.endts 
 and ppch.phonecontacttype = 'Home'
left join person_phone_contacts ppcw
  on ppcw.personid = pi.personid
 and current_date between ppcw.effectivedate and ppcw.enddate
 and current_timestamp between ppcw.createts and ppcw.endts  
 and ppcw.phonecontacttype = 'Work'   
left join person_phone_contacts ppcb
  on ppcb.personid = pi.personid
 and current_date between ppcb.effectivedate and ppcb.enddate
 and current_timestamp between ppcb.createts and ppcb.endts 
 and ppcb.phonecontacttype = 'BUSN'      
left join person_phone_contacts ppcm
  on ppcm.personid = pi.personid
 and current_date between ppcm.effectivedate and ppcm.enddate
 and current_timestamp between ppcm.createts and ppcm.endts 
 and ppcm.phonecontacttype = 'Mobile'  
left join person_net_contacts pncw 
  on pncw.personid = pi.personid 
 and pncw.netcontacttype = 'WRK'::bpchar 
 and current_date between pncw.effectivedate and pncw.enddate
 and current_timestamp between pncw.createts and pncw.enddate 
left join person_net_contacts pnch 
  on pnch.personid = pi.personid 
 and pnch.netcontacttype = 'HomeEmail'::bpchar 
 and current_date between pnch.effectivedate and pnch.enddate
 and current_timestamp between pnch.createts and pnch.enddate   




left join pers_pos pp 
  on pp.personid = pe.personid
 and current_date between pp.effectivedate and pp.enddate
 and current_timestamp between pp.createts and pp.endts 

left join position_desc pd
  on pd.positionid = pp.positionid
 and current_date between pd.effectivedate and pd.enddate
 and current_timestamp between pd.createts and pd.endts  

left join (SELECT personid, compamount, increaseamount, compevent, frequencycode, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate, 
                  RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             FROM person_compensation 
            WHERE current_date between effectivedate and enddate
              AND current_timestamp BETWEEN createts AND endts
            GROUP BY personid, compamount, increaseamount, compevent, frequencycode ) as pc on pc.personid = pe.personid and pc.rank = 1     
            
JOIN person_payroll ppr
  ON ppr.personid = pe.personid 
 AND current_date between ppr.effectivedate and ppr.enddate
 AND current_timestamp between ppr.createts AND ppr.endts
LEFT JOIN pay_unit pu
  ON pu.payunitid = ppr.payunitid
LEFT JOIN frequency_codes fc1
  ON fc1.frequencycode = pu.frequencycode 
  
left join position_job pj
  on pj.positionid = pp.positionid
 and current_date between pj.effectivedate and pj.enddate
 and current_timestamp between pj.createts and pj.endts
 and pj.effectivedate < pj.enddate
  
left join job_desc jd
  on jd.jobid = pj.jobid
 and current_date between jd.effectivedate and jd.enddate
 and current_timestamp between jd.createts and jd.endts 
 and jd.effectivedate < jd.enddate   
 
-- select * from federal_job_code; 
left join federal_job_code fjc
  on fjc.federaljobcodeid = jd.federaljobcodeid  

where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts 
  and pe.emplstatus = 'A'
  ;
  
  
  
  
  