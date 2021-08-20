select distinct
 pi.personid as group_personid
,pdr.dependentid as dependentid
,'TERMED EE W DEP' ::varchar(30) as qsource
,'"MS Clinical Services, LLC dba MedSource"' ::varchar(100) as company_code
,' ' ::char(1) as dept_div
,left(pi.identity,3)||'-'||substring(pi.identity,4,2)||'-'||right(pi.identity,4) ::char(11) as ssn
,pn.fname ::varchar(50) as fname
,pn.lname ::varchar(50) as lname
,pn.mname ::char(1) as mname
,'"'||pa.streetaddress||'"'::varchar(50) as addr1
,'"'||pa.streetaddress2||'"' ::varchar(50) as addr2
,pa.city ::varchar(50) as city
,pa.stateprovincecode ::char(2) as state
,pa.postalcode ::char(5) as zip
,to_char(pv.birthdate,'mm/dd/yyyy')::char(10) as dob
,to_char(rankpe.effectivedate,'mm/dd/yyyy')::char(10) as doh
,to_char(least(rankmed.effectivedate,rankdnt.effectivedate,rankvsn.effectivedate,rankfsa.effectivedate),'mm/dd/yyyy')::char(10) as edoc
,to_char(current_date,'mm/dd/yyyy')::char(10) as file_date
,rtrim(ltrim(pncw.url)) ::varchar(100) as email 

----- benefits

,'Termination of Employment' ::varchar(40) as q_event_type
,to_char(least(rankmed.effectivedate,rankdnt.effectivedate,rankvsn.effectivedate,rankfsa.effectivedate,rankfsadep.effectivedate),'mm/dd/yyyy')::char(10) as q_event_date

----- spouse 
,left(spid.identity,3)||'-'||substring(spid.identity,4,2)||'-'||right(spid.identity,4) ::char(11) as spssn
,spnd.fname ::varchar(40) as sp_fname    
,spnd.lname ::varchar(40) as sp_lname  
,spnd.mname ::char(1) as sp_mname  
,to_char(spvd.birthdate,'mm/dd/yyyy') ::char(10) as sp_dob


----- children
,left(pid.identity,3)||'-'||substring(pid.identity,4,2)||'-'||right(pid.identity,4) ::char(11) as dp_ssn
,pnd.fname ::varchar(40) as dp_fname
,pnd.lname ::varchar(40) as dp_lname  
,to_char(pvd.birthdate,'mm/dd/yyyy') ::char(10) as dp_dob
,coalesce(rankdep.depid,1) as key_rank
 
from person_identity pi

LEFT JOIN edi.edi_last_update elu ON elu.feedid =  'BEK_ProBenefits_QE_Export'

left join (select personid,  MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate, 
                  RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_employment 
             where emplstatus = 'A' 
               and current_timestamp between createts and endts
             group by personid) rankpe on rankpe.personid = pi.personid and rankpe.rank = 1

join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts

join person_bene_election pbe 
  on pbe.personid = pi.personid
 and pbe.benefitsubclass in ('10','11','14','60','61')
 and pbe.selectedoption = 'Y' 
 and pbe.benefitplanid is not null
 --and current_date between pbe.effectivedate and pbe.enddate
 and current_timestamp between pbe.createts and pbe.endts
   -- to be qualified for cobra the emp must have participated in employer's health care plan  
 and pbe.personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts 
                         and benefitsubclass in ('10','11','14','60','61') and benefitelection = 'E' and selectedoption = 'Y' and effectivedate < enddate) 

  
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

left join 

(SELECT personid, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate, 
        RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
        FROM person_bene_election pc1
        LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'BEK_ProBenefits_QE_Export'
        WHERE enddate > effectivedate 
          AND current_timestamp BETWEEN createts AND endts
          and benefitsubclass in ('11')
          and benefitelection in ( 'E')
          and selectedoption = 'Y'
          GROUP BY personid ) as rankdnt on rankdnt.personid = pe.personid and rankdnt.rank = 1  

left join 

(SELECT personid, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate, 
        RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
        FROM person_bene_election pc1
        LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'BEK_ProBenefits_QE_Export'
        WHERE enddate > effectivedate 
          AND current_timestamp BETWEEN createts AND endts
          and benefitsubclass in ('14')
          and benefitelection in ( 'E')
          and selectedoption = 'Y'
          GROUP BY personid ) as rankvsn on rankvsn.personid = pe.personid and rankvsn.rank = 1  

left join 

(SELECT personid, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate, 
        RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
        FROM person_bene_election pc1
        LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'BEK_ProBenefits_QE_Export'
        WHERE enddate > effectivedate 
          AND current_timestamp BETWEEN createts AND endts
          and benefitsubclass in ('60')
          and benefitelection in ( 'E')
          and selectedoption = 'Y'
          GROUP BY personid ) as rankfsa on rankfsa.personid = pe.personid and rankfsa.rank = 1  


left join 

(SELECT personid, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate, 
        RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
        FROM person_bene_election pc1
        LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'BEK_ProBenefits_QE_Export'
        WHERE enddate > effectivedate 
          AND current_timestamp BETWEEN createts AND endts
          and benefitsubclass in ('61')
          and benefitelection in ( 'E')
          and selectedoption = 'Y'
          GROUP BY personid ) as rankfsadep on rankfsadep.personid = pe.personid and rankfsadep.rank = 1                                         
          
