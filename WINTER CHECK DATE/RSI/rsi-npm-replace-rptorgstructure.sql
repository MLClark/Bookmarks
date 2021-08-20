/*
The NPM file for COBRA should only include an employee that goes on one of CAPPS’ COBRA eligible plans 
(Medical, Dental, Vision, HRA, Medical FSA) either as a new employee, new spouse of a covered employee or 
employee electing coverage for the first time at Open Enrollment. 
We do not want information for anyone that is a new hire but not taking benefits or 
any information about dependents which it looks like the file contains. 

The NPM file loaded fine into our test system but I compared the names to who I have in the live version already. 
I’m not sure (582) should be on the file. 
He is one of the partners and had gotten divorced in June and his ex-wife was sent COBRA paperwork. 
He had already been on the plan so I’m not sure why he is showing up as a New Plan member now. 
Perhaps because his coverage level would have dropped from QB+Spouse to QB Only? 
He wouldn’t need to be on the file if that’s the case. 
Could you maybe look in to why that one is showing up?
*/

SELECT distinct
pi.personid,
--pbe.compplanid,
--pbe.benefitsubclass,


'Capps, Inc./Rausch, Sturm, Israel, Enerson & Hornik, LLC' ::char(100)                          AS ClientName,
CASE WHEN ro.org2desc = 'Enerson Law LLC' THEN 'Enerson Law, LLC'
     ELSE ro.org2desc END ::char(50)                                                            AS ClientDivisionName,
pi.identity ::char(9)                                                                           AS SSN,
'' ::char(35)                                                                                   AS Salutation,    
rtrim(ltrim(pn.fname))::char(50)                                                                AS FirstName,
rtrim(ltrim(upper(substring(pn.mname from 1for 1))))::char(1)                                   AS MiddleInitial,
rtrim(ltrim(pn.lname)) ::char(50)                                                               AS LastName,
'' ::char(20)                                                                                   AS IndividualIdentifier,
rtrim(ltrim(pa.streetaddress)) ::char(50)                                                       AS Address1,
rtrim(ltrim(pa.streetaddress2)) ::char(50)                                                      AS Address2,
rtrim(ltrim(pa.city)) ::char(50)                                                                AS City,
rtrim(ltrim(pa.stateprovincecode)) ::char(50)                                                   AS StateOrProvince,
rtrim(ltrim(pa.postalcode)) ::char(35)                                                          AS PostalCode,
' ' ::char(50)                                                                                  AS Country,
CASE
    WHEN ppc2.phonecontacttype != 'Home'::bpchar 
    THEN rtrim(ltrim(ppc2.phoneno::character varying(10)))
    ELSE NULL::character varying(10)
END ::char(10)                                                                                   AS Phone,
CASE
    WHEN ppc2.phonecontacttype = 'Home'::bpchar 
    THEN rtrim(ltrim(ppc2.phoneno::character varying(10)))
    ELSE NULL::character varying(9)
END ::char(10)                                                                                  AS Phone2,
rtrim(ltrim(pnc.url)) ::char(100)                                                               AS Email,
rtrim(ltrim(pv.gendercode)) ::char(1)                                                           AS Sex,
to_char(pe.emplhiredate, 'MM/dd/YYYY')::char(10)                                                AS HireDate,
' ' ::char(1)                                                                                   AS HasWaivedAllCoverage,
'TRUE'::char(5)                                                                                 AS UsesFamilyInAddress


FROM person_identity pi
JOIN edi.edi_last_update edu on edu.feedID = 'RSI_DBS_COBRA_NPM_Feed'
JOIN person_employment pe 
  ON pe.personid = pi.personid 
 and pe.emplstatus <> 'L' 
 AND current_date between pe.effectivedate AND pe.enddate 
 AND current_timestamp between pe.createts AND pe.endts
 
LEFT JOIN person_bene_election pbe 
  on pbe.personid = pi.personid and benefitelection = 'E' and selectedoption = 'Y' 
 AND current_date between pbe.effectivedate AND pbe.enddate 
 AND current_timestamp between pbe.createts AND pbe.endts
 
LEFT JOIN person_names pn 
  ON pn.personid = pi.personid AND pn.nametype = 'Legal'::bpchar 
 AND current_date between pn.effectivedate AND pn.enddate 
 AND current_timestamp between pn.createts AND pn.endts
 
LEFT JOIN person_net_contacts pnc 
  ON pnc.personid = pi.personid AND pnc.netcontacttype = 'HomeEmail'::bpchar 
 AND current_date between pnc.effectivedate AND pnc.enddate 
 AND current_timestamp between pnc.createts AND pnc.endts
 
LEFT JOIN person_address pa 
  ON pa.personid = pi.personid AND pa.addresstype = 'Res'::bpchar 
 AND current_date between pa.effectivedate AND pa.enddate 
 AND current_timestamp between pa.createts AND pa.endts
 
LEFT JOIN ( SELECT max(ppc.personid) AS personid,
                   min(ppc.percontactpid) AS percontactpid
              FROM person_phone_contacts ppc
             WHERE current_date between ppc.effectivedate AND ppc.enddate 
               AND current_timestamp between ppc.createts AND ppc.endts
             GROUP BY ppc.personid) ppc1 
  ON pi.personid = ppc1.personid

LEFT JOIN person_phone_contacts ppc2 
  ON ppc2.personid = pi.personid 
 AND ppc2.percontactpid = ppc1.percontactpid 
 AND current_date between ppc2.effectivedate AND ppc2.enddate 
 AND current_timestamp between ppc2.createts AND ppc2.endts
 
LEFT JOIN person_vitals pv 
  ON pv.personid = pi.personid 
 AND current_date between pv.effectivedate AND pv.enddate 
 AND current_timestamp between pv.createts AND pv.endts
 
LEFT JOIN comp_plan_benefit_plan cpbp 
  on cpbp.benefitsubclass = pbe.benefitsubclass
 AND current_date between cpbp.effectivedate AND cpbp.enddate 
 AND current_timestamp between cpbp.createts AND cpbp.endts
 
LEFT JOIN edi.etl_employment_term_data etd 
  ON etd.personid = pbe.personid
  
JOIN edi.etl_employment_data ed 
  ON ed.personid = pe.personid
  
LEFT JOIN pos_org_rel por  
  ON por.positionid = COALESCE(ed.positionid, etd.positionid)
 AND por.posorgreltype = 'Member'  
 AND current_date between por.effectivedate AND por.enddate
 AND current_timestamp between por.createts AND por.endts

LEFT JOIN edi.orgstructure ro 
  ON ro.org1id = por.organizationid 
  
WHERE pi.identitytype = 'SSN' and pi.identity is not NULL 
 and cpbp.cobraplan = 'Y' 
 AND current_timestamp between pi.createts AND pi.endts  
 AND pbe.effectivedate  >=   '2018-01-01'
 --and pi.personid = '1895'


;
