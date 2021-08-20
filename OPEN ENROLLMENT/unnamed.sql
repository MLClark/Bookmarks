
select distinct

pi.personid
,'' as dependentid
--,pbemed.benefitelection
--,pbeden.benefitelection
--,pbevsn.benefitelection
-- ------------------- Add/Change/Delete Case -------------------------------------

,case when pe.emplstatus = 'T' then 'D' 
      when (pbemed.benefitelection in ('T','W') and pbeden.benefitelection  in ('T','W') and pbevsn.benefitelection in ('T','W')) then 'D'
      when ((pbemed.benefitelection = 'E' or pbeden.benefitelection = 'E' or pbevsn.benefitelection = 'E') and pbenpm.min_effectivedate = greatest(pbemed.effectivedate,pbeden.effectivedate,pbevsn.effectivedate)) then 'A'
      else 'C'
      end ::char(1) as transaction_code
-- --------------------------------------------------------------------------------
,'E' as emp_or_dep_code
,to_char(greatest(pbemed.effectivedate,pbeden.effectivedate,pbevsn.effectivedate), 'MMDDYYYY') as transaction_eff_date
,left(pi.identity,3)||'-'||substring(pi.identity,4,2)||'-'||substring(pi.identity,6,4)  as emp_ssn
,rtrim(pn.lname)::varchar(50) as last_name
,rtrim(ltrim(pn.fname))::varchar(50) as first_name
,rtrim(ltrim(pn.mname))::char(1)  as middle_name
,pv.gendercode ::char(1) as gender
,left(pi.identity,3)||'-'||substring(pi.identity,4,2)||'-'||substring(pi.identity,6,4)  as ssn
,to_char(pv.birthdate,'MMDDYYYY') ::char(8)  as dob
,to_char(pe.emplhiredate,'MMDDYYYY')::char(8)  as emp_doh
,rtrim(ltrim(pa.streetaddress))::varchar(50)  as emp_address
,rtrim(ltrim(pa.city))::varchar(50)  as emp_city
,rtrim(ltrim(pa.stateprovincecode))::char(2) as emp_state
,rtrim(ltrim(pa.postalcode))::char(9) as emp_zip
,rtrim(ltrim(ppch.phoneno,''))::varchar(10) as emp_phone

,case when pbemed.benefitsubclass = '10' then 'QVIMED' else ' ' end ::varchar(10) as med_plan
,case when pbemed.benefitsubclass = '10' and pbemed.effectivedate >= cppy.planyearstart then to_char(pbemed.effectivedate,'MMDDYYYY') else ' ' end as med_cov_effdt
,case when pbemed.benefitsubclass = '10' and pbemed.effectivedate >= cppy.planyearstart  and bcdmed.benefitcoveragedesc = 'Employee Only' then 'EE' 
      when pbemed.benefitsubclass = '10' and pbemed.effectivedate >= cppy.planyearstart  and bcdmed.benefitcoveragedesc = 'Employee + Spouse' then 'EE+SP' 
      when pbemed.benefitsubclass = '10' and pbemed.effectivedate >= cppy.planyearstart  and bcdmed.benefitcoveragedesc = 'Employee + Children' then 'EE+CH'
      when pbemed.benefitsubclass = '10' and pbemed.effectivedate >= cppy.planyearstart  and bcdmed.benefitcoveragedesc = 'Family' then 'FAM'
      else 'WAIVED' end ::varchar(10) as med_coverage


,case when pbeden.benefitsubclass = '11' then 'QVIDENT' else ' ' end ::varchar(10) as dent_plan
,case when pbeden.benefitsubclass = '11' and pbeden.effectivedate >= cppy.planyearstart then to_char(pbeden.effectivedate,'MMDDYYYY') else ' ' end as dent_cov_effdt 
,case when pbeden.benefitsubclass = '11' and pbeden.effectivedate >= cppy.planyearstart and bcdden.benefitcoveragedesc = 'Employee Only' then 'EE' 
      when pbeden.benefitsubclass = '11' and pbeden.effectivedate >= cppy.planyearstart and bcdden.benefitcoveragedesc = 'Employee + Spouse' then 'EE+SP' 
      when pbeden.benefitsubclass = '11' and pbeden.effectivedate >= cppy.planyearstart and bcdden.benefitcoveragedesc = 'Employee + Children' then 'EE+CH'
      when pbeden.benefitsubclass = '11' and pbeden.effectivedate >= cppy.planyearstart and bcdden.benefitcoveragedesc = 'Family' then 'FAM'
      else 'WAIVED'end ::varchar(10) as dent_coverage       
        
      
