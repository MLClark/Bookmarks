select distinct
 pi.personid 
,pdr.dependentid 
,'ACTIVE EE TERMED DEP'::varchar(30) as qsource
,'D' ::char(1) as transcode
,'5923955' ::char(7) as custnbr
,lpad(pi.identity,11,'0') ::char(11) as enbr
,' ' ::char(11) as filler_20_30
,pid.identity ::char(9) as member_ssn 
,pnd.lname ::char(20) as member_lname
,pnd.fname ::char(12) as member_fname
,pnd.mname ::char(1)  as member_mi
,to_char(pvd.birthdate, 'MMDDYYYY')::char(8) as member_dob
,case when pmsd.maritalstatus in ('M','R') then 'M' 
      when pmsd.maritalstatus in ('W','D','S') then 'S'else 'U' end ::char(1) as member_maritalstatus
,pvd.gendercode ::char(1) as member_gender
,case when pdr.dependentrelationship in ('SP','NA','DP') then '01'
      when pdr.dependentrelationship in ('D','C','S','NC','ND','NS') then '02' end ::char(2) as member_relcode
,' ' ::char(8) as emp_doh
,' ' ::char(11) as personnel_id
,' ' ::char(1) as emp_smoker
,case when pvd.smoker = 'Y' then 'S' else 'N' end ::char(1) as spouse_smoker
,' ' ::char(22) as filler_106_127
,' ' ::char(1) as survivor_ind  -- survivor needed for death
,' ' ::char(9) as suvivor_ssn
,' ' ::char(20) as survivor_lname
,' ' ::char(12) as survivor_fname
,'D' ::char(1) as foreign_addr_ind
,' ' ::char(32) as care_of_addr
,' ' ::char(32) as addr
,' ' ::char(21) as city
,' ' ::char(2) as state
,' ' ::char(9) as zip
,de.effectivedate as dentdate
--------------------------------------------------------------------------
---- start dental 11 columns 267 - 329 Based on Coverage Description -----
--------------------------------------------------------------------------
,case when pbednt.effectivedate - interval '14 days' <= current_date and pbednt.benefitsubclass = '11' then 'D ' else null end ::char(2) as d_covcode
,case when pbednt.effectivedate - interval '14 days' <= current_date and pbednt.benefitsubclass = '11' then to_char(de.effectivedate,'MMDDYYYY') else ' ' end ::char(8) as d_cov_start
,case when pbednt.effectivedate - interval '14 days' <= current_date and pbednt.benefitsubclass = '11' then to_char(de.enddate,'MMDDYYYY') else ' ' end ::char(8) as d_cov_end
,case when pbednt.effectivedate - interval '14 days' <= current_date and pbednt.benefitsubclass = '11' then '5923955' else ' ' end ::char(7) as d_grp_nbr
,case when pbednt.effectivedate - interval '14 days' <= current_date and pbednt.benefitsubclass = '11' then '0001' else ' ' end ::char(4) as d_sub_cd
,case when pbednt.effectivedate - interval '14 days' <= current_date and pbednt.benefitsubclass = '11' then '0001' else ' ' end ::char(4) as d_branch
,case when pbednt.effectivedate - interval '14 days' <= current_date and pbednt.benefitsubclass = '11' then pa.stateprovincecode else ' ' end ::char(2) as d_plan_cd
----- d_status Based on Employment Status 
----- R for Retirement
----- A for Active and all others
----- Note: terms will have an A, but will send Benefit End Date in Stop Date field (d_cov_end)
,case when pbednt.effectivedate - interval '14 days' <= current_date and pbednt.benefitsubclass = '11' and pe.emplstatus = 'R' then 'R' 
      when pbednt.effectivedate - interval '14 days' <= current_date and pbednt.benefitsubclass = '11' and pe.emplstatus <> 'R' then 'A' else ' ' end ::char(1) as d_status
,case when pbednt.effectivedate - interval '14 days' <= current_date and pbednt.benefitsubclass = '11' and bcddnt.benefitcoveragedesc = 'Employee Only' then '1'
      when pbednt.effectivedate - interval '14 days' <= current_date and pbednt.benefitsubclass = '11' and bcddnt.benefitcoveragedesc in ('EE & 1 Dep or More','Employee + Children') then '2' 
      when pbednt.effectivedate - interval '14 days' <= current_date and pbednt.benefitsubclass = '11' and bcddnt.benefitcoveragedesc = 'Employee + Spouse' then '3'
      when pbednt.effectivedate - interval '14 days' <= current_date and pbednt.benefitsubclass = '11' and bcddnt.benefitcoveragedesc in ('EE & Child(ren) + D/P Adult','EE&1+DPAdult &/or DPChild(ren)','EE&2+DPAdult &/or DPChild(ren)','EE&Child(ren) + DP Adult&DP Ch','Family') then '4'
      else ' ' end ::char(1) AS d_mbrs_covered
