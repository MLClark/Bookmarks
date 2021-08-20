select distinct
pi.personid,
'INGWIN6' as RecType,
'775223' as PlanId,
'5' as PayCycle
,to_char(ppd.check_date,'YYYYMMDD')::char(10) as CheckDate
,'401K' as IRSCode
,replace(pi.identity,'-','') ::char(11) as ssn 
,pie.identity as EmpNo
,' ' as DeptCode
,'1' as LocCode
,ltrim(pne.lname,' ') ::varchar(20) as LName
,ltrim(pne.fname,' ') ::varchar(35) as FName
,ltrim(pne.mname,' ') ::varchar(1) as MName
,replace(pae.streetaddress,',',' ') ::varchar(30) as Addr1
,replace(pae.streetaddress2,',',' ') ::varchar(30) as Addr2
,ltrim(pae.city,' ') ::varchar(25) as City
,pae.stateprovincecode ::char(2) as State
,ltrim(pae.postalcode,' ') ::varchar(10) as Zip
,' ' as ZipExtn
,pv.gendercode ::char(1) as Gender
,' ' as Resv1
,case when pm.maritalstatus = 'R' then 'M' 
      else coalesce(pm.maritalstatus,'S') end ::char(1) as maritalstatus

,pe.EmplStatus as EmpStatus
,to_char(pve.birthdate,'YYYYMMDD')::char(10) as dob 
,to_char(pe.emplhiredate,'YYYYMMDD')::char(10) as doh

,case when pe.emplstatus = 'T' then to_char(pe.enddate,'YYYYMMDD') 
      when pe.emplstatus = 'A' and pe.empllasthiredate > pe.emplhiredate THEN TO_CHAR(pe_term.enddate,'YYYYMMDD')
      else ' ' end ::char(10) as termdate
,case when pe.empllasthiredate > pe.emplhiredate then to_char(pe.empllasthiredate,'YYYYMMDD') else ' ' end ::char(10) as rehiredate 


,case when pe.emplstatus in ('L','P') then to_char(pe.effectivedate,'YYYYMMDD') 
       else ' ' end ::char(10) as LOAStartDate 

,case when pe.emplstatus in ('L','P') then to_char(pe.enddate,'YYYYMMDD') 
            else ' ' end ::char(10) as LOAEndDate


,CASE WHEN ytdcomp.ytdhours > 0 then ytdcomp.ytdhours
     ELSE salhrs.ytdhrs END as ytdhours

,curcomp.curhours as PayPeriodHours

,'' as AnnivHours



,CASE WHEN (COALESCE(ppdvb1.etv_amount,0) + COALESCE(ppdvb2.etv_amount,0)) > 0 THEN 'A' ELSE ' ' END ::char(5) as SC1
,COALESCE(ppdvb1.etv_amount,0) + COALESCE(ppdvb2.etv_amount,0) as ContribAmt1


,CASE WHEN COALESCE(ppdvb5.etv_amount,0) > 0 THEN 'D' ELSE ' ' END ::char(5) as SC2
,COALESCE(ppdvb5.etv_amount,0) as ContribAmt2

,CASE WHEN (COALESCE(ppdvb3.etv_amount,0) + COALESCE(ppdvb4.etv_amount,0)) > 0 THEN 'G' ELSE ' ' END ::char(5) as SC3
,COALESCE(ppdvb3.etv_amount,0) + COALESCE(ppdvb4.etv_amount,0) as ContribAmt3

,' ' as SC4
,' ' as ContribAmt4

,' ' as SC5
,' ' as ContribAmt5

,' ' as SC5
,' ' as ContribAmt5

,CASE WHEN COALESCE(ppdv65.etv_amount,0) > 0 THEN '001' ELSE ' ' END ::char(5) as Loan1
,COALESCE(ppdv65.etv_amount,0) as LoanAmt1

,CASE WHEN COALESCE(ppdvci.etv_amount,0) > 0 THEN '002' ELSE ' ' END ::char(5) as Loan2
,COALESCE(ppdvci.etv_amount,0) as LoanAmt1

,' ' as Loan3
,' ' as LoanAmt3

,' ' as Loan4
,' ' as LoanAmt4

,' ' as Loan5
,' ' as LoanAmt5

,' ' as Loan6
,' ' as LoanAmt6

,' ' as UnionMem

,'Y' as EmpElig

,' ' as Resv2
,' ' as YTDGrossComp

,' ' as Resv3
,' ' as YTDTestComp
,' ' as YTDAllocBenComp

