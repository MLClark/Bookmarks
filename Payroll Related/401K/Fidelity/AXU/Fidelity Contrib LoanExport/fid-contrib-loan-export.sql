
select  pe.personid,

	(left(trim(pip.identity), 3) || '-' || substr(trim(pip.identity),4,2) || '-' || right(trim(pip.identity),4))::char(11) as socialsecurity,

-- Parameters
	lookup.plan,

-- Record values
	c_rth.contribution_roth * 100 as contribution_roth,
	c_ee.contribution_employee * 100 as contribution_employee,
	c_er.contribution_employer * 100 as contribution_employer,
	c_aftax.contribution_aftertax	* 100 as contribution_aftertax, ----- AFTER TAX
	(loan.loan_amount * 100)::integer as loan_amount,
	(loan.loan_amount * 100)::integer as int_loan_amount,
	coalesce(pds.referencenumber, ' ')::varchar(20) as referencenumber,

-- Record amounts for comparison
	coalesce((c_rth.contribution_roth * 100), 0)::integer as orig_contribution_roth,
	coalesce((c_ee.contribution_employee * 100), 0)::integer as orig_contribution_employee,
	coalesce((c_er.contribution_employer * 100), 0)::integer as orig_contribution_employer,
	coalesce((c_aftax.contribution_aftertax	 * 100), 0)::integer as orig_contribution_aftertax,  ----- AFTER TAX
	coalesce((loan.loan_amount * 100), 0)::integer as orig_loan_amount,

-- Concatenate fields needed separate fields to pad with spaces
	' '::char(1) as blank1,
	' '::char(1) as blank2,
	' '::char(1) as blank3,
	' '::char(1) as blank4,
-- Fidelity Code Values
	employee.EEcode,
	employer.ERcode,
	roth.Rcode,
	aftertax.ATcode,
-- lookup constant
	1 as constant,

-- ATQ requires a "C" in column 67 on record 19
	case when (c_rth.contribution_roth * 100) < 0 then 'C'
	else ' '
	end::char(1) as Roth_Neg,

-- ATQ requires a "C" in column 67 on record 19
	case when (c_ee.contribution_employee * 100) < 0 then 'C'
	else ' '
	end::char(1) as Employee_Neg,

-- ATQ requires a "C" in column 67 on record 19
	case when (c_er.contribution_employer * 100) < 0 then 'C'
	else ' '
	end::char(1) as Employer_Neg,

-- ATQ requires a "C" in column 67 on record 19
	case when (c_aftax.contribution_aftertax * 100) < 0 then 'C'
	else ' '
	end::char(1) as Aftertax_Neg	


from
	person_employment pe

	left join person_identity pip
		on pip.personid = pe.personid
		and pip.identitytype = 'SSN'
		and current_timestamp between pip.createts and pip.endts 

	left join person_identity pi1
		on pi1.personid = pe.personid
		and pi1.identitytype = 'PSPID'
		and current_timestamp between pi1.createts and pi1.endts 

-- loan 1  V65

	left join (

		select distinct  individual_key, sum(etv_amount) as loan_amount
  
  from pspay_payment_detail ppd
  
  where paymentheaderid in 
          (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                  (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                          (select pspaypayrollid from pspay_payroll ppay join edi.edi_last_update elu 
                               on elu.feedid = 'Fidelity_ContributionLoan' and elu.lastupdatets <= ppay.statusdate
--                               on elu.feedid = 'Fidelity_ContributionLoan' and '2019-09-15'::DATE <= ppay.statusdate
                               where ppay.pspaypayrollstatusid = 4 )))
    and ppd.etv_id  in  (
				select	distinct unnest(array[value1,value2,value3,value4,value5,value6,value7,value8,value9,value10])
				from	edi.lookup_schema ls
				join	edi.lookup lkup on lkup.lookupid = ls.lookupid
					and lkup.active = 1
					and current_date between lkup.effectivedate and lkup.enddate
				where	ls.lookupname = 'FidelityLoanETVIdMap'
					and current_date between ls.effectivedate and ls.enddate
					and ls.active = 1
					and value1 is not null)
						group by ppd.individual_key
						order by ppd.individual_key
							) loan on loan.individual_key = pi1.identity

	left join (
		select	personid,referencenumber
		from	person_deduction_setup
		where	etvid in (
				select	distinct unnest(array[value1,value2,value3,value4,value5,value6,value7,value8,value9,value10])
				from	edi.lookup_schema ls
				join	edi.lookup lkup on lkup.lookupid = ls.lookupid
					and lkup.active = 1
					and current_date between lkup.effectivedate and lkup.enddate
				where	ls.lookupname = 'FidelityLoanETVIdMap'
					and current_date between ls.effectivedate and ls.enddate
					and ls.active = 1
					and value1 is not null)
				and current_date between effectivedate and enddate
				and current_timestamp between createts and endts
			) pds on pds.personid = pe.personid

-- employee contribution to 401K         contribution_employee          ('VB1', 'VB2')
	left join (

		select distinct
  individual_key, sum(etv_amount) as contribution_employee
  
  from pspay_payment_detail ppd
  
  where paymentheaderid in 
          (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                  (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                          (select pspaypayrollid from pspay_payroll ppay join edi.edi_last_update elu 
--                               on elu.feedid = 'Fidelity_ContributionLoan' and '2019-09-15'::DATE <= ppay.statusdate
                               on elu.feedid = 'Fidelity_ContributionLoan' and elu.lastupdatets <= ppay.statusdate
                               where ppay.pspaypayrollstatusid = 4 )))
    and ppd.etv_id  in  ('VB1', 'VB2')
		group by ppd.individual_key
		order by ppd.individual_key

) c_ee on c_ee.individual_key = pi1.identity


