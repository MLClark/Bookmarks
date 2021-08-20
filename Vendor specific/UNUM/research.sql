select * from person_phone_contacts;
select phonecontacttype from person_phone_contacts group by 1;
select rehireindicator from person_employment group by 1;
select * from pspay_employee_profile;
-- unum vol life / add
select * from benefit_plan_desc  bpd where bpd.benefitsubclass IN ('21','22','24','25','27','2Z')   
   and current_date between bpd.effectivedate and bpd.enddate
   and current_timestamp between bpd.createts and bpd.endts
;
-- unum basic life / ltd /std
select * from benefit_plan_desc  bpd where bpd.benefitsubclass IN ('20','23','30','31');
-- unum vol life / add
select benefitplanid from benefit_plan_desc  bpd where bpd.benefitsubclass IN ('21','22','24','25','27','2Z') group by 1;
-- unum basic life / ltd /std
select benefitplanid from benefit_plan_desc  bpd where bpd.benefitsubclass IN ('20','23','30','31') group by 1;

select benefitsubclass from benefit_plan_desc  bpd where benefitplancode LIKE '%ADD%' group by 1;
select * from benefit_plan_desc bpd 
 where bpd.benefitsubclass IN ( '61' )
   and current_date between bpd.effectivedate and bpd.enddate
   and current_timestamp between bpd.createts and bpd.endts
;
select * from edi.edi_last_update;
select * from benefit_plan_desc;


select * from person_identity where identitytype = 'SSN';

select * from person_identity where personid in ('3298') and identitytype = 'SSN';
select * from person_identity where personid in ('1000') and identitytype = 'PSPID';
select * from edi.etl_employment_data eed where personid in ('3345')  ;
SELECT * FROM edi.etl_personal_info epi WHERE personid in ('3345')  ;
select * from edi.ediemployee ee where personid in ('3345')  ;
select * from edi.ediemployeebenefit eeb where personid in ('1000')  ;
select * from person_employment pe where personid in ('3345')  ;


select benefitsubclass from person_bene_election group by 1;

      
select * from person_payroll ppr  where personid in ('3257')      
      AND current_date between ppr.effectivedate and ppr.enddate
      AND current_timestamp between ppr.createts AND ppr.endts;

select * from pers_pos pp where personid in ('3257')  
      AND pp.persposrel = 'Occupies'::bpchar 
      AND current_date between pp.effectivedate and pp.enddate 
      AND current_timestamp between pp.createts and pp.endts ;
      
select * from person_compensation pc where personid in ('3257')       
      AND pc.enddate > pc.effectivedate 
      AND pc.earningscode <> 'BenBase'::bpchar 
      AND current_date between pc.effectivedate AND pc.enddate 
      AND current_timestamp between pc.createts AND pc.endts ;

      
select * from pspay_payment_detail pdd  where personid in ('3257')      
      AND current_date between ppr.effectivedate and ppr.enddate
      AND current_timestamp between ppr.createts AND ppr.endts;    
   

select * from person_vitals pve where personid in ('3345','3901') 
 AND CURRENT_DATE BETWEEN pve.effectivedate AND pve.enddate
 AND CURRENT_TIMESTAMP BETWEEN pve.createts AND pve.endts   ;
    
select * from person_names pne where pne.personid  in ('3345','3901') 
 AND CURRENT_DATE BETWEEN pne.effectivedate AND pne.enddate
 AND CURRENT_TIMESTAMP BETWEEN pne.createts AND pne.endts ;
    
select * from person_address pa  where personid in ('1000')  
      AND pa.addresstype = 'Res'::bpchar 
      AND current_date between pa.effectivedate AND pa.enddate 
      AND current_timestamp between pa.createts AND pa.endts ; 
      
      
select * from person_locations pl  where personid in ('1742')   
      AND pl.personlocationtype = 'P'::bpchar 
      AND current_date between pl.effectivedate AND pl.enddate
      AND current_timestamp between pl.createts AND pl.endts;
             
select * from location_codes lc  ;

select * from person_phone_contacts ppc where personid in ('1742')
      AND current_date between ppc.effectivedate and ppc.enddate
      AND current_timestamp between ppc.createts and ppc.endts;
      
