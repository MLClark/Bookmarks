select distinct

 pe.personid 
,pn.name
,pe.emplstatus
,pp.scheduledhours


from person_identity pi

join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts
 
join person_bene_election pbe
  on pbe.personid = pe.personid
 and pbe.benefitsubclass in ('1W','1S','1C','1I','13')
 and pbe.benefitelection = 'E'
 and pbe.selectedoption = 'Y'
 and current_date between pbe.effectivedate and pbe.enddate
 and current_timestamp between pbe.createts and pbe.endts

join person_names pn
  on pn.personid = pe.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts 

left join pers_pos pp
  on pp.personid = pe.personid
 and pp.effectivedate < pp.enddate
 and current_timestamp between pp.createts and pp.endts 
  --- select * from pers_pos where personid = '2691'
left join person_compensation pc
  on pc.personid = pp.personid
 and current_date between pc.effectivedate and pc.enddate
 and current_timestamp between pc.createts and pc.endts
 and pc.earningscode <> 'BenBase' 

where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  