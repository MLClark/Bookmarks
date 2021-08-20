select distinct
 pi.personid
,pe.emplstatus
,pe.effectivedate
,pd.positiontitle
,pp.positionid
----------------------------------
----- EMPLOYEE DETAIL RECORD -----
----------------------------------
,'E' ::char(1) as record_type --1
,'0102570' ::char(7) as customer_number --2
,replace(pi.identity,'-','') ::char(11) as essn --9
,pie.identity ::char(9) as personnel_id --20
,' ' ::char(1) as filler29 --29
,'0' ::char(1) as relationship_code --42
,pn.lname ::char(20) as lname --43
,pn.fname ::char(12) as fname --63
,pn.mname ::char(1)  as mname --75
,to_char(pv.birthdate,'MMDDYYYY')::char(8) as dob --76
--,pm.maritalstatus
,case when pm.maritalstatus in ('M','S') then pm.maritalstatus else 'U' end ::char(1) as marital_status --84
,case when pv.gendercode in ('M','F') then pv.gendercode else 'U' end ::char(1) as sex  --85
--,pe.empllasthiredate
,to_char(pe.empllasthiredate,'MMDDYYYY')::char(8) as employment_date --86
,replace(ppch.phoneno,'-','')::char(10) as home_phone --102
----------------------------------------
----- EMPLOYEE CONTACT INFORMATION -----
----------------------------------------  
,pa.streetaddress ::char(32) as addr1 --113
,pa.streetaddress2 ::char(32) as addr2 --145
,pa.city ::char(21) as city --177
,pa.stateprovincecode ::char(2) as state --193
,pa.postalcode ::char(5) as zip --200
,coalesce(substring(psl.pspay_stx_data,23,2),pa.stateprovincecode) ::char(2) as work_state --209
--------------------------------
----- EMPLOYEE INFORMATION -----
--------------------------------
,case when pte.taxfilingstatus in ('1', '9', '34' ) then 'M' --- 34 is Married but withhold at higher single rate
      when pte.taxfilingstatus in ('2') then 'S' else 'E' end ::char(1) as federal_marital_tax_code --224
,coalesce(lpad(pte.exemptions::char(2),2,'0'),'00') ::char(2) as number_of_federal_exemptions --225
,case when pe.emplstatus = 'L' then 'C' else pe.emplstatus end ::char(1) as work_status_code --227
,to_char(pe.effectivedate,'MMDDYYYY')::char(8) as work_status_asof_date --228

,case when pc.frequencycode <> 'H' then to_char(coalesce((pc.compamount * fc.annualfactor),0) * 100,'0000000000')
      else to_char(coalesce((pc.compamount * (ppos.scheduledhours * fcpos.annualfactor)),0) * 100,'0000000000') end ::char(11) as salary_amount --236 
,'Y' ::char(1) as md_salary_mode --245
,to_char(coalesce(pc.effectivedate,pe.effectivedate),'MMDDYYYY')::char(8) as salary_effectivedate --246

/* The number of hours the employee works in a single work week.   
Example:  40 hours would appear as 400 or 37 1/2 hours would appear as 375.  
The value in this field has to be "010" or greater ('000" will cause the record to fail).
*/

------ ppos.schedulefrequency returns only a value of 'S'
--,ppos.schedulefrequency
--,ppos.scheduledhours
,rpad((case when ppos.schedulefrequency = 'S' and ppos.scheduledhours > 40 then round((ppos.scheduledhours*24)/52)::text
            when ppos.scheduledhours = 0.00 then '010' 
            else round(ppos.scheduledhours)::text end),3,'0') ::char(3) as weekly_scheduled_work_hours --254
            
,'01' ::char(2) as work_week_schedule --257

----------------------------------------
----- EMPLOYER CONTACT INFORMATION -----
----------------------------------------

---------------------------------
----- SHORT TERM DISABILITY -----
---------------------------------

--------------------------------
----- LONG TERM DISABILITY -----
--------------------------------

---------------------------------
----- NY PAID FAMILY LEAVE ------
---------------------------------

