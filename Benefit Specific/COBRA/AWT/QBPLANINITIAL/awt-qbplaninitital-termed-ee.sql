SELECT  distinct
 pi.personid
,'TERMED EE' ::varchar(30) as qsource
,'[QBPLANINITIAL]' :: varchar(35) as recordtype
,case when bpd.benefitplandesc = 'Medical Flexible Spending' then 'DBI Medical FSA'
      when lc.locationcode = '400' and bpd.benefitplandesc = 'HMO Blue NE Enhanced' then 'BCBS MA Med HMO Blue NE Enhan Val EPOCH Sen Liv'
      when lc.locationcode = '400' and bpd.benefitplandesc = 'Blue Care Elect Preferred' then 'BCBS MA Med PPO Blue Care Pref EPOCH Sen Liv'
      when lc.locationcode = '400' and bpd.benefitplandesc = 'HMO Blue NE Deductible' then 'BCBS MA Med HMO Blue NE $1500 EPOCH Sen Liv'
      when lc.locationcode = '400' and bpd.benefitplandesc = 'Dental Blue' then 'BCBS MA Dental Blue EPOCH Sen Liv'
      when lc.locationcode = '400' and bpd.benefitplandesc = 'Medical Enhanced Value - Domestic Partner' then 'BCBS MA Med HMO Blue NE Enhan Val EPOCH Sen Liv'
      when lc.locationcode = '400' and bpd.benefitplandesc = 'Medical Elect Preferred- Domestic Partner' then 'BCBS MA Med PPO Blue Care Pref EPOCH Sen Liv'
      when lc.locationcode = '400' and bpd.benefitplandesc = 'Medical 1500 Deductible - Domestic Partner' then 'BCBS MA Med HMO Blue NE $1500 EPOCH Sen Liv'
      when lc.locationcode = '400' and bpd.benefitplandesc = 'Dental Domestic Partner' then 'BCBS MA Dental Blue EPOCH Sen Liv'
 
      when lc.locationcode = '804' and bpd.benefitplandesc = 'HMO Blue NE Enhanced' then 'BCBS MA Med HMO Blue NE Enhan Val Br at Westwood'
      when lc.locationcode = '804' and bpd.benefitplandesc = 'Blue Care Elect Preferred' then 'BCBS MA MedPPO Blue Care Pref Br at Westwood'
      when lc.locationcode = '804' and bpd.benefitplandesc = 'HMO Blue NE Deductible' then 'BCBS MA Med HMO Blue NE $1500 Br at Westwood'
      when lc.locationcode = '804' and bpd.benefitplandesc = 'Dental Blue' then 'BCBS MA Dental Blue Br at Westwood'
      when lc.locationcode = '804' and bpd.benefitplandesc = 'Medical Enhanced Value - Domestic Partner' then 'BCBS MA Med HMO Blue NE Enhan Val Br at Westwood'
      when lc.locationcode = '804' and bpd.benefitplandesc = 'Medical Elect Preferred- Domestic Partner' then 'BCBS MA MedPPO Blue Care Pref Br at Westwood'
      when lc.locationcode = '804' and bpd.benefitplandesc = 'Medical 1500 Deductible - Domestic Partner' then 'BCBS MA Med HMO Blue NE $1500 Br at Westwood'
      when lc.locationcode = '804' and bpd.benefitplandesc = 'Dental Domestic Partner' then 'BCBS MA Dental Blue Br at Westwood'

      when lc.locationcode = '805' and bpd.benefitplandesc = 'HMO Blue NE Enhanced' then 'BCBS MA Med HMO Blue NE Enhan Val Br at Mashpee'
      when lc.locationcode = '805' and bpd.benefitplandesc = 'Blue Care Elect Preferred' then 'BCBS MA MedPPO Blue Care Pref Br at Mashpee'
      when lc.locationcode = '805' and bpd.benefitplandesc = 'HMO Blue NE Deductible' then 'BCBS MA Med HMO Blue NE $1500 Br at Mashpee'
      when lc.locationcode = '805' and bpd.benefitplandesc = 'Dental Blue' then 'BCBS MA Dental Blue Br at Mashpee'
      when lc.locationcode = '805' and bpd.benefitplandesc = 'Medical Enhanced Value - Domestic Partner' then 'BCBS MA Med HMO Blue NE Enhan Val Br at Mashpee'
      when lc.locationcode = '805' and bpd.benefitplandesc = 'Medical Elect Preferred- Domestic Partner' then 'BCBS MA MedPPO Blue Care Pref Br at Mashpee'
      when lc.locationcode = '805' and bpd.benefitplandesc = 'Medical 1500 Deductible - Domestic Partner' then 'BCBS MA Med HMO Blue NE $1500 Br at Mashpee'
      when lc.locationcode = '805' and bpd.benefitplandesc = 'Dental Domestic Partner' then 'BCBS MA Dental Blue Br at Mashpee'

      when lc.locationcode = '806' and bpd.benefitplandesc = 'HMO Blue NE Enhanced' then 'BCBS MA Med HMO Blue NE Enhan Val Br at Trumbull'
      when lc.locationcode = '806' and bpd.benefitplandesc = 'Blue Care Elect Preferred' then 'BCBS MA MedPPO Blue Care Pref Br at Trumbull'
      when lc.locationcode = '806' and bpd.benefitplandesc = 'HMO Blue NE Deductible' then 'BCBS MA Med HMO Blue NE $1500 Br at Trumbull'
      when lc.locationcode = '806' and bpd.benefitplandesc = 'Dental Blue' then 'BCBS MA Dental Blue Br at Trumbull'
      when lc.locationcode = '806' and bpd.benefitplandesc = 'Medical Enhanced Value - Domestic Partner' then 'BCBS MA Med HMO Blue NE Enhan Val Br at Trumbull'
      when lc.locationcode = '806' and bpd.benefitplandesc = 'Medical Elect Preferred- Domestic Partner' then 'BCBS MA MedPPO Blue Care Pref Br at Trumbull'
      when lc.locationcode = '806' and bpd.benefitplandesc = 'Medical 1500 Deductible - Domestic Partner' then 'BCBS MA Med HMO Blue NE $1500 Br at Trumbull'
      when lc.locationcode = '806' and bpd.benefitplandesc = 'Dental Domestic Partner' then 'BCBS MA Dental Blue Br at Trumbull'      

      when lc.locationcode = '807' and bpd.benefitplandesc = 'HMO Blue NE Enhanced' then 'BCBS MA Med HMO Blue NE Enhan Val Br at Nashua'
      when lc.locationcode = '807' and bpd.benefitplandesc = 'Blue Care Elect Preferred' then 'BCBS MA MedPPO Blue Care Pref Br at Nashua'
      when lc.locationcode = '807' and bpd.benefitplandesc = 'HMO Blue NE Deductible' then 'BCBS MA Med HMO Blue NE $1500 Br at Nashua'
      when lc.locationcode = '807' and bpd.benefitplandesc = 'Dental Blue' then 'BCBS MA Dental Blue Br at Nashua'
      when lc.locationcode = '807' and bpd.benefitplandesc = 'Medical Enhanced Value - Domestic Partner' then 'BCBS MA Med HMO Blue NE Enhan Val Br at Nashua'
      when lc.locationcode = '807' and bpd.benefitplandesc = 'Medical Elect Preferred- Domestic Partner' then 'BCBS MA MedPPO Blue Care Pref Br at Nashua'
      when lc.locationcode = '807' and bpd.benefitplandesc = 'Medical 1500 Deductible - Domestic Partner' then 'BCBS MA Med HMO Blue NE $1500 Br at Nashua'
      when lc.locationcode = '807' and bpd.benefitplandesc = 'Dental Domestic Partner' then 'BCBS MA Dental Blue Br at Nashua'      
      
      when lc.locationcode = '808' and bpd.benefitplandesc = 'HMO Blue NE Enhanced' then 'BCBS MA Med HMO Blue NE Enhan Val Br at Pembroke'
      when lc.locationcode = '808' and bpd.benefitplandesc = 'Blue Care Elect Preferred' then 'BCBS MA MedPPO Blue Care Pref Br at Pembroke'
      when lc.locationcode = '808' and bpd.benefitplandesc = 'HMO Blue NE Deductible' then 'BCBS MA Med HMO Blue NE $1500 Br at Pembroke'
      when lc.locationcode = '808' and bpd.benefitplandesc = 'Dental Blue' then 'BCBS MA Dental Blue Br at Pembroke'
      when lc.locationcode = '808' and bpd.benefitplandesc = 'Medical Enhanced Value - Domestic Partner' then 'BCBS MA Med HMO Blue NE Enhan Val Br at Pembroke'
      when lc.locationcode = '808' and bpd.benefitplandesc = 'Medical Elect Preferred- Domestic Partner' then 'BCBS MA MedPPO Blue Care Pref Br at Pembroke'
      when lc.locationcode = '808' and bpd.benefitplandesc = 'Medical 1500 Deductible - Domestic Partner' then 'BCBS MA Med HMO Blue NE $1500 Br at Pembroke'
      when lc.locationcode = '808' and bpd.benefitplandesc = 'Dental Domestic Partner' then 'BCBS MA Dental Blue Br at Pembroke'           
          
      when lc.locationcode = '809' and bpd.benefitplandesc = 'HMO Blue NE Enhanced' then 'BCBS MA Med HMO Blue NE Enhan Val Br at Norwalk'
      when lc.locationcode = '809' and bpd.benefitplandesc = 'Blue Care Elect Preferred' then 'BCBS MA MedPPO Blue Care Pref Br at Norwalk'
      when lc.locationcode = '809' and bpd.benefitplandesc = 'HMO Blue NE Deductible' then 'BCBS MA Med HMO Blue NE $1500 Br at Norwalk'
      when lc.locationcode = '809' and bpd.benefitplandesc = 'Dental Blue' then 'BCBS MA Dental Blue Br at Norwalk'
      when lc.locationcode = '809' and bpd.benefitplandesc = 'Medical Enhanced Value - Domestic Partner' then 'BCBS MA Med HMO Blue NE Enhan Val Br at Norwalk'
      when lc.locationcode = '809' and bpd.benefitplandesc = 'Medical Elect Preferred- Domestic Partner' then 'BCBS MA MedPPO Blue Care Pref Br at Norwalk'
      when lc.locationcode = '809' and bpd.benefitplandesc = 'Medical 1500 Deductible - Domestic Partner' then 'BCBS MA Med HMO Blue NE $1500 Br at Norwalk'
      when lc.locationcode = '809' and bpd.benefitplandesc = 'Dental Domestic Partner' then 'BCBS MA Dental Blue Br at Norwalk'    

      when lc.locationcode = '810' and bpd.benefitplandesc = 'HMO Blue NE Enhanced' then 'BCBS MA Med HMO Blue NE Enhan Val The Circle'
      when lc.locationcode = '810' and bpd.benefitplandesc = 'Blue Care Elect Preferred' then 'BCBS MA Med PPO Blue Care Pref The Circle'
      when lc.locationcode = '810' and bpd.benefitplandesc = 'HMO Blue NE Deductible' then 'BCBS MA Med HMO Blue NE $1500 The Circle'
      when lc.locationcode = '810' and bpd.benefitplandesc = 'Dental Blue' then 'BCBS MA Dental Blue The Circle'
      when lc.locationcode = '810' and bpd.benefitplandesc = 'Medical Enhanced Value - Domestic Partner' then 'BCBS MA Med HMO Blue NE Enhan Val The Circle'
      when lc.locationcode = '810' and bpd.benefitplandesc = 'Medical Elect Preferred- Domestic Partner' then 'BCBS MA Med PPO Blue Care Pref The Circle'
      when lc.locationcode = '810' and bpd.benefitplandesc = 'Medical 1500 Deductible - Domestic Partner' then 'BCBS MA Med HMO Blue NE $1500 The Circle'
      when lc.locationcode = '810' and bpd.benefitplandesc = 'Dental Domestic Partner' then 'BCBS MA Dental Blue The Circle'    

      when lc.locationcode = '811' and bpd.benefitplandesc = 'HMO Blue NE Enhanced' then 'BCBS MA Med HMO Blue NE Enhncd Value Br at Sudbury'
      when lc.locationcode = '811' and bpd.benefitplandesc = 'Blue Care Elect Preferred' then 'BCBS MA Med PPO Blue Care Pref Br at Sudbury'
      when lc.locationcode = '811' and bpd.benefitplandesc = 'HMO Blue NE Deductible' then 'BCBS MA Med HMO Blue NE $1500 Br at Sudbury'
      when lc.locationcode = '811' and bpd.benefitplandesc = 'Dental Blue' then 'BCBS MA Dental Blue Br at Sudbury'
      when lc.locationcode = '811' and bpd.benefitplandesc = 'Medical Enhanced Value - Domestic Partner' then 'BCBS MA Med HMO Blue NE Enhncd Value Br at Sudbury'
      when lc.locationcode = '811' and bpd.benefitplandesc = 'Medical Elect Preferred- Domestic Partner' then 'BCBS MA Med PPO Blue Care Pref Br at Sudbury'
      when lc.locationcode = '811' and bpd.benefitplandesc = 'Medical 1500 Deductible - Domestic Partner' then 'BCBS MA Med HMO Blue NE $1500 Br at Sudbury'
      when lc.locationcode = '811' and bpd.benefitplandesc = 'Dental Domestic Partner' then 'BCBS MA Dental Blue Br at Sudbury'  
         
      when lc.locationcode = '812' and bpd.benefitplandesc = 'HMO Blue NE Enhanced' then 'BCBS MA Med HMO Blue NE Enhncd Value Br at Andover'
      when lc.locationcode = '812' and bpd.benefitplandesc = 'Blue Care Elect Preferred' then 'BCBS MA Med PPO Blue Care Pref Br at Andover'
      when lc.locationcode = '812' and bpd.benefitplandesc = 'HMO Blue NE Deductible' then 'BCBS MA Med HMO Blue NE $1500 Br at Andover'
      when lc.locationcode = '812' and bpd.benefitplandesc = 'Dental Blue' then 'BCBS MA Dental Blue Br at Andover'
      when lc.locationcode = '812' and bpd.benefitplandesc = 'Medical Enhanced Value - Domestic Partner' then 'BCBS MA Med HMO Blue NE Enhncd Value Br at Andover'
      when lc.locationcode = '812' and bpd.benefitplandesc = 'Medical Elect Preferred- Domestic Partner' then 'BCBS MA Med PPO Blue Care Pref Br at Andover'
      when lc.locationcode = '812' and bpd.benefitplandesc = 'Medical 1500 Deductible - Domestic Partner' then 'BCBS MA Med HMO Blue NE $1500 Br at Andover'
      when lc.locationcode = '812' and bpd.benefitplandesc = 'Dental Domestic Partner' then 'BCBS MA Dental Blue Br at Andover'  

      when lc.locationcode = '901' and bpd.benefitplandesc = 'HMO Blue NE Enhanced' then 'BCBS MA Med HMO Blue NE Enhan Val Water Wellesley'
      when lc.locationcode = '901' and bpd.benefitplandesc = 'Blue Care Elect Preferred' then 'BCBS MA Med PPO Blue Care Pref Water Wellesley'
      when lc.locationcode = '901' and bpd.benefitplandesc = 'HMO Blue NE Deductible' then 'BCBS MA Med HMO Blue NE $1500 Water Wellesley'
      when lc.locationcode = '901' and bpd.benefitplandesc = 'Dental Blue' then 'BCBS MA Dental Blue Water Wellesley'
      when lc.locationcode = '901' and bpd.benefitplandesc = 'Medical Enhanced Value - Domestic Partner' then 'BCBS MA Med HMO Blue NE Enhan Val Water Wellesley'
      when lc.locationcode = '901' and bpd.benefitplandesc = 'Medical Elect Preferred- Domestic Partner' then 'BCBS MA Med PPO Blue Care Pref Water Wellesley'
      when lc.locationcode = '901' and bpd.benefitplandesc = 'Medical 1500 Deductible - Domestic Partner' then 'BCBS MA Med HMO Blue NE $1500 Water Wellesley'
      when lc.locationcode = '901' and bpd.benefitplandesc = 'Dental Domestic Partner' then 'BCBS MA Dental Blue Water Wellesley'     

      when lc.locationcode = '902' and bpd.benefitplandesc = 'HMO Blue NE Enhanced' then 'BCBS MA Med HMO Blue NE Enhan Val Br at Hingham'
      when lc.locationcode = '902' and bpd.benefitplandesc = 'Blue Care Elect Preferred' then 'BCBS MA Med PPO Blue Care Pref Br at Hingham'
      when lc.locationcode = '902' and bpd.benefitplandesc = 'HMO Blue NE Deductible' then 'BCBS MA Med HMO Blue NE $1500 Br at Hingham'
      when lc.locationcode = '902' and bpd.benefitplandesc = 'Dental Blue' then 'BCBS MA Dental Blue Br at Hingham'
      when lc.locationcode = '902' and bpd.benefitplandesc = 'Medical Enhanced Value - Domestic Partner' then 'BCBS MA Med HMO Blue NE Enhan Val Br at Hingham'
      when lc.locationcode = '902' and bpd.benefitplandesc = 'Medical Elect Preferred- Domestic Partner' then 'BCBS MA Med PPO Blue Care Pref Br at Hingham'
      when lc.locationcode = '902' and bpd.benefitplandesc = 'Medical 1500 Deductible - Domestic Partner' then 'BCBS MA Med HMO Blue NE $1500 Br at Hingham'
      when lc.locationcode = '902' and bpd.benefitplandesc = 'Dental Domestic Partner' then 'BCBS MA Dental Blue Br at Hingham'    

      when lc.locationcode = '903' and bpd.benefitplandesc = 'HMO Blue NE Enhanced' then 'BCBS MA Med HMO Blue NE Enhan Val Br at Westford'
      when lc.locationcode = '903' and bpd.benefitplandesc = 'Blue Care Elect Preferred' then 'BCBS MA Med PPO Blue Care Pref Br at Westford'
      when lc.locationcode = '903' and bpd.benefitplandesc = 'HMO Blue NE Deductible' then 'BCBS MA Med HMO Blue NE $1500 Br at Westford'
      when lc.locationcode = '903' and bpd.benefitplandesc = 'Dental Blue' then 'BCBS MA Dental Blue Br at Westford'
      when lc.locationcode = '903' and bpd.benefitplandesc = 'Medical Enhanced Value - Domestic Partner' then 'BCBS MA Med HMO Blue NE Enhan Val Br at Westford'
      when lc.locationcode = '903' and bpd.benefitplandesc = 'Medical Elect Preferred- Domestic Partner' then 'BCBS MA Med PPO Blue Care Pref Br at Westford'
      when lc.locationcode = '903' and bpd.benefitplandesc = 'Medical 1500 Deductible - Domestic Partner' then 'BCBS MA Med HMO Blue NE $1500 Br at Westford'
      when lc.locationcode = '903' and bpd.benefitplandesc = 'Dental Domestic Partner' then 'BCBS MA Dental Blue Br at Westford'              
      
      ELSE bpd.benefitplandesc end  ::varchar(150) as plan_name    

     
      