,case when pbevsn.benefitsubclass = '14' then 'QVIVIS' end ::varchar(10) as vision_plan
,case when pbevsn.benefitsubclass = '14' and pbevsn.effectivedate >= cppy.planyearstart then to_char(pbevsn.effectivedate,'MMDDYYYY') else ' ' end as vsn_cov_effdt 
,case when pbevsn.benefitsubclass = '14' and pbevsn.effectivedate >= cppy.planyearstart  and bcdvsn.benefitcoveragedesc = 'Employee Only' then 'EE' 
      when pbevsn.benefitsubclass = '14' and pbevsn.effectivedate >= cppy.planyearstart  and bcdvsn.benefitcoveragedesc = 'Employee + Spouse' then 'EE+SP' 
      when pbevsn.benefitsubclass = '14' and pbevsn.effectivedate >= cppy.planyearstart  and bcdvsn.benefitcoveragedesc = 'Employee + Children' then 'EE+CH'
      when pbevsn.benefitsubclass = '14' and pbevsn.effectivedate >= cppy.planyearstart  and bcdvsn.benefitcoveragedesc = 'Family' then 'FAM'
      else 'WAIVED' end ::varchar(10) as vision_coverage   
                  
from person_identity pi

left join edi.edi_last_update elu on feedid = 'BCE_med_den_vision_QVI_Benefits'

JOIN person_employment pe
  ON pe.personid = pi.personid
AND current_date BETWEEN pe.effectivedate AND pe.enddate
AND current_timestamp BETWEEN pe.createts AND pe.endts

--------------------------- Plan Year Joins ----------------------------------------

LEFT JOIN (select personid,positionid, max(createts) as createts, max(effectivedate) as effectivedate, max(enddate) as enddate,
     rank() over (partition by personid order by max(effectivedate) desc) as rank
from pers_pos persp 
where effectivedate < enddate and current_timestamp between createts and endts
group by 1,2) persp ON pe.personid = persp.personid and persp.rank = 1


LEFT JOIN position_comp_plan pcp on pcp.positionid = persp.positionid
   AND CURRENT_DATE BETWEEN pcp.effectivedate and pcp.enddate
   AND CURRENT_TIMESTAMP BETWEEN pcp.createts and pcp.endts
  
LEFT JOIN comp_plan_plan_year cppy on cppy.compplanid = pcp.compplanid
    AND cppy.compplanplanyeartype in ('Bene')
    AND ?::DATE between cppy.planyearstart and cppy.planyearend			-- Checks for planYearStartDate parameter for OE and uses current_date for non-OE when planYearStartDate parameter is null

LEFT JOIN person_names pn 
  ON pn.personid = pi.personid 
 AND pn.nametype = 'Legal'::bpchar 
 AND current_date between pn.effectivedate and pn.enddate
AND current_timestamp between pn.createts and pn.endts

LEFT JOIN person_vitals pv 
  on pv.personid = pi.personid
AND current_date between pv.effectivedate and pv.enddate
AND current_timestamp between pv.createts and pv.endts

LEFT JOIN person_address pa
  ON pa.personid = pi.personid 
 and pa.addresstype = 'Res'
and current_date between pa.effectivedate and pa.enddate
and current_timestamp between pa.createts and pa.endts

LEFT JOIN person_phone_contacts ppch
  ON ppch.personid = pi.personid 
 AND ppch.phonecontacttype = 'Home' 
 and current_date between ppch.effectivedate and ppch.enddate
and current_timestamp between ppch.createts and ppch.endts

--------------------------- Medical Joins ----------------------------------------

left JOIN (select pbemed.personid, pbemed.benefitsubclass, pbemed.benefitplanid, pbemed.benefitcoverageid, pbemed.benefitelection, pbemed.planyearenddate, max(pbemed.createts) as createts, max(pbemed.effectivedate) as effectivedate, max(pbemed.enddate) as enddate,
     rank() over (partition by pbemed.personid order by max(pbemed.effectivedate) desc) as rank
     from person_bene_election pbemed
     
	LEFT JOIN (select personid,positionid, max(createts) as createts, max(effectivedate) as effectivedate, max(enddate) as enddate,
	rank() over (partition by personid order by max(effectivedate) desc) as rank
	from pers_pos persp 
	where effectivedate < enddate and current_timestamp between createts and endts
	group by 1,2) persp ON pbemed.personid = persp.personid and persp.rank = 1

	LEFT JOIN position_comp_plan pcp on pcp.positionid = persp.positionid
	AND CURRENT_DATE BETWEEN pcp.effectivedate and pcp.enddate
	AND CURRENT_TIMESTAMP BETWEEN pcp.createts and pcp.endts
  
	LEFT JOIN comp_plan_plan_year cppy on cppy.compplanid = pcp.compplanid
	AND cppy.compplanplanyeartype = 'Bene'
	AND ?::date between cppy.planyearstart and cppy.planyearend			-- Checks for planYearStartDate parameter for OE and uses current_date for non-OE when planYearStartDate parameter is null

where pbemed.selectedoption  = 'Y' and pbemed.benefitsubclass in ('10') and current_timestamp between pbemed.createts and pbemed.endts --and pbeden.personid = '2320'
  and ((pbemed.benefitelection in ('E') and ((current_date between pbemed.effectivedate and pbemed.enddate) or (pbemed.effectivedate > current_date and pbemed.effectivedate < pbemed.enddate and pbemed.effectivedate between cppy.planyearstart and cppy.planyearend)))
   OR (pbemed.benefitelection in ('T','W') and pbemed.effectivedate < pbemed.enddate and pbemed.effectivedate between cppy.planyearstart and cppy.planyearend and pbemed.personid in (select personid from person_bene_election where benefitsubclass in ('10') and benefitelection = 'E' and selectedoption = 'Y' 
                        and current_timestamp between createts and endts and effectivedate < enddate and current_date - interval '1 day' between deductionstartdate and planyearenddate)))
                        
     group by 1,2,3,4,5,6) pbemed on pbemed.personid = pe.personid and pbemed.rank = 1
     
