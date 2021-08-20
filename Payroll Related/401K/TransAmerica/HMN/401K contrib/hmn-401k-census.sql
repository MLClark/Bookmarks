select distinct
 pi.personid
,pe.emplclass

,'EB' ::char(2) as eb_id
,replace(pi.identity,'-','') ::char(9) as ssn 
,pip.identity ::char(15) as trankey
,' ' ::char(9) as fill01

      
,pn.lname ::char(30) as lname
,pn.title ::char(10) as suffix
,pn.fname ::char(20) as fname
,pn.mname ::char(20) as mname
,pv.gendercode ::char(1) as gender
--,pe.effectivedate
,to_char(cast (DATE_PART('year',current_date ::date) - DATE_PART('year',pe.effectivedate::date) as dec (18,0)),'000') as years_of_service
,'00000' ::char(5) as fill_zeroes_01
,to_char(pv.birthdate,'yyyymmdd')::char(8) as dob

,case when pp.schedulefrequency = 'H' then to_char((pp.scheduledhours * 24) / 52,'0000V99')
      when pp.schedulefrequency = 'S' then to_char(40,'0000V99')
      end as normal_sched_hours
,'0040'   ::char(4) as pay_sched_value
,to_char(pspdate.periodstartdate,'yyyymmdd')::char(8) as pay_schedule_date  -----Scheduled Date – use pay period begin date
,pa.streetaddress       ::char(30) as addr1
,pa.streetaddress2      ::char(30) as addr2
,' '                    ::char(30) as fill02
,pa.city                ::char(30) as city
,pa.stateprovincecode   ::char(2) as state
,pa.postalcode          ::char(5) as zip
,' '                    ::char(4) as zip_plus
,case when pa.countrycode = 'US' then 'USA' end ::char(3) as country
,case when pa.createts::date <> pa.effectivedate and date_part('year',pa.effectivedate) = date_part('year',current_date) then to_char(pa.effectivedate,'yyyymmdd') else ' ' end ::char(8) as addr_chg_date
,' ' ::char(354) as fill03
,to_char(pe.emplservicedate,'yyyymmdd') ::char(8) as adj_hire_date ---- use service date
,case when pe.emplstatus = 'A' then to_char(pe.empllasthiredate,'yyyymmdd') else to_char(pe.empllasthiredate,'yyyymmdd') end ::char(8) as last_hire_date 
,pe.emplclass ::char(6) as emp_class_ind

,to_char(pspdate.periodstartdate,'yyyymmdd')::char(8) as ft_pt_eff_date
,case when pp.schedulefrequency = 'H' then 'HOURLY' else 'SALARY' end ::char(6) as pay_type

,to_char(pspdate.periodstartdate,'yyyymmdd')::char(8) as pay_type_eff_date
,' ' ::char(28) as fill04

,to_char(pe.emplhiredate,'yyyymmdd')::char(8) as original_hire_date

,' ' ::char(377) as fill05
,to_char(current_date,'yyyymmdd')::char(8) as sysdate
,' ' ::char(1088) as fill06

,case when pe.empleventdetcode in ('STP','STF','ULSTP','ULSTF') then 'DISABS'
      when pe.empleventdetcode in ('LTP','LTF','ULLTP','ULLTF') then 'DISABL'
      when pe.empleventdetcode in ('ULCHD','ULFME','ULFMM','ULMLC','ULMLE') then 'LOAFM'
      when pe.empleventdetcode in ('SRed') then 'LAYOFF' 
      when pe.empleventdetcode in ('ULMIL') then 'LOAML'
      when pe.empleventdetcode in ('Death') then 'DEATHR'
      when pe.empleventdetcode in ('ULWC') then 'WKCOMP'
      
      when pe.emplevent in ('FullPart','Hire','PartFull','Rehire') then 'ACTIVE'
      when pe.emplevent in ('L','LOA w/o Pa') then 'LOANP'
      when pe.emplevent in ('Retire') then 'RETIRE'
      when pe.emplevent in ('InvTerm') then 'TERMIV'
      when pe.emplevent in ('VolTerm') then 'TERM'    
      ELSE 'ACTIVE' END ::CHAR(6) AS BENEFIT_STATUS

