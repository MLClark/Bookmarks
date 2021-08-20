select distinct
 pi.personid
,concat(pn.lname,', ',pn.fname,' ',pn.mname) ::varchar(100) as namea
,pn.lname||', '||pn.fname||' '||pn.mname ::char(60) as nameb
,TRIM(UPPER(pn.lname||', '||fname||' '|| coalesce(LEFT(mname,1),' ')))::char(43) as "Last,First Name Uppercase"
,cast((case	when pn.mname is null then TRIM(both ' ' from pn.fname)
		else pn.fname || ' ' || LEFT(TRIM(both ' ' from pn.mname), 1)
		end) as varchar(100)) 				as "Cast Firstname "

from person_identity pi

join person_names pn
  on pn.personid = pi.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts
 
 
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts