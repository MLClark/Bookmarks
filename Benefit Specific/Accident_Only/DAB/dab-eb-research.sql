select * from benefit_plan_desc where benefitsubclass in 

(select benefitsubclass from comp_plan_benefit_plan where cobraplan = 'Y' group by 1);


select personid from person_bene_election where benefitsubclass in ('10','11','12','14');