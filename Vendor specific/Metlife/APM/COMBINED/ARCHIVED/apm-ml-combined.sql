select distinct
-- Metlife Dental (11) Life (20) Vision (14)
 pi.personid 
,'0' AS dependentid
,'emp demo data'::varchar(30) as qsource
,'E' ::char(1) as transcode
,'5923955' ::char(7) as custnbr 
,lpad(pi.identity,11,'0') ::char(11) as enbr
,' ' ::char(11) as filler_20_30
,pi.identity ::char(9) as member_ssn 
,pn.lname ::char(20) as member_lname
,pn.fname ::char(12) as member_fname
,pn.mname ::char(1)  as member_mi
,to_char(pv.birthdate, 'MMDDYYYY')::char(8) as member_dob
,case when pmse.maritalstatus in ('M','R') then 'M' 
      when pmse.maritalstatus in ('W','D','S') then 'S'else 'U' end ::char(1) as member_maritalstatus
,pv.gendercode ::char(1) as member_gender
,'00' ::char(2) as member_relcode
,to_char(pe.empllasthiredate,'MMDDYYYY') ::char(8) as emp_doh
,' ' ::char(11) as personnel_id
,case when pv.smoker = 'Y' then 'S' else 'N' end ::char(1) as emp_smoker
,' ' ::char(1) spouse_smoker
,' ' ::char(22) as filler_106_127
,' ' ::char(1) as survivor_ind  -- survivor needed for death
,' ' ::char(9) as suvivor_ssn
,' ' ::char(20) as survivor_lname
,' ' ::char(12) as survivor_fname
,'D' ::char(1) as foreign_addr_ind
,' ' ::char(32) as care_of_addr
,pa.streetaddress ::char(32) as addr
,pa.city ::char(21) as city
,pa.stateprovincecode ::char(2) as state
,replace(pa.postalcode,'-','') ::char(9) as zip
----------------------------------------------------------    
---- start dental 11 columns 267 - 329
----------------------------------------------------------
,case when pbednt.benefitsubclass = '11' then 'D ' else null end ::char(2) as d_covcode
--,'D '::char(2) as d_covcode
,case when pbednt.benefitsubclass = '11' then to_char(pbednt.effectivedate,'MMDDYYYY') else ' ' end ::char(8) as d_cov_start
,case when pbednt.benefitsubclass = '11' and pbednt.benefitelection = 'T' then to_char(pbednt.effectivedate,'MMDDYYYY') 
      when pbednt.benefitsubclass = '11' and pe.emplstatus = 'T' then to_char(pe.effectivedate,'MMDDYYYY') else ' ' end ::char(8) as d_cov_end
,case when pbednt.benefitsubclass = '11' then '5923955' else ' ' end ::char(7) as d_grp_nbr
,case when pbednt.benefitsubclass = '11' then '0001' else ' ' end ::char(4) as d_sub_cd
,case when pbednt.benefitsubclass = '11' then '0001' else ' ' end ::char(4) as d_branch
,case when pbednt.benefitsubclass = '11' then pa.stateprovincecode else ' ' end ::char(2) as d_plan_cd
,case when pbednt.benefitsubclass = '11' then pe.emplstatus else ' ' end ::char(1) as d_status
,case when pbednt.benefitsubclass = '11' and bcddnt.benefitcoveragedesc = 'Employee Only' then '1'
      when pbednt.benefitsubclass = '11' and bcddnt.benefitcoveragedesc in ('EE & 1 Dep or More','Employee + Children') then '2' 
      when pbednt.benefitsubclass = '11' and bcddnt.benefitcoveragedesc = 'Employee + Spouse' then '3'
      when pbednt.benefitsubclass = '11' and bcddnt.benefitcoveragedesc in ('EE & Child(ren) + D/P Adult','EE&1+DPAdult &/or DPChild(ren)','EE&2+DPAdult &/or DPChild(ren)','EE&Child(ren) + DP Adult&DP Ch','Family') then '4'
      else ' ' end ::char(1) AS d_mbrs_covered
,' ' ::char(2) as d_cancel_rsn
,' ' ::char(1) as d_filler_306
,' ' ::char(8) as d_facility_id
,' ' ::char(15) as d_filler_315_329
----------------------------------------------------------
---- start life 20 columns 330 - 392
----------------------------------------------------------
,case when pbeblife.benefitsubclass = '20' then 'CP' else ' ' end ::char(2) as cp_covcode
--,'CP' ::char(2) as cp_covcode
,case when pbeblife.benefitsubclass = '20' then to_char(pbeblife.effectivedate,'MMDDYYYY') else ' ' end ::char(8) as cp_cov_start
,case when pbeblife.benefitsubclass = '20' and pbeblife.benefitelection = 'T' then to_char(pbeblife.enddate,'MMDDYYYY') 
      when pbeblife.benefitsubclass = '20' and pe.emplstatus = 'T' then to_char(pe.effectivedate,'MMDDYYYY') else ' ' end ::char(8) as cp_cov_end
,case when pbeblife.benefitsubclass = '20' then '5923955' else ' ' end ::char(7) as cp_grp_nbr
,case when pbeblife.benefitsubclass = '20' then '0001' else ' ' end ::char(4) as cp_sub_cd
,case when pbeblife.benefitsubclass = '20' then '0001' else ' ' end ::char(4) as cp_branch
,' ' ::char(2) as cp_filler_363_364
,case when pbeblife.benefitsubclass = '20' then pe.emplstatus else ' ' end ::char(1) as cp_status
,case when pbeblife.benefitsubclass = '20' then '1' else ' ' end ::char(1) AS cp_mbrs_covered
,' ' ::char(10) as cp_filler_367_376
,case when pbeblife.benefitsubclass = '20' then to_char(pbeblife.coverageamount, 'FM00000000') else ' ' end ::char(8) as cp_annual_benefit_amt
,case when pbeblife.benefitsubclass = '20' and pc.frequencycode = 'H' then 'H'
      when pbeblife.benefitsubclass = '20' and pc.frequencycode = 'A' then 'A' else ' ' end ::char(1) as cp_salary_mode
,case when pbeblife.benefitsubclass = '20' and pc.frequencycode = 'H' then to_char(pc.compamount * 100,'FM0000000') 
      when pbeblife.benefitsubclass = '20' then to_char(pc.compamount,'FM0000000') else ' ' end ::char(7) as cp_salary_amount
----------------------------------------------------------
---- start AD&D 21 columns 393 - 455
----------------------------------------------------------
,case when pbeadd.benefitsubclass = '21' then 'AD' else ' ' end ::char(2) as ad_covcode
--,'AD' ::char(2) as ad_covcode
,case when pbeadd.benefitsubclass = '21' then to_char(pbeadd.effectivedate,'MMDDYYYY') else ' ' end ::char(8) as ad_cov_start
,case when pbeadd.benefitsubclass = '21' and pbeadd.benefitelection = 'T' then to_char(pbeadd.enddate,'MMDDYYYY') 
      when pbeadd.benefitsubclass = '21' and pe.emplstatus = 'T' then to_char(pe.effectivedate,'MMDDYYYY') else ' ' end ::char(8) as ad_cov_end
