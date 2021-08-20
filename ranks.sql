---- in case you need to pull part of a string from string - in this case everything before the underscore
select position('_' in 'PROGDIR_325 ' );
select char_length('PROGDIR_325 ' );

select substring('PROGDIR_325 ' from 1 for 8-1);
select substring('PROGDIR_325 ' from 1 for position('_' in 'PROGDIR_325 ' )-1);
select 
 pn.name,
 pn.lname,
 pn.title,
 position (' ' in pn.lname),
 
 char_length(pn.lname),
    CASE WHEN position(' ' in pn.lname) =  0 THEN ((pn.fname::text || ' '::text) || COALESCE(pn.mname::text || ' '::text, ''::text) || pn.lname::text || ' ' || COALESCE(pn.title::text || ' '::text, ''::text))
         WHEN position(' ' in pn.lname) <> 0 THEN ((pn.fname::text || ' '::text) || COALESCE(pn.mname::text || ' '::text, ''::text) || SUBSTRING(pn.lname FROM 1 FOR POSITION(' ' IN pn.lname) -1)::text || ' ' || COALESCE(pn.title::text || ' '::text, ''::text))
          END AS employeename,
    CASE WHEN position(' ' in pn.lname) =  0 THEN ((pn.lname::text || ' '::text || pn.fname::text) || ' '::text || COALESCE(pn.mname, ''::character VARYING)::text || ' ' || COALESCE(pn.title::text || ' '::text, ''::text)) 
         WHEN position(' ' in pn.lname) <> 0 THEN (SUBSTRING(pn.lname FROM 1 FOR POSITION(' ' IN pn.lname) -1)::text || ' '::text || pn.fname::text || ' ' || COALESCE(pn.mname, ''::character VARYING)::text || ' ' || COALESCE(pn.title::text || ' '::text, ''::text))
          END AS employeenamelastfirst
 
 
  from person_names pn where pn.nametype = 'Legal' and current_date between pn.effectivedate and pn.enddate and current_timestamp between pn.createts and pn.endts
;
    

join (select personid, createts, endts, eventname, eventeffectivedate as effectivedate, actionenddate as enddate, max ( personbenefitactionpid) as  personbenefitactionpid,
        rank() over (partition by personid order by createts desc) as rank  
        from person_benefit_action where current_timestamp between createts and endts and eventname in ('TER','RET') --and personid = '5183'
        group by personid, createts, endts, eventname, effectivedate, enddate) pba on pba.personid = pi.personid and pba.rank = 1

select * from person_benefit_action where eventname in ('TER','RET') and personid = '5183';

(select personid, createts, endts, eventname, eventeffectivedate as effectivedate, actionenddate as enddate, max ( personbenefitactionpid) as  personbenefitactionpid,
        rank() over (partition by personid order by createts desc) as rank  
        from person_benefit_action where current_timestamp between createts and endts and eventname in ('TER','RET') and personid = '5183'
        group by personid, createts, endts, eventname, effectivedate, enddate)
     

left join  (select personid, emplevent, emplstatus, emplclass, emplpermanency, benefitstatus, emplhiredate, empllasthiredate, effectivedate, enddate, createts, endts, rank() over (partition by personid order by effectivedate , createts ) as rank  
             from person_employment where effectivedate <  enddate and current_timestamp between createts and endts 
              and personid in (select distinct personid from person_employment where emplevent = 'Rehire' and effectivedate < enddate and current_timestamp between createts and endts group by 1)
              and emplstatus in ('T','R','D','V','X')
              ) rehired on rehired.personid = pi.personid and rehired.rank = 1
              
                      
---- with future dated logic

left join (select personid, emplevent, emplstatus, emplclass, emplpermanency, benefitstatus, emplhiredate, empllasthiredate, effectivedate, enddate, createts, endts, rank() over (partition by personid order by effectivedate , createts ) as rank  
             from person_employment where (current_date between effectivedate and enddate or (effectivedate > current_date and enddate > effectivedate)) and current_timestamp between createts and endts 
              and emplstatus not in ('T','R','D','V','X') ---not sure if Termed and Retired should be excluded this was from BA3 column 562 is required for termed ee's
              ) pe on pe.personid = pi.personid and pe.rank = 1

              
