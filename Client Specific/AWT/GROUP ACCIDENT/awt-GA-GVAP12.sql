---- accident for awt employee
select distinct
 pi.personid
,pe.emplstatus
,pne.lname ::varchar(35) as last_name
,pne.fname ::varchar(35) as first_name 
,'12' ::char(2) as record_type
,replace(pi.identity,'-','') ::char(9) as essn
,bcd.benefitcoveragecodexid
,case when bcd.benefitcoveragecodexid = 'EE' then '1'
      when bcd.benefitcoveragecodexid = 'EC' then '3'
      when bcd.benefitcoveragecodexid = 'ES' then '2'
      when bcd.benefitcoveragecodexid = 'F'  then '4' end ::char(1) cov_tier
,'N' ::char(1) as section_125 
,pbe.monthlyamount 
,pbe.coverageamount
--,cast(pboc.employeerate as dec(18,2)) as total_cost
,cast(pbe.monthlyamount * 100 as dec(18,0)) as total_cost
,case when pbe.benefitplanid = '58' then '200' else '300' end ::char(3) as base_plan_units
,'BER' ::char(10) as rider1
,'100' ::char(10) as rider1_amt

,' ' ::char(10) as rider2
,' ' ::char(10) as rider2_amt
,' ' ::char(10) as rider3
,' ' ::char(10) as rider3_amt
,' ' ::char(10) as rider4
,' ' ::char(10) as rider4_amt
,' ' ::char(10) as rider5
,' ' ::char(10) as rider5_amt
,' ' ::char(10) as rider6
,' ' ::char(10) as rider6_amt
,' ' ::char(10) as rider7
,' ' ::char(10) as rider7_amt
,' ' ::char(10) as rider8
,' ' ::char(10) as rider8_amt
,' ' ::char(10) as rider9
,' ' ::char(10) as rider9_amt
,' ' ::char(10) as rider10
,' ' ::char(10) as rider10_amt
,' ' ::char(10) as rider11
,' ' ::char(10) as rider11_amt
,' ' ::char(10) as rider12
,' ' ::char(10) as rider12_amt

,pc.frequencycode
,case when pc.frequencycode = 'H' then '52' else '26' end ::char(2) as prem_billing_mode
,to_char(pbe.effectivedate,'YYYYMMDD') ::char(8) first_ded_date
,to_char(pbe.effectivedate,'YYYYMMDD') ::char(8) req_issue_date
-- select * from location_codes where current_date between effectivedate and enddate and current_timestamp between createts and endts

,case when lc.locationcode = '400' then 'JG322' ---EPOCH Senior Living                               
      when lc.locationcode = '903' then 'MG395' ---Bridges at Westford                               
      when lc.locationcode = '805' then 'MH101' ---Bridges at Mashpee                                
      when lc.locationcode = '902' then 'LG719' ---Bridges at Hingham                                
      when lc.locationcode = '807' then 'MH494' ---Bridges at Nashua                                 
      when lc.locationcode = '901' then 'LG232' ---Waterstone at Wellesley                           
      when lc.locationcode = '804' then 'MH103' ---Bridges at Westwood                               
      when lc.locationcode = '806' then 'MH102' ---Bridges at Trumbull                               
      when lc.locationcode = '808' then '31909' ---Bridges at Pembroke                               
      else ' ' end ::char(10) as case_number
,case when pbe.benefitelection = 'T' then 'T' else ' ' end ::char(1) as status_code
,case when pe.emplstatus = 'T' then to_char(pe.effectivedate,'YYYYMMDD') else ' ' end ::char(8) term_stat_chg_date
--,case when pbe.benefitelection = 'T' then to_char(coalesce(pbe.effectivedate,pe.effectivedate),'YYYYMMDD') end ::char(8) as term_stat_chg_date
,concat( la.city || ', ' || la.stateprovincecode ) ::varchar(100) as signed_city_state
--,to_char(pbe.effectivedate, 'YYYYMMDD') ::char(8) as signature_date1

-----For the signature date we will take the createts for the earliest record for the plan year.
,to_char(sig.effectivedate, 'YYYYMMDD') ::char(8) as signature_date
,' ' ::char(1) as producers_name
,' ' ::char(1) as servicing_agent_nbr
,' ' ::char(1) as servicing_agent_split
,' ' ::char(1) as writing_agent_nbr
,' ' ::char(1) as writing_agent_split
,' ' ::char(1) as other_agent_nbr1
,' ' ::char(1) as other_agent_split1
,' ' ::char(1) as other_agent_nbr2
,' ' ::char(1) as other_agent_split2
,' ' ::char(1) as other_agent_nbr3
,' ' ::char(1) as other_agent_split3
,' ' ::char(1) as other_agent_nbr4
,' ' ::char(1) as other_agent_split4
,' ' ::char(1) as other_agent_nbr5
,' ' ::char(1) as other_agent_split5  