,case when bpd.benefitplandesc = 'Medical Flexible Spending' then 'EE'
      when bcd.benefitcoveragedesc in ('Employee Only') then 'EE'
      when bcd.benefitcoveragedesc in ('Employee + Spouse') then ('EE+1')
      when bcd.benefitcoveragedesc in ('Employee + Children') then ('EE+1')
      when bcd.benefitcoveragedesc in ('EE & 1 Dep') and pdr.dependentrelationship in ('SP') then ('EE+1') 
      when bcd.benefitcoveragedesc in ('EE & 1 Dep') and pdr.dependentrelationship <> ('SP') then ('EE+1')
      when bcd.benefitcoveragedesc in ('EE&Child(ren) + DP Adult&DP Ch') then ('EE+Family')
      when bcd.benefitcoveragedesc in ('Family') then ('EE+Family')
      else 'EE' end :: varchar(15) as coverage_level

,' ' ::char(1) as numberofunits
,'3A' ::char(10) as sort_seq


,'0' as dependentid
FROM person_identity pi

LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'AWT_Discovery_COBRA_QB_Export'
JOIN person_employment pe 
  ON pe.personid = pi.personid 
 AND current_date between pe.effectivedate AND pe.enddate 
 AND current_timestamp between pe.createts AND pe.endts

