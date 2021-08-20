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

,p.benefitsubclass as prior_benefitsubclass
,p.benefitelection as prior_benefitelection
,p.coverageamount as prior_coverageamount
,p.effectivedate as prior_effectivedate
,p.enddate as prior_enddate
,p.eventdate as prior_eventdate
,p.deductionstartdate as prior_deductionstartdate
,p.planyearenddate as prior_planyearenddate


from 
(select personid, benefitsubclass, benefitelection,  personbeneelectionpid, coverageamount, effectivedate, enddate, eventdate, deductionstartdate, planyearenddate
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
   )  
   and benefitelection in ('E','T') and selectedoption = 'Y' 
   and current_timestamp between createts and endts 
   and current_date between effectivedate and enddate
   and effectivedate >= elu.lastupdatets 
   ) c
left join 
(select personid, benefitsubclass, benefitelection,  personbeneelectionpid, coverageamount, effectivedate, enddate, eventdate, deductionstartdate, planyearenddate
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

) pbe)