select distinct
 pi.personid
,pn.fname as fname
,pn.lname as lname
,coalesce(pncw.url,pnch.url) as email
,'"'||pie.identity||'"' as empid
,coalesce(pncw.url,pnch.url) as ssoid --- email
,null as salary
,null as region
,null as managereeid
,'USD' as paycurrencycode 
,'"'||substring(to_char(fc.annualfactor,'99') from 2 for 2) ||'"' as payperiods
,null as payrollcenter 
,null as payrollid
,'"'||pa.postalcode||'"' as zip
,pa.countrycode as countrycode
,null as workaddr1
,null as workaddr2
,la.city as workcity
,la.stateprovincecode as workstate
,null as mailstop
,null as workphone
,null as homeaddress
,null as homeaddr2
,null as homecity
,null as homestate
,null as homezip
,null as homecountrycode
,null as hiredate
,null as positiontitle
,null as division
,null as market
,null as businessunit
,null as deptname
,null as jobcode
,null as shiftcode
,'"'||lkup.value1||'"' as tempp  --- convert to lkup value
,null as eetype
,null as eesubtype
,null as eestatus
,null as subcocode
,null as sitecode
,null as fulltimetemp
,null as payrolltype
,null as payrollfilter
,null as matchtype
,null as customsegment
,null as custom1
,null as custom2
,null as custom3
,null as custom4
,null as custom5
,null as custom6
,null as custom7
,null as custom8
,null as custom9
,null as custom10
,null as custom11
,null as custom12
,null as custom13
,1 as iseeactive

from person_identity pi

join  ( select lkups.lookupname, lkups.lookupid,lkup.lookupid,lkup.key1,lkup.value1
         from edi.lookup lkup
         join edi.lookup_schema lkups
           on lkups.lookupid = lkup.lookupid
          and current_date between lkups.effectivedate and lkups.enddate
        where current_date between lkup.effectivedate and lkup.enddate 
      ) lkup on lkup.lookupname =  ('YourCause_EmployeeDemographic')
      
join person_employment pe
  on pe.personid = pi.personid
 and pe.emplstatus = 'A'
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts
 
join person_identity pie
  on pie.personid = pe.personid
 and pie.identitytype = 'EmpNo'
 and current_timestamp between pie.createts and pie.endts
 
left join person_names pn
  on pn.personid = pe.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts

left join person_address pa
  on pa.personid = pe.personid
 and pa.addresstype = 'Res'
 and current_date between pa.effectivedate and pa.enddate
 and current_timestamp between pa.createts and pa.endts 

left join person_locations pl 
  on pl.personid = pe.personid 
 and pl.personlocationtype = 'P'
 and current_date between pl.effectivedate and pl.enddate 
 and current_timestamp between pl.createts and pl.endts

left join location_address la 
  on pl.locationid = la.locationid 
 and current_date between la.effectivedate and la.enddate 
 and current_timestamp between la.createts and la.endts

left join person_net_contacts pncw 
  on pncw.personid = pi.personid 
 and pncw.netcontacttype = 'WRK'::bpchar 
 and current_date between pncw.effectivedate and pncw.enddate
 and current_timestamp between pncw.createts and pncw.endts  

left join person_net_contacts pnch
  on pnch.personid = pi.personid 
 and pnch.netcontacttype = 'HomeEmail'::bpchar 
 and current_date between pnch.effectivedate and pnch.enddate
 and current_timestamp between pnch.createts and pnch.endts  

left join (select personid, compamount, increaseamount, compevent, frequencycode, earningscode, currencycode, max(createts) as createts, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate, RANK() OVER (PARTITION BY personid ORDER BY max(effectivedate)desc) AS RANK
             from person_compensation where effectivedate < enddate and current_timestamp between createts and endts  
            group by personid, compamount, increaseamount, compevent, frequencycode, earningscode, currencycode) as pc on pc.personid = pi.personid and pc.rank = 1   
  
left join  (select personid, positionid, scheduledhours, schedulefrequency, max(effectivedate) as effectivedate, RANK() OVER (PARTITION BY personid ORDER BY max(effectivedate) DESC) AS RANK
             from pers_pos where effectivedate < enddate and current_timestamp between createts and endts
            group by personid, positionid, scheduledhours, schedulefrequency) pp on pp.personid = pe.personid and pp.rank = 1  

left join  (select pp.personid, pp.scheduledhours, coalesce(payper.num_payperiods, 0::integer) as num_pp, pp.scheduledhours * coalesce(payper.num_payperiods, 0::integer) as ytdhrs
		    from pers_pos pp
		   left join (select personid, count(*) as num_payperiods from pspay_payment_header where record_stat = 'A' and check_date >= date_trunc('year', now()) 
		              group by personid order by personid) payper
		      on payper.personid = pp.personid where current_date between effectivedate and enddate and current_timestamp between createts and endts) as salhrs 
  on salhrs.personid = pe.personid

left join pay_unit pu --- select * from frequency_codes;
  on pu.frequencycode = 'S'
left join frequency_codes fc
  on fc.frequencycode = pu.frequencycode
  
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts