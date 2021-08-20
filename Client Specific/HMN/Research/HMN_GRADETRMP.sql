       SELECT distinct 
         sgrtrmp.personid
        ,sgrtrmp.positionid
        ,sgrtrmp.scheduledhours
        ,sgrtrmp.earningscode
        ,sgrtrmp.salarygradedesc
        ,sgrtrmp.grade
        ,sgrtrmp.salarygraderegion
        ,sgrtrmp.compamount
        ,sgrtrmp.orgcode
        ,sgrtrmp.organizationid
        ,CASE
               WHEN sgrtrmp.midpoint IS NOT NULL AND sgrtrmp.midpoint > 0::numeric AND (sgrtrmp.annualsalarymax - sgrtrmp.annualsalarymin) > 0::numeric THEN
               CASE
                   WHEN sgrtrmp.companyparametervalue IS NOT NULL 
                   THEN ((sgrtrmp.annualcompensation / sgrtrmp.partialpercent - sgrtrmp.annualsalarymin)::numeric(15,3) / (sgrtrmp.annualsalarymax - sgrtrmp.annualsalarymin)::numeric(15,3))::numeric(15,3)
                   ELSE (sgrtrmp.annualcompensation / sgrtrmp.partialpercent / sgrtrmp.midpoint)::numeric(15,3)
               END
               ELSE 0.00000        
         END AS percent_in_range           
        ,sgrtrmp.effectivedate
        ,sgrtrmp.enddate
        ,sgrtrmp.createts
        ,sgrtrmp.endts          
        ,sgrtrmp.increaseamount
        ,sgrtrmp.compevent
        ,sgrtrmp.prev_compamount    
        ,sgrtrmp.position_effectivedate     
        ,sgrtrmp.jobcode   
        ,sgrtrmp.positiontitle   
        ,TRUNC(sgrtrmp.hourly_rate,2) AS HOURLY_RATE
        ,sgrtrmp.locationdescription
        ,sgrtrmp.locationCode
              
         FROM (                 
                
                
                
                SELECT distinct            
                  pi.personid
     
                 ,porb.orgcode
                 ,porb.organizationid
                 ,pp.positionid
                 ,pc.frequencycode
                 ,pc.earningscode  
                 ,pc.effectivedate                                                  
                 ,pc.enddate
                 ,pc.createts
                 ,pc.endts
                 ,pc.compamount
                 ,pc.compevent                 
                 ,pc.increaseamount
                 ,coalesce(pc.compamount,prev_pc.compamount) as prev_compamount
                 ,case when pc.frequencycode = 'A' then pc.compamount / 2080 else pc.compamount end as hourly_rate                   
                 ,pp.scheduledhours
                 ,pp.effectivedate as position_effectivedate
                 ,jd.jobcode   
                 ,pd.positiontitle  
                 ,lc.locationdescription
                 ,lc.locationCode                                                                    

                 --,vdxp.grade
                               
                 ,sg.salarygradedesc
                 ,sg.grade 
                 ,sgr.salarygraderegion 


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
                       
                                                                        
                 from person_identity pi
                 
                 join person_employment pe
                   on pe.personid = pi.personid
                  and current_date between pe.effectivedate and pe.enddate
                  and current_timestamp between pe.createts and pe.endts
                  and pe.emplstatus = 'T'

                 join ( 
                        select
                            pi.personid
                           ,comp.percomppid
                           ,comp.compamount
                           ,comp.earningscode
                           ,comp.increaseamount
                           ,comp.effectivedate
                           ,comp.compevent
                           ,COMP.frequencycode
                           ,comp.enddate
                           ,comp.createts
                           ,comp.endts
    
                         from person_identity pi
    
                         join (select personid,  max(percomppid) as max_percomppid from person_compensation where current_timestamp between createts and endts group by 1) maxid
                           on maxid.personid = pi.personid
                         join (select personid, compamount, earningscode, percomppid,increaseamount,effectivedate,compevent,frequencycode,
                                      enddate,createts,endts
                                 from person_compensation where current_timestamp between createts and endts) comp 
                           on comp.personid = pi.personid
                          and comp.percomppid  = maxid.max_percomppid  
                          join person_employment pe
                            on pe.personid = pi.personid
                           and current_date between pe.effectivedate and pe.enddate
                           and current_timestamp between pe.createts and pe.endts
                           and pe.emplstatus in ('T','R')                         
    
                        where pi.identitytype = 'SSN'
                          and current_timestamp between pi.createts and pi.endts
                     --     and pi.personid in ('66231')
                       ) pc
                   on pc.personid = pi.personid

                 left JOIN pers_pos pp 
                   ON pp.personid = pi.personid
                  and pp.positionid = 
                      (select max(positionid) as maxpos 
                         from pers_pos x
                         where current_date between x.effectivedate and x.enddate
                           and current_timestamp between x.createts and x.endts
                           and x.personid = pi.personid)
                 JOIN person_locations pl 
                   ON pl.personid = pi.personid 
                  --AND pl.locationid = lc.locationid              
                  AND current_date between pl.effectivedate AND pl.enddate 
                  AND current_timestamp between pl.createts AND pl.endts                      
             

                  join 
                  (
                    select distinct
                          pi.personid
                         ,pp.positionid
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

                     
                     join pos_org_rel porb                      
                       on porb.positionid = pp.positionid
                      and porb.organizationid is not null

                     join organization_code oc_cc
                       ON oc_cc.organizationid = porb.organizationid 
                      and oc_cc.organizationxid is not null
                                         
                      
                      join person_employment pe
                       on pe.personid = pi.personid
                      and current_date between pe.effectivedate and pe.enddate
                      and current_timestamp between pe.createts and pe.endts
                      and pe.emplstatus in ('T','R')   
                                            
                     where pi.identitytype = 'SSN'
                       and current_timestamp between pi.createts and pi.endts
                       and pi.personid in ('65623')
                  
                  
                  ) porb 
                    on porb.personid = pi.personid
 
                 JOIN position_desc pd 
                   ON pd.positionid = pp.positionid
                  --AND current_date between pd.effectivedate AND pd.enddate 
                  AND current_timestamp between pd.createts AND pd.endts
                  
                  join positionhistory vph
                    on vph.positionid = pp.positionid
                  
                  join dxpersonpositiondet vdxp
                    on vdxp.personid = pp.personid
                   and vdxp.grade is not null 
 
                  join salary_grade sg
                   on sg.grade = vdxp.grade
                  and current_date between sg.effectivedate and sg.enddate
                  and current_timestamp between sg.createts and sg.endts                                  

                 LEFT JOIN company_parameters cp 
                   ON cp.companyparametername = 'PIRB'::bpchar 
                  AND cp.companyparametervalue::text = 'MIN'::text
                  
                 JOIN frequency_codes fcc 
                   ON fcc.frequencycode = pc.frequencycode
                 JOIN frequency_codes fcpos 
                   ON fcpos.frequencycode = pp.schedulefrequency
                 JOIN frequency_codes fcsg 
                   ON fcsg.frequencycode = pc.frequencycode 
                   

                 JOIN location_codes lc 
                   ON lc.locationid = pl.locationid 
                  AND current_date between lc.effectivedate AND lc.enddate 
                  AND current_timestamp between lc.createts AND lc.endts                   
                 join salary_grade_ranges sgr
                   on sgr.grade = sg.grade 
                  and sgr.salarygraderegion = lc.salarygraderegion 
                  and sgr.edtcode = pc.earningscode
                  and current_date between sgr.effectivedate and sgr.enddate
                  and current_timestamp between sgr.createts and sgr.endts  

                 left join position_job pj
                   on pj.positionid = PP.positionid
                  and current_date between pj.effectivedate and pj.enddate
                  and current_timestamp between pj.createts and pj.endts 
                  -- select * from pers_pos where personid = '65623';select * from position_job where jobid  = '70383';    select * from jobcodedetail where jobid = '70383';  --- this should be '333739'            
                 left join job_desc jd
                   on jd.jobid = pj.jobid
                  --and current_date between jd.effectivedate and jd.enddate
                  and current_timestamp between jd.createts and jd.endts     
                  
                  --select * from jobcodedetail where jobid = '70383';
                                      
 
                 left join person_compensation prev_pc
                   on prev_pc.personid = pc.personid
                  and prev_pc.percomppid = pc.percomppid - 1   
             
            where pi.identitytype = 'SSN'
              and current_timestamp between pi.createts and pi.endts

              and pi.personid = '65623'  
       ) sgrtrmp