---------------------
----- FMLA DATA -----
---------------------
,pe.emplclass ::char(1) as job_status_code --438
,to_char(pe.effectivedate,'MMDDYYYY')::char(8) as job_status_asof_date --439
/* Total Hours Worked in Prior 12 Month information is used to determine if the employee has worked a qualifying number of hours in the prior 12 months 
   immediately preceding the leave start date. This is required for TAM eligibility determination.
   It should not include such things as vacation or leave of absence time.
   the number should be right justified with a leading zero ie 703 hours is passed as 0703
*/
---- need to determine how to handle negative hours see personid in ('65809' and '66273')
--,pd.flsacode,nonexempt.reghours,exempt.reghours,exempt.total_hours
,lpad((round(coalesce(nonexempt.reghours,exempt.reghours,exempt.total_hours,0))::text),4,'0') as hrs_past_12m --450

--,to_char(yearlydte.check_date,'MMDDYYYY')::char(8) as start_date_past_12m --454
,to_char(pspdate.periodpaydate::DATE - interval '1 year','MMDDYYYY')::char(8) as start_date_past_12m --454
--,case when yearlydte.check_date is null then null else to_char(lastchk.last_check_date, 'MMDDYYYY') end ::char(8) as end_date_prior12m --462
,to_char(pspdate.periodpaydate::DATE,'MMDDYYYY')::char(8) as end_date_prior12m --462


------------------------------
----- ABSENCE MANAGEMENT -----
------------------------------
,'AM' ::char(2) as absence_mgmt_cvg --552
,to_char(greatest(pe.empllasthiredate::date,'2019-08-01'::date),'MMDDYYYY')::char(8) as absence_mgmt_cvg_start_date --554
----- note ba3 excludes terms absence_mgmt_cvg_stop_date --562 will never be populated
,case when pe.emplstatus in ('R','T')  then to_char(pe.effectivedate,'MMDDYYYY') else ' ' end ::char(8) as absence_mgmt_cvg_stop_date --562
,'0315980' ::char(7) as absence_mgmt_rpt_nbr --570
,'0001' ::char(4) as absence_mgmt_subcode --577
,'0001' ::char(4) as absence_mgmt_subpoint --581

,replace(ppcw.phoneno,'-','') ::char(10) as ee_work_phone --746

/*
Position 1062 Leave Absence Approver EE ID cross references to this field to populate the email address in MetLife's systems.
*/
,pncw.url ::char(40) as ee_work_email --777

----- pufv join - user defined value = 'Y' determines if ee was aquired with BCG aquisition or HMN ee

,case when pufv.ufvalue = 'Y' then 'HS1025' else 'HS1026' end ::char(6) as holiday_schedule --1014 HS1025 for BCG HS1026 for HMN
,sg.salarygradedesc
,case when pim.identity is null and sg.salarygradedesc = '00' then pi.identity else pim.identity end ::char(9) as approver_id1 --1062
--,pncmgr.url ::char(40) as approver_id1 --1062
,'APPROVER1' ::char(40) as approval_flow_type1 --1102
,'01' ::char(2) as approval_flow_level1 --1142
,elu.lastupdatets

from person_identity pi

left join edi.edi_last_update elu on elu.feedid = 'HMN_MetLife_DisabilityEligibility'

left join person_identity pie
  on pie.personid = pi.personid
 and pie.identitytype = 'EmpNo'
 and current_timestamp between pie.createts and pie.endts

left join person_identity pip
  on pip.personid = pi.personid
 and pip.identitytype = 'PSPID'
 and current_timestamp between pip.createts and pip.endts
 
left join (select periodstartdate, periodenddate, periodpaydate from pay_schedule_period) pspdate
  on pspdate.periodpaydate = ?::date
 
---- Note left future dated logic in place 
 
left join (select personid, emplevent, emplstatus, emplclass, emplpermanency, benefitstatus, emplhiredate, empllasthiredate, effectivedate, enddate, createts, endts, rank() over (partition by personid order by effectivedate , createts ) as rank  
             from person_employment where current_date between effectivedate and enddate and current_timestamp between createts and endts 
              --and emplstatus not in ('T','R','D','V','X') ---not sure if Termed and Retired should be excluded this was from BA3 column 562 is required for termed ee's
              ) pe on pe.personid = pi.personid and pe.rank = 1

left join (select personid, fname, lname, mname, nametype, effectivedate, enddate, createts, endts, rank() over (partition by personid order by effectivedate , createts ) as rank
             from person_names pn where (current_date between effectivedate and enddate or (effectivedate > current_date and enddate > effectivedate)) and current_timestamp between createts and endts  
              and nametype = 'Legal') pn on pn.personid = pi.personid and pn.rank = 1
          
