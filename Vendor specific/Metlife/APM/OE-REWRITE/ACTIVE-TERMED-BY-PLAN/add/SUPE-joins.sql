select distinct
 pi.personid      
,elu.lastupdatets
,'0' AS dependentid
,'ACTIVE EE SUPE(21)'::varchar(30) as qsource
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
  
  UNION
  
select distinct
 pi.personid 
,elu.lastupdatets 
,'0' AS dependentid
,'TERMED EE SUPE(21)'::varchar(30) as qsource
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
----- ad_status Based on Employment Status 
----- R for Retirement
----- A for Active and all others
----- Note: terms will have an A, but will send Benefit End Date in Stop Date field (ad_cov_end)
,case when pbesupe.benefitsubclass = '21' and pe.emplstatus = 'R' then 'R' 
      when pbesupe.benefitsubclass = '21' and pe.emplstatus <> 'R' then 'A' else ' ' end ::char(1) as ad_status
,case when pbesupe.benefitsubclass = '21' then '1' else ' ' end ::char(1) AS ad_mbrs_covered
,' ' ::char(10) as ad_filler_430_439
,case when pbesupe.benefitsubclass = '21' then to_char(pbesupe.coverageamount, 'FM00000000') else ' ' end ::char(8) as ad_annual_benefit_amt
,case when pbesupe.benefitsubclass = '21' and pc.frequencycode = 'H' then 'H'
      when pbesupe.benefitsubclass = '21' and pc.frequencycode = 'A' then 'A' else ' ' end ::char(1) as ad_salary_mode      
,case when pbesupe.benefitsubclass = '21' and pc.frequencycode = 'H' then to_char(pc.compamount * 100,'FM0000000') 
      when pbesupe.benefitsubclass = '21' then to_char(pc.compamount,'FM0000000')  else ' ' end ::char(7) as ad_salary_amount                   
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
----- op_status Based on Employment Status 
----- R for Retirement
----- A for Active and all others
----- Note: terms will have an A, but will send Benefit End Date in Stop Date field (op_cov_end)
,case when pbesupe.benefitsubclass = '21' and pe.emplstatus = 'R' then 'R' 
      when pbesupe.benefitsubclass = '21' and pe.emplstatus <> 'R' then 'A'else ' ' end ::char(1) as op_status
,case when pbesupe.benefitsubclass = '21' then '1' else ' ' end ::char(1) AS op_mbrs_covered
,' ' ::char(10) as op_filler_682_691
,case when pbesupe.benefitsubclass = '21' then to_char(pbesupe.coverageamount, 'FM00000000') else ' ' end ::char(8) as op_annual_benefit_amt
,case when pbesupe.benefitsubclass = '21' and pc.frequencycode = 'H' then 'H' 
      when pbesupe.benefitsubclass = '21' and pc.frequencycode = 'A' then 'A' else ' ' end ::char(1) as op_salary_mode
,case when pbesupe.benefitsubclass = '21' and pc.frequencycode = 'H' then to_char(pc.compamount * 100,'FM0000000') 
      when pbesupe.benefitsubclass = '21' then to_char(pc.compamount,'FM0000000') else ' ' end ::char(7) as op_salary_amount
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
----- od_status Based on Employment Status 
----- R for Retirement
----- A for Active and all others
----- Note: terms will have an A, but will send Benefit End Date in Stop Date field (od_cov_end)
,case when pbesupe.benefitsubclass = '21' and pe.emplstatus = 'R' then 'R' 
      when pbesupe.benefitsubclass = '21' and pe.emplstatus <> 'R' then 'A' else ' ' end ::char(1) as od_status
,case when pbesupe.benefitsubclass = '21' then '1' else ' ' end ::char(1) AS od_mbrs_covered
,' ' ::char(10) as od_filler_871_880
,case when pbesupe.benefitsubclass = '21' then to_char(pbesupe.coverageamount, 'FM00000000') else ' ' end ::char(8) as od_annual_benefit_amt
,case when pbesupe.benefitsubclass = '21' and pc.frequencycode = 'H' then 'H' 
      when pbesupe.benefitsubclass = '21' and pc.frequencycode = 'A' then 'A' else ' ' end ::char(1) as od_salary_mode
,case when pbesupe.benefitsubclass = '21' and pc.frequencycode = 'H' then to_char(pc.compamount * 100,'FM0000000') 
      when pbesupe.benefitsubclass = '21' then to_char(pc.compamount,'FM0000000') else ' ' end ::char(7) as od_salary_amount  
      
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

join person_bene_election pbe
  on pbe.personid = pe.personid
 and pbe.benefitelection <> 'W'
 and pbe.selectedoption = 'Y' 
 and pbe.benefitsubclass in ('21') 
 and pbe.effectivedate < pbe.enddate
 and current_timestamp between pbe.createts and pbe.endts
 and pbe.personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts 
                         and benefitsubclass in ('21')  and benefitelection = 'E' and selectedoption = 'Y' and effectivedate < enddate) 
 
