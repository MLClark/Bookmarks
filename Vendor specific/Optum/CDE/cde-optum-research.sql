--SELECT * from benefit_plan_desc;
--select * from edi.edi_last_update;
--insert into edi.edi_last_update (feedid,lastupdatets) values ('CDE_OE_Optum_HSA_Changes','2019-09-01 00:00:00');

select * from position_comp_plan where compplanid in (select compplanid from comp_plan_plan_year where compplanplanyeartype = 'Bene');
select * from person_bene_election where personid = '305' and benefitsubclass in ('10', '6Z');


select * from comp_plan_plan_year where compplanplanyeartype = 'Bene';
select * from person_bene_election where benefitsubclass in ('10','6Z') and selectedoption = 'Y' and benefitelection = 'E' and effectivedate = '2020-01-01';

(select personid, ?::date, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid, pbe.compplanid, cppy.planyearstart, max(effectivedate) as effectivedate, max(enddate) as enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election pbe 
             left join comp_plan_plan_year cppy on cppy.compplanid = pbe.compplanid and cppy.compplanplanyeartype = 'Bene' 
                   and ?::date between cppy.planyearstart::date and cppy.planyearend::date			-- Checks for planYearStartDate parameter for OE and uses current_date for non-OE when planYearStartDate parameter is null
            where benefitsubclass = '6Z' and benefitelection = 'E' and selectedoption = 'Y' --and current_timestamp between createts and endts --and personid = '305'
              and case when ?::date > current_date then pbe.effectivedate >= cppy.planyearstart::date --and cppy.planyearend::date
                       else pbe.effectivedate < pbe.enddate and pbe.effectivedate > current_date and current_timestamp between createts and endts end

            group by personid, ?::date, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid, pbe.compplanid, cppy.planyearstart )   ;    