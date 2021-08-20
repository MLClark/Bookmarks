join person_names pn 
  on pn.personid = pe.personid
 and current_timestamp between pn.createts and pn.endts
 and (current_date between pn.effectivedate and pn.enddate
          or (pn.effectivedate > current_date and pn.enddate > pn.effectivedate))