
with suborg as 

(
select distinct
 cor.organizationid      
,oc.organizationdesc     
,oc.orgcode             
,oc.organizationtype   
,oc.organizationevent  
,oc.effectivedate       
,oc.enddate     
,orel.memberoforgid         

,oc2.organizationid    as organizationid2
,oc2.organizationdesc  as organizationdesc2     
,oc2.orgcode           as orgcode2           
,oc2.organizationtype  as organizationtype2
,oc2.organizationevent as organizationevent2 
,oc2.effectivedate     as effectivedate2  
,oc2.enddate           as enddate2
,orel2.memberoforgid   as memberoforgid2   

,oc3.organizationid    as organizationid3
,oc3.organizationdesc  as organizationdesc3   
,oc3.orgcode           as orgcode3          
,oc3.organizationtype  as organizationtype3
,oc3.organizationevent as organizationevent3
,oc3.effectivedate     as effectivedate3
,oc3.enddate           as enddate3
,orel3.memberoforgid   as memberoforgid3  

,oc4.organizationid    as organizationid4
,oc4.organizationdesc  as organizationdesc4     
,oc4.orgcode           as orgcode4           
,oc4.organizationtype  as organizationtype4
,oc4.organizationevent as organizationevent4 
,oc4.effectivedate     as effectivedate4 
,oc4.enddate           as enddate4


from company_organization_rel cor

join organization_code oc 
  on oc.organizationid = cor.organizationid
 and current_date between oc.effectivedate and oc.enddate
 and current_timestamp between oc.createts and oc.endts 

left join org_rel orel 
  on orel.memberoforgid = oc.organizationid
 and current_date between orel.effectivedate and orel.enddate
 and current_timestamp between orel.createts and orel.endts

left join organization_code oc2
  on oc2.organizationid = orel.organizationid
 and current_date between oc2.effectivedate and oc2.enddate
 and current_timestamp between oc2.createts and oc2.endts  

left join org_rel orel2
  on orel2.memberoforgid = oc2.organizationid
 and current_date between orel2.effectivedate and orel2.enddate
 and current_timestamp between orel2.createts and orel2.endts 
 
left join organization_code oc3
  on oc3.organizationid = orel2.organizationid
 and current_date between oc3.effectivedate and oc3.enddate
 and current_timestamp between oc3.createts and oc3.endts 

left join org_rel orel3
  on orel3.memberoforgid = oc3.organizationid
 and current_date between orel3.effectivedate and orel3.enddate
 and current_timestamp between orel3.createts and orel3.endts  

left join organization_code oc4
  on oc4.organizationid = orel3.organizationid
 and current_date between oc4.effectivedate and oc4.enddate
 and current_timestamp between oc4.createts and oc4.endts 
 
where current_date between cor.effectivedate and cor.enddate
  and current_timestamp between cor.createts and cor.endts
  
  order by 1
  )  
select distinct

 suborg.organizationid as org1id
,suborg.organizationdesc as org1desc
,suborg.orgcode as org1code
,suborg.organizationtype as org1type
,suborg.effectivedate as org1effdt
,suborg.enddate as org1enddt
 
,null::int as org2id
,null as org2desc
,null as org2code
,null as org2type
,null::date as org2effdt
,null::date as org2enddt

,null::int as org3id
,null as org3desc
,null as org3code
,null as org3type
,null::date as org3effdt
,null::date as org3enddt

,null::int as org4id
,null as org4desc
,null as org4code
,null as org4type
,null::date as org4effdt
,null::date as org4enddt

, '1' as qsource

from suborg  
where suborg.memberoforgid is null
  --- using this sub select to only pull highest org level - usually div or cost centers
  and suborg.organizationid not in (select organizationid from org_rel where current_date between effectivedate and enddate and current_timestamp between createts and endts group by 1)

union  
  
select distinct
  -- this is for level 1 and level 2 only 
 case when suborg.organizationid2 is not null then suborg.organizationid2 else suborg.organizationid end as org1id
,case when suborg.organizationdesc2 is not null then suborg.organizationdesc2 else suborg.organizationdesc end as org1desc
,case when suborg.orgcode2 is not null then suborg.orgcode2 else suborg.orgcode end as org1code
,case when suborg.organizationtype2 is not null then suborg.organizationtype2 else suborg.organizationtype end as org1type
,case when suborg.effectivedate2 is not null then suborg.effectivedate2 else suborg.effectivedate end as org1effdt
,case when suborg.enddate2 is not null then suborg.enddate2 else suborg.enddate end as org1enddt
 
,case when suborg.organizationid2 is not null then suborg.organizationid else null::int end as org2id
,case when suborg.organizationdesc2 is not null then suborg.organizationdesc else null end as org2desc
,case when suborg.orgcode2 is not null then suborg.orgcode else null end as org2code
,case when suborg.organizationtype2 is not null then suborg.organizationtype else null end as org2type
,case when suborg.effectivedate2 is not null then suborg.effectivedate else null::date end as org2effdt
,case when suborg.enddate2 is not null then suborg.enddate else null::date end as org2enddt

,null::int as org3id
,null as org3desc
,null as org3code
,null as org3type
,null::date as org3effdt
,null::date as org3enddt

,null::int as org4id
,null as org4desc
,null as org4code
,null as org4type
,null::date as org4effdt
,null::date as org4enddt