,case when pbeadd.benefitsubclass = '21' then '5923955' else ' ' end ::char(7) as ad_grp_nbr
,case when pbeadd.benefitsubclass = '21' then '0001' else ' ' end ::char(4) as ad_sub_cd
,case when pbeadd.benefitsubclass = '21' then '0001' else ' ' end ::char(4) as ad_branch
,' ' ::char(2) as ad_filler_426_427
,case when pbeadd.benefitsubclass = '21' then pe.emplstatus else ' ' end ::char(1) as ad_status
,case when pbeadd.benefitsubclass = '21' then '1' else ' ' end ::char(1) AS ad_mbrs_covered
,' ' ::char(10) as ad_filler_430_439
,case when pbeadd.benefitsubclass = '21' then to_char(pbeadd.coverageamount, 'FM00000000') else ' ' end ::char(8) as ad_annual_benefit_amt
,case when pbeadd.benefitsubclass = '21' and pc.frequencycode = 'H' then 'H'
      when pbeadd.benefitsubclass = '21' and pc.frequencycode = 'A' then 'A' else ' ' end ::char(1) as ad_salary_mode      
,case when pbeadd.benefitsubclass = '21' and pc.frequencycode = 'H' then to_char(pc.compamount * 100,'FM0000000') 
      when pbeadd.benefitsubclass = '21' then to_char(pc.compamount,'FM0000000')  else ' ' end ::char(7) as ad_salary_amount           
----------------------------------------------------------
---- start ltd 31 columns 456 - 518
----------------------------------------------------------
,case when pbeltd.benefitsubclass = '31' then 'LT' else ' ' end ::char(2) as lt_covcode
--,'LT' ::char(2) as lt_covcode
,case when pbeltd.benefitsubclass = '31' then to_char(pbeltd.effectivedate,'MMDDYYYY') else ' ' end ::char(8) as lt_cov_start
,case when pbeltd.benefitsubclass = '31' and pbeltd.benefitelection = 'T' then to_char(pbeltd.enddate,'MMDDYYYY') 
      when pbeltd.benefitsubclass = '31' and pe.emplstatus = 'T' then to_char(pe.effectivedate,'MMDDYYYY') else ' ' end ::char(8) as lt_cov_end
,case when pbeltd.benefitsubclass = '31' then '5923955' else ' ' end ::char(7) as lt_grp_nbr
,case when pbeltd.benefitsubclass = '31' then '0001' else ' ' end ::char(4) as lt_sub_cd
,case when pbeltd.benefitsubclass = '31' then '0001' else ' ' end ::char(4) as lt_branch
,' ' ::char(2) as lt_filler_489_490
,case when pbeltd.benefitsubclass = '31' then pe.emplstatus else ' ' end ::char(1) as lt_status
,case when pbeltd.benefitsubclass = '31' then '1' else ' ' end ::char(1) AS lt_mbrs_covered
,' ' ::char(10) as lt_filler_493_502
,case when pbeltd.benefitsubclass = '31' then to_char(pbeltd.coverageamount, 'FM00000000') else ' ' end ::char(8) as lt_annual_benefit_amt
,case when pbeltd.benefitsubclass = '31' and pc.frequencycode = 'H' then 'H' 
      when pbeltd.benefitsubclass = '31' and pc.frequencycode = 'A' then 'A' else ' ' end ::char(1) as lt_salary_mode
,case when pbeltd.benefitsubclass = '31' and pc.frequencycode = 'H' then to_char(pc.compamount * 100,'FM0000000') 
      when pbeltd.benefitsubclass = '31' then to_char(pc.compamount,'FM0000000') else ' ' end ::char(7) as lt_salary_amount
----------------------------------------------------------
---- start STD 30 columns 519 - 581
----------------------------------------------------------
,case when pbestd.benefitsubclass = '30' then 'AS' else ' ' end ::char(2) as as_covcode
--,'AS' ::char(2) as as_covcode
,case when pbestd.benefitsubclass = '30' then to_char(pbestd.effectivedate,'MMDDYYYY') else ' ' end ::char(8) as as_cov_start
,case when pbestd.benefitsubclass = '30' and pbestd.benefitelection = 'T' then to_char(pbestd.enddate,'MMDDYYYY') 
      when pbestd.benefitsubclass = '30' and pe.emplstatus = 'T' then to_char(pe.effectivedate,'MMDDYYYY') else ' ' end ::char(8) as as_cov_end
,case when pbestd.benefitsubclass = '30' then '5923955' else ' ' end ::char(7) as as_grp_nbr
,case when pbestd.benefitsubclass = '30' then '0001' else ' ' end ::char(4) as as_sub_cd
,case when pbestd.benefitsubclass = '30' then '0001' else ' ' end ::char(4) as as_branch
,' ' ::char(2) as as_filler_552_553
,case when pbestd.benefitsubclass = '30' then pe.emplstatus else ' ' end ::char(1) as as_status
,case when pbestd.benefitsubclass = '30' then '1' else ' ' end ::char(1) AS as_mbrs_covered
,' ' ::char(10) as as_filler_556_565
,case when pbestd.benefitsubclass = '30' then to_char(pbestd.coverageamount, 'FM00000000') else ' ' end ::char(8) as as_annual_benefit_amt
,case when pbestd.benefitsubclass = '30' and pc.frequencycode = 'H' then 'H' 
      when pbestd.benefitsubclass = '30' and pc.frequencycode = 'A' then 'A' else ' ' end ::char(1) as as_salary_mode
,case when pbestd.benefitsubclass = '30' and pc.frequencycode = 'H' then to_char(pc.compamount * 100,'FM0000000') 
      when pbestd.benefitsubclass = '30' then to_char(pc.compamount,'FM0000000') else ' ' end ::char(7) as as_salary_amount     
----------------------------------------------------------     
---- start Dependent Basic Life 25 columns 582 - 644
----------------------------------------------------------
,case when pbedblife.benefitsubclass = '??' then 'DL' else ' ' end ::char(2) as dl_covcode
--,'DL' ::char(2) as dl_covcode
,case when pbedblife.benefitsubclass = '??' then to_char(pbedblife.effectivedate,'MMDDYYYY') else ' ' end ::char(8) as dl_cov_start
,case when pbedblife.benefitsubclass = '??' and pbedblife.benefitelection = 'T' then to_char(pbedblife.enddate,'MMDDYYYY') 
      when pbedblife.benefitsubclass = '??' and pe.emplstatus = 'T' then to_char(pe.effectivedate,'MMDDYYYY') else ' ' end ::char(8) as dl_cov_end
,case when pbedblife.benefitsubclass = '??' then '5923955' else ' ' end ::char(7) as dl_grp_nbr
,case when pbedblife.benefitsubclass = '??' then '0001' else ' ' end ::char(4) as dl_sub_cd
,case when pbedblife.benefitsubclass = '??' then '0001' else ' ' end ::char(4) as dl_branch
,' ' ::char(2) as dl_filler_615_616
,case when pbedblife.benefitsubclass = '??' then pe.emplstatus else ' ' end ::char(1) as dl_status
,case when pbedblife.benefitsubclass = '??' and bcd25.benefitcoveragedesc = 'Employee Only' then '1'
      when pbedblife.benefitsubclass = '??' and bcd25.benefitcoveragedesc in ('EE & 1 Dep or More','Employee + Children') then '2' 
      when pbedblife.benefitsubclass = '??' and bcd25.benefitcoveragedesc = 'Employee + Spouse' then '3'
      when pbedblife.benefitsubclass = '??' and bcd25.benefitcoveragedesc in ('EE & Child(ren) + D/P Adult','EE&1+DPAdult &/or DPChild(ren)','EE&2+DPAdult &/or DPChild(ren)','EE&Child(ren) + DP Adult&DP Ch','Family') then '4'
      else ' ' end ::char(1) AS dl_mbrs_covered     
,' ' ::char(10) as dl_filler_619_628
,case when pbedblife.benefitsubclass = '??' then to_char(pbedblife.coverageamount, 'FM00000000') else ' ' end ::char(8) as dl_annual_benefit_amt
,' ' ::char(8) as dl_filler_637_644           
----------------------------------------------------------            
---- start Supplemental Basic Life 21 columns 645 - 707
----------------------------------------------------------
,case when pbeesuplife.benefitsubclass = '21' then 'OP' else ' ' end ::char(2) as op_covcode
--,'OP' ::char(2) as op_covcode
,case when pbeesuplife.benefitsubclass = '21' then to_char(pbeesuplife.effectivedate,'MMDDYYYY') else ' ' end ::char(8) as op_cov_start
,case when pbeesuplife.benefitsubclass = '21' and pbeesuplife.benefitelection = 'T' then to_char(pbeesuplife.enddate,'MMDDYYYY') 
      when pbeesuplife.benefitsubclass = '21' and pe.emplstatus = 'T' then to_char(pe.effectivedate,'MMDDYYYY') else ' ' end ::char(8) as op_cov_end
,case when pbeesuplife.benefitsubclass = '21' then '5923955' else ' ' end ::char(7) as op_grp_nbr
,case when pbeesuplife.benefitsubclass = '21' then '0001' else ' ' end ::char(4) as op_sub_cd
,case when pbeesuplife.benefitsubclass = '21' then '0001' else ' ' end ::char(4) as op_branch
,' ' ::char(2) as op_filler_678_679
,case when pbeesuplife.benefitsubclass = '21' then pe.emplstatus else ' ' end ::char(1) as op_status
,case when pbeesuplife.benefitsubclass = '21' then '1' else ' ' end ::char(1) AS op_mbrs_covered
,' ' ::char(10) as op_filler_682_691
,case when pbeesuplife.benefitsubclass = '21' then to_char(pbeesuplife.coverageamount, 'FM00000000') else ' ' end ::char(8) as op_annual_benefit_amt
,case when pbeesuplife.benefitsubclass = '21' and pc.frequencycode = 'H' then 'H' 
      when pbeesuplife.benefitsubclass = '21' and pc.frequencycode = 'A' then 'A' else ' ' end ::char(1) as op_salary_mode
,case when pbeesuplife.benefitsubclass = '21' and pc.frequencycode = 'H' then to_char(pc.compamount * 100,'FM0000000') 
      when pbeesuplife.benefitsubclass = '21' then to_char(pc.compamount,'FM0000000') else ' ' end ::char(7) as op_salary_amount
----------------------------------------------------------            
---- start Supplemental Spouse Life 2Z columns 708 - 770
----------------------------------------------------------      
,case when pbesupslife.benefitsubclass = '2Z' then 'LZ' else ' ' end ::char(2) as lz_covcode
--,'LZ' ::char(2) as lz_covcode
,case when pbesupslife.benefitsubclass = '2Z' then to_char(pbesupslife.effectivedate,'MMDDYYYY') else ' ' end ::char(8) as lz_cov_start
,case when pbesupslife.benefitsubclass = '2Z' and pbesupslife.benefitelection = 'T' then to_char(pbesupslife.enddate,'MMDDYYYY') 
      when pbesupslife.benefitsubclass = '2Z' and pe.emplstatus = 'T' then to_char(pe.effectivedate,'MMDDYYYY') else ' ' end ::char(8) as lz_cov_end
,case when pbesupslife.benefitsubclass = '2Z' then '5923955' else ' ' end ::char(7) as lz_grp_nbr
,case when pbesupslife.benefitsubclass = '2Z' then '0001' else ' ' end ::char(4) as lz_sub_cd
,case when pbesupslife.benefitsubclass = '2Z' then '0001' else ' ' end ::char(4) as lz_branch
,' ' ::char(2) as lz_filler_741_742
,case when pbesupslife.benefitsubclass = '2Z' then pe.emplstatus else ' ' end ::char(1) as lz_status
,case when pbesupslife.benefitsubclass = '2Z' and bcd2z.benefitcoveragedesc = 'Employee Only' then '1'
      when pbesupslife.benefitsubclass = '2Z' and bcd2z.benefitcoveragedesc in ('EE & 1 Dep or More','Employee + Children') then '2' 
      when pbesupslife.benefitsubclass = '2Z' and bcd2z.benefitcoveragedesc = 'Employee + Spouse' then '3'
      when pbesupslife.benefitsubclass = '2Z' and bcd2z.benefitcoveragedesc in ('EE & Child(ren) + D/P Adult','EE&1+DPAdult &/or DPChild(ren)','EE&2+DPAdult &/or DPChild(ren)','EE&Child(ren) + DP Adult&DP Ch','Family') then '4'
      else ' ' end ::char(1) AS lz_mbrs_covered
,' ' ::char(10) as lz_filler_745_754
,case when pbesupslife.benefitsubclass = '2Z' then to_char(pbesupslife.coverageamount, 'FM00000000') else ' ' end ::char(8) as lz_annual_benefit_amt
,' ' ::char(8) as lz_filler_763_770
----------------------------------------------------------            
---- start Supplemental Child Life 25 columns 771 - 833
----------------------------------------------------------  
,case when pbesupclife.benefitsubclass = '25' then 'LF' else ' ' end ::char(2) as lf_covcode
--,'LF' ::char(2) as lf_covcode
,case when pbesupclife.benefitsubclass = '25' then to_char(pbesupclife.effectivedate,'MMDDYYYY') else ' ' end ::char(8) as lf_cov_start
,case when pbesupclife.benefitsubclass = '25' and pbesupclife.benefitelection = 'T' then to_char(pbesupclife.enddate,'MMDDYYYY') 
      when pbesupclife.benefitsubclass = '25' and pe.emplstatus = 'T' then to_char(pe.effectivedate,'MMDDYYYY') else ' ' end ::char(8) as lf_cov_end
,case when pbesupclife.benefitsubclass = '25' then '5923955' else ' ' end ::char(7) as lf_grp_nbr
,case when pbesupclife.benefitsubclass = '25' then '0001' else ' ' end ::char(4) as lf_sub_cd
,case when pbesupclife.benefitsubclass = '25' then '0001' else ' ' end ::char(4) as lf_branch
,' ' ::char(2) as lf_filler_804_805
,case when pbesupclife.benefitsubclass = '25' then pe.emplstatus else ' ' end ::char(1) as lf_status
,case when pbesupclife.benefitsubclass = '25' and bcd25.benefitcoveragedesc = 'Employee Only' then '1'
      when pbesupclife.benefitsubclass = '25' and bcd25.benefitcoveragedesc in ('EE & 1 Dep or More','Employee + Children') then '2' 
      when pbesupclife.benefitsubclass = '25' and bcd25.benefitcoveragedesc = 'Employee + Spouse' then '3'
      when pbesupclife.benefitsubclass = '25' and bcd25.benefitcoveragedesc in ('EE & Child(ren) + D/P Adult','EE&1+DPAdult &/or DPChild(ren)','EE&2+DPAdult &/or DPChild(ren)','EE&Child(ren) + DP Adult&DP Ch','Family') then '4'
      else ' ' end ::char(1) AS lf_mbrs_covered 
