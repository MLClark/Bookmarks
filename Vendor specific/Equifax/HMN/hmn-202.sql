WITH perschkdt AS
(select eemax.personid,  
  eemax.check_date AS check_date, psp.periodstartdate, psp.periodenddate, pu.payunitid, pu.payunitxid, pu.frequencycode, pu.employertaxid
        FROM (select dpmax.personid as personid, MAX(dpmax.check_date)  AS check_date
        	from cognos_payment_earnings_by_check_date dpmax 
       		where dpmax.check_date in ( ?::DATE , 
     		( SELECT periodpaydate FROM pay_schedule_period
        		 WHERE periodpaydate < ?::DATE        		 
        		   AND payrolltypeid = 1
     		ORDER BY periodpaydate desc limit 1)) GROUP BY dpmax.personid ) AS eemax
        join person_payroll pp on eemax.personid = pp.personid and current_date between pp.effectivedate and pp.enddate and current_timestamp between pp.createts and pp.endts
        LEFT JOIN pay_unit pu ON pu.payunitid = pp.payunitid 
 join pay_schedule_period psp on psp.payunitid = pu.payunitid and psp.periodpaydate = eemax.check_date AND payrolltypeid = 1
)  
select distinct

 perschkdt.personid
,pe.emplstatus 
,'ACTIVE EE' ::varchar(50) as qsource
,'1' ::char(1) as sort_seq
,'202EMPLPIM' ::char(15) as rectype
,'11340' ::char(16) as cocode
,replace(pi.identity,'-','') ::char(11) as ssn           
,replace(pi.identity,'-','') ::char(64) as empl_id       
,replace(pi.identity,'-','') ::char(64) as user_id
,'I19M' ::char(4) as inhousenum                          

,to_char(perschkdt.periodenddate::date,'yyyymmdd')::char(8) as pasofdate 
-- select * from person_names
,pn.fname ::char(64) as fname
,pn.mname ::char(64) as mname
,pn.lname ::char(64) as lname 
,pn.title ::char(12) as suffix
,null ::char(1) as title
,substring(pi.identity from 6 for 4) ::char(8) as dfpin
,'Y' ::char(1) as direct_login
,null ::char(1) as verdiv
,pd.positiontitle ::char(64) as jobtitle
,case when pe.emplstatus = 'T' then 'I' else 'A' end ::char(1) as eestatcd
,to_char(pe.empllasthiredate,'yyyymmdd')::char(8) as mrhdate
,pe.emplclass ::char(1) as eestattype
,to_char(pe.emplhiredate,'yyyymmdd')::char(8) as orighiredate

,case when pe.emplstatus not in ('A','L','P') then to_char(pe.paythroughdate,'yyyymmdd') else ' ' end ::char(8) as termdate
,null ::char(1) as termreason
,pe.emplevent
,case when pe.emplstatus not in ('A','L','P') then pe.empleventdetcode else ' ' end ::char(10) as uctermreason
,case when pe.emplstatus not in ('A','L','P') then to_char(pe.paythroughdate,'yyyymmdd') else ' ' end ::char(8) as lastdaywrkf

,la.stateprovincecode ::char(2) as wrkstate
--,xppd.positiontitle
--,pd.positiontitle
--,lc.locationcode 
,case when lc.locationcode = 'HO' and pd.positiontitle <> 'Agent' then 'HMNHO' 
      when lc.locationcode <> 'HO' and pd.positiontitle = 'Agent' then 'HMNFA' 
      else 'HMNFN' end ::char(20) as wrkloccd
      
,case when pe.emplstatus not in ('A','L','P') then rpad(''||pu.employertaxid,15,' ') else ' ' end ::char(15) as fein
,case when pe.emplstatus not in ('A','L','P') then rpad(''||puc.identification,15,' ') else ' ' end ::char(15) as suiacctnum   