,' ' ::char(2) as d_cancel_rsn
,' ' ::char(1) as d_filler_306
,' ' ::char(8) as d_facility_id
,' ' ::char(15) as d_filler_315_329
----------------------------------------------------------
---- start life 20 columns 330 - 392 EMPLOYEE ONLY   -----
----------------------------------------------------------
,' ' ::char(2) as cp_covcode
,' ' ::char(8) as cp_cov_start
,' ' ::char(8) as cp_cov_end
,' ' ::char(7) as cp_grp_nbr
,' ' ::char(4) as cp_sub_cd
,' ' ::char(4) as cp_branch
,' ' ::char(2) as cp_filler_363_364
,' ' ::char(1) as cp_status
,' ' ::char(1) AS cp_mbrs_covered
,' ' ::char(10) as cp_filler_367_376
,' ' ::char(8) as cp_annual_benefit_amt
,' ' ::char(1) as cp_salary_mode
,' ' ::char(7) as cp_salary_amount
----------------------------------------------------------
---- start AD&D 21 columns 393 - 455 EMPLOYEE ONLY   -----
----------------------------------------------------------
,' ' ::char(2) as ad_covcode
,' ' ::char(8) as ad_cov_start
,' ' ::char(8) as ad_cov_end
,' ' ::char(7) as ad_grp_nbr
,' ' ::char(4) as ad_sub_cd
,' ' ::char(4) as ad_branch
,' ' ::char(2) as ad_filler_426_427
,' ' ::char(1) as ad_status
,' ' ::char(1) AS ad_mbrs_covered
,' ' ::char(10) as ad_filler_430_439
,' ' ::char(8) as ad_annual_benefit_amt
,' ' ::char(1) as ad_salary_mode
,' ' ::char(7) as ad_salary_amount
----------------------------------------------------------
---- start ltd 31 columns 456 - 518  EMPLOYEE ONLY   -----
----------------------------------------------------------
,' ' ::char(2) as lt_covcode
,' ' ::char(8) as lt_cov_start
,' ' ::char(8) as lt_cov_end
,' ' ::char(7) as lt_grp_nbr
,' ' ::char(4) as lt_sub_cd
,' ' ::char(4) as lt_branch
,' ' ::char(2) as lt_filler_489_490
,' ' ::char(1) as lt_status
,' ' ::char(1) AS lt_mbrs_covered
,' ' ::char(10) as lt_filler_493_502
,' ' ::char(8) as lt_annual_benefit_amt
,' ' ::char(1) as lt_salary_mode
,' ' ::char(7) as lt_salary_amount
----------------------------------------------------------
---- start STD 30 columns 519 - 581  EMPLOYEE ONLY   -----
----------------------------------------------------------
,' ' ::char(2) as as_covcode
,' ' ::char(8) as as_cov_start
,' ' ::char(8) as as_cov_end
,' ' ::char(7) as as_grp_nbr
,' ' ::char(4) as as_sub_cd
,' ' ::char(4) as as_branch
,' ' ::char(2) as as_filler_552_553
,' ' ::char(1) as as_status
,' ' ::char(1) AS as_mbrs_covered
,' ' ::char(10) as as_filler_556_565
,' ' ::char(8) as as_annual_benefit_amt
,' ' ::char(1) as as_salary_mode
,' ' ::char(7) as as_salary_amount
-------------------------------------------------------------------------   
---- start Dependent Basic Life 25 columns 582 - 644 DON'T POPULATE -----
-------------------------------------------------------------------------
,' ' ::char(2) as dl_covcode
,' ' ::char(8) as dl_cov_start
,' ' ::char(8) as dl_cov_end
,' ' ::char(7) as dl_grp_nbr
,' ' ::char(4) as dl_sub_cd
,' ' ::char(4) as dl_branch
,' ' ::char(2) as dl_filler_615_616
,' ' ::char(1) as dl_status
,' ' ::char(1) AS dl_mbrs_covered
,' ' ::char(10) as dl_filler_619_628
,' ' ::char(8) as dl_annual_benefit_amt
,' ' ::char(8) as dl_filler_637_644  
-----------------------------------------------------------------------------            
---- start Supplemental Basic Life 21 columns 645 - 707 EMPLOYEE ONLY   -----
-----------------------------------------------------------------------------
,' ' ::char(2) as op_covcode
,' ' ::char(8) as op_cov_start
,' ' ::char(8) as op_cov_end
,' ' ::char(7) as op_grp_nbr
,' ' ::char(4) as op_sub_cd
,' ' ::char(4) as op_branch
,' ' ::char(2) as op_filler_678_679
,' ' ::char(1) as op_status
,' ' ::char(1) AS op_mbrs_covered
,' ' ::char(10) as op_filler_682_691
,' ' ::char(8) as op_annual_benefit_amt
,' ' ::char(1) as op_salary_mode
,' ' ::char(7) as op_salary_amount      
--------------------------------------------------------------------------            
---- start Supplemental Spouse Life 2Z columns 708 - 770 SPOUSE ONLY -----
--------------------------------------------------------------------------      
,case when pbesups.effectivedate - interval '14 days' <= current_date and pbesups.benefitsubclass = '2Z' then 'LZ' else ' ' end ::char(2) as lz_covcode
,case when pbesups.effectivedate - interval '14 days' <= current_date and pbesups.benefitsubclass = '2Z' then to_char(de.effectivedate,'MMDDYYYY') else ' ' end ::char(8) as lz_cov_start
,case when pbesups.effectivedate - interval '14 days' <= current_date and pbesups.benefitsubclass = '2Z' then to_char(de.enddate,'MMDDYYYY') else ' ' end ::char(8) as lz_cov_end
,case when pbesups.effectivedate - interval '14 days' <= current_date and pbesups.benefitsubclass = '2Z' then '5923955' else ' ' end ::char(7) as lz_grp_nbr
,case when pbesups.effectivedate - interval '14 days' <= current_date and pbesups.benefitsubclass = '2Z' then '0001' else ' ' end ::char(4) as lz_sub_cd
,case when pbesups.effectivedate - interval '14 days' <= current_date and pbesups.benefitsubclass = '2Z' then '0001' else ' ' end ::char(4) as lz_branch
,' ' ::char(2) as lz_filler_741_742
----- lz_status Based on Employment Status 
----- R for Retirement
----- A for Active and all others
----- Note: terms will have an A, but will send Benefit End Date in Stop Date field (lz_cov_end)
,case when pbesups.effectivedate - interval '14 days' <= current_date and pbesups.benefitsubclass = '2Z' and pe.emplstatus = 'R' then 'R' 
      when pbesups.effectivedate - interval '14 days' <= current_date and pbesups.benefitsubclass = '2Z' and pe.emplstatus <> 'R' then 'A' else ' ' end ::char(1) as lz_status
