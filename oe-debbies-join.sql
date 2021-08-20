join person_names pn
  on pn.personid = pi.personid
 and pn.nametype = 'Legal'
 and current_timestamp between pn.createts and pn.endts
 and (current_date between pn.effectivedate and pn.enddate or (pn.effectivedate > current_date and pn.enddate > pn.effectivedate))


join person_bene_election pbe
  on pbe.personid = pi.personid
 and pbe.benefitsubclass in ('60','61')
 and pbe.selectedoption = 'Y' 
 and pbe.benefitelection = 'E'
 and current_timestamp between pbe.createts and pbe.endts
 and (current_date between pbe.effectivedate and pbe.enddate or (pbe.effectivedate > current_date and pbe.enddate > pbe.effectivedate))

left join person_bene_election pbefsa
  on pbefsa.personid = pbe.personid
 and pbefsa.benefitsubclass = '60'
 and pbefsa.selectedoption = 'Y'
 and pbefsa.benefitelection = 'E'
 and current_timestamp between pbefsa.createts and pbefsa.endts
 and (current_date between pbefsa.effectivedate and pbefsa.enddate or (pbefsa.effectivedate > current_date and pbefsa.enddate > pbefsa.effectivedate))

left join person_bene_election pbedfsa
  on pbedfsa.personid = pbe.personid
 and pbedfsa.benefitsubclass = '61'
 and pbedfsa.selectedoption = 'Y'
 and pbedfsa.benefitelection = 'E'
 and current_timestamp between pbedfsa.createts and pbedfsa.endts
 and (current_date between pbedfsa.effectivedate and pbedfsa.enddate or (pbedfsa.effectivedate > current_date and pbedfsa.enddate > pbedfsa.effectivedate)) 