left join (SELECT personid, benefitsubclass, benefitelection, benefitcoverageid, coverageamount, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate, 
            RANK() OVER (PARTITIon BY personid ORDER BY MAX(effectivedate) ASC) AS RANK
            FROM person_bene_election left join edi.edi_last_update elu on elu.feedid = 'APM_Metlife_DentalVisionLife_Export'
           WHERE effectivedate < enddate  and current_timestamp BETWEEN createts and endts and benefitsubclass in ('21') and benefitelection in ( 'E')  and selectedoption = 'Y' 
             and effectivedate <= elu.lastupdatets GROUP BY personid, benefitsubclass, benefitelection, benefitcoverageid, coverageamount) as pbesupe on pbesupe.personid = pbe.personid and pbesupe.rank = 1   
             

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
 
left join (select personid, compamount, increaseamount, compevent, frequencycode, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate, RANK() OVER (PARTITIon BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_compensation where effectivedate < enddate and current_timestamp between createts and endts
            group by personid, compamount, increaseamount, compevent, frequencycode ) as pc on pc.personid = pe.personid and pc.rank = 1  
 
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  and pe.emplstatus IN ('T','R') 
  and ((pe.effectivedate >= elu.lastupdatets::DATE 
   or (pe.createts > elu.lastupdatets and pe.effectivedate < coalesce(elu.lastupdatets, '2017-01-01')) )
     
   or (pbe.effectivedate >= elu.lastupdatets::DATE 
   or (pbe.createts > elu.lastupdatets and pbe.effectivedate < coalesce(elu.lastupdatets, '2017-01-01')) ))
     
   UNION  

select distinct
 pi.personid      
,elu.lastupdatets
,'0' AS dependentid
,'ACTIVE EE FD TRM SUPE(21) BENEFITS'::varchar(30) as qsource
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
----- ad_status Based on Employment Status 
----- R for Retirement
----- A for Active and all others
----- Note: terms will have an A, but will send Benefit End Date in Stop Date field (ad_cov_end)
,case when pbesupe.benefitsubclass = '21' and pe.emplstatus = 'R' then 'R' 
      when pbesupe.benefitsubclass = '21' and pe.emplstatus <> 'R' then 'A' else ' ' end ::char(1) as ad_status
,case when pbesupe.benefitsubclass = '21' then '1' else ' ' end ::char(1) AS ad_mbrs_covered
,' ' ::char(10) as ad_filler_430_439
,case when pbesupe.benefitsubclass = '21' then to_char(pbesupe.coverageamount, 'FM00000000') else ' ' end ::char(8) as ad_annual_benefit_amt
,case when pbesupe.benefitsubclass = '21' and pc.frequencycode = 'H' then 'H'
      when pbesupe.benefitsubclass = '21' and pc.frequencycode = 'A' then 'A' else ' ' end ::char(1) as ad_salary_mode      
,case when pbesupe.benefitsubclass = '21' and pc.frequencycode = 'H' then to_char(pc.compamount * 100,'FM0000000') 
      when pbesupe.benefitsubclass = '21' then to_char(pc.compamount,'FM0000000')  else ' ' end ::char(7) as ad_salary_amount                  
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
----- op_status Based on Employment Status 
----- R for Retirement
----- A for Active and all others
----- Note: terms will have an A, but will send Benefit End Date in Stop Date field (op_cov_end)
,case when pbesupe.benefitsubclass = '21' and pe.emplstatus = 'R' then 'R' 
      when pbesupe.benefitsubclass = '21' and pe.emplstatus <> 'R' then 'A'else ' ' end ::char(1) as op_status
,case when pbesupe.benefitsubclass = '21' then '1' else ' ' end ::char(1) AS op_mbrs_covered
,' ' ::char(10) as op_filler_682_691
,case when pbesupe.benefitsubclass = '21' then to_char(pbesupe.coverageamount, 'FM00000000') else ' ' end ::char(8) as op_annual_benefit_amt
,case when pbesupe.benefitsubclass = '21' and pc.frequencycode = 'H' then 'H' 
      when pbesupe.benefitsubclass = '21' and pc.frequencycode = 'A' then 'A' else ' ' end ::char(1) as op_salary_mode
,case when pbesupe.benefitsubclass = '21' and pc.frequencycode = 'H' then to_char(pc.compamount * 100,'FM0000000') 
      when pbesupe.benefitsubclass = '21' then to_char(pc.compamount,'FM0000000') else ' ' end ::char(7) as op_salary_amount
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
----- od_status Based on Employment Status 
----- R for Retirement
----- A for Active and all others
----- Note: terms will have an A, but will send Benefit End Date in Stop Date field (od_cov_end)
,case when pbesupe.benefitsubclass = '21' and pe.emplstatus = 'R' then 'R' 
      when pbesupe.benefitsubclass = '21' and pe.emplstatus <> 'R' then 'A' else ' ' end ::char(1) as od_status
,case when pbesupe.benefitsubclass = '21' then '1' else ' ' end ::char(1) AS od_mbrs_covered
,' ' ::char(10) as od_filler_871_880
,case when pbesupe.benefitsubclass = '21' then to_char(pbesupe.coverageamount, 'FM00000000') else ' ' end ::char(8) as od_annual_benefit_amt
,case when pbesupe.benefitsubclass = '21' and pc.frequencycode = 'H' then 'H' 
      when pbesupe.benefitsubclass = '21' and pc.frequencycode = 'A' then 'A' else ' ' end ::char(1) as od_salary_mode
,case when pbesupe.benefitsubclass = '21' and pc.frequencycode = 'H' then to_char(pc.compamount * 100,'FM0000000') 
      when pbesupe.benefitsubclass = '21' then to_char(pc.compamount,'FM0000000') else ' ' end ::char(7) as od_salary_amount         

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

join person_employment pe 
  on pe.personid = pi.personid 
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts

join person_identity pie
  on pie.personid = pi.personid
 and pie.identitytype = 'EmpNo'
 and current_timestamp between pie.createts and pie.endts

join person_address pa 
  on pa.personid = pi.personid
 and pa.addresstype = 'Res'
 and current_date between pa.effectivedate and pa.enddate
 and current_timestamp between pa.createts and pa.endts 

join person_bene_election pbe
  on pbe.personid = pe.personid
 and pbe.benefitelection = 'E'
 and pbe.selectedoption = 'Y' 
 and current_date between pbe.effectivedate and pbe.enddate
 and current_timestamp between pbe.createts and pbe.endts 
 and pbe.benefitsubclass in ('21') 

--------------------------------------------------------------------------
---- start dental 11 columns 267 - 329 Based on Coverage Description -----
--------------------------------------------------------------------------
join (select pbe.personid, pbe.benefitelection, pbe.benefitcoverageid, pbe.benefitsubclass, pbe.benefitplanid, pbe.personbeneelectionpid, pbe.coverageamount, max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate,RANK() over (partition by pbe.personid order by max(pbe.effectivedate) desc) AS RANK
             from person_bene_election pbe 
             join person_employment pe on pe.personid = pbe.personid and current_date between pe.effectivedate and pe.enddate and current_timestamp between pe.createts and pe.endts and pe.emplstatus not in ('T','R')
            where pbe.benefitsubclass = '21' and pbe.benefitelection in ('T','W') and pbe.selectedoption = 'Y' and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate and pbe.effectivedate >= '2019-09-01'
              and pbe.personid in (select distinct(personid) from person_bene_election where benefitsubclass in ('21')  and selectedoption = 'Y' and benefitelection = 'E' and current_timestamp between createts and endts and current_date between effectivedate and enddate and date_part('year',deductionstartdate) = date_part('year',current_date - interval '1 year'))
            group by pbe.personid, pbe.benefitelection, pbe.benefitcoverageid, pbe.benefitsubclass, pbe.benefitplanid, pbe.personbeneelectionpid, pbe.coverageamount) pbesupe on pbesupe.personid = pbe.personid and pbesupe.RANK = 1    

left join (select personid, positionid, scheduledhours, schedulefrequency, max(effectivedate) as effectivedate, RANK() over (partition by personid order by max(effectivedate) desc) AS RANK
             from pers_pos where effectivedate < enddate and current_timestamp between createts and endts
            group by personid, positionid, scheduledhours, schedulefrequency) pp on pp.personid = pe.personid and pp.RANK = 1 
 
left join (select personid, locationid, max(effectivedate) as effectivedate, RANK() over (partition by personid order by max(effectivedate) desc) AS RANK
             from person_locations where effectivedate < enddate and current_timestamp between createts and endts
            group by personid, locationid) pl on pl.personid = pp.personid and pl.RANK = 1 

left join (select locationid, stateprovincecode, city, locaddrpid, max(effectivedate) as effectivedate, RANK() over (partition by locationid order by max(effectivedate) desc) AS RANK
             from location_address where effectivedate < enddate and current_timestamp between createts and endts
            group by locationid, stateprovincecode, city, locaddrpid) la on la.locationid = pl.locationid and la.RANK = 1  


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
   
---,'ACTIVE EE DEP BLIFE(20)'::varchar(30) as qsource
---,'TERMED EE DEP BLIFE(20)'::varchar(30) as qsource
---,'ACTIVE EE TERMED DEP BLIFE (30)'::varchar(30) as qsource
  
ORDER BY PERSONID, TRANSCODE DESC, MEMBER_RELCODE