,case when pbesups.effectivedate - interval '14 days' <= current_date and pbesups.benefitsubclass = '2Z' then 'A' else ' ' end ::char(1) AS lz_mbrs_covered
,' ' ::char(10) as lz_filler_745_754
,case when pbesups.effectivedate - interval '14 days' <= current_date and pbesups.benefitsubclass = '2Z' then to_char(pbesups.coverageamount, 'FM00000000') else ' ' end ::char(8) as lz_annual_benefit_amt
,' ' ::char(8) as lz_filler_763_770
------------------------------------------------------------------------------            
---- start Supplemental Child Life 25 columns 771 - 833  CHILD(REN) ONLY -----
------------------------------------------------------------------------------  
,case when pbesupc.effectivedate - interval '14 days' <= current_date and pbesupc.benefitsubclass = '25' then 'LF' else ' ' end ::char(2) as lf_covcode
,case when pbesupc.effectivedate - interval '14 days' <= current_date and pbesupc.benefitsubclass = '25' then to_char(de.effectivedate,'MMDDYYYY') else ' ' end ::char(8) as lf_cov_start
,case when pbesupc.effectivedate - interval '14 days' <= current_date and pbesupc.benefitsubclass = '25' then to_char(de.enddate,'MMDDYYYY') else ' ' end ::char(8) as lf_cov_end
,case when pbesupc.effectivedate - interval '14 days' <= current_date and pbesupc.benefitsubclass = '25' then '5923955' else ' ' end ::char(7) as lf_grp_nbr
,case when pbesupc.effectivedate - interval '14 days' <= current_date and pbesupc.benefitsubclass = '25' then '0001' else ' ' end ::char(4) as lf_sub_cd
,case when pbesupc.effectivedate - interval '14 days' <= current_date and pbesupc.benefitsubclass = '25' then '0001' else ' ' end ::char(4) as lf_branch
,' ' ::char(2) as lf_filler_804_805
----- lf_status Based on Employment Status 
----- R for Retirement
----- A for Active and all others
----- Note: terms will have an A, but will send Benefit End Date in Stop Date field (lf_cov_end)
,case when pbesupc.effectivedate - interval '14 days' <= current_date and pbesupc.benefitsubclass = '25' and pe.emplstatus = 'R' then 'R' 
      when pbesupc.effectivedate - interval '14 days' <= current_date and pbesupc.benefitsubclass = '25' and pe.emplstatus <> 'R' then 'A' else ' ' end ::char(1) as lf_status
,case when pbesupc.effectivedate - interval '14 days' <= current_date and pbesupc.benefitsubclass = '25' then 'C' else ' ' end ::char(1) AS lf_mbrs_covered 
,' ' ::char(10) as lf_filler_808_817
,case when pbesupc.effectivedate - interval '14 days' <= current_date and pbesupc.benefitsubclass = '25' then to_char(pbesupc.coverageamount, 'FM00000000') else ' ' end ::char(8) as lf_annual_benefit_amt
,' ' ::char(8) as lf_filler_826_833
---------------------------------------------------------------------------            
---- start Supplemental Basic AD&D 21 columns 834 - 896 EMPLOYEE ONLY -----
---------------------------------------------------------------------------  
,' ' ::char(2) as od_covcode
,' ' ::char(8) as od_cov_start
,' ' ::char(8) as od_cov_end
,' ' ::char(7) as od_grp_nbr
,' ' ::char(4) as od_sub_cd
,' ' ::char(4) as od_branch
,' ' ::char(2) as od_filler_867_868
,' ' ::char(1) as od_status
,' ' ::char(1) AS od_mbrs_covered
,' ' ::char(10) as od_filler_871_880
,' ' ::char(8) as od_annual_benefit_amt
,' ' ::char(1) as od_salary_mode
,' ' ::char(7) as od_salary_amount
--------------------------------------------------------------------------            
---- start Supplemental Spouse AD&D 2Z columns 897 - 959 SPOUSE ONLY -----
--------------------------------------------------------------------------  
,case when pbesups.effectivedate - interval '14 days' <= current_date and pbesups.benefitsubclass = '2Z' then 'AE' else ' ' end ::char(2) as ae_covcode
,case when pbesups.effectivedate - interval '14 days' <= current_date and pbesups.benefitsubclass = '2Z' then to_char(de.effectivedate,'MMDDYYYY') else ' ' end ::char(8) as ae_cov_start
,case when pbesups.effectivedate - interval '14 days' <= current_date and pbesups.benefitsubclass = '2Z' then to_char(de.enddate,'MMDDYYYY') else ' ' end ::char(8) as ae_cov_end
,case when pbesups.effectivedate - interval '14 days' <= current_date and pbesups.benefitsubclass = '2Z' then '5923955' else ' ' end ::char(7) as ae_grp_nbr
,case when pbesups.effectivedate - interval '14 days' <= current_date and pbesups.benefitsubclass = '2Z' then '0001' else ' ' end ::char(4) as ae_sub_cd
,case when pbesups.effectivedate - interval '14 days' <= current_date and pbesups.benefitsubclass = '2Z' then '0001' else ' ' end ::char(4) as ae_branch
,' ' ::char(2) as ae_filler_930_931
----- ae_status Based on Employment Status 
----- R for Retirement
----- A for Active and all others
----- Note: terms will have an A, but will send Benefit End Date in Stop Date field (ae_cov_end)
,case when pbesups.effectivedate - interval '14 days' <= current_date and pbesups.benefitsubclass = '2Z' and pe.emplstatus = 'R' then 'R' 
      when pbesups.effectivedate - interval '14 days' <= current_date and pbesups.benefitsubclass = '2Z' and pe.emplstatus <> 'R' then 'A' else ' ' end ::char(1) as ae_status
,case when pbesups.effectivedate - interval '14 days' <= current_date and pbesups.benefitsubclass = '2Z' then 'A' else ' ' end ::char(1) AS ae_mbrs_covered
,' ' ::char(10) as ae_filler_934_943
,case when pbesups.benefitsubclass = '2Z' then to_char(pbesups.coverageamount, 'FM00000000') else ' ' end ::char(8) as ae_annual_benefit_amt
,' ' ::char(8) as ae_filler_952_959
------------------------------------------------------------------------------            
---- start Supplemental Child AD&D 25 columns 960 - 1022 CHILD(REN) ONLY -----
------------------------------------------------------------------------------  
,case when pbesupc.effectivedate - interval '14 days' <= current_date and pbesupc.benefitsubclass = '25' then 'AT' else ' ' end ::char(2) as at_covcode
,case when pbesupc.effectivedate - interval '14 days' <= current_date and pbesupc.benefitsubclass = '25' then to_char(de.effectivedate,'MMDDYYYY') else ' ' end ::char(8) as at_cov_start
,case when pbesupc.effectivedate - interval '14 days' <= current_date and pbesupc.benefitsubclass = '25' then to_char(de.enddate,'MMDDYYYY') else ' ' end ::char(8) as at_cov_end
,case when pbesupc.effectivedate - interval '14 days' <= current_date and pbesupc.benefitsubclass = '25' then '5923955' else ' ' end ::char(7) as at_grp_nbr
,case when pbesupc.effectivedate - interval '14 days' <= current_date and pbesupc.benefitsubclass = '25' then '0001' else ' ' end ::char(4) as at_sub_cd
,case when pbesupc.effectivedate - interval '14 days' <= current_date and pbesupc.benefitsubclass = '25' then '0001' else ' ' end ::char(4) as at_branch
,' ' ::char(2) as at_filler_993_994
----- at_status Based on Employment Status 
----- R for Retirement
----- A for Active and all others
----- Note: terms will have an A, but will send Benefit End Date in Stop Date field (at_cov_end)
,case when pbesupc.effectivedate - interval '14 days' <= current_date and pbesupc.benefitsubclass = '25' and pe.emplstatus = 'R' then 'R' 
      when pbesupc.effectivedate - interval '14 days' <= current_date and pbesupc.benefitsubclass = '25' and pe.emplstatus <> 'R' then 'A' else ' ' end ::char(1) as at_status
