select distinct
 pi.personid
,pi.identity as empnbr
,pp.positionid
,pe.emplstatus

,pn.fname ::varchar(64) as fname
,'"'||pn.lname||'"' ::varchar(64) as lname
,pe.emplclass ::char(1) as pay_class
,pc.compamount
,pp.scheduledhours

,case when pc.frequencycode = 'H' then 'Hourly' else 'Salaried' end as pay_type
,case when pc.frequencycode = 'H' and pc.compamount > 100 then to_char(round((pc.compamount/greatest(pp.scheduledhours,2080)),2),'99999999.00')
      when pc.frequencycode = 'S' then to_char(pc.compamount,'99999999.00') else to_char(pc.compamount,'99999999.00') end as pay_rate
,pe.emplstatus ::char(1) as status  
,pc.compevent ::varchar(40) as reason_code   
,to_char(pc.effectivedate,'mm/dd/yyyy')::char(10) as effectivedate 
,pis.identity as ssn
,pc.earningscode as earning_code
,cpd.compplandesc as comp_plan_code

from person_identity pi

join person_identity pis
  on pis.personid = pi.personid 
 and pis.identitytype = 'SSN'
 and current_timestamp between pis.createts and pis.endts
 
join person_employment pe 
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts

join person_names pn
  on pn.personid = pi.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts
 
left join  (select personid, positionid, scheduledhours, schedulefrequency, max(effectivedate) as effectivedate, RANK() OVER (PARTITION BY personid ORDER BY max(effectivedate) DESC) AS RANK
             from pers_pos where effectivedate < enddate and current_timestamp between createts and endts
            group by personid, positionid, scheduledhours, schedulefrequency) pp on pp.personid = pe.personid and pp.rank = 1

left join person_compensation pc
  on pc.personid = pi.personid 

left join position_comp_plan pcp 
  on pcp.positionid = pp.positionid
 and current_date between pcp.effectivedate and pcp.enddate
 and current_timestamp between pcp.createts and pcp.endts
	
left join comp_plan_desc cpd 
  on cpd.compplanid = pcp.compplanid
 and current_date between cpd.effectivedate and cpd.enddate
 and current_timestamp between cpd.createts and cpd.endts 
	
where pi.identitytype = 'EmpNo'
  and current_timestamp between pi.createts and pi.endts 
    order by personid 
