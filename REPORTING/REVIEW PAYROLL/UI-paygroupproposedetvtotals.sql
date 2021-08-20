-- EHCM-22367

--drop view if exists payroll.paygroupproposedetvtotals;
--create or replace view payroll.paygroupproposedetvtotals as
select 
   sum(x.grosswagesytd) as grosswagesytd,
   x.pspaypayrollid, 
   
   x.personid as employer_id,
   x.payscheduleperiodid,
   x.payunitid,
   x.etorv,
   x.etv_code,
   string_agg(distinct x.paycode, ',') as etvids,
   x.paycode as etvid,
   max(x.etvname)::text as etvname,
   x.psdcode,
   x.stateprovincecode,
   x.ttype_tax_code,
   x.taxcodeoretvid,
   x.taxid,
   x.taxrate,
   x.stateordering,
   x.stateprovincename,
   x.emplcategory,
   count(distinct x.personid) as numemployees,
   sum(x.grosssum) as grosswages,
   sum(x.grosswagesq1td) as grosswagesq1td,
   sum(x.grosswagesq2td) as grosswagesq2td,
   sum(x.grosswagesq3td) as grosswagesq3td,
   sum(x.grosswagesq4td) as grosswagesq4td,
   z.totalamount as totalamount,
   sum(x.totalamountytd) as totalamountytd,
   sum(x.totalamountq1td) as totalamountq1td,
   sum(x.totalamountq2td) as totalamountq2td,
   sum(x.totalamountq3td) as totalamountq3td,
   sum(x.totalamountq4td) as totalamountq4td,
   z.totaltaxablewage as totaltaxablewage,
   sum(x.totaltaxablewageytd) as totaltaxablewageytd,
   sum(x.totaltaxablewageq1td) as totaltaxablewageq1td,
   sum(x.totaltaxablewageq2td) as totaltaxablewageq2td,
   sum(x.totaltaxablewageq3td) as totaltaxablewageq3td,
   sum(x.totaltaxablewageq4td) as totaltaxablewageq4td,
   z.totalhours as totalhours,
   sum(x.totalhoursytd) as totalhoursytd,
   sum(x.totalhoursq1td) as totalhoursq1td,
   sum(x.totalhoursq2td) as totalhoursq2td,
   sum(x.totalhoursq3td) as totalhoursq3td,
   sum(x.totalhoursq4td) as totalhoursq4td,
   array_agg(distinct x.personid)::text as persons,
   x.privateplan