,' ' as Resv4
,' ' as AnnSal
,' ' as MiscComp

,' ' as Resv5
,' ' as Resv6

,' ' as KeyEE

,' ' as Resv7
,' ' as Resv8


,' ' as HighcompEE
,' ' as NonResAlien


,' ' as Resv9
,pncw.url::varchar(100) as email

 
,' ' as TierGroup
,' ' as ClientData1
,' ' as ClientDate1

,' ' as Filler


 
from person_identity pi

left join person_identity pie
  on pie.personid = pi.personid
 and pie.identitytype = 'EmpNo'
 and current_timestamp between pie.createts and pie.endts
 
left join person_identity pip
  on pip.personid = pi.personid
 and pip.identitytype = 'PSPID'
 and current_timestamp between pip.createts and pip.endts 
 
left join person_compensation pc
  on pc.personid = pi.personid 
 and current_date between pc.effectivedate and pc.enddate
 and current_timestamp between pc.createts and pc.endts 
 

left join person_vitals pv
  on pv.personid = pi.personid
 and current_date between pv.effectivedate and pv.enddate
 and current_timestamp between pv.createts and pv.endts
 
left join person_maritalstatus pm
  on pm.personid = pi.personid
 and current_date between pm.effectivedate and pm.enddate
 and current_timestamp between pm.createts and pm.endts 
 
LEFT JOIN person_net_contacts pncw 
  ON pncw.personid = pi.personid 
 AND pncw.netcontacttype = 'WRK'::bpchar 
 AND current_date between pncw.effectivedate and pncw.enddate
 AND current_timestamp between pncw.createts and pncw.endts 
 
left JOIN person_phone_contacts ppch 
  ON ppch.personid = pi.personid
 AND current_date between ppch.effectivedate and ppch.enddate
 AND current_timestamp between ppch.createts and ppch.endts 
 AND ppch.phonecontacttype = 'Home'
left JOIN person_phone_contacts ppcw 
  ON ppcw.personid = pi.personid
 AND current_date between ppcw.effectivedate and ppcw.enddate
 AND current_timestamp between ppcw.createts and ppcw.endts 
 AND ppcw.phonecontacttype = 'Work'   
left JOIN person_phone_contacts ppcb 
  ON ppcb.personid = pi.personid
 AND current_date between ppcb.effectivedate and ppcb.enddate
 AND current_timestamp between ppcb.createts and ppcb.endts 
 AND ppcb.phonecontacttype = 'BUSN'      
left JOIN person_phone_contacts ppcm 
  ON ppcm.personid = pi.personid
 AND current_date between ppcm.effectivedate and ppcm.enddate
 AND current_timestamp between ppcm.createts and ppcm.endts 
 AND ppcm.phonecontacttype = 'Mobile'  
  
left join dxpersonposition div
  on div.personid = pi.personid  

left join pspay_payment_header pph
  on pph.personid = pi.personid
 AND pph.check_date  =  ?::DATE
 and pph.individual_key = piP.identity 
 
 join pspay_payment_detail ppd
  on ppd.etv_id IN ('VB1','VB2','VB3','VB4','VB5','V25','V65', 'VCQ', 'VCI')
 AND ppd.check_date =   ?::DATE
 and ppd.individual_key = piP.identity
 
-- Pre Taxed 401(k)                             
LEFT JOIN (SELECT personid
                 ,sum(etv_amount) as etv_amount
             FROM pspay_payment_detail            
            WHERE etv_id in  ('VB1')    
              and check_date = ?::DATE       
         GROUP BY personid
          ) ppdvb1
  ON ppdvb1.personid  = ppd.personid
-- Pre Taxed 401(k) Catch Up  
LEFT JOIN (SELECT personid
                 ,sum(etv_amount) as etv_amount
             FROM pspay_payment_detail            
            WHERE etv_id in  ('VB2')    
              and check_date = ?::DATE       
         GROUP BY personid
          ) ppdvb2
  ON ppdvb2.personid  = ppd.personid
-- roth
LEFT JOIN (SELECT personid
                 ,sum(etv_amount) as etv_amount
             FROM pspay_payment_detail            
            WHERE etv_id in  ('VB3')    
              and check_date = ?::DATE       
         GROUP BY personid
          ) ppdvb3
  ON ppdvb3.personid  = ppd.personid
-- Roth Catch Up                                
LEFT JOIN (SELECT personid
                 ,sum(etv_amount) as etv_amount
             FROM pspay_payment_detail            
            WHERE etv_id in  ('VB4')    
              and check_date = ?::DATE       
         GROUP BY personid
          ) ppdvb4
  ON ppdvb4.personid  = ppd.personid