JOIN benefit_plan_desc bpd  
  on bpd.benefitsubclass = pbe.benefitsubclass
 and bpd.benefitplanid = pbe.benefitplanid
 AND current_date between bpd.effectivedate and bpd.enddate
 AND current_timestamp between bpd.createts and bpd.endts 

left JOIN benefit_coverage_desc bcd 
  on bcd.benefitcoverageid = pbe.benefitcoverageid 
 and current_date between bcd.effectivedate and bcd.enddate
 and current_timestamp between bcd.createts and bcd.endts 
          
join person_names pn
  on pn.personid = pi.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts

left join person_address pa
  on pa.personid = pi.personid
 and pa.addresstype = 'Res'
 and current_date between pa.effectivedate and pa.enddate
 and current_timestamp between pa.createts and pa.endts
 
left join person_vitals pv
  on pv.personid = pi.personid
 and current_date between pv.effectivedate and pv.enddate
 and current_timestamp between pv.createts and pv.endts 

LEFT JOIN person_net_contacts pncw 
  ON pncw.personid = pi.personid 
 AND pncw.netcontacttype = 'WRK'::bpchar 
 AND current_date between pncw.effectivedate and pncw.enddate
 AND current_timestamp between pncw.createts and pncw.endts 

LEFT JOIN person_net_contacts pnch
  ON pnch.personid = pi.personid 
 AND pnch.netcontacttype = 'HomeEmail'::bpchar 
 AND current_date between pnch.effectivedate and pnch.enddate
 AND current_timestamp between pnch.createts and pnch.endts 

LEFT JOIN person_net_contacts pnco
  ON pnco.personid = pi.personid 
 AND pnco.netcontacttype = 'Other'::bpchar 
 AND current_date between pnco.effectivedate and pnco.enddate
 AND current_timestamp between pnco.createts and pnco.endts   
 
left join person_dependent_relationship pdr
  on pdr.personid = pe.personid
 and pdr.dependentrelationship in ('S','D','C','AC')
 and current_date between pdr.effectivedate and pdr.enddate
 and current_timestamp between pdr.createts and pdr.endts

left join person_dependent_relationship spdr
  on spdr.personid = pe.personid
 and spdr.dependentrelationship in ('SP','DP')
 and current_date between spdr.effectivedate and spdr.enddate
 and current_timestamp between spdr.createts and spdr.endts 

left JOIN dependent_enrollment de
  on de.personid = pdr.personid
 and de.dependentid = pdr.dependentid
 AND de.selectedoption = 'Y'
 and de.benefitsubclass in ('10','11','14','60','61')
 --and current_date between de.effectivedate and de.enddate
 and current_timestamp between de.createts and de.endts

left JOIN dependent_enrollment sde
  on sde.personid = spdr.personid
 and sde.dependentid = spdr.dependentid
 AND sde.selectedoption = 'Y'
 and sde.benefitsubclass in ('10','11','14','60','61')
 --and current_date between sde.effectivedate and sde.enddate
 and current_timestamp between sde.createts and sde.endts
 
left join person_names pnd
  on pnd.personid = de.dependentid
 and pnd.nametype = 'Dep'
 and current_date between pnd.effectivedate and pnd.enddate
 and current_timestamp between pnd.createts and pnd.endts

left join person_names spnd
  on spnd.personid = sde.dependentid
 and spnd.nametype = 'Dep'
 and current_date between spnd.effectivedate and spnd.enddate
 and current_timestamp between spnd.createts and spnd.endts
 
left join person_identity pid
  on pid.personid = de.dependentid
 and pid.identitytype = 'SSN'
 and current_timestamp between pid.createts and pid.endts 

left join person_identity spid
  on spid.personid = sde.dependentid
 and spid.identitytype = 'SSN'
 and current_timestamp between spid.createts and spid.endts 
 
LEFT JOIN person_vitals pvd 
  ON pvd.personid = de.dependentid
 AND current_date between pvd.effectivedate AND pvd.enddate 
 AND current_timestamp between pvd.createts AND pvd.endts  

LEFT JOIN person_vitals spvd 
  ON spvd.personid = sde.dependentid
 AND current_date between spvd.effectivedate AND spvd.enddate 
 AND current_timestamp between spvd.createts AND spvd.endts    

left JOIN 
(select distinct pdr.personid, pdr.dependentid, rank() over(partition by pdr.personid order by  pdr.dependentid asc) as depid
   from person_dependent_relationship pdr 

  WHERE pdr.dependentrelationship in ('S','D','C','AC')
    AND CURRENT_DATE BETWEEN pdr.EFFECTIVEDATE AND pdr.ENDDATE
    AND CURRENT_TIMESTAMP BETWEEN pdr.CREATETS AND pdr.ENDTS) rankdep on rankdep.personid = pdr.personid and rankdep.dependentid = pdr.dependentid
             

left join person_maritalstatus pm
  on pm.personid = de.dependentid
 and current_date between pm.effectivedate and pm.enddate
 and current_timestamp between pm.createts and pm.endts 
 

  
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  and pe.emplstatus = 'T'
  and pe.personid = '289'
  order by 1 , key_rank