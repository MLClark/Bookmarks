
select distinct
 ssn.personid
,ssn.trankey
,ssn.taxformyear
,ssn.ssn
,ein.ein
,erna.er_name
,era1.er_addr1
,era2.er_addr2
,era3.er_addr3
,cnbr.control_number
,eena.ee_name
,eea1.er_addr1
,eea2.er_addr2
,eea3.er_addr3
,b1.box1_wages
,b2.box2_wages
,b3.box3_wages
,b4.box4_wages
,b5.box5_wages
,b6.box6_wages
,b7.box7_wages
,b8.box8_wages
,b10.box10_wages
,b11.box11_wages
from cognos_w2_data w2d


join 

--- SSN

(
select
 personid
,trankey 
,taxformyear
,boxnumber
,box
,subbox
,alphavalue as ssn
,dollarsvalue
from cognos_w2_data 
where taxformyear = '2019'
  and boxnumber = 'a         '
  and trankey = 'AZW20000009078'
) ssn on ssn.personid = w2d.personid and ssn.trankey = w2d.trankey and ssn.taxformyear = w2d.taxformyear --and ssn.boxnumber = w2d.boxnumber --and ssn.subbox = w2d.subbox

join

--- EIN
(
select
 personid
,trankey 
,taxformyear
,boxnumber
,box
,subbox
,alphavalue as ein
,dollarsvalue
from cognos_w2_data 
where taxformyear = '2019'
  and boxnumber = 'b         '
  and trankey = 'AZW10000008765'
) ein on ein.personid = w2d.personid and ein.trankey = w2d.trankey and ein.taxformyear = w2d.taxformyear --and ein.boxnumber = w2d.boxnumber --and ein.subbox = w2d.subbox
  
join

--- er name 
(
select distinct
 personid
,trankey 
,taxformyear
,boxnumber
,box
,subbox
,case when subbox = 1 then alphavalue end as er_name
,dollarsvalue
from cognos_w2_data 
where taxformyear = '2019'
  and boxnumber = 'c         ' and subbox = 1
  and trankey = 'AZW10000008765'
  and alphavalue is not null
) erna on erna.personid = w2d.personid and erna.trankey = w2d.trankey and erna.taxformyear = w2d.taxformyear --and ein.boxnumber = w2d.boxnumber --and ein.subbox = w2d.subbox
  
join

--- er addr1  
(
select distinct
 personid
,trankey 
,taxformyear
,boxnumber
,box
,subbox
,case when subbox = 2 then alphavalue end as er_addr1
,dollarsvalue
from cognos_w2_data 
where taxformyear = '2019'
  and boxnumber = 'c         ' and subbox = 2
  and trankey = 'AZW10000008765'
  and alphavalue is not null
) era1 on era1.personid = w2d.personid and era1.trankey = w2d.trankey and era1.taxformyear = w2d.taxformyear --and ein.boxnumber = w2d.boxnumber --and ein.subbox = w2d.subbox
  
left join

--- er addr2 
(
select distinct
 personid
,trankey 
,taxformyear
,boxnumber
,box
,subbox
,case when subbox = 3 then alphavalue end as er_addr2
,dollarsvalue
from cognos_w2_data 
where taxformyear = '2019'
  and boxnumber = 'c         ' and subbox = 3
  and trankey = 'AZW10000008765'
  and alphavalue is not null
) era2 on era2.personid = w2d.personid and era2.trankey = w2d.trankey and era2.taxformyear = w2d.taxformyear --and ein.boxnumber = w2d.boxnumber --and ein.subbox = w2d.subbox
  
  
left join

--- er addr23
(
select distinct
 personid
,trankey 
,taxformyear
,boxnumber
,box
,subbox
,case when subbox = 4 then alphavalue end as er_addr3
,dollarsvalue
from cognos_w2_data 
where taxformyear = '2019'
  and boxnumber = 'c         ' and subbox = 4
  and trankey = 'AZW10000008765'
  and alphavalue is not null
) era3 on era3.personid = w2d.personid and era3.trankey = w2d.trankey and era3.taxformyear = w2d.taxformyear --and ein.boxnumber = w2d.boxnumber --and ein.subbox = w2d.subbox
  

join

