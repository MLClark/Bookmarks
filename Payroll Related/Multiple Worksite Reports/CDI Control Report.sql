/*

   MWR Control report query
   This query can be used for all clients IE CDI (which has to be split by groups and CSI)
   
*/
WITH DATES AS (
select case when extract(month from current_date) in ('1', '2', '3')
            then extract(year from current_date) - 1 
            else extract(year from current_date) 
       end as prevQTR_year
      ,case when extract(month from current_date) in ('1', '2', '3')
            then '4'
            when extract(month from current_date) in ('4', '5', '6')
            then '1'
            when extract(month from current_date) in ('7', '8', '9')
            then '2'
            when extract(month from current_date) in ('10', '11', '12')
            then '3'
            end as prevQTR_number
     , case when extract(month from current_date) in ('1', '2', '3')
            then to_date(extract(year from current_date) - 1 || '-10' || '-01', 'yyyy-mm-dd')
            when extract(month from current_date) in ('4', '5', '6')
            then to_date(extract(year from current_date) || '-'  || '01' || '-' || '01', 'yyyy-MM-DD')
            when extract(month from current_date) in ('7', '8', '9')
            then to_date(extract(year from current_date) || '-'  || '04' || '-' || '01', 'yyyy-MM-DD')
            when extract(month from current_date) in ('10', '11', '12')
            then to_date(extract(year from current_date) || '-'  || '07' || '-' || '01', 'yyyy-MM-DD')
            end as prevQTR_begin_dt
     , case when extract(month from current_date) in ('1', '2', '3')
            then to_date(extract(year from current_date) - 1 || '-12' || '-31', 'yyyy-mm-dd')
            when extract(month from current_date) in ('4', '5', '6')
            then to_date(extract(year from current_date) || '-'  || '03' || '-' || '31', 'yyyy-MM-DD')
            when extract(month from current_date) in ('7', '8', '9')
            then to_date(extract(year from current_date) || '-'  || '06' || '-' || '30', 'yyyy-MM-DD')
            when extract(month from current_date) in ('10', '11', '12')
            then to_date(extract(year from current_date) || '-'  || '09' || '-' || '30', 'yyyy-MM-DD')
            end as prevQTR_end_dt
     , case when extract(month from current_date) in ('1', '2', '3')
            then to_date(extract(year from current_date) - 1 || '-10' || '-12', 'yyyy-mm-dd')
            when extract(month from current_date) in ('4', '5', '6')
            then to_date(extract(year from current_date) || '-'  || '01' || '-' || '12', 'yyyy-MM-DD')
            when extract(month from current_date) in ('7', '8', '9')
            then to_date(extract(year from current_date) || '-'  || '04' || '-' || '12', 'yyyy-MM-DD')
            when extract(month from current_date) in ('10', '11', '12')
            then to_date(extract(year from current_date) || '-'  || '07' || '-' || '12', 'yyyy-MM-DD')
            end as m1_12_dt
     , case when extract(month from current_date) in ('1', '2', '3')
            then to_date(extract(year from current_date) - 1 || '-11' || '-12', 'yyyy-mm-dd')
            when extract(month from current_date) in ('4', '5', '6')
            then to_date(extract(year from current_date) || '-'  || '02' || '-' || '12', 'yyyy-MM-DD')
            when extract(month from current_date) in ('7', '8', '9')
            then to_date(extract(year from current_date) || '-'  || '05' || '-' || '12', 'yyyy-MM-DD')
            when extract(month from current_date) in ('10', '11', '12')
            then to_date(extract(year from current_date) || '-'  || '08' || '-' || '12', 'yyyy-MM-DD')
            end as m2_12_dt
     , case when extract(month from current_date) in ('1', '2', '3')
            then to_date(extract(year from current_date) - 1 || '-12' || '-12', 'yyyy-mm-dd')
            when extract(month from current_date) in ('4', '5', '6')
            then to_date(extract(year from current_date) || '-'  || '03' || '-' || '12', 'yyyy-MM-DD')
            when extract(month from current_date) in ('7', '8', '9')
            then to_date(extract(year from current_date) || '-'  || '06' || '-' || '12', 'yyyy-MM-DD')
            when extract(month from current_date) in ('10', '11', '12')
            then to_date(extract(year from current_date) || '-'  || '09' || '-' || '12', 'yyyy-MM-DD')
            end as m3_12_dt
            )