,case when pe.empleventdetcode in ('STP','STF','ULSTP','ULSTF') then to_char(pe.effectivedate,'yyyymmdd')
      when pe.empleventdetcode in ('LTP','LTF','ULLTP','ULLTF') then to_char(pe.effectivedate,'yyyymmdd')
      when pe.empleventdetcode in ('ULCHD','ULFME','ULFMM','ULMLC','ULMLE') then to_char(pe.effectivedate,'yyyymmdd')																						 
      when pe.empleventdetcode in ('SRed') then to_char(coalesce(pe.paythroughdate,pe.effectivedate),'yyyymmdd') -- 4/19/19 - Employment Status Effective Date (Termination Date changed to paythroughdate)
      when pe.empleventdetcode in ('ULMIL') then to_char(pe.effectivedate,'yyyymmdd')
      when pe.empleventdetcode in ('ULWC') then to_char(pe.effectivedate,'yyyymmdd')
      when pe.empleventdetcode in ('Death') then to_char(coalesce(pe.paythroughdate,pe.effectivedate),'yyyymmdd') -- 4/19/19 - Employment Status Effective Date (Termination Date changed to paythroughdate)
      when pe.empleventdetcode in ('LvR') then to_char(pe.effectivedate,'yyyymmdd')
      when pe.emplevent in ('VolTerm') then to_char(coalesce(pe.paythroughdate,pe.effectivedate),'yyyymmdd') -- 4/19/19 - Employment Status Effective Date (Termination Date changed to paythroughdate)
      when pe.emplevent in ('InvTerm') then to_char(coalesce(pe.paythroughdate,pe.effectivedate),'yyyymmdd') -- 4/19/19 - Employment Status Effective Date (Termination Date changed to paythroughdate)
      when pe.emplevent in ('Retire') then to_char(coalesce(pe.paythroughdate,pe.effectivedate),'yyyymmdd') -- 4/19/19 - Employment Status Effective Date (Termination Date changed to paythroughdate)
      when pe.emplevent in ('L','LOA w/o Pa') then to_char(pe.effectivedate,'yyyymmdd')
      when pe.emplevent in ('FullPart','Hire','PartFull','Rehire') then to_char(pe.empllasthiredate,'yyyymmdd')
      when pe.empleventdetcode in ('CHD','TP')then to_char(pe.empllasthiredate,'yyyymmdd')
      else ' ' end ::char(8) as benefit_status_eff_date

,case when pe.emplclass = 'T' then 'N' else 'Y' end ::char(1) as code_401k
,to_char(pspdate.periodstartdate,'yyyymmdd')::char(8) as eff_date_401k  ----– use pay period begin date

,case when pe.emplclass = 'T' then 'N'
      when pe.emplclass in ('P', 'F') and (cast (DATE_PART('year',current_date ::date) - DATE_PART('year',pe.emplhiredate::date) as dec (18,0)) ) < 1 
      then 'N' else 'Y' end ::char(1) as mppp_code ----Medicare Premium Payment Program (MPPP)?

,to_char(pspdate.periodstartdate,'yyyymmdd')::char(8) as mppp_eff_date ----MPPP Effective Date– use pay period begin date
,' ' ::char(38) as fill07
,to_char(pe.emplservicedate,'yyyymmdd')::char(8) as hire_date_401k ---- 401k Hire Date – use service date
,'00000000' ::char(8) as mppp_hire_date  ---MPPP Hire Date – zero fill 
,' ' ::char(232) as fill08
,'00' ::char(2) as hmn_group
,' ' ::char(29) as fill09
--,to_char(pe.effectivedate,'yyyymmdd')::char(8) as group_eff_date ----Group Effective Date – Recent Hire date


,case when pe.empleventdetcode in ('STP','STF','ULSTP','ULSTF') then to_char(pe.effectivedate,'yyyymmdd')
      when pe.empleventdetcode in ('LTP','LTF','ULLTP','ULLTF') then to_char(pe.effectivedate,'yyyymmdd')
      when pe.empleventdetcode in ('ULCHD','ULFME','ULFMM','ULMLC','ULMLE') then to_char(pe.effectivedate,'yyyymmdd')
      when pe.empleventdetcode in ('SRed') then to_char(pe.effectivedate,'yyyymmdd')
      when pe.empleventdetcode in ('ULMIL') then to_char(pe.effectivedate,'yyyymmdd')
      when pe.empleventdetcode in ('ULWC') then to_char(pe.effectivedate,'yyyymmdd')
      when pe.empleventdetcode in ('Death') then to_char(pe.effectivedate,'yyyymmdd')
      when pe.emplevent in ('VolTerm') then to_char(pe.effectivedate,'yyyymmdd')
      when pe.emplevent in ('InvTerm') then to_char(pe.effectivedate,'yyyymmdd')
      when pe.emplevent in ('Retire') then to_char(pe.effectivedate,'yyyymmdd')
      when pe.emplevent in ('L','LOA w/o Pa') then to_char(pe.effectivedate,'yyyymmdd')
      when pe.emplevent in ('FullPart','Hire','PartFull','Rehire') then to_char(pe.empllasthiredate,'yyyymmdd')
      when pe.empleventdetcode in ('LvR','CHD','TP')then to_char(pe.empllasthiredate,'yyyymmdd')
      else ' ' end ::char(8) as group_eff_date ----Group Effective Date – Recent Hire date.
,' ' ::char(346) as fill10
,'09878' ::char(5) client_id

      

 
from person_identity pi

