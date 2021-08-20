select * from pers_pos where personid = '64531';
select * from pos_org_rel where  positionid = '404967' and posorgreltype = 'Budget';
select * from pos_org_rel where  positionid = '405238' and posorgreltype = 'Member';
select * from position_job where positionid = '404967' ;
select * from job_desc where jobid = '69248';
select * from organization_code where organizationid = '1314' and organizationtype = 'CC';
select * from org_rel where orgreltype = 'Management' and organizationid = '127';

select * from organization_code where orgcode = '572820' and organizationtype = 'CC';
select * from pos_org_rel where  organizationid = '1451' and posorgreltype = 'Budget' and positionid in (select positionid from pers_pos where personid = '66160');
select * from pers_pos where personid = '66160' and positionid = '397588';


select * from job_desc where jobid = 

select * from position_desc where positionid = '404925';
select * from salary_grade 

select * from organization_code where organizationtype in ('Div', 'Dept')
SELECT * FROM edi.edi_last_update;
UPDATE  edi.edi_last_update elu SET LASTUPDATETS = '2018-06-01 00:00:00' WHERE elu.feedid = 'HMN_Monthly_Promotion_Report'

select * from pers_pos where personid = '66543' --and positionid = '404751';
  and current_timestamp between createts and endts
  and effectivedate < enddate
  and 
  ;
left join pers_pos prev_pp
  ON prev_PP.personid = pp.personid
 and current_timestamp between prev_PP.createts and prev_PP.endts
 and prev_PP.effectivedate < prev_PP.enddate
 and prev_PP.enddate = pp.effectivedate - interval '1 day'





















select * from person_user_field_vals

select * from person_locations where personid = '64588';
select * from location_codes;
select * from person_employment where personid = '66048';
select * from organization_code where organizationid in ('1427', '1430') and organizationtype = 'CC';

          
select * from pspay_payment_detail where etv_id = 'VEH' and check_date > '2018-05-31';      
63595 63620
select * from person_compensation where personid in ( '66208');

(SELECT personid, compamount, increaseamount, compevent, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate, 
            RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
            FROM person_compensation pc1
            LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'HMN_PS_CogDetGet_Export'
            WHERE enddate > effectivedate 
              AND current_timestamp BETWEEN createts AND endts
              and increaseamount <> 0
              --and effectivedate <= elu.lastupdatets::DATE
              and personid in ( '63703')
            GROUP BY personid, compamount, increaseamount, compevent )



select * from pers_pos where personid = '64523';
select * from pos_org_rel where positionid = '405177';

select * from position_job where positionid in ('404925','404989');
select * from job_desc where jobid in ('75447', '75429','75430');

select jobid,jobcode,max(effectivedate)as effectivedate, max(enddate) as enddate,
  RANK() OVER (PARTITION BY jobid ORDER BY MAX(effectivedate) DESC) AS RANK
 from job_desc 
 LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'HMN_Monthly_Promotion_Report'
 where enddate > effectivedate
   and current_timestamp between createts and endts
   and enddate < '2199-12-30'
   and jobid in ('75447', '75429')
   group by 1,2
   ;



left join 

(SELECT personid, compamount, increaseamount, compevent, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate, 
            RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
            FROM person_compensation pc1
            LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'HMN_PS_CogDetGet_Export'
            WHERE enddate > effectivedate 
              AND current_timestamp BETWEEN createts AND endts
              and increaseamount <> 0
              and effectivedate <= elu.lastupdatets::DATE
            GROUP BY personid, compamount, increaseamount, compevent ) as lastcompdt on lastcompdt.personid = pe.personid and lastcompdt.rank = 1   


select pp.personid
,pp.positionid as curpos
,pp.effectivedate
,ppp.positionid as prevpos
,pc.compevent
,pc.effectivedate
,sg.salarygradedesc
,sgp.salarygradedesc

from pers_pos pp
LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'HMN_Monthly_Promotion_Report'
left join person_compensation pc
  on pc.personid = pp.personid
 and current_date between pc.effectivedate and pc.enddate
 and current_timestamp between pc.createts and pc.endts
left join pers_pos ppp
  on ppp.personid = pp.personid
 and current_timestamp between ppp.createts and ppp.endts
 and ppp.effectivedate > elu.lastupdatets
 and ppp.enddate < '2199-12-30'
left join position_desc pd 
  on pd.positionid = pp.positionid
 and current_date between pd.effectivedate and pd.enddate
 and current_timestamp between pd.createts and pd.endts
 
left join position_desc pdp
  on pdp.positionid = ppp.positionid
 and current_timestamp between pdp.createts and pdp.endts
 
left join salary_grade sg 
  on sg.grade = pd.grade
 and current_date between sg.effectivedate and sg.enddate
 and current_timestamp between sg.createts and sg.endts
 
left join salary_grade sgp
  on sgp.grade = pdp.grade
 and current_timestamp between sgp.createts and sgp.endts 
 
where current_date between pp.effectivedate and pp.enddate
  and current_timestamp between pp.createts and pp.endts
  and pp.personid = '66246'
  and pc.compevent = 'Promo'


;
select * from person_compensation where personid in ('65735','66246');

select * from pers_pos where personid in ('65735','66246');







select * from pers_pos where persposevent = 'Promo';


select * from personpromotion;
select * from pers_pos where personid = '66504';
select * from position_desc where positionid = '404999';
select * from positiondetails where positionid = '404999';
select * from salarygradelist;
select * from pers_pos where personid = '65548';
select * from position_desc where positionid = '404871';
select * from person_employment
select * from positiondetails

select * from pers_pos where personid in ('66246');
select * from position_desc where positionid = '405273';
select * from position_desc where positionid = '405171';



select pc.personid from person_compensation pc 
  join 
 where pc.compevent = 'Promo' 

select * from pay_unit;
select * from person_names where lname like 'Thomas%';

select * from job_desc where jobid in 
(select positionid, jobid from position_job where positionid in 
(select  positionid from pers_pos where personid = '66504' group by 1)
group by 1,2);
select * from position_job where jobid = '70657';
select * from pers_pos 
where current_timestamp between createts and endts
  --and current_date between effectivedate and enddate
  and personid = '66504';
  select * from person_names where personid = '67860';
---- current promos based on pers pos

select distinct personid from pers_pos pp
LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'HMN_Monthly_Promotion_Report'
where pp.persposevent in ('Promo')
  and pp.effectivedate >= elu.lastupdatets
  and date_part('month',pp.effectivedate) > date_part('month',elu.lastupdatets)
  and date_part('year',pp.effectivedate) = date_part('year',elu.lastupdatets)
  and pp.effectivedate is not null  ;
  select distinct personid, pp.positionid, pp.effectivedate, pp.persposevent from pers_pos pp
LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'HMN_Monthly_Promotion_Report'
where pp.persposevent in ('Promo')
  and pp.effectivedate >= elu.lastupdatets
  and date_part('month',pp.effectivedate) = date_part('month',elu.lastupdatets)
  and date_part('year',pp.effectivedate) = date_part('year',elu.lastupdatets)
  and pp.effectivedate is not null  ;
  
select * from person_compensation where personid in ('67794','67860');       

select distinct personid from person_compensation pc
LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'HMN_Monthly_Promotion_Report'
where pc.compevent = 'Promo'
  and pc.effectivedate >= elu.lastupdatets and pc.effectivedate < elu.lastupdatets + interval '1 month'
  and date_part('month',pc.effectivedate) = date_part('month',elu.lastupdatets)
  and date_part('year',pc.effectivedate) = date_part('year',elu.lastupdatets)
  and pc.effectivedate is not null  ;  
  
select distinct personid,pc.compevent,pc.effectivedate , elu.lastupdatets + interval '1 month' from person_compensation pc
LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'HMN_Monthly_Promotion_Report'
where pc.compevent = 'Promo'
  and pc.effectivedate >= elu.lastupdatets and pc.effectivedate < elu.lastupdatets + interval '1 month'
  and current_date between pc.effectivedate and pc.enddate
  and current_timestamp between pc.createts and pc.endts
  and date_part('month',pc.effectivedate) = date_part('month',elu.lastupdatets)
  and date_part('year',pc.effectivedate) = date_part('year',elu.lastupdatets)
  and pc.effectivedate is not null  ;    
  
select * from person_compensation where personid = '67860';  
select * from pers_pos where personid = '67860';
select * from person_names where personid = '67794';

--- thomas
select * from person_compensation where personid = '65735';  
select * from pers_pos where personid = '65735';
select * from person_names where personid = '65735';