left join (select personid, fname, lname, mname, nametype, effectivedate, enddate, createts, endts, rank() over (partition by personid order by effectivedate , createts ) as rank
             from person_names pn where (current_date between effectivedate and enddate or (effectivedate > current_date and enddate > effectivedate)) and current_timestamp between createts and endts  
              and nametype = 'Legal') pn on pn.personid = pi.personid and pn.rank = 1
          
left join (select personid, gendercode, birthdate, effectivedate, enddate, createts, endts, rank() over (partition by personid order by effectivedate , createts ) as rank
             from person_vitals where (current_date between effectivedate and enddate or (effectivedate > current_date and enddate > effectivedate)) and current_timestamp between createts and endts  
          ) pv on pv.personid = pi.personid and pv.rank = 1 

left join (select personid, maritalstatus, effectivedate, enddate, createts, endts, rank() over (partition by personid order by effectivedate , createts ) as rank
             from person_maritalstatus where (current_date between effectivedate and enddate or (effectivedate > current_date and enddate > effectivedate)) and current_timestamp between createts and endts  
          ) pm on pm.personid = pi.personid and pm.rank = 1

left join (select personid, phoneno, phonecontacttype, effectivedate, enddate, createts, endts, rank() over (partition by personid order by effectivedate , createts ) as rank
             from person_phone_contacts where (current_date between effectivedate and enddate or (effectivedate > current_date and enddate > effectivedate)) and current_timestamp between createts and endts  
              and phonecontacttype = 'Home') ppch on ppch.personid = pi.personid and ppch.rank = 1

left join (select personid, phoneno, phonecontacttype, effectivedate, enddate, createts, endts, rank() over (partition by personid order by effectivedate , createts ) as rank
             from person_phone_contacts where (current_date between effectivedate and enddate or (effectivedate > current_date and enddate > effectivedate)) and current_timestamp between createts and endts  
              and phonecontacttype = 'Work') ppcw on ppcw.personid = pi.personid and ppcw.rank = 1            

left join (select personid,addresstype,effectivedate,streetaddress,streetaddress2,city,stateprovincecode,postalcode,countrycode,privacycode,enddate,createts,endts,rank() over (partition by personid order by effectivedate , createts ) as rank
             from person_address where (current_date between effectivedate and enddate or (effectivedate > current_date and enddate > effectivedate)) and current_timestamp between createts and endts  
              and addresstype = 'Res') pa on pa.personid = pi.personid and pa.rank = 1

left join (select personid, url, enddate, max(effectivedate) as effectivedate, max(endts) as endts,  RANK() OVER (PARTITION BY personid ORDER BY max(endts) DESC) AS RANK
             from person_net_contacts where netcontacttype = 'WRK' and current_date between effectivedate and enddate and current_timestamp between createts and endts
            group by personid, url, enddate) pncw on pncw.personid = pi.personid and pncw.rank = 1


--- medical
left join (select personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid,max(effectivedate) as effectivedate, max(enddate) as enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election where benefitsubclass = '10' and benefitelection = 'E' and selectedoption = 'Y' and current_timestamp between createts and endts --and personid = '10146'
            group by personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid) pbemed on pbemed.personid = pbe.personid and pbemed.rank = 1         
--- dental
left join (select personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid,max(effectivedate) as effectivedate, max(enddate) as enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election where benefitsubclass = '11' and benefitelection = 'E' and selectedoption = 'Y' and current_timestamp between createts and endts --and personid = '10146'
            group by personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid) pbednt on pbednt.personid = pbe.personid and pbednt.rank = 1     
--- vision
left join (select personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid,max(effectivedate) as effectivedate, max(enddate) as enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election where benefitsubclass = '14' and benefitelection = 'E' and selectedoption = 'Y' and current_timestamp between createts and endts --and personid = '10146'
            group by personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid) pbevsn on pbevsn.personid = pbe.personid and pbevsn.rank = 1                       
--- medical fsa
left join   (select personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid,max(effectivedate) as effectivedate, max(enddate) as enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election where benefitsubclass = '60' and benefitelection = 'E' and selectedoption = 'Y' and effectivedate < enddate and current_timestamp between createts and endts 
            group by personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid) pbemfsa on pbemfsa.personid = pbe.personid and pbemfsa.rank = 1  