from person_identity pi

join person_bene_election pbe
  on pbe.personid = pi.personid
 and current_date between pbe.effectivedate and pbe.enddate
 and current_timestamp between pbe.createts and pbe.endts
 and pbe.benefitsubclass in ('13')
 and pbe.selectedoption = 'Y'
 and pbe.benefitelection in ('T', 'E' )
 and pbe.effectivedate - interval '1 day' <> pbe.enddate 

left join ( select personid, min(createts) as effectivedate
             from person_bene_election 
            where benefitsubclass in ('13')
            group by 1
      ) sig on sig.personid = pbe.personid

left join benefit_coverage_desc bcd
  on bcd.benefitcoverageid = pbe.benefitcoverageid
 and current_date between bcd.effectivedate and bcd.enddate
 and current_timestamp between bcd.createts and bcd.endts  

left join person_employment pe 
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts 
 and pe.effectivedate - interval '1 day' <> pe.enddate  
 
left join person_compensation pc
  on pc.personid = pi.personid
 and current_date between pc.effectivedate and pc.enddate
 and current_timestamp between pc.createts and pc.endts
 and pc.effectivedate - interval '1 day' <> pc.enddate 
 
--=======================================================--

left join person_dependent_relationship pdr
  on pdr.personid = pi.personid
 and current_date between pdr.effectivedate and pdr.enddate
 and current_timestamp between pdr.createts and pdr.endts
 and pdr.effectivedate - interval '1 day' <> pdr.enddate 
 
left join dependent_enrollment de
  on de.dependentid = pdr.dependentid
 and de.benefitsubclass = pbe.benefitsubclass
 and current_date between de.effectivedate and de.enddate
 and current_timestamp between de.createts and de.endts
 and de.effectivedate - interval '1 day' <> de.enddate

--=======================================================--
     
left outer join pers_pos pp
     on  (pi.personid = pp.personid
     and pp.effectivedate - interval '1 day' <> pp.enddate
     and CURRENT_DATE between pp.effectivedate and pp.enddate
     and current_timestamp between pp.createts and pp.endts)
left outer join position_desc pdd
     on (pp.positionid = pdd.positionid
     and pdd.effectivedate - interval '1 day' <> pdd.enddate
     and CURRENT_DATE between pdd.effectivedate and pdd.enddate
     and current_timestamp between  pdd.createts and  pdd.endts)
left outer join person_payroll ppy
     on (pi.personid = ppy.personid
     and ppy.effectivedate - interval '1 day' <> ppy.enddate
     and CURRENT_DATE between ppy.effectivedate and ppy.enddate
     and current_timestamp between ppy.createts and ppy.endts )
     
left join
  (select personid,max(positionid) as positionid from pers_pos
    where current_timestamp between createts and endts
      and current_timestamp between createts and endts
      and effectivedate - interval '1 day' <> enddate
      group by 1) ppt
  on ppt.personid = pe.personid

left outer join pay_unit_periods pup
     on (ppy.payunitid = pup.payunitid
     and pup.periodenddate = 
         (select min(periodenddate)
		      from pay_unit_periods ppp 
		     where ppp.payunitid = ppy.payunitid
			    and ppp.checkdate > pe.effectivedate))

left join pay_unit pu 
  on ppy.payunitid = pu.payunitid
 and pu.payunitid = '1'

left join person_locations pl 
  on pl.personid = pi.personid 
 and CURRENT_DATE BETWEEN pl.effectivedate AND pl.enddate 
 and CURRENT_TIMESTAMP BETWEEN pl.createts AND pl.endts
 and pl.effectivedate - interval '1 day' <> pl.enddate
 
left join person_names pne
  on pne.personid = pi.personid
 and pne.nametype = 'Legal'
 and current_date between pne.effectivedate and pne.enddate
 and current_timestamp between pne.createts and pne.endts
 and pne.effectivedate - interval '1 day' <> pne.enddate 

left join location_codes lc 
  on lc.locationid = pl.locationid 
 and CURRENT_DATE BETWEEN lc.effectivedate AND lc.enddate 
 and CURRENT_TIMESTAMP BETWEEN lc.createts AND lc.endts
 and lc.effectivedate - interval '1 day' <> lc.enddate

left join location_address la
  on la.locationid = pl.locationid
 and current_date between la.effectivedate and la.enddate
 and current_timestamp between la.createts and la.endts
 and la.effectivedate - interval '1 day' <> la.enddate

where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts 
  --and pe.emplstatus = 'A'
 -- and pi.personid in ('7128')
 --and pi.personid = '7106'
