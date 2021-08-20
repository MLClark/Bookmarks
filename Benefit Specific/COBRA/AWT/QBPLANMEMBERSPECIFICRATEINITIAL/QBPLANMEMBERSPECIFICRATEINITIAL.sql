SELECT distinct  
--- this is only required for FSA plans
 pi.personid
,pp.schedulefrequency
,'[QBPLANMEMBERSPECIFICRATEINITIAL]' :: varchar(35) as recordtype
,replace(pi.identity,'-','') :: char(9) as emp_ssn -- not in out put
,'DBI Medical FSA' ::varchar(150) as plan_name    
,case when pp.schedulefrequency = 'B' then cast (rankpbe.monthlyamount * 12 / 26 as dec(18,2)) 
      else cast (rankpbe.monthlyamount * 12 / 52 as dec(18,2)) end as rate
,'5A' ::char(10) as sort_seq

-- select * from payunitdetails

FROM person_identity pi

join person_identity pip
  on pip.personid = pi.personid
 and pip.identitytype = 'PSPID'
 and current_timestamp between pip.createts and pip.endts
 
join (select personid, schedulefrequency, max(effectivedate),RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
        from pers_pos where current_timestamp between createts and endts group by 1,2) pp on pp.personid = pi.personid and pp.rank = 1

LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'AWT_Discovery_COBRA_QB_Export'

JOIN person_employment pe 
  ON pe.personid = pi.personid 
 AND current_date between pe.effectivedate AND pe.enddate 
 AND current_timestamp between pe.createts AND pe.endts

join 

(SELECT personid, benefitsubclass, benefitcoverageid, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate, 
        RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
        FROM person_bene_election pc1
        LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'AWT_Discovery_COBRA_QB_Export'
        WHERE enddate > effectivedate 
          AND current_timestamp BETWEEN createts AND endts
          and benefitsubclass in ('60','61')
          and benefitelection = 'E'
          and selectedoption = 'Y'
        GROUP BY personid ,benefitsubclass,benefitcoverageid) as pbeedt on pbeedt.personid = pe.personid and pbeedt.rank = 1   

JOIN person_bene_election pbe 
  on pbe.personid = pbeedt.personid 
 and pbe.selectedoption = 'Y' 
 and pbe.benefitsubclass in ('60','61')
 and pbe.benefitplanid <> '132'
 --and pbe.benefitcoverageid = pbeedt.benefitcoverageid
 AND current_date between pbe.effectivedate AND pbe.enddate 
 AND current_timestamp between pbe.createts AND pbe.endts
  -- to be qualified for cobra the emp must have participated in employer's health care plan  
 and pbe.personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts 
                         and benefitsubclass in ('60','61') and benefitelection = 'E' and selectedoption = 'Y') 
                         

left join (select personid, cast(monthlyamount as dec(18,2)) as monthlyamount, max(effectivedate) as effectivedate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election where benefitsubclass in ('60','61') and benefitelection = 'E' and selectedoption = 'Y' and current_timestamp between createts and endts 
            group by 1,2) as rankpbe on rankpbe.personid = pbe.personid and rankpbe.rank = 1                
  
            
left JOIN benefit_plan_desc bpd  
  on bpd.benefitsubclass = pbe.benefitsubclass
 and bpd.benefitplanid = pbe.benefitplanid
 AND current_date between bpd.effectivedate and bpd.enddate
 AND current_timestamp between bpd.createts and bpd.endts

 
left join person_locations pl
  on pl.personid = pi.personid
 and current_date between pl.effectivedate and pl.enddate
 and current_timestamp between pl.createts and pl.endts 
 
left join location_codes lc
  on lc.locationid = pl.locationid
 and current_date between lc.effectivedate and lc.enddate
 and current_timestamp between lc.createts and lc.endts 
where pi.identitytype = 'SSN' 
 AND CURRENT_TIMESTAMP BETWEEN pi.createts and pi.endts 
  and (pe.effectivedate >= elu.lastupdatets::DATE 
   or (pe.createts > elu.lastupdatets and pe.effectivedate < coalesce(elu.lastupdatets, '2017-01-01')) )
 and pe.emplstatus in ('R','T')
-- select * from edi.edi_last_update
order by pi.personid