select * from acapreviewlist where personid = '402';
select * from acaemployeeline14and15 where personid = '402';

 (
                                SELECT
                                    x.personid,
                                    x.minessentialcoverage,
                                    x.minessentialcoverageoffered,
                                    x.certificationofeligibility,
                                    x.employeelowestcost1effectivedate,
                                    x.employeelowestcost2effectivedate,
                                    x.employeelowestcost1,
                                    x.employeelowestcost2,
                                    x.reportyear,
                                    MIN(x.line14)        AS line14,
                                    MAX(x.ptmedcoverage) AS ptmedcoverage,
                                    x.benefitelection,
                                    x.monthcov
                                FROM
                                    (
                                        SELECT
                                            pe.effectivedate,
                                            pe.enddate,
                                            pe.personid,
                                            reportspan.asofdate,
                                            crpa.minessentialcoverage,
                                            crpa.minessentialcoverageoffered,
                                            crpa.certificationofeligibility,
                                            crpa.employeelowestcost1effectivedate,
                                            crpa.employeelowestcost2effectivedate,
                                            crpa.employeelowestcost1,
                                            crpa.employeelowestcost2,
                                            crpa.reportyear,
                                            pe.emplstatus,
                                            pe.emplclass,
                                            pe.emplhiredate,
                                            pe.empllasthiredate,
                                            pbe.benefitelection,
                                            CASE
                                                WHEN ((pbe.personbeneelectionpid IS NOT NULL)
                                                    AND (pbe.benefitelection = 'E'::bpchar)
                                                    AND (COALESCE(ec.emplclassequiv, pe.emplclass)
                                                            = 'P'::bpchar))
                                                THEN 1
                                                ELSE 0
                                            END AS ptmedcoverage,
                                            date_part('month'::text, (reportspan.asofdate)::
                                            TIMESTAMP without TIME zone) AS monthcov,
                                            CASE
                                                WHEN ((COALESCE(ec.emplclassequiv, pe.emplclass) =
                                                            'F'::bpchar)
                                                    AND (pbe.personbeneelectionpid IS NOT NULL)
                                                    AND (pe.emplstatus <> 'T'::bpchar)
                                                    AND (pe.emplstatus <> 'R'::bpchar)
                                                    AND ((crpa.minessentialcoverage)::text = 'Y'::
                                                            text)
                                                    AND (NOT (crpa.certificationofeligibility ~~
                                                                '%B%'::text)))
                                                THEN 1
                                                WHEN ((COALESCE(ec.emplclassequiv, pe.emplclass) =
                                                            'F'::bpchar)
                                                    AND (pbe.personbeneelectionpid IS NOT NULL)
                                                    AND (pe.emplstatus <> 'T'::bpchar)
                                                    AND (pe.emplstatus <> 'R'::bpchar)
                                                    AND ((crpa.minessentialcoverage)::text = 'Y'::
                                                            text)
                                                    AND (crpa.certificationofeligibility ~~ '%B%'::
                                                            text))
                                                THEN 2
                                                WHEN ((COALESCE(ec.emplclassequiv, pe.emplclass) =
                                                            'P'::bpchar)
                                                    AND (pbe.personbeneelectionpid IS NOT NULL)
                                                    AND (pbe.benefitelection = 'E'::bpchar)
                                                    AND (pe.emplstatus <> 'T'::bpchar)
                                                    AND (pe.emplstatus <> 'R'::bpchar)
                                                    AND (pbe.personbeneelectionpid IS NOT NULL))
                                                THEN 3
                                                WHEN (((crpa.minessentialcoverage)::text = 'N'::
                                                            text)
                                                    AND (pbe.personbeneelectionpid IS NOT NULL)
                                                    AND (pe.emplstatus <> 'T'::bpchar)
                                                    AND (pe.emplstatus <> 'R'::bpchar)
                                                    AND (crpa.certificationofeligibility ~~ '%B%'::
                                                            text))
                                                THEN 4
                                                WHEN (((crpa.minessentialcoverage)::text = 'N'::
                                                            text)
                                                    AND (pbe.personbeneelectionpid IS NOT NULL)
                                                    AND (pe.emplstatus <> 'T'::bpchar)
                                                    AND (pe.emplstatus <> 'R'::bpchar))
                                                THEN 5
                                                ELSE 6
                                            END AS line14
                                        FROM ((((( (person_employment pe JOIN compliance_report_params_aca crpa ON (((pe.companyid = crpa.companyid) AND (now() >= crpa.createts) AND (now() <= crpa.endts) AND (('now'::text)::DATE >= crpa.effectivedate) AND (('now'::text)::DATE <= crpa.enddate))))
                                        
                                        CROSS JOIN asof reportspan)
                                        LEFT JOIN  person_bene_election pbe ON (((pe.personid = pbe.personid) AND (reportspan.asofdate >= pbe.effectivedate) AND (reportspan.asofdate <= pbe.enddate) AND (now() >= pbe.createts) AND (now() <= pbe.endts) AND (pbe.benefitelection = ANY (ARRAY['E'::bpchar, 'W'::bpchar])))))
                                        JOIN benefit_subclass bsc ON ((bsc.benefitsubclass = pbe.benefitsubclass)))
                                        JOIN benefit_class bc ON ((bc.benefitclass = bsc.benefitclass)))
                                        JOIN employment_class ec ON ((pe.emplclass = ec.emplclass)))
                                        WHERE ((reportspan.asofdate >= pe.effectivedate) and pe.personid = '402'
                                            AND (reportspan.asofdate <= pe.enddate)
                                            AND (bc.benefitclassdesc = 'Medical ACA'::bpchar)
                                            AND (now() >= pe.createts)
                                            AND (now() <= pe.endts)
                                            AND (reportspan.asofdate >= (('01/01/'::text ||(crpa.reportyear)::text))::DATE)
                                            AND (reportspan.asofdate <= (('12/31/'::text ||(crpa.reportyear)::text))::DATE))) x
                                GROUP BY
                                    x.personid,
                                    x.minessentialcoverage,
                                    x.minessentialcoverageoffered,
                                    x.certificationofeligibility,
                                    x.employeelowestcost1effectivedate,
                                    x.employeelowestcost2effectivedate,
                                    x.employeelowestcost1,
                                    x.employeelowestcost2,
                                    x.reportyear,
                                    x.monthcov,
                                    x.benefitelection
                                ORDER BY
                                    x.personid,
                                    x.monthcov)