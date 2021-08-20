--select * from person_vitals limit 100

select distinct
 pi.personid as group_personid   --1
,de.dependentid  --2
,left(pi.identity,3)||'-'||substring(pi.identity,4,2)||'-'||right(pi.identity,4) ::char(11) as ssn --3
,pn.fname ::varchar(50) as fname   --4
,pn.lname ::varchar(50) as lname   --5
,pn.mname ::char(1) as mname    
,Replace(pa.streetaddress,',','') || ' ' || COALESCE(Replace(pa.streetaddress2,',',''),'') ::varchar(50) as addr1
--,pa.streetaddress2 ::varchar(50) as addr2
,'' ::varchar(50) as addr2
,pa.city ::varchar(50) as city
,pa.stateprovincecode ::char(2) as state
,pa.postalcode ::char(5) as zip
,pv.gendercode as gender 
,to_char(pv.birthdate,'mm/dd/yyyy')::char(10) as dob
,to_char(pe.effectivedate,'mm/dd/yyyy')::char(10) as doh
,case when pbeM.planId = '6'  then 'Kaiser BuyUp $3000' --'Regence Buy-Up'
      when pbeM.planId = '9'  then 'Kaiser Base $5000'  --'Regence Base' 
      when pbeM.planId = '96' then 'Kaiser $2000'  --NEW for 2021 Medical BuyUp
       END ::varchar(30) as plandesc 
--,pbeM.plandesc
,pbeM.coveragedesc
,pbed.plandesc
,pbeD.coveragedesc
,pbeV.plandesc
,pbeV.coveragedesc
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

,elu.lastupdatets
 
from person_identity pi

JOIN edi.edi_last_update elu ON elu.feedid =  'RBA_SoundAdmin_COBRA_IN_Export'

join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts

join person_bene_election pbe 
  on pbe.personid = pi.personid
 and pbe.benefitsubclass in ('10','11','14')
 and pbe.selectedoption = 'Y' 
 and benefitelection = 'E' 
 and pbe.effectivedate < pbe.enddate
 and current_timestamp between pbe.createts and pbe.endts
 and pbe.personid NOT IN (Select distinct PRpbe.personid from person_bene_election PRpbe WHERE PRpbe.personid = pbe.personid
										       and PRpbe.benefitsubclass in ('10','11','14')
										       and PRpbe.selectedoption = 'Y' 
										       and PRpbe.benefitelection = 'E' 
										       and PRpbe.effectivedate < PRpbe.endDate
											   and PRpbe.endDate < pbe.effectiveDate	
											   and current_timestamp between PRpbe.createts and PRpbe.endts)

--Subquery to get plans and coverage descriptions for medical plan 
left join (Select pbe1.benefitplanid as planId, 
		  pbe1.benefitcoverageid as coverageId, 
		  pbe1.personid as EmpId,
		  bpdm.benefitplandesc as plandesc,
		  bcdm.benefitcoveragedesc as coveragedesc
			from person_bene_election pbe1
			inner join benefit_plan_desc bpdM on bpdM.benefitsubclass = pbe1.benefitsubclass
				 and bpdM.benefitplanid = pbe1.benefitplanid
				 AND current_date between bpdM.effectivedate and bpdM.enddate
				 AND current_timestamp between bpdM.createts and bpdM.endts 
				
			inner  JOIN benefit_coverage_desc bcdM on bcdM.benefitcoverageid = pbe1.benefitcoverageid 
				 and current_date between bcdM.effectivedate and bcdM.enddate
				 and current_timestamp between bcdM.createts and bcdM.endts 
			WHERE pbe1.benefitsubclass in ('10')
			  and pbe1.selectedoption = 'Y' 
			  and pbe1.benefitelection = 'E' 
			  and pbe1.effectivedate < pbe1.enddate
			  and current_timestamp between pbe1.createts and pbe1.endts ) pbeM on pbeM.EmpId = pbe.personid     

 --Subquery to get plans and coverage descriptions for dental plan 
