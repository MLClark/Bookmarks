select 

 pi.personid
,elu.lastupdatets
,lkclient.value1 as client_tasc_id -- 1 Must match value found in Universal Benefit Account
,'' as indv_tasc_id --2 *File must contain Employee ID or Individual TASC ID to identify Participant Must match value found in Universal Benefit Account
,pie.identity as employee_id --3 *If unable to provide the Individual TASC ID then Employee ID is required. Employee ID is required for new enrollees.
,pi.identity as ssn --4 '######### or ###-##-####
,pn.lname as lname --5
,pn.fname as fname --6

,case when pbe.benefitsubclass = lkFSA.value1   then lkFSA.value2
      when pbe.benefitsubclass = lkHSAa.value1  then lkHSAa.value2
      when pbe.benefitsubclass = lkHSA.value1   then lkHSA.value2
      when pbe.benefitsubclass = lkDFSA.value1  then lkdFSA.value2 
      when pbe.benefitsubclass = lkTran.value1  then lkTran.value2 
      when pbe.benefitsubclass = lkTranP.value1 then lkTranP.value2 
      when pbe.benefitsubclass = lkPark.value1  then lkPark.value2 
      when pbe.benefitsubclass = lkParkP.value1 then lkParkP.value2 
      when pbe.benefitsubclass = lkHSAcu.value1 then lkHSAcu.value2
      when pbe.benefitsubclass = lkHRA.value1   then lkHRA.value2
      else ' ' end as benefitplanid --7 Must match value found in Universal Benefit Account

,case when pbe.benefitsubclass = lkFSA.value1   then to_char(pbe.effectivedate,'mm/dd/yyyy')
      when pbe.benefitsubclass = lkHSAa.value1  then to_char(pbe.effectivedate,'mm/dd/yyyy')
      when pbe.benefitsubclass = lkHSA.value1   then to_char(pbe.effectivedate,'mm/dd/yyyy')
      when pbe.benefitsubclass = lkDFSA.value1  then to_char(pbe.effectivedate,'mm/dd/yyyy')
      when pbe.benefitsubclass = lkTran.value1  then to_char(pbe.effectivedate,'mm/dd/yyyy')
      when pbe.benefitsubclass = lkTranP.value1 then to_char(pbe.effectivedate,'mm/dd/yyyy')      
      when pbe.benefitsubclass = lkPark.value1  then to_char(pbe.effectivedate,'mm/dd/yyyy')
      when pbe.benefitsubclass = lkParkP.value1 then to_char(pbe.effectivedate,'mm/dd/yyyy')
      when pbe.benefitsubclass = lkHSAcu.value1 then to_char(pbe.effectivedate,'mm/dd/yyyy')
      when pbe.benefitsubclass = lkHRA.value1   then to_char(pbe.effectivedate,'mm/dd/yyyy')
      else ' ' end as effectivedate --8        

,changes.change_date as election_change_date --9 *Only required if an election amount is changing
,changes.eligibilty_date as eligibility_date --10 *Only required if an election amount is terminating

-----------------------------------------------------------------------------------------
----- Annual Elections - except for Transit and Parking benefits which are Monthly. -----
-----------------------------------------------------------------------------------------      
,case when pbe.benefitsubclass in (parking.benefitsubclass) then changes.current_monthlyamount
      when pbe.benefitsubclass in (flex.benefitsubclass)    then changes.current_coverageamount
      else null  end as individual_election_amount --11 

,null as client_election_amount --12
,null as disbursable_date --13
,null as takeover_override --14
,null as value1

from person_identity pi

join edi.edi_last_update elu on elu.feedid = 'TASC_FSA_Enrollment_File_Export'

left join person_names pn
  on pn.personid = pi.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts 
 