,' ' ::char(10) as lf_filler_808_817
,case when pbesupclife.benefitsubclass = '25' then to_char(pbesupclife.coverageamount, 'FM00000000') else ' ' end ::char(8) as lf_annual_benefit_amt
,' ' ::char(8) as lf_filler_826_833
----------------------------------------------------------            
---- start Supplemental Basic AD&D 21 columns 834 - 896
----------------------------------------------------------  
,case when pbesbadd.benefitsubclass = '21' then 'OD' else ' ' end ::char(2) as od_covcode
--,'OD' ::char(2) as od_covcode
,case when pbesbadd.benefitsubclass = '21' then to_char(pbesbadd.effectivedate,'MMDDYYYY') else ' ' end ::char(8) as od_cov_start
,case when pbesbadd.benefitsubclass = '21' and pbesbadd.benefitelection = 'T' then to_char(pbesbadd.enddate,'MMDDYYYY') 
      when pbesbadd.benefitsubclass = '21' and pe.emplstatus = 'T' then to_char(pe.effectivedate,'MMDDYYYY') else ' ' end ::char(8) as od_cov_end
,case when pbesbadd.benefitsubclass = '21' then '5923955' else ' ' end ::char(7) as od_grp_nbr
,case when pbesbadd.benefitsubclass = '21' then '0001' else ' ' end ::char(4) as od_sub_cd
,case when pbesbadd.benefitsubclass = '21' then '0001' else ' ' end ::char(4) as od_branch
,' ' ::char(2) as od_filler_867_868
,case when pbesbadd.benefitsubclass = '21' then pe.emplstatus else ' ' end ::char(1) as od_status
,case when pbesbadd.benefitsubclass = '21' then '1' else ' ' end ::char(1) AS od_mbrs_covered
,' ' ::char(10) as od_filler_871_880
,case when pbesbadd.benefitsubclass = '21' then to_char(pbesbadd.coverageamount, 'FM00000000') else ' ' end ::char(8) as od_annual_benefit_amt
,case when pbesbadd.benefitsubclass = '21' and pc.frequencycode = 'H' then 'H' 
      when pbesbadd.benefitsubclass = '21' and pc.frequencycode = 'A' then 'A' else ' ' end ::char(1) as od_salary_mode
,case when pbesbadd.benefitsubclass = '21' and pc.frequencycode = 'H' then to_char(pc.compamount * 100,'FM0000000') 
      when pbesbadd.benefitsubclass = '21' then to_char(pc.compamount,'FM0000000') else ' ' end ::char(7) as od_salary_amount        
----------------------------------------------------------            
---- start Supplemental Spouse AD&D 2Z columns 897 - 959
----------------------------------------------------------  
,case when pbessadd.benefitsubclass = '2Z' then 'AE' else ' ' end ::char(2) as ae_covcode
--,'AE' ::char(2) as ae_covcode
,case when pbessadd.benefitsubclass = '2Z' then to_char(pbessadd.effectivedate,'MMDDYYYY') else ' ' end ::char(8) as ae_cov_start
,case when pbessadd.benefitsubclass = '2Z' and pbessadd.benefitelection = 'T' then to_char(pbessadd.enddate,'MMDDYYYY') 
      when pbessadd.benefitsubclass = '2Z' and pe.emplstatus = 'T' then to_char(pe.effectivedate,'MMDDYYYY') else ' ' end ::char(8) as ae_cov_end
,case when pbessadd.benefitsubclass = '2Z' then '5923955' else ' ' end ::char(7) as ae_grp_nbr
,case when pbessadd.benefitsubclass = '2Z' then '0001' else ' ' end ::char(4) as ae_sub_cd
,case when pbessadd.benefitsubclass = '2Z' then '0001' else ' ' end ::char(4) as ae_branch
,' ' ::char(2) as ae_filler_930_931
,case when pbessadd.benefitsubclass = '2Z' then pe.emplstatus else ' ' end ::char(1) as ae_status
,case when pbessadd.benefitsubclass = '2Z' and bcd2z.benefitcoveragedesc = 'Employee Only' then '1'
      when pbessadd.benefitsubclass = '2Z' and bcd2z.benefitcoveragedesc in ('EE & 1 Dep or More','Employee + Children') then '2' 
      when pbessadd.benefitsubclass = '2Z' and bcd2z.benefitcoveragedesc = 'Employee + Spouse' then '3'
      when pbessadd.benefitsubclass = '2Z' and bcd2z.benefitcoveragedesc in ('EE & Child(ren) + D/P Adult','EE&1+DPAdult &/or DPChild(ren)','EE&2+DPAdult &/or DPChild(ren)','EE&Child(ren) + DP Adult&DP Ch','Family') then '4'
      else ' ' end ::char(1) AS ae_mbrs_covered
,' ' ::char(10) as ae_filler_934_943
,case when pbessadd.benefitsubclass = '2Z' then to_char(pbessadd.coverageamount, 'FM00000000') else ' ' end ::char(8) as ae_annual_benefit_amt
,' ' ::char(8) as ae_filler_952_959
----------------------------------------------------------            
---- start Supplemental Child AD&D 25 columns 960 - 1022
----------------------------------------------------------  
,case when pbescadd.benefitsubclass = '25' then 'AT' else ' ' end ::char(2) as at_covcode
--,'AT' ::char(2) as at_covcode
,case when pbescadd.benefitsubclass = '25' then to_char(pbescadd.effectivedate,'MMDDYYYY') else ' ' end ::char(8) as at_cov_start
,case when pbescadd.benefitsubclass = '25' and pbescadd.benefitelection = 'T' then to_char(pbescadd.enddate,'MMDDYYYY') 
      when pbescadd.benefitsubclass = '25' and pe.emplstatus = 'T' then to_char(pe.effectivedate,'MMDDYYYY') else ' ' end ::char(8) as at_cov_end
,case when pbescadd.benefitsubclass = '25' then '5923955' else ' ' end ::char(7) as at_grp_nbr
,case when pbescadd.benefitsubclass = '25' then '0001' else ' ' end ::char(4) as at_sub_cd
,case when pbescadd.benefitsubclass = '25' then '0001' else ' ' end ::char(4) as at_branch
,' ' ::char(2) as at_filler_993_994
,case when pbescadd.benefitsubclass = '25' then pe.emplstatus else ' ' end ::char(1) as at_status
,case when pbescadd.benefitsubclass = '25' and bcd25.benefitcoveragedesc = 'Employee Only' then '1'
      when pbescadd.benefitsubclass = '25' and bcd25.benefitcoveragedesc in ('EE & 1 Dep or More','Employee + Children') then '2' 
      when pbescadd.benefitsubclass = '25' and bcd25.benefitcoveragedesc = 'Employee + Spouse' then '3'
      when pbescadd.benefitsubclass = '25' and bcd25.benefitcoveragedesc in ('EE & Child(ren) + D/P Adult','EE&1+DPAdult &/or DPChild(ren)','EE&2+DPAdult &/or DPChild(ren)','EE&Child(ren) + DP Adult&DP Ch','Family') then '4'
      else ' ' end ::char(1) AS at_mbrs_covered
