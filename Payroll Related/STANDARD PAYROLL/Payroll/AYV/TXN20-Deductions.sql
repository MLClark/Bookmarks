
select distinct
---- deductions
 bd.personid 
,2 as seqnbr 
,bh.batchheaderid ::varchar(15) as BACHNUMB
,pie.identity ::varchar(15) as EMPLOYID
,'3' ::char(1) as COMPTRTP
,0 as SALCHG
--,case when bd.etv_id = 'E01' and pc.frequencycode = 'H' then bd.etv_id || 'H' 
--      when bd.etv_id = 'E01' and pc.frequencycode = 'A' then bd.etv_id || 'S' else bd.etv_id end ::char(6) as UPRTRXCD
--,pbmy.eeperpayamtcode
--,pbmn.eeperpayamtcode
--,pbmnl.eeperpayamtcode
,pbe.benefitsubclass
,'V' || substring(coalesce(pbmy.eeperpayamtcode,pbmn.eeperpayamtcode,pbmnl.eeperpayamtcode) from 3 for 2) ::char(6) as UPRTRXCD
,to_char(psp.periodstartdate,'yyyymmdd') ::char(8) as TRXBEGDT ---Transaction begin date
,to_char(psp.periodenddate,'yyyymmdd') ::char(8) as TRXENDDT ---Transaction end date
,0 as TRXHRUNT 
,0 as HRLYPYRT    
,0 as PAYRTAMT
,round(poc.employeerate::numeric, 2) as VARDBAMT -----Variable deduction/benefit amount
,0 as VARDBPCT -----Variable deduction/benefit percent
,0 as RECEIPTS -----Receipts
,0 as DAYSWRDK -----Days worked
,0 as WKSWRKD -----Weeks worked
,split_part(ocd.orgcode, '-' ,1) ::char(6) as DEPRTMNT
,pos_d.positionxid ::char(6) as JOBTITLE   
,la.stateprovincecode ::char(2) as STATECD -----State code
,0 as LOCALTAX -----Local tax
,la.stateprovincecode ::char(2) as SUTASTAT -----SUTA state
,pd.workerscompcode as WRKRCOMP -----Workers' compensation code
,pd.shiftcode ::char(1) as SHFTCODE -----Shift code
,case when bd.etv_id in ('E05','E06','E07') 
      then bd.amount else null end ::varchar(21) as SHFTPREM -----Shift premium
,0 as RequesterTrx
,' '  ::varchar(21) as USERID
,' '  ::varchar(21) as USRDEFND1
,' '  ::varchar(21) as USRDEFND2
,' '  ::varchar(21) as USRDEFND3
,' '  ::varchar(21) as USRDEFND4
,' '  ::varchar(21) as USRDEFND5      
      
from batch_header bh 

JOIN pay_schedule_period psp 
  ON psp.payscheduleperiodid = bh.payscheduleperiodid
 and psp.periodpaydate = ?::date
 and psp.payunitid in ('8')

JOIN batch_detail bd 
  ON bd.batchheaderid = bh.batchheaderid 
 AND current_date between bd.effectivedate and bd.enddate 
 AND current_timestamp between bd.createts AND bd.endts

join person_identity pie
  on pie.personid = bd.personid
 and pie.identitytype = 'EmpNo'
 and current_timestamp between pie.createts and pie.endts

left join person_bene_election pbe
  on pbe.personid = pie.personid
 and current_date between pbe.effectivedate and pbe.enddate
 and current_timestamp between pbe.createts and pbe.endts
 and pbe.selectedoption = 'Y'
 and pbe.benefitelection = 'E'

left join pspay_benefit_mapping pbmy
  on pbmy.benefitsubclass = pbe.benefitsubclass
 and pbmy.taxable = 'Y' 
left join pspay_benefit_mapping pbmn
  on pbmn.benefitsubclass = pbe.benefitsubclass
 and pbmn.taxable = 'Y'  
 left join pspay_benefit_mapping pbmnl
  on pbmnl.benefitsubclass = pbe.benefitsubclass
 and pbmnl.taxable is null
 
JOIN person_compensation pc 
  ON pc.personid = bd.personid 
 and current_date between pc.effectivedate and pc.enddate
 AND current_timestamp between pc.createts AND pc.endts 
 AND (pc.earningscode = ANY (ARRAY['Regular'::bpchar, 'RegHrly'::bpchar, 'ExcHrly'::bpchar])) 

JOIN pers_pos pp 
  ON pp.personid = pie.personid 
 and current_date between pp.effectivedate and pp.enddate  
 AND current_timestamp between pp.createts AND pp.endts 
 AND pp.persposrel = 'Occupies'::bpchar 

left join personbenoptioncostl poc 
  on poc.personid = pbe.personid
 and poc.personbeneelectionpid = pbe.personbeneelectionpid
 and poc.costsby = 'P'
 
left join pos_org_rel por
  on por.positionid = pp.positionid
 and current_date between por.effectivedate and por.enddate
 and current_timestamp between por.createts and por.endts

left join organization_code ocd
  on ocd.organizationid = por.organizationid
 and current_date between ocd.effectivedate and ocd.enddate 
 and current_timestamp between ocd.createts and ocd.endts

left join position_desc pos_d
  on pos_d.positionid = pp.positionid
 and current_date between pos_d.effectivedate and pos_d.enddate
 and current_timestamp between pos_d.createts and pos_d.endts
 
left join person_locations pl
  on pl.personid = pie.personid
 and current_date between pl.effectivedate and pl.enddate
 and current_timestamp between pl.createts and pl.endts

left join location_address la
  on la.locationid = pl.locationid
 and current_date between la.effectivedate and la.enddate
 and current_timestamp between la.createts and la.endts  

JOIN position_desc pd 
  ON pd.positionid = pp.positionid 
 and current_date between pd.effectivedate and pd.enddate
 AND current_timestamp between pd.createts AND pd.endts 
 
where current_date between bh.effectivedate and bh.enddate 
  and current_timestamp between bh.createts AND bh.endts  
   and pie.personid = '6138'
  order by 3