, '2' as qsource

from suborg  
where suborg.memberoforgid is not null and suborg.memberoforgid = suborg.organizationid
  and suborg.memberoforgid2 is null and suborg.memberoforgid3 is null  
  
  and suborg.organizationid not in (select organizationid from org_rel where current_date between effectivedate and enddate and current_timestamp between createts and endts group by 1) 

union

select distinct
 -- 3 tier levels  
 case when suborg.organizationid3 is not null then suborg.organizationid3 else suborg.organizationid2 end as org1id
,case when suborg.organizationid3 is not null then suborg.organizationdesc3 else suborg.organizationdesc2  end as org1desc
,case when suborg.organizationid3 is not null then suborg.orgcode3 else suborg.orgcode2 end as org1code
,case when suborg.organizationid3 is not null then suborg.organizationtype3 else suborg.organizationtype2 end as org1type
,case when suborg.organizationid3 is not null then suborg.effectivedate3 else suborg.effectivedate2 end as org1effdt
,case when suborg.organizationid3 is not null then suborg.enddate3 else suborg.enddate3 end as org1enddt
 
,case when suborg.organizationid3 is not null then suborg.organizationid2 else suborg.organizationid end as org2id
,case when suborg.organizationid3 is not null then suborg.organizationdesc2 else suborg.organizationdesc end as org2desc
,case when suborg.organizationid3 is not null then suborg.orgcode2 else suborg.orgcode end as org2code
,case when suborg.organizationid3 is not null then suborg.organizationtype2 else suborg.organizationtype end as org2type
,case when suborg.organizationid3 is not null then suborg.effectivedate2 else suborg.effectivedate end as org2effdt
,case when suborg.organizationid3 is not null then suborg.enddate2 else suborg.enddate end as org2enddt

,case when suborg.organizationid3 is not null then suborg.organizationid else null::int end as org3id
,case when suborg.organizationid3 is not null then suborg.organizationdesc else null end as org3desc
,case when suborg.organizationid3 is not null then suborg.orgcode else null end as org3code
,case when suborg.organizationid3 is not null then suborg.organizationtype else null end as org3type
,case when suborg.organizationid3 is not null then suborg.effectivedate else null::date end as org3effdt
,case when suborg.organizationid3 is not null then suborg.enddate else null::date end as org3enddt

,null::int as org4id
,null as org4desc
,null as org4code
,null as org4type
,null::date as org4effdt
,null::date as org4enddt

, '3' as qsource

from suborg  
where suborg.memberoforgid2 is not null and suborg.memberoforgid3 is null 



union

select distinct
--- when section 4 is null shift columns over by 1 section 
 case when suborg.organizationid4 is not null then suborg.organizationid4 else suborg.organizationid3 end as org1id
,case when suborg.organizationid4 is not null then suborg.organizationdesc4 else suborg.organizationdesc3 end as org1desc
,case when suborg.organizationid4 is not null then suborg.orgcode4 else suborg.orgcode3 end as org1code
,case when suborg.organizationid4 is not null then suborg.organizationtype4 else suborg.organizationtype3 end as org1type
,case when suborg.organizationid4 is not null then suborg.effectivedate4 else suborg.effectivedate3 end as org1effdt
,case when suborg.organizationid4 is not null then suborg.enddate4 else suborg.enddate3 end as org1enddt
 
,case when suborg.organizationid4 is not null then suborg.organizationid3 else suborg.organizationid2 end as org2id
,case when suborg.organizationid4 is not null then suborg.organizationdesc3 else suborg.organizationdesc2 end as org2desc
,case when suborg.organizationid4 is not null then suborg.orgcode3 else suborg.orgcode2 end as org2code
,case when suborg.organizationid4 is not null then suborg.organizationtype3 else suborg.organizationtype2 end as org2type
,case when suborg.organizationid4 is not null then suborg.effectivedate3 else suborg.effectivedate2 end as org2effdt
,case when suborg.organizationid4 is not null then suborg.enddate3 else suborg.enddate2 end as org2enddt

,case when suborg.organizationid4 is not null then suborg.organizationid2 else suborg.organizationid end as org3id
,case when suborg.organizationid4 is not null then suborg.organizationdesc2 else suborg.organizationdesc end as org3desc
,case when suborg.organizationid4 is not null then suborg.orgcode2 else suborg.orgcode end as org3code
,case when suborg.organizationid4 is not null then suborg.organizationtype2 else suborg.organizationtype end as org3type
,case when suborg.organizationid4 is not null then suborg.effectivedate2 else suborg.effectivedate2 end as org3effdt
,case when suborg.organizationid4 is not null then suborg.enddate2 else suborg.enddate end as org3enddt

,case when suborg.organizationid4 is not null then suborg.organizationid else null::int end as org4id
,case when suborg.organizationid4 is not null then suborg.organizationdesc else null end as org4desc
,case when suborg.organizationid4 is not null then suborg.orgcode else null end as org4code
,case when suborg.organizationid4 is not null then suborg.organizationtype else null end as org4type
,case when suborg.organizationid4 is not null then suborg.effectivedate else null::date end as org4effdt
,case when suborg.organizationid4 is not null then suborg.enddate else null::date end as org4enddt

, '4' as qsource

from suborg  
where suborg.memberoforgid3 is not null 
;
