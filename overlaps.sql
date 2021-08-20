JOIN EmployeeEnrollments AS pbe
ON pbe.personid = pe.personid
	AND (CURRENT_DATE between pbe.effectivedate AND pbe.enddate
    OR pbe.effectivedate > current_date)
 	AND current_date <= pbe.planyearenddate
 	AND ((pbe.effectivedate, pbe.enddate) overlaps (cppy.planyearstart, cppy.planyearend) OR cppy.planyearstart IS NULL) 
 ---This expression yields true when two time periods (defined by their endpoints) overlap, false when they do not overlap.
 
 select 
  pe.personid
 ,pe.effectivedate
 ,pe.emplstatus
 ,pbe.benefitelection
 ,pbe.benefitsubclass
 ,pbe.selectedoption
 ,pbe.effectivedate
 ,pbe.enddate
 ,cppy.planyearstart
 ,cppy.planyearend
 
   from person_employment pe 
   join comp_plan_plan_year cppy 
     on cppy.compplanplanyeartype = 'Bene'
   join person_bene_election pbe
     on pbe.personid = pe.personid
    and current_date between pbe.effectivedate and pbe.enddate
    and current_date <= pbe.planyearenddate
    --and ((pbe.effectivedate, pbe.enddate) overlaps (cppy.planyearstart, cppy.planyearend) OR cppy.planyearstart IS NULL) 
   
 where pe.personid = '836' and pbe.benefitelection = 'E' and pbe.selectedoption = 'Y' and pe.emplstatus = 'T';
 
 select * from person_bene_election where personid = '2176' and benefitsubclass = '11';
 select * from person_bene_election where personid = '2176' and benefitsubclass = '14';

 select 
  pe.personid
 ,pe.effectivedate
 ,pe.emplstatus
 ,pbe.benefitelection
 ,pbe.benefitsubclass
 ,pbe.selectedoption
 ,pbe.effectivedate
 ,pbe.enddate
 ,cppy.planyearstart
 ,cppy.planyearend
 
   from person_employment pe 
   join comp_plan_plan_year cppy 
     on cppy.compplanplanyeartype = 'Bene'
   join person_bene_election pbe
     on pbe.personid = pe.personid
    and current_date between pbe.effectivedate and pbe.enddate
    and current_date <= pbe.planyearenddate
    --and ((pe.effectivedate, pe.enddate) overlaps (pbe.deductionstartdate, pbe.planyearenddate) OR pbe.deductionstartdate IS NULL) 
    and ((pbe.effectivedate, pbe.enddate) overlaps (cppy.planyearstart, cppy.planyearend) OR cppy.planyearstart IS NULL) 
   
 where pe.personid = '2176' and pbe.benefitelection = 'E' and pbe.selectedoption = 'Y' and pe.emplstatus = 'T') 