--- for terms w multiple rank 1 due to effectivedate and createts 
left join (select personid, compamount, frequencycode, max(createts) as createts, max(effectivedate) as effectivedate, max(enddate) as enddate,rank() over (partition by personid order by max(createts),max(effectivedate) desc) as rank
             from person_compensation where compamount <> 0 
            group by personid, compamount, frequencycode) pc on pc.personid = pi.personid and pc.rank = 1 
            
left join (select personid, compamount, increaseamount, compevent, frequencycode, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate, RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_compensation where effectivedate < enddate and current_timestamp between createts and endts
            group by personid, compamount, increaseamount, compevent, frequencycode ) as pc on pc.personid = pe.personid and pc.rank = 1  


left join  (select personid, positionid, scheduledhours, schedulefrequency, max(effectivedate) as effectivedate, RANK() OVER (PARTITION BY personid ORDER BY max(effectivedate) DESC) AS RANK
             from pers_pos where effectivedate < enddate and current_timestamp between createts and endts
            group by personid, positionid, scheduledhours, schedulefrequency) pp on pp.personid = pe.personid and pp.rank = 1
            
left join (select positionid, grade, positiontitle, flsacode, max(effectivedate) as effectivedate, RANK() OVER (PARTITION BY positionid ORDER BY max(effectivedate) DESC) AS RANK
             from position_desc where effectivedate < enddate and current_timestamp between createts and endts 
            group by positionid, grade, positiontitle, flsacode) pd on pd.positionid = pp.positionid and pd.rank = 1           

left join (select personid, url, enddate, max(effectivedate) as effectivedate, max(endts) as endts,  RANK() OVER (PARTITION BY personid ORDER BY max(endts) DESC) AS RANK
             from person_net_contacts where netcontacttype = 'WRK' and current_date between effectivedate and enddate and current_timestamp between createts and endts
            group by personid, url, enddate)

left join (select personid, phoneno, enddate, max(effectivedate) as effectivedate, max(endts) as endts,  RANK() OVER (PARTITION BY personid ORDER BY max(endts) DESC) AS RANK
             from person_phone_contacts where phonecontacttype in ('BUSN','Work','Home') and current_date between effectivedate and enddate and current_timestamp between createts and endts
            group by personid, phoneno, enddate) ppc on ppc.personid = pi.personid
            

left join (SELECT personid,coverageamount,createts,personbeneelectionevent, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             FROM person_bene_election WHERE effectivedate < enddate AND current_timestamp BETWEEN createts AND endts and benefitsubclass in ('21') and benefitelection in ( 'E') and selectedoption = 'Y'
            GROUP BY personid,coverageamount,createts,personbeneelectionevent ) as pbelm on pbelm.personid = pbe.personid and pbelm.rank = 1  

left join 

(SELECT personid, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate, 
        RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
        FROM person_bene_election pc1
        LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'BEK_ProBenefits_QE_Export'
        WHERE enddate > effectivedate 
          AND current_timestamp BETWEEN createts AND endts
          and benefitsubclass in ('10')
          and benefitelection in ( 'E')
          and selectedoption = 'Y'
          GROUP BY personid ) as rankmed on rankmed.personid = pe.personid and rankmed.rank = 1  



join person_deduction_setup pds
  on pds.personid = pi.personid
 and pds.etvid in  ('VB1','VB2','VB3','VB4','VB5','V25','V65', 'VCQ')
 and current_date between pds.effectivedate and pds.enddate
 and current_timestamp between pds.createts and pds.endts
 select * from person_deduction_setup where personid = '101' and etvid in  ('VB1','VB2','VB3','VB4','VB5','V25','V65', 'VCQ');
join (select personid, max(effectivedate) as effectivedate, rank() over(partition by personid order by max(effectivedate) desc) as rank
        from person_deduction_setup where etvid in  ('VB1','VB2','VB3','VB4','VB5','V25','V65', 'VCQ') 
         and current_date between effectivedate and enddate
         and current_timestamp between createts and endts) pds on pds.personid = pi.personid


