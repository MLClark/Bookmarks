select * from edi.etl_employment_data where personid = '63090';

select * from person_employment where personid = '66162' and current_date between effectivedate and enddate and current_timestamp between createts and endts;

(SELECT personid, emplstatus, emplevent,  empleventdetcode, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate, 
            RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
            FROM person_employment pe1
            WHERE current_date between effectivedate and enddate
              AND current_timestamp BETWEEN createts AND endts
              and emplpermanency in ('T', 'P')
                   and personid = '66162'
            GROUP BY personid, emplstatus, emplevent, empleventdetcode )
            ;
SELECT * FROM person_names where personid = '68320';
select * from edi.etl_employment_term_data where personid = '63090';
select * from person_names where lname like 'Ruot%';

select * from pspay_etv_list ;
select * from pspay_payment_detail PPD where personid = '63840';

( select personid, phoneno, enddate, max(effectivedate) as effectivedate, max(endts) as endts,
  RANK() OVER (PARTITION BY personid ORDER BY max(endts) DESC) AS RANK
  from person_phone_contacts
  where phonecontacttype = 'Home' 
   and current_date between effectivedate and enddate 
   and current_timestamp between createts and endts
   group by personid, phoneno, enddate)
   ;

select * from person_phone_contacts where personid = '63099';
select * from pspay_payment_detail PPD where personid = '63840'
 and date_part('year',ppd.check_date)=date_part('year',current_date - interval '1 year')  
 and etv_id in  ('E01','E64','EB5','E05','EB8','E15','E16','E17','E18','E19','E20',
                 'ECA','EAJ','EAR','EB4','EAK','E30','EBF','E61','EA1','EB1','EBE',
                 'EBH','EA2','VBB','VBC','VBD','VBA','VBE','VEH','VEJ','EB7') ;
select * from pspay_payment_detail PPD where personid = '63840'
 and date_part('year',ppd.check_date)='2018'
 and etv_id in  ('E01','E64','EB5','E05','EB8','E15','E16','E17','E18','E19','E20',
                 'ECA','EAJ','EAR','EB4','EAK','E30','EBF','E61','EA1','EB1','EBE',
                 'EBH','EA2','VBB','VBC','VBD','VBA','VBE','VEH','VEJ') ;

       select individual_key
             ,current_earn_amount as shift_dif_amt
             ,to_char(round((mtd_earn_amount / ytd_earn_amount),1),'FM0d000' ) as shift_dif_rate
         from pspay_earning_accumulators
        where etv_id = 'E05'
          and date_part('year',last_updt_dt) = '2018'
          and date_part('month',last_updt_dt) = date_part('month',current_date)
      and individual_key = 'HMN00000099583';


       select *
         from pspay_earning_accumulators
        where etv_id = 'E05'
      and individual_key = 'HMN00000099583';

SELECT personid ,etv_id
                 ,coalesce(sum(etv_amount),0) as ALL_bonus
             FROM pspay_payment_detail            --- not ,'E64' hiring bonus - this is considered an earnings and is added to the gross
            WHERE etv_id in  ('E61','EA1','EB1','EBE','EBH','EA2')           
              --AND date_part('year', check_date) = '2017'
              --and check_number = 'AdjManual'
              and personid = '63185'
            GROUP BY 1,2;

SELECT *
             FROM pspay_earning_accumulators            --- not ,'E64' hiring bonus - this is considered an earnings and is added to the gross
            WHERE etv_id in  ('E61','EA1','EB1','EBE','EBH','EA2')     
              and individual_key = 'HMN00000012274'   
              --and current_payroll_status = 'P'
              AND year = '2017'
              ;            


SELECT personid, etv_id, etv_amount, check_number,check_date
                 --,sum(etype_hours) AS ytdhours
                 ,sum(etv_amount) as fica
             FROM pspay_payment_detail            
            WHERE etv_id in  ('T01','T13')           
              AND date_part('year', check_date) = '2017'
              and personid = '65727'
         GROUP BY personid,2,3,4,5;

