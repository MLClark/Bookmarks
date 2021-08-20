select distinct
 pie.personid
,pp.positionid
,pj.positionid
,pj.jobid
,jd.jobid 
,pie.identity ::varchar(15) as employeeid
,pe.emplclass ::varchar(15) as empclass
,case when pe.emplstatus = 'A' then 0 else 1 end as inactive
,pn.lname ::varchar(20) as lastname
,pn.fname ::varchar(20) as firstname
,replace(pn.mname,',',' ') ::varchar(20) as middlename
,pn.title ::char(4) as emplsuffix
,' ' ::char(1) as address_code
,replace(pa.streetaddress,',',' ')  ::char(50) as address1
,replace(pa.streetaddress2,',',' ') ::char(50) as address2
,replace(pa.streetaddress3,',',' ') ::char(50) as address3
,pa.city ::varchar(30) as city
,pa.stateprovincecode ::char(2) as state
,pa.postalcode ::char(10) as zip
,' ' ::char(1) as county
,pa.countrycode ::varchar(20) as country

,replace(ppcM.phoneno,'-','') ::char(21) as phone1
,replace(ppcH.phoneno,'-','') ::char(21) as phone2
,replace(ppcW.phoneno,'-','') ::char(21) as phone3
,' ' ::char(1) as fax


,coalesce(pis.identity) as ssn
,pit.identity as tin

,to_char(pv.birthdate,'yyyy/mm/dd') ::char(10) as dob
,case when pv.gendercode = 'M' then 1 
      when pv.gendercode = 'F' then 2 
      else 3 end as gender
,case when pv.ethniccode = 'W' then 1 
      when pv.ethniccode = 'B' then 3 
      when pv.ethniccode = 'N' then 2 
      ELSE 6 END as ethnicity
,0 as calc_min_wage

,SPLIT_PART(coalesce(rptorgstrc1.org2code,rptorgstrc2.org2code,rptorgstrc3.org2code,rptorgstrc4.org2code),'-',1)::char(5) AS divcode_1 
,case when SPLIT_PART(coalesce(rptorgstrc1.org1code,rptorgstrc2.org1code,rptorgstrc3.org2code,rptorgstrc4.org1code),'-',1) = '1' then '00001'
      else SPLIT_PART(coalesce(rptorgstrc1.org1code,rptorgstrc2.org1code,rptorgstrc3.org2code,rptorgstrc4.org1code),'-',1) end ::char(5) AS department


,replace(coalesce(rptorgstrc1.positiontitle,rptorgstrc2.positiontitle,rptorgstrc3.positiontitle,rptorgstrc4.positiontitle),',',' ') ::varchar(50) as jobtitle
-----for AYV - we will be mapping to jobcode for the feed - vs positioncode
,coalesce(rptorgstrc1.positionxid,rptorgstrc2.positionxid,rptorgstrc3.positionxid,rptorgstrc4.positionxid) ::char(5) as jobtitleid
--,jd.jobcode
,split_part(coalesce(jd.jobcode,rptorgstrc1.jobcode,rptorgstrc3.jobcode),'-',1)::char(5)  as job_code_jobtitleid
,' ' ::char(6) as supervisor_code

,case when pl.locationid = '29' then 'BZE' else 'STX' END ::char(15) as locationid
,1 as wcacfpay
,' ' ::char(1) as account_nbr
,pp.scheduledhours as work_hours_per_week
,pp.scheduledhours * 52 as work_hours_per_yr
, case when pc.personid is not null 
       then cast(((pp.scheduledhours * fcpos.annualfactor)/ fcpay.annualfactor) * pdx.distinctpayperiods as dec (18,2))
       else pdx.workedhours end as hours