join 

(SELECT personid, benefitsubclass, benefitcoverageid, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate, 
        RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
        FROM person_bene_election pc1
        LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'BEK_ProBenefits_Initial_Notice_Export'
        WHERE enddate > effectivedate 
          AND current_timestamp BETWEEN createts AND endts
          and benefitsubclass in ('10','11','60','61')
          and benefitelection = 'E'
          and selectedoption = 'Y'
        GROUP BY personid ,benefitsubclass,benefitcoverageid) as pbeedt on pbeedt.personid = pe.personid and pbeedt.rank = 1   


JOIN person_bene_election pbe 
  on pbe.personid = pbeedt.personid 
 and pbe.selectedoption = 'Y' 
 and pbe.benefitsubclass in ('10','11','60','61')
 and pbe.benefitplanid <> '132'
 --and pbe.benefitcoverageid = pbeedt.benefitcoverageid
 AND current_date between pbe.effectivedate AND pbe.enddate 
 AND current_timestamp between pbe.createts AND pbe.endts
  -- to be qualified for cobra the emp must have participated in employer's health care plan  
 and pbe.personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts 
                         and benefitsubclass in ('10','11','60','61') and benefitelection = 'E' and selectedoption = 'Y') 

left JOIN benefit_plan_desc bpd  
  on bpd.benefitsubclass = pbe.benefitsubclass
 and bpd.benefitplanid = pbe.benefitplanid
 AND current_date between bpd.effectivedate and bpd.enddate
 AND current_timestamp between bpd.createts and bpd.endts 

