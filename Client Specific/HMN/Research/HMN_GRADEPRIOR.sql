       SELECT distinct 
         sgrprior.personid
        ,sgrprior.positionid
        ,sgrprior.scheduledhours
        ,sgrprior.earningscode
        ,sgrprior.salarygradedesc
        ,sgrprior.grade
        ,sgrprior.salarygraderegion
        ,sgrprior.compamount
        ,sgrprior.orgcode
        ,sgrprior.organizationid
        ,CASE
               WHEN sgrprior.midpoint IS NOT NULL AND sgrprior.midpoint > 0::numeric AND (sgrprior.annualsalarymax - sgrprior.annualsalarymin) > 0::numeric THEN
               CASE
                   WHEN sgrprior.companyparametervalue IS NOT NULL 
                   THEN ((sgrprior.annualcompensation / sgrprior.partialpercent - sgrprior.annualsalarymin)::numeric(15,3) / (sgrprior.annualsalarymax - sgrprior.annualsalarymin)::numeric(15,3))::numeric(15,3)
                   ELSE (sgrprior.annualcompensation / sgrprior.partialpercent / sgrprior.midpoint)::numeric(15,3)
               END
               ELSE 0.00000        
         END AS percent_in_range           
        ,sgrprior.effectivedate
        ,sgrprior.enddate
        ,sgrprior.createts
        ,sgrprior.endts          
        ,sgrprior.increaseamount
        ,sgrprior.compevent
        ,sgrprior.prev_compamount    
        ,sgrprior.position_effectivedate     
        ,sgrprior.jobcode   
        ,sgrprior.positiontitle   
        ,TRUNC(sgrprior.hourly_rate,2) AS HOURLY_RATE
        ,sgrprior.locationdescription
        ,sgrprior.locationCode
        ,sgrprior.flsacode
              
         FROM ( 
                SELECT distinct            
                  pi.personid
                 ,pc.compevent
                 ,pc.compamount
                 ,pc.increaseamount
                 ,pc.earningscode  
                 ,pc.effectivedate                                                  
                 ,pc.enddate
                 ,pc.createts
                 ,pc.endts                           
                 ,coalesce(prev_pc.compamount,pc.compamount) as prev_compamount
                 ,case when pc.frequencycode = 'A' then pc.compamount / 2080 else pc.compamount end as hourly_rate                     
                 ,pp.positionid
                 ,pp.scheduledhours
                 ,pp.effectivedate as position_effectivedate        
                 ,porb.orgcode
                 ,porb.organizationid
                 ,pd.positiontitle   
                 ,jd.jobcode  
                 ,sg.salarygradedesc
                 ,sg.grade
                 ,sgr.salarygraderegion
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
                 ,pd.flsacode                                  
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
                          and pi.personid in ('64166')
                       ) pc
                   on pc.personid = pi.personid
 
                 left JOIN pers_pos pp 
                   ON pp.personid = pi.personid
                  and pp.updatets is not null
                 
                 JOIN person_locations pl 
                   ON pl.personid = pi.personid 
                  --AND pl.locationid = lc.locationid              
                  AND current_date between pl.effectivedate AND pl.enddate 
                  AND current_timestamp between pl.createts AND pl.endts                   

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
                      AND CURRENT_TIMESTAMP BETWEEN PP.CREATETS AND PP.ENDTS  

                     join pos_org_rel porb 
                       ON porb.positionid = PP.positionid 
                      AND porb.posorgreltype = 'Budget' 
                      and current_timestamp between porb.createts and porb.endts
                      and porb.posorgrelevent = 'NewPos'
                        
                     join organization_code oc_cc
                       ON oc_cc.organizationid = porb.organizationid
                      AND oc_cc.organizationtype = 'CC'

                      --and current_timestamp between oc_cc.createts and oc_cc.endts 
                      --and oc_cc.effectivedate - interval '1 day' <> oc_cc.enddate 
                      
                      join person_employment pe
                       on pe.personid = pi.personid
                      and current_date between pe.effectivedate and pe.enddate
                      and current_timestamp between pe.createts and pe.endts
                      and pe.emplstatus in ('T','R')                      
                      
                     where pi.identitytype = 'SSN'
                       and current_timestamp between pi.createts and pi.endts
                      -- and pi.personid in ('66231')
                  
                  
                  ) porb 
                    on porb.personid = pi.personid
                  
                 JOIN position_desc pd 
                   ON pd.positionid = pp.positionid
                  AND current_date between pd.effectivedate AND pd.enddate 
                  AND current_timestamp between pd.createts AND pd.endts

                 join salary_grade sg
                   on sg.grade = pd.grade
                  and current_date between sg.effectivedate and sg.enddate
                  and current_timestamp between sg.createts and sg.endts

                 JOIN location_codes lc 
                   ON lc.locationid = pl.locationid 
                  AND current_date between lc.effectivedate AND lc.enddate 
                  AND current_timestamp between lc.createts AND lc.endts
                  
                 join salary_grade_ranges sgr
                   on sgr.grade = sg.grade 
                  and sgr.salarygraderegion = lc.salarygraderegion 
                  and current_date between sgr.effectivedate and sgr.enddate
                  and current_timestamp between sgr.createts and sgr.endts        
                  
                 left join person_compensation prev_pc
                   on prev_pc.personid = pc.personid
                  and prev_pc.percomppid = pc.percomppid - 1  
                 
                 LEFT JOIN company_parameters cp 
                   ON cp.companyparametername = 'PIRB'::bpchar 
                  AND cp.companyparametervalue::text = 'MIN'::text

                 left join position_job pj
                   on pj.positionid = PP.positionid
                  and current_date between pj.effectivedate and pj.enddate
                  and current_timestamp between pj.createts and pj.endts                  
                 left join job_desc jd
                   on jd.jobid = pj.jobid
                  --and current_date between jd.effectivedate and jd.enddate
                  and current_timestamp between jd.createts and jd.endts                     

                 JOIN frequency_codes fcc 
                   ON fcc.frequencycode = pc.frequencycode
                 JOIN frequency_codes fcpos 
                   ON fcpos.frequencycode = pp.schedulefrequency
                 JOIN frequency_codes fcsg 
                   ON fcsg.frequencycode = pc.frequencycode
                                        
                 join pspay_payment_detail ppd
                   on ppd.personid = pp.personid
                  and date_part('year',ppd.check_date)=date_part('year',current_date - interval '1 year')  
                  and PPD.etv_id in  ('E01','E64','EB5','E05','EB8','E15','E16','E17','E18','E19','E20','ECA','EAJ','EAR','EB4','EAK'
                                     ,'E30','EBF','E61','EA1','EB1','EBE',
                                      'EBH','EA2','VBB','VBC','VBD','VBA','VBE','VEH','VEJ','EB7') 
                  --and ppd.check_number = 'DIRDEP'
             
            where pi.identitytype = 'SSN'
              and current_timestamp between pi.createts and pi.endts
              and sgr.frequencycode = pc.frequencycode
              and pp.personid = '64166'             

        ) sgrprior