,to_char(pe.emplhiredate,'yyyy/mm/dd') ::char(10) as hiredate
,case when pe.emplstatus in ('T','R') then to_char(pe.effectivedate,'yyyy/mm/dd') else NULL end ::char(10) as termdate
,case when pe.emplstatus = 'T' then 1 else 0 end as termreason
,pc.compamount as min_net_pay
,' ' as suta
,' ' as worker_comp_code
,0 as auto_accrue
,0 as vac_accrue_amt
,0 as vac_accrue_method
,0 as vac_hours_per_year
,0 as vac_avail
,0 as vac_below_zero_warn

,0 as auto_accrue_sick
,0 as sick_accrue_meth
,0 as sick_accue_amt
,0 as sick_accrue_avail
,0 as sick_hours_per_year
,0 as sick_below_zero_warn

,' ' as udf01
,' ' as udf02
--,ed.emplclass 
,CASE pe.emplclass 
      WHEN 'F' THEN 1
      WHEN 'P' THEN 3
      when 'PU' then 3
      ELSE 6 end ::char(2) as employeetype
--,pm.maritalstatus 
,case pm.maritalstatus
      when 'S' then 2
      when 'M' then 1
      else 3 end as maritalstatus     
      
,to_char(pe.effectivedate,'yyyy/mm/dd')::char(10) as benefit_adj_date
,to_char(pe.paythroughdate,'yyyy/mm/dd')::char(10) as last_date_worked
,DATE_PART('DAY',pv.birthdate) as birthday
,date_part('month',pv.birthdate) as birth_month   

,pnd.fname ::char(15) as spouse
,pidep.identity ::char(15) as spouse_ssn
,(pn_p.fname || ' ' || pn_p.lname)::varchar(255) as nickname
,' ' ::char(20) as alt_name
,' ' ::char(2) as status_code

,case pe.emplstatus 
      when 'A' then 1
      when 'L' then 2
      when 'LO' then 3
      when 'M' then 4
      when 'R' then 5
      when 'S' then 6
      when 'T' then 8
      else 9 end as hr_status
      
,' ' ::char(1) as date_of_last_review
,' ' ::char(1) as date_of_next_review
,' ' ::char(1) as date_of_bene_expire

,CASE WHEN pdis.disabilitycode = 'Y' THEN 1 ELSE 0 END as handicapped
,CASE WHEN pvs.veteranstatus = 'Y' THEN 1 ELSE 0 END as veteran
,0 as vietname_vet
,CASE WHEN pvs.veterandisability = 'Y' THEN 1 ELSE 0 END as disabled_vet
,0 as union_emp
,CASE WHEN pv.smoker = 'Y' THEN 1 ELSE 0 END as smoker
--,pcz.
,0 as citizen
,0 as verified
,' ' ::char(1) as i9renew
,' ' ::char(1) as Primary_Pay_Record

,' ' ::char(1) as change_by_date
,' ' ::char(1) as change_date
,' ' ::char(1) as union_code

,' ' ::char(1) as rate_class
,' ' ::char(1) as fed_class_code
,0 as other_vet
,' ' ::char(1) as military_discharge_date
,0 as default_from_class
,0 as update_if_exists
,0 as requester_trx

,' ' ::char(1) as udf1
,' ' ::char(1) as udf2
,' ' ::char(1) as udf3
,' ' ::char(1) as udf4
,' ' ::char(1) as udf5
,' ' ::char(1) as userid


,coalesce(rptorgstrc1.org1desc,rptorgstrc2.org1desc,rptorgstrc3.org2desc,rptorgstrc4.org1desc) as mbr_desc
,coalesce(rptorgstrc1.org2desc,rptorgstrc2.org2desc,rptorgstrc3.org2desc) as division_desc



from person_identity pie

left join person_employment pe
  on pe.personid = pie.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts
 and pe.effectivedate - interval '1 day' <> pe.enddate 

left join person_identity pis
  on pis.personid = pe.personid
 and pis.identitytype in ( 'SSN','SSNVI')
 and current_timestamp between pis.createts and pis.endts
