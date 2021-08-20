select distinct
 active_emp.personid
,active_emp.lastupdatets
,active_emp.dependentid

 from 

(
select distinct
 pi.personid      
,elu.lastupdatets
,'0' AS dependentid
,'11'::char(2) as qsource
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
--------------------------------------------------------------------------
---- start dental 11 columns 267 - 329 Based on Coverage Description -----
--------------------------------------------------------------------------
--,to_char(current_date + interval '14 days','MMDDYYYY') as future_date
,case when pbednt.benefitsubclass = '11' then 'D ' else null end ::char(2) as d_covcode
,case when pbednt.benefitsubclass = '11' then to_char(pbednt.effectivedate,'MMDDYYYY') else ' ' end ::char(8) as d_cov_start
,case when pbednt.benefitsubclass = '11' and pbednt.benefitelection = 'T' then to_char(pbednt.effectivedate,'MMDDYYYY') 
      when pbednt.benefitsubclass = '11' and pe.emplstatus = 'T' then to_char(pe.effectivedate,'MMDDYYYY') else ' ' end ::char(8) as d_cov_end
,case when pbednt.benefitsubclass = '11' then '5923955' else ' ' end ::char(7) as d_grp_nbr
,case when pbednt.benefitsubclass = '11' then '0001' else ' ' end ::char(4) as d_sub_cd
,case when pbednt.benefitsubclass = '11' then '0001' else ' ' end ::char(4) as d_branch
,case when pbednt.benefitsubclass = '11' then pa.stateprovincecode else ' ' end ::char(2) as d_plan_cd
----- d_status Based on Employment Status 
----- R for Retirement
----- A for Active and all others
----- Note: terms will have an A, but will send Benefit End Date in Stop Date field (d_cov_end)
,case when pbednt.benefitsubclass = '11' and pe.emplstatus = 'R' then 'R' 
      when pbednt.benefitsubclass = '11' and pe.emplstatus <> 'R' then 'A' else ' ' end ::char(1) as d_status
,case when pbednt.benefitsubclass = '11' and bcddnt.benefitcoveragedesc = 'Employee Only' then '1'
      when pbednt.benefitsubclass = '11' and bcddnt.benefitcoveragedesc in ('EE & 1 Dep or More','Employee + Children') then '2' 
      when pbednt.benefitsubclass = '11' and bcddnt.benefitcoveragedesc = 'Employee + Spouse' then '3'
      when pbednt.benefitsubclass = '11' and bcddnt.benefitcoveragedesc in ('EE & Child(ren) + D/P Adult','EE&1+DPAdult &/or DPChild(ren)','EE&2+DPAdult &/or DPChild(ren)','EE&Child(ren) + DP Adult&DP Ch','Family') then '4'
      else ' ' end ::char(1) AS d_mbrs_covered
,' ' ::char(2) as d_cancel_rsn
,' ' ::char(1) as d_filler_30621
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
,' ' ::char(8) as lt_monthly_benefit_amt
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
,' ' ::char(8) as as_weekly_benefit_amt
,' ' ::char(1) as as_salary_mode
,' ' ::char(7) as as_salary_amount    
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
------------------------------------------------------------------------------            
---- start Supplemental Child Life 25 columns 771 - 833  CHILD(REN) ONLY -----
------------------------------------------------------------------------------  
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
------------------------------------------------------------------------------            
---- start Supplemental Child AD&D 25 columns 960 - 1022 CHILD(REN) ONLY -----
------------------------------------------------------------------------------  
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
----------------------------------------------------------------------------            
---- start Vision 14 columns 1279 - 1340 Based on Coverage Description -----
----------------------------------------------------------------------------  
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
--------------------------------------------------------------------------------------
----- start columns 1350 - 1359 Employee Specific Fields for Voluntary Coverages -----
--------------------------------------------------------------------------------------
,case when la.locationid in ('1','14','15','16','22','23','24') then 'HUNTS'
      when la.locationid = '2'  then 'CULLMAN'
      when la.locationid = '3'  then 'JASPER'
      when la.locationid = '4'  then 'BIRM'
      when la.locationid = '5'  then 'TRUSS'
      when la.locationid = '6'  then 'PELHAM'
      when la.locationid = '7'  then 'GADSDEN'
      when la.locationid = '8'  then 'ALBERT'
      when la.locationid = '9'  then 'MONT'
      when la.locationid = '10' then 'AUBURN'
      when la.locationid = '11' then 'ATHENS'
      when la.locationid = '12' then 'CHATTAN'
      when la.locationid = '13' then 'SHEFFI'
      when la.locationid = '19' then 'TUSC' 
      when la.locationid = '21' then 'RING' end ::char(10) as dept_code

from person_identity pi

left join edi.edi_last_update elu on elu.feedid = 'APM_Metlife_DentalVisionLife_Export'

left join person_employment pe 
  on pe.personid = pi.personid 
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts

left join person_identity pie
  on pie.personid = pi.personid
 and pie.identitytype = 'EmpNo'
 and current_timestamp between pie.createts and pie.endts

left join person_address pa 
  on pa.personid = pi.personid
 and pa.addresstype = 'Res'
 and current_date between pa.effectivedate and pa.enddate
 and current_timestamp between pa.createts and pa.endts 

join person_bene_election pbednt
  on pbednt.personid = pe.personid
 and pbednt.benefitelection = 'E'
 and pbednt.selectedoption = 'Y' 
 and pbednt.benefitsubclass in ('11')  
 and current_date between pbednt.effectivedate and pbednt.enddate
 and current_timestamp between pbednt.createts and pbednt.endts
 ---exclude future dated terms
 and pbednt.personid not in  (select distinct pbe.personid from person_bene_election pbe
                               join (select pbe.personid, pbe.benefitelection, pbe.benefitcoverageid, pbe.benefitsubclass, pbe.benefitplanid, pbe.personbeneelectionpid, pbe.coverageamount, max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate,RANK() over (partition by pbe.personid order by max(pbe.effectivedate) desc) AS RANK
                                       from person_bene_election pbe 
                                       join person_employment pe on pe.personid = pbe.personid and current_date between pe.effectivedate and pe.enddate and current_timestamp between pe.createts and pe.endts and pe.emplstatus not in ('T','R')
                                      where pbe.benefitsubclass = '11' and pbe.benefitelection in ('T','W') and pbe.selectedoption = 'Y' and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate and pbe.effectivedate >= '2019-09-01'
                                        and pbe.personid in (select distinct(personid) from person_bene_election where benefitsubclass in ('11')  and selectedoption = 'Y' and benefitelection = 'E' and current_timestamp between createts and endts and current_date between effectivedate and enddate and date_part('year',deductionstartdate) = date_part('year',current_date - interval '1 year'))
                                      group by pbe.personid, pbe.benefitelection, pbe.benefitcoverageid, pbe.benefitsubclass, pbe.benefitplanid, pbe.personbeneelectionpid, pbe.coverageamount)   pbednt on pbednt.personid = pbe.personid and pbednt.RANK = 1           
                               where pbe.benefitelection = 'E' and pbe.selectedoption = 'Y'  and current_date between pbe.effectivedate and pbe.enddate and current_timestamp between pbe.createts and pbe.endts  and pbe.benefitsubclass in ('11'))  

join benefit_coverage_desc bcddnt
  on bcddnt.benefitcoverageid = pbednt.benefitcoverageid
 and current_date between bcddnt.effectivedate and bcddnt.enddate
 and current_timestamp between bcddnt.createts and bcddnt.endts  

left join (select personid, positionid, scheduledhours, schedulefrequency, max(effectivedate) as effectivedate, RANK() OVER (PARTITION BY personid ORDER BY max(effectivedate) DESC) AS RANK
             from pers_pos where effectivedate < enddate and current_timestamp between createts and endts
            group by personid, positionid, scheduledhours, schedulefrequency) pp on pp.personid = pe.personid and pp.rank = 1 
 
left join (select personid, locationid, max(effectivedate) as effectivedate, RANK() OVER (PARTITION BY personid ORDER BY max(effectivedate) DESC) AS RANK
             from person_locations where effectivedate < enddate and current_timestamp between createts and endts
            group by personid, locationid) pl on pl.personid = pp.personid and pl.rank = 1 

left join (select locationid, stateprovincecode, city, locaddrpid, max(effectivedate) as effectivedate, RANK() OVER (PARTITION BY locationid ORDER BY max(effectivedate) DESC) AS RANK
             from location_address where effectivedate < enddate and current_timestamp between createts and endts
            group by locationid, stateprovincecode, city, locaddrpid) la on la.locationid = pl.locationid and la.rank = 1  


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

left join person_compensation pc
  on pc.personid = pi.personid
 and current_date between pc.effectivedate and pc.enddate
 and current_timestamp between pc.createts and pc.endts 
 
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  and pe.emplstatus NOT IN ('T','R')
  AND PE.PERSONID = '762'
  
  UNION
  
select distinct
 pi.personid      
,elu.lastupdatets
,'0' AS dependentid
,'21'::char(2) as qsource
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
--------------------------------------------------------------------------
---- start dental 11 columns 267 - 329 Based on Coverage Description -----
--------------------------------------------------------------------------
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
,' ' ::char(1) as d_filler_30621
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
,case when pbesupe.benefitsubclass = '21' then 'AD' else ' ' end ::char(2) as ad_covcode
,case when pbesupe.benefitsubclass = '21' then to_char(pbesupe.effectivedate,'MMDDYYYY') else ' ' end ::char(8) as ad_cov_start
,case when pbesupe.benefitsubclass = '21' and pbesupe.benefitelection = 'T' then to_char(pbesupe.enddate,'MMDDYYYY') 
      when pbesupe.benefitsubclass = '21' and pe.emplstatus = 'T' then to_char(pe.effectivedate,'MMDDYYYY') else ' ' end ::char(8) as ad_cov_end
,case when pbesupe.benefitsubclass = '21' then '5923955' else ' ' end ::char(7) as ad_grp_nbr
,case when pbesupe.benefitsubclass = '21' then '0001' else ' ' end ::char(4) as ad_sub_cd
,case when pbesupe.benefitsubclass = '21' then '0001' else ' ' end ::char(4) as ad_branch
,' ' ::char(2) as ad_filler_426_427
,case when pbesupe.benefitsubclass = '21' and pe.emplstatus = 'R' then 'R' 
      when pbesupe.benefitsubclass = '21' and pe.emplstatus <> 'R' then 'A' else ' ' end ::char(1) as ad_status
,case when pbesupe.benefitsubclass = '21' then '1' else ' ' end ::char(1) AS ad_mbrs_covered
,' ' ::char(10) as ad_filler_430_439
,case when pbesupe.benefitsubclass = '21' then to_char(pbesupe.coverageamount, 'FM00000000') else ' ' end ::char(8) as ad_annual_benefit_amt
,case when pbesupe.benefitsubclass = '21' and pc.frequencycode = 'H' then 'H'
      when pbesupe.benefitsubclass = '21' and pc.frequencycode = 'A' then 'A' else ' ' end ::char(1) as ad_salary_mode      
,case when pbesupe.benefitsubclass = '21' and pc.frequencycode = 'H' then to_char(pc.compamount * 100,'FM0000000') 
      when pbesupe.benefitsubclass = '21' then to_char(pc.compamount,'FM0000000')  else ' ' end ::char(7) as ad_salary_amount    
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
,' ' ::char(8) as lt_monthly_benefit_amt
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
,' ' ::char(8) as as_weekly_benefit_amt
,' ' ::char(1) as as_salary_mode
,' ' ::char(7) as as_salary_amount                       
-----------------------------------------------------------------------------            
---- start Supplemental Basic Life 21 columns 645 - 707 EMPLOYEE ONLY   -----
-----------------------------------------------------------------------------
,case when pbesupe.benefitsubclass = '21' then 'OP' else ' ' end ::char(2) as op_covcode
,case when pbesupe.benefitsubclass = '21' then to_char(pbesupe.effectivedate,'MMDDYYYY') else ' ' end ::char(8) as op_cov_start
,case when pbesupe.benefitsubclass = '21' and pbesupe.benefitelection = 'T' then to_char(pbesupe.enddate,'MMDDYYYY') 
      when pbesupe.benefitsubclass = '21' and pe.emplstatus = 'T' then to_char(pe.effectivedate,'MMDDYYYY') else ' ' end ::char(8) as op_cov_end
,case when pbesupe.benefitsubclass = '21' then '5923955' else ' ' end ::char(7) as op_grp_nbr
,case when pbesupe.benefitsubclass = '21' then '0001' else ' ' end ::char(4) as op_sub_cd
,case when pbesupe.benefitsubclass = '21' then '0001' else ' ' end ::char(4) as op_branch
,' ' ::char(2) as op_filler_678_679
,case when pbesupe.benefitsubclass = '21' and pe.emplstatus = 'R' then 'R' 
      when pbesupe.benefitsubclass = '21' and pe.emplstatus <> 'R' then 'A'else ' ' end ::char(1) as op_status
,case when pbesupe.benefitsubclass = '21' then '1' else ' ' end ::char(1) AS op_mbrs_covered
,' ' ::char(10) as op_filler_682_691
,case when pbesupe.benefitsubclass = '21' then to_char(pbesupe.coverageamount, 'FM00000000') else ' ' end ::char(8) as op_annual_benefit_amt
,case when pbesupe.benefitsubclass = '21' and pc.frequencycode = 'H' then 'H' 
      when pbesupe.benefitsubclass = '21' and pc.frequencycode = 'A' then 'A' else ' ' end ::char(1) as op_salary_mode
,case when pbesupe.benefitsubclass = '21' and pc.frequencycode = 'H' then to_char(pc.compamount * 100,'FM0000000') 
      when pbesupe.benefitsubclass = '21' then to_char(pc.compamount,'FM0000000') else ' ' end ::char(7) as op_salary_amount
--------------------------------------------------------------------------            
---- start Supplemental Spouse Life 2Z columns 708 - 770 SPOUSE ONLY -----
--------------------------------------------------------------------------    
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
------------------------------------------------------------------------------            
---- start Supplemental Child Life 25 columns 771 - 833  CHILD(REN) ONLY -----
------------------------------------------------------------------------------  
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
---------------------------------------------------------------------------            
---- start Supplemental Basic AD&D 21 columns 834 - 896 EMPLOYEE ONLY -----
---------------------------------------------------------------------------  
,case when pbesupe.benefitsubclass = '21' then 'OD' else ' ' end ::char(2) as od_covcode
,case when pbesupe.benefitsubclass = '21' then to_char(pbesupe.effectivedate,'MMDDYYYY') else ' ' end ::char(8) as od_cov_start
,case when pbesupe.benefitsubclass = '21' and pbesupe.benefitelection = 'T' then to_char(pbesupe.enddate,'MMDDYYYY') 
      when pbesupe.benefitsubclass = '21' and pe.emplstatus = 'T' then to_char(pe.effectivedate,'MMDDYYYY') else ' ' end ::char(8) as od_cov_end
,case when pbesupe.benefitsubclass = '21' then '5923955' else ' ' end ::char(7) as od_grp_nbr
,case when pbesupe.benefitsubclass = '21' then '0001' else ' ' end ::char(4) as od_sub_cd
,case when pbesupe.benefitsubclass = '21' then '0001' else ' ' end ::char(4) as od_branch
,' ' ::char(2) as od_filler_867_868
,case when pbesupe.benefitsubclass = '21' and pe.emplstatus = 'R' then 'R' 
      when pbesupe.benefitsubclass = '21' and pe.emplstatus <> 'R' then 'A' else ' ' end ::char(1) as od_status
,case when pbesupe.benefitsubclass = '21' then '1' else ' ' end ::char(1) AS od_mbrs_covered
,' ' ::char(10) as od_filler_871_880
,case when pbesupe.benefitsubclass = '21' then to_char(pbesupe.coverageamount, 'FM00000000') else ' ' end ::char(8) as od_annual_benefit_amt
,case when pbesupe.benefitsubclass = '21' and pc.frequencycode = 'H' then 'H' 
      when pbesupe.benefitsubclass = '21' and pc.frequencycode = 'A' then 'A' else ' ' end ::char(1) as od_salary_mode
,case when pbesupe.benefitsubclass = '21' and pc.frequencycode = 'H' then to_char(pc.compamount * 100,'FM0000000') 
      when pbesupe.benefitsubclass = '21' then to_char(pc.compamount,'FM0000000') else ' ' end ::char(7) as od_salary_amount         
--------------------------------------------------------------------------            
---- start Supplemental Spouse AD&D 2Z columns 897 - 959 SPOUSE ONLY -----
--------------------------------------------------------------------------  
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
------------------------------------------------------------------------------            
---- start Supplemental Child AD&D 25 columns 960 - 1022 CHILD(REN) ONLY -----
------------------------------------------------------------------------------  
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
----------------------------------------------------------------------------            
---- start Vision 14 columns 1279 - 1340 Based on Coverage Description -----
----------------------------------------------------------------------------  
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
--------------------------------------------------------------------------------------
----- start columns 1350 - 1359 Employee Specific Fields for Voluntary Coverages -----
--------------------------------------------------------------------------------------
,case when la.locationid in ('1','14','15','16','22','23','24') then 'HUNTS'
      when la.locationid = '2'  then 'CULLMAN'
      when la.locationid = '3'  then 'JASPER'
      when la.locationid = '4'  then 'BIRM'
      when la.locationid = '5'  then 'TRUSS'
      when la.locationid = '6'  then 'PELHAM'
      when la.locationid = '7'  then 'GADSDEN'
      when la.locationid = '8'  then 'ALBERT'
      when la.locationid = '9'  then 'MONT'
      when la.locationid = '10' then 'AUBURN'
      when la.locationid = '11' then 'ATHENS'
      when la.locationid = '12' then 'CHATTAN'
      when la.locationid = '13' then 'SHEFFI'
      when la.locationid = '19' then 'TUSC' 
      when la.locationid = '21' then 'RING' end ::char(10) as dept_code

from person_identity pi

left join edi.edi_last_update elu on elu.feedid = 'APM_Metlife_DentalVisionLife_Export'

left join person_employment pe 
  on pe.personid = pi.personid 
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts

left join person_identity pie
  on pie.personid = pi.personid
 and pie.identitytype = 'EmpNo'
 and current_timestamp between pie.createts and pie.endts

left join person_address pa 
  on pa.personid = pi.personid
 and pa.addresstype = 'Res'
 and current_date between pa.effectivedate and pa.enddate
 and current_timestamp between pa.createts and pa.endts 

join person_bene_election pbesupe
  on pbesupe.personid = pe.personid
 and pbesupe.benefitelection = 'E'
 and pbesupe.selectedoption = 'Y' 
 and pbesupe.benefitsubclass in ('21')  
 and current_date between pbesupe.effectivedate and pbesupe.enddate
 and current_timestamp between pbesupe.createts and pbesupe.endts 
 ---exclude future dated terms
 and pbesupe.personid not in  (select distinct pbe.personid from person_bene_election pbe
                               join (select pbe.personid, pbe.benefitelection, pbe.benefitcoverageid, pbe.benefitsubclass, pbe.benefitplanid, pbe.personbeneelectionpid, pbe.coverageamount, max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate,RANK() over (partition by pbe.personid order by max(pbe.effectivedate) desc) AS RANK
                                       from person_bene_election pbe 
                                       join person_employment pe on pe.personid = pbe.personid and current_date between pe.effectivedate and pe.enddate and current_timestamp between pe.createts and pe.endts and pe.emplstatus not in ('T','R')
                                      where pbe.benefitsubclass = '21' and pbe.benefitelection in ('T','W') and pbe.selectedoption = 'Y' and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate and pbe.effectivedate >= '2019-09-01'
                                        and pbe.personid in (select distinct(personid) from person_bene_election where benefitsubclass in ('21')  and selectedoption = 'Y' and benefitelection = 'E' and current_timestamp between createts and endts and current_date between effectivedate and enddate and date_part('year',deductionstartdate) = date_part('year',current_date - interval '1 year'))
                                      group by pbe.personid, pbe.benefitelection, pbe.benefitcoverageid, pbe.benefitsubclass, pbe.benefitplanid, pbe.personbeneelectionpid, pbe.coverageamount)   pbednt on pbednt.personid = pbe.personid and pbednt.RANK = 1           
                               where pbe.benefitelection = 'E' and pbe.selectedoption = 'Y'  and current_date between pbe.effectivedate and pbe.enddate and current_timestamp between pbe.createts and pbe.endts  and pbe.benefitsubclass in ('21'))   
 
 
left join (select personid, positionid, scheduledhours, schedulefrequency, max(effectivedate) as effectivedate, RANK() OVER (PARTITION BY personid ORDER BY max(effectivedate) DESC) AS RANK
             from pers_pos where effectivedate < enddate and current_timestamp between createts and endts
            group by personid, positionid, scheduledhours, schedulefrequency) pp on pp.personid = pe.personid and pp.rank = 1 
 
left join (select personid, locationid, max(effectivedate) as effectivedate, RANK() OVER (PARTITION BY personid ORDER BY max(effectivedate) DESC) AS RANK
             from person_locations where effectivedate < enddate and current_timestamp between createts and endts
            group by personid, locationid) pl on pl.personid = pp.personid and pl.rank = 1 

left join (select locationid, stateprovincecode, city, locaddrpid, max(effectivedate) as effectivedate, RANK() OVER (PARTITION BY locationid ORDER BY max(effectivedate) DESC) AS RANK
             from location_address where effectivedate < enddate and current_timestamp between createts and endts
            group by locationid, stateprovincecode, city, locaddrpid) la on la.locationid = pl.locationid and la.rank = 1  


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

left join person_compensation pc
  on pc.personid = pi.personid
 and current_date between pc.effectivedate and pc.enddate
 and current_timestamp between pc.createts and pc.endts 
 
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts 
  and pe.emplstatus NOT IN ('T','R')  
  AND PE.PERSONID = '762'
  
  UNION
  
select distinct
 pi.personid      
,elu.lastupdatets
,'0' AS dependentid
,'ACTIVE EE BLIFE(20)'::varchar(30) as qsource
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
--------------------------------------------------------------------------
---- start dental 11 columns 267 - 329 Based on Coverage Description -----
--------------------------------------------------------------------------
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
,' ' ::char(1) as d_filler_30621
,' ' ::char(8) as d_facility_id
,' ' ::char(15) as d_filler_315_329
----------------------------------------------------------
---- start life 20 columns 330 - 392 EMPLOYEE ONLY   -----
----------------------------------------------------------
,case when pbeblife.benefitsubclass = '20' then 'CP' else ' ' end ::char(2) as cp_covcode
,case when pbeblife.benefitsubclass = '20' then to_char(pbeblife.effectivedate,'MMDDYYYY') else ' ' end ::char(8) as cp_cov_start
,case when pbeblife.benefitsubclass = '20' and pbeblife.benefitelection = 'T' then to_char(pbeblife.enddate,'MMDDYYYY') 
      when pbeblife.benefitsubclass = '20' and pe.emplstatus = 'T' then to_char(pe.effectivedate,'MMDDYYYY') else ' ' end ::char(8) as cp_cov_end
,case when pbeblife.benefitsubclass = '20' then '5923955' else ' ' end ::char(7) as cp_grp_nbr
,case when pbeblife.benefitsubclass = '20' then '0001' else ' ' end ::char(4) as cp_sub_cd
,case when pbeblife.benefitsubclass = '20' then '0001' else ' ' end ::char(4) as cp_branch
,' ' ::char(2) as cp_filler_363_364
----- cp_status Based on Employment Status 
----- R for Retirement
----- A for Active and all others
----- Note: terms will have an A, but will send Benefit End Date in Stop Date field (cp_cov_end)
,case when pbeblife.benefitsubclass = '20' and pe.emplstatus = 'R' then 'R' 
      when pbeblife.benefitsubclass = '20' and pe.emplstatus <> 'R' then 'A' else ' ' end ::char(1) as cp_status
,case when pbeblife.benefitsubclass = '20' then '1' else ' ' end ::char(1) AS cp_mbrs_covered
,' ' ::char(10) as cp_filler_367_376
,case when pbeblife.benefitsubclass = '20' then to_char(pbeblife.coverageamount, 'FM00000000') else ' ' end ::char(8) as cp_annual_benefit_amt
,case when pbeblife.benefitsubclass = '20' and pc.frequencycode = 'H' then 'H'
      when pbeblife.benefitsubclass = '20' and pc.frequencycode = 'A' then 'A' else ' ' end ::char(1) as cp_salary_mode
,case when pbeblife.benefitsubclass = '20' and pc.frequencycode = 'H' then to_char(pc.compamount * 100,'FM0000000') 
      when pbeblife.benefitsubclass = '20' then to_char(pc.compamount,'FM0000000') else ' ' end ::char(7) as cp_salary_amount
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
,' ' ::char(8) as lt_monthly_benefit_amt
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
,' ' ::char(8) as as_weekly_benefit_amt
,' ' ::char(1) as as_salary_mode
,' ' ::char(7) as as_salary_amount    
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
------------------------------------------------------------------------------            
---- start Supplemental Child Life 25 columns 771 - 833  CHILD(REN) ONLY -----
------------------------------------------------------------------------------  
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
------------------------------------------------------------------------------            
---- start Supplemental Child AD&D 25 columns 960 - 1022 CHILD(REN) ONLY -----
------------------------------------------------------------------------------  
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
----------------------------------------------------------------------------            
---- start Vision 14 columns 1279 - 1340 Based on Coverage Description -----
----------------------------------------------------------------------------  
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
--------------------------------------------------------------------------------------
----- start columns 1350 - 1359 Employee Specific Fields for Voluntary Coverages -----
--------------------------------------------------------------------------------------
,case when la.locationid in ('1','14','15','16','22','23','24') then 'HUNTS'
      when la.locationid = '2'  then 'CULLMAN'
      when la.locationid = '3'  then 'JASPER'
      when la.locationid = '4'  then 'BIRM'
      when la.locationid = '5'  then 'TRUSS'
      when la.locationid = '6'  then 'PELHAM'
      when la.locationid = '7'  then 'GADSDEN'
      when la.locationid = '8'  then 'ALBERT'
      when la.locationid = '9'  then 'MONT'
      when la.locationid = '10' then 'AUBURN'
      when la.locationid = '11' then 'ATHENS'
      when la.locationid = '12' then 'CHATTAN'
      when la.locationid = '13' then 'SHEFFI'
      when la.locationid = '19' then 'TUSC' 
      when la.locationid = '21' then 'RING' end ::char(10) as dept_code

from person_identity pi

left join edi.edi_last_update elu on elu.feedid = 'APM_Metlife_DentalVisionLife_Export'

left join person_employment pe 
  on pe.personid = pi.personid 
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts

left join person_identity pie
  on pie.personid = pi.personid
 and pie.identitytype = 'EmpNo'
 and current_timestamp between pie.createts and pie.endts

left join person_address pa 
  on pa.personid = pi.personid
 and pa.addresstype = 'Res'
 and current_date between pa.effectivedate and pa.enddate
 and current_timestamp between pa.createts and pa.endts 

join person_bene_election pbeblife
  on pbeblife.personid = pe.personid
 and pbeblife.benefitelection = 'E'
 and pbeblife.selectedoption = 'Y' 
 and pbeblife.benefitsubclass in ('20')  
 and current_date between pbeblife.effectivedate and pbeblife.enddate
 and current_timestamp between pbeblife.createts and pbeblife.endts
  ---exclude future dated terms
 and pbeblife.personid not in  (select distinct pbe.personid from person_bene_election pbe
                               join (select pbe.personid, pbe.benefitelection, pbe.benefitcoverageid, pbe.benefitsubclass, pbe.benefitplanid, pbe.personbeneelectionpid, pbe.coverageamount, max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate,RANK() over (partition by pbe.personid order by max(pbe.effectivedate) desc) AS RANK
                                       from person_bene_election pbe 
                                       join person_employment pe on pe.personid = pbe.personid and current_date between pe.effectivedate and pe.enddate and current_timestamp between pe.createts and pe.endts and pe.emplstatus not in ('T','R')
                                      where pbe.benefitsubclass = '20' and pbe.benefitelection in ('T','W') and pbe.selectedoption = 'Y' and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate and pbe.effectivedate >= '2019-09-01'
                                        and pbe.personid in (select distinct(personid) from person_bene_election where benefitsubclass in ('20')  and selectedoption = 'Y' and benefitelection = 'E' and current_timestamp between createts and endts and current_date between effectivedate and enddate and date_part('year',deductionstartdate) = date_part('year',current_date - interval '1 year'))
                                      group by pbe.personid, pbe.benefitelection, pbe.benefitcoverageid, pbe.benefitsubclass, pbe.benefitplanid, pbe.personbeneelectionpid, pbe.coverageamount)   pbednt on pbednt.personid = pbe.personid and pbednt.RANK = 1           
                               where pbe.benefitelection = 'E' and pbe.selectedoption = 'Y'  and current_date between pbe.effectivedate and pbe.enddate and current_timestamp between pbe.createts and pbe.endts  and pbe.benefitsubclass in ('20'))   

left join (select personid, positionid, scheduledhours, schedulefrequency, max(effectivedate) as effectivedate, RANK() OVER (PARTITION BY personid ORDER BY max(effectivedate) DESC) AS RANK
             from pers_pos where effectivedate < enddate and current_timestamp between createts and endts
            group by personid, positionid, scheduledhours, schedulefrequency) pp on pp.personid = pe.personid and pp.rank = 1 
 
left join (select personid, locationid, max(effectivedate) as effectivedate, RANK() OVER (PARTITION BY personid ORDER BY max(effectivedate) DESC) AS RANK
             from person_locations where effectivedate < enddate and current_timestamp between createts and endts
            group by personid, locationid) pl on pl.personid = pp.personid and pl.rank = 1 

left join (select locationid, stateprovincecode, city, locaddrpid, max(effectivedate) as effectivedate, RANK() OVER (PARTITION BY locationid ORDER BY max(effectivedate) DESC) AS RANK
             from location_address where effectivedate < enddate and current_timestamp between createts and endts
            group by locationid, stateprovincecode, city, locaddrpid) la on la.locationid = pl.locationid and la.rank = 1  


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

left join person_compensation pc
  on pc.personid = pi.personid
 and current_date between pc.effectivedate and pc.enddate
 and current_timestamp between pc.createts and pc.endts 
 
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts 
  and pe.emplstatus NOT IN ('T','R') 
  AND PE.PERSONID = '762' 

  UNION
  
select distinct
 pi.personid      
,elu.lastupdatets
,'0' AS dependentid
,'ACTIVE EE LTD(31)'::varchar(30) as qsource
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
--------------------------------------------------------------------------
---- start dental 11 columns 267 - 329 Based on Coverage Description -----
--------------------------------------------------------------------------
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
,' ' ::char(1) as d_filler_30621
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
,case when pbeltd.benefitsubclass = '31' then 'LT' else ' ' end ::char(2) as lt_covcode
,case when pbeltd.benefitsubclass = '31' then to_char(pbeltd.effectivedate,'MMDDYYYY') else ' ' end ::char(8) as lt_cov_start
,case when pbeltd.benefitsubclass = '31' and pbeltd.benefitelection = 'T' then to_char(pbeltd.enddate,'MMDDYYYY') 
      when pbeltd.benefitsubclass = '31' and pe.emplstatus = 'T' then to_char(pe.effectivedate,'MMDDYYYY') else ' ' end ::char(8) as lt_cov_end
,case when pbeltd.benefitsubclass = '31' then '5923955' else ' ' end ::char(7) as lt_grp_nbr
,case when pbeltd.benefitsubclass = '31' then '0001' else ' ' end ::char(4) as lt_sub_cd
,case when pbeltd.benefitsubclass = '31' then '0001' else ' ' end ::char(4) as lt_branch
,' ' ::char(2) as lt_filler_489_490
----- lt_status Based on Employment Status 
----- R for Retirement
----- A for Active and all others
----- Note: terms will have an A, but will send Benefit End Date in Stop Date field (lt_cov_end)
,case when pbeltd.benefitsubclass = '31' and pe.emplstatus = 'R' then 'R' 
      when pbeltd.benefitsubclass = '31' and pe.emplstatus <> 'R' then 'A' else ' ' end ::char(1) as lt_status
,case when pbeltd.benefitsubclass = '31' then '1' else ' ' end ::char(1) AS lt_mbrs_covered
,' ' ::char(10) as lt_filler_493_502
,case when pbeltd.benefitsubclass = '31' then to_char(pbocm.employeerate, 'FM00000000') else ' ' end ::char(8) as lt_monthly_benefit_amt
,case when pbeltd.benefitsubclass = '31' and pc.frequencycode = 'H' then 'H' 
      when pbeltd.benefitsubclass = '31' and pc.frequencycode = 'A' then 'A' else ' ' end ::char(1) as lt_salary_mode
,case when pbeltd.benefitsubclass = '31' and pc.frequencycode = 'H' then to_char(pc.compamount * 100,'FM0000000') 
      when pbeltd.benefitsubclass = '31' then to_char(pc.compamount,'FM0000000') else ' ' end ::char(7) as lt_salary_amount   
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
,' ' ::char(8) as as_weekly_benefit_amt
,' ' ::char(1) as as_salary_mode
,' ' ::char(7) as as_salary_amount               
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
------------------------------------------------------------------------------            
---- start Supplemental Child Life 25 columns 771 - 833  CHILD(REN) ONLY -----
------------------------------------------------------------------------------  
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
------------------------------------------------------------------------------            
---- start Supplemental Child AD&D 25 columns 960 - 1022 CHILD(REN) ONLY -----
------------------------------------------------------------------------------  
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
----------------------------------------------------------------------------            
---- start Vision 14 columns 1279 - 1340 Based on Coverage Description -----
----------------------------------------------------------------------------  
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
--------------------------------------------------------------------------------------
----- start columns 1350 - 1359 Employee Specific Fields for Voluntary Coverages -----
--------------------------------------------------------------------------------------
,case when la.locationid in ('1','14','15','16','22','23','24') then 'HUNTS'
      when la.locationid = '2'  then 'CULLMAN'
      when la.locationid = '3'  then 'JASPER'
      when la.locationid = '4'  then 'BIRM'
      when la.locationid = '5'  then 'TRUSS'
      when la.locationid = '6'  then 'PELHAM'
      when la.locationid = '7'  then 'GADSDEN'
      when la.locationid = '8'  then 'ALBERT'
      when la.locationid = '9'  then 'MONT'
      when la.locationid = '10' then 'AUBURN'
      when la.locationid = '11' then 'ATHENS'
      when la.locationid = '12' then 'CHATTAN'
      when la.locationid = '13' then 'SHEFFI'
      when la.locationid = '19' then 'TUSC' 
      when la.locationid = '21' then 'RING' end ::char(10) as dept_code

from person_identity pi

left join edi.edi_last_update elu on elu.feedid = 'APM_Metlife_DentalVisionLife_Export'

left join person_employment pe 
  on pe.personid = pi.personid 
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts

left join person_identity pie
  on pie.personid = pi.personid
 and pie.identitytype = 'EmpNo'
 and current_timestamp between pie.createts and pie.endts

left join person_address pa 
  on pa.personid = pi.personid
 and pa.addresstype = 'Res'
 and current_date between pa.effectivedate and pa.enddate
 and current_timestamp between pa.createts and pa.endts 

join person_bene_election pbeltd
  on pbeltd.personid = pe.personid
 and pbeltd.benefitelection = 'E'
 and pbeltd.selectedoption = 'Y' 
 and pbeltd.benefitsubclass in ('31')  
 and current_date between pbeltd.effectivedate and pbeltd.enddate
 and current_timestamp between pbeltd.createts and pbeltd.endts
  ---exclude future dated terms
 and pbeltd.personid not in  (select distinct pbe.personid from person_bene_election pbe
                               join (select pbe.personid, pbe.benefitelection, pbe.benefitcoverageid, pbe.benefitsubclass, pbe.benefitplanid, pbe.personbeneelectionpid, pbe.coverageamount, max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate,RANK() over (partition by pbe.personid order by max(pbe.effectivedate) desc) AS RANK
                                       from person_bene_election pbe 
                                       join person_employment pe on pe.personid = pbe.personid and current_date between pe.effectivedate and pe.enddate and current_timestamp between pe.createts and pe.endts and pe.emplstatus not in ('T','R')
                                      where pbe.benefitsubclass = '31' and pbe.benefitelection in ('T','W') and pbe.selectedoption = 'Y' and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate and pbe.effectivedate >= '2019-09-01'
                                        and pbe.personid in (select distinct(personid) from person_bene_election where benefitsubclass in ('31')  and selectedoption = 'Y' and benefitelection = 'E' and current_timestamp between createts and endts and current_date between effectivedate and enddate and date_part('year',deductionstartdate) = date_part('year',current_date - interval '1 year'))
                                      group by pbe.personid, pbe.benefitelection, pbe.benefitcoverageid, pbe.benefitsubclass, pbe.benefitplanid, pbe.personbeneelectionpid, pbe.coverageamount)   pbednt on pbednt.personid = pbe.personid and pbednt.RANK = 1           
                               where pbe.benefitelection = 'E' and pbe.selectedoption = 'Y'  and current_date between pbe.effectivedate and pbe.enddate and current_timestamp between pbe.createts and pbe.endts  and pbe.benefitsubclass in ('31'))    

left join personbenoptioncostl pbocm
  on pbocm.personid = pbeltd.personid
 and pbocm.personbeneelectionpid = pbeltd.personbeneelectionpid
 and pbocm.costsby = 'M' --- monthly amount
 and pbocm.benefitelection = 'E'    
 
left join (select personid, positionid, scheduledhours, schedulefrequency, max(effectivedate) as effectivedate, RANK() OVER (PARTITION BY personid ORDER BY max(effectivedate) DESC) AS RANK
             from pers_pos where effectivedate < enddate and current_timestamp between createts and endts
            group by personid, positionid, scheduledhours, schedulefrequency) pp on pp.personid = pe.personid and pp.rank = 1 
 
left join (select personid, locationid, max(effectivedate) as effectivedate, RANK() OVER (PARTITION BY personid ORDER BY max(effectivedate) DESC) AS RANK
             from person_locations where effectivedate < enddate and current_timestamp between createts and endts
            group by personid, locationid) pl on pl.personid = pp.personid and pl.rank = 1 

left join (select locationid, stateprovincecode, city, locaddrpid, max(effectivedate) as effectivedate, RANK() OVER (PARTITION BY locationid ORDER BY max(effectivedate) DESC) AS RANK
             from location_address where effectivedate < enddate and current_timestamp between createts and endts
            group by locationid, stateprovincecode, city, locaddrpid) la on la.locationid = pl.locationid and la.rank = 1  


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

left join person_compensation pc
  on pc.personid = pi.personid
 and current_date between pc.effectivedate and pc.enddate
 and current_timestamp between pc.createts and pc.endts 
 
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts 
  and pe.emplstatus NOT IN ('T','R')    
  AND PE.PERSONID = '762'
  
  UNION
  
select distinct
 pi.personid      
,elu.lastupdatets
,'0' AS dependentid
,'ACTIVE EE STD(30)'::varchar(30) as qsource
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
--------------------------------------------------------------------------
---- start dental 11 columns 267 - 329 Based on Coverage Description -----
--------------------------------------------------------------------------
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
,' ' ::char(1) as d_filler_30621
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
,' ' ::char(8) as lt_monthly_benefit_amt
,' ' ::char(1) as lt_salary_mode
,' ' ::char(7) as lt_salary_amount
----------------------------------------------------------
---- start STD 30 columns 519 - 581  EMPLOYEE ONLY   -----
----------------------------------------------------------
,case when pbestd.benefitsubclass = '30' then 'AS' else ' ' end ::char(2) as as_covcode
,case when pbestd.benefitsubclass = '30' then to_char(pbestd.effectivedate,'MMDDYYYY') else ' ' end ::char(8) as as_cov_start
,case when pbestd.benefitsubclass = '30' and pe.emplstatus in ('T','R') then to_char(pe.effectivedate,'MMDDYYYY')
      when pbestd.benefitsubclass = '30' and pbestd.benefitelection in ('T') then to_char(pbestd.enddate,'MMDDYYYY') else ' ' end ::char(8) as as_cov_end
,case when pbestd.benefitsubclass = '30' then '5923955' else ' ' end ::char(7) as as_grp_nbr
,case when pbestd.benefitsubclass = '30' then '0001' else ' ' end ::char(4) as as_sub_cd
,case when pbestd.benefitsubclass = '30' then '0001' else ' ' end ::char(4) as as_branch
,' ' ::char(2) as as_filler_552_553
----- as_status Based on Employment Status 
----- R for Retirement
----- A for Active and all others
----- Note: terms will have an A, but will send Benefit End Date in Stop Date field (as_cov_end)
,case when pbestd.benefitsubclass = '30' and pe.emplstatus = 'R' then 'R' 
      when pbestd.benefitsubclass = '30' and pe.emplstatus <> 'R' then 'A' else ' ' end ::char(1) as as_status
,case when pbestd.benefitsubclass = '30' then '1' else ' ' end ::char(1) AS as_mbrs_covered
,' ' ::char(10) as as_filler_556_565
,case when pbestd.benefitsubclass = '30' then to_char(pbocp.employeerate, 'FM00000000') else ' ' end ::char(8) as as_weekly_benefit_amt
,case when pbestd.benefitsubclass = '30' and pc.frequencycode = 'H' then 'H' 
      when pbestd.benefitsubclass = '30' and pc.frequencycode = 'A' then 'A' else ' ' end ::char(1) as as_salary_mode
,case when pbestd.benefitsubclass = '30' and pc.frequencycode = 'H' then to_char(pc.compamount * 100,'FM0000000') 
      when pbestd.benefitsubclass = '30' then to_char(pc.compamount,'FM0000000') else ' ' end ::char(7) as as_salary_amount    
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
------------------------------------------------------------------------------            
---- start Supplemental Child Life 25 columns 771 - 833  CHILD(REN) ONLY -----
------------------------------------------------------------------------------  
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
------------------------------------------------------------------------------            
---- start Supplemental Child AD&D 25 columns 960 - 1022 CHILD(REN) ONLY -----
------------------------------------------------------------------------------  
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
----------------------------------------------------------------------------            
---- start Vision 14 columns 1279 - 1340 Based on Coverage Description -----
----------------------------------------------------------------------------  
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
--------------------------------------------------------------------------------------
----- start columns 1350 - 1359 Employee Specific Fields for Voluntary Coverages -----
--------------------------------------------------------------------------------------
,case when la.locationid in ('1','14','15','16','22','23','24') then 'HUNTS'
      when la.locationid = '2'  then 'CULLMAN'
      when la.locationid = '3'  then 'JASPER'
      when la.locationid = '4'  then 'BIRM'
      when la.locationid = '5'  then 'TRUSS'
      when la.locationid = '6'  then 'PELHAM'
      when la.locationid = '7'  then 'GADSDEN'
      when la.locationid = '8'  then 'ALBERT'
      when la.locationid = '9'  then 'MONT'
      when la.locationid = '10' then 'AUBURN'
      when la.locationid = '11' then 'ATHENS'
      when la.locationid = '12' then 'CHATTAN'
      when la.locationid = '13' then 'SHEFFI'
      when la.locationid = '19' then 'TUSC' 
      when la.locationid = '21' then 'RING' end ::char(10) as dept_code

from person_identity pi

left join edi.edi_last_update elu on elu.feedid = 'APM_Metlife_DentalVisionLife_Export'

left join person_employment pe 
  on pe.personid = pi.personid 
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts

left join person_identity pie
  on pie.personid = pi.personid
 and pie.identitytype = 'EmpNo'
 and current_timestamp between pie.createts and pie.endts

left join person_address pa 
  on pa.personid = pi.personid
 and pa.addresstype = 'Res'
 and current_date between pa.effectivedate and pa.enddate
 and current_timestamp between pa.createts and pa.endts 

join person_bene_election pbestd
  on pbestd.personid = pe.personid
 and pbestd.benefitelection = 'E'
 and pbestd.selectedoption = 'Y' 
 and pbestd.benefitsubclass in ('30')  
 and current_date between pbestd.effectivedate and pbestd.enddate
 and current_timestamp between pbestd.createts and pbestd.endts
  ---exclude future dated terms
 and pbestd.personid not in  (select distinct pbe.personid from person_bene_election pbe
                               join (select pbe.personid, pbe.benefitelection, pbe.benefitcoverageid, pbe.benefitsubclass, pbe.benefitplanid, pbe.personbeneelectionpid, pbe.coverageamount, max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate,RANK() over (partition by pbe.personid order by max(pbe.effectivedate) desc) AS RANK
                                       from person_bene_election pbe 
                                       join person_employment pe on pe.personid = pbe.personid and current_date between pe.effectivedate and pe.enddate and current_timestamp between pe.createts and pe.endts and pe.emplstatus not in ('T','R')
                                      where pbe.benefitsubclass = '30' and pbe.benefitelection in ('T','W') and pbe.selectedoption = 'Y' and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate and pbe.effectivedate >= '2019-09-01'
                                        and pbe.personid in (select distinct(personid) from person_bene_election where benefitsubclass in ('30')  and selectedoption = 'Y' and benefitelection = 'E' and current_timestamp between createts and endts and current_date between effectivedate and enddate and date_part('year',deductionstartdate) = date_part('year',current_date - interval '1 year'))
                                      group by pbe.personid, pbe.benefitelection, pbe.benefitcoverageid, pbe.benefitsubclass, pbe.benefitplanid, pbe.personbeneelectionpid, pbe.coverageamount)   pbednt on pbednt.personid = pbe.personid and pbednt.RANK = 1           
                               where pbe.benefitelection = 'E' and pbe.selectedoption = 'Y'  and current_date between pbe.effectivedate and pbe.enddate and current_timestamp between pbe.createts and pbe.endts  and pbe.benefitsubclass in ('30'))    

left join personbenoptioncostl pbocp
  on pbocp.personid = pbestd.personid
 and pbocp.personbeneelectionpid = pbestd.personbeneelectionpid
 and pbocp.costsby = 'P' --- weekly amount
 and pbocp.benefitelection = 'E'         
 
left join (select personid, positionid, scheduledhours, schedulefrequency, max(effectivedate) as effectivedate, RANK() OVER (PARTITION BY personid ORDER BY max(effectivedate) DESC) AS RANK
             from pers_pos where effectivedate < enddate and current_timestamp between createts and endts
            group by personid, positionid, scheduledhours, schedulefrequency) pp on pp.personid = pe.personid and pp.rank = 1 
 
left join (select personid, locationid, max(effectivedate) as effectivedate, RANK() OVER (PARTITION BY personid ORDER BY max(effectivedate) DESC) AS RANK
             from person_locations where effectivedate < enddate and current_timestamp between createts and endts
            group by personid, locationid) pl on pl.personid = pp.personid and pl.rank = 1 

left join (select locationid, stateprovincecode, city, locaddrpid, max(effectivedate) as effectivedate, RANK() OVER (PARTITION BY locationid ORDER BY max(effectivedate) DESC) AS RANK
             from location_address where effectivedate < enddate and current_timestamp between createts and endts
            group by locationid, stateprovincecode, city, locaddrpid) la on la.locationid = pl.locationid and la.rank = 1  


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

left join person_compensation pc
  on pc.personid = pi.personid
 and current_date between pc.effectivedate and pc.enddate
 and current_timestamp between pc.createts and pc.endts 
 
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts 
  and pe.emplstatus NOT IN ('T','R')  
  AND PE.PERSONID = '762'
  
  UNION
  
select distinct
 pi.personid      
,elu.lastupdatets
,'0' AS dependentid
,'ACTIVE EE SUPS(2Z)'::varchar(30) as qsource
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
--------------------------------------------------------------------------
---- start dental 11 columns 267 - 329 Based on Coverage Description -----
--------------------------------------------------------------------------
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
,' ' ::char(1) as d_filler_30621
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
,' ' ::char(8) as lt_monthly_benefit_amt
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
,' ' ::char(8) as as_weekly_benefit_amt
,' ' ::char(1) as as_salary_mode
,' ' ::char(7) as as_salary_amount     
      
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
,case when pbesups.benefitsubclass = '2Z' then 'LZ' else ' ' end ::char(2) as lz_covcode
,case when pbesups.benefitsubclass = '2Z' then to_char(pbesups.effectivedate,'MMDDYYYY') else ' ' end ::char(8) as lz_cov_start
,case when pbesups.benefitsubclass = '2Z' and pe.emplstatus in ('T','R') then to_char(pe.effectivedate,'MMDDYYYY')
      when pbesups.benefitsubclass = '2Z' and pbesups.benefitelection in ('T') then to_char(pbesups.enddate,'MMDDYYYY') else ' ' end ::char(8) as lz_cov_end
,case when pbesups.benefitsubclass = '2Z' then '5923955' else ' ' end ::char(7) as lz_grp_nbr
,case when pbesups.benefitsubclass = '2Z' then '0001' else ' ' end ::char(4) as lz_sub_cd
,case when pbesups.benefitsubclass = '2Z' then '0001' else ' ' end ::char(4) as lz_branch
,' ' ::char(2) as lz_filler_741_742
----- lz_status Based on Employment Status 
----- R for Retirement
----- A for Active and all others
----- Note: terms will have an A, but will send Benefit End Date in Stop Date field (lz_cov_end)
,case when pbesups.benefitsubclass = '2Z' and pe.emplstatus = 'R' then 'R' 
      when pbesups.benefitsubclass = '2Z' and pe.emplstatus <> 'R' then 'A' else ' ' end ::char(1) as lz_status
,case when pbesups.benefitsubclass = '2Z' then 'A' else ' ' end ::char(1) AS lz_mbrs_covered
,' ' ::char(10) as lz_filler_745_754
,case when pbesups.benefitsubclass = '2Z' then to_char(pbesups.coverageamount, 'FM00000000') else ' ' end ::char(8) as lz_annual_benefit_amt
,' ' ::char(8) as lz_filler_763_770
------------------------------------------------------------------------------            
---- start Supplemental Child Life 25 columns 771 - 833  CHILD(REN) ONLY -----
------------------------------------------------------------------------------  
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
,case when pbesups.benefitsubclass = '2Z' then 'AE' else ' ' end ::char(2) as ae_covcode
,case when pbesups.benefitsubclass = '2Z' then to_char(pbesups.effectivedate,'MMDDYYYY') else ' ' end ::char(8) as ae_cov_start
,case when pbesups.benefitsubclass = '2Z' and pe.emplstatus in ('T','R') then to_char(pe.effectivedate,'MMDDYYYY')
      when pbesups.benefitsubclass = '2Z' and pbesups.benefitelection in ('T') then to_char(pbesups.enddate,'MMDDYYYY') else ' ' end ::char(8) as ae_cov_end
,case when pbesups.benefitsubclass = '2Z' then '5923955' else ' ' end ::char(7) as ae_grp_nbr
,case when pbesups.benefitsubclass = '2Z' then '0001' else ' ' end ::char(4) as ae_sub_cd
,case when pbesups.benefitsubclass = '2Z' then '0001' else ' ' end ::char(4) as ae_branch
,' ' ::char(2) as ae_filler_930_931
----- ae_status Based on Employment Status 
----- R for Retirement
----- A for Active and all others
----- Note: terms will have an A, but will send Benefit End Date in Stop Date field (ae_cov_end)
,case when pbesups.benefitsubclass = '2Z' and pe.emplstatus = 'R' then 'R' 
      when pbesups.benefitsubclass = '2Z' and pe.emplstatus <> 'R' then 'A' else ' ' end ::char(1) as ae_status
,case when pbesups.benefitsubclass = '2Z' then 'A' else ' ' end ::char(1) AS ae_mbrs_covered
,' ' ::char(10) as ae_filler_934_943
,case when pbesups.benefitsubclass = '2Z' then to_char(pbesups.coverageamount, 'FM00000000') else ' ' end ::char(8) as ae_annual_benefit_amt
,' ' ::char(8) as ae_filler_952_959
 ------------------------------------------------------------------------------            
---- start Supplemental Child AD&D 25 columns 960 - 1022 CHILD(REN) ONLY -----
------------------------------------------------------------------------------  
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
----------------------------------------------------------------------------            
---- start Vision 14 columns 1279 - 1340 Based on Coverage Description -----
----------------------------------------------------------------------------  
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
--------------------------------------------------------------------------------------
----- start columns 1350 - 1359 Employee Specific Fields for Voluntary Coverages -----
--------------------------------------------------------------------------------------
,case when la.locationid in ('1','14','15','16','22','23','24') then 'HUNTS'
      when la.locationid = '2'  then 'CULLMAN'
      when la.locationid = '3'  then 'JASPER'
      when la.locationid = '4'  then 'BIRM'
      when la.locationid = '5'  then 'TRUSS'
      when la.locationid = '6'  then 'PELHAM'
      when la.locationid = '7'  then 'GADSDEN'
      when la.locationid = '8'  then 'ALBERT'
      when la.locationid = '9'  then 'MONT'
      when la.locationid = '10' then 'AUBURN'
      when la.locationid = '11' then 'ATHENS'
      when la.locationid = '12' then 'CHATTAN'
      when la.locationid = '13' then 'SHEFFI'
      when la.locationid = '19' then 'TUSC' 
      when la.locationid = '21' then 'RING' end ::char(10) as dept_code

from person_identity pi

left join edi.edi_last_update elu on elu.feedid = 'APM_Metlife_DentalVisionLife_Export'

left join person_employment pe 
  on pe.personid = pi.personid 
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts

left join person_identity pie
  on pie.personid = pi.personid
 and pie.identitytype = 'EmpNo'
 and current_timestamp between pie.createts and pie.endts

left join person_address pa 
  on pa.personid = pi.personid
 and pa.addresstype = 'Res'
 and current_date between pa.effectivedate and pa.enddate
 and current_timestamp between pa.createts and pa.endts 

join person_bene_election pbesups
  on pbesups.personid = pe.personid
 and pbesups.benefitelection = 'E'
 and pbesups.selectedoption = 'Y' 
 and pbesups.benefitsubclass in ('2Z')  
 and current_date between pbesups.effectivedate and pbesups.enddate
 and current_timestamp between pbesups.createts and pbesups.endts
  ---exclude future dated terms
 and pbesups.personid not in  (select distinct pbe.personid from person_bene_election pbe
                               join (select pbe.personid, pbe.benefitelection, pbe.benefitcoverageid, pbe.benefitsubclass, pbe.benefitplanid, pbe.personbeneelectionpid, pbe.coverageamount, max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate,RANK() over (partition by pbe.personid order by max(pbe.effectivedate) desc) AS RANK
                                       from person_bene_election pbe 
                                       join person_employment pe on pe.personid = pbe.personid and current_date between pe.effectivedate and pe.enddate and current_timestamp between pe.createts and pe.endts and pe.emplstatus not in ('T','R')
                                      where pbe.benefitsubclass = '2Z' and pbe.benefitelection in ('T','W') and pbe.selectedoption = 'Y' and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate and pbe.effectivedate >= '2019-09-01'
                                        and pbe.personid in (select distinct(personid) from person_bene_election where benefitsubclass in ('2Z')  and selectedoption = 'Y' and benefitelection = 'E' and current_timestamp between createts and endts and current_date between effectivedate and enddate and date_part('year',deductionstartdate) = date_part('year',current_date - interval '1 year'))
                                      group by pbe.personid, pbe.benefitelection, pbe.benefitcoverageid, pbe.benefitsubclass, pbe.benefitplanid, pbe.personbeneelectionpid, pbe.coverageamount)   pbednt on pbednt.personid = pbe.personid and pbednt.RANK = 1           
                               where pbe.benefitelection = 'E' and pbe.selectedoption = 'Y'  and current_date between pbe.effectivedate and pbe.enddate and current_timestamp between pbe.createts and pbe.endts  and pbe.benefitsubclass in ('2Z'))    

left join (select personid, positionid, scheduledhours, schedulefrequency, max(effectivedate) as effectivedate, RANK() OVER (PARTITION BY personid ORDER BY max(effectivedate) DESC) AS RANK
             from pers_pos where effectivedate < enddate and current_timestamp between createts and endts
            group by personid, positionid, scheduledhours, schedulefrequency) pp on pp.personid = pe.personid and pp.rank = 1 
 
left join (select personid, locationid, max(effectivedate) as effectivedate, RANK() OVER (PARTITION BY personid ORDER BY max(effectivedate) DESC) AS RANK
             from person_locations where effectivedate < enddate and current_timestamp between createts and endts
            group by personid, locationid) pl on pl.personid = pp.personid and pl.rank = 1 

left join (select locationid, stateprovincecode, city, locaddrpid, max(effectivedate) as effectivedate, RANK() OVER (PARTITION BY locationid ORDER BY max(effectivedate) DESC) AS RANK
             from location_address where effectivedate < enddate and current_timestamp between createts and endts
            group by locationid, stateprovincecode, city, locaddrpid) la on la.locationid = pl.locationid and la.rank = 1  


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

left join person_compensation pc
  on pc.personid = pi.personid
 and current_date between pc.effectivedate and pc.enddate
 and current_timestamp between pc.createts and pc.endts 
 
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts 
  and pe.emplstatus NOT IN ('T','R')
  AND PE.PERSONID = '762'
  
  UNION
  
select distinct
 pi.personid      
,elu.lastupdatets
,'0' AS dependentid
,'ACTIVE EE SUPC(25)'::varchar(30) as qsource
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
--------------------------------------------------------------------------
---- start dental 11 columns 267 - 329 Based on Coverage Description -----
--------------------------------------------------------------------------
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
,' ' ::char(1) as d_filler_30621
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
,' ' ::char(8) as lt_monthly_benefit_amt
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
,' ' ::char(8) as as_weekly_benefit_amt
,' ' ::char(1) as as_salary_mode
,' ' ::char(7) as as_salary_amount             
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
------------------------------------------------------------------------------            
---- start Supplemental Child Life 25 columns 771 - 833  CHILD(REN) ONLY -----
------------------------------------------------------------------------------  
,case when pbesupc.benefitsubclass = '25' then 'LF' else ' ' end ::char(2) as lf_covcode
,case when pbesupc.benefitsubclass = '25' then to_char(pbesupc.effectivedate,'MMDDYYYY') else ' ' end ::char(8) as lf_cov_start
,case when pbesupc.benefitsubclass = '25' and pe.emplstatus in ('T','R') then to_char(pe.effectivedate,'MMDDYYYY')
      when pbesupc.benefitsubclass = '25' and pbesupc.benefitelection in ('T') then to_char(pbesupc.enddate,'MMDDYYYY') else ' ' end ::char(8) as lf_cov_end
,case when pbesupc.benefitsubclass = '25' then '5923955' else ' ' end ::char(7) as lf_grp_nbr
,case when pbesupc.benefitsubclass = '25' then '0001' else ' ' end ::char(4) as lf_sub_cd
,case when pbesupc.benefitsubclass = '25' then '0001' else ' ' end ::char(4) as lf_branch
,' ' ::char(2) as lf_filler_804_805
----- lf_status Based on Employment Status 
----- R for Retirement
----- A for Active and all others
----- Note: terms will have an A, but will send Benefit End Date in Stop Date field (lf_cov_end)
,case when pbesupc.benefitsubclass = '25' and pe.emplstatus = 'R' then 'R' 
      when pbesupc.benefitsubclass = '25' and pe.emplstatus <> 'R' then 'A' else ' ' end ::char(1) as lf_status
,case when pbesupc.benefitsubclass = '25' then 'C' else ' ' end ::char(1) AS lf_mbrs_covered 
,' ' ::char(10) as lf_filler_808_817
,case when pbesupc.benefitsubclass = '25' then to_char(pbesupc.coverageamount, 'FM00000000') else ' ' end ::char(8) as lf_annual_benefit_amt
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
------------------------------------------------------------------------------            
---- start Supplemental Child AD&D 25 columns 960 - 1022 CHILD(REN) ONLY -----
------------------------------------------------------------------------------  
,case when pbesupc.benefitsubclass = '25' then 'AT' else ' ' end ::char(2) as at_covcode
,case when pbesupc.benefitsubclass = '25' then to_char(pbesupc.effectivedate,'MMDDYYYY') else ' ' end ::char(8) as at_cov_start
,case when pbesupc.benefitsubclass = '25' and pe.emplstatus in ('T','R') then to_char(pe.effectivedate,'MMDDYYYY')
      when pbesupc.benefitsubclass = '25' and pbesupc.benefitsubclass in ('T') then to_char(pbesupc.enddate,'MMDDYYYY') else ' ' end ::char(8) as at_cov_end
,case when pbesupc.benefitsubclass = '25' then '5923955' else ' ' end ::char(7) as at_grp_nbr
,case when pbesupc.benefitsubclass = '25' then '0001' else ' ' end ::char(4) as at_sub_cd
,case when pbesupc.benefitsubclass = '25' then '0001' else ' ' end ::char(4) as at_branch
,' ' ::char(2) as at_filler_993_994
----- at_status Based on Employment Status 
----- R for Retirement
----- A for Active and all others
----- Note: terms will have an A, but will send Benefit End Date in Stop Date field (at_cov_end)
,case when pbesupc.benefitsubclass = '25' and pe.emplstatus = 'R' then 'R' 
      when pbesupc.benefitsubclass = '25' and pe.emplstatus <> 'R' then 'A' else ' ' end ::char(1) as at_status
,case when pbesupc.benefitsubclass = '25' then 'C' else ' ' end ::char(1) AS at_mbrs_covered
,' ' ::char(10) as at_filler_997_1006
,case when pbesupc.benefitsubclass = '25' then to_char(pbesupc.coverageamount, 'FM00000000') else ' ' end ::char(8) as at_annual_benefit_amt
,' ' ::char(8) as at_filler_1015_1022
----------------------------------------------------------------------------            
---- start Vision 14 columns 1279 - 1340 Based on Coverage Description -----
----------------------------------------------------------------------------  
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
--------------------------------------------------------------------------------------
----- start columns 1350 - 1359 Employee Specific Fields for Voluntary Coverages -----
--------------------------------------------------------------------------------------
,case when la.locationid in ('1','14','15','16','22','23','24') then 'HUNTS'
      when la.locationid = '2'  then 'CULLMAN'
      when la.locationid = '3'  then 'JASPER'
      when la.locationid = '4'  then 'BIRM'
      when la.locationid = '5'  then 'TRUSS'
      when la.locationid = '6'  then 'PELHAM'
      when la.locationid = '7'  then 'GADSDEN'
      when la.locationid = '8'  then 'ALBERT'
      when la.locationid = '9'  then 'MONT'
      when la.locationid = '10' then 'AUBURN'
      when la.locationid = '11' then 'ATHENS'
      when la.locationid = '12' then 'CHATTAN'
      when la.locationid = '13' then 'SHEFFI'
      when la.locationid = '19' then 'TUSC' 
      when la.locationid = '21' then 'RING' end ::char(10) as dept_code

from person_identity pi

left join edi.edi_last_update elu on elu.feedid = 'APM_Metlife_DentalVisionLife_Export'

left join person_employment pe 
  on pe.personid = pi.personid 
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts

left join person_identity pie
  on pie.personid = pi.personid
 and pie.identitytype = 'EmpNo'
 and current_timestamp between pie.createts and pie.endts

left join person_address pa 
  on pa.personid = pi.personid
 and pa.addresstype = 'Res'
 and current_date between pa.effectivedate and pa.enddate
 and current_timestamp between pa.createts and pa.endts 

join person_bene_election pbesupc
  on pbesupc.personid = pe.personid
 and pbesupc.benefitelection = 'E'
 and pbesupc.selectedoption = 'Y' 
 and pbesupc.benefitsubclass in ('25')  
 and current_date between pbesupc.effectivedate and pbesupc.enddate
 and current_timestamp between pbesupc.createts and pbesupc.endts
  ---exclude future dated terms
 and pbesupc.personid not in  (select distinct pbe.personid from person_bene_election pbe
                               join (select pbe.personid, pbe.benefitelection, pbe.benefitcoverageid, pbe.benefitsubclass, pbe.benefitplanid, pbe.personbeneelectionpid, pbe.coverageamount, max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate,RANK() over (partition by pbe.personid order by max(pbe.effectivedate) desc) AS RANK
                                       from person_bene_election pbe 
                                       join person_employment pe on pe.personid = pbe.personid and current_date between pe.effectivedate and pe.enddate and current_timestamp between pe.createts and pe.endts and pe.emplstatus not in ('T','R')
                                      where pbe.benefitsubclass = '25' and pbe.benefitelection in ('T','W') and pbe.selectedoption = 'Y' and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate and pbe.effectivedate >= '2019-09-01'
                                        and pbe.personid in (select distinct(personid) from person_bene_election where benefitsubclass in ('25')  and selectedoption = 'Y' and benefitelection = 'E' and current_timestamp between createts and endts and current_date between effectivedate and enddate and date_part('year',deductionstartdate) = date_part('year',current_date - interval '1 year'))
                                      group by pbe.personid, pbe.benefitelection, pbe.benefitcoverageid, pbe.benefitsubclass, pbe.benefitplanid, pbe.personbeneelectionpid, pbe.coverageamount)   pbednt on pbednt.personid = pbe.personid and pbednt.RANK = 1           
                               where pbe.benefitelection = 'E' and pbe.selectedoption = 'Y'  and current_date between pbe.effectivedate and pbe.enddate and current_timestamp between pbe.createts and pbe.endts  and pbe.benefitsubclass in ('25'))   

left join (select personid, positionid, scheduledhours, schedulefrequency, max(effectivedate) as effectivedate, RANK() OVER (PARTITION BY personid ORDER BY max(effectivedate) DESC) AS RANK

             from pers_pos where effectivedate < enddate and current_timestamp between createts and endts
            group by personid, positionid, scheduledhours, schedulefrequency) pp on pp.personid = pe.personid and pp.rank = 1 
 
left join (select personid, locationid, max(effectivedate) as effectivedate, RANK() OVER (PARTITION BY personid ORDER BY max(effectivedate) DESC) AS RANK
             from person_locations where effectivedate < enddate and current_timestamp between createts and endts
            group by personid, locationid) pl on pl.personid = pp.personid and pl.rank = 1 

left join (select locationid, stateprovincecode, city, locaddrpid, max(effectivedate) as effectivedate, RANK() OVER (PARTITION BY locationid ORDER BY max(effectivedate) DESC) AS RANK
             from location_address where effectivedate < enddate and current_timestamp between createts and endts
            group by locationid, stateprovincecode, city, locaddrpid) la on la.locationid = pl.locationid and la.rank = 1  


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

left join person_compensation pc
  on pc.personid = pi.personid
 and current_date between pc.effectivedate and pc.enddate
 and current_timestamp between pc.createts and pc.endts 
 
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts 
  and pe.emplstatus NOT IN ('T','R')
  AND PE.PERSONID = '762'
  
  UNION
  
select distinct
 pi.personid      
,elu.lastupdatets
,'0' AS dependentid
,'ACTIVE EE VSN(14)'::varchar(30) as qsource
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
--------------------------------------------------------------------------
---- start dental 11 columns 267 - 329 Based on Coverage Description -----
--------------------------------------------------------------------------
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
,' ' ::char(1) as d_filler_30621
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
,' ' ::char(8) as lt_monthly_benefit_amt
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
,' ' ::char(8) as as_weekly_benefit_amt
,' ' ::char(1) as as_salary_mode
,' ' ::char(7) as as_salary_amount             
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
------------------------------------------------------------------------------            
---- start Supplemental Child Life 25 columns 771 - 833  CHILD(REN) ONLY -----
------------------------------------------------------------------------------  
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
------------------------------------------------------------------------------            
---- start Supplemental Child AD&D 25 columns 960 - 1022 CHILD(REN) ONLY -----
------------------------------------------------------------------------------  
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
----------------------------------------------------------------------------            
---- start Vision 14 columns 1279 - 1340 Based on Coverage Description -----
----------------------------------------------------------------------------  
,case when pbevsn.benefitsubclass = '14' and pbevsn.benefitcoverageid > '1'then 'VV' else ' ' end ::char(2) as vv_covcode
,case when pbevsn.benefitsubclass = '14' and pbevsn.benefitcoverageid > '1'then to_char(pbevsn.effectivedate,'MMDDYYYY') else ' ' end ::char(8) as vv_cov_start
,case when pbevsn.benefitsubclass = '14' and pbevsn.benefitcoverageid > '1'and pe.emplstatus in ('T','R') then to_char(pe.effectivedate,'MMDDYYYY')
      when pbevsn.benefitsubclass = '14' and pbevsn.benefitcoverageid > '1'and pbevsn.benefitelection in ('T') then to_char(pbevsn.enddate,'MMDDYYYY') else ' ' end ::char(8) as vv_cov_end
,case when pbevsn.benefitsubclass = '14' and pbevsn.benefitcoverageid > '1'then '5923955' else ' ' end ::char(7) as vv_grp_nbr
,case when pbevsn.benefitsubclass = '14' and pbevsn.benefitcoverageid > '1'then '0001' else ' ' end ::char(4) as vv_sub_cd
,case when pbevsn.benefitsubclass = '14' and pbevsn.benefitcoverageid > '1'then '0001' else ' ' end ::char(4) as vv_branch
,' ' ::char(2) as vv_filler_1312_1313
----- vv_status Based on Employment Status 
----- R for Retirement
----- A for Active and all others
----- Note: terms will have an A, but will send Benefit End Date in Stop Date field (vv_cov_end)
,case when pbevsn.benefitsubclass = '14' and pbevsn.benefitcoverageid > '1' and pe.emplstatus = 'R' then 'R' 
      when pbevsn.benefitsubclass = '14' and pbevsn.benefitcoverageid > '1'and pe.emplstatus <> 'R' then 'A' else ' ' end ::char(1) as vv_status
,case when pbevsn.benefitsubclass = '14' and pbevsn.benefitcoverageid > '1'and bcdvsn.benefitcoveragedesc = 'Employee Only' then '1'
      when pbevsn.benefitsubclass = '14' and pbevsn.benefitcoverageid > '1'and bcdvsn.benefitcoveragedesc in ('EE & 1 Dep or More','Employee + Children') then '2' 
      when pbevsn.benefitsubclass = '14' and pbevsn.benefitcoverageid > '1'and bcdvsn.benefitcoveragedesc = 'Employee + Spouse' then '3'
      when pbevsn.benefitsubclass = '14' and pbevsn.benefitcoverageid > '1'and bcdvsn.benefitcoveragedesc in ('EE & Child(ren) + D/P Adult','EE&1+DPAdult &/or DPChild(ren)','EE&2+DPAdult &/or DPChild(ren)','EE&Child(ren) + DP Adult&DP Ch','Family') then '4'
      else ' ' end ::char(1) AS vv_mbrs_covered
,' ' ::char(2) as vv_cancel_rsn
,' ' ::char(23) as vv_filler_1318_1340
--------------------------------------------------------------------------------------
----- start columns 1350 - 1359 Employee Specific Fields for Voluntary Coverages -----
--------------------------------------------------------------------------------------
,case when la.locationid in ('1','14','15','16','22','23','24') then 'HUNTS'
      when la.locationid = '2'  then 'CULLMAN'
      when la.locationid = '3'  then 'JASPER'
      when la.locationid = '4'  then 'BIRM'
      when la.locationid = '5'  then 'TRUSS'
      when la.locationid = '6'  then 'PELHAM'
      when la.locationid = '7'  then 'GADSDEN'
      when la.locationid = '8'  then 'ALBERT'
      when la.locationid = '9'  then 'MONT'
      when la.locationid = '10' then 'AUBURN'
      when la.locationid = '11' then 'ATHENS'
      when la.locationid = '12' then 'CHATTAN'
      when la.locationid = '13' then 'SHEFFI'
      when la.locationid = '19' then 'TUSC' 
      when la.locationid = '21' then 'RING' end ::char(10) as dept_code

from person_identity pi

left join edi.edi_last_update elu on elu.feedid = 'APM_Metlife_DentalVisionLife_Export'

left join person_employment pe 
  on pe.personid = pi.personid 
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts

left join person_identity pie
  on pie.personid = pi.personid
 and pie.identitytype = 'EmpNo'
 and current_timestamp between pie.createts and pie.endts

left join person_address pa 
  on pa.personid = pi.personid
 and pa.addresstype = 'Res'
 and current_date between pa.effectivedate and pa.enddate
 and current_timestamp between pa.createts and pa.endts 

join person_bene_election pbevsn
  on pbevsn.personid = pe.personid
 and pbevsn.benefitelection = 'E'
 and pbevsn.selectedoption = 'Y' 
 and pbevsn.benefitsubclass in ('14')  
 and current_date between pbevsn.effectivedate and pbevsn.enddate
 and current_timestamp between pbevsn.createts and pbevsn.endts
  ---exclude future dated terms
 and pbevsn.personid not in  (select distinct pbe.personid from person_bene_election pbe
                               join (select pbe.personid, pbe.benefitelection, pbe.benefitcoverageid, pbe.benefitsubclass, pbe.benefitplanid, pbe.personbeneelectionpid, pbe.coverageamount, max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate,RANK() over (partition by pbe.personid order by max(pbe.effectivedate) desc) AS RANK
                                       from person_bene_election pbe 
                                       join person_employment pe on pe.personid = pbe.personid and current_date between pe.effectivedate and pe.enddate and current_timestamp between pe.createts and pe.endts and pe.emplstatus not in ('T','R')
                                      where pbe.benefitsubclass = '14' and pbe.benefitelection in ('T','W') and pbe.selectedoption = 'Y' and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate and pbe.effectivedate >= '2019-09-01'
                                        and pbe.personid in (select distinct(personid) from person_bene_election where benefitsubclass in ('14')  and selectedoption = 'Y' and benefitelection = 'E' and current_timestamp between createts and endts and current_date between effectivedate and enddate and date_part('year',deductionstartdate) = date_part('year',current_date - interval '1 year'))
                                      group by pbe.personid, pbe.benefitelection, pbe.benefitcoverageid, pbe.benefitsubclass, pbe.benefitplanid, pbe.personbeneelectionpid, pbe.coverageamount)   pbednt on pbednt.personid = pbe.personid and pbednt.RANK = 1           
                               where pbe.benefitelection = 'E' and pbe.selectedoption = 'Y'  and current_date between pbe.effectivedate and pbe.enddate and current_timestamp between pbe.createts and pbe.endts  and pbe.benefitsubclass in ('14'))  

left join benefit_coverage_desc bcdvsn
  on bcdvsn.benefitcoverageid = pbevsn.benefitcoverageid
 and current_date between bcdvsn.effectivedate and bcdvsn.enddate
 and current_timestamp between bcdvsn.createts and bcdvsn.endts 

left join (select personid, positionid, scheduledhours, schedulefrequency, max(effectivedate) as effectivedate, RANK() OVER (PARTITION BY personid ORDER BY max(effectivedate) DESC) AS RANK
             from pers_pos where effectivedate < enddate and current_timestamp between createts and endts
            group by personid, positionid, scheduledhours, schedulefrequency) pp on pp.personid = pe.personid and pp.rank = 1 
 
left join (select personid, locationid, max(effectivedate) as effectivedate, RANK() OVER (PARTITION BY personid ORDER BY max(effectivedate) DESC) AS RANK
             from person_locations where effectivedate < enddate and current_timestamp between createts and endts
            group by personid, locationid) pl on pl.personid = pp.personid and pl.rank = 1 

left join (select locationid, stateprovincecode, city, locaddrpid, max(effectivedate) as effectivedate, RANK() OVER (PARTITION BY locationid ORDER BY max(effectivedate) DESC) AS RANK
             from location_address where effectivedate < enddate and current_timestamp between createts and endts
            group by locationid, stateprovincecode, city, locaddrpid) la on la.locationid = pl.locationid and la.rank = 1  


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

left join person_compensation pc
  on pc.personid = pi.personid
 and current_date between pc.effectivedate and pc.enddate
 and current_timestamp between pc.createts and pc.endts 
 
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts 
  and pe.emplstatus NOT IN ('T','R')
  AND PE.PERSONID = '762'
  ) active_emp
    
    