LEFT JOIN benefit_plan_desc bpdmed 
  on bpdmed.benefitsubclass = '10'
AND current_date between bpdmed.effectivedate and bpdmed.enddate
AND pbemed.benefitplanid = bpdmed.benefitplanid                      
AND current_timestamp between bpdmed.createts and bpdmed.endts

LEFT JOIN benefit_coverage_desc bcdmed 
  on bcdmed.benefitcoverageid = pbemed.benefitcoverageid 
 AND current_date between bcdmed.effectivedate and bcdmed.enddate
AND current_timestamp between bcdmed.createts and bcdmed.endts

--------------------------- Dental Joins ----------------------------------------

left JOIN (select pbeden.personid, pbeden.benefitsubclass, pbeden.benefitplanid, pbeden.benefitcoverageid, pbeden.benefitelection, pbeden.planyearenddate, max(pbeden.createts) as createts, max(pbeden.effectivedate) as effectivedate, max(pbeden.enddate) as enddate,
     rank() over (partition by pbeden.personid order by max(pbeden.effectivedate) desc) as rank
     from person_bene_election pbeden
     
	LEFT JOIN (select personid,positionid, max(createts) as createts, max(effectivedate) as effectivedate, max(enddate) as enddate,
	rank() over (partition by personid order by max(effectivedate) desc) as rank
	from pers_pos persp 
	where effectivedate < enddate and current_timestamp between createts and endts
	group by 1,2) persp ON pbeden.personid = persp.personid and persp.rank = 1

	LEFT JOIN position_comp_plan pcp on pcp.positionid = persp.positionid
	AND CURRENT_DATE BETWEEN pcp.effectivedate and pcp.enddate
	AND CURRENT_TIMESTAMP BETWEEN pcp.createts and pcp.endts
  
	LEFT JOIN comp_plan_plan_year cppy on cppy.compplanid = pcp.compplanid
	AND cppy.compplanplanyeartype = 'Bene'
	AND ?::date between cppy.planyearstart and cppy.planyearend			-- Checks for planYearStartDate parameter for OE and uses current_date for non-OE when planYearStartDate parameter is null

where pbeden.selectedoption  = 'Y' and pbeden.benefitsubclass in ('11') and current_timestamp between pbeden.createts and pbeden.endts --and pbeden.personid = '2320'
  and ((pbeden.benefitelection in ('E') and ((current_date between pbeden.effectivedate and pbeden.enddate) or (pbeden.effectivedate > current_date and pbeden.effectivedate < pbeden.enddate and pbeden.effectivedate between cppy.planyearstart and cppy.planyearend)))
   OR (pbeden.benefitelection in ('T','W') and pbeden.effectivedate < pbeden.enddate and pbeden.effectivedate between cppy.planyearstart and cppy.planyearend and pbeden.personid in (select personid from person_bene_election where benefitsubclass in ('11') and benefitelection = 'E' and selectedoption = 'Y' 
                        and current_timestamp between createts and endts and effectivedate < enddate and current_date - interval '1 day' between deductionstartdate and planyearenddate)))
                        
     group by 1,2,3,4,5,6) pbeden on pbeden.personid = pe.personid and pbeden.rank = 1
     
LEFT JOIN benefit_plan_desc bpdden  
  on bpdden.benefitsubclass = '11'
AND pbeden.benefitplanid = bpdden.benefitplanid                         
AND current_date between bpdden.effectivedate and bpdden.enddate
AND current_timestamp between bpdden.createts and bpdden.endts

LEFT JOIN benefit_coverage_desc bcdden 
  on bcdden.benefitcoverageid = pbeden.benefitcoverageid 
 AND current_date between bcdden.effectivedate and bcdden.enddate
AND current_timestamp between bcdden.createts and bcdden.endts
     
--------------------------- Vision Joins ----------------------------------------