left join person_identity pit
  on pit.personid = pe.personid
 and pit.identitytype in ( 'TIN')
 and current_timestamp between pit.createts and pit.endts 
 

 
left join person_names pn
  on pn.personid = pie.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts
 and pn.effectivedate - interval '1 day' <> pn.enddate
  
left outer join person_names pn_p
  on pn_p.personid = pie.personid 
 and pn_p.nametype = 'Pref'
 and CURRENT_DATE between pn_p.effectivedate and pn_p.enddate
 and current_timestamp between pn_p.createts and pn_p.endts
 and pn_p.effectivedate - interval '1 day' <> pn_p.enddate

left join person_address pa
  on pa.personid = pie.personid
 and pa.addresstype = 'Res'
 and current_date between pa.effectivedate and pa.enddate
 and current_timestamp between pa.createts and pa.endts
 and pa.effectivedate - interval '1 day' <> pa.enddate

left join person_vitals pv
  on pv.personid = pie.personid
 and current_date between pv.effectivedate and pv.enddate
 and current_timestamp between pv.createts and pv.endts
 and pv.effectivedate - interval '1 day' <> pv.enddate 

left join person_phone_contacts ppcw 
  on ppcw.personid = pie.personid
 and ppcw.phonecontacttype = 'Work'     
 and current_date between ppcw.effectivedate and ppcw.enddate
 and current_timestamp between ppcw.createts and ppcw.endts 
 and ppcw.effectivedate - interval '1 day' <> ppcw.enddate  
 
left join person_phone_contacts ppch
  on ppch.personid = pie.personid
 and ppch.phonecontacttype = 'Home'     
 and current_date between ppch.effectivedate and ppch.enddate
 and current_timestamp between ppch.createts and ppch.endts 
 and ppch.effectivedate - interval '1 day' <> ppch.enddate   
 
left join person_phone_contacts ppcm
  on ppcm.personid = pie.personid
 and ppcm.phonecontacttype = 'Mobile'     
 and current_date between ppcm.effectivedate and ppcm.enddate
 and current_timestamp between ppcm.createts and ppcm.endts 
 and ppcm.effectivedate - interval '1 day' <> ppcm.enddate  
 
left join person_maritalstatus pm 
  on pm.personid = pie.personid
 and current_date between pm.effectivedate and pm.enddate
 and current_timestamp between pm.createts and pm.endts
 and pm.effectivedate - interval '1 day' <> pm.enddate
 
left join person_net_contacts pnc
  on pnc.personid = pie.personid
 and pnc.netcontacttype = 'WRK'
 and current_date between pnc.effectivedate and pnc.enddate
 and current_timestamp between pnc.createts and pnc.endts
 and pnc.effectivedate - interval '1 day' <> pnc.enddate 

left join person_disability pdis
  on pdis.personid = pie.personid
 and current_date between pdis.effectivedate and pdis.enddate
 and current_timestamp between pdis.createts and pdis.endts
 
left join person_veteran_status pvs
  on pvs.personid = pie.personid
 and current_timestamp between pvs.createts and pvs.endts 

left join person_citizenship pcz
  on pcz.personid = pie.personid
 and current_date between pcz.effectivedate and pcz.enddate
 and current_timestamp between pcz.createts and pcz.endts
 and pcz.effectivedate - interval '1 day' <> pcz.enddate 

left join person_payroll p_pay
  on p_pay.personid = pie.personid
 and current_date between p_pay.effectivedate and p_pay.enddate
 and current_timestamp between p_pay.createts and p_pay.endts
 and p_pay.effectivedate - interval '1 day' <> p_pay.enddate 

left join pay_unit_periods pup
  on pup.payunitid = p_pay.payunitid
 and pup.periodenddate = (select min(periodenddate)
			                   from pay_unit_periods ppp 
			                  where ppp.payunitid = p_pay.payunitid
			                    and ppp.checkdate > pe.effectivedate) 

