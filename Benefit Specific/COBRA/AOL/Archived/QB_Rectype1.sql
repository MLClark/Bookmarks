SELECT distinct
-- QB record type 1 - Primary QB record
 pi.personid
,pip.identity
,pi.identity AS e_ssn_001
,' ' ::char(1) as filler_002
,rtrim(ltrim(pne.lname)) AS e_lname_003
,rtrim(ltrim(pne.fname)) AS e_fname_004
,rtrim(ltrim(upper(substring(pne.mname from 1for 1)))) AS e_mname_005
--,pp.positionid
--,por.organizationid 
--,oc.organizationtype
,'USB' ::char(3) as clientkey_006
,oc.orgcode as deptkey_007
,rtrim(ltrim(pvE.gendercode)) as e_sex_008
,' '::char(1) as e_title_009
,'PQB' as e_relation_010
,' ' ::char(1) as d_ssn_011

,to_char(pve.birthdate, 'MM/dd/YYYY')::char(10) as e_dob_012
,to_char(etd.termdate + interval '1 day','MM/DD/YYYY') ::char(10) as first_day_after_LOCdate_013
,to_char(etd.termdate,'MM/DD/YYYY') ::char(10) as cobra_event_date_014
,case when etd.emplevent = 'InvTerm' then '1'
      when etd.emplevent = 'VolTerm' then '1' 
      end ::char(1) as qb_event_code_015

,rtrim(ltrim(pae.streetaddress)) AS e_addr_016
,rtrim(ltrim(pae.city)) as e_city_017
,rtrim(ltrim(pae.stateprovincecode)) as e_state_018
,rtrim(ltrim(pae.postalcode)) as e_zip_019

,replace(replace(replace(replace(coalesce(ppcw.phoneno,ppcb.phoneno,ppcm.phoneno,ppch.phoneno,'no phones'),')',''),'-',''),'(',''),' ','') ::varchar(10) AS e_phone_020
,piE.identity ::char(9) as employeenbr_021
,' ' ::char(1) as filler_022
,' ' ::char(1) as filler_023
,' ' ::char(1) as filler_024
,' ' ::char(1) as filler_025
,' ' ::char(1) as filler_026
,' ' ::char(1) as filler_027
,' ' ::char(1) as filler_028
,' ' ::char(1) as filler_029
,' ' ::char(1) as filler_030
,' ' ::char(1) as filler_031
,' ' ::char(1) as filler_032
,' ' ::char(1) as filler_033
,' ' ::char(1) as filler_034
,' ' ::char(1) as filler_035
,' ' ::char(1) as filler_036
,' ' ::char(1) as filler_037
,' ' ::char(1) as filler_038
,' ' ::char(1) as filler_039
,' ' ::char(1) as filler_040
,rtrim(ltrim(pae.streetaddress2)) AS e_addr2_041
,'N' ::char(1) as t1_eligible_for_medicaid_042
,' ' ::char(1) as t3_amt_paid_for_flex_bene_plan_043
,' ' ::char(1) as filler_044
,' ' ::char(1) as filler_045
,' ' ::char(1) as filler_046
,' ' ::char(1) as filler_047
,' ' ::char(1) as filler_048
,' ' ::char(1) as filler_049
,' ' ::char(1) as filler_050
,' ' ::char(1) as filler_051
,' ' ::char(1) as filler_052
,' ' ::char(1) as filler_053
,' ' ::char(1) as filler_054
,' ' ::char(1) as filler_055
,' ' ::char(1) as filler_056
,' ' ::char(1) as filler_057
,' ' ::char(1) as t3_cover_amt_058
,to_char(ed.emplhiredate,'MM/dd/YYYY')::char(10) as doh_059
,' ' ::char(1) as t2_ind_id_060
,' ' ::char(1) as filler_061
,' ' ::char(1) as filler_062
,' ' ::char(1) as filler_063
,' ' ::char(1) as filler_064
,' ' ::char(1) as filler_065
,' ' ::char(1) as filler_066
,' ' ::char(1) as filler_067
,' ' ::char(1) as filler_068
,' ' ::char(1) as filler_069
,' ' ::char(1) as filler_070
,' ' ::char(1) as filler_071
,' ' ::char(1) as filler_072
,' ' ::char(1) as filler_073
,' ' ::char(1) as filler_074
,' ' ::char(1) as filler_075
,' ' ::char(1) as filler_076
,' ' ::char(1) as filler_077
,' ' ::char(1) as filler_078
,' ' ::char(1) as filler_079
,' ' ::char(1) as filler_080
,' ' ::char(1) as filler_081
,' ' ::char(1) as filler_082
,' ' ::char(1) as filler_083
,' ' ::char(1) as filler_084
,' ' ::char(1) as filler_085
,' ' ::char(1) as filler_086
,' ' ::char(1) as filler_087
,' ' ::char(1) as filler_088
,' ' ::char(1) as filler_089
,' ' ::char(1) as filler_090
,' ' ::char(1) as filler_091
,' ' ::char(1) as filler_092
,' ' ::char(1) as filler_093
,' ' ::char(1) as filler_094
,' ' ::char(1) as filler_095
,' ' ::char(1) as filler_096
,' ' ::char(1) as filler_097

,'F' ::char(1) as t1_include_fam_in_addr_098
,' ' ::char(1) as filler_099
,' ' ::char(1) as filler_100
,' ' ::char(1) as filler_101
,' ' ::char(1) as filler_102
,' ' ::char(1) as filler_103
,' ' ::char(1) as filler_104
,' ' ::char(1) as filler_105
,' ' ::char(1) as filler_106
,' ' ::char(1) as filler_107
,' ' ::char(1) as filler_108
,' ' ::char(1) as filler_109
,' ' ::char(1) as filler_110
,' ' ::char(1) as filler_111
,' ' ::char(1) as filler_112
,' ' ::char(1) as filler_113
,' ' ::char(1) as filler_114
,' ' ::char(1) as filler_115
,' ' ::char(1) as filler_116
,' ' ::char(1) as filler_117
,' ' ::char(1) as filler_118
,' ' ::char(1) as filler_119
,' ' ::char(1) as filler_120
,' ' ::char(1) as filler_121
,' ' ::char(1) as filler_122
,' ' ::char(1) as filler_123
,' ' ::char(1) as filler_124
,' ' ::char(1) as filler_125
,' ' ::char(1) as filler_126
,' ' ::char(1) as filler_127
,' ' ::char(1) as filler_128
,' ' ::char(1) as filler_129
,' ' ::char(1) as filler_130
,' ' ::char(1) as filler_131
,' ' ::char(1) as filler_132
,' ' ::char(1) as filler_133
,' ' ::char(1) as filler_134
,' ' ::char(1) as filler_135
,' ' ::char(1) as filler_136
,' ' ::char(1) as filler_137
,' ' ::char(1) as filler_138
,' ' ::char(1) as filler_139
,' ' ::char(1) as filler_140
,' ' ::char(1) as filler_141
,' ' ::char(1) as filler_142
,' ' ::char(1) as filler_143
,' ' ::char(1) as filler_144
,' ' ::char(1) as filler_145
,' ' ::char(1) as filler_146
,' ' ::char(1) as filler_147
,' ' ::char(1) as filler_148
,' ' ::char(1) as filler_149
,' ' ::char(1) as filler_150
,' ' ::char(1) as filler_151
,' ' ::char(1) as filler_152
,' ' ::char(1) as filler_153
,' ' ::char(1) as filler_154
,' ' ::char(1) as filler_155
,' ' ::char(1) as filler_156
,' ' ::char(1) as filler_157
,' ' ::char(1) as filler_158
,' ' ::char(1) as filler_159
,' ' ::char(1) as filler_160
,' ' ::char(1) as filler_161
,' ' ::char(1) as filler_162
,' ' ::char(1) as filler_163
,' ' ::char(1) as filler_164
,' ' ::char(1) as filler_165
,' ' ::char(1) as filler_166
,' ' ::char(1) as filler_167
,' ' ::char(1) as filler_168
,' ' ::char(1) as filler_169
,' ' ::char(1) as filler_170
,' ' ::char(1) as filler_171
,' ' ::char(1) as filler_172
,' ' ::char(1) as filler_173
,' ' ::char(1) as filler_174
,' ' ::char(1) as filler_175
,' ' ::char(1) as filler_176
,' ' ::char(1) as filler_177
,' ' ::char(1) as filler_178
,' ' ::char(1) as filler_179
,'F' ::char(1) as t1_ARRA_stimulous_180
,' ' ::char(1) as filler_181
,' ' ::char(1) as filler_182
,' ' ::char(1) as filler_183
,' ' ::char(1) as filler_184
,' ' ::char(1) as filler_185
,' ' ::char(1) as filler_186
,' ' ::char(1) as filler_187
,' ' ::char(1) as filler_188
,'F' ::char(1) as t1_print_and_dependents_189



FROM person_identity pi
JOIN identity_types it 
  ON pi.identitytype = it.identitytype 
 AND current_timestamp between pi.createts AND pi.endts
LEFT JOIN person_identity piE 
  ON pi.personid = piE.personid 
 AND piE.identitytype = 'EmpNo' 
 AND current_timestamp between piE.createts AND piE.endts
LEFT JOIN person_identity piP
  ON pi.personid = piP.personid 
 AND piP.identitytype = 'PSPID' 
 AND current_timestamp between piP.createts AND piP.endts 
 
left JOIN edi.etl_employment_term_data etd 
  ON etd.personid = pi.personid
left JOIN edi.etl_employment_data ed 
  ON ed.personid = pi.personid AND ed.EMPLSTATUS in ( 'T', 'L') 
  