left join (select personid, gendercode, birthdate, effectivedate, enddate, createts, endts, rank() over (partition by personid order by effectivedate , createts ) as rank
             from person_vitals where (current_date between effectivedate and enddate or (effectivedate > current_date and enddate > effectivedate)) and current_timestamp between createts and endts  
          ) pv on pv.personid = pi.personid and pv.rank = 1 

left join (select personid, maritalstatus, effectivedate, enddate, createts, endts, rank() over (partition by personid order by effectivedate , createts ) as rank
             from person_maritalstatus where (current_date between effectivedate and enddate or (effectivedate > current_date and enddate > effectivedate)) and current_timestamp between createts and endts  
          ) pm on pm.personid = pi.personid and pm.rank = 1

left join (select personid, phoneno, phonecontacttype, effectivedate, enddate, createts, endts, rank() over (partition by personid order by effectivedate , createts ) as rank
             from person_phone_contacts where (current_date between effectivedate and enddate or (effectivedate > current_date and enddate > effectivedate)) and current_timestamp between createts and endts  
              and phonecontacttype = 'Home') ppch on ppch.personid = pi.personid and ppch.rank = 1

left join (select personid, phoneno, phonecontacttype, effectivedate, enddate, createts, endts, rank() over (partition by personid order by effectivedate , createts ) as rank
             from person_phone_contacts where (current_date between effectivedate and enddate or (effectivedate > current_date and enddate > effectivedate)) and current_timestamp between createts and endts  
              and phonecontacttype = 'Work') ppcw on ppcw.personid = pi.personid and ppcw.rank = 1            

left join (select personid,addresstype,effectivedate,streetaddress,streetaddress2,city,stateprovincecode,postalcode,countrycode,privacycode,enddate,createts,endts,rank() over (partition by personid order by effectivedate , createts ) as rank
             from person_address where (current_date between effectivedate and enddate or (effectivedate > current_date and enddate > effectivedate)) and current_timestamp between createts and endts  
              and addresstype = 'Res') pa on pa.personid = pi.personid and pa.rank = 1

left join (select personid, url, enddate, max(effectivedate) as effectivedate, max(endts) as endts,  RANK() OVER (PARTITION BY personid ORDER BY max(endts) DESC) AS RANK
             from person_net_contacts where netcontacttype = 'WRK' and current_date between effectivedate and enddate and current_timestamp between createts and endts
            group by personid, url, enddate) pncw on pncw.personid = pi.personid and pncw.rank = 1
            
left join (select pph2.personid, pph2.individual_key, pph2.period_begin_date, pph2.period_end_date, state_code 
             from pspay_payment_header pph2
             join (select personid, max(check_date) as max_check_date from cognos_payment_earnings_by_check_date group by personid) as pmax2
               on pmax2.personid = pph2.personid and pmax2.max_check_date = pph2.check_date
            group by pph2.personid, pph2.individual_key, pph2.period_begin_date, pph2.period_end_date, state_code) pph on pph.personid = pi.personid


------ NOTE stx list may not be in winter ------

left join pspay_stx_list psl ON psl.pspay_stx_key = pph.state_code

left join person_tax_elections pte 
  on pte.personid = pi.personid 
 and pte.taxid in (select t.taxid from tax t where t.taxcode = 'FIT000') and (current_date between pte.effectivedate and pte.enddate or (pte.effectivedate > current_date and pte.enddate > pte.effectivedate))
 and current_timestamp between pte.createts and pte.endts 
 
left join pers_pos pp
  on pp.personid = pe.personid
 and current_date between pp.effectivedate and pp.enddate
 and current_timestamp between pp.createts and pp.endts

left join (select positionid, grade, positiontitle, flsacode, max(effectivedate) as effectivedate, RANK() OVER (PARTITION BY positionid ORDER BY max(effectivedate) DESC) AS RANK
             from position_desc where effectivedate < enddate and current_timestamp between createts and endts 
            group by positionid, grade, positiontitle, flsacode) pd on pd.positionid = pp.positionid and pd.rank = 1         

left join (select personid, compamount, increaseamount, compevent, frequencycode, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate, RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_compensation where earningscode in ('Regular','RegHrly','ExcHrly')
              and current_timestamp between createts and endts and (current_date between effectivedate and enddate or (effectivedate > current_date and enddate > effectivedate))
            group by personid, compamount, increaseamount, compevent, frequencycode ) as pc on pc.personid = pe.personid and pc.rank = 1  