join person_bene_election pbe  
  on pbe.personid = pI.personid
 and pbe.benefitsubclass in 
   ( select lkup.value1 as benefitsubclass 
         from edi.lookup lkup
         join edi.lookup_schema lkups
           on lkups.lookupid = lkup.lookupid
          and current_date between lkups.effectivedate and lkups.enddate
          and current_timestamp between lkups.createts and lkups.endts
          and lkups.lookupname = 'TASC_FSA_Exports' 
   )
 and pbe.selectedoption = 'Y'
 and pbe.benefitelection = 'E'
 and pbe.effectivedate < pbe.enddate 
 and current_timestamp between pbe.createts and pbe.endts
 and case when ?::date is null     then current_date between pbe.effectivedate and pbe.enddate and pbe.effectivedate >= elu.lastupdatets 
          when ?::date is not null then pbe.effectivedate >= ?::date
      end 
 

join person_identity pie
  on pie.personid = pi.personid
 and pie.identitytype = 'EmpNo'
 and current_timestamp between pie.createts and pie.endts

left join ( select lkups.lookupname,lkups.lookupid,lkup.lookupid,lkup.key1,lkup.value1
         from edi.lookup lkup
         join edi.lookup_schema lkups
           on lkups.lookupid = lkup.lookupid
          and current_date between lkups.effectivedate and lkups.enddate
        where current_date between lkup.effectivedate and lkup.enddate
      ) lkclient on lkclient.lookupname = 'TASC_FSA_Exports' and lkclient.key1 = 'ClientTASCID' 

left join ( select lkups.lookupname, lkup.key2,lkup.value1::text as benefitsubclass
         from edi.lookup lkup
         join edi.lookup_schema lkups
           on lkups.lookupid = lkup.lookupid
          and current_date between lkups.effectivedate and lkups.enddate
        where current_date between lkup.effectivedate and lkup.enddate
      ) parking on parking.lookupname = 'TASC_FSA_Exports' and parking.key2 = 'Parking'  and parking.benefitsubclass = pbe.benefitsubclass  

left join ( select lkups.lookupname, lkup.key2,lkup.value1::text as benefitsubclass
         from edi.lookup lkup
         join edi.lookup_schema lkups
           on lkups.lookupid = lkup.lookupid
          and current_date between lkups.effectivedate and lkups.enddate
        where current_date between lkup.effectivedate and lkup.enddate
      ) flex on flex.lookupname = 'TASC_FSA_Exports' and flex.key2 = 'FLEX' and flex.benefitsubclass = pbe.benefitsubclass        

left join ( select lkups.lookupname,lkups.lookupid,lkup.lookupid,lkup.key1,lkup.key2,lkup.value1::text,lkup.value2::text
         from edi.lookup lkup
         join edi.lookup_schema lkups
           on lkups.lookupid = lkup.lookupid
          and current_date between lkups.effectivedate and lkups.enddate
        where current_date between lkup.effectivedate and lkup.enddate
      ) lkFSA on lkFSA.lookupname = 'TASC_FSA_Exports' and lkFSA.value1 = pbe.benefitsubclass --'60'

left join ( select lkups.lookupname,lkups.lookupid,lkup.lookupid,lkup.key1,lkup.key2,lkup.value1::text,lkup.value2::text
         from edi.lookup lkup
         join edi.lookup_schema lkups
           on lkups.lookupid = lkup.lookupid
          and current_date between lkups.effectivedate and lkups.enddate
        where current_date between lkup.effectivedate and lkup.enddate
      ) lkHSAa on lkHSAa.lookupname = 'TASC_FSA_Exports'  and lkHSAa.value1 = pbe.benefitsubclass --'67'    

left join ( select lkups.lookupname,lkups.lookupid,lkup.lookupid,lkup.key1,lkup.key2,lkup.value1::text,lkup.value2::text
         from edi.lookup lkup
         join edi.lookup_schema lkups
           on lkups.lookupid = lkup.lookupid
          and current_date between lkups.effectivedate and lkups.enddate
        where current_date between lkup.effectivedate and lkup.enddate
      ) lkHSA on lkHSA.lookupname = 'TASC_FSA_Exports' and lkHSA.value1 = pbe.benefitsubclass --'6Z'      