,' ' ::char(10) as at_filler_997_1006
,case when pbescadd.benefitsubclass = '25' then to_char(pbescadd.coverageamount, 'FM00000000') else ' ' end ::char(8) as at_annual_benefit_amt
,' ' ::char(8) as at_filler_1015_1022
----------------------------------------------------------            
---- start BuyUp Spouse Life ?? columns 1023 - 1085
----------------------------------------------------------  
,case when pbebuslife.benefitsubclass = '??' then 'LU' else ' ' end ::char(2) as lu_covcode
--,'LU' ::char(2) as lu_covcode
,case when pbebuslife.benefitsubclass = '??' then to_char(pbebuslife.effectivedate,'MMDDYYYY') else ' ' end ::char(8) as lu_cov_start
,case when pbebuslife.benefitsubclass = '??' and pbebuslife.benefitelection = 'T' then to_char(pbebuslife.enddate,'MMDDYYYY') 
      when pbebuslife.benefitsubclass = '??' and pe.emplstatus = 'T' then to_char(pe.effectivedate,'MMDDYYYY') else ' ' end ::char(8) as lu_cov_end
,case when pbebuslife.benefitsubclass = '??' then '5923955' else ' ' end ::char(7) as lu_grp_nbr
,case when pbebuslife.benefitsubclass = '??' then '0001' else ' ' end ::char(4) as lu_sub_cd
,case when pbebuslife.benefitsubclass = '??' then '0001' else ' ' end ::char(4) as lu_branch
,' ' ::char(2) as lu_filler_1056_1057
,case when pbebuslife.benefitsubclass = '??' then pe.emplstatus else ' ' end ::char(1) as lu_status
,case when pbebuslife.benefitsubclass = '??' and bcd2z.benefitcoveragedesc = 'Employee Only' then '1'
      when pbebuslife.benefitsubclass = '??' and bcd2z.benefitcoveragedesc in ('EE & 1 Dep or More','Employee + Children') then '2' 
      when pbebuslife.benefitsubclass = '??' and bcd2z.benefitcoveragedesc = 'Employee + Spouse' then '3'
      when pbebuslife.benefitsubclass = '??' and bcd2z.benefitcoveragedesc in ('EE & Child(ren) + D/P Adult','EE&1+DPAdult &/or DPChild(ren)','EE&2+DPAdult &/or DPChild(ren)','EE&Child(ren) + DP Adult&DP Ch','Family') then '4'
      else ' ' end ::char(1) AS lu_mbrs_covered
,' ' ::char(10) as lu_filler_1060_1069
,case when pbebuslife.benefitsubclass = '??' then to_char(pbebuslife.coverageamount, 'FM00000000') else ' ' end ::char(8) as lu_annual_benefit_amt
,' ' ::char(8) as lu_filler_1078_1085 
----------------------------------------------------------            
---- start BuyUp Child Life ?? columns 1086 - 1152
----------------------------------------------------------  
,case when pbebuclife.benefitsubclass = '??' then 'LY' else ' ' end ::char(2) as ly_covcode
--,'LY' ::char(2) as ly_covcode
,case when pbebuclife.benefitsubclass = '??' then to_char(pbebuclife.effectivedate,'MMDDYYYY') else ' ' end ::char(8) as ly_cov_start
,case when pbebuclife.benefitsubclass = '??' and pbebuclife.benefitelection = 'T' then to_char(pbebuclife.enddate,'MMDDYYYY') 
      when pbebuclife.benefitsubclass = '??' and pe.emplstatus = 'T' then to_char(pe.effectivedate,'MMDDYYYY') else ' ' end ::char(8) as ly_cov_end
,case when pbebuclife.benefitsubclass = '??' then '5923955' else ' ' end ::char(7) as ly_grp_nbr
,case when pbebuclife.benefitsubclass = '??' then '0001' else ' ' end ::char(4) as ly_sub_cd
,case when pbebuclife.benefitsubclass = '??' then '0001' else ' ' end ::char(4) as ly_branch
,' ' ::char(2) as ly_filler_1119_1120
,case when pbebuclife.benefitsubclass = '??' then pe.emplstatus else ' ' end ::char(1) as ly_status
,case when pbebuclife.benefitsubclass = '??' then '?' else ' ' end ::char(1) AS ly_mbrs_covered
,' ' ::char(10) as ly_filler_1123_1132
,case when pbebuclife.benefitsubclass = '??' then to_char(pbebuclife.coverageamount, 'FM00000000') else ' ' end ::char(8) as ly_annual_benefit_amt
,' ' ::char(8) as ly_filler_1141_1152
----------------------------------------------------------            
---- start BuyUp Spouse AD&D ?? columns 1153 - 1215
----------------------------------------------------------  
,case when pbebusadd.benefitsubclass = '??' then 'AC' else ' ' end ::char(2) as ac_covcode
--,'AC' ::char(2) as ac_covcode
,case when pbebusadd.benefitsubclass = '??' then to_char(pbebusadd.effectivedate,'MMDDYYYY') else ' ' end ::char(8) as ac_cov_start
,case when pbebusadd.benefitsubclass = '??' and pbebusadd.benefitelection = 'T' then to_char(pbebusadd.enddate,'MMDDYYYY') 
      when pbebusadd.benefitsubclass = '??' and pe.emplstatus = 'T' then to_char(pe.effectivedate,'MMDDYYYY') else ' ' end ::char(8) as ac_cov_end
,case when pbebusadd.benefitsubclass = '??' then '5923955' else ' ' end ::char(7) as ac_grp_nbr
,case when pbebusadd.benefitsubclass = '??' then '0001' else ' ' end ::char(4) as ac_sub_cd
,case when pbebusadd.benefitsubclass = '??' then '0001' else ' ' end ::char(4) as ac_branch
,' ' ::char(2) as ac_filler_1186_1187
,case when pbebusadd.benefitsubclass = '??' then pe.emplstatus else ' ' end ::char(1) as ac_status
,case when pbebusadd.benefitsubclass = '??' then '?' else ' ' end ::char(1) AS ac_mbrs_covered
,' ' ::char(10) as ac_filler_1190_1199
,case when pbebusadd.benefitsubclass = '??' then to_char(pbebusadd.coverageamount, 'FM00000000') else ' ' end ::char(8) as ac_annual_benefit_amt
,' ' ::char(8) as ac_filler_1208_1215
----------------------------------------------------------            
---- start BuyUp Child AD&D ?? columns 1216 - 1278
----------------------------------------------------------  
,case when pbebusadd.benefitsubclass = '??' then 'AY' else ' ' end ::char(2) as ay_covcode
--,'AY' ::char(2) as ay_covcode
,case when pbebusadd.benefitsubclass = '??' then to_char(pbebusadd.effectivedate,'MMDDYYYY') else ' ' end ::char(8) as ay_cov_start
,case when pbebusadd.benefitsubclass = '??' and pbebusadd.benefitelection = 'T' then to_char(pbebusadd.enddate,'MMDDYYYY') 
      when pbebusadd.benefitsubclass = '??' and pe.emplstatus = 'T' then to_char(pe.effectivedate,'MMDDYYYY') else ' ' end ::char(8) as ay_cov_end