left JOIN benefit_coverage_desc bcd 
  on bcd.benefitcoverageid = pbe.benefitcoverageid 
 and current_date between bcd.effectivedate and bcd.enddate
 and current_timestamp between bcd.createts and bcd.endts 
 
left join person_dependent_relationship pdr
  on pdr.personid = pi.personid
 and current_date between pdr.effectivedate and pdr.enddate
 and current_timestamp between pdr.createts and pdr.endts
 AND pdr.dependentrelationship in ('SP','C','S','DP','D') 

left join person_locations pl
  on pl.personid = pi.personid
 and current_date between pl.effectivedate and pl.enddate
 and current_timestamp between pl.createts and pl.endts 
 
left join location_codes lc
  on lc.locationid = pl.locationid
 and current_date between lc.effectivedate and lc.enddate
 and current_timestamp between lc.createts and lc.endts 


WHERE pi.identitytype = 'SSN' 
  and current_timestamp between pi.createts and pi.endts
  and (pe.effectivedate >= elu.lastupdatets::DATE 
   or (pe.createts > elu.lastupdatets and pe.effectivedate < coalesce(elu.lastupdatets, '2017-01-01')) ) 
  and pe.emplstatus = 'T'

union

SELECT  distinct
 pi.personid
,'ACTIVE EE TERMED DEP' ::varchar(30) as qsource
,'[QBPLANINITIAL]' :: varchar(35) as recordtype

