       SELECT distinct 
          sgrcurr.personid
         ,sgrcurr.earningscode
         ,sgrcurr.positionid
         ,sgrcurr.salarygraderegion
         ,sgrcurr.salarygradedesc
         ,sgrcurr.positiontitle
         ,sgrcurr.jobcode
         ,sgrcurr.compamount
         ,sgrcurr.midpoint 
         ,sgrcurr.annualsalarymax
         ,sgrcurr.annualsalarymin
         ,sgrcurr.locationdescription
         ,sgrcurr.locationCode
         ,sgrcurr.effectivedate    
         ,sgrcurr.increaseamount
         ,sgrcurr.compevent
         ,sgrcurr.prev_compamount   
         ,sgrcurr.position_effectivedate  
         ,TRUNC(sgrcurr.hourly_rate,2) AS HOURLY_RATE
         ,sgrcurr.orgcode
         ,sgrcurr.organizationid    
         ,sgrcurr.flsacode
         ,sgrcurr.pct_in_range
         ,sgrcurr.vpcpira_pct_in_range as percent_in_range 
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
               ,case when pc.compamount < 50 then 0 else pc.compamount end as compamount
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
               ,pd.flsacode    
               ,vpir.percent_in_range as pct_in_range  
               ,vpcpira.percent_in_range as vpcpira_pct_in_range        
                 
               from pers_pos pp
               --- this pc join insures I don't pull compensation details from future.
               join 
(
select 
 allpc.personid
,allpc.percomppid
,allpc.compamount
,allpc.increaseamount
,allpc.effectivedate
,allpc.enddate
,allpc.createts
,allpc.endts
,allpc.earningscode
,allpc.compevent
,allpc.frequencycode
from 


(
select personid,percomppid,compamount,effectivedate,enddate,createts,endts,increaseamount,earningscode,compevent,frequencycode
  from person_compensation
 where personid = '64166'
   and current_timestamp between createts and endts
)allpc
join 
(
select personid,max(percomppid) as percomppid
       from person_compensation
       where effectivedate <= ?::date
       and current_timestamp between createts and endts
       group by 1
) maxpc on maxpc.personid = allpc.personid and maxpc.percomppid = allpc.percomppid     
) pc    on pc.personid = pp.personid           
               
               
               
               
               
               left join dcperscompensationdet vpir
                 on vpir.personid = pp.personid 
                and current_date between vpir.effectivedate and vpir.enddate
                and current_timestamp between vpir.createts and vpir.endts
               
               left join personcomppercentinrangeasof vpcpira
                 on vpcpira.personid = pp.personid        
                and current_date = vpcpira.asofdate  
                
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
               
               join person_locations pl
                 on pl.personid = pp.personid
                and current_date between pl.effectivedate and pl.enddate
                and current_timestamp between pl.createts and pl.endts
               
               JOIN location_codes lc 
                 ON lc.locationid = pl.locationid
                AND current_date between lc.effectivedate AND lc.enddate 
                AND current_timestamp between lc.createts AND lc.endts  
                -- select * from location_codes 
               
               LEFT JOIN company_parameters cp 
                 ON cp.companyparametername = 'PIRB'::bpchar 
                AND cp.companyparametervalue::text = 'MIN'::text  
               
         
               JOIN position_desc pd 
                 ON pd.positionid = pp.positionid
            --AND current_date between pd.effectivedate AND pd.enddate 
                AND current_timestamp between pd.createts AND pd.endts         
                                
                                      
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
                   --select * from pers_pos where personid = '64831';
                  join pos_org_rel porb 
                    ON porb.positionid = PP.positionid 
                   AND porb.posorgreltype = 'Budget' 
                   and current_timestamp between porb.createts and porb.endts
         
                   -- select * from pos_org_rel where positionid = '389427'
         
                  
                  join organization_code oc_cc
                    ON oc_cc.organizationid = porb.organizationid
                   AND oc_cc.organizationtype = 'CC'
                   and current_timestamp between oc_cc.createts and oc_cc.endts 
                   and oc_cc.effectivedate - interval '1 day' <> oc_cc.enddate                       
                   --- select * from organization_code where organizationid = '1363'                 
                   
                   join person_employment pe
                    on pe.personid = pi.personid
                   and current_date between pe.effectivedate and pe.enddate
                   and current_timestamp between pe.createts and pe.endts
                   and pe.emplstatus = 'A'   
                                    
                   
                  where pi.identitytype = 'SSN'
                    and current_timestamp between pi.createts and pi.endts                      
                    --and pi.personid in ('66504')
               ) porb 
                on porb.personid = pp.personid
               and porb.positionid = pp.positionid
                                 
               where current_date between pp.effectivedate and pp.enddate
               and current_timestamp between pp.createts and pp.endts
     
      
      and pp.personid = '64166'
     ) sgrcurr      