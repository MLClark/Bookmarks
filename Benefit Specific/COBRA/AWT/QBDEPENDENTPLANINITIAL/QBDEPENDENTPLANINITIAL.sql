SELECT distinct  
 pi.personid
,pdr.dependentid
,'DEPENDENT TERMED EE' ::varchar(30) as qsource
------- don't send dependent row for termed dep of active employee
--,pbe.benefitplanid 
,'[QBDEPENDENTPLANINITIAL]' :: varchar(35) as recordtype
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

      when lc.locationcode = '902' and bpd.benefitplandesc = 'HMO Blue NE Enhanced' then 'BCBS MA Med HMO Blue NE Enhncd Value Br at Hingham'
      when lc.locationcode = '902' and bpd.benefitplandesc = 'Blue Care Elect Preferred' then 'BCBS MA Med PPO Blue Care Pref Br at Hingham'
      when lc.locationcode = '902' and bpd.benefitplandesc = 'HMO Blue NE Deductible' then 'BCBS MA Med HMO Blue NE $1500 Br at Hingham'
      when lc.locationcode = '902' and bpd.benefitplandesc = 'Dental Blue' then 'BCBS MA Dental Blue Br at Hingham'
      when lc.locationcode = '902' and bpd.benefitplandesc = 'Medical Enhanced Value - Domestic Partner' then 'BCBS MA Med HMO Blue NE Enhncd Value Br at Hingham'
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
  
,'4'||pdr.dependentid||'B' ::char(10) as sort_seq

FROM person_identity pi

LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'AWT_Discovery_COBRA_QB_Export'

JOIN person_employment pe 
  ON pe.personid = pi.personid 
 AND current_date between pe.effectivedate AND pe.enddate 
 AND current_timestamp between pe.createts AND pe.endts

JOIN person_bene_election pbe 
  on pbe.personid = pi.personid 
 and pbe.selectedoption = 'Y' 
 and pbe.benefitsubclass in ('10','11')
 AND current_date between pbe.effectivedate AND pbe.enddate 
 AND current_timestamp between pbe.createts AND pbe.endts
  -- to be qualified for cobra the emp must have participated in employer's health care plan  
 and pbe.personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts 
                         and benefitsubclass in ('10','11') and benefitelection = 'E' and selectedoption = 'Y') 

join person_dependent_relationship pdr
  on pdr.personid = pi.personid
 and current_date between pdr.effectivedate and pdr.enddate
 and current_timestamp between pdr.createts and pdr.endts
 AND pdr.dependentrelationship in ('SP','C','S','DP','D')
 
 -- select * from dependent_enrollment where personid = '6094';
JOIN dependent_enrollment de
  on de.personid = pdr.personid
 and de.dependentid = pdr.dependentid
 AND de.selectedoption = 'Y'
 and de.benefitsubclass = pbe.benefitsubclass
 --and current_date between de.effectivedate and de.enddate
 and current_timestamp between de.createts and de.endts

LEFT JOIN person_identity pid
  ON pid.personid = pdr.dependentid
 AND pid.identitytype = 'SSN'::bpchar 
 and current_timestamp between pid.createts and pid.endts

JOIN benefit_plan_desc bpd  
  on bpd.benefitsubclass = pbe.benefitsubclass
 and bpd.benefitplanid = pbe.benefitplanid
 AND current_date between bpd.effectivedate and bpd.enddate
 AND current_timestamp between bpd.createts and bpd.endts 

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
  and pe.emplstatus = 'T' and pe.empleventdetcode <> 'Death'
  and date_part('year',pbe.planyearenddate) = date_part('year',current_date)
  
  
  UNION
  
SELECT distinct  
 pi.personid
,pdr.dependentid
,'DEPENDENT EE DEATH' ::varchar(30) as qsource
------- don't send dependent row for termed dep of active employee
--,pbe.benefitplanid 
,'[QBDEPENDENTPLANINITIAL]' :: varchar(35) as recordtype
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

      when lc.locationcode = '902' and bpd.benefitplandesc = 'HMO Blue NE Enhanced' then 'BCBS MA Med HMO Blue NE Enhncd Value Br at Hingham'
      when lc.locationcode = '902' and bpd.benefitplandesc = 'Blue Care Elect Preferred' then 'BCBS MA Med PPO Blue Care Pref Br at Hingham'
      when lc.locationcode = '902' and bpd.benefitplandesc = 'HMO Blue NE Deductible' then 'BCBS MA Med HMO Blue NE $1500 Br at Hingham'
      when lc.locationcode = '902' and bpd.benefitplandesc = 'Dental Blue' then 'BCBS MA Dental Blue Br at Hingham'
      when lc.locationcode = '902' and bpd.benefitplandesc = 'Medical Enhanced Value - Domestic Partner' then 'BCBS MA Med HMO Blue NE Enhncd Value Br at Hingham'
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
  
,'4'||pdr.dependentid||'B' ::char(10) as sort_seq

FROM person_identity pi

LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'AWT_Discovery_COBRA_QB_Export'

JOIN person_employment pe 
  ON pe.personid = pi.personid 
 AND current_date between pe.effectivedate AND pe.enddate 
 AND current_timestamp between pe.createts AND pe.endts

JOIN person_bene_election pbe 
  on pbe.personid = pi.personid 
 and pbe.selectedoption = 'Y' 
 and pbe.benefitsubclass in ('10','11')
 AND current_date between pbe.effectivedate AND pbe.enddate 
 AND current_timestamp between pbe.createts AND pbe.endts
  -- to be qualified for cobra the emp must have participated in employer's health care plan  
 and pbe.personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts 
                         and benefitsubclass in ('10','11') and benefitelection = 'E' and selectedoption = 'Y') 

join person_dependent_relationship pdr
  on pdr.personid = pi.personid
 and current_date between pdr.effectivedate and pdr.enddate
 and current_timestamp between pdr.createts and pdr.endts
 AND pdr.dependentrelationship in ('SP','C','S','DP','D')
 
 -- select * from dependent_enrollment where personid = '6094';
JOIN dependent_enrollment de
  on de.personid = pdr.personid
 and de.dependentid = pdr.dependentid
 AND de.selectedoption = 'Y'
 and de.benefitsubclass = pbe.benefitsubclass
 --and current_date between de.effectivedate and de.enddate
 and current_timestamp between de.createts and de.endts

LEFT JOIN person_identity pid
  ON pid.personid = pdr.dependentid
 AND pid.identitytype = 'SSN'::bpchar 
 and current_timestamp between pid.createts and pid.endts

JOIN benefit_plan_desc bpd  
  on bpd.benefitsubclass = pbe.benefitsubclass
 and bpd.benefitplanid = pbe.benefitplanid
 AND current_date between bpd.effectivedate and bpd.enddate
 AND current_timestamp between bpd.createts and bpd.endts 

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
  and pe.emplstatus = 'T' and pe.empleventdetcode = 'Death' and pdr.dependentrelationship <> ('SP')
  and date_part('year',pbe.planyearenddate) = date_part('year',current_date)  


order by 1,2