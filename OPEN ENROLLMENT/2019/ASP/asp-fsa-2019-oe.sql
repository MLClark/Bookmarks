

select distinct
 pi.personid
,'M' ::char(1) as record_id
,to_char(pbels.effectivedate,'YYYY-MM-DD')::char(10) as effectivedate
,pn.lname ::char(20) as lname
,pn.fname ::char(18) as fname
,pn.mname ::char(1) as mname
,pa.streetaddress  ::char(30) as addr1
,pa.streetaddress2 ::char(30) as addr2
,pa.streetaddress3 ::char(30) as addr3
,pa.city ::char(25) as city
,pa.stateprovincecode ::char(2) as state
,pa.postalcode ::char(12) as zip
,lpad(pi.identity,11,'0') ::char(11) as ssn
,to_char(pv.birthdate,'YYYY-MM-DD') ::char(10) as dob
,ppch.phoneno ::char(10) as home_phone
,ppcw.phoneno ::char(10) as work_phone
,' ' ::char(5) as work_phone_ext
,'204308' ::char(7) as ls_group_nbr
,' ' ::char(5) as filler01
,'NB' ::char(2) as ls_cvg_type
,pie.identity ::char(15) as empno
,pe.emplstatus ::char(1) as activity
,pncw.url ::char(50) as email
,' ' ::char(153) as filler02
,case when pe.emplstatus in ('R','T','D') then to_char(pe.effectivedate,'YYYY-MM-DD') 
      else ' ' end ::char(10) as term_date
,case when pe.emplstatus in ('R','T') then 'G' 
      when pe.emplstatus in ('D') then 'B' -- Deceased
      else ' ' end ::char(1) as term_rsn
,' ' ::char(10) as billing_division_code
,'24' ::char(2) as pay_period
,' ' ::char(15) as filler

,'T' ::char(1) as trailer_record_type
,to_char(current_date,'YYYY-MM-DD')::char(10) as trailer_file_date
,'Chef Works, Inc' ::char(50) as trailer_group_name


from person_identity pi

join person_identity pie 
  on pie.personid = pi.personid
 and pie.identitytype = 'EmpNo'
 and current_timestamp between pie.createts and pie.endts
 
left join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts 

---- Legal Shield
join (select personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid, pbe.compplanid, max(effectivedate) as effectivedate, max(enddate) as enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election pbe 
             left join comp_plan_plan_year cppy on cppy.compplanid = pbe.compplanid and cppy.compplanplanyeartype = 'Bene' 
                   and ?::date between cppy.planyearstart::date and cppy.planyearend::date			-- Checks for planYearStartDate parameter for OE and uses current_date for non-OE when planYearStartDate parameter is null
            where benefitsubclass = '19' and benefitelection = 'E' and selectedoption = 'Y' and current_timestamp between pbe.createts and pbe.endts 
              and case when (?::date > current_date and pbe.effectivedate <= current_date + interval '120 days') then pbe.effectivedate >= cppy.planyearstart::date 
                       else pbe.effectivedate < pbe.enddate and pbe.effectivedate >= current_date and current_timestamp between pbe.createts and pbe.endts
                       end

            group by personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid, pbe.compplanid) pbels on pbels.personid = pi.personid and pbels.rank = 1         


left join person_names pn
  on pn.personid = pi.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts

left join person_address pa
  on pa.personid = pi.personid
 and pa.addresstype = 'Res'
 and current_date between pa.effectivedate and pa.enddate
 and current_timestamp between pa.createts and pa.endts 

left join person_vitals pv
  on pv.personid = pi.personid
 and current_date between pv.effectivedate and pv.enddate
 and current_timestamp between pv.createts and pv.endts 

left join (select personid, phoneno, phonecontacttype, effectivedate, enddate, createts, endts, rank() over (partition by personid order by effectivedate , createts ) as rank
             from person_phone_contacts where (current_date between effectivedate and enddate or (effectivedate > current_date and enddate > effectivedate)) and current_timestamp between createts and endts  
              and phonecontacttype in ('Home','Mobile')) ppch on ppch.personid = pi.personid and ppch.rank = 1

left join (select personid, phoneno, phonecontacttype, effectivedate, enddate, createts, endts, rank() over (partition by personid order by effectivedate , createts ) as rank
             from person_phone_contacts where (current_date between effectivedate and enddate or (effectivedate > current_date and enddate > effectivedate)) and current_timestamp between createts and endts  
              and phonecontacttype in ('Work')) ppcw on ppcw.personid = pi.personid and ppcw.rank = 1              
 
left join ( select personid, url, max(effectivedate) as effectivedate,  RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
              from person_net_contacts where netcontacttype = 'WRK' and current_date between effectivedate and enddate and current_timestamp between createts and endts
             group by personid, url) pncw on pncw.personid = pi.personid and pncw.rank = 1 
              
-- select * from person_phone_contacts where personid = '4069';
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  order by 1