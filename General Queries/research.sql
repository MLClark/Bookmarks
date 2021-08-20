select benefitsubclass from benefit_plan_desc  bpd where bpd.benefitsubclass IN ( '1W','13','30','31' )
select * from benefit_plan_desc bpd 
 where bpd.benefitsubclass = '13'
   and current_date between bpd.effectivedate and bpd.enddate
   and current_timestamp between bpd.createts and bpd.endts;
   
   
select * from person_bene_election pbe where pbe.benefitsubclass in
   (select benefitsubclass from benefit_plan_desc where edtcode = '403BCL' group by 1)
   and current_date between pbe.effectivedate and pbe.enddate
   and current_timestamp between pbe.createts and pbe.endts
;
select * from edi.edi_last_update;
select benefitsubclass from benefit_plan_desc where edtcode = '403BCL';

select identitytype from person_identity group by 1;

select * from person_identity where identitytype = 'SSN';

select * from person_identity where personid in ('432') and identitytype = 'SSN';
select * from person_identity where personid in ('1000') and identitytype = 'PSPID';
select * from edi.etl_employment_data ed where personid in ('1000')  ;
SELECT * FROM edi.etl_personal_info epi WHERE personid in (
select distinct personid from person_bene_election pbe where pbe.benefitsubclass = '61'
   and current_date between pbe.effectivedate and pbe.enddate
   and current_timestamp between pbe.createts and pbe.endts
)   
select * from edi.ediemployee ee where personid in ('1000')  ;
select * from edi.ediemployeebenefit eeb where personid in ('1000')  ;
select * from person_employment pe where personid in ('1000')  ;
select * from pers_pos pp where personid in ('1000')  
      AND pp.persposrel = 'Occupies'::bpchar 
      AND current_date between pp.effectivedate and pp.enddate 
      AND current_timestamp between pp.createts and pp.endts ;
select * from person_compensation pc where personid in ('828')       
      AND pc.enddate > pc.effectivedate 
      AND pc.earningscode <> 'BenBase'::bpchar 
      AND current_date between pc.effectivedate AND pc.enddate 
      AND current_timestamp between pc.createts AND pc.endts ;
select * from person_payroll ppr  where personid in ('828')      
      AND current_date between ppr.effectivedate and ppr.enddate
      AND current_timestamp between ppr.createts AND ppr.endts;
select * from pspay_payment_detail pdd  where personid in ('828')      
      AND current_date between ppr.effectivedate and ppr.enddate
      AND current_timestamp between ppr.createts AND ppr.endts;    
   
select * from person_address pa  where personid in ('1000')  
      AND pa.addresstype = 'Res'::bpchar 
      AND current_date between pa.effectivedate AND pa.enddate 
      AND current_timestamp between pa.createts AND pa.endts ; 
select * from person_bene_election pbe where personid in ('1742')  
      AND current_date between pbe.effectivedate and pbe.enddate
      AND current_timestamp between pbe.createts and pbe.endts
      --AND pbe.benefitplanid IN ( '14', '16', '17', '26', '65' )
      
      --AND pbe.benefitelection = 'E'
      AND pbe.selectedoption = 'Y';  
      
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



select * from person_vitals where personid in ('9639','9906')  
select * from edi.ediemployeebenefit where personid in ('9911')  
select pc.frequencycode from person_compensation pc group by 1;
select EPI.maritalstatus from  edi.etl_personal_info epi group by 1;
select pv.gendercode  from person_vitals pv group by 1;

select * from edi.etl_employment_term_data where personid in ('518');

select * from edi.edidependent where employeepersonid in ('9911');

select * from person_bene_election where personid in ('1742');   -- AND benefitsubclass in ('60','61');
select benefitplanid,benefitplandesc from benefit_plan_desc where edtcode = 'LIFE' group by 1,2;
select etv_id from pspay_payment_detail group by 1; --('VEH','VEK', 'VEJ') 
select * from pspay_etv_list where etv_id like 'V%';
select etv_id from pspay_etv_list where etv_short like '%HSA%';

select * from pspay_payment_detail where etv_amount > 0 and etv_id = 'VEK';
select * from person_compensation;
select etv_id from pspay_payment_detail group by 1;

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