left JOIN (select pbevsn.personid, pbevsn.benefitsubclass, pbevsn.benefitplanid, pbevsn.benefitcoverageid, pbevsn.benefitelection, pbevsn.planyearenddate, max(pbevsn.createts) as createts, max(pbevsn.effectivedate) as effectivedate, max(pbevsn.enddate) as enddate,
     rank() over (partition by pbevsn.personid order by max(pbevsn.effectivedate) desc) as rank
     from person_bene_election pbevsn
     
	LEFT JOIN (select personid,positionid, max(createts) as createts, max(effectivedate) as effectivedate, max(enddate) as enddate,
	rank() over (partition by personid order by max(effectivedate) desc) as rank
	from pers_pos persp 
	where effectivedate < enddate and current_timestamp between createts and endts
	group by 1,2) persp ON pbevsn.personid = persp.personid and persp.rank = 1

	LEFT JOIN position_comp_plan pcp on pcp.positionid = persp.positionid
	AND CURRENT_DATE BETWEEN pcp.effectivedate and pcp.enddate
	AND CURRENT_TIMESTAMP BETWEEN pcp.createts and pcp.endts
  
	LEFT JOIN comp_plan_plan_year cppy on cppy.compplanid = pcp.compplanid
	AND cppy.compplanplanyeartype = 'Bene'
	AND ?::date between cppy.planyearstart and cppy.planyearend			-- Checks for planYearStartDate parameter for OE and uses current_date for non-OE when planYearStartDate parameter is null

where pbevsn.selectedoption  = 'Y' and pbevsn.benefitsubclass in ('14') and current_timestamp between pbevsn.createts and pbevsn.endts --and pbeden.personid = '2320'
  and ((pbevsn.benefitelection in ('E') and ((current_date between pbevsn.effectivedate and pbevsn.enddate) or (pbevsn.effectivedate > current_date and pbevsn.effectivedate < pbevsn.enddate and pbevsn.effectivedate between cppy.planyearstart and cppy.planyearend)))
   OR (pbevsn.benefitelection in ('T','W') and pbevsn.effectivedate < pbevsn.enddate and pbevsn.effectivedate between cppy.planyearstart and cppy.planyearend and pbevsn.personid in (select personid from person_bene_election where benefitsubclass in ('14') and benefitelection = 'E' and selectedoption = 'Y' 
                        and current_timestamp between createts and endts and effectivedate < enddate and current_date - interval '1 day' between deductionstartdate and planyearenddate)))
                        
     group by 1,2,3,4,5,6) pbevsn on pbevsn.personid = pe.personid and pbevsn.rank = 1
     
LEFT JOIN benefit_plan_desc bpdvsn 
  on bpdvsn.benefitsubclass = '14'
AND pbevsn.benefitplanid = bpdvsn.benefitplanid                           
AND current_date between bpdvsn.effectivedate and bpdvsn.enddate
AND current_timestamp between bpdvsn.createts and bpdvsn.endts

LEFT JOIN benefit_coverage_desc bcdvsn
  on bcdvsn.benefitcoverageid = pbevsn.benefitcoverageid 
 AND current_date between bcdvsn.effectivedate and bcdvsn.enddate
AND current_timestamp between bcdvsn.createts and bcdvsn.endts

-- CHECK FOR NO PRIOR COVERAGE -----------------------------------------------

left join (select personid,benefitsubclass,benefitelection,min_effectivedate,max_effectivedate
        from (select pbe.personid,pbe.benefitsubclass,pbe.benefitelection,max(pbe.createts) as createts,min(pbe.effectivedate) as min_effectivedate,max(pbe.effectivedate) as max_effectivedate
              from person_bene_election pbe
              where pbe.benefitsubclass in ('10','11','14') and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate
              and pbe.selectedoption = 'Y' and pbe.benefitelection = 'E' group by 1,2,3 order by 1) effcovdate
        left join edi.edi_last_update elu on elu.feedid = 'BCE_med_den_vision_QVI_Benefits'
        where effcovdate.min_effectivedate = effcovdate.max_effectivedate
        and effcovdate.createts >= elu.lastupdatets					
        and effcovdate.personid not in (select pbe.personid from person_bene_election pbe
              join person_employment pe on pe.personid = pbe.personid and current_date between pe.effectivedate and pe.enddate and current_timestamp between pe.createts and pe.endts
              where pbe.benefitelection = 'E'
              and current_timestamp between pbe.createts and pbe.endts 
              and pbe.enddate < current_date 
              and pbe.effectivedate < pbe.enddate
              and pbe.benefitsubclass in  ('10','11','14')
              and pbe.effectivedate >= pe.empllasthiredate)order by 1) pbenpm on pbenpm.personid = pe.personid 
    
WHERE pi.identitytype = 'SSN'
  AND CURRENT_TIMESTAMP BETWEEN pi.createts and pi.endts 
  and (greatest(pbemed.effectivedate,pbeden.effectivedate,pbevsn.effectivedate) >= elu.lastupdatets::DATE                                                                                        
  or (greatest(pbemed.createts,pbeden.createts,pbevsn.createts) > elu.lastupdatets::date and greatest(pbemed.effectivedate,pbeden.effectivedate,pbevsn.effectivedate) < coalesce(elu.lastupdatets::date, '2017-01-01')))
               --AND ((pbemed.effectivedate, pbemed.enddate) overlaps (cppy.planyearstart, cppy.planyearend)
		--and (pbeden.effectivedate, pbeden.enddate) overlaps (cppy.planyearstart, cppy.planyearend)
		--and (pbevsn.effectivedate, pbevsn.enddate) overlaps (cppy.planyearstart, cppy.planyearend)
		--or cppy.planyearstart IS NULL)

-- -----------------DEPENDENTS -----------------------------------------------------------------------------------------------------------------------------------------------------------------
union

select distinct

pi.personid 
,pdr.dependentid as dependentid
-- ------------------- Add/Change/Delete Case -------------------------------------     
,case when pe.emplstatus = 'T' then 'D' 
      when (pbemed.benefitelection in ('T','W') and pbeden.benefitelection  in ('T','W') and pbevsn.benefitelection in ('T','W'))then 'D'
      when (current_date > demed.enddate and current_date > dednt.enddate and current_date > devsn.enddate) 
	or (cppy.planyearend >= greatest(demed.enddate,dednt.enddate,devsn.enddate)) then 'D'
      when greatest(demed.effectivedate,dednt.effectivedate,devsn.effectivedate) >= elu.lastupdatets and denpm.min_effectivedate = greatest(demed.effectivedate,dednt.effectivedate,devsn.effectivedate)then 'A'
      else 'C'
      end ::char(1) as transaction_code
-- -------------------------------------------------------------------------------
,'D' as emp_or_dep_code
,to_char(greatest(pbemed.effectivedate,pbeden.effectivedate,pbevsn.effectivedate), 'MMDDYYYY') as transaction_eff_date
,left(pi.identity,3)||'-'||substring(pi.identity,4,2)||'-'||substring(pi.identity,6,4)  as emp_ssn
,rtrim(ltrim(pnd.lname)) ::varchar(50) as last_name
,rtrim(ltrim(pnd.fname)) ::varchar(50) as first_name
,rtrim(ltrim(pnd.mname)) ::char(1)     as middle_name
,pvd.gendercode ::char(1) as gender
,left(pid.identity,3)||'-'||substring(pid.identity,4,2)||'-'||substring(pid.identity,6,4)  as  ssn
,to_char(pvd.birthdate, 'MMDDYYYY') ::char(8) as dob
,' ' ::char(1) as emp_doh

,' ' ::char(1) as emp_address
,' ' ::char(1) as emp_city
,' ' ::char(1) as emp_state
,' ' ::char(1) as emp_zip
,' ' ::char(1) as emp_phone

,case when demed.benefitsubclass = '10' then 'QVIMED' else null end ::varchar(15) as med_plan
,' ' ::char(1) as med_cov_effdt
,' ' ::CHAR(1) AS med_coverage
,case when dednt.benefitsubclass = '11' then 'QVIDENT' else null end ::varchar(15) as dent_plan
,' ' ::char(1) as dent_cov_effdt
,' ' ::CHAR(1) AS dent_coverage
,case when devsn.benefitsubclass = '14' then 'QVIVIS' else null end ::varchar(15) as vision_plan
,' ' ::char(1) as vsn_cov_effdt
,' ' ::CHAR(1) AS vision_coverage

from person_identity pi

left join edi.edi_last_update elu on feedid = 'BCE_med_den_vision_QVI_Benefits'

left JOIN person_employment pe
  ON pe.personid = pi.personid
 AND current_date between pe.effectivedate and pe.enddate
 AND current_timestamp BETWEEN pe.createts AND pe.endts

--------------------------- PLAN YEAR JOINS ----------------------------------------

LEFT JOIN (select personid,positionid, max(createts) as createts, max(effectivedate) as effectivedate, max(enddate) as enddate,
     rank() over (partition by personid order by max(effectivedate) desc) as rank
from pers_pos persp 
where effectivedate < enddate and current_timestamp between createts and endts
group by 1,2) persp ON pe.personid = persp.personid and persp.rank = 1

LEFT JOIN position_comp_plan pcp on pcp.positionid = persp.positionid
   AND CURRENT_DATE BETWEEN pcp.effectivedate and pcp.enddate
   AND CURRENT_TIMESTAMP BETWEEN pcp.createts and pcp.endts
  
LEFT JOIN comp_plan_plan_year cppy on cppy.compplanid = pcp.compplanid
    AND cppy.compplanplanyeartype = 'Bene'
    AND ?::date between cppy.planyearstart and cppy.planyearend			-- Checks for planYearStartDate parameter for OE and uses current_date for non-OE when planYearStartDate parameter is null

--------------------------- EE MEDICAL JOIN ----------------------------------------

