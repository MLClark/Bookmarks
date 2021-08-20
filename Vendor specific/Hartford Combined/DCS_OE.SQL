--%%%%% DCS RECORD
Select distinct
 'DCS'                                       ::char(3) AS recordtype
,'HAR'                                       ::char(5) AS client
,PI.identity                                 ::char(10) AS certnumber
,' '                                         ::char(2) as filler
,to_char(pe.effectivedate,'mm/dd/yyyy') ::char(10) as effectivedate
--,epi.homephone
, case character_length(epi.homephone) 
  when 14 then(substring(epi.homephone from 2 for 3) || substring(epi.homephone from 7 for 3) || substring(epi.homephone from 11 for 4) )
  when 12 then(substring(epi.homephone from 1 for 3) || substring(epi.homephone from 5 for 3) || substring(epi.homephone from 9 for 4) )
  when 10 then epi.homephone else ' ' end    ::char(10) as homephone
,pe.emplstatus ::char(1) as empstatus
,to_char(pe.effectivedate, 'mm/dd/yyyy')     ::char(10) as statuseftdate
,pe.emplclass ::char(1) as salaryclass
,to_char(pe.effectivedate,'mm/dd/yyyy')      ::char(10) as salaryeffdate
,lpad(coalesce(CASE pc.frequencycode 
               WHEN 'A'::bpchar THEN cast(round(pc.compamount, 2)*100 as bigint)
               WHEN 'H'::bpchar THEN cast(round(pc.compamount * pp.scheduledhours * fc1.annualfactor, 2)*100 as bigint)
               ELSE 0::numeric
        END,0)::text,9,'0') AS annualsalary
        --RPAD(numcol::text, 3, '0'), -- Zero-pads to the right up to the length of 3
,'A'                                         ::char(1) as salarybasis       
,CASE WHEN clr.companylocationtype = 'WH'
      ::bpchar THEN st.stateprovincecode 
      ELSE EE.statecode END         ::char(2) AS workstatecode
--,EE.countrycode      
,upper(ed.positiontitle)                     ::char(25) as jobtitle
,ed.flsacode                                 ::char(1) as exempt_ind
,' '                                         ::char(1) as union_ind
,' '                                         ::char(30) as union_name
,' '                                         ::char(10) as department
,lc.locationcode ::char(10)               as division
,' '                                         ::char(10) as location
,' '                                         ::char(10) as account
,' '                                         ::char(10) as region
,' '                                         ::char(10) as company
,' '                                         ::char(50) as employee_email
,to_char(pe.emplhiredate,'mm/dd/yyyy')       ::char(10) as std_cvrg_eff_dt
,' '                                         ::char(10) as std_cvrg_trm_dt
,'STD '                                         ::char(5) as std_cvrg_option
,to_char(pe.emplhiredate,'mm/dd/yyyy')       ::char(10) as ltd_cvrg_eff_dt
,' '                                         ::char(10) as ltd_cvrg_trm_dt
,'LTD '                                         ::char(5) as ltd_cvrg_option
,' '                                         ::char(3) as flex_com_prd_day_injury
,' '                                         ::char(3) as flex_com_prd_day_sickness
,' '                                         ::char(3) as flex_benefit_duration
,' '                                         ::char(6) as flex_benefit_amount
FROM person_identity PI 
JOIN edi.etl_employment_data ed ON ed.personid = pi.personid
JOIN edi.etl_personal_info EPI on EPI.personid = pi.personid
JOIN edi.ediemployee ee on ee.personid = pi.personid

JOIN person_bene_election pbe 
  on pbe.personid = pi.personid 
 AND current_timestamp between pbe.createts and pbe.endts
 and date_part('year',pbe.effectivedate) = date_part('year',current_date + interval '1 year')
 AND pbe.benefitsubclass IN ( '1W','13','30','31' )
 AND pbe.selectedoption = 'Y'
 and pbe.benefitelection in ('T','W','E')

JOIN person_employment pe 
  ON pe.personid = pi.personid 
 AND current_date between pe.effectivedate and pe.enddate 
 AND current_timestamp between pe.createts and pe.endts 

JOIN pers_pos pp 
  ON pe.personid = pp.personid 
 AND pp.persposrel = 'Occupies'::bpchar 
 AND current_date between pp.effectivedate and pp.enddate 
 AND current_timestamp between pp.createts and pp.endts 

JOIN person_compensation pc 
  ON pc.personid = pe.personid 
 AND pc.enddate > pc.effectivedate 
 AND pc.earningscode <> 'BenBase'::bpchar 
 AND current_date between pc.effectivedate AND pc.enddate 
 AND current_timestamp between pc.createts AND pc.endts 

JOIN person_payroll ppr 
  ON ppr.personid = pe.personid 
 AND current_date between ppr.effectivedate and ppr.enddate
 AND current_timestamp between ppr.createts AND ppr.endts

LEFT JOIN pay_unit pu ON pu.payunitid = ppr.payunitid

LEFT JOIN frequency_codes fc1 ON fc1.frequencycode = pu.frequencycode

LEFT JOIN person_locations pl 
  ON pl.personid = pi.personid 
 AND pl.personlocationtype = 'P'::bpchar 
 AND current_date between pl.effectivedate AND pl.enddate
 AND current_timestamp between pl.createts AND pl.endts
      
join location_codes lc 
  on lc.locationid = pl.locationid

LEFT JOIN company_location_rel clr 
  ON clr.locationid = pl.locationid 
 AND current_timestamp between clr.createts AND clr.endts       
 
LEFT JOIN person_address pa 
  ON pa.personid = pi.personid 
 AND pa.addresstype = 'Res'::bpchar 
 AND current_date between pa.effectivedate AND pa.enddate 
 AND current_timestamp between pa.createts AND pa.endts
 
LEFT JOIN state_province st 
  ON st.stateprovincecode = pa.stateprovincecode 
 AND st.countrycode = pa.countrycode


left join 
(select ro.org2desc, ro.org1id, por.organizationid, por.positionid from rpt_orgstructure ro 
        left join pos_org_rel por on ro.org1id = por.organizationid 
        AND current_date between por.effectivedate AND por.enddate 
        AND current_timestamp between por.createts AND por.endts 
        AND por.posorgreltype = 'Member' 
        where ro.org2desc is not null group by 1,2,3,4
) org on org.positionid = ed.positionid


WHERE PI.identitytype = 'SSN' 
and current_timestamp between PI.createts and PI.endts 

order by 3

--'016369645'