-- employer contribution to Roth	contribution_roth	('VB3', 'VB4')  V25?
left join (select distinct  individual_key, sum(etv_amount) as contribution_roth
  
  from pspay_payment_detail ppd
  
  where paymentheaderid in 
          (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                  (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                          (select pspaypayrollid from pspay_payroll ppay join edi.edi_last_update elu 
--                                 on elu.feedid = 'Fidelity_ContributionLoan' and '2019-09-15'::DATE <= ppay.statusdate
                             on elu.feedid = 'Fidelity_ContributionLoan' and elu.lastupdatets <= ppay.statusdate
                               where ppay.pspaypayrollstatusid = 4 )))
    and ppd.etv_id  in  ('VB3', 'VB4') -- Do we need to add V25?
		group by ppd.individual_key
		order by ppd.individual_key

			) c_rth on c_rth.individual_key = pi1.identity
		
		
-- employer contribution to 401K	contribution_employer	= 'VB5'
	left join (
		select distinct
  individual_key, sum(etv_amount) as contribution_employer
  
  from pspay_payment_detail ppd
  
  where paymentheaderid in 
          (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                  (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                          (select pspaypayrollid from pspay_payroll ppay join edi.edi_last_update elu 
--                                 on elu.feedid = 'Fidelity_ContributionLoan' and '2019-09-15'::DATE <= ppay.statusdate
                             on elu.feedid = 'Fidelity_ContributionLoan' and elu.lastupdatets <= ppay.statusdate
                               where ppay.pspaypayrollstatusid = 4 )))
    and ppd.etv_id  = 'VB5'
		group by ppd.individual_key
		order by ppd.individual_key
			) c_er on c_er.individual_key = pi1.identity

----------------------------------			
----- AFTER TAX V25 FOR AXU ------
----------------------------------			
left join (select distinct  individual_key, sum(etv_amount) as contribution_aftertax
  
  from pspay_payment_detail ppd
  
  where paymentheaderid in 
          (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                  (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                          (select pspaypayrollid from pspay_payroll ppay join edi.edi_last_update elu 
                             on elu.feedid = 'Fidelity_ContributionLoan' and elu.lastupdatets <= ppay.statusdate
                               where ppay.pspaypayrollstatusid = 4 )))
    and ppd.etv_id  in  ('V25')  
		group by ppd.individual_key
		order by ppd.individual_key

			) c_aftax on c_aftax.individual_key = pi1.identity	
			
-- get plan number
	left join (
			select	lkup.value1 as plan
			from	edi.lookup_schema ls
			join	edi.lookup lkup on lkup.lookupid = ls.lookupid
				and lkup.active = 1
				and current_date between lkup.effectivedate and lkup.enddate
			where	ls.lookupname = 'FidelityPlanNumber'
				and current_date between ls.effectivedate and ls.enddate
				and ls.active = 1) lookup on lookup.plan is not null

-- Employee Contribution Value
	left join (
			select	lkup.value1 as EECode
			from	edi.lookup_schema ls
			join	edi.lookup lkup on lkup.lookupid = ls.lookupid
				and lkup.active = 1
				and current_date between lkup.effectivedate and lkup.enddate
			where	ls.lookupname = 'FidelityContributionLoan'
				and lkup.key1 = 'Employee'
				and current_date between ls.effectivedate and ls.enddate
				and ls.active = 1) employee on employee.EEcode is not null

-- Employer Contribution Value
	left join (
			select	lkup.value1 as ERCode
			from	edi.lookup_schema ls
			join	edi.lookup lkup on lkup.lookupid = ls.lookupid
				and lkup.active = 1
				and current_date between lkup.effectivedate and lkup.enddate
			where	ls.lookupname = 'FidelityContributionLoan'
				and lkup.key1 = 'Employer'
				and current_date between ls.effectivedate and ls.enddate
				and ls.active = 1) employer on employer.ERcode is not null

-- Roth Contribution Value
	left join (
			select	lkup.value1 as Rcode
			from	edi.lookup_schema ls
			join	edi.lookup lkup on lkup.lookupid = ls.lookupid
				and lkup.active = 1
				and current_date between lkup.effectivedate and lkup.enddate
			where	ls.lookupname = 'FidelityContributionLoan'
				and lkup.key1 = 'Roth'
				and current_date between ls.effectivedate and ls.enddate
				and ls.active = 1) roth on roth.Rcode is not null

-- After Tax Value
	left join (
			select	lkup.value1 as ATcode
			from	edi.lookup_schema ls
			join	edi.lookup lkup on lkup.lookupid = ls.lookupid
				and lkup.active = 1
				and current_date between lkup.effectivedate and lkup.enddate
			where	ls.lookupname = 'FidelityContributionLoan'
				and lkup.key1 = 'After-Tax'
				and current_date between ls.effectivedate and ls.enddate
				and ls.active = 1) aftertax on aftertax.ATcode is not null		

						

where --pe.personid = '873' and 
	 
	'now'::text::date >= pe.effectivedate AND 'now'::text::date <= pe.enddate AND now() >= pe.createts AND now() <= pe.endts and

	(coalesce(c_ee.contribution_employee,0) <> 0 or coalesce(c_er.contribution_employer,0)<> 0 or coalesce(loan.loan_amount,0) <> 0 or coalesce(c_aftax.contribution_aftertax,0) <> 0 or coalesce(c_rth.contribution_roth,0) <> 0)

order by pip.identity