left join person_compensation pc
  on pc.personid = pie.personid
 and current_date between pc.effectivedate and pc.enddate
 and current_timestamp between pc.createts and pc.endts
 and pc.effectivedate - interval '1 day' <> pc.enddate

---------------------------------------------------------
left join pers_pos pp
  on pp.personid = pie.personid
 and current_date between pp.effectivedate and pp.enddate
 and current_timestamp between pp.createts and pp.endts
 and pp.effectivedate - interval '1 day' <> pp.enddate 

left join position_job pj
  on pj.positionid = pp.positionid
 and current_date between pj.effectivedate and pj.enddate
 and current_timestamp between pj.createts and pj.endts
 
left join job_desc jd
  on jd.jobid = pj.jobid
 and current_Date between jd.effectivedate and jd.enddate
 and current_timestamp between jd.createts and jd.endts  
 
left join person_locations pl
  on pl.personid = pie.personid
 and pl.personlocationtype = 'P'
 and current_date between pl.effectivedate and pl.enddate
 and current_timestamp between pl.createts and pl.endts
 and pl.effectivedate - interval '1 day' <> pl.enddate 
 
left join location_address la 
  on la.locationid = pl.locationid
 and current_date between la.effectivedate and la.enddate
 and current_timestamp between la.createts and la.endts 
 and la.effectivedate - interval '1 day' <> la.enddate  



left join (select pd.personid
           , psp.payunitid
           , sum(case when peo.etvoperatorpid is null then pd.etype_hours else 0 end) as workedhours
           , extract(year from pd.check_date) as payyear
           , count(distinct psp.payscheduleperiodid) as distinctpayperiods
        from pspay_payment_header ph
        join pspay_payment_detail pd 
          on pd.paymentheaderid = ph.paymentheaderid
         and pd.personid = ph.personid
        join pay_schedule_period psp 
          on ph.payscheduleperiodid = psp.payscheduleperiodid
         and psp.payrolltypeid = 1 ----- NORMAL
   left join pspay_etv_operators peo 
          on peo.group_key = pd.group_key
         and peo.etv_id = pd.etv_id 
         and current_timestamp between peo.createts and peo.endts
         and peo.operand = 'WS102'
         and peo.opcode = 'A'
       where extract(year from pd.check_date) = extract(year from current_date)
       group by pd.personid, extract(year from pd.check_date), psp.payunitid)pdx 
  on pdx.personid = pie.personid
 

left join frequency_codes fcpos 
  on fcpos.frequencycode = pp.schedulefrequency

left join pay_unit pu 
  on pu.payunitid = pdx.payunitid
  
left join frequency_codes fcpay 
  on fcpay.frequencycode = pu.frequencycode 

left join companyname cn 
  on cn.companyid = pu.companyid

----- dependent data
left join person_dependent_relationship pdr
  on pdr.personid = pe.personid
 and pdr.dependentrelationship in ('SP')
 and current_date between pdr.effectivedate and pdr.enddate
 and current_timestamp between pdr.createts and pdr.endts
 and pdr.effectivedate - interval '1 day' <> pdr.enddate

left join person_identity piDep
  on piDep.personid = pdr.dependentid
 and piDep.identitytype = 'SSN'
 and current_timestamp between piDep.createts and piDep.endts 
 
left join person_names pnd
  on pnD.personid = pdr.dependentid
 and pnD.nametype = 'Dep'  
 and current_date between pnD.effectivedate and pnD.enddate
 and current_timestamp between pnd.createts and pnD.endts
 and pnd.effectivedate - interval '1 day' <> pnd.enddate