left join ( select lkups.lookupname,lkups.lookupid,lkup.lookupid,lkup.key1,lkup.key2,lkup.value1::text,lkup.value2::text
         from edi.lookup lkup
         join edi.lookup_schema lkups
           on lkups.lookupid = lkup.lookupid
          and current_date between lkups.effectivedate and lkups.enddate
        where current_date between lkup.effectivedate and lkup.enddate
      ) lkdFSA on lkdFSA.lookupname = 'TASC_FSA_Exports' and lkdFSA.value1 = pbe.benefitsubclass --'61'  

left join ( select lkups.lookupname,lkups.lookupid,lkup.lookupid,lkup.key1,lkup.key2,lkup.value1::text,lkup.value2::text
         from edi.lookup lkup
         join edi.lookup_schema lkups
           on lkups.lookupid = lkup.lookupid
          and current_date between lkups.effectivedate and lkups.enddate
        where current_date between lkup.effectivedate and lkup.enddate
      ) lkTran on lkTran.lookupname = 'TASC_FSA_Exports' and lkTran.value1 = pbe.benefitsubclass --'6A'  

left join ( select lkups.lookupname,lkups.lookupid,lkup.lookupid,lkup.key1,lkup.key2,lkup.value1::text,lkup.value2::text
         from edi.lookup lkup
         join edi.lookup_schema lkups
           on lkups.lookupid = lkup.lookupid
          and current_date between lkups.effectivedate and lkups.enddate
        where current_date between lkup.effectivedate and lkup.enddate
      ) lkTranP on lkTranP.lookupname = 'TASC_FSA_Exports' and lkTranP.value1 = pbe.benefitsubclass --'6AP'        
      
left join ( select lkups.lookupname,lkups.lookupid,lkup.lookupid,lkup.key1,lkup.key2,lkup.value1::text,lkup.value2::text
         from edi.lookup lkup
         join edi.lookup_schema lkups
           on lkups.lookupid = lkup.lookupid
          and current_date between lkups.effectivedate and lkups.enddate
        where current_date between lkup.effectivedate and lkup.enddate
      ) lkPark on lkPark.lookupname = 'TASC_FSA_Exports' and lkPark.value1 = pbe.benefitsubclass --'6B'             

left join ( select lkups.lookupname,lkups.lookupid,lkup.lookupid,lkup.key1,lkup.key2,lkup.value1::text,lkup.value2::text
         from edi.lookup lkup
         join edi.lookup_schema lkups
           on lkups.lookupid = lkup.lookupid
          and current_date between lkups.effectivedate and lkups.enddate
        where current_date between lkup.effectivedate and lkup.enddate
      ) lkParkP on lkParkP.lookupname = 'TASC_FSA_Exports' and lkParkP.value1 = pbe.benefitsubclass --'6BP' 
      
left join ( select lkups.lookupname,lkups.lookupid,lkup.lookupid,lkup.key1,lkup.key2,lkup.value1::text,lkup.value2::text
         from edi.lookup lkup
         join edi.lookup_schema lkups
           on lkups.lookupid = lkup.lookupid
          and current_date between lkups.effectivedate and lkups.enddate
        where current_date between lkup.effectivedate and lkup.enddate
      ) lkHSAcu on lkHSAcu.lookupname = 'TASC_FSA_Exports' and lkHSAcu.value1 = pbe.benefitsubclass --'6Y' 

left join ( select lkups.lookupname,lkups.lookupid,lkup.lookupid,lkup.key1,lkup.key2,lkup.value1::text,lkup.value2::text
         from edi.lookup lkup
         join edi.lookup_schema lkups
           on lkups.lookupid = lkup.lookupid
          and current_date between lkups.effectivedate and lkups.enddate
        where current_date between lkup.effectivedate and lkup.enddate
      ) lkHRA on lkHRA.lookupname = 'TASC_FSA_Exports' and lkHRA.value1 = pbe.benefitsubclass --'1Y'    

