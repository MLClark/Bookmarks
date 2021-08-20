select DISTINCT personid 

, CASE WHEN  benefitsubclass = '20'  THEN 'Basic Life'  -- Basic Life
       WHEN  benefitsubclass = '24'  THEN 'Opt Sp AD&D' -- Opt Spouse AD&D
       WHEN  benefitsubclass = '2Z'  THEN 'Opt Sp Life' -- Opt Spouse Life
       WHEN  benefitsubclass = '25'  THEN 'Child'       -- Child Life
       WHEN  benefitsubclass = '27'  THEN 'Opt Emp AD&D' -- Opt Employee AD&D
       WHEN  benefitsubclass = '21'  THEN 'Opt Emp Life' -- Opt Employee Life
       WHEN  benefitsubclass = '30'  THEN 'STD'          -- STD
       WHEN  benefitsubclass = '31'  THEN 'LTD'          -- LTD
       when  benefitsubclass = '2SA' then 'Opt Sp AD&D 25K'   -- OptADDSP25  AD&D Opt Spouse 25K                 
       when  benefitsubclass = '2SL' then 'Opt Sp Life 25K'   -- Optional Life Sp 25k Voluntary Life - Spouse 25k
       when  benefitsubclass = '2EA' then 'Opt Emp AD&D 25K'  -- OptADD25k  Employee Vol ADD 25K                
       when  benefitsubclass = '2EL' then 'Opt Emp Life 25K'  -- Optional Life 25k    Employee Vol Life 25K    
        END AS lifeplan

,coverageamount


FROM person_bene_election

WHERE benefitsubclass in ('20', '24', '2Z', '25', '27', '21', '30', '31','2SA','2SL','2EA','2EL')
  AND ? BETWEEN effectivedate AND enddate
  AND current_timestamp BETWEEN createts AND endts
  and benefitelection = 'E'
order by personid, lifeplan