,case when pbebusadd.benefitsubclass = '??' then '5923955' else ' ' end ::char(7) as ay_grp_nbr
,case when pbebusadd.benefitsubclass = '??' then '0001' else ' ' end ::char(4) as ay_sub_cd
,case when pbebusadd.benefitsubclass = '??' then '0001' else ' ' end ::char(4) as ay_branch
,' ' ::char(2) as ay_filler_1249_1250
,case when pbebusadd.benefitsubclass = '??' then pe.emplstatus else ' ' end ::char(1) as ay_status
,case when pbebusadd.benefitsubclass = '??' then '?' else ' ' end ::char(1) AS ay_mbrs_covered
,' ' ::char(10) as ay_filler_1253_1262
,case when pbebusadd.benefitsubclass = '??' then to_char(pbebusadd.coverageamount, 'FM00000000') else ' ' end ::char(8) as ay_annual_benefit_amt
,' ' ::char(8) as ay_filler_1271_1278
----------------------------------------------------------            
---- start Vision 14 columns 1279 - 1340
----------------------------------------------------------  
,case when pbevsn.benefitsubclass = '14' then 'VV' else ' ' end ::char(2) as vv_covcode
--,'VV' ::char(2) as vv_covcode
,case when pbevsn.benefitsubclass = '14' then to_char(pbevsn.effectivedate,'MMDDYYYY') else ' ' end ::char(8) as vv_cov_start
,case when pbevsn.benefitsubclass = '14' and pbevsn.benefitelection = 'T' then to_char(pbevsn.effectivedate,'MMDDYYYY') 
      when pbevsn.benefitsubclass = '14' and pe.emplstatus = 'T' then to_char(pe.effectivedate,'MMDDYYYY') else ' ' end ::char(8) as vv_cov_end
,case when pbevsn.benefitsubclass = '14' then '5923955' else ' ' end ::char(7) as vv_grp_nbr
,case when pbevsn.benefitsubclass = '14' then '0001' else ' ' end ::char(4) as vv_sub_cd
,case when pbevsn.benefitsubclass = '14' then '0001' else ' ' end ::char(4) as vv_branch
,' ' ::char(2) as vv_filler_1312_1313
,case when pbevsn.benefitsubclass = '14' then pe.emplstatus else ' ' end ::char(1) as vv_status
,case when pbevsn.benefitsubclass = '14' and bcdvsn.benefitcoveragedesc = 'Employee Only' then '1'
      when pbevsn.benefitsubclass = '14' and bcdvsn.benefitcoveragedesc in ('EE & 1 Dep or More','Employee + Children') then '2' 
      when pbevsn.benefitsubclass = '14' and bcdvsn.benefitcoveragedesc = 'Employee + Spouse' then '3'
      when pbevsn.benefitsubclass = '14' and bcdvsn.benefitcoveragedesc in ('EE & Child(ren) + D/P Adult','EE&1+DPAdult &/or DPChild(ren)','EE&2+DPAdult &/or DPChild(ren)','EE&Child(ren) + DP Adult&DP Ch','Family') then '4'
      else ' ' end ::char(1) AS vv_mbrs_covered
,' ' ::char(2) as vv_cancel_rsn
,' ' ::char(23) as vv_filler_1318_1340

from person_identity pi

left join edi.edi_last_update elu on elu.feedid = 'APM_Metlife_DentalVisionLife_Export'

LEFT JOIN person_employment pe 
  ON pe.personid = pi.personid 
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts

left join person_identity pie
  on pie.personid = pi.personid
 and pie.identitytype = 'EmpNo'
 and current_timestamp between pie.createts and pie.endts

join person_bene_election pbe
  on pbe.personid = pe.personid
 and pbe.benefitelection = 'E'
 and pbe.selectedoption = 'Y' 
 and pbe.enddate > current_date   
 and pbe.benefitsubclass in ('20','21','11','30','31','14','25','2Z') 
 and current_date between pbe.effectivedate and pbe.enddate
 and current_timestamp between pbe.createts and pbe.endts
----------------------------------------------------------    
---- start dental 11 columns 267 - 329
----------------------------------------------------------
left join person_bene_election pbednt
  on pbednt.personid = pbe.personid
 and pbednt.benefitsubclass in ('11')
 and pbednt.benefitelection = 'E'
 and pbednt.selectedoption = 'Y' 
 and pbednt.enddate > current_date
 and current_date between pbednt.effectivedate and pbednt.enddate
 and current_timestamp between pbednt.createts and pbednt.endts

left JOIN benefit_coverage_desc bcddnt
  ON bcddnt.benefitcoverageid = pbednt.benefitcoverageid
 AND current_date between bcddnt.effectivedate and bcddnt.enddate
 and current_timestamp between bcddnt.createts and bcddnt.endts  
----------------------------------------------------------
---- start life 20 columns 330 - 392
----------------------------------------------------------
left join person_bene_election pbeblife
  on pbeblife.personid = pbe.personid
 and pbeblife.benefitsubclass in ('20')
 and pbeblife.benefitelection = 'E'
 and pbeblife.selectedoption = 'Y' 
 and pbeblife.enddate > current_date
 and current_date between pbeblife.effectivedate and pbeblife.enddate
 and current_timestamp between pbeblife.createts and pbeblife.endts
 
left JOIN benefit_coverage_desc bcdblife
  ON bcdblife.benefitcoverageid = pbeblife.benefitcoverageid
 AND current_date between bcdblife.effectivedate and bcdblife.enddate
 and current_timestamp between bcdblife.createts and bcdblife.endts   
----------------------------------------------------------
---- start AD&D 21 columns 393 - 455
----------------------------------------------------------
left join person_bene_election pbeadd
  on pbeadd.personid = pbe.personid
 and pbeadd.benefitsubclass in ('21')
 and pbeadd.benefitelection = 'E'
 and pbeadd.selectedoption = 'Y' 
 and pbeadd.enddate > current_date
 and current_date between pbeadd.effectivedate and pbeadd.enddate
 and current_timestamp between pbeadd.createts and pbeadd.endts
----------------------------------------------------------
---- start ltd 31 columns 456 - 518
----------------------------------------------------------
left join person_bene_election pbeltd
  on pbeltd.personid = pbe.personid
 and pbeltd.benefitsubclass in ('31')
 and pbeltd.benefitelection = 'E'
 and pbeltd.selectedoption = 'Y' 
 and pbeltd.enddate > current_date
 and current_date between pbeltd.effectivedate and pbeltd.enddate
 and current_timestamp between pbeltd.createts and pbeltd.endts
----------------------------------------------------------
---- start STD 30 columns 519 - 581
----------------------------------------------------------
left join person_bene_election pbestd
  on pbestd.personid = pbe.personid
 and pbestd.benefitsubclass in ('30')
 and pbestd.benefitelection = 'E'
 and pbestd.selectedoption = 'Y' 
 and pbestd.enddate > current_date
 and current_date between pbestd.effectivedate and pbestd.enddate
 and current_timestamp between pbestd.createts and pbestd.endts 
