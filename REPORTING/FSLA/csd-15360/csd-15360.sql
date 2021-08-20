SELECT pp.personid,
    pp.effectivedate,
    pp.enddate,
    pp.createts,
    pp.endts,
    pp.partialpercent,
    pp.scheduledhours,
    pp.schedulefrequency,
    pp.persposrel,
    pp.persposevent,
    pd.positionid,
    pd.positiondescpid,
    pd.effectivedate AS pdeffectivedate,
    pd.enddate AS pdenddate,
    pd.positionevent,
    pd.positionxid,
    pd.positiontitle,
    pd.positionplanid,
    pd.mgmtclass,
    pd.shiftcode,
    pd.scheduleid,
    pd.companyofficer,
    pd.payovertime,
    pd.createts AS pdcreatets,
    pd.updatets AS pdupdatets,
    pd.endts AS pdendts,
    pd.upperpositiontitle,
    pd.flsacode,
    pd.flsaprofile,
    pd.companyid,
    pd.workerscompcode,
    pd.workerscompprofile,
    pd.eeocode,
    pd.grade,
    pd.wfmuser,
    pd.taquser,
    pd.dtip,
    pd.tippedpostype,
    pd.wfmwidget,
    pd.remoteemployee,
    pd.positiontemplate,
    pd.overtimetype,
    cpd.compplancode,
    cpd.compplandesc,
   cpd.compplandescshort,
    cpd.effectivedate AS cpdeffectivedate,
    cpd.enddate AS cpdenddate,
    eeo_codes.eeocodedesc,
    pers_pos_events.persposeventdesc,
    job_desc.effectivedate AS jdeffectivedate,
    job_desc.enddate AS jdenddate,
    job_desc.jobcode,
    job_desc.jobdesc,
    job_desc.jobexperience,
    job_family_desc.jobfamilycode,
    job_family_desc.jobfamilydesc,
    federal_job_code.federaljobcode,
    federal_job_code.federaljobcodedesc,
    flsa_codes.flsacodedesc,
    salary_grade.salarygradedesc,
    salary_grade.mgmtlevel,
    shift_codes.shiftcodedesc,
    porm.effectivedate AS matrixeffectivedate,
    porm.enddate AS matrixenddate,
    porm.organizationid AS matrixorganizationid,
    ocm.organizationtype AS matrixorgtype,
    ocm.orgcode AS matrixorgcode,
    ocm.organizationdesc AS matrixorganizationdesc,
    porf.effectivedate AS membereffectivedate,
    porf.enddate AS memberenddate,
    porf.organizationid AS memberorganizationid,
    ocf.organizationtype AS memberorgtype,
    ocf.orgcode AS memberorgcode,
    ocf.organizationdesc AS memberorganizationdesc,
    porb.effectivedate AS budgeteffectivedate,
    porb.enddate AS budgetenddate,
    porb.organizationid AS budgetorganizationid,
    ocb.organizationtype AS budgetorgtype,
    ocb.orgcode AS budgetorgcode,
    ocb.organizationdesc AS budgetorganizationdesc,
    ppo.effectivedate AS mgreffectivedate,
    ppo.enddate AS mgrenddate,
    ppo.positionid AS mgrpositionid,
    ppom.personid AS mgrpersonid,
    (pnm.lname::text || ', '::text) || pnm.fname::text AS mgrname,
    pnm.lname AS mgrlname,
    pdm.positiontitle AS mgrtitle,
    pim.identity AS mgrempno
   FROM pers_pos pp
     LEFT JOIN position_desc pd ON pd.positionid = pp.positionid AND "overlaps"(pp.effectivedate::timestamp with time zone, pp.enddate::timestamp with time zone, pd.effectivedate::timestamp with time zone, pd.enddate::timestamp with time zone) AND pd.effectivedate <= pd.enddate AND now() >= pd.createts AND now() <= pd.endts
     LEFT 
     JOIN pos_pos ppo ON pp.positionid = ppo.topositionid AND "overlaps"(GREATEST(pp.effectivedate, pd.effectivedate)::timestamp with time zone, LEAST(pp.enddate, pd.enddate)::timestamp with time zone, ppo.effectivedate::timestamp with time zone, ppo.enddate::timestamp with time zone) AND ppo.effectivedate <= ppo.enddate AND now() >= ppo.createts AND now() <= ppo.endts
      --and current_date between ppo.effectivedate and ppo.enddate
     LEFT JOIN pos_org_rel porf ON pp.positionid = porf.positionid AND "overlaps"(GREATEST(pd.effectivedate)::timestamp with time zone, LEAST(pd.enddate)::timestamp with time zone, porf.effectivedate::timestamp with time zone, porf.enddate::timestamp with time zone) AND porf.effectivedate <= porf.enddate AND porf.posorgreltype = 'Member'::bpchar AND now() >= porf.createts AND now() <= porf.endts
      --and current_date between porf.effectivedate and porf.enddate
     LEFT JOIN organization_code ocf ON porf.organizationid = ocf.organizationid AND LEAST('now'::text::date, porf.enddate) >= ocf.effectivedate AND LEAST('now'::text::date, porf.enddate) <= ocf.enddate AND ocf.effectivedate <= ocf.enddate AND now() >= ocf.createts AND now() <= ocf.endts
     LEFT JOIN pos_org_rel porb ON pp.positionid = porb.positionid AND "overlaps"(GREATEST(pp.effectivedate, pd.effectivedate, ppo.effectivedate)::timestamp with time zone, LEAST(pp.enddate, pd.enddate, ppo.enddate)::timestamp with time zone, porb.effectivedate::timestamp with time zone, porb.enddate::timestamp with time zone) AND porb.effectivedate <= porb.enddate AND porb.posorgreltype = 'Budget'::bpchar AND now() >= porb.createts AND now() <= porb.endts
     LEFT JOIN organization_code ocb ON porb.organizationid = ocb.organizationid AND LEAST('now'::text::date, porb.enddate) >= ocb.effectivedate AND LEAST('now'::text::date, porb.enddate) <= ocb.enddate AND ocb.effectivedate <= ocb.enddate AND now() >= ocb.createts AND now() <= ocb.endts
     LEFT JOIN pos_org_rel porm ON pp.positionid = porm.positionid AND "overlaps"(GREATEST(pp.effectivedate, pd.effectivedate, ppo.effectivedate)::timestamp with time zone, LEAST(pp.enddate, pd.enddate, ppo.enddate)::timestamp with time zone, porm.effectivedate::timestamp with time zone, porm.enddate::timestamp with time zone) AND porm.effectivedate <= porm.enddate AND porm.posorgreltype = 'Matrix'::bpchar AND now() >= porm.createts AND now() <= porm.endts
     LEFT JOIN organization_code ocm ON porm.organizationid = ocm.organizationid AND LEAST('now'::text::date, porm.enddate) >= ocm.effectivedate AND LEAST('now'::text::date, porm.enddate) <= ocm.enddate AND ocm.effectivedate <= ocm.enddate AND now() >= ocm.createts AND now() <= ocm.endts
-- manager
     LEFT JOIN pers_pos ppom ON ppo.positionid = ppom.positionid AND "overlaps"(GREATEST(pp.effectivedate, ppo.effectivedate)::timestamp with time zone, LEAST(pp.enddate, ppo.enddate)::timestamp with time zone, ppom.effectivedate::timestamp with time zone, ppom.enddate::timestamp with time zone) AND ppom.effectivedate <= ppom.enddate AND now() >= ppom.createts AND now() <= ppom.endts
     LEFT JOIN person_names pnm ON ppom.personid = pnm.personid AND 'now'::text::date >= pnm.effectivedate AND 'now'::text::date <= pnm.enddate AND now() >= pnm.createts AND now() <= pnm.endts AND pnm.nametype = 'Legal'::bpchar
     LEFT JOIN person_identity pim ON ppom.personid = pim.personid AND now() >= pim.createts AND now() <= pim.endts AND pim.identitytype = 'EmpNo'::bpchar
     LEFT JOIN position_desc pdm ON ppo.positionid = pdm.positionid AND LEAST('now'::text::date, ppo.enddate) >= pdm.effectivedate AND LEAST('now'::text::date, ppo.enddate) <= pdm.enddate AND pdm.effectivedate <= pdm.enddate AND now() >= pdm.createts AND now() <= pdm.endts
     LEFT JOIN position_comp_plan pcp ON pcp.positionid = pp.positionid AND pd.effectivedate >= pcp.effectivedate AND pd.effectivedate <= pcp.enddate AND now() >= pcp.createts AND now() <= pcp.endts
     LEFT JOIN comp_plan_desc cpd ON cpd.compplanid = pcp.compplanid AND 'now'::text::date >= cpd.effectivedate AND 'now'::text::date <= cpd.enddate AND now() >= cpd.createts AND now() <= cpd.endts
     LEFT JOIN eeo_codes ON eeo_codes.eeocode = pd.eeocode
     LEFT JOIN pers_pos_events ON pers_pos_events.persposevent = pp.persposevent
     LEFT JOIN position_job ON position_job.positionid = pp.positionid AND pd.effectivedate >= position_job.effectivedate AND pd.effectivedate <= position_job.enddate AND now() >= position_job.createts AND now() <= position_job.endts
     LEFT JOIN job_desc ON job_desc.jobid = position_job.jobid AND "overlaps"(GREATEST(pp.effectivedate, pd.effectivedate, ppo.effectivedate, porf.effectivedate, porb.effectivedate, position_job.effectivedate)::timestamp with time zone, LEAST(pp.enddate, pd.enddate, ppo.enddate, porf.enddate, porb.enddate, position_job.enddate)::timestamp with time zone, job_desc.effectivedate::timestamp with time zone, (job_desc.enddate + 1)::timestamp with time zone) AND job_desc.effectivedate <= job_desc.enddate AND now() >= job_desc.createts AND now() <= job_desc.endts
     LEFT JOIN federal_job_code ON federal_job_code.federaljobcodeid = job_desc.federaljobcodeid
     LEFT JOIN job_family_desc ON job_family_desc.jobfamilyid = job_desc.jobfamilyid
     LEFT JOIN flsa_codes ON flsa_codes.flsacode = pd.flsacode
     LEFT JOIN salary_grade ON salary_grade.grade = pd.grade AND "overlaps"(salary_grade.effectivedate::timestamp with time zone, salary_grade.enddate::timestamp with time zone, pd.effectivedate::timestamp with time zone, pd.enddate::timestamp with time zone) AND salary_grade.effectivedate <= salary_grade.enddate AND now() >= salary_grade.createts AND now() <= salary_grade.endts
     LEFT JOIN shift_codes ON shift_codes.shiftcode = pd.shiftcode
  WHERE pp.enddate > pp.effectivedate AND now() >= pp.createts AND now() <= pp.endts
  and pp.personid = '63570'                   