left JOIN (select pbemed.personid, pbemed.benefitsubclass,pbemed.benefitplanid, pbemed.benefitcoverageid, pbemed.benefitelection, pbemed.planyearenddate, max(pbemed.createts) as createts, max(pbemed.effectivedate) as effectivedate, max(pbemed.enddate) as enddate,
     rank() over (partition by pbemed.personid order by max(pbemed.effectivedate) desc) as rank
     from person_bene_election pbemed
     
	LEFT JOIN (select personid,positionid, max(createts) as createts, max(effectivedate) as effectivedate, max(enddate) as enddate,
	rank() over (partition by personid order by max(effectivedate) desc) as rank
	from pers_pos persp 
	where effectivedate < enddate and current_timestamp between createts and endts
	group by 1,2) persp ON pbemed.personid = persp.personid and persp.rank = 1

	LEFT JOIN position_comp_plan pcp on pcp.positionid = persp.positionid
	AND CURRENT_DATE BETWEEN pcp.effectivedate and pcp.enddate
	AND CURRENT_TIMESTAMP BETWEEN pcp.createts and pcp.endts
  
	LEFT JOIN comp_plan_plan_year cppy on cppy.compplanid = pcp.compplanid
	AND cppy.compplanplanyeartype = 'Bene'
	AND ?::date between cppy.planyearstart and cppy.planyearend			-- Checks for planYearStartDate parameter for OE and uses current_date for non-OE when planYearStartDate parameter is null

where pbemed.selectedoption  = 'Y' and pbemed.benefitsubclass in ('10') and current_timestamp between pbemed.createts and pbemed.endts --and pbeden.personid = '2320'
  and ((pbemed.benefitelection in ('E') and ((current_date between pbemed.effectivedate and pbemed.enddate) or (pbemed.effectivedate > current_date and pbemed.effectivedate < pbemed.enddate and pbemed.effectivedate between cppy.planyearstart and cppy.planyearend)))
   OR (pbemed.benefitelection in ('T','W') and pbemed.effectivedate < pbemed.enddate and pbemed.effectivedate between cppy.planyearstart and cppy.planyearend and pbemed.personid in (select personid from person_bene_election where benefitsubclass in ('10') and benefitelection = 'E' and selectedoption = 'Y' 
                        and current_timestamp between createts and endts and effectivedate < enddate and current_date - interval '1 day' between deductionstartdate and planyearenddate)))
                        
     group by 1,2,3,4,5,6) pbemed on pbemed.personid = pe.personid and pbemed.rank = 1
     
--------------------------- EE DENTAL JOIN ----------------------------------------

left JOIN (select pbeden.personid, pbeden.benefitsubclass,pbeden.benefitplanid, pbeden.benefitcoverageid, pbeden.benefitelection, pbeden.planyearenddate, max(pbeden.createts) as createts, max(pbeden.effectivedate) as effectivedate, max(pbeden.enddate) as enddate,
     rank() over (partition by pbeden.personid order by max(pbeden.effectivedate) desc) as rank
     from person_bene_election pbeden
     
	LEFT JOIN (select personid,positionid, max(createts) as createts, max(effectivedate) as effectivedate, max(enddate) as enddate,
	rank() over (partition by personid order by max(effectivedate) desc) as rank
	from pers_pos persp 
	where effectivedate < enddate and current_timestamp between createts and endts
	group by 1,2) persp ON pbeden.personid = persp.personid and persp.rank = 1

	LEFT JOIN position_comp_plan pcp on pcp.positionid = persp.positionid
	AND CURRENT_DATE BETWEEN pcp.effectivedate and pcp.enddate
	AND CURRENT_TIMESTAMP BETWEEN pcp.createts and pcp.endts
  
	LEFT JOIN comp_plan_plan_year cppy on cppy.compplanid = pcp.compplanid
	AND cppy.compplanplanyeartype = 'Bene'
	AND ?::date between cppy.planyearstart and cppy.planyearend			-- Checks for planYearStartDate parameter for OE and uses current_date for non-OE when planYearStartDate parameter is null

where pbeden.selectedoption  = 'Y' and pbeden.benefitsubclass in ('11') and current_timestamp between pbeden.createts and pbeden.endts --and pbeden.personid = '2320'
  and ((pbeden.benefitelection in ('E') and ((current_date between pbeden.effectivedate and pbeden.enddate) or (pbeden.effectivedate > current_date and pbeden.effectivedate < pbeden.enddate and pbeden.effectivedate between cppy.planyearstart and cppy.planyearend)))
   OR (pbeden.benefitelection in ('T','W') and pbeden.effectivedate < pbeden.enddate and pbeden.effectivedate between cppy.planyearstart and cppy.planyearend and pbeden.personid in (select personid from person_bene_election where benefitsubclass in ('11') and benefitelection = 'E' and selectedoption = 'Y' 
                        and current_timestamp between createts and endts and effectivedate < enddate and current_date - interval '1 day' between deductionstartdate and planyearenddate)))
                        
     group by 1,2,3,4,5,6) pbeden on pbeden.personid = pe.personid and pbeden.rank = 1

--------------------------- EE VISION JOIN ----------------------------------------

