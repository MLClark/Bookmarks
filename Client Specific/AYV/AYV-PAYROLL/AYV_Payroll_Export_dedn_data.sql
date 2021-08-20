--CREATE OR REPLACE VIEW public.personbatchtransactionrate AS 
 SELECT 
 bd.personid
,psp.periodpaydate  
,pn.lname
,pn.fname
,bd.batchdetailid

,pda.etv_id
,pel.etv_short
,pda.current_dedn_amount
--,pda.current_dedn_hours



,bh.batchheaderid ::char(15) as BACHNUMB -----Batch number

,pi.identity ::char(15) as EMPLOYID -----Employee ID

,case when left(bd.etv_id,1) = 'E' then '1'
      when left(bd.etv_id,1) = 'V' then '2' end ::char(2) as COMPTRTP
/*
Computer transaction type (COMPTRTP):
1=Pay code;
2=Deduction;
3=Benefit
*/      
,'??' ::char(2) as SALCHG
/*
Salary change(SALCHG): required if passing a salary pay code:
1=Reallocate dollars;
2=Reallocate hours;
3=Reduce dollars;
4=Reduce hours;
5=Additional amount
*/
,pda.etv_id ::char(6) as UPRTRXCD --- UPR transaction code (Pay code, Deduction Code or Benefit Code)

,to_char(psp.periodstartdate,'yyyymmdd') ::char(8) as TRXBEGDT ---Transaction begin date

,to_char(psp.periodenddate,'yyyymmdd') ::char(8) as TRXENDDT ---Transaction end date

,0 ::char(21) as TRXHRUNT
/*
Transaction hours/units (TRXHRUNT): required if the pay code passed is:
1=Salary with a salary change of reallocated hours;
2=Salary with a salary change of reduced hours;
3=Piecework;
4=Overtime;
5=Double time;
6=Vacation;
7=Sick;
8=Holiday;
9=Minimum wage balance
*/
       ,round(
        CASE
            WHEN bd.overriderate IS NOT NULL AND (bd.processed = ANY (ARRAY['R'::bpchar, 'C'::bpchar])) THEN bd.overriderate
            ELSE
            CASE
                WHEN pg.default_rate > 0::numeric THEN pg.default_rate
                ELSE
                CASE
                    WHEN pc.frequencycode = 'H'::bpchar THEN pc.compamount
                    ELSE
                    CASE
                        WHEN (pp.scheduledhours * fcpos.annualfactor) > 0::numeric THEN pc.compamount * fc.annualfactor / (pp.scheduledhours * fcpos.annualfactor)
                        ELSE 0.00
                    END
                END
            END * COALESCE(pg.rate_multiplier, 1::numeric)
        END, 4) AS HRLYPYRT -------Hourly pay rate

   
       ,round(
        CASE
            WHEN bd.overriderate IS NOT NULL AND (bd.processed = ANY (ARRAY['R'::bpchar, 'C'::bpchar])) THEN bd.overriderate
            ELSE
            CASE
                WHEN pg.default_rate > 0::numeric THEN pg.default_rate
                ELSE
                CASE
                    WHEN pc.frequencycode = 'H'::bpchar THEN pc.compamount
                    ELSE
                    CASE
                        WHEN (pp.scheduledhours * fcpos.annualfactor) > 0::numeric THEN pc.compamount * fc.annualfactor / (pp.scheduledhours * fcpos.annualfactor)
                        ELSE 0.00
                    END
                END
            END * COALESCE(pg.rate_multiplier, 1::numeric)
        END, 4) AS PAYRTAMT
/*
Pay rate amount(PAYRTAMT): required if passing the pay code:
1=Salary with a salary change of reallocated dollars;
2=Salary with a salary change of reduced dollars;
3=Salary with a salary change of additional amount;
4=Charged tips;
5=Reported tips
*/        
        
,'??' ::char(21) as VARDBAMT -----Variable deduction/benefit amount

,'??' ::char(21) as VARDBPCT -----Variable deduction/benefit percent

,'??' ::char(21) as RECEIPTS -----Receipts

,'??' ::char(21) as DAYSWRDK -----Days worked

,'??' ::char(21) as WKSWRKD -----Weeks worked
   

,ocd.orgcode as DEPRTMNT -----Department; if empty, pulls from UPR00100

,dpd.positiontitle ::char(50) as JOBTITLE -----Job title/position code; if empty, pulls from UPR00100

,la.stateprovincecode ::char(2) as STATECD -----State code
  
,'??' ::char(21) as LOCALTAX -----Local tax

,la.stateprovincecode ::char(2) as SUTASTAT -----SUTA state

,wcps.workerscompprofile
,pd.workerscompcode as WRKRCOMP -----Workers' compensation code

,pd.shiftcode as SHFTCODE -----Shift code



,'0' ::char(21) as SHFTPREM -----Shift premium

,'0' ::char(2) as RequesterTrx
/*
Requester transaction (RequesterTrx):
0=False;
1=True (if True, it populates the requester shadow table)
*/

,' '  ::char(21) as USERID
,' '  ::char(21) as USRDEFND1
,' '  ::char(21) as USRDEFND2
,' '  ::char(21) as USRDEFND3
,' '  ::char(21) as USRDEFND4
,' '  ::char(21) as USRDEFND5
     

    
,bh.payunitid
,bh.payscheduleperiodid


,psp.periodpaydate
,psp.payrolltypeid
,psp.processfinaldate
,bh.processed AS headerprocessed
,bd.effectivedate


,bd.amount
,bd.overriderate
,bd.generalledgeroverride
,bd.sequencenumber
,bd.processed AS detailprocessed

,COALESCE(pg.rate_multiplier, 1::numeric) AS ratemultiplier
    
       ,CASE
            WHEN bd.overriderate IS NOT NULL AND (bd.processed = ANY (ARRAY['R'::bpchar, 'C'::bpchar])) THEN 0
            WHEN bd.amount <> 0::numeric THEN 0
            WHEN round(
            CASE
                WHEN bd.overriderate IS NOT NULL AND (bd.processed = ANY (ARRAY['R'::bpchar, 'C'::bpchar])) THEN bd.overriderate
                ELSE
                CASE
                    WHEN pg.default_rate > 0::numeric THEN pg.default_rate
                    ELSE
                    CASE
                        WHEN pc.frequencycode = 'H'::bpchar THEN pc.compamount
                        ELSE
                        CASE
                            WHEN (pp.scheduledhours * fcpos.annualfactor) > 0::numeric THEN pc.compamount * fc.annualfactor / (pp.scheduledhours * fcpos.annualfactor)
                            ELSE 0.00
                        END
                    END
                END * COALESCE(pg.rate_multiplier, 1::numeric)
            END, 4) > 99.9999 THEN 0
            ELSE 1
        END AS calculate_override
        
    ,round(
        CASE
            WHEN bd.overriderate IS NOT NULL AND (bd.processed = ANY (ARRAY['R'::bpchar, 'C'::bpchar])) THEN bd.overriderate
            ELSE
            CASE
                WHEN pg.default_rate > 0::numeric THEN pg.default_rate
                ELSE
                CASE
                    WHEN pc.frequencycode = 'H'::bpchar THEN pc.compamount
                    ELSE
                    CASE
                        WHEN (pp.scheduledhours * fcpos.annualfactor) > 0::numeric THEN pc.compamount * fc.annualfactor / (pp.scheduledhours * fcpos.annualfactor)
                        ELSE 0.00
                    END
                END
            END * COALESCE(pg.rate_multiplier, 1::numeric)
        END, 4) AS transaction_rate_rounded
        
       ,CASE
            WHEN bd.overriderate IS NOT NULL AND (bd.processed = ANY (ARRAY['R'::bpchar, 'C'::bpchar])) THEN bd.overriderate
            ELSE round(
            CASE
                WHEN pg.default_rate > 0::numeric THEN pg.default_rate
                ELSE
                CASE
                    WHEN pc.frequencycode = 'H'::bpchar THEN pc.compamount
                    ELSE
                    CASE
                        WHEN (pp.scheduledhours * fcpos.annualfactor) > 0::numeric THEN pc.compamount * fc.annualfactor / (pp.scheduledhours * fcpos.annualfactor)
                        ELSE 0.00
                    END
                END
            END * COALESCE(pg.rate_multiplier, 1::numeric), 6)
        END AS transaction_rate
        
        
FROM batch_header bh

JOIN batch_detail bd 
  ON bd.batchheaderid = bh.batchheaderid 
 AND current_date between bd.effectivedate and bd.enddate 
 AND current_timestamp between bd.createts AND bd.endts
 
JOIN person_payroll ppay 
  ON ppay.personid = bd.personid 
 AND bd.effectivedate >= ppay.effectivedate 
 AND bd.effectivedate <= ppay.enddate 
 AND current_timestamp between ppay.createts and ppay.endts 
 AND ppay.payunitrelationship = 'M'::bpchar
 
JOIN pers_pos pp 
  ON pp.personid = bd.personid 
 AND bd.effectivedate >= pp.effectivedate 
 AND bd.effectivedate <= pp.enddate 
 AND current_timestamp between pp.createts AND pp.endts 
 AND pp.persposrel = 'Occupies'::bpchar
 
join person_identity pi 
  on pi.personid = pp.personid
 and pi.identitytype = 'EmpNo'
 and current_timestamp between pi.createts and pi.endts
 
join person_identity pip
  on pip.personid = pp.personid
 and pip.identitytype = 'PSPID'
 and current_timestamp between pip.createts and pip.endts 
 
join person_names pn
  on pn.personid = pp.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts

JOIN position_desc pd 
  ON pd.positionid = pp.positionid 
 AND bd.effectivedate >= pd.effectivedate 
 AND bd.effectivedate <= pd.enddate 
 AND current_timestamp between pd.createts AND pd.endts
 
JOIN person_compensation pc 
  ON pc.personid = bd.personid 
 AND bd.effectivedate >= pc.effectivedate 
 AND bd.effectivedate <= pc.enddate 
 AND current_timestamp between pc.createts AND pc.endts 
 AND (pc.earningscode = ANY (ARRAY['Regular'::bpchar, 'RegHrly'::bpchar, 'ExcHrly'::bpchar]))
 
JOIN frequency_codes fc 
  ON fc.frequencycode = pc.frequencycode
  
JOIN pay_unit pu 
  ON pu.payunitid = ppay.payunitid
  
JOIN frequency_codes fcpos 
  ON fcpos.frequencycode = pp.schedulefrequency
  
JOIN frequency_codes fcpay 
  ON fcpay.frequencycode = pu.frequencycode
  
JOIN groupkey g 
  ON g.payunitid = pu.payunitid

join pspay_deduction_accumulators pda
  on pda.individual_key = pip.identity
 and pda.year = '2017'
 and pda.current_payroll_status = 'A'
  
LEFT JOIN pspay_group_earnings pg 
  ON pg.etv_id = bd.etv_id
 AND pg.group_key = g.groupkey
 AND current_timestamp between pg.createts AND pg.endts 
 AND NOT (COALESCE(pg.otwagetype, 1) = 2 AND COALESCE(pd.overtimetype, 1) = 2)
 
join pspay_etv_list pel
  on pel.etv_id = pda.etv_id  
 and pel.group_key = g.groupkey 
 
JOIN pay_schedule_period psp 
  ON psp.payscheduleperiodid = bh.payscheduleperiodid
 and psp.periodstartdate >= '2017-11-15'
     
left join 
     (
     Select distinct pp.personid, pp.positionid, pc.hce_Ind
       From pers_pos pp
		 JOIN person_compensation pc 
		   ON pc.personid = pp.personid
		group by 1,2,3
	  ) as HCE
on hce.personid = pp.personid			
 
left join 
     (
      Select distinct pd.positionid, sgr.*
        From positiondetails pd
	     JOIN salary_grade_ranges sgr 
	       ON sgr.grade = pd.grade
	      AND sgr.edtcode = 'Regular' 
	      AND frequencycode = 'A'
			and current_date between sgr.effectivedate and sgr.enddate 
			AND current_timestamp between sgr.createts and sgr.endts
			and sgr.effectivedate - interval '1 day' <> sgr.enddate
		) as sg
on sg.positionid = hce.positionid

left join 
     (
      Select distinct pp.personid as mgrpersonid, ppm.*
        From posposmanagerdetail ppm
		  LEFT OUTER JOIN pers_pos pp 
		    ON pp.positionid = ppm.mgrpositionid
		   AND current_date between pp.effectivedate and pp.enddate 
		   AND current_timestamp between pp.createts and pp.endts
		   and pp.effectivedate - interval '1 day' <> pp.enddate
       Where current_date between ppm.effectivedate and ppm.enddate 
         AND current_timestamp between ppm.createts and ppm.endts
         and ppm.effectivedate - interval '1 day' <> ppm.enddate
      )	as pmd
on pmd.mgrpersonid = pi.personid 


left join dcpositiondesc dpd
  on dpd.positionid = hce.positionid

left join positionorgreldetail pord 
  on pord.positionid = dpd.positionid	
 and pord.posorgreltype = 'Member'

left join org_rel orel
  on orel.organizationid = pord.organizationid
 and current_date between orel.effectivedate and orel.enddate
 and current_timestamp between orel.createts and orel.endts
 and orel.effectivedate - interval '1 day' <> orel.enddate	

left join organization_code oc_div 
  on oc_div.organizationid = orel.memberoforgid
 and oc_div.organizationtype = 'Div'
 and current_date between oc_div.effectivedate and oc_div.enddate
 and current_timestamp between oc_div.createts and oc_div.endts
 and oc_div.effectivedate - interval '1 day' <> oc_div.enddate

left join jobcodedetail jcd
  on jcd.jobid = dpd.jobid
 and current_date between jcd.effectivedate and jcd.enddate
 and current_timestamp between jcd.createts and jcd.endts
 and jcd.effectivedate - interval '1 day' <> jcd.enddate							
							
left join organization_code ocd
  on ocd.organizationid = pord.organizationid
 and current_date between ocd.effectivedate and ocd.enddate 
 and current_timestamp between ocd.createts and ocd.endts
 and ocd.effectivedate - interval '1 day' <> ocd.enddate  
 
left join person_locations pl
  on pl.personid = pp.personid
 and current_date between pl.effectivedate and pl.enddate
 and current_timestamp between pl.createts and pl.endts
 
left join location_address la
  on la.locationid = pl.locationid
 and current_date between la.effectivedate and la.enddate
 and current_timestamp between la.createts and la.endts 
 
JOIN work_comp_profile_states wcps 
  on wcps.stateprovincecode = la.stateprovincecode  
/*  
join workers_comp_code wcc
  on wcc.workerscompprofile = wcps.workerscompprofile
 and wcc.workerscompcode in ('8810','8832','953')
*/

WHERE current_date between bh.effectivedate and bh.enddate 
  AND current_timestamp between bh.createts AND bh.endts
  --and psp.periodpaydate = ?
  AND PI.personid = '4061'