left join 
  (
     select distinct
      pi.personid
      ,pp.positionid
      ,por.organizationid 
      --,orl.memberoforgid
      ,orl.organizationid
      ,pd.positiontitle
      ,pd.positionxid
      ,ros.org1desc
      ,ros.org1id
      ,ros.org1code
      ,ros.org2code
      ,rosdiv.org2desc 
      ,jd.jobcode
      
      from person_identity pi
      
      join pers_pos pp 
      on pp.personid = pi.personid
      and current_date between pp.effectivedate and pp.enddate
      and current_timestamp between pp.createts and pp.endts
      
      join pos_org_rel por 
      on por.positionid = pp.positionid
      and current_date between por.effectivedate and por.enddate
      and current_timestamp between por.createts and por.endts 
      
      join position_desc pd
      on pd.positionid = pp.positionid
      and current_date between pd.effectivedate and pd.enddate
      and current_timestamp between pd.createts and pd.endts 
      
      join org_rel orl
      on orl.organizationid = por.organizationid
      and current_date between orl.effectivedate and orl.enddate
      and current_timestamp between orl.createts and orl.endts
      
      join cognos_orgstructure ros
      on ros.org2id = orl.memberoforgid
      and ros.org1type = 'Dept'
      and ros.org1id = orl.organizationid

      join cognos_orgstructure rosdiv
        on rosdiv.org2id = orl.memberoforgid
       and rosdiv.org2type = 'Div'
       
      join position_job pj
        on pj.positionid = pp.positionid
       and current_date between pj.effectivedate and pj.enddate
       and current_timestamp between pj.createts and pj.endts
      
      left join job_desc jd
        on jd.jobid = pj.jobid
       and current_date between jd.effectivedate and jd.enddate
       and current_timestamp between jd.createts and jd.endts
       and jd.effectivedate - interval '1 day' <> jd.enddate          
       
      where current_timestamp between pi.createts and pi.endts

)  rptorgstrc1 on rptorgstrc1.personid = pie.personid
-------------------
left join 
     (
        select distinct
         pi.personid
         ,pp.positionid
         ,por.organizationid 
         --,orl.memberoforgid
         ,orl.organizationid
         ,pd.positiontitle
         ,pd.positionxid
         ,ros.org1desc
         ,ros.org1id
         ,ros.org1code
         ,ros.org2code
         ,rosdiv.org2desc 
         ,jd.jobcode
         
         from person_identity pi
         
         join pers_pos pp 
         on pp.personid = pi.personid
         and current_date between pp.effectivedate and pp.enddate
         and current_timestamp between pp.createts and pp.endts
         
         join pos_org_rel por 
         on por.positionid = pp.positionid
         and current_date between por.effectivedate and por.enddate
         and current_timestamp between por.createts and por.endts 
         
         join position_desc pd
         on pd.positionid = pp.positionid
         and current_date between pd.effectivedate and pd.enddate
         and current_timestamp between pd.createts and pd.endts 
         
         join org_rel orl
         on orl.memberoforgid = por.organizationid
         and current_date between orl.effectivedate and orl.enddate
         and current_timestamp between orl.createts and orl.endts
         
         join cognos_orgstructure ros
         on ros.org2id = orl.memberoforgid
         and ros.org1type = 'Dept'
         and ros.org1id = orl.organizationid
         
         join positionorgrelhist porh
         on porh.positionid = pp.positionid 
         and porh.organizationdesc = ros.org1desc 

         join cognos_orgstructure rosdiv
           on rosdiv.org2id = orl.memberoforgid
          and rosdiv.org2type = 'Div'
          
         join position_job pj
           on pj.positionid = pp.positionid
          and current_date between pj.effectivedate and pj.enddate
          and current_timestamp between pj.createts and pj.endts
         
         join job_desc jd
           on jd.jobid = pj.jobid
          and current_date between jd.effectivedate and jd.enddate
          and current_timestamp between jd.createts and jd.endts
          and jd.effectivedate - interval '1 day' <> jd.enddate          
          
         where current_timestamp between pi.createts and pi.endts
   
  )  rptorgstrc2 on rptorgstrc2.personid = pie.personid