left JOIN (select pbevsn.personid, pbevsn.benefitsubclass,pbevsn.benefitplanid, pbevsn.benefitcoverageid, pbevsn.benefitelection, pbevsn.planyearenddate, max(pbevsn.createts) as createts, max(pbevsn.effectivedate) as effectivedate, max(pbevsn.enddate) as enddate,
     rank() over (partition by pbevsn.personid order by max(pbevsn.effectivedate) desc) as rank
     from person_bene_election pbevsn
     
	LEFT JOIN (select personid,positionid, max(createts) as createts, max(effectivedate) as effectivedate, max(enddate) as enddate,
	rank() over (partition by personid order by max(effectivedate) desc) as rank
	from pers_pos persp 
	where effectivedate < enddate and current_timestamp between createts and endts
	group by 1,2) persp ON pbevsn.personid = persp.personid and persp.rank = 1

	LEFT JOIN position_comp_plan pcp on pcp.positionid = persp.positionid
	AND CURRENT_DATE BETWEEN pcp.effectivedate and pcp.enddate
	AND CURRENT_TIMESTAMP BETWEEN pcp.createts and pcp.endts
  
	LEFT JOIN comp_plan_plan_year cppy on cppy.compplanid = pcp.compplanid
	AND cppy.compplanplanyeartype = 'Bene'
	AND ?::date between cppy.planyearstart and cppy.planyearend			-- Checks for planYearStartDate parameter for OE and uses current_date for non-OE when planYearStartDate parameter is null

where pbevsn.selectedoption  = 'Y' and pbevsn.benefitsubclass in ('14') and current_timestamp between pbevsn.createts and pbevsn.endts --and pbeden.personid = '2320'
  and ((pbevsn.benefitelection in ('E') and ((current_date between pbevsn.effectivedate and pbevsn.enddate) or (pbevsn.effectivedate > current_date and pbevsn.effectivedate < pbevsn.enddate and pbevsn.effectivedate between cppy.planyearstart and cppy.planyearend)))
   OR (pbevsn.benefitelection in ('T','W') and pbevsn.effectivedate < pbevsn.enddate and pbevsn.effectivedate between cppy.planyearstart and cppy.planyearend and pbevsn.personid in (select personid from person_bene_election where benefitsubclass in ('14') and benefitelection = 'E' and selectedoption = 'Y' 
                        and current_timestamp between createts and endts and effectivedate < enddate and current_date - interval '1 day' between deductionstartdate and planyearenddate)))
                        
     group by 1,2,3,4,5,6) pbevsn on pbevsn.personid = pe.personid and pbevsn.rank = 1

-- DEPENDENT RELATIONSHIP/INFO JOINS --------------------------------------------------
left join (select dependentid,personid,dependentrelationship, max(createts) as createts, max(effectivedate) as effectivedate, max(enddate) as enddate,
	rank() over (partition by dependentid order by max(effectivedate) desc) as rank
	from person_dependent_relationship
	where effectivedate < enddate and current_timestamp between createts and endts
	group by 1,2,3) pdr on pdr.personid = pi.personid and pdr.rank = 1

LEFT JOIN (select personid, identitytype, identity, max(createts) as createts, max(endts) as endts,
	rank() over (partition by personid order by max(createts) desc) as rank
	from person_identity pid 
	where identitytype = 'SSN' and current_timestamp between createts and endts
	group by 1,2,3) pid ON pid.personid = pdr.personid and pid.rank = 1

LEFT JOIN (select personid,fname,lname,mname,nametype,max(effectivedate) as effectivedate, max(enddate) as enddate,
	rank() over (partition by personid order by max(effectivedate) desc) as rank
	from person_names pnd
	where effectivedate < enddate and current_timestamp between createts and endts and nametype = 'Dep'
	group by 1,2,3,4,5) pnd ON pnd.personid = pdr.dependentid and pnd.rank = 1

LEFT JOIN (select personid, birthdate, gendercode, max(effectivedate) as effectivedate, max(enddate) as enddate,
	rank() over (partition by personid order by max(effectivedate) desc) as rank
	from person_vitals pvd
	where effectivedate < enddate and current_timestamp between createts and endts
	group by 1,2,3) pvd ON pvd.personid = pdr.dependentid and pvd.rank = 1

--------------------------- DEPENDENT ENROLLMENT MEDICAL JOIN ----------------------------------------

LEFT JOIN (select demed.personid, demed.dependentid, demed.benefitsubclass,demed.createts, demed.effectivedate,demed.enddate,
     rank() over (partition by demed.personid order by demed.effectivedate desc) as rank
     from dependent_enrollment demed
	LEFT JOIN (select personid,positionid, max(createts) as createts, max(effectivedate) as effectivedate, max(enddate) as enddate,
	rank() over (partition by personid order by max(effectivedate) desc) as rank
	from pers_pos persp 
	where effectivedate < enddate and current_timestamp between createts and endts
	group by 1,2) persp ON demed.personid = persp.personid and persp.rank = 1

	LEFT JOIN position_comp_plan pcp on pcp.positionid = persp.positionid
	AND CURRENT_DATE BETWEEN pcp.effectivedate and pcp.enddate
	AND CURRENT_TIMESTAMP BETWEEN pcp.createts and pcp.endts
  
	LEFT JOIN comp_plan_plan_year cppy on cppy.compplanid = pcp.compplanid
	AND cppy.compplanplanyeartype = 'Bene'
	AND ?::date between cppy.planyearstart and cppy.planyearend			-- Checks for planYearStartDate parameter for OE and uses current_date for non-OE when planYearStartDate parameter is null
    
where demed.selectedoption = 'Y' and demed.benefitsubclass = '10' and demed.effectivedate < demed.enddate and current_timestamp between demed.createts and demed.endts
	and demed.effectivedate <= cppy.planyearend --and demed.enddate > cppy.planyearstart
) demed on demed.personid = pe.personid and demed.dependentid = pdr.dependentid and demed.rank = 1