left join frequency_codes fc on fc.frequencycode = pc.frequencycode

left join  (select personid, positionid, scheduledhours, schedulefrequency, max(effectivedate) as effectivedate, RANK() OVER (PARTITION BY personid ORDER BY max(effectivedate) DESC) AS RANK
             from pers_pos where (current_date between effectivedate and enddate or (effectivedate > current_date and enddate > effectivedate)) and current_timestamp between createts and endts
            group by personid, positionid, scheduledhours, schedulefrequency) ppos on ppos.personid = pe.personid and ppos.rank = 1 

left join frequency_codes fcpos on fcpos.frequencycode = ppos.schedulefrequency
---- hours should not include such things as vacation or leave of absence time ('E15','E16','E17','E18','E19','E20')
---- select * from pspay_etv_list where etv_id in ('E15','E16','E17','E18','E19','E20');
---- select * from pspay_etv_operators where operand = 'WS01';
---- not sure if WS01 is correct since operand includes these etv id which should be excluded ('E15','E16','E17','E18','E19','E20')  

left join (select ppd.personid,sum(ppd.etype_hours) as reghours
             from pay_schedule_period psp 
             join pspay_payment_header pph on pph.check_date = psp.periodpaydate and pph.payscheduleperiodid = psp.payscheduleperiodid  
             join pspay_payment_detail ppd on ppd.etv_id IN ('E01','E02') and ppd.personid = pph.personid and ppd.check_date = psp.periodpaydate and pph.paymentheaderid = ppd.paymentheaderid  	                
            where psp.payrolltypeid in (1,2) and psp.periodpaydate between ?::date - interval '1 year' and ?::date
            group by 1 having sum(ppd.etype_hours) > 0) nonexempt on nonexempt.personid = pi.personid and pd.flsacode <> 'E' ----- 9/6/19 added exempt check to join filter
   
----------------------------------------------------------------
----- TOTAL HOURS WORKED IN PAST 12 MONTHS FOR EXEMPT EE'S -----
----------------------------------------------------------------         
left join (select distinct a.personid,pto.takehours,sum(a.total_hours) as total_hours,cast(sum(a.total_hours) - pto.takehours as dec(18,2)) as reghours
             from (select distinct  pe.personid
                         ,case when pe.emplstatus in ('P','L') then extract (days from (least(pe.enddate,current_date)) - (greatest(pe.effectivedate - interval '1 day' ,current_date - interval '1 year'))) else null end as leave_days  
                         ,case when pe.emplstatus = 'A' then extract (days from (least(pe.enddate,current_date)) - (greatest(pe.effectivedate - interval '1 day' ,current_date - interval '1 year'))) else 0 end as active_days  
                         ,case when pe.enddate > current_date then extract(days from current_date::date - greatest(pe.effectivedate,current_date::date - interval '1 year'))+1
                               when pe.effectivedate > (current_date::date - interval '1 year') and pe.enddate < current_date::date then  pe.enddate - pe.effectivedate+1
                               else extract(days from least(pe.enddate,current_date::date) - (current_date::date - interval '1 year')) end as numdays   
                         ,cast(fc.annualfactor * pp.scheduledhours * 
                              ((case when pe.enddate > current_date then extract(days from current_date::date - greatest(pe.effectivedate ,current_date::date - interval '1 year'))+1 
                                     when pe.effectivedate > (current_date::date - interval '1 year') and pe.enddate < current_date::date then  pe.enddate - pe.effectivedate + 1
                                     else extract(days from least(pe.enddate,current_date::date) - (current_date::date - interval '1 year')) end ) /365::numeric) as dec(18,2)) as total_hours
                      from person_employment pe
                      left join pers_pos pp on pe.personid = pp.personid and current_timestamp between pp.createts and pp.endts and pp.effectivedate < pp.enddate and (pp.effectivedate, pp.enddate) overlaps (pe.effectivedate, pe.enddate)
                      left join person_payroll ppl on ppl.personid = pe.personid and current_date between ppl.effectivedate and ppl.enddate and current_timestamp between ppl.createts and ppl.endts
                      left join pay_unit pu on pu.payunitid = ppl.payunitid
                      left join frequency_codes fc on fc.frequencycode = pu.frequencycode  
                     where current_timestamp between pe.createts and pe.endts and (pe.effectivedate, pe.enddate) overlaps (current_date::date, current_date::date - interval '1 year' ) and pe.effectivedate < pe.enddate and pe.emplstatus = 'A'
                   ) a
            left join (select distinct personid, sum(takehours) as takehours from person_pto_activity_request 
                where ((effectivedate, enddate) overlaps (current_date::date , current_date::date - interval '1 year' )) and reasoncode = 'REQ'
                  and effectivedate >= current_date - interval '1 year' and current_timestamp between createts and endts and effectivedate < enddate group by 1)
               pto on pto.personid = a.personid
           group by 1,2) exempt on exempt.personid = pi.personid and pd.flsacode = 'E'        ----- 9/6/19 added exempt check to join filter