left join (select personid, dependentid, effectivedate, max(enddate) as enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) desc) AS RANK
  from dependent_enrollment
 where benefitsubclass = '13'
   and selectedoption = 'Y'
   and enddate < '2199-12-30'
 group by personid, dependentid, effectivedate) de13 on de13.personid = de.personid and de13.dependentid = de.dependentid and de13.rank = 1
 
left join (select personid, dependentid, effectivedate, max(enddate) as enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) desc) AS RANK
  from dependent_enrollment
 where benefitsubclass = '1W'
   and selectedoption = 'Y'
   and enddate < '2199-12-30'
 group by personid, dependentid, effectivedate) de1w on de1w.personid = de.personid and de1w.dependentid = de.dependentid  
   
left join (select personid, positionid, persposevent, max(effectivedate) as effectivedate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) desc) AS RANK
             from pers_pos
             LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'HMN_Monthly_Promotion_Report'
            where current_timestamp between createts and endts and effectivedate < enddate
              and date_part('year',effectivedate) = date_part('year',elu.lastupdatets)
              and date_part('month',effectivedate) = date_part('month',elu.lastupdatets)
              and personid in ('66253')
            group by personid, positionid, persposevent) pp on pp.personid = pi.personid and pp.rank = 1

--prev_pp  

left join (select personid, positionid, max(effectivedate) as effectivedate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) desc) AS RANK
            from pers_pos 
            LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'HMN_Monthly_Promotion_Report'
           where current_timestamp between createts and endts and effectivedate < enddate
             and effectivedate < elu.lastupdatets
             and personid in ('66253')         
           group by personid, positionid) prev_pp on prev_pp.personid = pp.personid and prev_pp.rank = 1
           
           
select personid, positionid, max(effectivedate) as effectivedate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) desc) AS RANK
  from pers_pos where current_timestamp between createts and endts 
    and effectivedate < enddate and enddate < '2199-12-30'
    and personid in ('66253')
  group by personid, positionid
  ;
  
  
--prev_pd
(select positionid, positiontitle, grade, max(effectivedate) as effectivedate, rank() over(partition by positionid order by max(effectivedate) desc) as rank
             from position_desc where current_timestamp between createts and endts and effectivedate < enddate
             and positionid in ('405510')
            group by positionid, positiontitle, grade)
            ;      
select * from salary_grade where grade in ('13','26');                 
select * from position_job where positionid in ('405551');  
select * from position_desc where positionid in ( '405551');
select * from job_desc where jobid = '70716';


--prev_pp  
select personid, positionid, max(effectivedate) as effectivedate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) desc) AS RANK
  from pers_pos 
  LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'HMN_Monthly_Promotion_Report'
  where current_timestamp between createts and endts and enddate < '2199-12-30' and personid in ('66253')
    and effectivedate < elu.lastupdatets
  group by personid, positionid
  ;



left join 

(SELECT personid, compamount, increaseamount, compevent, frequencycode, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate, 
            RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
            FROM person_compensation pc1
            LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'HMN_PS_CogDetGet_Export'
            WHERE enddate > effectivedate 
              AND current_timestamp BETWEEN createts AND endts
              and increaseamount <> 0
              and effectivedate <= elu.lastupdatets::DATE
            GROUP BY personid, compamount, increaseamount, compevent, frequencycode ) as pc on pc.personid = pe.personid and pc.rank = 1   

  
( select personid, phoneno, enddate, max(effectivedate) as effectivedate, max(endts) as endts,
  RANK() OVER (PARTITION BY personid ORDER BY max(endts) DESC) AS RANK
  from person_phone_contacts
  where phonecontacttype = 'Home' 
   and current_date between effectivedate and enddate 
   and current_timestamp between createts and endts
   group by personid, phoneno, enddate)

  
left join ( select personid, url, max(effectivedate) as effectivedate,  RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
              from person_net_contacts where netcontacttype = 'HomeEmail' and current_date between effectivedate and enddate and current_timestamp between createts and endts
             group by personid, url) pnch on pnch.personid = pe.personid and pnch.rank = 1 

