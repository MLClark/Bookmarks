select distinct

 pi.personid
,'TERMED EE' ::varchar(30) as qsource 
,left(pi.identity,3)||'-'||substring(pi.identity,4,2)||'-'||right(pi.identity,4) ::char(11) as essn
,pn.fname ::varchar(30) as fname
,pn.lname ::varchar(30) as lname
,to_char(pv.birthdate,'mm/dd/yyyy')::char(10) as dob
,pv.gendercode ::char(1) as gender
,'Employee' ::char(8) as relationship
,pa.streetaddress ::varchar(30) as addr1
,pa.streetaddress2 ::varchar(30) as addr2
,pa.city ::varchar(40) as city
,pa.stateprovincecode ::char(2) as state
,pa.postalcode ::char(5) as zip
,coalesce(ppch.phoneno,ppcm.phoneno) ::char(10) as phone 
,rtrim(ltrim(coalesce(pncw.url,pnch.url))) ::varchar(100) as work_email 
,'BiWeekly' ::char(8) as payroll_freq
,to_char(pbe.effectivedate,'mm/dd/yyyy')::char(10) as effective_date
,'EE' ::char(2) as ee_contrib_source
,null as er_contrib
,case when rankmfsa.coverageamount = 2500.00 then cast(pbemfsa.monthlyamount/2-.01 as dec(18,2)) 
      when rankmfsa.coverageamount = 1000.00 then cast(pbemfsa.monthlyamount/2-.01 as dec(18,2)) 
      else cast(pbemfsa.monthlyamount/2 as dec(18,2))end as mfsa_ppay_contrib
,cast(rankmfsa.coverageamount as dec(18,2)) as mfsa_annual_election
,cast(rankdfsa.coverageamount as dec(18,2)) as dfsa_annual_election
,cast(pbedfsa.monthlyamount/2 as dec(18,2)) as dfsa_ppay_contrib
,null as term_date
 
from person_identity pi

join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts
 
join person_bene_election pbe
  on pbe.personid = pi.personid 
 and pbe.benefitsubclass in ('60','61')
 and pbe.selectedoption = 'Y'
 and pbe.benefitelection = 'E'
 and current_timestamp between pbe.createts and pbe.endts
 and pbe.personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts 
                         and benefitsubclass in ('60','61') and benefitelection = 'E' and selectedoption = 'Y' and effectivedate < enddate)  

left join person_bene_election pbemfsa
  on pbemfsa.personid = pbe.personid 
 and pbemfsa.benefitsubclass in ('60')
 and pbemfsa.selectedoption = 'Y'
 and pbemfsa.benefitelection = 'E'
 and current_date between pbemfsa.effectivedate and pbemfsa.enddate
 and current_timestamp between pbemfsa.createts and pbemfsa.endts 

left join person_bene_election pbedfsa
  on pbedfsa.personid = pbe.personid 
 and pbedfsa.benefitsubclass in ('61')
 and pbedfsa.selectedoption = 'Y'
 and pbedfsa.benefitelection = 'E'
 and current_date between pbedfsa.effectivedate and pbedfsa.enddate
 and current_timestamp between pbedfsa.createts and pbedfsa.endts  

left join (select personid, monthlyamount, coverageamount, max(effectivedate) as effectivedate, max(enddate) as enddate,
             RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election
            where benefitsubclass in ('60') and selectedoption = 'Y' and benefitelection in ('E') 
              and current_date between effectivedate and enddate and current_timestamp between createts and endts
            group by 1,2,3) rankmfsa on rankmfsa.personid = pbe.personid and rankmfsa.rank = 1

left join (select personid, monthlyamount, coverageamount, max(effectivedate) as effectivedate, max(enddate) as enddate,
             RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election
            where benefitsubclass in ('61') and selectedoption = 'Y' and benefitelection in ('E') 
              and current_date between effectivedate and enddate and current_timestamp between createts and endts
            group by 1,2,3) rankdfsa on rankdfsa.personid = pbe.personid and rankdfsa.rank = 1
             

  
join person_names pn
  on pn.personid = pi.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts
 
left join person_vitals pv
  on pv.personid = pi.personid
 and current_date between pv.effectivedate and pv.enddate
 and current_timestamp between pv.createts and pv.endts

left join person_address pa
  on pa.personid = pi.personid
 and pa.addresstype = 'Res'
 and current_date between pa.effectivedate and pa.enddate
 and current_timestamp between pa.createts and pa.endts 

left join person_phone_contacts ppch 
  on ppch.personid = pi.personid
 and ppch.phonecontacttype = 'Home'  
 and current_date between ppch.effectivedate and ppch.enddate
 and current_timestamp between ppch.createts and ppch.endts 

left join person_phone_contacts ppcm 
  on ppcm.personid = pi.personid
 and ppcm.phonecontacttype = 'Mobile'     
 and current_date between ppcm.effectivedate and ppcm.enddate
 and current_timestamp between ppcm.createts and ppcm.endts  

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

where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts 
  and pe.emplstatus in ('R','T')