LEFT JOIN person_names pne 
  ON pne.personid = pi.personid 
 AND pne.nametype = 'Legal'::bpchar 
 AND current_date between pne.effectivedate AND pne.enddate 
 AND current_timestamp between pne.createts AND pne.endts
LEFT JOIN person_address pae 
 ON pae.personid = pi.personid 
AND pae.addresstype = 'Res'::bpchar 
AND current_date between pae.effectivedate AND pae.enddate 
AND current_timestamp between pae.createts AND pae.endts

LEFT JOIN person_phone_contacts ppch 
 ON ppch.personid = pi.personid
 AND current_date between ppch.effectivedate and ppch.enddate
 AND current_timestamp between ppch.createts and ppch.endts 
 AND ppch.phonecontacttype = 'Home'
LEFT JOIN person_phone_contacts ppcw 
  ON ppcw.personid = pi.personid
 AND current_date between ppcw.effectivedate and ppcw.enddate
 AND current_timestamp between ppcw.createts and ppcw.endts 
 AND ppcw.phonecontacttype = 'Work'   
LEFT JOIN person_phone_contacts ppcb 
  ON ppcb.personid = pi.personid
 AND current_date between ppcb.effectivedate and ppcb.enddate
 AND current_timestamp between ppcb.createts and ppcb.endts 
 AND ppcb.phonecontacttype = 'BUSN'      
LEFT JOIN person_phone_contacts ppcm 
  ON ppcm.personid = pi.personid
 AND current_date between ppcm.effectivedate and ppcm.enddate
 AND current_timestamp between ppcm.createts and ppcm.endts 
 AND ppcm.phonecontacttype = 'Mobile'  
 
LEFT JOIN person_vitals pvE 
 ON pvE.personid = pi.personid 
AND current_date between pvE.effectivedate AND pvE.enddate 
AND current_timestamp between pvE.createts AND pvE.endts

JOIN person_bene_election pbe 
 on pbe.personid = pi.personid 
and benefitelection = 'T' 
and selectedoption = 'Y' 
AND current_date between pbe.effectivedate AND pbe.enddate 
AND current_timestamp between pbe.createts AND pbe.endts
JOIN comp_plan_benefit_plan cpbp 
 on cpbp.compplanid = pbe.compplanid 
and pbe.benefitsubclass = cpbp.benefitsubclass 
AND current_date between cpbp.effectivedate AND cpbp.enddate 
AND current_timestamp between cpbp.createts AND cpbp.endts

left JOIN person_employment pe 
 ON pe.personid = pi.personid 
AND current_date between pe.effectivedate AND pe.enddate 
AND current_timestamp between pe.createts AND pe.endts

left JOIN person_employment pe_end
 ON pe_end.personid = pi.personid 
and pe_end.enddate < '2199-12-31'

left join pers_pos pp on pp.personid = pi.personid
 and pp.enddate = pe_end.enddate

left join pos_org_rel por
  on por.positionid = pp.positionid

left join organization_code oc
  on oc.organizationid = por.organizationid  

---- Spouse data

left JOIN person_dependent_relationship pdrS 
 on pdrS.personid = pi.personid 
AND current_date between pdrS.effectivedate AND pdrS.enddate 
AND current_timestamp between pdrS.createts AND pdrS.endts 
AND pdrS.dependentrelationship = 'SP'

LEFT JOIN person_names pnS 
 ON pnS.personid = pdrS.dependentid 
AND current_date between pnS.effectivedate AND pnS.enddate 
AND current_timestamp between pnS.createts AND pnS.endts

LEFT JOIN person_identity piS
  ON piS.personid = pdrS.personid 
 AND piS.identitytype = 'SSN'::bpchar 
 AND current_timestamp between piS.createts AND piS.endts

LEFT JOIN person_vitals pvS
  ON pvS.personid = pdrS.personid 
 AND current_date between pvS.effectivedate AND pvS.enddate 
 AND current_timestamp between pvS.createts AND pvS.endts

LEFT JOIN dependent_enrollment dpS 
  on dpS.dependentid = pdrS.dependentid 
 AND current_date between dpS.effectivedate AND dpS.enddate 
 AND current_timestamp between dpS.createts AND dpS.endts

LEFT JOIN person_address paS 
 ON paS.personid = piS.personid 
AND paS.addresstype = 'Res'::bpchar 
AND current_date between paS.effectivedate AND paS.enddate 
AND current_timestamp between paS.createts AND paS.endts 
 
LEFT JOIN edi.edi_last_update lu on lu.feedid = 'AOL_COBRASimple_COBRA_Employee'


WHERE pi.identitytype = 'SSN' 
  and cpbp.cobraplan = 'Y'
  and oc.organizationtype = 'CCDept'

and pi.personid in ('1917', '1928','1966', '1982','1926')

order by 1,2


-- 476