select * from person_phone_contacts ppc where       
         current_date between ppc.effectivedate and ppc.enddate
      AND current_timestamp between ppc.createts and ppc.endts
      and ppc.phonecontacttype = 'Work';      

      
      
select * from person_bene_election pbe where --personid in ('3345','3901') 
  --ON pbe.personid = pI.personid
 --AND 
 pbe.benefitplanid in ('14','15','16','25','26','27')
 AND pbe.benefitelection IN ('E','W')
 AND pbe.enddate = '2199-12-31' 
 AND CURRENT_DATE BETWEEN pbe.effectivedate AND pbe.enddate 
 AND CURRENT_TIMESTAMP BETWEEN pbe.createts AND pbe.endts
 ;
 
select * from 
person_bene_election pbe1
 where personid in ('3345','3901') 
 AND pbe1.personbeneelectionpid in 
   (SELECT MAX(pbe2.personbeneelectionpid) as personbeneelectionpid
      FROM person_bene_election pbe2
     WHERE pbe2.personid in ('3345','3901') 
       AND pbe2.benefitsubclass = '10'
       AND pbe2.benefitelection IN ('T','E','W')
       AND pbe2.enddate = '2199-12-31'
       AND CURRENT_DATE BETWEEN pbe2.effectivedate AND pbe2.enddate 
       AND CURRENT_TIMESTAMP BETWEEN pbe2.createts AND pbe2.endts
)  ;

 
 
select * from edi.ediemployeebenefit where personid in ('9911')  
select pc.frequencycode from person_compensation pc group by 1;
select EPI.maritalstatus from  edi.etl_personal_info epi group by 1;
select pv.gendercode  from person_vitals pv group by 1;

select * from edi.etl_employment_term_data where personid in ('9628');

--- dependents
select * from edi.edidependent where employeepersonid in ('3345');
SELECT * FROM person_dependent_relationship pdr WHERE PERSONID in ('3345')
      AND current_date between pdr.effectivedate and pdr.enddate
      AND current_timestamp between pdr.createts and pdr.endts;
select * from dependent_relationship dr ;
select * from dependent_enrollment de where personid in ('3345')
      AND current_date between de.effectivedate and de.enddate
      AND current_timestamp between de.createts and de.endts
      and de.benefitsubclass = '10';
select * from person_identity pid where personid in ('3901') and identitytype = 'SSN';

select * from person_bene_election where personid in ('1742');   -- AND benefitsubclass in ('60','61');
select benefitplanid,benefitplandesc from benefit_plan_desc where edtcode = 'LIFE' group by 1,2;
select etv_id from pspay_payment_detail group by 1; --('VEH','VEK', 'VEJ') 
select * from pspay_etv_list where etv_id like 'V%';
select etv_id from pspay_etv_list where etv_short like '%HSA%';

select * from pspay_payment_detail where etv_amount > 0 and etv_id = 'VEK';
select * from person_compensation;

 	SELECT distinct pd.individual_key
             , pd.check_date
             , coalesce(pd1x.employeramt, 0) as employeramt
             , coalesce(pd2x.employeeamt, 0) as employeeamt
          FROM pspay_payment_detail pd
        LEFT JOIN (select individual_key, sum(coalesce(etv_amount,0)) as employeramt from pspay_payment_detail pd1
                       where pd1.check_date = ?::date
                         AND pd1.etv_id             = 'VEK' 
                   group by individual_key ) pd1x on pd1x.individual_key = pd.individual_key              

--JT Add employee catchup amount in VEJ
        LEFT JOIN (select individual_key, sum(coalesce(etv_amount,0)) as employeeamt from pspay_payment_detail pd2
                       where pd2.check_date = ?::date
                         AND pd2.etv_id            in ('VEH', 'VEJ') 
--                         AND pd2.etv_id             = 'VEH' 
                       group by individual_key ) pd2x on pd2x.individual_key = pd.individual_key              
       --WHERE pd.check_date = (select max(check_date) from pspay_payment_detail)
       WHERE pd.check_date = ?::date
           AND pd.etv_id IN ('VEH','VEK', 'VEJ') 
--           AND pd.etv_id IN ('VEH','VEK') 

select netcontacttype from person_net_contacts group by 1;