left join (Select pbe2.benefitplanid as planId, 
		  pbe2.benefitcoverageid as coverageId, 
		  pbe2.personid as EmpId,
		  bdpd.benefitplandesc as plandesc,
		  bcdd.benefitcoveragedesc as coveragedesc
			from person_bene_election pbe2
			inner join benefit_plan_desc bdpd on bdpd.benefitsubclass = pbe2.benefitsubclass
				 and bdpd.benefitplanid = pbe2.benefitplanid
				 AND current_date between bdpd.effectivedate and bdpd.enddate
				 AND current_timestamp between bdpd.createts and bdpd.endts 
				
			inner  JOIN benefit_coverage_desc bcdd on bcdd.benefitcoverageid = pbe2.benefitcoverageid 
				 and current_date between bcdd.effectivedate and bcdd.enddate
				 and current_timestamp between bcdd.createts and bcdd.endts 
			WHERE pbe2.benefitsubclass in ('11')
			  and pbe2.selectedoption = 'Y' 
			  and pbe2.benefitelection = 'E' 
			  and pbe2.effectivedate < pbe2.enddate
			  and current_timestamp between pbe2.createts and pbe2.endts ) pbeD on pbeD.EmpId = pbe.personid 

			  
 --Subquery to get plans and coverage descriptions for vision plan 
left join (Select pbe3.benefitplanid as planId, 
		  pbe3.benefitcoverageid as coverageId, 
		  pbe3.personid as EmpId,
		  bdpv.benefitplandesc as plandesc,
		  bcdv.benefitcoveragedesc as coveragedesc
			from person_bene_election pbe3
			inner join benefit_plan_desc bdpv on bdpv.benefitsubclass = pbe3.benefitsubclass
				 and bdpv.benefitplanid = pbe3.benefitplanid
				 AND current_date between bdpv.effectivedate and bdpv.enddate
				 AND current_timestamp between bdpv.createts and bdpv.endts 
				
			inner  JOIN benefit_coverage_desc bcdv on bcdv.benefitcoverageid = pbe3.benefitcoverageid 
				 and current_date between bcdv.effectivedate and bcdv.enddate
				 and current_timestamp between bcdv.createts and bcdv.endts 
			WHERE pbe3.benefitsubclass in ('14')
			  and pbe3.selectedoption = 'Y' 
			  and pbe3.benefitelection = 'E' 
			  and pbe3.effectivedate < pbe3.enddate
			  and current_timestamp between pbe3.createts and pbe3.endts ) pbeV on pbeV.EmpId = pbe.personid 
         
/*JOIN benefit_plan_desc bpd  
  on bpd.benefitsubclass = pbe.benefitsubclass
 and bpd.benefitplanid = pbe.benefitplanid
 AND current_date between bpd.effectivedate and bpd.enddate
 AND current_timestamp between bpd.createts and bpd.endts 

left JOIN benefit_coverage_desc bcd 
  on bcd.benefitcoverageid = pbe.benefitcoverageid 
 and current_date between bcd.effectivedate and bcd.enddate
 and current_timestamp between bcd.createts and bcd.endts */
          
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
 and de.benefitsubclass = pbe.benefitsubclass
 --and current_date between de.effectivedate and de.enddate
 and current_timestamp between de.createts and de.endts

left JOIN dependent_enrollment sde
  on sde.personid = spdr.personid
 and sde.dependentid = spdr.dependentid
 AND sde.selectedoption = 'Y'
 and sde.benefitsubclass = pbe.benefitsubclass
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


WHERE pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  and current_date < pbe.planyearenddate

/*(pe.effectivedate >= elu.lastupdatets::DATE 
   or (pe.createts > elu.lastupdatets and pe.effectivedate <  coalesce(elu.lastupdatets, '2019-01-01')) 
*/
   and ((pbe.effectivedate >= elu.lastupdatets::DATE)
   or (pbe.createts > elu.lastupdatets and pbe.effectivedate < coalesce(elu.lastupdatets, '2019-01-01'))) 


  --and pe.emplstatus not in ('T')

  --and pe.EmplClass = 'F'
  --and pe.EmplPermanency = 'P'


--  and current_timestamp between pi.createts and pi.endts
--  and ((pe.effectivedate >= elu.lastupdatets::DATE)
--   or (pe.createts > elu.lastupdatets and pe.effectivedate < elu.lastupdatets)) 
--  and pe.emplstatus in ('A')
--  and pbe.personid not in (select distinct ppbe.personid from person_bene_election ppbe where 
--                           current_timestamp between ppbe.createts and ppbe.endts and 
--                           ppbe.benefitsubclass in ('10','11','14') and
--                           benefitelection = 'E' and selectedoption = 'Y' and 
-- 			   ppbe.effectivedate < pbe.effectivedate) 

  order by 1 , key_rank