----------------------------------------------------------------
----------------------------------------------------------------
----------------------------------------------------------------
left join (select ppdx.personid, min(ppdx.check_date) check_date from pspay_payment_detail ppdx 
             left JOIN (select substring(individual_key,1,5) as paygroup, max(check_date) as last_check_date 
                          from pspay_payment_header group by 1) lastchk2 ON  lastchk2.paygroup = substring(ppdx.individual_key,1,5)
	                 where ppdx.etv_id IN ('E01','E02')
	          	   and ppdx.check_number <> 'INIT REC'
		           and ppdx.check_date between current_date - interval '12 months' and lastchk2.last_check_date
	       group by ppdx.personid order by 1) yearlydte on yearlydte.personid = pi.personid	  
	        
left join (select substring(individual_key,1,5) as paygroup, ?::DATE as last_check_date from pspay_payment_header group by 1) lastchk ON lastchk.paygroup = substring(pip.identity,1,5)	                    

-- BCG - HMN's latest aquisition identified by udf field
left join person_user_field_vals pufv
  on pufv.personid = pi.personid
 and current_date between pufv.effectivedate and pufv.enddate
 and current_timestamp between pufv.createts and pufv.endts
 and pufv.ufid = (select ufid from user_field_desc where ufname = 'BCG1' and current_date between effectivedate and enddate and current_timestamp between createts and endts)
--------------------------------
----- MANAGERS INFORMATION -----
-------------------------------- 
left join salary_grade sg
  on sg.grade = pd.grade
 and current_date between sg.effectivedate and sg.enddate
 and current_timestamp between sg.createts and sg.endts  
 
left join pos_pos popos 
  on popos.topositionid = ppos.positionid and popos.posposrel = 'Manages'
 and current_date between popos.effectivedate and popos.enddate
 and current_timestamp between popos.createts and popos.endts

left join pers_pos perp
  on perp.positionid = popos.positionid
 and (current_date between perp.effectivedate and perp.enddate or (perp.effectivedate > current_date and perp.enddate > perp.effectivedate))
 and current_timestamp between perp.createts and perp.endts 
 
left join person_identity pim
  on pim.personid = perp.personid 
 and pim.identitytype = 'SSN'
 and current_timestamp between pim.createts and pim.endts 

left join dxpersonpositiondet xppd
  on xppd.personid = pe.personid
 and current_date between xppd.effectivedate and xppd.enddate
 and current_timestamp between xppd.createts and xppd.endts 

where pi.identitytype = 'SSN'
  and pd.positiontitle not in ('Agent','Intern-Tp','Intern             -Tp','Intern - BCG','Intern -TP','Intern -Tp')
  and ((current_timestamp between pi.createts and pi.endts
  and pe.emplstatus not in ('T','R','D','V','X')  ---not sure if Termed and Retired should be excluded this was from BA3
  ---- exclude all termed prior 8/1/2019
  and pe.emplclass  not in ('T')) --- temporary ee's 
  ----- Terms should be processed once then fall off from next file
   or ((pe.emplstatus in ('T','R','D','V','X')  and  (pe.effectivedate >= elu.lastupdatets::DATE or (pe.createts > elu.lastupdatets and pe.effectivedate < coalesce(elu.lastupdatets, '2017-01-01')) )) ))
   

   --having coalesce(nonexempt.reghours,exempt.reghours,exempt.total_hours,0) <> 0
 
 --and pe.personid in ('66026','63249','63632','63694','63743', '66578')


