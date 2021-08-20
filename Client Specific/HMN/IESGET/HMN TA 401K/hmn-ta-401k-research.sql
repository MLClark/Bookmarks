
select * from person_employment where personid = '63368';

select * from person_identity where identity = '002686117';
select * from edi.edi_last_update;
update edi.edi_last_update set lastupdatets = '2018-09-18 23:59:04' where feedid in ('HMN_401k_Census_File_Export');  
2018-09-18 23:59:04


2018-08-21 23:59:01


select * from frequency_codes;
select * from pay_schedule_period;
select * from person_names where personid = '63368';
select * from person_compensation where personid = '66578';
select * from pers_pos where personid = '66578';
select * from person_address where personid = '66578';

select * from person_vitals where personid = '66578';

select * from person_names where lname like 'Pearse%';


select * from pspay_payment_detail limit 10;
select * from employment_events;

(select 1 
          from pers_pos pp1
          join edi.edi_last_update elu on elu.feedid = 'HMN_401k_Census_File_Export'
         where pp1.personid = '66578'
           and current_date      between pp1.effectivedate and pp1.enddate
           and current_timestamp between pp1.createts      and pp1.endts
           and (pp1.effectivedate >= elu.lastupdatets::DATE 
            or (pp1.createts > elu.lastupdatets and pp1.effectivedate < coalesce(elu.lastupdatets, '2017-01-01')) ))  ;
            
(select 1 
          from person_compensation pc1
          join edi.edi_last_update elu on elu.feedid = 'HMN_401k_Census_File_Export'
         where pc1.personid = '66578'
           and current_date      between pc1.effectivedate and pc1.enddate
           and current_timestamp between pc1.createts      and pc1.endts
           and (pc1.effectivedate >= elu.lastupdatets::DATE 
            or (pc1.createts > elu.lastupdatets and pc1.effectivedate < coalesce(elu.lastupdatets, '2017-01-01')) ));
                        
(select 1 
          from person_address pa1 
          join edi.edi_last_update elu on elu.feedid = 'HMN_401k_Census_File_Export'
         where pa1.personid = '66578'
           and pa1.addresstype = 'Res' 
           and current_date      between pa1.effectivedate and pa1.enddate
           and current_timestamp between pa1.createts      and pa1.endts
           and (pa1.effectivedate >= elu.lastupdatets::DATE 
            or (pa1.createts > elu.lastupdatets and pa1.effectivedate < coalesce(elu.lastupdatets, '2017-01-01')) )) ;
 (select 1 
          from person_names pn1
          join edi.edi_last_update elu on elu.feedid = 'HMN_401k_Census_File_Export'
         where pn1.personid = '66578'
           and pn1.nametype = 'Legal' 
           and current_date      between pn1.effectivedate and pn1.enddate
           and current_timestamp between pn1.createts      and pn1.endts
           and (pn1.effectivedate >= elu.lastupdatets::DATE 
            or (pn1.createts > elu.lastupdatets and pn1.effectivedate < coalesce(elu.lastupdatets, '2017-01-01')) ))  ;
(select 1 
          from person_employment pe1
          join edi.edi_last_update elu on elu.feedid = 'HMN_401k_Census_File_Export'
         where pe1.personid = '66578'
           and current_date      between pe1.effectivedate and pe1.enddate
           and current_timestamp between pe1.createts      and pe1.endts
           and (pe1.effectivedate >= elu.lastupdatets::DATE 
            or (pe1.createts > elu.lastupdatets and pe1.effectivedate < coalesce(elu.lastupdatets, '2017-01-01')) ))  ;        

(select 1 
          from person_vitals pv1
          join edi.edi_last_update elu on elu.feedid = 'HMN_401k_Census_File_Export'
         where pv1.personid = '66578'
           and current_date      between pv1.effectivedate and pv1.enddate
           and current_timestamp between pv1.createts      and pv1.endts
           and (pv1.effectivedate >= elu.lastupdatets::DATE 
            or (pv1.createts > elu.lastupdatets and pv1.effectivedate < coalesce(elu.lastupdatets, '2017-01-01')) ))  ;