,case when bpd.benefitplandesc = 'Medical Flexible Spending' then 'DBI Medical FSA'
      when lc.locationcode = '400' and bpd.benefitplandesc = 'HMO Blue NE Enhanced' then 'BCBS MA Med HMO Blue NE Enhan Val EPOCH Sen Liv'
      when lc.locationcode = '400' and bpd.benefitplandesc = 'Blue Care Elect Preferred' then 'BCBS MA Med PPO Blue Care Pref EPOCH Sen Liv'
      when lc.locationcode = '400' and bpd.benefitplandesc = 'HMO Blue NE Deductible' then 'BCBS MA Med HMO Blue NE $1500 EPOCH Sen Liv'
      when lc.locationcode = '400' and bpd.benefitplandesc = 'Dental Blue' then 'BCBS MA Dental Blue EPOCH Sen Liv'
      when lc.locationcode = '400' and bpd.benefitplandesc = 'Medical Enhanced Value - Domestic Partner' then 'BCBS MA Med HMO Blue NE Enhan Val EPOCH Sen Liv'
      when lc.locationcode = '400' and bpd.benefitplandesc = 'Medical Elect Preferred- Domestic Partner' then 'BCBS MA Med PPO Blue Care Pref EPOCH Sen Liv'
      when lc.locationcode = '400' and bpd.benefitplandesc = 'Medical 1500 Deductible - Domestic Partner' then 'BCBS MA Med HMO Blue NE $1500 EPOCH Sen Liv'
      when lc.locationcode = '400' and bpd.benefitplandesc = 'Dental Domestic Partner' then 'BCBS MA Dental Blue EPOCH Sen Liv'
 
      when lc.locationcode = '804' and bpd.benefitplandesc = 'HMO Blue NE Enhanced' then 'BCBS MA Med HMO Blue NE Enhan Val Br at Westwood'
      when lc.locationcode = '804' and bpd.benefitplandesc = 'Blue Care Elect Preferred' then 'BCBS MA MedPPO Blue Care Pref Br at Westwood'
      when lc.locationcode = '804' and bpd.benefitplandesc = 'HMO Blue NE Deductible' then 'BCBS MA Med HMO Blue NE $1500 Br at Westwood'
      when lc.locationcode = '804' and bpd.benefitplandesc = 'Dental Blue' then 'BCBS MA Dental Blue Br at Westwood'
      when lc.locationcode = '804' and bpd.benefitplandesc = 'Medical Enhanced Value - Domestic Partner' then 'BCBS MA Med HMO Blue NE Enhan Val Br at Westwood'
      when lc.locationcode = '804' and bpd.benefitplandesc = 'Medical Elect Preferred- Domestic Partner' then 'BCBS MA MedPPO Blue Care Pref Br at Westwood'
      when lc.locationcode = '804' and bpd.benefitplandesc = 'Medical 1500 Deductible - Domestic Partner' then 'BCBS MA Med HMO Blue NE $1500 Br at Westwood'
      when lc.locationcode = '804' and bpd.benefitplandesc = 'Dental Domestic Partner' then 'BCBS MA Dental Blue Br at Westwood'

      when lc.locationcode = '805' and bpd.benefitplandesc = 'HMO Blue NE Enhanced' then 'BCBS MA Med HMO Blue NE Enhan Val Br at Mashpee'
      when lc.locationcode = '805' and bpd.benefitplandesc = 'Blue Care Elect Preferred' then 'BCBS MA MedPPO Blue Care Pref Br at Mashpee'
      when lc.locationcode = '805' and bpd.benefitplandesc = 'HMO Blue NE Deductible' then 'BCBS MA Med HMO Blue NE $1500 Br at Mashpee'
      when lc.locationcode = '805' and bpd.benefitplandesc = 'Dental Blue' then 'BCBS MA Dental Blue Br at Mashpee'
      when lc.locationcode = '805' and bpd.benefitplandesc = 'Medical Enhanced Value - Domestic Partner' then 'BCBS MA Med HMO Blue NE Enhan Val Br at Mashpee'
      when lc.locationcode = '805' and bpd.benefitplandesc = 'Medical Elect Preferred- Domestic Partner' then 'BCBS MA MedPPO Blue Care Pref Br at Mashpee'
      when lc.locationcode = '805' and bpd.benefitplandesc = 'Medical 1500 Deductible - Domestic Partner' then 'BCBS MA Med HMO Blue NE $1500 Br at Mashpee'
      when lc.locationcode = '805' and bpd.benefitplandesc = 'Dental Domestic Partner' then 'BCBS MA Dental Blue Br at Mashpee'

      when lc.locationcode = '806' and bpd.benefitplandesc = 'HMO Blue NE Enhanced' then 'BCBS MA Med HMO Blue NE Enhan Val Br at Trumbull'
      when lc.locationcode = '806' and bpd.benefitplandesc = 'Blue Care Elect Preferred' then 'BCBS MA MedPPO Blue Care Pref Br at Trumbull'
      when lc.locationcode = '806' and bpd.benefitplandesc = 'HMO Blue NE Deductible' then 'BCBS MA Med HMO Blue NE $1500 Br at Trumbull'
      when lc.locationcode = '806' and bpd.benefitplandesc = 'Dental Blue' then 'BCBS MA Dental Blue Br at Trumbull'
      when lc.locationcode = '806' and bpd.benefitplandesc = 'Medical Enhanced Value - Domestic Partner' then 'BCBS MA Med HMO Blue NE Enhan Val Br at Trumbull'
      when lc.locationcode = '806' and bpd.benefitplandesc = 'Medical Elect Preferred- Domestic Partner' then 'BCBS MA MedPPO Blue Care Pref Br at Trumbull'
      when lc.locationcode = '806' and bpd.benefitplandesc = 'Medical 1500 Deductible - Domestic Partner' then 'BCBS MA Med HMO Blue NE $1500 Br at Trumbull'
      when lc.locationcode = '806' and bpd.benefitplandesc = 'Dental Domestic Partner' then 'BCBS MA Dental Blue Br at Trumbull'      

      when lc.locationcode = '807' and bpd.benefitplandesc = 'HMO Blue NE Enhanced' then 'BCBS MA Med HMO Blue NE Enhan Val Br at Nashua'
      when lc.locationcode = '807' and bpd.benefitplandesc = 'Blue Care Elect Preferred' then 'BCBS MA MedPPO Blue Care Pref Br at Nashua'
      when lc.locationcode = '807' and bpd.benefitplandesc = 'HMO Blue NE Deductible' then 'BCBS MA Med HMO Blue NE $1500 Br at Nashua'
      when lc.locationcode = '807' and bpd.benefitplandesc = 'Dental Blue' then 'BCBS MA Dental Blue Br at Nashua'
      when lc.locationcode = '807' and bpd.benefitplandesc = 'Medical Enhanced Value - Domestic Partner' then 'BCBS MA Med HMO Blue NE Enhan Val Br at Nashua'
      when lc.locationcode = '807' and bpd.benefitplandesc = 'Medical Elect Preferred- Domestic Partner' then 'BCBS MA MedPPO Blue Care Pref Br at Nashua'
      when lc.locationcode = '807' and bpd.benefitplandesc = 'Medical 1500 Deductible - Domestic Partner' then 'BCBS MA Med HMO Blue NE $1500 Br at Nashua'
      when lc.locationcode = '807' and bpd.benefitplandesc = 'Dental Domestic Partner' then 'BCBS MA Dental Blue Br at Nashua'      
      
      when lc.locationcode = '808' and bpd.benefitplandesc = 'HMO Blue NE Enhanced' then 'BCBS MA Med HMO Blue NE Enhan Val Br at Pembroke'
      when lc.locationcode = '808' and bpd.benefitplandesc = 'Blue Care Elect Preferred' then 'BCBS MA MedPPO Blue Care Pref Br at Pembroke'
      when lc.locationcode = '808' and bpd.benefitplandesc = 'HMO Blue NE Deductible' then 'BCBS MA Med HMO Blue NE $1500 Br at Pembroke'
      when lc.locationcode = '808' and bpd.benefitplandesc = 'Dental Blue' then 'BCBS MA Dental Blue Br at Pembroke'
      when lc.locationcode = '808' and bpd.benefitplandesc = 'Medical Enhanced Value - Domestic Partner' then 'BCBS MA Med HMO Blue NE Enhan Val Br at Pembroke'
      when lc.locationcode = '808' and bpd.benefitplandesc = 'Medical Elect Preferred- Domestic Partner' then 'BCBS MA MedPPO Blue Care Pref Br at Pembroke'
      when lc.locationcode = '808' and bpd.benefitplandesc = 'Medical 1500 Deductible - Domestic Partner' then 'BCBS MA Med HMO Blue NE $1500 Br at Pembroke'
      when lc.locationcode = '808' and bpd.benefitplandesc = 'Dental Domestic Partner' then 'BCBS MA Dental Blue Br at Pembroke'           
          
      when lc.locationcode = '809' and bpd.benefitplandesc = 'HMO Blue NE Enhanced' then 'BCBS MA Med HMO Blue NE Enhan Val Br at Norwalk'
      when lc.locationcode = '809' and bpd.benefitplandesc = 'Blue Care Elect Preferred' then 'BCBS MA MedPPO Blue Care Pref Br at Norwalk'
      when lc.locationcode = '809' and bpd.benefitplandesc = 'HMO Blue NE Deductible' then 'BCBS MA Med HMO Blue NE $1500 Br at Norwalk'
      when lc.locationcode = '809' and bpd.benefitplandesc = 'Dental Blue' then 'BCBS MA Dental Blue Br at Norwalk'
      when lc.locationcode = '809' and bpd.benefitplandesc = 'Medical Enhanced Value - Domestic Partner' then 'BCBS MA Med HMO Blue NE Enhan Val Br at Norwalk'
      when lc.locationcode = '809' and bpd.benefitplandesc = 'Medical Elect Preferred- Domestic Partner' then 'BCBS MA MedPPO Blue Care Pref Br at Norwalk'
      when lc.locationcode = '809' and bpd.benefitplandesc = 'Medical 1500 Deductible - Domestic Partner' then 'BCBS MA Med HMO Blue NE $1500 Br at Norwalk'
      when lc.locationcode = '809' and bpd.benefitplandesc = 'Dental Domestic Partner' then 'BCBS MA Dental Blue Br at Norwalk'    

      when lc.locationcode = '810' and bpd.benefitplandesc = 'HMO Blue NE Enhanced' then 'BCBS MA Med HMO Blue NE Enhan Val The Circle'
      when lc.locationcode = '810' and bpd.benefitplandesc = 'Blue Care Elect Preferred' then 'BCBS MA Med PPO Blue Care Pref The Circle'
      when lc.locationcode = '810' and bpd.benefitplandesc = 'HMO Blue NE Deductible' then 'BCBS MA Med HMO Blue NE $1500 The Circle'
      when lc.locationcode = '810' and bpd.benefitplandesc = 'Dental Blue' then 'BCBS MA Dental Blue The Circle'
      when lc.locationcode = '810' and bpd.benefitplandesc = 'Medical Enhanced Value - Domestic Partner' then 'BCBS MA Med HMO Blue NE Enhan Val The Circle'
      when lc.locationcode = '810' and bpd.benefitplandesc = 'Medical Elect Preferred- Domestic Partner' then 'BCBS MA Med PPO Blue Care Pref The Circle'
      when lc.locationcode = '810' and bpd.benefitplandesc = 'Medical 1500 Deductible - Domestic Partner' then 'BCBS MA Med HMO Blue NE $1500 The Circle'
      when lc.locationcode = '810' and bpd.benefitplandesc = 'Dental Domestic Partner' then 'BCBS MA Dental Blue The Circle'    

      when lc.locationcode = '811' and bpd.benefitplandesc = 'HMO Blue NE Enhanced' then 'BCBS MA Med HMO Blue NE Enhncd Value Br at Sudbury'
      when lc.locationcode = '811' and bpd.benefitplandesc = 'Blue Care Elect Preferred' then 'BCBS MA Med PPO Blue Care Pref Br at Sudbury'
      when lc.locationcode = '811' and bpd.benefitplandesc = 'HMO Blue NE Deductible' then 'BCBS MA Med HMO Blue NE $1500 Br at Sudbury'
      when lc.locationcode = '811' and bpd.benefitplandesc = 'Dental Blue' then 'BCBS MA Dental Blue Br at Sudbury'
      when lc.locationcode = '811' and bpd.benefitplandesc = 'Medical Enhanced Value - Domestic Partner' then 'BCBS MA Med HMO Blue NE Enhncd Value Br at Sudbury'
      when lc.locationcode = '811' and bpd.benefitplandesc = 'Medical Elect Preferred- Domestic Partner' then 'BCBS MA Med PPO Blue Care Pref Br at Sudbury'
      when lc.locationcode = '811' and bpd.benefitplandesc = 'Medical 1500 Deductible - Domestic Partner' then 'BCBS MA Med HMO Blue NE $1500 Br at Sudbury'
      when lc.locationcode = '811' and bpd.benefitplandesc = 'Dental Domestic Partner' then 'BCBS MA Dental Blue Br at Sudbury'  
         
      when lc.locationcode = '812' and bpd.benefitplandesc = 'HMO Blue NE Enhanced' then 'BCBS MA Med HMO Blue NE Enhncd Value Br at Andover'
      when lc.locationcode = '812' and bpd.benefitplandesc = 'Blue Care Elect Preferred' then 'BCBS MA Med PPO Blue Care Pref Br at Andover'
      when lc.locationcode = '812' and bpd.benefitplandesc = 'HMO Blue NE Deductible' then 'BCBS MA Med HMO Blue NE $1500 Br at Andover'
      when lc.locationcode = '812' and bpd.benefitplandesc = 'Dental Blue' then 'BCBS MA Dental Blue Br at Andover'
      when lc.locationcode = '812' and bpd.benefitplandesc = 'Medical Enhanced Value - Domestic Partner' then 'BCBS MA Med HMO Blue NE Enhncd Value Br at Andover'
      when lc.locationcode = '812' and bpd.benefitplandesc = 'Medical Elect Preferred- Domestic Partner' then 'BCBS MA Med PPO Blue Care Pref Br at Andover'
      when lc.locationcode = '812' and bpd.benefitplandesc = 'Medical 1500 Deductible - Domestic Partner' then 'BCBS MA Med HMO Blue NE $1500 Br at Andover'
      when lc.locationcode = '812' and bpd.benefitplandesc = 'Dental Domestic Partner' then 'BCBS MA Dental Blue Br at Andover'  

      when lc.locationcode = '901' and bpd.benefitplandesc = 'HMO Blue NE Enhanced' then 'BCBS MA Med HMO Blue NE Enhan Val Water Wellesley'
      when lc.locationcode = '901' and bpd.benefitplandesc = 'Blue Care Elect Preferred' then 'BCBS MA Med PPO Blue Care Pref Water Wellesley'
      when lc.locationcode = '901' and bpd.benefitplandesc = 'HMO Blue NE Deductible' then 'BCBS MA Med HMO Blue NE $1500 Water Wellesley'
      when lc.locationcode = '901' and bpd.benefitplandesc = 'Dental Blue' then 'BCBS MA Dental Blue Water Wellesley'
      when lc.locationcode = '901' and bpd.benefitplandesc = 'Medical Enhanced Value - Domestic Partner' then 'BCBS MA Med HMO Blue NE Enhan Val Water Wellesley'
      when lc.locationcode = '901' and bpd.benefitplandesc = 'Medical Elect Preferred- Domestic Partner' then 'BCBS MA Med PPO Blue Care Pref Water Wellesley'
      when lc.locationcode = '901' and bpd.benefitplandesc = 'Medical 1500 Deductible - Domestic Partner' then 'BCBS MA Med HMO Blue NE $1500 Water Wellesley'
      when lc.locationcode = '901' and bpd.benefitplandesc = 'Dental Domestic Partner' then 'BCBS MA Dental Blue Water Wellesley'     

      when lc.locationcode = '902' and bpd.benefitplandesc = 'HMO Blue NE Enhanced' then 'BCBS MA Med HMO Blue NE Enhan Val Br at Hingham'
      when lc.locationcode = '902' and bpd.benefitplandesc = 'Blue Care Elect Preferred' then 'BCBS MA Med PPO Blue Care Pref Br at Hingham'
      when lc.locationcode = '902' and bpd.benefitplandesc = 'HMO Blue NE Deductible' then 'BCBS MA Med HMO Blue NE $1500 Br at Hingham'
      when lc.locationcode = '902' and bpd.benefitplandesc = 'Dental Blue' then 'BCBS MA Dental Blue Br at Hingham'
      when lc.locationcode = '902' and bpd.benefitplandesc = 'Medical Enhanced Value - Domestic Partner' then 'BCBS MA Med HMO Blue NE Enhan Val Br at Hingham'
      when lc.locationcode = '902' and bpd.benefitplandesc = 'Medical Elect Preferred- Domestic Partner' then 'BCBS MA Med PPO Blue Care Pref Br at Hingham'
      when lc.locationcode = '902' and bpd.benefitplandesc = 'Medical 1500 Deductible - Domestic Partner' then 'BCBS MA Med HMO Blue NE $1500 Br at Hingham'
      when lc.locationcode = '902' and bpd.benefitplandesc = 'Dental Domestic Partner' then 'BCBS MA Dental Blue Br at Hingham'    

      when lc.locationcode = '903' and bpd.benefitplandesc = 'HMO Blue NE Enhanced' then 'BCBS MA Med HMO Blue NE Enhan Val Br at Westford'
      when lc.locationcode = '903' and bpd.benefitplandesc = 'Blue Care Elect Preferred' then 'BCBS MA Med PPO Blue Care Pref Br at Westford'
      when lc.locationcode = '903' and bpd.benefitplandesc = 'HMO Blue NE Deductible' then 'BCBS MA Med HMO Blue NE $1500 Br at Westford'
      when lc.locationcode = '903' and bpd.benefitplandesc = 'Dental Blue' then 'BCBS MA Dental Blue Br at Westford'
      when lc.locationcode = '903' and bpd.benefitplandesc = 'Medical Enhanced Value - Domestic Partner' then 'BCBS MA Med HMO Blue NE Enhan Val Br at Westford'
      when lc.locationcode = '903' and bpd.benefitplandesc = 'Medical Elect Preferred- Domestic Partner' then 'BCBS MA Med PPO Blue Care Pref Br at Westford'
      when lc.locationcode = '903' and bpd.benefitplandesc = 'Medical 1500 Deductible - Domestic Partner' then 'BCBS MA Med HMO Blue NE $1500 Br at Westford'
      when lc.locationcode = '903' and bpd.benefitplandesc = 'Dental Domestic Partner' then 'BCBS MA Dental Blue Br at Westford'              
      
      ELSE bpd.benefitplandesc end  ::varchar(150) as plan_name    

     
      