SELECT * 
             FROM pspay_payment_detail            
            WHERE etv_id in  ('T01','T13')           
              AND date_part('year', check_date) = '2017'
              and personid = '65727';

              


SELECT * FROM pspay_payment_detail where etv_id = 'E05' AND date_part('year', check_date) = '2017'and individual_key = 'HMN00000022215';
       select *
         from pspay_earning_accumulators
        where etv_id = 'E05'
          and year = '2017'
       --   and current_payroll_status = 'P'
          and individual_key = 'HMN00000022215';

                
SELECT * FROM pay_schedule_period
select * from pspay_payment_detail where etv_id = 'EBF' ;
select * from pspay_deduction_accumulators where individual_key = 'HMN00000021932';
select * from pspay_earning_accumulators where individual_key = 'HMN00000021932';
select * from pspay_earning_accumulators where individual_key = 'HMN00000021932' and etv_id in ('EA1','EB1','EBE','EBH','EA2','EBI');
select * from pspay_tax_accumulators where individual_key = 'HMN00000021932' and etv_id in  ('T01','T13')  and year = '2017'  ;

select * from pspay_payment_detail where personid = '67866' and etv_id = 'EBF' and date_part('year',check_date) = '2017';

select * from position_desc where positionid in ('405000','401113');
select * from pers_pos where personid = '65993';
select * from person_compensation where personid = '65993';
select * from person_employment  where personid = '64838';
select individual_key, etv_amount, etv_id
         from  pspay_payment_detail 
        where  personid = '63402'
          AND check_date = ?::DATE;
select * from person_names where lname like 'Abrams%';

select * from pspay_EARNING_accumulators where individual_key = 'HMN00000099583';
select * from pspay_deduction_accumulators where individual_key = 'HMN00000016189';
select * from pspay_tax_accumulators  where individual_key = 'ARO00000050007' and current_payroll_status = 'A';
select * from pers_pos where personid = '65993';
select * from person_locations;

select * from positionorgreldetail where positionid = '389826';
select * from person_names where lname like 'Patarozzi%';
select * from dcpositiondesc;
select * from salary_grade_ranges;
select * from salary_grade_regions;
select * from positiondetails;
select * from salarY_grade;
select * from person_salary_allocation;
select * from person_employment where personid = '66266';
select * from pers_pos where personid = '65527';

                 left join person_compensation pc 
                   on pc.personid = pp.personid
                  --and current_date between pc.effectivedate and pc.enddate
                  and current_timestamp between pc.createts and pc.endts
                  and date_part('year',pc.effectivedate) = date_part('year',current_date - interval '1 year')
                  and pc.compevent = 'Merit'
                  and pc.earningscode = 'Regular'
                  and pc.enddate < '2100-12-31'


select * from pers_pos where personid = '65527';
select * from position_desc where positionid in ('404996');
select * from position_job where positionid in ('404996');
select * from job where jobid in ('70684', '68153');
select * from job_desc where jobid  in ('70684', '68153');

select * from job_desc where jobcode in ('A1900','A1619','B8514');

select * from person_user_field_vals  where personid = '62958';

select * from person_employment where emplevent like 'L%';
select * from person_names where personid = '66404';

select * from job_desc where jobid in ('69889','69895');
select * from position_job where jobid in ('69889','69895');

select * from dcpositiondesc;
select * from person_identity where personid = '63064';
select * from person_names where lname like 'Noll%';
select * from person_names where personid = '63527';
select * from person_employment where personid = '63064';
select * from federal_job_code ;

select * from positiontitlelb;
select * from pspay_etv_operators;
select * from pspay_etv_accumulator_codes;
select * from pspay_payroll_profile;
select * from person_payroll;
select * from person_etvearnings_totals;
select * from pspay_earning_accumulators where etv_id in ('E05','E06','E07') ;
select * from pspay_earning_limits;
select * from pspay_group_earnings where etv_id = 'E05';
select * from pspay_payment_detail where personid = '63064' and etv_id = 'V38';
select * from pspay_payment_detail where etv_id = 'E05' and personid = '63527';
select * from pspay_earning_accumulators where individual_key = 'HMN00000008993';
select * from pspay_financial_plan_accumulators where individual_key = 'HMN00000008993';