,case when pbesupc.effectivedate - interval '14 days' <= current_date and pbesupc.benefitsubclass = '25' then 'C' else ' ' end ::char(1) AS at_mbrs_covered
,' ' ::char(10) as at_filler_997_1006
,case when pbesupc.effectivedate - interval '14 days' <= current_date and pbesupc.benefitsubclass = '25' then to_char(pbesupc.coverageamount, 'FM00000000') else ' ' end ::char(8) as at_annual_benefit_amt
,' ' ::char(8) as at_filler_1015_1022
------------------------------------------------------------------------            
---- start BuyUp Spouse Life ?? columns 1023 - 1085 DON'T POPULATE -----
------------------------------------------------------------------------  
,' ' ::char(2) as lu_covcode
,' ' ::char(8) as lu_cov_start
,' ' ::char(8) as lu_cov_end
,' ' ::char(7) as lu_grp_nbr
,' ' ::char(4) as lu_sub_cd
,' ' ::char(4) as lu_branch
,' ' ::char(2) as lu_filler_1056_1057
,' ' ::char(1) as lu_status
,' ' ::char(1) AS lu_mbrs_covered
,' ' ::char(10) as lu_filler_1060_1069
,' ' ::char(8) as lu_annual_benefit_amt
,' ' ::char(8) as lu_filler_1078_1085
-----------------------------------------------------------------------            
---- start BuyUp Child Life ?? columns 1086 - 1152 DON'T POPULATE -----
-----------------------------------------------------------------------  
,' ' ::char(2) as ly_covcode
,' ' ::char(8) as ly_cov_start
,' ' ::char(8) as ly_cov_end
,' ' ::char(7) as ly_grp_nbr
,' ' ::char(4) as ly_sub_cd
,' ' ::char(4) as ly_branch
,' ' ::char(2) as ly_filler_1119_1120
,' ' ::char(1) as ly_status
,' ' ::char(1) AS ly_mbrs_covered
,' ' ::char(10) as ly_filler_1123_1132
,' ' ::char(8) as ly_annual_benefit_amt
,' ' ::char(8) as ly_filler_1141_1152
------------------------------------------------------------------------            
---- start BuyUp Spouse AD&D ?? columns 1153 - 1215 DON'T POPULATE -----
------------------------------------------------------------------------  
,' ' ::char(2) as ac_covcode
,' ' ::char(8) as ac_cov_start
,' ' ::char(8) as ac_cov_end
,' ' ::char(7) as ac_grp_nbr
,' ' ::char(4) as ac_sub_cd
,' ' ::char(4) as ac_branch
,' ' ::char(2) as ac_filler_1186_1187
,' ' ::char(1) as ac_status
,' ' ::char(1) AS ac_mbrs_covered
,' ' ::char(10) as ac_filler_1190_1199
,' ' ::char(8) as ac_annual_benefit_amt
,' ' ::char(8) as ac_filler_1208_1215
-----------------------------------------------------------------------            
---- start BuyUp Child AD&D ?? columns 1216 - 1278 DON'T POPULATE -----
-----------------------------------------------------------------------  
,' ' ::char(2) as ay_covcode
,' ' ::char(8) as ay_cov_start
,' ' ::char(8) as ay_cov_end
,' ' ::char(7) as ay_grp_nbr
,' ' ::char(4) as ay_sub_cd
,' ' ::char(4) as ay_branch
,' ' ::char(2) as ay_filler_1249_1250
,' ' ::char(1) as ay_status
,' ' ::char(1) AS ay_mbrs_covered
,' ' ::char(10) as ay_filler_1253_1262
,' ' ::char(8) as ay_annual_benefit_amt
,' ' ::char(8) as ay_filler_1271_1278
----------------------------------------------------------------------------            
---- start Vision 14 columns 1279 - 1340 Based on Coverage Description -----
----------------------------------------------------------------------------  
,case when pbevsn.effectivedate - interval '14 days' <= current_date and pbevsn.benefitsubclass = '14' then 'VV' else ' ' end ::char(2) as vv_covcode
,case when pbevsn.effectivedate - interval '14 days' <= current_date and pbevsn.benefitsubclass = '14' then to_char(de.effectivedate,'MMDDYYYY') else ' ' end ::char(8) as vv_cov_start
,case when pbevsn.effectivedate - interval '14 days' <= current_date and pbevsn.benefitsubclass = '14' then to_char(de.enddate,'MMDDYYYY') else ' ' end ::char(8) as vv_cov_end
,case when pbevsn.effectivedate - interval '14 days' <= current_date and pbevsn.benefitsubclass = '14' then '5923955' else ' ' end ::char(7) as vv_grp_nbr
,case when pbevsn.effectivedate - interval '14 days' <= current_date and pbevsn.benefitsubclass = '14' then '0001' else ' ' end ::char(4) as vv_sub_cd
,case when pbevsn.effectivedate - interval '14 days' <= current_date and pbevsn.benefitsubclass = '14' then '0001' else ' ' end ::char(4) as vv_branch
,' ' ::char(2) as vv_filler_1312_1313
----- vv_status Based on Employment Status 
----- R for Retirement
----- A for Active and all others
----- Note: terms will have an A, but will send Benefit End Date in Stop Date field (vv_cov_end)
,case when pbevsn.effectivedate - interval '14 days' <= current_date and pbevsn.benefitsubclass = '14' and pe.emplstatus = 'R' then 'R' 
      when pbevsn.effectivedate - interval '14 days' <= current_date and pbevsn.benefitsubclass = '14' and pe.emplstatus <> 'R' then 'A' else ' ' end ::char(1) as vv_status
,case when pbevsn.effectivedate - interval '14 days' <= current_date and pbevsn.benefitsubclass = '14' and bcdvsn.benefitcoveragedesc = 'Employee Only' then '1'
      when pbevsn.effectivedate - interval '14 days' <= current_date and pbevsn.benefitsubclass = '14' and bcdvsn.benefitcoveragedesc in ('EE & 1 Dep or More','Employee + Children') then '2' 
      when pbevsn.effectivedate - interval '14 days' <= current_date and pbevsn.benefitsubclass = '14' and bcdvsn.benefitcoveragedesc = 'Employee + Spouse' then '3'
      when pbevsn.effectivedate - interval '14 days' <= current_date and pbevsn.benefitsubclass = '14' and bcdvsn.benefitcoveragedesc in ('EE & Child(ren) + D/P Adult','EE&1+DPAdult &/or DPChild(ren)','EE&2+DPAdult &/or DPChild(ren)','EE&Child(ren) + DP Adult&DP Ch','Family') then '4'
      else ' ' end ::char(1) AS vv_mbrs_covered
