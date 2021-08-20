select distinct

 
 bd.personid
,pfe.personid as frompfe
,pip.identity 
,bh.batchheaderid ::varchar(15) as BACHNUMB -----Batch number
,pi.identity ::varchar(15) as EMPLOYID -----Employee ID

/*
Computer transaction type (COMPTRTP):
1=Pay code;
2=Deduction;
3=Benefit
*/      
,0 as SALCHG
/*
Salary change(SALCHG): required if passing a salary pay code:
1=Reallocate dollars;
2=Reallocate hours;
3=Reduce dollars;
4=Reduce hours;
5=Additional amount
*/

-- select * from pspay_etv_list where etv_id = 'E17';
 ---COMPTRTP the -1 and -2 designates each as 1=paycode 2=deduction 3=benefit
,case when bd.etv_id = 'E01' and pc.frequencycode = 'H' then bd.etv_id || 'H' 
      when bd.etv_id = 'E01' and pc.frequencycode = 'A' then bd.etv_id || 'S' else bd.etv_id end ::char(6) as UPRTRXCD_earnings
,bd.amount      
,pc.compamount
,case when coalesce(pmO.benefiteffdatecode, pmS.benefiteffdatecode) = 'MEDT' AND pc.frequencycode = 'H' then 'V37'
      when coalesce(pmO.benefiteffdatecode, pmS.benefiteffdatecode) = 'MEDT' AND pc.frequencycode = 'A' then 'V37'
      when coalesce(pmO.benefiteffdatecode, pmS.benefiteffdatecode) = 'VISD' AND pc.frequencycode = 'H' then 'V46'
      when coalesce(pmO.benefiteffdatecode, pmS.benefiteffdatecode) = 'VISD' AND pc.frequencycode = 'A' then 'V46'
      when coalesce(pmO.benefiteffdatecode, pmS.benefiteffdatecode) = 'DEPD' AND pc.frequencycode = 'H' then 'V38'  
      when coalesce(pmO.benefiteffdatecode, pmS.benefiteffdatecode) = 'DEPD' AND pc.frequencycode = 'A' then 'V38' 
      when coalesce(pmO.benefiteffdatecode, pmS.benefiteffdatecode) = 'OLDT' AND pc.frequencycode = 'H' then 'VA9'  
      when coalesce(pmO.benefiteffdatecode, pmS.benefiteffdatecode) = 'OLDT' AND pc.frequencycode = 'A' then 'VA9'      
      END ::char(6) as UPRTRXCD_benefits

,to_char(psp.periodstartdate,'yyyymmdd') ::char(8) as TRXBEGDT ---Transaction begin date

,to_char(psp.periodenddate,'yyyymmdd') ::char(8) as TRXENDDT ---Transaction end date

,CASE WHEN bd.etv_id in ('E01','E02','E03','E15','E19','E18','E08', 'E61','E05','ECZ','EC8','E17')
      THEN TRUNC(bd.hours,2)
      ELSE 0 END ::varchar(21) as TRXHRUNT
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
,pc.frequencycode 
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
        END, 2) AS HRLYPYRT -------Hourly pay rate

   
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
        END, 2) AS PAYRTAMT
/*
Pay rate amount(PAYRTAMT): required if passing the pay code:
1=Salary with a salary change of reallocated dollars;
2=Salary with a salary change of reduced dollars;
3=Salary with a salary change of additional amount;
4=Charged tips;
5=Reported tips
*/        

, round(poc.employeerate::numeric, 2) as VARDBAMT -----Variable deduction/benefit amount
,0 as VARDBPCT -----Variable deduction/benefit percent
,0 as RECEIPTS -----Receipts
,0 as DAYSWRDK -----Days worked
,0 as WKSWRKD -----Weeks worked
   

--,ocd.orgcode as DEPRTMNT -----Department; if empty, pulls from UPR00100

,split_part(ocd.orgcode, '-' ,1) ::char(6) as DEPRTMNT
,pos_d.positionxid ::char(6) as JOBTITLE
--,replace(dpd.positiontitle,',','') as JOBTITLE -----Job title/position code; if empty, pulls from UPR00100

,la.stateprovincecode ::char(2) as STATECD -----State code
  
,0 as LOCALTAX -----Local tax

,la.stateprovincecode ::char(2) as SUTASTAT -----SUTA state

--,wcps.workerscompprofile
,pd.workerscompcode as WRKRCOMP -----Workers' compensation code

,pd.shiftcode ::char(1) as SHFTCODE -----Shift code
,case when bd.etv_id in ('E05','E06','E07') 
      then bd.amount else null end ::varchar(21) as SHFTPREM -----Shift premium

,0 as RequesterTrx
/*
Requester transaction (RequesterTrx):
0=False;
1=True (if True, it populates the requester shadow table)
*/

