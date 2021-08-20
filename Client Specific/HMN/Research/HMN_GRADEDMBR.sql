       SELECT distinct 
         sgrdeptmbr.personid
        ,sgrdeptmbr.earningscode
        ,sgrdeptmbr.positionid
    --    ,sgr.edtcode
        ,sgrdeptmbr.salarygraderegion
     --   ,sgr.grade
        ,sgrdeptmbr.salarygradedesc
        ,sgrdeptmbr.positiontitle
        ,sgrdeptmbr.jobcode
        ,sgrdeptmbr.compamount
        ,sgrdeptmbr.midpoint 
        ,sgrdeptmbr.annualsalarymax
        ,sgrdeptmbr.annualsalarymin
        ,sgrdeptmbr.locationdescription
        ,sgrdeptmbr.locationCode
        ,CASE
               WHEN sgrdeptmbr.midpoint IS NOT NULL AND sgrdeptmbr.midpoint > 0::numeric AND (sgrdeptmbr.annualsalarymax - sgrdeptmbr.annualsalarymin) > 0::numeric THEN
               CASE
                   WHEN sgrdeptmbr.companyparametervalue IS NOT NULL 
                   THEN ((sgrdeptmbr.annualcompensation / sgrdeptmbr.partialpercent - sgrdeptmbr.annualsalarymin)::numeric(15,4) / (sgrdeptmbr.annualsalarymax - sgrdeptmbr.annualsalarymin)::numeric(15,4))::numeric(15,4)
                   ELSE (sgrdeptmbr.annualcompensation / sgrdeptmbr.partialpercent / sgrdeptmbr.midpoint)::numeric(15,4)
               END
               ELSE 0.00000
           END AS percent_in_range    
         ,sgrdeptmbr.effectivedate    
         ,sgrdeptmbr.increaseamount
         ,sgrdeptmbr.compevent
         ,sgrdeptmbr.prev_compamount   
         ,sgrdeptmbr.position_effectivedate  
         ,TRUNC(sgrdeptmbr.hourly_rate,2) AS HOURLY_RATE
         ,sgrdeptmbr.orgcode
         ,sgrdeptmbr.organizationid    
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
        
      from pers_pos pp
      
      join person_compensation pc
        on pc.personid = pp.personid
       and current_date between pc.effectivedate and pc.enddate
       and current_timestamp between pc.createts and pc.endts
      
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
      
      JOIN location_codes lc 
        ON lc.salarygraderegion = sgr.salarygraderegion 
       AND current_date between lc.effectivedate AND lc.enddate 
       AND current_timestamp between lc.createts AND lc.endts   
      
      LEFT JOIN company_parameters cp 
        ON cp.companyparametername = 'PIRB'::bpchar 
       AND cp.companyparametervalue::text = 'MIN'::text  
      
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
          --select * from pers_pos where personid = '63747';
         join pos_org_rel porb 
           ON porb.positionid = PP.positionid 
          AND porb.posorgreltype = 'Member' 
          and current_timestamp between porb.createts and porb.endts
          and porb.organizationid = 
              (select max(organizationid) 
                 from pos_org_rel x
                where x.positionid = pp.positionid
                  and x.posorgreltype = 'Member'
                  and current_date between x.effectivedate and x.enddate
                  and current_timestamp between x.createts and x.endts)
          -- select * from pos_org_rel where positionid = '404830'

         
         join organization_code oc_cc
           ON oc_cc.organizationid = porb.organizationid
          AND oc_cc.organizationtype = 'Dept'
          and current_timestamp between oc_cc.createts and oc_cc.endts 
          and oc_cc.effectivedate - interval '1 day' <> oc_cc.enddate                       
          --- select * from organization_code where organizationid = '1470'
          
          
          join person_employment pe
           on pe.personid = pi.personid
          and current_date between pe.effectivedate and pe.enddate
          and current_timestamp between pe.createts and pe.endts
          and pe.emplstatus = 'A'   
                           
          
         where pi.identitytype = 'SSN'
           and current_timestamp between pi.createts and pi.endts                      
        --   and pi.personid in ('63747')
      ) porb 
       on porb.personid = pp.personid
      and porb.positionid = pp.positionid

                        
      where current_date between pp.effectivedate and pp.enddate
      and current_timestamp between pp.createts and pp.endts
     
      
   --   and pp.personid = '63747'
     ) sgrdeptmbr