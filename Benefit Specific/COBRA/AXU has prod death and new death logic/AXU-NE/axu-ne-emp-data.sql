select distinct

 pi.personid
,pbe.effectivedate
,'11 ACTIVE EE EMP' ::varchar(30) as qsource
,'0' as dependentid
,'2' ::char(10) as sort_seq
,'EMP' ::char(3) as recordtype
,'4A1032' ::char(15) as company_no
,pie.identity ::char(20) as empnbr
,left(pi.identity,3)||'-'||substring(pi.identity,4,2)||'-'||right(pi.identity,4) ::char(12) as ssn
,to_char(pv.birthdate,'yyyy-mm-dd')::char(10) as dob
,pn.fname ::char(25) as fname
,pn.lname ::char(35) as lname
,pn.mname ::char(1) as mname
,'English' ::char(25) as language_code


from person_identity pi

left join edi.edi_last_update elu on elu.feedid = 'AXU_Infinisource_Cobra_NE_Export'

join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts

join (select effcovdate.personid,effcovdate.benefitsubclass,effcovdate.min_effectivedate
        from (select pbe.personid,pbe.benefitsubclass,min(pbe.effectivedate) as min_effectivedate,max(pbe.effectivedate) as max_effectivedate
                from person_bene_election pbe
               where pbe.benefitsubclass in ('10','11','14','60')
                 and pbe.selectedoption = 'Y' and pbe.benefitelection = 'E' group by 1,2) effcovdate
       left join edi.edi_last_update elu on elu.feedid = 'AXU_Infinisource_Cobra_NE_Export'
      where effcovdate.min_effectivedate = effcovdate.max_effectivedate
        and effcovdate.min_effectivedate >= elu.lastupdatets) pbene on pbene.personid = pe.personid

JOIN person_bene_election pbe 
  on pbe.personid = pbene.personid 
 and pbe.selectedoption = 'Y' 
 and pbe.benefitelection = 'E'
 and pbe.benefitsubclass in ('10','11','14','60')
 and current_date between pbe.effectivedate and pbe.enddate 
 AND current_timestamp between pbe.createts AND pbe.endts
 and pbe.effectivedate >= elu.lastupdatets::DATE 

join person_identity pie
  on pie.personid = pi.personid
 and pie.identitytype = 'EmpNo'
 and current_timestamp between pie.createts and pie.endts
 
left join person_vitals pv
  on pv.personid = pi.personid
 and current_date between pv.effectivedate and pv.enddate
 and current_timestamp between pv.createts and pv.endts 

left join person_names pn
  on pn.personid = pi.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts 

where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts 
  and pe.emplstatus = 'A'
  order by empnbr