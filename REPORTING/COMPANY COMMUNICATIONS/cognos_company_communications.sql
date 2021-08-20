-- View: public.cognos_company_communications

-- DROP VIEW public.cognos_company_communications;

--CREATE OR REPLACE VIEW public.cognos_company_communications AS 
select 
 cc.companycommunicationsid
,cc.companyid
,cc.initiator
,cc.title
,cc.requireagreementacknowledged
,ccr.personid
,ccr.compcommrecipientspid
,ccr.acknowledgerecpt
,ccr.timeviewed
,ccr.effectivedate
,ccr.enddate
,ccr.createts
,ccr.endts
,ccr.agreementacknowledged
,ccr.agreementacknowledgedts

from company_communications_recipients ccr
join company_communications cc 
  on cc.companycommunicationsid = ccr.companycommunicationsid
 and cc.effectivedate < cc.enddate
 and current_timestamp between cc.createts and cc.endts

where current_date between ccr.effectivedate and ccr.enddate
  and current_timestamp between ccr.createts and ccr.endts
;
/*
ALTER TABLE public.cognos_company_communications
  OWNER TO ehcmuser;
GRANT ALL ON TABLE public.cognos_company_communications TO ehcmuser;
GRANT SELECT ON TABLE public.cognos_company_communications TO read_only;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE public.cognos_company_communications TO read_write;
*/