left join ( select personid, url, max(effectivedate) as effectivedate,  RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
              from person_net_contacts where netcontacttype = 'WRK' and current_date between effectivedate and enddate and current_timestamp between createts and endts
             group by personid, url) pncw on pncw.personid = pe.personid and pncw.rank = 1              
 
left join ( select personid, phoneno, max(effectivedate) as effectivedate,  RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
              from person_phone_contacts where phonecontacttype = 'Home' and current_date between effectivedate and enddate and current_timestamp between createts and endts
             group by personid, phoneno) ppch on ppch.personid = pe.personid and ppch.rank = 1

left join ( select personid, phoneno, max(effectivedate) as effectivedate,  RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
              from person_phone_contacts where phonecontacttype = 'Mobile' and current_date between effectivedate and enddate and current_timestamp between createts and endts
             group by personid, phoneno) ppcm on ppcm.personid = pe.personid and ppcm.rank = 1
     


left join (SELECT personid, emplstatus, emplevent,  empleventdetcode, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate, 
            RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
            FROM person_employment pe1
            WHERE enddate > effectivedate 
                   AND current_timestamp BETWEEN createts AND endts
                   and emplstatus = 'L'
                   and enddate <= current_date
            GROUP BY personid, emplstatus, emplevent, empleventdetcode ) leavest on leavest.rank = 1 and leavest.personid = pe.personid

left join (select a.personid, a.compamount,a.percent_in_range, max(asofdate) as asofdate,
rank() over (partition by a.personid order by max(asofdate) desc) as rank
            from personcomppercentinrangeasof a
            join person_employment pe 
            LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'HMN_PS_CogDetGet_Export'
              on pe.personid = a.personid
             and pe.emplstatus = 'T' 
           where asofdate = pe.effectivedate - interval '1 day' --and pe.personid = '63656'
             and effectivedate <= elu.lastupdatets::DATE 
             group by 1,2,3)  as vpcpira on vpcpira.personid = pc.personid and vpcpira.rank = 1    

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
            
--- SHIFT DIF RATE
left join (   
select personid, etv_amount as shift_dif_amt, max(check_date) as check_date,
RANK() OVER (PARTITION BY personid ORDER BY MAX(check_date) ASC) AS RANK   
from pspay_payment_detail where etv_id = 'E05' and etv_amount > 0 group by 1,2 ) sdrate on sdrate.personid = pi.personid and sdrate.rank = 1

left join (select personid,  MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate, 
                  RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_employment 
             where emplstatus = 'A' 
               and current_timestamp between createts and endts
             group by personid) rankpe on rankpe.personid = pi.personid and rankpe.rank = 1  
             
(SELECT wh.personid, wh.check_date, wh.rank, sum(wh.units_ytd) as YTD_hours, sum(wh.amount_ytd) as YTD_taxable_wage
   from    
       (Select 
              ppd.personid
             ,ppd.amount_ytd 
             ,ppd.check_date
             ,ppd.paymentheaderid
             ,ppd.units_ytd
             ,ppd.paycode
             ,rank() OVER (PARTITION BY personid,check_date, paycode ORDER BY MAX(paymentdetailid) DESC) AS RANK  
             from PAYROLL.payment_detail ppd
             where ppd.paymentheaderid in (select paymentheaderid from PAYROLL.payment_header 
             where payscheduleperiodid in (select payscheduleperiodid from pspay_payroll_pay_sch_periods 
             where pspaypayrollid in (select pspaypayrollid from pspay_payroll ppay join edi.edi_last_update elu on elu.feedid =  'KD0_LincolnFinancial_403B_Contributions' and date_part('year',elu.lastupdatets) >= date_part('year',ppay.statusdate) where ppay.pspaypayrollstatusid = 4 ))) 
               and ppd.paycode in (select a.paycode from payroll.pay_code_relationships a where a.paycoderelationshiptype in ('401kWg') and current_date between a.effectivedate and a.enddate and current_timestamp between a.createts and a.endts group by paycode)
            and ppd.personid = '1557'
           -- and ppd.check_date = '2021-03-19' 
            group by 1,2,3,4,5,6
       ) wh where wh.rank = 1 group by 1,2,3
)                                       