,' ' ::char(2) as vv_cancel_rsn
,' ' ::char(23) as vv_filler_1318_1340
            
from person_identity pi

left join edi.edi_last_update elu on elu.feedid = 'APM_Metlife_DentalVisionLife_Export'

left join person_employment pe 
  on pe.personid = pi.personid 
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts

left join person_address pa 
  on pa.personid = pi.personid
 and current_date between pa.effectivedate and pa.enddate
 and current_timestamp between pa.createts and pa.endts
 
join person_bene_election pbe
  on pbe.personid = pe.personid
 and pbe.benefitelection = 'E'
 and pbe.selectedoption = 'Y' 
 and pbe.enddate > current_date   
 and pbe.benefitsubclass in ('11','14','25','2Z') 
 and (current_date between pbe.effectivedate and pbe.enddate or (pbe.effectivedate > current_date and pbe.enddate > pbe.effectivedate)) and current_timestamp between pbe.createts and pbe.endts
--------------------------------------------------------------------------
---- start dental 11 columns 267 - 329 Based on Coverage Description -----
--------------------------------------------------------------------------
left join (select personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid, coverageamount, max(effectivedate) as effectivedate, max(enddate) as enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election where benefitsubclass = '11' and benefitelection = 'E' and selectedoption = 'Y' and (current_date between effectivedate and enddate or (effectivedate > current_date and enddate > effectivedate)) and current_timestamp between createts and endts 
            group by personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid, coverageamount) pbednt on pbednt.personid = pbe.personid and pbednt.rank = 1   

left join benefit_coverage_desc bcddnt
  on bcddnt.benefitcoverageid = pbednt.benefitcoverageid
 and current_date between bcddnt.effectivedate and bcddnt.enddate
 and current_timestamp between bcddnt.createts and bcddnt.endts  
------------------------------------------------------------------------------            
---- start Supplemental Child Life 25 columns 771 - 833  CHILD(REN) ONLY -----
------------------------------------------------------------------------------  
------------------------------------------------------------------------------            
---- start Supplemental Child AD&D 25 columns 960 - 1022 CHILD(REN) ONLY -----
------------------------------------------------------------------------------  
left join (select personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid, coverageamount, max(effectivedate) as effectivedate, max(enddate) as enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election where benefitsubclass = '25' and benefitelection = 'E' and selectedoption = 'Y' and (current_date between effectivedate and enddate or (effectivedate > current_date and enddate > effectivedate)) and current_timestamp between createts and endts 
            group by personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid, coverageamount) pbesupc on pbesupc.personid = pbe.personid and pbesupc.rank = 1   
--------------------------------------------------------------------------            
---- start Supplemental Spouse Life 2Z columns 708 - 770 SPOUSE ONLY -----
--------------------------------------------------------------------------  
--------------------------------------------------------------------------            
---- start Supplemental Spouse AD&D 2Z columns 897 - 959 SPOUSE ONLY -----
--------------------------------------------------------------------------  
left join (select personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid, coverageamount, max(effectivedate) as effectivedate, max(enddate) as enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election where benefitsubclass = '2Z' and benefitelection = 'E' and selectedoption = 'Y' and (current_date between effectivedate and enddate or (effectivedate > current_date and enddate > effectivedate)) and current_timestamp between createts and endts 
            group by personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid, coverageamount) pbesups on pbesups.personid = pbe.personid and pbesups.rank = 1   
----------------------------------------------------------------------------            
---- start Vision 14 columns 1279 - 1340 Based on Coverage Description -----
----------------------------------------------------------------------------  
left join (select personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid, coverageamount, max(effectivedate) as effectivedate, max(enddate) as enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election where benefitsubclass = '14' and benefitelection = 'E' and selectedoption = 'Y' and (current_date between effectivedate and enddate or (effectivedate > current_date and enddate > effectivedate)) and current_timestamp between createts and endts 
            group by personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid, coverageamount) pbevsn on pbevsn.personid = pbe.personid and pbevsn.rank = 1                       