----------------------------------------------------------     
---- start Dependent Basic Life 25 columns 582 - 644
---------------------------------------------------------- 
left join person_bene_election pbedblife
  on pbedblife.personid = pbe.personid
 and pbedblife.benefitsubclass in ('25') 
 and pbedblife.benefitelection = 'E'
 and pbedblife.selectedoption = 'Y' 
 and pbedblife.enddate > current_date
 and current_date between pbedblife.effectivedate and pbedblife.enddate
 and current_timestamp between pbedblife.createts and pbedblife.endts 

left JOIN benefit_coverage_desc bcd25
  ON bcd25.benefitcoverageid = pbedblife.benefitcoverageid
 AND current_date between bcd25.effectivedate and bcd25.enddate
 and current_timestamp between bcd25.createts and bcd25.endts   
----------------------------------------------------------            
---- start Supplemental Basic Life 21 columns 645 - 707
----------------------------------------------------------
left join person_bene_election pbeesuplife
  on pbeesuplife.personid = pbe.personid
 and pbeesuplife.benefitsubclass in ('21') 
 and pbeesuplife.benefitelection = 'E'
 and pbeesuplife.selectedoption = 'Y' 
 and pbeesuplife.enddate > current_date
 and current_date between pbeesuplife.effectivedate and pbeesuplife.enddate
 and current_timestamp between pbeesuplife.createts and pbeesuplife.endts 
----------------------------------------------------------            
---- start Supplemental Spouse Life 2Z columns 708 - 770
---------------------------------------------------------- 
left join person_bene_election pbesupslife
  on pbesupslife.personid = pbe.personid
 and pbesupslife.benefitsubclass in ('2Z') 
 and pbesupslife.benefitelection = 'E'
 and pbesupslife.selectedoption = 'Y'  
 and pbesupslife.enddate > current_date
 and current_date between pbesupslife.effectivedate and pbesupslife.enddate
 and current_timestamp between pbesupslife.createts and pbesupslife.endts

left JOIN benefit_coverage_desc bcd2z
  ON bcd2z.benefitcoverageid = pbesupslife.benefitcoverageid
 AND current_date between bcd2z.effectivedate and bcd2z.enddate
 and current_timestamp between bcd2z.createts and bcd2z.endts    
----------------------------------------------------------            
---- start Supplemental Child Life 25 columns 771 - 833
---------------------------------------------------------- 
left join person_bene_election pbesupclife
  on pbesupclife.personid = pbe.personid
 and pbesupclife.benefitsubclass in ('25') 
 and pbesupclife.benefitelection = 'E'
 and pbesupclife.selectedoption = 'Y'  
 and pbesupclife.enddate > current_date
 and current_date between pbesupclife.effectivedate and pbesupclife.enddate
 and current_timestamp between pbesupclife.createts and pbesupclife.endts
----------------------------------------------------------            
---- start Supplemental Basic AD&D 21 columns 834 - 896
----------------------------------------------------------  
left join person_bene_election pbesbadd
  on pbesbadd.personid = pbe.personid
 and pbesbadd.benefitsubclass in ('21')
 and pbesbadd.benefitelection = 'E'
 and pbesbadd.selectedoption = 'Y'
 and pbesbadd.enddate > current_date 
 and current_date between pbesbadd.effectivedate and pbesbadd.enddate
 and current_timestamp between pbesbadd.createts and pbesbadd.endts 
----------------------------------------------------------            
---- start Supplemental Spouse AD&D 2Z columns 897 - 959
----------------------------------------------------------  
left join person_bene_election pbessadd
  on pbessadd.personid = pbe.personid
 and pbessadd.benefitsubclass in ('2Z') 
 and pbessadd.benefitelection = 'E'
 and pbessadd.selectedoption = 'Y'  
 and pbessadd.enddate > current_date
 and current_date between pbessadd.effectivedate and pbessadd.enddate
 and current_timestamp between pbessadd.createts and pbessadd.endts
----------------------------------------------------------            
---- start Supplemental Child AD&D 25 columns 960 - 1022
----------------------------------------------------------  
left join person_bene_election pbescadd
  on pbescadd.personid = pbe.personid
 and pbescadd.benefitsubclass in ('25') 
 and pbescadd.benefitelection = 'E'
 and pbescadd.selectedoption = 'Y'  
 and pbescadd.enddate > current_date
 and current_date between pbescadd.effectivedate and pbescadd.enddate
 and current_timestamp between pbescadd.createts and pbescadd.endts
----------------------------------------------------------            
---- start BuyUp Spouse Life ?? columns 1023 - 1085
----------------------------------------------------------
left join person_bene_election pbebuslife
  on pbebuslife.personid = pbe.personid
 and pbebuslife.benefitsubclass in ('??') 
 and pbebuslife.benefitelection = 'E'
 and pbebuslife.selectedoption = 'Y' 
 and pbebuslife.enddate > current_date
 and current_date between pbebuslife.effectivedate and pbebuslife.enddate
 and current_timestamp between pbebuslife.createts and pbebuslife.endts
----------------------------------------------------------            
---- start BuyUp Child Life ?? columns 1086 - 1152
----------------------------------------------------------  
left join person_bene_election pbebuclife
  on pbebuclife.personid = pbe.personid
 and pbebuclife.benefitsubclass in ('??') 
 and pbebuclife.benefitelection = 'E'
 and pbebuclife.selectedoption = 'Y' 
 and pbebuclife.enddate > current_date
 and current_date between pbebuclife.effectivedate and pbebuclife.enddate
 and current_timestamp between pbebuclife.createts and pbebuclife.endts
----------------------------------------------------------            
---- start BuyUp Spouse AD&D ?? columns 1153 - 1215
----------------------------------------------------------  
left join person_bene_election pbebusadd
  on pbebusadd.personid = pbe.personid
 and pbebusadd.benefitsubclass in ('??') 
 and pbebusadd.benefitelection = 'E'
 and pbebusadd.selectedoption = 'Y' 
 and current_date between pbebusadd.effectivedate and pbebusadd.enddate
 and current_timestamp between pbebusadd.createts and pbebusadd.endts
----------------------------------------------------------            
---- start BuyUp Child AD&D ?? columns 1216 - 1278
---------------------------------------------------------- 
left join person_bene_election pbebucadd
  on pbebucadd.personid = pbe.personid
 and pbebucadd.benefitsubclass in ('??') 
 and pbebucadd.benefitelection = 'E'
 and pbebucadd.selectedoption = 'Y' 
 and current_date between pbebucadd.effectivedate and pbebucadd.enddate
 and current_timestamp between pbebucadd.createts and pbebucadd.endts 
----------------------------------------------------------            
---- start Vision 14 columns 1279 - 1340
----------------------------------------------------------
left join person_bene_election pbevsn
  on pbevsn.personid = pbe.personid
 and pbevsn.benefitsubclass in ('14')
 and pbevsn.benefitelection = 'E'
 and pbevsn.selectedoption = 'Y' 
 and pbevsn.enddate > current_date
 and current_date between pbevsn.effectivedate and pbevsn.enddate
 and current_timestamp between pbevsn.createts and pbevsn.endts 
  
left JOIN benefit_coverage_desc bcdvsn
  ON bcdvsn.benefitcoverageid = pbevsn.benefitcoverageid
 AND current_date between bcdvsn.effectivedate and bcdvsn.enddate
 and current_timestamp between bcdvsn.createts and bcdvsn.endts 

left join person_names pn
  on pn.personid = pi.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts

left join person_vitals pv
  on pv.personid = pi.personid
 and current_date between pv.effectivedate and pv.enddate
 and current_timestamp between pv.createts and pv.endts