from ( 
	select distinct
      pp.pspaypayrollid, 
      psp.payscheduleperiodid,
      psp.payunitid,
      pu.employertaxid,
      (case when pc.paycodetypeid in (1,2,7) then 'E'
           when pc.paycodetypeid in (4,8) then 'T'
           when pc.paycodetypeid in (3,6) then  'V'
           else ''
      end)::text as etorv,
      st.paycode,
      case when pc.paycodetypeid in (1,2,3,4,7) then 'EE'
           when pc.paycodetypeid in (6,8) then 'ER'
           else null
      end as etv_code,
      coalesce(t.taxiddesc, pc.paycodeshortdesc, ('___'::text)) || (case when coalesce(cts.privateplan, 'N') = 'Y' then ' - Private Plan' else '' end) as etvname,
      t.psdcode,
      ppp.personid,
      grs.grosssum,
      btrim((sp.stateprovincecode)::text) AS stateprovincecode,
      tla.ttype_tax_code,
      coalesce(tla.ttype_tax_code, case when pc.paycodesourceid in (10,15)
                                        then ''
                                        else st.paycode
                                   end) as taxcodeoretvid,
      coalesce(trim(cts.businessid), btrim((pucsui.identification)::text)) as taxid,
      case when coalesce(t.taxtype, '') = 'E' then coalesce(cts.taxrate::numeric(6, 4), pucsui.rate)
           else coalesce(cts.employeerate::numeric(6,4), cts.taxrate::numeric(6, 4), pucsui.rate)
      end as taxrate,
      case when (btrim(sp.stateprovincecode::text) = 'FED' OR (sp.stateprovincecode is null)) then ('00-'::text || (t.taxiddesc)::text)
           else btrim(sp.stateprovincecode::text)
      end as stateordering,
      sp.stateprovincename,
      case when t.taxiddesc is not null then ecti.emplcategory
           else null::bpchar
      end as emplcategory,
      coalesce(ppym.gross_wages_ytd, 0) + grs.grosssum as grosswagesytd,
      case when extract(quarter from ppp.asofdate) >= 1 then coalesce(ppym.gross_wages_q1td, 0) + grs.grosssum else 0 end as grosswagesq1td,
      case when extract(quarter from ppp.asofdate) >= 2 then coalesce(ppym.gross_wages_q2td, 0) + grs.grosssum else 0 end as grosswagesq2td,
      case when extract(quarter from ppp.asofdate) >= 3 then coalesce(ppym.gross_wages_q3td, 0) + grs.grosssum else 0 end as grosswagesq3td,
      case when extract(quarter from ppp.asofdate) >= 4 then coalesce(ppym.gross_wages_q4td, 0) + grs.grosssum else 0 end as grosswagesq4td,
      coalesce(st.amount, 0) AS totalamount,
      coalesce(st.amount_ytd, 0) AS totalamountytd,
      coalesce(st.amount_q1td, 0) as totalamountq1td,
      coalesce(st.amount_q2td, 0) as totalamountq2td,
      coalesce(st.amount_q3td, 0) as totalamountq3td,
      coalesce(st.amount_q4td, 0) as totalamountq4td,
      coalesce(st.subject_wages, 0) AS totaltaxablewage,
      coalesce(st.subject_wages_ytd, 0) AS totaltaxablewageytd,
      coalesce(st.subject_wages_q1td, 0) AS totaltaxablewageq1td,
      coalesce(st.subject_wages_q2td, 0) AS totaltaxablewageq2td,
      coalesce(st.subject_wages_q3td, 0) AS totaltaxablewageq3td,
      coalesce(st.subject_wages_q4td, 0) AS totaltaxablewageq4td,
      coalesce(st.units, 0) AS totalhours,
      coalesce(st.units_ytd, 0) AS totalhoursytd,
      coalesce(st.units_q1td, 0) as totalhoursq1td,
      coalesce(st.units_q2td, 0) as totalhoursq2td,
      coalesce(st.units_q3td, 0) as totalhoursq3td,
      coalesce(st.units_q4td, 0) as totalhoursq4td,
      cts.privateplan
	from pspay_payroll pp
	join pspay_payroll_pay_sch_periods ppsp on pp.pspaypayrollid = ppsp.pspaypayrollid
	join pay_schedule_period psp on psp.payscheduleperiodid = ppsp.payscheduleperiodid
	join runpayrollgetdates rpgd on rpgd.payscheduleperiodid = psp.payscheduleperiodid
   join payroll.personperiodpayments ppp on ppp.payscheduleperiodid = psp.payscheduleperiodid
   join (select s.payscheduleperiodid
				 ,s.personid
		         ,s.employer_id
		         ,pt.processingorder
		         ,ph.paymenttype
		         ,ph.paycode
		         ,case when row_number() over (partition by s.personid, s.employer_id, ph.paycode order by ph.accepted_ts desc, pt.processingorder desc) = 1 then ph.paymentseq else null end as paymentseq
		   from payroll.person_payperiod_snapshot s
		   join (
		   select ps.payscheduleperiodid, pp.statusdate as accepted_ts, st.paymenttype, st.paycode, st.personid, st.paymentseq, pp.pspaypayrollstatusid 
		   from pspay_payroll_pay_sch_periods ps
		   join payroll.staged_transaction st on st.payscheduleperiodid = ps.payscheduleperiodid 
		   JOIN pspay_payroll pp ON pp.pspaypayrollid = ps.pspaypayrollid and pp.pspaypayrollstatusid = 3
		   ) 
		   ph on s.payscheduleperiodid = ph.payscheduleperiodid and s.personid = ph.personid
		   join payroll.payment_types pt 
		      on pt.paymenttype = ph.paymenttype) stx 
		      	on stx.payscheduleperiodid = ppp.payscheduleperiodid and stx.personid = ppp.personid and stx.paymenttype = ppp.paymenttype
		      
   join payroll.staged_transaction st on st.payscheduleperiodid = stx.payscheduleperiodid and st.personid = stx.personid and st.paymenttype = stx.paymenttype and st.paymentseq = stx.paymentseq
   join (  select pp.personid, pp.payscheduleperiodid, sum(pp.gross_amount) as grosssum
         from payroll.personperiodpayments pp
         group by pp.payscheduleperiodid, pp.personid ) grs on grs.payscheduleperiodid = ppp.payscheduleperiodid and grs.personid = ppp.personid
   join person_employment pe on pe.personid = ppp.personid
                                and rpgd.asofdate between pe.effectivedate and pe.enddate 
                                and current_timestamp between pe.createts and pe.endts
	join person_identity pi on pi.personid = ppp.personid
                              and current_timestamp between pi.createts and pi.endts 
                              and identitytype = 'PSPID'
	join person_payroll ppay on ppay.personid = ppp.personid
                               and rpgd.asofdate between ppay.effectivedate and ppay.enddate
                               and current_timestamp between ppay.createts and ppay.endts
                                    
	join pay_unit pu on pu.payunitid = psp.payunitid and current_timestamp between pu.createts and pu.endts
   join payroll.pay_codes pc on pc.paycode = st.paycode
                                and pc.uidisplay = 'Y'
                                and rpgd.asofdate between pc.effectivedate and pc.enddate
                                and current_timestamp between pc.createts and pc.endts
	left join tax t on t.taxid = st.taxid
	left join person_tax_elections_aggregators_asof tla on tla.personid = ppp.personid 
                                                          and tla.asofdate = ppp.asofdate
                                                          and tla.taxid = st.taxid
                                                          and tla.etvid_lookups @> array[st.paycode]
	left join tax_entity te on t.taxentity = te.taxentity
	left join state_province sp on btrim(sp.taxstatecode::text) = btrim(te.taxstatecode::text)
	left join pay_unit_configuration pucsui on pucsui.payunitid = psp.payunitid
                                              and rpgd.asofdate between pucsui.effectivedate and pucsui.enddate
                                              and current_timestamp between pucsui.createts and pucsui.endts
                                              and btrim(pucsui.stateprovincecode::text) = btrim(sp.stateprovincecode::text)
                                              and pucsui.payunitconfigurationtypeid = (select pay_unit_configuration_type.payunitconfigurationtypeid
                                                                                       from pay_unit_configuration_type
                                                                                       where pay_unit_configuration_type.payunitconfigurationtypename = 'SUI')
                                              and tla.ttype_tax_code ~~ '%AZ%'
	left join emplcategorytaxinfo ecti on ecti.emplcategory = pe.emplcategory
	left join tax_related_plan trp on (trp.taxidee = t.taxid or trp.taxider = t.taxid)
                                     and rpgd.asofdate between trp.effectivedate and trp.enddate
                                     and current_timestamp between trp.createts and trp.endts
	left join company_tax_setup cts on pu.employertaxid::varchar = any(cts.feinlist)
                                      and current_timestamp between pu.createts and pu.endts
                                      and current_timestamp between cts.createts and cts.endts
                                      and rpgd.asofdate between cts.effectivedate and cts.enddate
                                      and (cts.taxid = tla.taxid or cts.taxid = trp.taxider)
                                      and cts.privateplan = 'Y' 
    left join payroll.person_paycode_yeartodate_mv ppym on ppym.employer_id = pu.employertaxid and ppym.personid = ppp.personid and ppym.paycode = st.paycode and ppym.payyear = extract('year' from rpgd.asofdate)                     
                                      ) x
