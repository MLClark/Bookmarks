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
            then to_date(extract(year from current_date) - 1 || '-'  ||  '10' || '-'  ||  '01', 'yyyy-mm-dd')
            when extract(month from current_date) in ('4', '5', '6')
            then to_date(extract(year from current_date) || '-'  || '01' || '-' || '01', 'yyyy-MM-DD')
            when extract(month from current_date) in ('7', '8', '9')
            then to_date(extract(year from current_date) || '-'  || '04' || '-' || '01', 'yyyy-MM-DD')
            when extract(month from current_date) in ('10', '11', '12')
            then to_date(extract(year from current_date) || '-'  || '07' || '-' || '01', 'yyyy-MM-DD')
            end as prevQTR_begin_dt
     , case when extract(month from current_date) in ('1', '2', '3')
            then to_date(extract(year from current_date) - 1 || '-'  ||  '12' ||  '-'  || '31', 'yyyy-mm-dd')
            when extract(month from current_date) in ('4', '5', '6')
            then to_date(extract(year from current_date) || '-'  || '03' || '-' || '31', 'yyyy-MM-DD')
            when extract(month from current_date) in ('7', '8', '9')
            then to_date(extract(year from current_date) || '-'  || '06' || '-' || '30', 'yyyy-MM-DD')
            when extract(month from current_date) in ('10', '11', '12')
            then to_date(extract(year from current_date) || '-'  || '09' || '-' || '30', 'yyyy-MM-DD')
            end as prevQTR_end_dt
     , case when extract(month from current_date) in ('1', '2', '3')
            then to_date(extract(year from current_date) - 1 || '-'  ||  '10' ||  '-'  || '12', 'yyyy-mm-dd')
            when extract(month from current_date) in ('4', '5', '6')
            then to_date(extract(year from current_date) || '-'  || '01' || '-' || '12', 'yyyy-MM-DD')
            when extract(month from current_date) in ('7', '8', '9')
            then to_date(extract(year from current_date) || '-'  || '04' || '-' || '12', 'yyyy-MM-DD')
            when extract(month from current_date) in ('10', '11', '12')
            then to_date(extract(year from current_date) || '-'  || '07' || '-' || '12', 'yyyy-MM-DD')
            end as m1_12_dt
     , case when extract(month from current_date) in ('1', '2', '3')
            then to_date(extract(year from current_date) - 1 || '-'  ||  '11' || '-'  ||  '12', 'yyyy-mm-dd')
            when extract(month from current_date) in ('4', '5', '6')
            then to_date(extract(year from current_date) || '-'  || '02' || '-' || '12', 'yyyy-MM-DD')
            when extract(month from current_date) in ('7', '8', '9')
            then to_date(extract(year from current_date) || '-'  || '05' || '-' || '12', 'yyyy-MM-DD')
            when extract(month from current_date) in ('10', '11', '12')
            then to_date(extract(year from current_date) || '-'  || '08' || '-' || '12', 'yyyy-MM-DD')
            end as m2_12_dt
     , case when extract(month from current_date) in ('1', '2', '3')
            then to_date(extract(year from current_date) - 1 || '-'  ||  '12' || '-'  ||  '12', 'yyyy-mm-dd')
            when extract(month from current_date) in ('4', '5', '6')
            then to_date(extract(year from current_date) || '-'  || '03' || '-' || '12', 'yyyy-MM-DD')
            when extract(month from current_date) in ('7', '8', '9')
            then to_date(extract(year from current_date) || '-'  || '06' || '-' || '12', 'yyyy-MM-DD')
            when extract(month from current_date) in ('10', '11', '12')
            then to_date(extract(year from current_date) || '-'  || '09' || '-' || '12', 'yyyy-MM-DD')
            end as m3_12_dt
            )
select distinct
  lc.locationcode::char(21) as worksitecode
, lc.locationdescription::char(35) as worksitedesc
, pl.personid as personid
, pis.identity as ssn
, pph.individual_key
, SUBSTRING(pph.individual_key,1,5) as pay_group
, to_char(PPH.CHECK_DATE,'MMDDYYYY')::char(8)
, pph.state_gross_pay as qtr_state_gross_pay_CD

, pn.lname 
, pn.fname



, DATES.prevQTR_year as refyear 
, DATES.prevQTR_number as refqtr
, DATES.prevQTR_begin_dt
, DATES.prevQTR_end_dt 




from DATES  
join location_codes lc 
  on 1 = 1


left join person_locations pl 
  on pl.locationid = lc.locationid
 AND pl.personlocationtype = 'P' 
 and DATES.prevQTR_begin_dt <= pl.enddate 
 and DATES.prevQTR_end_dt >= pl.effectivedate 
 and current_timestamp between pl.createts and pl.endts    
  
left join person_names pn
  on pn.personid = pl.personid
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts  
 and pn.nametype = 'Legal'
 
left join person_identity pis
  on pis.personid = pl.personid
 and pis.identitytype = 'SSN'
 and current_timestamp between pis.createts and pis.endts
 
left join person_identity pip
  on pip.personid = pl.personid
 and pip.identitytype = 'PSPID'
 and current_timestamp between pip.createts and pip.endts   

LEFT JOIN company_location_rel clr2 
  on clr2.locationid = lc.locationid
 and current_timestamp between clr2.createts and clr2.endts

left join dxcompanyname nm 
  ON nm.companyid = clr2.companyid
  
LEFT JOIN company_identity ci 
  on nm.companyid = ci.companyid
 and ci.companyidentitytype = 'FEIN'

LEFT JOIN company_location_rel clr 
  on nm.companyid = clr.companyid
 and current_timestamp between clr.createts and clr.endts
 and clr.companylocationtype = 'M'

LEFT JOIN location_address la 
  on clr.locationid = la.locationid 
 AND DATES.prevQTR_begin_dt <= la.enddate 
 and DATES.prevQTR_end_dt >= la.effectivedate  
 and current_timestamp between la.createts and la.endts
  
left join pspay_payment_header pph
  on pph.personid = pl.personid 
 and pph.check_date BETWEEN DATES.prevQTR_begin_dt and DATES.prevQTR_end_dt
 --AND DATES.m1_12_dt between pph.period_begin_date  and pph.period_end_date


 
WHERE DATES.prevQTR_begin_dt <= lc.enddate 
  and DATES.prevQTR_end_dt >= lc.effectivedate 
  and current_timestamp between lc.createts and lc.endts
  and lc.locationcode in ('ALB','BUF','NYS','END')
  and SUBSTRING(pip.identity,1,5) in ('BA305','BA300')
  and pph.check_date BETWEEN '2017-01-01' and '2017-03-31' 
  --AND DATES.m1_12_dt between pph.period_begin_date  and pph.period_end_date
  --and pl.personid in ('85232')

  order by 3,6,1
;