----------------------------------------------------------------------
----- Locate coverage change dates or coverage termination dates -----
----------------------------------------------------------------------     

 
left join 
(
select 
 pbe.personid
,pbe.current_benefitelection
,pbe.prior_benefitelection
,pbe.current_benefitsubclass as benefitsubclass
,pbe.current_effectivedate
,pbe.prior_effectivedate
,pbe.current_enddate
,pbe.prior_enddate
,pbe.current_eventdate
,pbe.prior_eventdate
,pbe.current_deductionstartdate
,pbe.prior_deductionstartdate
,pbe.current_planyearenddate
,pbe.prior_planyearenddate
,pbe.current_monthlyamount
,pbe.current_coverageamount


,case when pbe.current_benefitelection in ('E') and pbe.prior_benefitelection = 'E' then to_char(pbe.current_effectivedate,'mm/dd/yyyy') 
      when pbe.current_benefitelection in ('W','T') and pbe.prior_benefitelection = 'E' then to_char(pbe.prior_enddate,'mm/dd/yyyy') 
      end as change_date
 
,case when pbe.current_benefitelection in ('W','T') and pbe.prior_benefitelection = 'E' then to_char(pbe.current_effectivedate,'mm/dd/yyyy') 
      end as eligibilty_date
from 
(
select 
 c.personid
,c.benefitsubclass as current_benefitsubclass
,c.benefitelection as current_benefitelection
,c.coverageamount as current_coverageamount
,c.effectivedate as current_effectivedate
,c.enddate as current_enddate
,c.eventdate as current_eventdate 
,c.deductionstartdate as current_deductionstartdate
,c.planyearenddate as current_planyearenddate
,c.monthlyamount as current_monthlyamount


,p.benefitsubclass as prior_benefitsubclass
,p.benefitelection as prior_benefitelection
,p.coverageamount as prior_coverageamount
,p.effectivedate as prior_effectivedate
,p.enddate as prior_enddate
,p.eventdate as prior_eventdate
,p.deductionstartdate as prior_deductionstartdate
,p.planyearenddate as prior_planyearenddate
,p.monthlyamount as prior_monthlyamount


from 
(select personid, benefitsubclass, benefitelection,  personbeneelectionpid, coverageamount, effectivedate, enddate, eventdate, deductionstartdate, planyearenddate, monthlyamount
  from person_bene_election
  join edi.edi_last_update elu on elu.feedid = 'TASC_FSA_Enrollment_File_Export'
 where benefitsubclass in  
   ( select lkup.value1 as benefitsubclass 
         from edi.lookup lkup
         join edi.lookup_schema lkups
           on lkups.lookupid = lkup.lookupid
          and current_date between lkups.effectivedate and lkups.enddate
          and current_timestamp between lkups.createts and lkups.endts
          and lkups.lookupname = 'TASC_FSA_Exports' 
          and lkup.key1 ilike ('%FSA%')
   )  
   and benefitelection in ('E','T') and selectedoption = 'Y' 
   and current_timestamp between createts and endts and 
   case when ?::date is null then current_date between effectivedate and enddate and effectivedate >= elu.lastupdatets 
        when ?::date  is not null then effectivedate >= ?::date 
   end 
   ) c
left join 
(select personid, benefitsubclass, benefitelection,  personbeneelectionpid, coverageamount, effectivedate, enddate, eventdate, deductionstartdate, planyearenddate
,monthlyamount
  from person_bene_election
 where benefitsubclass in      
   ( select lkup.value1 as benefitsubclass 
         from edi.lookup lkup
         join edi.lookup_schema lkups
           on lkups.lookupid = lkup.lookupid
          and current_date between lkups.effectivedate and lkups.enddate
          and current_timestamp between lkups.createts and lkups.endts
          and lkups.lookupname = 'TASC_FSA_Exports' 
   )
   and benefitelection in ('E','T') and selectedoption = 'Y' 
   and current_timestamp between createts and endts and effectivedate < enddate and enddate < '2199-12-30'
   and date_part('year',deductionstartdate) >= date_part('year',current_date)
   ) p on p.personid = c.personid

) pbe ) changes on changes.personid = pbe.personid and changes.benefitsubclass = pbe.benefitsubclass 

where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts