select * from personbenoptioncostl where personid = '1347' and benefitelection = 'E' and personbeneelectionpid in 
(select personbeneelectionpid from person_bene_election where personid = '1347' and benefitelection = 'E' and selectedoption = 'Y'
   and current_date between effectivedate and enddate and current_timestamp between createts and endts and benefitsubclass = '31');