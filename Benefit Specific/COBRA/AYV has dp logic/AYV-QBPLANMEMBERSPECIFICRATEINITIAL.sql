SELECT distinct  
--- this is only required for FSA plans
 pi.personid
,pn.name
,pbe.benefitsubclass
,pbe.benefitplanid
,bpd.benefitplandesc

/*
Flex - Limited Scope - ProBenefits      Flexible Spending Account ProBenefits 60,341
Flex - ProBenefits 208833786            Flexible Spending Account ProBenefits 60,83
*/
,'[QBPLANMEMBERSPECIFICRATEINITIAL]' :: varchar(35) as recordtype
,case when pbe.benefitsubclass = '60' and pbe.benefitplanid = '341' then 'Flex - Limited Scope - ProBenefits'
      when pbe.benefitsubclass = '60' and pbe.benefitplanid = '83'  then 'Flex - ProBenefits' end  ::varchar(150) as plan_name  
,pbe.coverageamount        
,'5A' ::char(10) as sort_seq

from person_identity pi

left join edi.edi_last_update elu ON elu.feedid = 'AYV_SHDR_COBRA_QB_Export'

join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts
 
join person_names pn
  on pn.personid = pe.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts 

join person_benefit_action pba
  on pba.personid = pe.personid
 and pba.eventname in ('TER')  
 and pba.eventeffectivedate >= elu.lastupdatets

join person_bene_election pbe 
  on pbe.personid = pi.personid 
 and pbe.selectedoption = 'Y' 
 and pbe.benefitsubclass in ('60') 
 and pbe.effectivedate < pbe.enddate 
 and pbe.personbenefitactionpid = pba.personbenefitactionpid
 and current_timestamp between pbe.createts AND pbe.endts
  -- to be qualified for cobra the emp must have participated in employer's health care plan  
 and pbe.personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts and date_part('year',deductionstartdate)>=date_part('year',current_date)
                         and benefitsubclass in ('60') and benefitelection = 'E' and selectedoption = 'Y' and effectivedate < enddate) 
                          

left join benefit_plan_desc bpd  
  on bpd.benefitsubclass = pbe.benefitsubclass
 and bpd.benefitplanid = pbe.benefitplanid
 and current_date between bpd.effectivedate and bpd.enddate
 and current_timestamp between bpd.createts and bpd.endts

where pi.identitytype = 'SSN' 
  and current_timestamp between pi.createts and pi.endts 
  and (pe.effectivedate >= elu.lastupdatets::DATE 
   or (pe.createts > elu.lastupdatets and pe.effectivedate < coalesce(elu.lastupdatets, '2017-01-01')) )
  and pe.emplstatus in ('R','T')
 

order by personid