join (
	select y.pspaypayrollid, 
         y.payunitid,
         y.etorv,
         y.etv_code,
         y.paycode,
         y.etvname,
         y.psdcode,
         y.payscheduleperiodid,
         y.stateprovincecode,
         y.employertaxid,
         y.ttype_tax_code,
         y.taxcodeoretvid,
         y.taxid,
         y.taxrate,
         y.stateordering,
         y.stateprovincename,
         y.emplcategory,
         y.privateplan,
         sum(y.totalamount) as totalamount,
         sum(y.totalhours) as totalhours,
         sum(y.totaltaxablewage) as totaltaxablewage
from (
	select distinct
      pp.pspaypayrollid, 
      psp.payscheduleperiodid,
      psp.payunitid,
      pu.employertaxid,
      (case when pc.paycodetypeid in (1,2,7) then 'E'
           when pc.paycodetypeid in (4,8) then 'T'
           when pc.paycodetypeid in (3,6) then  'V'
           else ''
      end)::text as etorv,
      st.paycode,
      case when pc.paycodetypeid in (1,2,3,4,7) then 'EE'
           when pc.paycodetypeid in (6,8) then 'ER'
           else null
      end as etv_code,
      coalesce(t.taxiddesc, pc.paycodeshortdesc, ('___'::text)) || (case when coalesce(cts.privateplan, 'N') = 'Y' then ' - Private Plan' else '' end) as etvname,
      t.psdcode,
      ppp.personid,
      btrim((sp.stateprovincecode)::text) AS stateprovincecode,
      tla.ttype_tax_code,
      coalesce(tla.ttype_tax_code, case when pc.paycodesourceid in (10,15)
                                        then ''
                                        else st.paycode
                                   end) as taxcodeoretvid,
      coalesce(trim(cts.businessid), btrim((pucsui.identification)::text)) as taxid,
      case when coalesce(t.taxtype, '') = 'E' then coalesce(cts.taxrate::numeric(6, 4), pucsui.rate)
           else coalesce(cts.employeerate::numeric(6,4), cts.taxrate::numeric(6, 4), pucsui.rate)
      end as taxrate,
      case when (btrim(sp.stateprovincecode::text) = 'FED' OR (sp.stateprovincecode is null)) then ('00-'::text || (t.taxiddesc)::text)
           else btrim(sp.stateprovincecode::text)
      end as stateordering,
      sp.stateprovincename,
      case when t.taxiddesc is not null then ecti.emplcategory
           else null::bpchar
      end as emplcategory,
      coalesce(st.amount, 0) AS totalamount,
      coalesce(st.subject_wages, 0) AS totaltaxablewage,
      coalesce(st.units, 0) AS totalhours,
      cts.privateplan
	from pspay_payroll pp
	join pspay_payroll_pay_sch_periods ppsp on pp.pspaypayrollid = ppsp.pspaypayrollid
	join pay_schedule_period psp on psp.payscheduleperiodid = ppsp.payscheduleperiodid
	join runpayrollgetdates rpgd on rpgd.payscheduleperiodid = psp.payscheduleperiodid
   join payroll.personperiodpayments ppp on ppp.payscheduleperiodid = ppsp.payscheduleperiodid
   join payroll.staged_transaction st on st.payscheduleperiodid = ppp.payscheduleperiodid and st.personid = ppp.personid and st.paymenttype = ppp.paymenttype
   join person_employment pe on pe.personid = ppp.personid
                                and rpgd.asofdate between pe.effectivedate and pe.enddate 
                                and current_timestamp between pe.createts and pe.endts
	join person_identity pi on pi.personid = ppp.personid
                              and current_timestamp between pi.createts and pi.endts 
                              and identitytype = 'PSPID'
	join person_payroll ppay on ppay.personid = ppp.personid
                               and rpgd.asofdate between ppay.effectivedate and ppay.enddate
                               and current_timestamp between ppay.createts and ppay.endts                                 
   join pay_unit pu on pu.payunitid = psp.payunitid and current_timestamp between pu.createts and pu.endts
   join payroll.pay_codes pc on pc.paycode = st.paycode
                                and pc.uidisplay = 'Y'
                                and rpgd.asofdate between pc.effectivedate and pc.enddate
                                and current_timestamp between pc.createts and pc.endts
	left join tax t on t.taxid = st.taxid
	left join person_tax_elections_aggregators_asof tla on tla.personid = ppp.personid 
                                                          and tla.asofdate = ppp.asofdate
                                                          and tla.taxid = st.taxid
                                                          and tla.etvid_lookups @> array[st.paycode]
	left join tax_entity te on t.taxentity = te.taxentity
	left join state_province sp on btrim(sp.taxstatecode::text) = btrim(te.taxstatecode::text)
	left join pay_unit_configuration pucsui on pucsui.payunitid = psp.payunitid
                                              and rpgd.asofdate between pucsui.effectivedate and pucsui.enddate
                                              and current_timestamp between pucsui.createts and pucsui.endts
                                              and btrim(pucsui.stateprovincecode::text) = btrim(sp.stateprovincecode::text)
                                              and pucsui.payunitconfigurationtypeid = (select pay_unit_configuration_type.payunitconfigurationtypeid
                                                                                       from pay_unit_configuration_type
                                                                                       where pay_unit_configuration_type.payunitconfigurationtypename = 'SUI')
                                              and tla.ttype_tax_code ~~ '%AZ%'
	left join emplcategorytaxinfo ecti on ecti.emplcategory = pe.emplcategory
	left join tax_related_plan trp on (trp.taxidee = t.taxid or trp.taxider = t.taxid)
                                     and rpgd.asofdate between trp.effectivedate and trp.enddate
                                     and current_timestamp between trp.createts and trp.endts
	left join company_tax_setup cts on pu.employertaxid::varchar = any(cts.feinlist)
                                      and current_timestamp between pu.createts and pu.endts
                                      and current_timestamp between cts.createts and cts.endts
                                      and rpgd.asofdate between cts.effectivedate and cts.enddate
                                      and (cts.taxid = tla.taxid or cts.taxid = trp.taxider)
                                      and cts.privateplan = 'Y'
                                      ) y
                                
group by y.pspaypayrollid, 
         y.payunitid,
         y.etorv,
         y.etv_code,
         y.paycode,
         y.etvname,
         y.psdcode,
         y.payscheduleperiodid,
         y.stateprovincecode,
         y.employertaxid,
         y.ttype_tax_code,
         y.taxcodeoretvid,
         y.taxid,
         y.taxrate,
         y.stateordering,
         y.stateprovincename,
         y.emplcategory,
         y.privateplan
                                      ) z on z.pspaypayrollid = x.pspaypayrollid 
                                      	  and z.payscheduleperiodid = x.payscheduleperiodid 
                                          and z.paycode = x.paycode
                                          and x.employertaxid = z.employertaxid
                                          and (z.stateprovincecode = x.stateprovincecode or z.stateprovincecode is null) 
                                          and x.etv_code = z.etv_code
where (z.totalamount <> 0 or x.totalamountytd <> 0 or z.totalhours <> 0 or x.totalhoursytd <> 0) and x.personid = '1075'
group by x.pspaypayrollid, 
         x.personid,
         x.payunitid,
         x.etorv,
         x.etv_code,
         x.paycode,
         x.etvname,
         x.psdcode,
         x.payscheduleperiodid,
         x.stateprovincecode,
         x.employertaxid,
         x.ttype_tax_code,
         x.taxcodeoretvid,
         x.taxid,
         x.taxrate,
         x.stateordering,
         x.stateprovincename,
         x.emplcategory,
         x.privateplan,
         z.totalamount,
         z.totalhours,
         z.totaltaxablewage;