,'EE'::varchar(15) as coverage_level

,' ' ::char(1) as numberofunits
,'3A' ::char(10) as sort_seq


,'0' as dependentid
FROM person_identity pi

LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'AWT_Discovery_COBRA_QB_Export'


JOIN person_employment pe 
  ON pe.personid = pi.personid 
 AND current_date between pe.effectivedate AND pe.enddate 
 AND current_timestamp between pe.createts AND pe.endts

left join person_maritalstatus pm
  on pm.personid = pi.personid
 and current_date between pm.effectivedate and pm.enddate
 and current_timestamp between pm.createts and pm.endts 

JOIN person_bene_election pbe 
  on pbe.personid = pe.personid 
 and pbe.selectedoption = 'Y' 
 and pbe.benefitelection = 'E'
 and pbe.benefitplanid <> '132'
 and pbe.benefitsubclass in ('10','11','60','61')
 and current_date between pbe.effectivedate and pbe.enddate 
 and current_timestamp between pbe.createts and pbe.endts
  -- to be qualified for cobra the emp must have participated in employer's health care plan  
 and pbe.personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts 
                         and benefitsubclass in ('10','11','60','61') and benefitelection = 'E' and selectedoption = 'Y' and effectivedate < enddate) 

JOIN benefit_plan_desc bpd  
  on bpd.benefitsubclass = pbe.benefitsubclass
 and bpd.benefitplanid = pbe.benefitplanid
 AND current_date between bpd.effectivedate and bpd.enddate
 AND current_timestamp between bpd.createts and bpd.endts 