-- 401KCMAE
LEFT JOIN (SELECT personid
                 ,sum(etv_amount) as etv_amount
             FROM pspay_payment_detail            
            WHERE etv_id in  ('VB5')    
              and check_date = ?::DATE       
         GROUP BY personid
          ) ppdvb5
  ON ppdvb5.personid  = ppd.personid

LEFT JOIN (SELECT personid
                 ,sum(etv_amount) as etv_amount
             FROM pspay_payment_detail            
            WHERE etv_id in  ('V65')    
              and check_date = ?::DATE       
         GROUP BY personid
          ) ppdv65
  ON ppdv65.personid  = ppd.personid
-- loan 2
left JOIN (SELECT personid
                 ,sum(etv_amount) as etv_amount
             FROM pspay_payment_detail            
            WHERE etv_id in  ('VCI')    
              and check_date = ?::DATE       
         GROUP BY personid
          ) ppdvci
  ON ppdvci.personid  = ppd.personid

 
-- ee total hours 
-- ee total gross based on federal tax

JOIN (SELECT individual_key
                 ,sum(etype_hours) AS curhours
                 ,sum(etv_amount) as curtaxable_wage
             FROM pspay_payment_detail            
             -- Hours include Reg,OT,DT,PTO,Jury,Bereavement - exclude reg shift and OT shift
             -- 6/16 feedback need holiday pay included in ytd totals adding ECZ, EC8, E17
            WHERE etv_id in (select a.etv_id 
                             from pspay_etv_operators a
                             join pspay_etv_list b 
                               on a.etv_id = b.etv_id
                              and a.group_key = b.group_key
                            where a.operand = 'WS15' and a.etvindicator = 'E' group by 1)          
              AND date_part('year', check_date) = date_part('year',?::DATE)
              AND check_date  = ?::DATE
         GROUP BY individual_key
          ) curcomp
  ON curcomp.individual_key = piP.identity  


JOIN (SELECT individual_key
                 ,sum(etype_hours) AS ytdhours
                 ,sum(etv_amount) as taxable_wage
             FROM pspay_payment_detail            
             -- Hours include Reg,OT,DT,PTO,Jury,Bereavement - exclude reg shift and OT shift
             -- 6/16 feedback need holiday pay included in ytd totals adding ECZ, EC8, E17
            WHERE etv_id in (select a.etv_id 
                             from pspay_etv_operators a
                             join pspay_etv_list b 
                               on a.etv_id = b.etv_id
                              and a.group_key = b.group_key
                            where a.operand = 'WS15' and a.etvindicator = 'E' group by 1)          
              AND date_part('year', check_date) = date_part('year',?::DATE)
              AND check_date  <= ?::DATE
         GROUP BY individual_key
          ) ytdcomp
  ON ytdcomp.individual_key = piP.identity 
 
LEFT JOIN (select pp.personid, pp.scheduledhours, coalesce(payper.num_payperiods, 0::integer) as num_pp, pp.scheduledhours * coalesce(payper.num_payperiods, 0::integer) as ytdhrs
		 from pers_pos pp
		left join
		(select personid, count(*) as num_payperiods
		from pspay_payment_header 
		where  record_stat = 'A' and check_date >= date_trunc('year', now()) 
		group by personid order by personid) payper on payper.personid = pp.personid
		where current_date between effectivedate and enddate
		and current_timestamp between createts and endts) as salhrs on salhrs.personid = pi.personid

join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts 
 
left join person_employment pe_term
  on pe_term.personid = pi.personid
 and pe_term.enddate <> '2199-12-31'
 and pe_term.emplstatus = 'T'
 and current_timestamp between pe_term.createts and pe_term.endts  
 
join person_vitals pve
  on pve.personid = pi.personid
 and current_date between pve.effectivedate and pve.enddate
 and current_timestamp between pve.createts and pve.endts  
 
join person_names pne
  on pne.personid = pi.personid
 and pne.nametype = 'Legal'
 and current_date between pne.effectivedate and pne.enddate
 and current_timestamp between pne.createts and pne.endts
  
join person_address pae 
  on pae.personid = pi.personid
 and pae.addresstype = 'Res' 
 and current_date between pae.effectivedate and pae.enddate
 and current_timestamp between pae.createts and pae.endts 
 
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  order by lname
  --and pi.personid = '1784'