----future dated          where (current_date between effectivedate and enddate or (effectivedate > current_date and enddate > effectivedate)) and current_timestamp between createts and endts    
left join benefit_coverage_desc bcdvsn
  on bcdvsn.benefitcoverageid = pbevsn.benefitcoverageid
 and current_date between bcdvsn.effectivedate and bcdvsn.enddate
 and current_timestamp between bcdvsn.createts and bcdvsn.endts 
 
 
----- dependent data

join person_dependent_relationship pdr
  on pdr.personid = pbe.personid
 and current_date between pdr.effectivedate and pdr.enddate
 and current_timestamp between pdr.createts and pdr.endts
 -- select * from dependent_enrollment where personid = '940' and benefitsubclass in ('11','14') ;
join dependent_enrollment de
  on de.dependentid = pdr.dependentid
 and de.benefitsubclass = pbe.benefitsubclass
 and de.personid = pbe.personid
 and current_timestamp between de.createts and de.endts
 and de.enddate >= elu.lastupdatets  
 --and (current_date between de.effectivedate and de.enddate or (de.effectivedate > current_date and de.enddate > de.effectivedate)) and current_timestamp between de.createts and de.endts    
 and de.dependentid in 
 ( select distinct de.dependentid as dependentid
    from dependent_enrollment de 
    join person_names pne
      on pne.personid = de.personid
     and pne.nametype = 'Legal'
     and current_date between pne.effectivedate and pne.enddate
     and current_timestamp between pne.createts and pne.endts
    join person_names pnd
      on pnd.personid = de.dependentid
     and pnd.nametype = 'Dep'
     and current_date between pnd.effectivedate and pnd.enddate
     and current_timestamp between pnd.createts and pnd.endts    
    join person_vitals pvd
      on pvd.personid = de.dependentid
     and current_date between pvd.effectivedate and pvd.enddate
     and current_timestamp between pvd.createts and pvd.endts 
    join person_dependent_relationship pdr
      on pdr.personid = de.personid
     and pdr.dependentid = de.dependentid
     and current_date between pdr.effectivedate and pdr.enddate
     and current_timestamp between pdr.createts and pdr.endts
    join person_employment pe
      on pe.personid = de.personid
     and current_date between pe.effectivedate and pe.enddate
     and current_timestamp between pe.createts and pe.endts
    join person_bene_election pbe
      on pbe.personid = de.personid
     and pbe.benefitsubclass in ('11','14','25','2Z') 
     and pbe.selectedoption = 'Y'
     and current_date between pbe.effectivedate and pbe.enddate
     and current_timestamp between pbe.createts and pbe.endts     
   where current_timestamp between de.createts and de.endts
    and de.benefitsubclass in ('11','14','25','2Z') 
    --and pdr.dependentrelationship in ('S','D','C','NC','NS','ND')
    and pe.emplstatus = 'A'
    and pbe.benefitelection = 'E'
    and date_part('year',de.enddate)=date_part('year',current_date)
   -- and pe.personid = '9707'
    and de.dependentid not in 
   (select distinct de.dependentid from dependent_enrollment de
      join person_dependent_relationship pdr
        on pdr.personid = de.personid
       and pdr.dependentid = de.dependentid
       and current_date between pdr.effectivedate and pdr.enddate
       and current_timestamp between pdr.createts and pdr.endts
     where current_date between de.effectivedate and de.enddate
       and current_timestamp between de.createts and de.endts
       and de.benefitsubclass in ('11','14','25','2Z')  -- and de.dependentid = '1964'
       --and pdr.dependentrelationship in ('S','D','C','NC','NS','ND')
   )
)     
left join person_identity piD
  on piD.personid = pdr.dependentid
 and piD.identitytype = 'SSN'
 and current_timestamp between piD.createts and piD.endts 
 
left join person_names pnd
  on pnD.personid = pdr.dependentid
 and current_date between pnD.effectivedate and pnD.enddate
 and current_timestamp between pnd.createts and pnD.endts
 and pnD.nametype = 'Dep'
 
left join person_vitals pvD
  on pvD.personid = piD.personid
 and current_date between pvD.effectivedate and pvD.enddate
 and current_timestamp between pvD.createts and pvD.endts  

left join person_maritalstatus pmsd
  on pmsd.personid = pdr.dependentid
 and current_date between pmsd.effectivedate and pmsd.enddate
 and current_timestamp between pmsd.createts and pmsd.endts
 
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  and pe.emplstatus NOT IN ('T','R')
  
  -- select * from person_names where personid = '940';
  --- select current_date - interval '26 years';
  --- select * from edi.edi_last_update;