select 
-- epi.firstname, epi.lastname, epi.employeessn, epi.locationid
-- pi.personid,
pn.fname
, pn.lname
, pissn.identity as ssn
, pi.identity as trankey
, substring(pi.identity,1,5) as group
, pl.locationid
, lc.locationcode
, gwage.qwage
, case when  mth1.individual_key <> '' then 'Y'
      else 'N' END as mth1
, case when  mth2.individual_key is not null then 'Y'
      else 'N' END as mth2
, case when  mth3.individual_key is not null then 'Y'
      else 'N' END as mth3
FROM  DATES
JOIN  person_identity pi ON 1 = 1
JOIN (SELECT  pph.individual_key, sum(pph.gross_pay) as qwage
      FROM DATES 
      JOIN pspay_payment_header pph ON 1 = 1
      JOIN person_identity pi ON pi.identity = pph.individual_key and pi.identitytype = 'PSPID' and CURRENT_TIMESTAMP BETWEEN createts and endts
      WHERE check_date >= DATES.prevqtr_begin_dt
        AND check_date <= DATES.prevqtr_end_dt                         
     group by pph.individual_key ) gwage on gwage.individual_key = pi.identity


-- edi.etl_personal_info epi 
JOIN person_identity pissn on pissn.personid = pi.personid and current_timestamp between pissn.createts and pissn.endts and pissn.identitytype = 'SSN'
JOIN person_names pn on pn.personid = pi.personid AND current_date between pn.effectivedate and pn.enddate AND current_timestamp between pn.createts and pn.endts 
                     AND pn.nametype = 'Legal'
LEFT JOIN person_locations pl on pi.personid = pl.personid  AND pl.effectivedate <= DATES.prevqtr_end_dt and pl.enddate >= DATES.prevqtr_begin_dt
                     AND current_timestamp between pl.createts and pl.endts   
                     AND pl.personlocationtype = 'P'                
LEFT JOIN location_codes lc on pl.locationid = lc.locationid AND CURRENT_DATE BETWEEN lc.effectivedate and lc.enddate 
                               and CURRENT_TIMESTAMP BETWEEN lc.createts and lc.endts
LEFT JOIN ( SELECT DISTINCT pph.individual_key 
      FROM DATES
      JOIN pspay_payment_header pph ON 1 = 1
      JOIN person_identity pi ON pi.identity = pph.individual_key and pi.identitytype = 'PSPID' and CURRENT_TIMESTAMP BETWEEN createts and endts
      left join person_locations pl on pl.personid = pi.personid AND pl.personlocationtype = 'P' 
           and pl.effectivedate <= DATES.prevqtr_end_dt and pl.enddate >= DATES.prevqtr_begin_dt
           and current_timestamp between pl.createts and pl.endts
      WHERE DATES.m1_12_dt between  period_begin_date  and  period_end_date 
) mth1 ON mth1.individual_key = pi.identity 

LEFT JOIN ( SELECT DISTINCT pph.individual_key 
      FROM DATES
      JOIN pspay_payment_header pph ON 1 = 1
      JOIN person_identity pi ON pi.identity = pph.individual_key and pi.identitytype = 'PSPID' and CURRENT_TIMESTAMP BETWEEN createts and endts
      left join person_locations pl on pl.personid = pi.personid AND pl.personlocationtype = 'P' 
           and pl.effectivedate <= DATES.prevqtr_end_dt and pl.enddate >= DATES.prevqtr_begin_dt
           and current_timestamp between pl.createts and pl.endts
      WHERE DATES.m2_12_dt between  period_begin_date  and  period_end_date 
) mth2 oN mth2.individual_key = pi.identity 

LEFT JOIN ( SELECT DISTINCT pph.individual_key 
      FROM DATES
      JOIN pspay_payment_header pph ON 1 = 1
      JOIN person_identity pi ON pi.identity = pph.individual_key and pi.identitytype = 'PSPID' and CURRENT_TIMESTAMP BETWEEN createts and endts
      left join person_locations pl on pl.personid = pi.personid AND pl.personlocationtype = 'P' 
           and pl.effectivedate <= DATES.prevqtr_end_dt and pl.enddate >= DATES.prevqtr_begin_dt
           and current_timestamp between pl.createts and pl.endts
      WHERE DATES.m3_12_dt between  period_begin_date  and  period_end_date 
) mth3 oN mth3.individual_key = pi.identity 
WHERE pi.identitytype = 'PSPID' and current_timestamp between pi.createts and pi.endts
order by 5,pl.locationid, pn.lname;