join edi.edi_last_update elu on elu.feedid = 'HMN_401k_Census_File_Export'

join person_identity pip
  on pip.personid = pi.personid
 and pip.identitytype = 'PSPID'
 and current_timestamp between pip.createts and pip.endts
 
join person_names pn
  on pn.personid = pi.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts 

join person_address pa
  on pa.personid = pi.personid
 and pa.addresstype = 'Res'
 and current_date between pa.effectivedate and pa.enddate
 and current_timestamp between pa.createts and pa.endts

join person_vitals pv
  on pv.personid = pi.personid
 and current_date between pv.effectivedate and pv.enddate
 and current_timestamp between pv.createts and pv.endts 
 
join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts 
-- and pe.emplstatus = 'A'
 --and pe.emplevent = 'Hire'

left JOIN pers_pos pp 
  ON pp.personid = pi.personid 
 and current_date between pp.effectivedate and pp.enddate  
 AND current_timestamp between pp.createts AND pp.endts 
 AND pp.persposrel = 'Occupies'::bpchar

left join (select periodstartdate, periodenddate, periodpaydate from pay_schedule_period) pspdate
  on pspdate.periodpaydate = ?::date

where pi.identitytype = 'SSN'
  and current_date between pi.createts and pi.endts
  and ((pe.emplclass <> 'T') or (pe.employmenttype <> 'T'))
  ---and pe.emplevent in ('L','LOA w/o Pa') 
  --and pe.empleventdetcode in ('ULWC')
  and 
  
(      
exists (select 1 
          from person_identity pi1
         where pi1.personid     = pi.personid
           and pi1.identitytype = 'SSN' 
           and current_timestamp between pi1.createts and pi1.endts
           and pi1.createts >= elu.lastupdatets)
           -- select * from person_identity where personid = '63379' and createts >= '2018-01-01';
or
exists (select 1 
          from person_identity pip1
         where pip1.personid     = pi.personid
           and pip1.identitytype = 'PSPID' 
           and current_timestamp between pip1.createts and pip1.endts
           and pip1.createts >= elu.lastupdatets)        
or
exists (select 1 
          from person_names pn1
         where pn1.personid = pi.personid
           and pn1.nametype = 'Legal' 
           and current_date      between pn1.effectivedate and pn1.enddate
           and current_timestamp between pn1.createts      and pn1.endts
           and (pn1.effectivedate >= elu.lastupdatets::DATE 
            or (pn1.createts > elu.lastupdatets and pn1.effectivedate < coalesce(elu.lastupdatets, '2017-01-01')) ))
or
exists (select 1 
          from person_address pa1
         where pa1.personid = pi.personid
           and pa1.addresstype = 'Res' 
           and current_date      between pa1.effectivedate and pa1.enddate
           and current_timestamp between pa1.createts      and pa1.endts
           and (pa1.effectivedate >= elu.lastupdatets::DATE 
            or (pa1.createts > elu.lastupdatets and pa1.effectivedate < coalesce(elu.lastupdatets, '2017-01-01')) ))   
or
exists (select 1 
          from person_vitals pv1
         where pv1.personid = pi.personid
           and current_date      between pv1.effectivedate and pv1.enddate
           and current_timestamp between pv1.createts      and pv1.endts
           and (pv1.effectivedate >= elu.lastupdatets::DATE 
            or (pv1.createts > elu.lastupdatets and pv1.effectivedate < coalesce(elu.lastupdatets, '2017-01-01')) ))
or
exists (select 1 
          from person_employment pe1
         where pe1.personid = pi.personid
           and current_date      between pe1.effectivedate and pe1.enddate
           and current_timestamp between pe1.createts      and pe1.endts
           and (pe1.effectivedate >= elu.lastupdatets::DATE 
            or (pe1.createts > elu.lastupdatets and pe1.effectivedate < coalesce(elu.lastupdatets, '2017-01-01')) ))
or
exists (select 1 
          from person_compensation pc1
         where pc1.personid = pi.personid
           and current_date      between pc1.effectivedate and pc1.enddate
           and current_timestamp between pc1.createts      and pc1.endts
           and (pc1.effectivedate >= elu.lastupdatets::DATE 
            or (pc1.createts > elu.lastupdatets and pc1.effectivedate < coalesce(elu.lastupdatets, '2017-01-01')) ))
or
exists (select 1 
          from pers_pos pp1
         where pp1.personid = pi.personid
           and current_date      between pp1.effectivedate and pp1.enddate
           and current_timestamp between pp1.createts      and pp1.endts
           and (pp1.effectivedate >= elu.lastupdatets::DATE 
            or (pp1.createts > elu.lastupdatets and pp1.effectivedate < coalesce(elu.lastupdatets, '2017-01-01')) ))            
                              
) order by ssn
;

