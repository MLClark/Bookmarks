select distinct

 'BENEFIT' ::char(6) as BENEFIT
,pgd.deduction_desc ::varchar(30) as DSCRIPTN
,null as inactive
,to_char(bbd.effectivedate,'MMDDYYYY')::char(8) as BNFBEGDT
,null as BNFENDDT
,null as VARBENFT
,null as BNFTFREQ
,null as SBJTFDTX
,null as SBJTSSEC
,null as SBJTMCAR
,null as SBJTSTTX
,null as SBJTLTAX
,null as SBJTFUTA
,null as SBJTSUTA
,null as FFEDTXRT
,null as FLSTTXRT
,null as BORCDTYP
,null as BSDORCDS

,pgd.etv_id ::char(3) as BSDONCDE -- pay code or deduction code 

,null as BNFTMTHD
,null as BNFFRMLA
,null as BNFPRCNT_1
,null as BNFPRCNT_2
,null as BNFPRCNT_3
,null as BNFPRCNT_4
,null as BNFPRCNT_5
,null as BNFITAMT_1
,null as BNFITAMT_2
,null as BNFITAMT_3
,null as BNFITAMT_4
,null as BNFITAMT_5
,null as BNFTRMAX_1
,null as BNFTRMAX_2
,null as BNFTRMAX_3
,null as BNFTRMAX_4
,null as BNFTRMAX_5
,null as BNTRMXUN_1
,null as BNTRMXUN_2
,null as BNTRMXUN_3
,null as BNTRMXUN_4
,null as BNTRMXUN_5
,null as BNPAYPMX
,null as BNFYRMAX
,null as Benefit_Fiscal_Max
,null as BNFLFMAX
,null as W2BXNMBR
,null as W2BXLABL
,null as W2BXNMBR2
,null as W2BXLABL2
,null as W2BXNMBR3
,null as W2BXLABL3
,null as W2BXNMBR4
,null as W2BXLABL4
,null as DATAENTDFLT
,null as UpdateIfExists
,null as RequesterTrx
,null as USRDEFND1
,null as USRDEFND2
,null as USRDEFND3
,null as USRDEFND4
,null as USRDEFND5


from pspay_group_deductions pgd
join pspay_benefit_mapping pbm
  on substring(pbm.eeperpayamtcode,3,2) = substring(pgd.etv_id,2,2) 
 --and pbm.taxable = 'Y'
join (select benefitsubclass,min(effectivedate) effectivedate
        from benefit_plan_desc 
        where current_date between effectivedate and enddate
          and current_timestamp between createts and endts
        group by 1) bbd on bbd.benefitsubclass = pbm.benefitsubclass  
where group_key <> '$$$$$' 
  and deduction_name <> 'Reserved'
  and deduction_name <> '' 
  and current_timestamp between createts and endts
  and group_key in ('AYV20','AYV25')
  and etv_id not like 'T%' 
  
  order by 2,3
  ;
  