select * from pspay_etv_list ;
select * from pspay_deduction_accumulators where individual_key = 'HMN00000016189' and etv_id = 'V38';
select * from benefit_plan_desc  where current_date between effectivedate and enddate and current_timestamp between createts and endts;
select * from person_bene_election where personid = '63071';
select * from pspay_deduction_types;
select * from pspay_earning_types;
select * from pspay_earning_accumulators where etv_id = 'V38' and individual_key = 'HMN00000009233';

   select individual_key
         ,to_char(round((mtd_earn_amount / ytd_earn_amount),1),'FM0d000' ) as shift_dif_rate
     from pspay_earning_accumulators
    where etv_id = 'E05'
      and date_part('year',last_updt_dt) = date_part('year',current_date)
      and date_part('month',last_updt_dt) = date_part('month',current_date)
      and individual_key = 'HMN00000017265';
      

      
select * from pspay_edcc_system_erngs;
select * from pspay_edcc_system_taxable;
select * from pspay_group_earnings;
select * from person_user_field_vals where personid = '62958';
select * from batch_detail where personid = '63066' and etv_id = 'VBC';
select * from pspay_payment_detail where personid =  '63066' and etv_id = 'VBC';
select * from benefit_plan_desc where current_date between effectivedate and enddate and current_timestamp between createts and endts;
select * from person_bene_election where current_date between effectivedate and enddate and current_timestamp between createts and endts and personid = '63258';


                  left join positionorgreldetail porb 
                    ON porb.positionid = PP.positionid 
                   AND porb.posorgreltype = 'Budget' 
                   and current_date between porb.effectivedate and porb.enddate
                   and current_timestamp between porb.createts and porb.endts
                  
                  left join organization_code oc_cc
                    ON oc_cc.organizationid = porb.organizationid
                   AND oc_cc.organizationtype = 'CC'
                   and current_date between oc_cc.effectivedate and oc_cc.enddate 
                   and current_timestamp between oc_cc.createts and oc_cc.endts 
                   and oc_cc.effectivedate - interval '1 day' <> oc_cc.enddate  
                   --select * from positionorgreldetail where positionid = '389805'
                   
select * from position_desc where positionid = '404996';
select * from position_job where positionid = '404996';
select * from pers_pos where personid = '65527';
select * from job_desc;

select * from dcpositiondesc where positionid = '404996';
select * from positionorgreldetail where positionid in ('391264');
select * from organization_code where organizationid in ( select organizationid from pos_org_rel where positionid in ('401587'));
select * from pos_org_rel where positionid in ('401587') ;

select * from pos_org_rel where positionid in ('391264') and posorgreltype = 'Budget' and posorgrelevent in ( 'NewPos','NewOrgRel ')
   --and current_date between effectivedate and enddate
   and current_timestamp between createts and endts;
select * from pos_org_rel where positionid in ('401587') and posorgreltype = 'Budget' 
   and posorgrelevent in ( 'NewPos','NewOrgRel ')
   and current_date between effectivedate and enddate
   and current_timestamp between createts and endts;   
select * from pos_org_rel where positionid in ('391264') and posorgreltype = 'Budget' 
   and posorgrelevent in ( 'NewPos','NewOrgRel ')
   and current_date > effectivedate
   and enddate = '2199-12-31'
   and current_timestamp between createts and endts;  
select * from pos_org_rel where positionid in ('391264') and posorgreltype = 'Budget' 
   and posorgrelevent in ( 'NewPos','NewOrgRel ')
   and current_date > effectivedate
   and date_part('year',effectivedate)=date_part('year',current_date-interval '1 year')
   and effectivedate - interval '1 day' <> enddate
   and current_timestamp between createts and endts;  
      
select * from rpt_orgstructure;   
select * from edi.lookup ;