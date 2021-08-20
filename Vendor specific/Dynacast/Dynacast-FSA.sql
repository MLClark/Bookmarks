SELECT distinct
 pi.personid
,pbe.benefitsubclass
,pbe.benefitplanid
--,elu.lastupdatets
,pbe.selectedoption
,to_char(pbe.effectivedate,'MM/DD/YYYY')::char(10) AS "Effective Date"
--,CASE pbe.benefitelection WHEN 'T' THEN to_char(pbe.effectivedate,'MM/DD/YYYY')END ::char(10) AS "Termination Date"


,epi.trankey ::char(20) AS "EMPLOYEE ID"
,pi.identity ::char(9) AS "SOCIAL SEC #" 
,pne.fname ::char(20) AS "FIRST NAME"
,pne.lname ::char(20) AS "LAST NAME"
,pne.mname ::char(20) AS "MIDDLE"
,pne.title ::char(4) AS "TITLE"
,epi.emailaddress ::char(50) AS "EMAIL ADDRESS"
,' ' ::char(1) AS "CATEGORY OR DEPARTMENT"
,to_char(pve.birthdate, 'MM/DD/YYYY') ::char(10) AS "BIRTH DATE"
,pve.gendercode ::char(1) AS "GENDER"


,epi.streetaddress1 ::char(50) AS "STREET 1"
,epi.streetaddress2 ::char(50) AS "STREET 2"
,epi.city ::char(50) AS "CITY"
,epi.statecode::char(2) AS "STATE"
,epi.zipcode::char(9) AS "ZIP"

,epi.homephone ::char(10) AS "HOME PHONE"
,epi.workphone ::char(10) AS "WORK PHONE"

,epi.streetaddress1 ::char(50) AS "MAILING STREET 1"
,epi.streetaddress2 ::char(50) AS "MAILING STREET 2"
,epi.city ::char(50) AS "MAILING CITY"
,epi.statecode::char(2) AS "MAILING STATE"
,epi.zipcode::char(9) AS "MAILING ZIP"
,case pbe.benefitsubclass WHEN '60' THEN '1' ELSE '2' END ::char(5) AS "PLAN TYPE"
,to_char(pbe.effectivedate,'MM/DD/YYYY') ::char(10) AS "ACCOUNT START DATE"
,to_char(pbe.planyearenddate,'MM/DD/YYYY') ::char(10) AS "ACCOUNT END DATE"


,CASE WHEN pbe.benefitelection = 'T' 
      THEN pbe1.coverageamount       
      ELSE pbe.coverageamount END AS "ACCOUNT ELECTION AMOUNT"
,pbe.benefitplanid ::char(10) AS "RA PLAN ID"


from person_identity pi

JOIN edi.edi_last_update elu
  ON elu.feedid = 'AJG-Dynacast-FSA'
  
LEFT JOIN edi.edidependent eed
  ON eed.employeepersonid = pi.personid
  
JOIN person_names pne 
  ON pne.personid = pi.personid
 AND current_date BETWEEN pne.effectivedate AND pne.enddate
 AND current_timestamp BETWEEN pne.createts AND pne.endts      
 AND pne.enddate > now()
 
LEFT JOIN person_address pa 
  ON pa.personid = pi.personid
 AND current_date BETWEEN pa.effectivedate AND pa.enddate
 AND current_timestamp BETWEEN pne.createts AND pa.endts      
 AND pa.enddate > now()

JOIN person_vitals pve 
  ON pve.personid = pi.personid 
 AND current_date BETWEEN pve.effectivedate AND pve.enddate
 AND current_timestamp BETWEEN pve.createts AND pve.endts    
 AND pve.enddate > now() 

JOIN person_bene_election pbe  
  ON pbe.personid = pI.personid
 AND pbe.benefitsubclass IN ( '60', '61')
 AND pbe.benefitelection IN ('E')
 AND pbe.enddate = '2199-12-31' 
 AND current_date BETWEEN pbe.effectivedate AND pbe.enddate 
 AND current_timestamp BETWEEN pbe.createts AND pbe.endts
 
JOIN person_employment pe
  ON pe.personid = pi.personid
 AND current_date BETWEEN pe.effectivedate AND pe.enddate
 AND current_timestamp BETWEEN pe.createts AND pe.endts
 
JOIN person_bene_election pbe1
  ON pbe1.personid = pbe.personid
 AND pbe1.personbeneelectionpid in 
   (SELECT MAX(pbe2.personbeneelectionpid) as personbeneelectionpid
      FROM person_bene_election pbe2
     WHERE pbe2.personid = pi.personid
       AND pbe2.benefitsubclass IN ( '60', '61')
        AND pbe.benefitelection IN ('E')
       AND pbe2.enddate = '2199-12-31'
       AND current_date BETWEEN pbe2.effectivedate AND pbe2.enddate 
       AND current_timestamp BETWEEN pbe2.createts AND pbe2.endts
)      
       
 
JOIN benefit_plan_desc bpd 
  ON bpd.benefitsubclass = pbe.benefitsubclass 
 AND bpd.enddate = '2199-12-31' 
 AND bpd.benefitplanid = pbe.benefitplanid
 
LEFT JOIN edi.etl_employment_term_data eetd
  ON eetd.personid = pi.personid

LEFT JOIN edi.etl_personal_info epi
  ON epi.personid = pbe.personid
 

where pi.identitytype = 'SSN' 
  and pbe.effectivedate >= elu.lastupdatets