-------------------
left join 
     (select distinct

            pi.personid
            ,pp.positionid
            --,por.organizationid 
            ,orl.memberoforgid
            --,orl.organizationid
            ,pd.positiontitle
            ,pd.positionxid
            --,rosdept.org1desc
            --,rosdept.org1id
            --,rosdept.org1code
            ,rosdept.org2code
            --,rosdept.org1desc
            ,rosdiv.org2desc
            ,jd.jobcode
            
            from person_identity pi
            
            join pers_pos pp 
            on pp.personid = pi.personid
            and current_date between pp.effectivedate and pp.enddate
            and current_timestamp between pp.createts and pp.endts
            
            join pos_org_rel por 
            on por.positionid = pp.positionid
            and current_date between por.effectivedate and por.enddate
            and current_timestamp between por.createts and por.endts 
            
            join position_desc pd
            on pd.positionid = pp.positionid
            and current_date between pd.effectivedate and pd.enddate
            and current_timestamp between pd.createts and pd.endts 
            
            join org_rel orl
            on orl.memberoforgid = por.organizationid
            and current_date between orl.effectivedate and orl.enddate
            and current_timestamp between orl.createts and orl.endts
            
            join cognos_orgstructure rosdept
            on rosdept.org2id = orl.memberoforgid
            and rosdept.org1type = 'Dept'
            and rosdept.org1id = orl.organizationid
            
            join cognos_orgstructure rosdiv
            on rosdiv.org2id = orl.memberoforgid
            and rosdiv.org2type = 'Div'
                       
            join position_job pj
            on pj.positionid = pp.positionid
            and current_date between pj.effectivedate and pj.enddate
            and current_timestamp between pj.createts and pj.endts
            
            join job_desc jd
            on jd.jobid = pj.jobid
            and current_date between jd.effectivedate and jd.enddate
            and current_timestamp between jd.createts and jd.endts
            and jd.effectivedate - interval '1 day' <> jd.enddate
            
            where current_timestamp between pi.createts and pi.endts
   
  )  rptorgstrc3 on rptorgstrc3.personid = pie.personid
  
left join 
     (select distinct
   
          pi.personid
         ,pp.positionid
         ,por.organizationid 
         ,orl.memberoforgid
         ,orl.organizationid
         ,pd.positiontitle
         ,pd.positionxid
         ,ros.org1desc
         ,ros.org1id
         ,ros.org1code
         ,ros.org2code
      --   ,rosdiv.org2desc 
   --      ,pj.jobid
        -- ,jd.jobcode
   
         
         from person_identity pi
         
         join pers_pos pp 
         on pp.personid = pi.personid
         and current_date between pp.effectivedate and pp.enddate
         and current_timestamp between pp.createts and pp.endts
         
         join pos_org_rel por 
         on por.positionid = pp.positionid
         and current_date between por.effectivedate and por.enddate
         and current_timestamp between por.createts and por.endts 
         
         join position_desc pd
         on pd.positionid = pp.positionid
         and current_date between pd.effectivedate and pd.enddate
         and current_timestamp between pd.createts and pd.endts 
         
         join org_rel orl
         on orl.organizationid = por.organizationid
         and current_date between orl.effectivedate and orl.enddate
         and current_timestamp between orl.createts and orl.endts
         
         join cognos_orgstructure ros
         on ros.org2id = orl.memberoforgid
         and ros.org1type = 'Dept'
         and ros.org1id = orl.organizationid

         where current_timestamp between pi.createts and pi.endts
   
  )  rptorgstrc4 on rptorgstrc4.personid = pie.personid
  
    
 
where pie.identitytype = 'EmpNo'
  and current_timestamp between pie.createts and pie.endts
  and pa.stateprovincecode in ('BZ','CH','FR')
  and pe.emplstatus <> 'T'
  --and pe.effectivedate >= current_date - interval '30 days'
  --and pie.personid = '7371'
  order by 1,2,3
  