left JOIN benefit_coverage_desc bcd 
  on bcd.benefitcoverageid = pbe.benefitcoverageid 
 and current_date between bcd.effectivedate and bcd.enddate
 and current_timestamp between bcd.createts and bcd.endts 


join person_dependent_relationship pdr
  on pdr.personid = pe.personid
 and pdr.dependentrelationship in ('S','D','C','SP','DP')
 and current_date between pdr.effectivedate and pdr.enddate
 and current_timestamp between pdr.createts and pdr.endts

join dependent_enrollment de
  on de.dependentid = pdr.dependentid
 and de.benefitsubclass = pbe.benefitsubclass
 and de.personid = pi.personid
 --and current_date between de.effectivedate and de.enddate
 and current_timestamp between de.createts and de.endts
--- yes I'm hardcoding this on purpose this is the earliest day I need to go back to get termed dependents for Regina 
 --and de.enddate >= '2018-01-01' 
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
     and pbe.benefitsubclass in ('10','11','60','61')
     and pbe.selectedoption = 'Y'
     and current_date between pbe.effectivedate and pbe.enddate
     and current_timestamp between pbe.createts and pbe.endts     
   where current_timestamp between de.createts and de.endts
    and de.benefitsubclass in ('10','11','60','61')
    and pdr.dependentrelationship in ('S','D','C','SP','DP')
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
       and de.benefitsubclass in ('10','11','60','61')
       and pdr.dependentrelationship in ('S','D','C','SP','DP')
   )
) 


left join person_locations pl
  on pl.personid = pi.personid
 and current_date between pl.effectivedate and pl.enddate
 and current_timestamp between pl.createts and pl.endts 
 
left join location_codes lc
  on lc.locationid = pl.locationid
 and current_date between lc.effectivedate and lc.enddate
 and current_timestamp between lc.createts and lc.endts 
 
WHERE pi.identitytype = 'SSN' 
  and current_timestamp between pi.createts and pi.endts
  and pe.emplstatus = 'A' 
--  and (de.effectivedate >= elu.lastupdatets::DATE 
  -- or (de.createts > elu.lastupdatets and de.effectivedate < coalesce(elu.lastupdatets, '2017-01-01')) ) 

order by 1, sort_seq