--------------------------- DEPENDENT ENROLLMENT DENTAL JOIN ----------------------------------------

LEFT JOIN (select dednt.personid, dednt.dependentid, dednt.benefitsubclass,dednt.createts, dednt.effectivedate,dednt.enddate,cppy.planyearstart,
     rank() over (partition by dednt.personid order by dednt.effectivedate desc) as rank
     from dependent_enrollment dednt
	LEFT JOIN (select personid,positionid, max(createts) as createts, max(effectivedate) as effectivedate, max(enddate) as enddate,
	rank() over (partition by personid order by max(effectivedate) desc) as rank
	from pers_pos persp 
	where effectivedate < enddate and current_timestamp between createts and endts
	group by 1,2) persp ON dednt.personid = persp.personid and persp.rank = 1

	LEFT JOIN position_comp_plan pcp on pcp.positionid = persp.positionid
	AND CURRENT_DATE BETWEEN pcp.effectivedate and pcp.enddate
	AND CURRENT_TIMESTAMP BETWEEN pcp.createts and pcp.endts
  
	LEFT JOIN comp_plan_plan_year cppy on cppy.compplanid = pcp.compplanid
	AND cppy.compplanplanyeartype = 'Bene'
	AND ?::date between cppy.planyearstart and cppy.planyearend			-- Checks for planYearStartDate parameter for OE and uses current_date for non-OE when planYearStartDate parameter is null

    where dednt.selectedoption = 'Y' and dednt.benefitsubclass = '11' and dednt.effectivedate < dednt.enddate and current_timestamp between dednt.createts and dednt.endts
	and dednt.effectivedate <= cppy.planyearend --and dednt.enddate > cppy.planyearstart
     ) dednt on dednt.personid = pe.personid and dednt.dependentid = pdr.dependentid and dednt.rank = 1

--------------------------- DEPENDENT ENROLLMENT VISION JOIN ----------------------------------------

LEFT JOIN (select devsn.personid, devsn.dependentid, devsn.benefitsubclass,cppy.planyearstart,cppy.planyearend,devsn.createts, devsn.effectivedate,devsn.enddate,
     rank() over (partition by devsn.personid order by devsn.effectivedate desc) as rank
     from dependent_enrollment devsn
	LEFT JOIN (select personid,positionid, max(createts) as createts, max(effectivedate) as effectivedate, max(enddate) as enddate,
	rank() over (partition by personid order by max(effectivedate) desc) as rank
	from pers_pos persp 
	where effectivedate < enddate and current_timestamp between createts and endts
	group by 1,2) persp ON devsn.personid = persp.personid and persp.rank = 1

	LEFT JOIN position_comp_plan pcp on pcp.positionid = persp.positionid
	AND CURRENT_DATE BETWEEN pcp.effectivedate and pcp.enddate
	AND CURRENT_TIMESTAMP BETWEEN pcp.createts and pcp.endts
  
	LEFT JOIN comp_plan_plan_year cppy on cppy.compplanid = pcp.compplanid
	AND cppy.compplanplanyeartype = 'Bene'
	AND ?::date between cppy.planyearstart and cppy.planyearend			-- Checks for planYearStartDate parameter for OE and uses current_date for non-OE when planYearStartDate parameter is null

    where devsn.selectedoption = 'Y' and devsn.benefitsubclass = '14' and devsn.effectivedate < devsn.enddate and current_timestamp between devsn.createts and devsn.endts 
	and devsn.effectivedate <= cppy.planyearend --and devsn.enddate > cppy.planyearstart
     ) devsn on devsn.personid = pe.personid and devsn.dependentid = pdr.dependentid and devsn.rank = 1

-- CHECK FOR NO PRIOR COVERAGE -----------------------------------------------

left join (select personid,benefitsubclass,min_effectivedate,max_effectivedate
        from (select de.personid,de.benefitsubclass,max(de.createts) as createts,min(de.effectivedate) as min_effectivedate,max(de.effectivedate) as max_effectivedate
              from dependent_enrollment de
              where de.benefitsubclass in ('10','11','14') and current_timestamp between de.createts and de.endts and de.effectivedate < de.enddate
              and de.selectedoption = 'Y' group by 1,2 order by 1) effcovdate
        left join edi.edi_last_update elu on elu.feedid = 'BCE_med_den_vision_QVI_Benefits'
        where effcovdate.min_effectivedate = effcovdate.max_effectivedate
        and effcovdate.createts >= elu.lastupdatets) denpm on denpm.personid = pe.personid	


where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  and (greatest(pbemed.effectivedate,pbeden.effectivedate,pbevsn.effectivedate) >= elu.lastupdatets::DATE                                                                                        
   or (greatest(pbemed.createts,pbeden.createts,pbevsn.createts) > elu.lastupdatets::date and greatest(pbemed.effectivedate,pbeden.effectivedate,pbevsn.effectivedate) < coalesce(elu.lastupdatets::date, '2017-01-01'))) 
   
and greatest(demed.effectivedate,dednt.effectivedate,devsn.effectivedate) <= cppy.planyearend 

order by 1,2,4 desc
		