left join person_maritalstatus pmse
  on pmse.personid = pi.personid
 and current_date between pmse.effectivedate and pmse.enddate
 and current_timestamp between pmse.createts and pmse.endts
 
left join person_address pa 
  on pa.personid = pi.personid
 and current_date between pa.effectivedate and pa.enddate
 and current_timestamp between pa.createts and pa.endts

left join person_compensation pc
  on pc.personid = pi.personid
 and current_date between pc.effectivedate and pc.enddate
 and current_timestamp between pc.createts and pc.endts 
 
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  and pe.emplstatus = 'A'
  
  
  UNION
  
select distinct
 pi.personid 
,pdr.dependentid 
,'dep demo data'::varchar(30) as qsource
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

----------------------------------------------------------
---- start dental 11 columns 267 - 329
----------------------------------------------------------
,' ' ::char(2) as d_covcode
,' ' ::char(8) as d_cov_start
,' ' ::char(8) as d_cov_end
,' ' ::char(7) as d_grp_nbr
,' ' ::char(4) as d_sub_cd
,' ' ::char(4) as d_branch
,' ' ::char(2) as d_plan_cd
,' ' ::char(1) as d_status
,' ' ::char(1) AS d_mbrs_covered
,' ' ::char(2) as d_cancel_rsn
,' ' ::char(1) as d_filler_306
,' ' ::char(8) as d_facility_id
,' ' ::char(15) as d_filler_315_329
----------------------------------------------------------
---- start life 20 columns 330 - 392
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
---- start AD&D 21 columns 393 - 455
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
---- start ltd 31 columns 456 - 518
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
---- start STD 30 columns 519 - 581
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
----------------------------------------------------------   
---- start Dependent Basic Life 25 columns 582 - 644
----------------------------------------------------------
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
----------------------------------------------------------            
---- start Supplemental Basic Life 21 columns 645 - 707
----------------------------------------------------------
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
----------------------------------------------------------            
---- start Supplemental Spouse Life 2Z columns 708 - 770
----------------------------------------------------------      
,' ' ::char(2) as lz_covcode
,' ' ::char(8) as lz_cov_start
,' ' ::char(8) as lz_cov_end
,' ' ::char(7) as lz_grp_nbr
,' ' ::char(4) as lz_sub_cd
,' ' ::char(4) as lz_branch
,' ' ::char(2) as lz_filler_741_742
,' ' ::char(1) as lz_status
,' ' ::char(1) AS lz_mbrs_covered
,' ' ::char(10) as lz_filler_745_754
,' ' ::char(8) as lz_annual_benefit_amt
,' ' ::char(8) as lz_filler_763_770
----------------------------------------------------------            
---- start Supplemental Child Life 25 columns 771 - 833
----------------------------------------------------------  
,' ' ::char(2) as lf_covcode
,' ' ::char(8) as lf_cov_start
,' ' ::char(8) as lf_cov_end
,' ' ::char(7) as lf_grp_nbr
,' ' ::char(4) as lf_sub_cd
,' ' ::char(4) as lf_branch
,' ' ::char(2) as lf_filler_804_805
,' ' ::char(1) as lf_status
,' ' ::char(1) AS lf_mbrs_covered
,' ' ::char(10) as lf_filler_808_817
,' ' ::char(8) as lf_annual_benefit_amt
,' ' ::char(8) as lf_filler_826_833
----------------------------------------------------------            
---- start Supplemental Basic AD&D 21 columns 834 - 896
----------------------------------------------------------  
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
----------------------------------------------------------            
---- start Supplemental Spouse AD&D 2Z columns 897 - 959
----------------------------------------------------------  
,' ' ::char(2) as ae_covcode
,' ' ::char(8) as ae_cov_start
,' ' ::char(8) as ae_cov_end
,' ' ::char(7) as ae_grp_nbr
,' ' ::char(4) as ae_sub_cd
,' ' ::char(4) as ae_branch
,' ' ::char(2) as ae_filler_930_931
,' ' ::char(1) as ae_status
,' ' ::char(1) AS ae_mbrs_covered
,' ' ::char(10) as ae_filler_934_943
,' ' ::char(8) as ae_annual_benefit_amt
,' ' ::char(8) as ae_filler_952_959
----------------------------------------------------------            
---- start Supplemental Child AD&D 25 columns 960 - 1022
----------------------------------------------------------  
,' ' ::char(2) as at_covcode
,' ' ::char(8) as at_cov_start
,' ' ::char(8) as at_cov_end
,' ' ::char(7) as at_grp_nbr
,' ' ::char(4) as at_sub_cd
,' ' ::char(4) as at_branch
,' ' ::char(2) as at_filler_993_994
,' ' ::char(1) as at_status
,' ' ::char(1) AS at_mbrs_covered
,' ' ::char(10) as at_filler_997_1006
,' ' ::char(8) as at_annual_benefit_amt
,' ' ::char(8) as at_filler_1015_1022
----------------------------------------------------------            
---- start BuyUp Spouse Life ?? columns 1023 - 1085
----------------------------------------------------------  
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
----------------------------------------------------------            
---- start BuyUp Child Life ?? columns 1086 - 1152
----------------------------------------------------------  
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
----------------------------------------------------------            
---- start BuyUp Spouse AD&D ?? columns 1153 - 1215
----------------------------------------------------------  
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
----------------------------------------------------------            
---- start BuyUp Child AD&D ?? columns 1216 - 1278
----------------------------------------------------------  
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
----------------------------------------------------------            
---- start Vision 14 columns 1279 - 1340
----------------------------------------------------------  
,' ' ::char(2) as vv_covcode
,' ' ::char(8) as vv_cov_start
,' ' ::char(8) as vv_cov_end
,' ' ::char(7) as vv_grp_nbr
,' ' ::char(4) as vv_sub_cd
,' ' ::char(4) as vv_branch
,' ' ::char(2) as vv_filler_1312_1313
,' ' ::char(1) as vv_status
,' ' ::char(1) AS vv_mbrs_covered
,' ' ::char(2) as vv_cancel_rsn
,' ' ::char(23) as vv_filler_1318_1340
            
from person_identity pi

left join edi.edi_last_update elu on elu.feedid = 'APM_Metlife_DentalVisionLife_Export'

LEFT JOIN person_employment pe 
  ON pe.personid = pi.personid 
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts

join person_bene_election pbe
  on pbe.personid = pe.personid
 and pbe.benefitelection = 'E'
 and pbe.selectedoption = 'Y'   
 and pbe.benefitsubclass in ('20','21','11','30','31','14','25','2Z') 
 and current_date between pbe.effectivedate and pbe.enddate
 and current_timestamp between pbe.createts and pbe.endts

----- dependent data

join person_dependent_relationship pdr
  on pdr.personid = pbe.personid
 and current_date between pdr.effectivedate and pdr.enddate
 and current_timestamp between pdr.createts and pdr.endts
 
join dependent_enrollment de
  on de.dependentid = pdr.dependentid
 and de.personid = pbe.personid
 and de.benefitsubclass = pbe.benefitsubclass
 and current_date between de.effectivedate and de.enddate
 and current_timestamp between de.createts and de.endts
  
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
  and pe.emplstatus = 'A'
  order by 1
  ;


  
  