--- control number
(
select distinct
 personid
,trankey 
,taxformyear
,boxnumber
,box
,subbox
,alphavalue as control_number
,dollarsvalue
from cognos_w2_data 
where taxformyear = '2019'
  and boxnumber = 'd         ' 
  and trankey = 'AZW10000008765'
  and alphavalue is not null
) cnbr on cnbr.personid = w2d.personid and cnbr.trankey = w2d.trankey and cnbr.taxformyear = w2d.taxformyear --and ein.boxnumber = w2d.boxnumber --and ein.subbox = w2d.subbox
  
    
join

--- ee name 
(
select distinct
 personid
,trankey 
,taxformyear
,boxnumber
,box
,subbox
,case when subbox = 1 then alphavalue end as ee_name
,dollarsvalue
from cognos_w2_data 
where taxformyear = '2019'
  and boxnumber = 'e         ' and subbox = 1
  and trankey = 'AZW10000008765'
  and alphavalue is not null
) eena on eena.personid = w2d.personid and eena.trankey = w2d.trankey and eena.taxformyear = w2d.taxformyear --and ein.boxnumber = w2d.boxnumber --and ein.subbox = w2d.subbox
 
join

--- ee addr1  
(
select distinct
 personid
,trankey 
,taxformyear
,boxnumber
,box
,subbox
,case when subbox = 2 then alphavalue end as er_addr1
,dollarsvalue
from cognos_w2_data 
where taxformyear = '2019'
  and boxnumber = 'e         ' and subbox = 2
  and trankey = 'AZW10000008765'
  and alphavalue is not null
) eea1 on eea1.personid = w2d.personid and eea1.trankey = w2d.trankey and eea1.taxformyear = w2d.taxformyear --and ein.boxnumber = w2d.boxnumber --and ein.subbox = w2d.subbox
  
left join

--- ee addr2 
(
select distinct
 personid
,trankey 
,taxformyear
,boxnumber
,box
,subbox
,case when subbox = 3 then alphavalue end as er_addr2
,dollarsvalue
from cognos_w2_data 
where taxformyear = '2019'
  and boxnumber = 'e         ' and subbox = 3
  and trankey = 'AZW10000008765'
  and alphavalue is not null
) eea2 on eea2.personid = w2d.personid and eea2.trankey = w2d.trankey and eea2.taxformyear = w2d.taxformyear --and ein.boxnumber = w2d.boxnumber --and ein.subbox = w2d.subbox
  
  
left join

--- ee addr23
(
select distinct
 personid
,trankey 
,taxformyear
,boxnumber
,box
,subbox
,case when subbox = 4 then alphavalue end as er_addr3
,dollarsvalue
from cognos_w2_data 
where taxformyear = '2019'
  and boxnumber = 'e         ' and subbox = 4
  and trankey = 'AZW10000008765'
  and alphavalue is not null
) eea3 on eea3.personid = w2d.personid and eea3.trankey = w2d.trankey and eea3.taxformyear = w2d.taxformyear --and ein.boxnumber = w2d.boxnumber --and ein.subbox = w2d.subbox
  
  
left join

--- box1 wages
(
select distinct
 personid
,trankey 
,taxformyear
,boxnumber
,box
,subbox
,alphavalue 
,dollarsvalue as box1_wages
from cognos_w2_data 
where taxformyear = '2019'
  and boxnumber = '1         ' 
  and trankey = 'AZW10000008765'
) b1 on b1.personid = w2d.personid and b1.trankey = w2d.trankey and b1.taxformyear = w2d.taxformyear --and ein.boxnumber = w2d.boxnumber --and ein.subbox = w2d.subbox
  
  
left join

--- box1 wages
(
select distinct
 personid
,trankey 
,taxformyear
,boxnumber
,box
,subbox
,alphavalue 
,dollarsvalue as box2_wages
from cognos_w2_data 
where taxformyear = '2019'
  and boxnumber = '2         ' 
  and trankey = 'AZW10000008765'
) b2 on b2.personid = w2d.personid and b2.trankey = w2d.trankey and b2.taxformyear = w2d.taxformyear --and ein.boxnumber = w2d.boxnumber --and ein.subbox = w2d.subbox
  
  
left join

--- box1 wages
(
select distinct
 personid
,trankey 
,taxformyear
,boxnumber
,box
,subbox
,alphavalue 
,dollarsvalue as box3_wages
from cognos_w2_data 
where taxformyear = '2019'
  and boxnumber = '3         ' 
  and trankey = 'AZW10000008765'
) b3 on b3.personid = w2d.personid and b3.trankey = w2d.trankey and b3.taxformyear = w2d.taxformyear --and ein.boxnumber = w2d.boxnumber --and ein.subbox = w2d.subbox
  

left join

--- box1 wages
(
select distinct
 personid
,trankey 
,taxformyear
,boxnumber
,box
,subbox
,alphavalue 
,dollarsvalue as box4_wages
from cognos_w2_data 
where taxformyear = '2019'
  and boxnumber = '4         ' 
  and trankey = 'AZW10000008765'
) b4 on b4.personid = w2d.personid and b4.trankey = w2d.trankey and b4.taxformyear = w2d.taxformyear --and ein.boxnumber = w2d.boxnumber --and ein.subbox = w2d.subbox
  

left join

--- box1 wages
(
select distinct
 personid
,trankey 
,taxformyear
,boxnumber
,box
,subbox
,alphavalue 
,dollarsvalue as box5_wages
from cognos_w2_data 
where taxformyear = '2019'
  and boxnumber = '5         ' 
  and trankey = 'AZW10000008765'
) b5 on b5.personid = w2d.personid and b5.trankey = w2d.trankey and b5.taxformyear = w2d.taxformyear --and ein.boxnumber = w2d.boxnumber --and ein.subbox = w2d.subbox
  
left join

--- box1 wages
(
select distinct
 personid
,trankey 
,taxformyear
,boxnumber
,box
,subbox
,alphavalue 
,dollarsvalue as box6_wages
from cognos_w2_data 
where taxformyear = '2019'
  and boxnumber = '6         ' 
  and trankey = 'AZW10000008765'
) b6 on b6.personid = w2d.personid and b6.trankey = w2d.trankey and b6.taxformyear = w2d.taxformyear --and ein.boxnumber = w2d.boxnumber --and ein.subbox = w2d.subbox
  
left join

--- box1 wages
(
select distinct
 personid
,trankey 
,taxformyear
,boxnumber
,box
,subbox
,alphavalue 
,dollarsvalue as box7_wages
from cognos_w2_data 
where taxformyear = '2019'
  and boxnumber = '7         ' 
  and trankey = 'AZW10000008765'
) b7 on b7.personid = w2d.personid and b7.trankey = w2d.trankey and b7.taxformyear = w2d.taxformyear --and ein.boxnumber = w2d.boxnumber --and ein.subbox = w2d.subbox
  

left join

--- box1 wages
(
select distinct
 personid
,trankey 
,taxformyear
,boxnumber
,box
,subbox
,alphavalue 
,dollarsvalue as box8_wages
from cognos_w2_data 
where taxformyear = '2019'
  and boxnumber = '8         ' 
  and trankey = 'AZW10000008765'
) b8 on b8.personid = w2d.personid and b8.trankey = w2d.trankey and b8.taxformyear = w2d.taxformyear --and ein.boxnumber = w2d.boxnumber --and ein.subbox = w2d.subbox
  

left join

--- box1 wages
(
select distinct
 personid
,trankey 
,taxformyear
,boxnumber
,box
,subbox
,alphavalue 
,dollarsvalue as box10_wages
from cognos_w2_data 
where taxformyear = '2019'
  and boxnumber = '10        ' 
  and trankey = 'AZW10000008765'
) b10 on b10.personid = w2d.personid and b10.trankey = w2d.trankey and b10.taxformyear = w2d.taxformyear --and ein.boxnumber = w2d.boxnumber --and ein.subbox = w2d.subbox
  
left join

--- box1 wages
(
select distinct
 personid
,trankey 
,taxformyear
,boxnumber
,box
,subbox
,alphavalue 
,dollarsvalue as box11_wages
from cognos_w2_data 
where taxformyear = '2019'
  and boxnumber = '11        ' 
  and trankey = 'AZW10000008765'
) b11 on b10.personid = w2d.personid and b11.trankey = w2d.trankey and b11.taxformyear = w2d.taxformyear --and ein.boxnumber = w2d.boxnumber --and ein.subbox = w2d.subbox
  
                
    
where w2d.taxformyear = '2019'
  and w2d.trankey = 'AZW10000008765' 
 ;
 

select distinct
 w2d.personid
,w2d.trankey 
,w2d.taxformyear
,w2d.boxnumber
,w2d.box
,w2d.subbox
,w2d.alphavalue
,w2d.dollarsvalue
from cognos_w2_data w2d
where w2d.taxformyear = '2019'
  and w2d.trankey = 'AZW10000008765'
  ;

   