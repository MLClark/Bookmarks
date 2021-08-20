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
  nm.companyid
, pu.payunitdesc as group
, replace(pu.employertaxid,'-','')::char(9) as fein
, CASE WHEN nm.companydba IS NOT NULL THEN nm.companydba::char(35)
                ELSE nm.companyname::char(35) 
                END AS tradename

, nm.companyname::CHAR(35) AS legalname
, la.streetaddress::char(35)
, la.city::char(30)
, la.stateprovincecode::char(2)
, la.postalcode::char(5)
, (select taxstatecode::char(2) from state_province where stateprovincecode = la.stateprovincecode and countrycode = 'US') as refstate
, lpad(''||lc.locationcode, 5, '0')::char(5) as worksiteid
, lc.locationcode::char(21) as worksitecode
, lc.locationdescription::char(35) as worksitedesc
,  DATES.prevQTR_year as refyear 
,  DATES.prevQTR_number as refqtr

, lpad(''||m1c.month1count, 6, '0')::char(6) as month1count
, lpad(''||m2c.month2count, 6, '0')::char(6) as month2count
, lpad(''||m3c.month3count, 6, '0')::char(6) as month3count
, lpad(''||round(qsal.quarterwages, 0), 10, '0')::char(10) as quarterwages

from DATES  join location_codes lc on 1 = 1
join ( select pl.locationid, sum(pphs.gross_pay) as quarterwages
       from DATES join pspay_payment_header pphs on 1 = 1
          join person_identity pi on pi.identity = pphs.individual_key 
           and pi.identitytype = 'PSPID' 
           and current_timestamp BETWEEN pi.createts and pi.endts
          left join person_locations pl on pl.personid = pi.personid 
           AND pl.personlocationtype = 'P' 
           and DATES.prevQTR_begin_dt <= pl.enddate 
           and DATES.prevQTR_end_dt >= pl.effectivedate  
           and current_timestamp between pl.createts and pl.endts
       where pphs.check_date between DATES.prevQTR_begin_dt and DATES.prevQTR_end_dt
       group by pl.locationid ) qsal on qsal.locationid = lc.locationid

left join (
select x.locationid, count(*) as month1count
from (SELECT DISTINCT pl.locationid, pph.individual_key 
      FROM  DATES join pspay_payment_header pph on 1 = 1
          JOIN person_identity pi ON pi.identity = pph.individual_key 
           and pi.identitytype = 'PSPID' 
           and current_timestamp BETWEEN createts and endts
          left join person_locations pl on pl.personid = pi.personid 
           AND pl.personlocationtype = 'P' 
           and DATES.prevQTR_begin_dt <= pl.enddate 
           and DATES.prevQTR_end_dt >= pl.effectivedate   
           and current_timestamp between pl.createts and pl.endts
      WHERE pph.check_date BETWEEN DATES.prevQTR_begin_dt and DATES.prevQTR_end_dt
        AND DATES.m1_12_dt between  pph.period_begin_date  and  pph.period_end_date
                )x
group by x.locationid     

) as  m1c on m1c.locationid = lc.locationid
left join (
select x.locationid, count(*) as month2count
from (SELECT DISTINCT pl.locationid, pph.individual_key 
      FROM DATES join pspay_payment_header pph on 1 = 1
         JOIN person_identity pi ON pi.identity = pph.individual_key 
          and pi.identitytype = 'PSPID' 
          and current_timestamp BETWEEN createts and endts
          left join person_locations pl on pl.personid = pi.personid 
           AND pl.personlocationtype = 'P' 
           and DATES.prevQTR_begin_dt <= pl.enddate 
           and DATES.prevQTR_end_dt >= pl.effectivedate 
           and current_timestamp between pl.createts and pl.endts
      WHERE pph.check_date BETWEEN DATES.prevQTR_begin_dt and DATES.prevQTR_end_dt
        AND DATES.m2_12_dt between  pph.period_begin_date  and  pph.period_end_date  )x
group by x.locationid     

) as  m2c on m2c.locationid = lc.locationid

left join (
select x.locationid, count(*) as month3count
from (SELECT DISTINCT pl.locationid, pph.individual_key 
      FROM DATES join pspay_payment_header pph on 1 = 1
        JOIN person_identity pi ON pi.identity = pph.individual_key 
         and pi.identitytype = 'PSPID' 
         and current_timestamp BETWEEN createts and endts
        left join person_locations pl on pl.personid = pi.personid 
         AND pl.personlocationtype = 'P' 
           and DATES.prevQTR_begin_dt <= pl.enddate 
           and DATES.prevQTR_end_dt >= pl.effectivedate 
         and current_timestamp between pl.createts and pl.endts
      WHERE pph.check_date BETWEEN DATES.prevQTR_begin_dt and DATES.prevQTR_end_dt
        AND DATES.m3_12_dt between  pph.period_begin_date  and  pph.period_end_date    )x
group by x.locationid     

) as  m3c on m3c.locationid = lc.locationid

LEFT JOIN company_location_rel clr2 on clr2.locationid = lc.locationid
     and current_timestamp between clr2.createts and clr2.endts

left join dxcompanyname nm ON nm.companyid = clr2.companyid
---- company_identity is empty for CDI using pay_unit instead
--LEFT JOIN company_identity ci on nm.companyid = ci.companyid
  --   and ci.companyidentitytype = 'FEIN'
left join pay_unit pu on pu.companyid = nm.companyid

LEFT JOIN company_location_rel clr on nm.companyid = clr.companyid
     and current_timestamp between clr.createts and clr.endts
     and clr.companylocationtype = 'M'

LEFT JOIN location_address la on clr.locationid = la.locationid 
     AND DATES.prevQTR_begin_dt <= la.enddate 
     and DATES.prevQTR_end_dt >= la.effectivedate  
     and current_timestamp between la.createts and la.endts

WHERE DATES.prevQTR_begin_dt <= lc.enddate 
  and DATES.prevQTR_end_dt >= lc.effectivedate 
  and current_timestamp between lc.createts and lc.endts
AND pu.payunitdesc = 'CDI05'
AND la.locationid is not null

order by worksiteid