,' '  ::varchar(21) as USERID
,' '  ::varchar(21) as USRDEFND1
,' '  ::varchar(21) as USRDEFND2
,' '  ::varchar(21) as USRDEFND3
,' '  ::varchar(21) as USRDEFND4
,' '  ::varchar(21) as USRDEFND5

FROM batch_header bh

JOIN batch_detail bd 
  ON bd.batchheaderid = bh.batchheaderid 
 --AND current_date between bd.effectivedate and bd.enddate 
 AND current_timestamp between bd.createts AND bd.endts

-- select * from person_financial_plan_election where personid in ('6099');

-- SELECT * FROM PAY_UNIT
join person_bene_election pbe 
  on pbe.personid = bd.personid
 and current_date between pbe.effectivedate and pbe.enddate
 and current_timestamp between pbe.createts and pbe.endts
 and pbe.benefitelection in ('E', 'T', 'W')
 
 
left join person_financial_plan_election pfe
  on pfe.personid = pbe.personid
 and pfe.benefitsubclass = pbe.benefitsubclass   
 and current_date between pfe.effectivedate and pfe.enddate
 and current_timestamp between pfe.createts and pfe.endts

 
left join personbenoptioncostl poc 
  on poc.personid = pbe.personid
 and poc.personbeneelectionpid = pbe.personbeneelectionpid
 and poc.costsby = 'P'
 
left join pspay_benefit_mapping pmS 
  on pmS.benefitsubclass = pbe.benefitsubclass
 and pmS.benefitplanid is null
 and (pbe.taxable = pmS.taxable
      or pmS.taxable is null)
      
left join pspay_benefit_mapping pmO 
  on pmO.benefitsubclass = pbe.benefitsubclass
 and pmO.benefitplanid = pbe.benefitplanid 
  

JOIN pay_schedule_period psp 
  ON psp.payscheduleperiodid = bh.payscheduleperiodid
 and psp.periodpaydate >= ?::date

JOIN pers_pos pp 
  ON pp.personid = bd.personid 
 AND bd.effectivedate >= pp.effectivedate 
 AND bd.effectivedate <= pp.enddate 
 AND current_timestamp between pp.createts AND pp.endts 
 AND pp.persposrel = 'Occupies'::bpchar
 
join person_names pn
  on pn.personid = pp.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts
  
join person_address pa
  on pa.personid = pp.personid
 and pa.addresstype = 'Res'
 and pa.stateprovincecode in ('CH','BZ','FR')
 and current_date between pa.effectivedate and pa.enddate 
 and current_timestamp between pa.createts and pa.endts 

join person_identity pi 
  on pi.personid = pp.personid
 and pi.identitytype = 'EmpNo'
 and current_timestamp between pi.createts and pi.endts
 
join person_identity pip
  on pip.personid = pp.personid
 and pip.identitytype = 'PSPID'
 and current_timestamp between pip.createts and pip.endts  
 
left join person_locations pl
  on pl.personid = pp.personid
 and current_date between pl.effectivedate and pl.enddate
 and current_timestamp between pl.createts and pl.endts 
 
JOIN person_compensation pc 
  ON pc.personid = bd.personid 
 AND bd.effectivedate >= pc.effectivedate 
 AND bd.effectivedate <= pc.enddate 
 AND current_timestamp between pc.createts AND pc.endts 
 AND (pc.earningscode = ANY (ARRAY['Regular'::bpchar, 'RegHrly'::bpchar, 'ExcHrly'::bpchar]))
 
JOIN position_desc pd 
  ON pd.positionid = pp.positionid 
 AND bd.effectivedate >= pd.effectivedate 
 AND bd.effectivedate <= pd.enddate 
 AND current_timestamp between pd.createts AND pd.endts
 
JOIN person_payroll ppay 
  ON ppay.personid = bd.personid 
 AND bd.effectivedate >= ppay.effectivedate 
 AND bd.effectivedate <= ppay.enddate 
 AND current_timestamp between ppay.createts and ppay.endts 
 AND ppay.payunitrelationship = 'M'::bpchar 

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


LEFT JOIN pspay_group_earnings pg 
  ON pg.etv_id = bd.etv_id
 AND g.groupkey::bpchar = pg.group_key
 AND current_timestamp between pg.createts AND pg.endts 
 AND NOT (COALESCE(pg.otwagetype, 1) = 2 AND COALESCE(pd.overtimetype, 1) = 2)
 
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
 and pord.enddate = '2199-12-31'

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
 
left join location_address la
  on la.locationid = pl.locationid
 and current_date between la.effectivedate and la.enddate
 and current_timestamp between la.createts and la.endts 

left join position_desc pos_d
  on pos_d.positionid = pp.positionid
 and current_date between pos_d.effectivedate and pos_d.enddate
 and current_timestamp between pos_d.createts and pos_d.endts
 and pos_d.effectivedate - interval '1 day' <> pos_d.enddate     
 
WHERE current_date between bh.effectivedate and bh.enddate 
  AND current_timestamp between bh.createts AND bh.endts
  and pu.payunitxid in ('25');
