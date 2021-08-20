       SELECT distinct 
         sgr.personid
        ,sgr.earningscode
        ,sgr.positionid
    --    ,sgr.edtcode
        ,sgr.salarygraderegion
     --   ,sgr.grade
        ,sgr.salarygradedesc
        ,sgr.positiontitle
        ,sgr.jobcode
        ,sgr.compamount
        ,sgr.midpoint 
        ,sgr.annualsalarymax
        ,sgr.annualsalarymin
        ,sgr.locationdescription
        ,sgr.locationCode
        ,CASE
               WHEN sgr.midpoint IS NOT NULL AND sgr.midpoint > 0::numeric AND (sgr.annualsalarymax - sgr.annualsalarymin) > 0::numeric THEN
               CASE
                   WHEN sgr.companyparametervalue IS NOT NULL 
                   THEN ((sgr.annualcompensation / sgr.partialpercent - sgr.annualsalarymin)::numeric(15,4) / (sgr.annualsalarymax - sgr.annualsalarymin)::numeric(15,4))::numeric(15,4)
                   ELSE (sgr.annualcompensation / sgr.partialpercent / sgr.midpoint)::numeric(15,4)
               END
               ELSE 0.00000
           END AS percent_in_range  
         ,sgr.effectivedate      
         ,sgr.increaseamount   
         ,sgr.compevent     
         ,sgr.prev_compamount 
         ,sgr.position_effectivedate
         ,TRUNC(sgr.hourly_rate,2) AS HOURLY_RATE
         ,sgr.orgcode
         ,sgr.organizationid
          
         FROM ( SELECT distinct 
                 --  sgr.edtcode
                   pc.earningscode
                  ,sgr.salarygraderegion
                  --,sgr.grade
                  ,sg.salarygradedesc
                  ,pp.personid
                  ,pp.positionid
                  ,pd.positiontitle
                  ,jd.jobcode
                  ,pc.compamount
                  ,lc.locationdescription
                  ,lc.locationCode
                  ,(sgr.salaryminimum * fcsg.annualfactor)::numeric(15,4) AS annualsalarymin
                  ,(sgr.salarymaximum * fcsg.annualfactor)::numeric(15,4) AS annualsalarymax
                  ,(sgr.salaryminimum * fcsg.annualfactor)::numeric(15,4) + (((sgr.salarymaximum * fcsg.annualfactor)::numeric(15,4) - (sgr.salaryminimum * fcsg.annualfactor)::numeric(15,4)) / 2.0000)::numeric(15,4) AS midpoint
                  ,cp.companyparametervalue
                  ,CASE WHEN pc.frequencycode = 'H'::bpchar THEN pc.compamount * (pp.scheduledhours * fcpos.annualfactor)
                        ELSE (pc.compamount * fcc.annualfactor)::numeric(15,4)
                        END AS annualcompensation
                  ,CASE WHEN pp.partialpercent > 0::numeric THEN pp.partialpercent / 100.000000
                        ELSE 1::numeric
                        END AS partialpercent  
                  ,pc.effectivedate
                  ,pc.increaseamount
                  ,pc.compevent    
                  ,coalesce(prev_pc.compamount,pc.compamount) as prev_compamount 
                  ,pp.effectivedate as position_effectivedate
                  ,case when pc.frequencycode = 'A' then pc.compamount / 2080 else pc.compamount end as hourly_rate
                  ,porb.orgcode
                  ,porb.organizationid

                                                 
                 FROM salary_grade_ranges sgr
                 
                 join salary_grade sg
                   on sg.grade = sgr.grade
                  and current_date between sg.effectivedate and sg.enddate
                  and current_timestamp between sg.createts and sg.endts
                             
                 JOIN position_desc pd 
                   ON pd.grade = sgr.grade 
                 -- AND current_date between pd.effectivedate AND pd.enddate 
                  AND current_timestamp between pd.createts AND pd.endts   

                 JOIN location_codes lc 
                   ON lc.salarygraderegion = sgr.salarygraderegion 
                  AND current_date between lc.effectivedate AND lc.enddate 
                  AND current_timestamp between lc.createts AND lc.endts
                  
                 JOIN pers_pos pp 
                   ON pp.positionid = pd.positionid 
                  --and current_timestamp between pp.createts and pp.endts
                  --and pp.updatets is not null
                  --and pp.effectivedate <> '2018-01-01'  
                 JOIN person_locations pl 
                   ON pl.personid = pp.personid 
                  AND pl.locationid = lc.locationid              
                  AND current_date between pl.effectivedate AND pl.enddate 
                  AND current_timestamp between pl.createts AND pl.endts 

                 left join person_compensation pc 
                   on pc.personid = pp.personid
                  and current_timestamp between pc.createts and pc.endts 
                  and pc.updatets is not null
                  and pc.effectivedate <> '2018-01-01'                                      
 
                  left join position_job pj
                   on pj.positionid = PP.positionid
                  --and current_date between pj.effectivedate and pj.enddate
                  and current_timestamp between pj.createts and pj.endts
                  
                 left join job_desc jd
                   on jd.jobid = pj.jobid
                  and current_date between jd.effectivedate and jd.enddate
                  and current_timestamp between jd.createts and jd.endts         

                 JOIN frequency_codes fcc 
                   ON fcc.frequencycode = pc.frequencycode
                 JOIN frequency_codes fcpos 
                   ON fcpos.frequencycode = pp.schedulefrequency
                 JOIN frequency_codes fcsg 
                   ON fcsg.frequencycode = pc.frequencycode

                 LEFT JOIN company_parameters cp 
                   ON cp.companyparametername = 'PIRB'::bpchar 
                  AND cp.companyparametervalue::text = 'MIN'::text
                                    
                 left join person_compensation prev_pc
                   on prev_pc.personid = pc.personid
                  and prev_pc.percomppid = pc.percomppid - 1 


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
                      and pp.updatets is not null     
                      and pp.persposevent in ('Promo','NewAssgmnt')
                      --and current_date between pp.effectivedate and pp.enddate
                      AND CURRENT_TIMESTAMP BETWEEN PP.CREATETS AND PP.ENDTS  
                      --select * from pers_pos where personid = '66231';

                     join pos_org_rel porb 
                       ON porb.positionid = PP.positionid 
                      AND porb.posorgreltype = 'Budget' 
                      and current_timestamp between porb.createts and porb.endts
                      and porb.posorgrelevent = 'NewPos'
                        
                     join organization_code oc_cc
                       ON oc_cc.organizationid = porb.organizationid
                      AND oc_cc.organizationtype = 'CC'

                      and current_timestamp between oc_cc.createts and oc_cc.endts 
                      and oc_cc.effectivedate - interval '1 day' <> oc_cc.enddate 
                      
                      join person_employment pe
                       on pe.personid = pi.personid
                      and current_date between pe.effectivedate and pe.enddate
                      and current_timestamp between pe.createts and pe.endts
                      and pe.emplstatus = 'A'                    
                      
                     where pi.identitytype = 'SSN'
                       and current_timestamp between pi.createts and pi.endts
                       and date_part('year',pp.effectivedate) < date_part('year',current_date)
                       and date_part('month',pp.effectivedate) <> date_part('month',current_date)                       
                       and pi.personid in ('65966')
                  
                  
                  ) porb 
                    on porb.personid = pp.personid
                   and porb.positionid = pp.positionid
                                                                                                                          
                  
                  where sgr.frequencycode = pc.frequencycode  -- pd.positionid in ('401113')
                    and pp.personid = '65966'               

        ) sgr 