,to_char(pe.emplservicedate,'yyyymmdd')::char(8) as adjhiredate
,null ::char(1) as yrsofserv
,null ::char(1) as mthofserv
--,pp.schedulefrequency 
,case when pp.schedulefrequency = 'S' then '05' else '04' end ::char(2) as payfreq
,' ' ::char(1) as twn_add
,' ' ::char(1) as ucx_add
,'U' ::char(1) as add_ind_1
,'home' ::char(20) as type_1
,pa.streetaddress ::char(60) as l1_1
,pa.streetaddress2 ::char(60) as l2_1
,pa.streetaddress3 ::char(60) as l3_1
,pa.city ::char(60) as city_1
,pa.stateprovincecode ::char(2) as state_1
,pa.postalcode ::char(16) as zip_1
,pa.countrycode ::char(2) as country_1
,to_char(pv.birthdate,'yyyymmdd')::char(8) as birth_date



from perschkdt 

join person_identity pi
  on perschkdt.personid = pi.personid
 and pi.identitytype = 'SSN'
 and current_timestamp between pi.createts and pi.endts

join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts
 
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

left join person_vitals pv
  on pv.personid = pi.personid
 and current_date between pv.effectivedate and pv.enddate
 and current_timestamp between pv.createts and pv.endts 
 
left join (select personid, positionid, scheduledhours, schedulefrequency, max(effectivedate) as effectivedate, RANK() OVER (PARTITION BY personid ORDER BY max(effectivedate) DESC) AS RANK
             from pers_pos where effectivedate < enddate and current_timestamp between createts and endts
            group by personid, positionid, scheduledhours, schedulefrequency) pp on pp.personid = pe.personid and pp.rank = 1

left join (select positionid, grade, positiontitle, flsacode, max(effectivedate) as effectivedate, RANK() OVER (PARTITION BY positionid ORDER BY max(effectivedate) DESC) AS RANK
             from position_desc where effectivedate < enddate and current_timestamp between createts and endts 
            group by positionid, grade, positiontitle, flsacode) pd on pd.positionid = pp.positionid and pd.rank = 1    

left join salary_grade sg
  on sg.grade = pd.grade
 and current_date between sg.effectivedate and sg.enddate
 and current_timestamp between sg.createts and sg.endts  
 
left join (select personid, locationid, max(effectivedate) as effectivedate, RANK() OVER (PARTITION BY personid ORDER BY max(effectivedate) DESC) AS RANK
             from person_locations where effectivedate < enddate and current_timestamp between createts and endts
            group by personid, locationid) pl on pl.personid = pp.personid and pl.rank = 1 

left join (select locationid, stateprovincecode, max(effectivedate) as effectivedate, RANK() OVER (PARTITION BY locationid ORDER BY max(effectivedate) DESC) AS RANK
             from location_address where effectivedate < enddate and current_timestamp between createts and endts
            group by locationid, stateprovincecode) la on la.locationid = pl.locationid and la.rank = 1             

 
left join pay_schedule_period psp 
  on psp.payrolltypeid in (1,2)
 and psp.processfinaldate is not null
 and psp.periodpaydate = ?::date

left join pspay_payment_header pph
  on pph.check_date = psp.periodpaydate
 and pph.payscheduleperiodid = psp.payscheduleperiodid 
 
left join pspay_payment_detail ppd 
  on ppd.personid = pi.personid
 and ppd.check_date = psp.periodpaydate
 and pph.paymentheaderid = ppd.paymentheaderid
 
left join person_payroll ppay
  on ppay.personid = pi.personid
 and current_date between ppay.effectivedate AND ppay.enddate
 and current_timestamp between ppay.createts AND ppay.endts 
 
left join pay_unit pu
  on pu.payunitid = ppay.payunitid
 and current_timestamp between pu.createts and pu.endts

left join pay_unit_configuration_type puct
  on puct.payunitconfigurationtypename = 'SUI'

left join pay_unit_configuration puc
  on puc.payunitconfigurationtypeid = puct.payunitconfigurationtypeid
 and puc.payunitid = pu.payunitid
 and current_date between puc.effectivedate and puc.enddate
 and current_timestamp between puc.createts and puc.endts
 and puc.stateprovincecode = la.stateprovincecode                         
            
left join location_codes lc
  on lc.locationid = la.locationid
 and current_date between lc.effectivedate and lc.enddate
 and current_timestamp between lc.createts and lc.endts 
 
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  --and pi.personid = '63126'

  order by personid    
  --limit 10
  