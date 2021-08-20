select * from personcompanyrel where personid = '22960';
select * from personcompanyreldetails where personid in ('22960');
select * from person_company_rel where personid in ('22960')
and current_date between effectivedate and enddate
and current_timestamp between createts and endts;

select * from person_company_rel where personcompanyreltype in ('WF4', 'WF5')
and current_date between effectivedate and enddate
and current_timestamp between createts and endts;
select * from personassignment where personid = '86349';

select * from position_job where positionid = '157993';
select * from job_desc where jobid = '730';
select * from eeo_codes where eeocode = '11';

select * from job where jobid = '730';

select * from pers_pos 
 where personid = '6693'
   and current_date between effectivedate and enddate
   and current_timestamp between createts and endts;
   
select * from position_job 
 where positionid = '20503'
   and current_date between effectivedate and enddate
   and current_timestamp between createts and endts;


select * from person_company_rel where personid = '6693';
select * from person_compensation 
 where personid = '6693'
   and current_date between effectivedate and enddate
   and current_timestamp between createts and endts;
 
select * from person_employment
 where personid = '6693'
   and current_date between effectivedate and enddate
   and current_timestamp between createts and endts;
   
   
select * from dxpersonposition where personid = '6693';
select * from jobcodelist where jobcode = 'A6414';
select * from company_job where jobid = '49378';
select * from job where jobid = '49378';
select * from job_desc where jobcode = 'A6414';
select * from companyjobdet where jobid = '49378';
 SELECT j.jobid,
    '' AS detail_,
    j.effectivedate,
    j.jobdescpid,
    j.jobdesc,
    j.jobcode,
    f.flsacodedesc,
    e.eeocodedesc,
    j.federaljobcodeid,
    j.jobexperience,
    j.enddate,
    j.jobfamilyid
   FROM job_desc j
     JOIN eeo_codes e ON j.eeocode = e.eeocode
     JOIN flsa_codes f ON j.flsacode = f.flsacode
  WHERE 'now'::text::date < j.enddate AND now() >= j.createts AND now() <= j.endts
  and j.jobcode = 'A6414';
  
select * from person_company_rel where personid = '86349';
select * from pos_pos where topositionid = '86349';
select * from pos_org_rel where positionid = '326561';
select * from personposition where personid = '86349';
select * from job_desc where jobid = '730';
select * from eeo_codes where eeocode = '11';
select * from flsa_codes where flsacode = 'E';
select * from jobfamilyid;


 SELECT j.jobid,
    j.detail_,
    j.effectivedate,
    j.jobdescpid,
    j.jobdesc,
    j.jobcode,
    j.jobfamilyid,
    j.flsacodedesc,
    j.eeocodedesc,
    j.federaljobcodeid,
    j.jobexperience,
    j.enddate,
    c.companyid
   FROM jobcodelist j
     JOIN company_job c ON j.jobid = c.jobid
     where   j.jobcode = 'A6414';
;


select * from job;

select 
pp.personid
,pp.positionid
,pd.grade
,sg.grade
,sg.salarygradedesc
FROM pers_pos pp

JOIN position_desc pd ON pp.positionid = pd.positionid 
 and current_date between pd.effectivedate and pd.enddate
 and current_timestamp between pd.createts and pd.endts

join salary_grade sg on sg.grade = pd.grade
 and current_date between sg.effectivedate and sg.enddate
 and current_timestamp between sg.createts and sg.endts
where pp.personid = '22960';   
--select * from position_desc where positionid in ('326404', '326405', '326406');
select * from salary_grade where grade = '17';

select * from salary_grade where grade = '17';
select * from federaljobcodelist;
select * from federaljobcodeid;
select * from federal_job_code;

 SELECT j.jobid,
    j.detail_,
    j.effectivedate,
    j.jobdescpid,
    j.jobdesc,
    j.jobcode,
    j.jobfamilyid,
    j.flsacodedesc,
    j.eeocodedesc,
    j.federaljobcodeid,
    j.jobexperience,
    j.enddate,
    c.companyid
   FROM jobcodelist j
     JOIN company_job c ON j.jobid = c.jobid
     where j.jobid = '49378'
;
Select jobcode || Case
			When current_date between effectivedate and enddate Then '0'
			Else '1'
			End  as JobCode
		, jobdesc as JobCodeDescription
		, eeocode as FederalJobCode
		, Case
			When current_date between effectivedate and enddate Then '0'
			Else '1'
			End as Disabled
From job_desc
Order by JobCode ASC