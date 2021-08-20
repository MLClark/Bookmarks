SELECT distinct
-- QB record type 1 - Primary QB record
 pi.personid
,pip.identity
,pe.effectivedate
,pe.emplstatus
,pi.identity AS e_ssn_001
,null as filler_002
,rtrim(ltrim(pne.lname)) AS e_lname_003
,rtrim(ltrim(pne.fname)) AS e_fname_004
,rtrim(ltrim(upper(substring(pne.mname from 1for 1)))) AS e_mname_005
--,pp.positionid
--,por.organizationid 
--,oc.organizationtype
,'USB' ::char(3) as clientkey_006
,oc.orgcode::char(2) as deptkey_007
,rtrim(ltrim(pvE.gendercode)) as e_sex_008
,null as e_title_009
,'PQB' as e_relation_010
,null as d_ssn_011
,etd.termdate
,date_trunc('month', etd.termdate - interval '1 month' ) as last_month

,to_char(pve.birthdate, 'MM/dd/YYYY')::char(10) as e_dob_012
,to_char(date_trunc('month', pe.effectivedate + interval '1 month' ), 'MM/DD/YYYY') ::char(10) as first_day_after_LOCdate_013
,to_char( pe.effectivedate,'MM/DD/YYYY') ::char(10) as cobra_event_date_014
,case when etd.emplevent = 'InvTerm' then '1'
      when etd.emplevent = 'VolTerm' then '1' 
      end ::char(1) as qb_event_code_015

,rtrim(ltrim(pae.streetaddress)) AS e_addr_016
,rtrim(ltrim(pae.city)) as e_city_017
,rtrim(ltrim(pae.stateprovincecode)) as e_state_018
,rtrim(ltrim(pae.postalcode)) as e_zip_019

,replace(coalesce(ppcw.phoneno,' '),'-','') ::varchar(10) AS e_phone_020

,piE.identity ::char(9) as employeenbr_021
,null as filler_022
,null as filler_023
,null as filler_024
,null as filler_025
,null as filler_026
,null as filler_027
,null as filler_028
,null as filler_029
,null as filler_030
,null as filler_031
,null as filler_032
,null as filler_033
,null as filler_034
,null as filler_035
,null as filler_036
,null as filler_037
,null as filler_038
,null as filler_039
,to_char(current_date,'mm/dd/yyyy')::char(10) today_date_040
,rtrim(ltrim(pae.streetaddress2)) AS e_addr2_041
,null as t1_eligible_for_medicaid_042
,null as t3_amt_paid_for_flex_bene_plan_043
,null as filler_044
,null as filler_045
,null as filler_046
,null as filler_047
,null as filler_048
,null as filler_049
,null as filler_050
,null as filler_051
,null as filler_052
,null as filler_053
,null as filler_054
,null as filler_055
,null as filler_056
,null as filler_057
,null as t3_cover_amt_058
,to_char(ed.emplhiredate,'MM/dd/YYYY')::char(10) as doh_059
,null as t2_ind_id_060
,null as filler_061
,null as filler_062
,null as filler_063
,null as filler_064
,null as filler_065
,null as filler_066
,null as filler_067
,null as filler_068
,null as filler_069
,null as filler_070
,null as filler_071
,null as filler_072
,null as filler_073
,null as filler_074
,null as filler_075
,null as filler_076
,null as filler_077
,null as filler_078
,null as filler_079
,null as filler_080
,null as filler_081
,null as filler_082
,null as filler_083
,null as filler_084
,null as filler_085
,null as filler_086
,null as filler_087
,null as filler_088
,null as filler_089
,null as filler_090
,null as filler_091
,null as filler_092
,null as filler_093
,null as filler_094
,null as filler_095
,null as filler_096
,null as filler_097

,'F' ::char(1) as t1_include_fam_in_addr_098
,null as filler_099
,null as filler_100
,null as filler_101
,null as filler_102
,null as filler_103
,null as filler_104
,null as filler_105
,null as filler_106
,null as filler_107
,null as filler_108
,null as filler_109
,null as filler_110
,null as filler_111
,null as filler_112
,null as filler_113
,null as filler_114
,null as filler_115
,null as filler_116
,null as filler_117
,null as filler_118
,null as filler_119
,null as filler_120
,null as filler_121
,null as filler_122
,null as filler_123
,null as filler_124
,null as filler_125
,null as filler_126
,null as filler_127
,null as filler_128
,null as filler_129
,null as filler_130
,null as filler_131
,null as filler_132
,null as filler_133
,null as filler_134
,null as filler_135
,null as filler_136
,null as filler_137
,null as filler_138
,null as filler_139
,null as filler_140
,null as filler_141
,null as filler_142
,null as filler_143
,null as filler_144
,null as filler_145
,null as filler_146
,null as filler_147
,null as filler_148
,null as filler_149
,null as filler_150
,null as filler_151
,null as filler_152
,null as filler_153
,null as filler_154
,null as filler_155
,null as filler_156
,null as filler_157
,null as filler_158
,null as filler_159
,null as filler_160
,null as filler_161
,null as filler_162
,null as filler_163
,null as filler_164
,null as filler_165
,null as filler_166
,null as filler_167
,null as filler_168
,null as filler_169
,null as filler_170
,null as filler_171
,null as filler_172
,null as filler_173
,null as filler_174
,null as filler_175
,null as filler_176
,null as filler_177
,null as filler_178
,null as filler_179
,'F' ::char(1) as t1_ARRA_stimulous_180
,null as filler_181
,null as filler_182
,null as filler_183
,null as filler_184
,null as filler_185
,null as filler_186
,null as filler_187
,null as filler_188
,'F' ::char(1) as t1_print_and_dependents_189



FROM person_identity pi
join edi.edi_last_update elu 
  on elu.feedid = 'AOL_COBRASimple_QB_Export'

JOIN person_bene_election pbe 
  on pbe.personid = pi.personid 
 and benefitelection = 'T' 
 and selectedoption = 'Y' 
 AND current_date between pbe.effectivedate AND pbe.enddate 
 AND current_timestamp between pbe.createts AND pbe.endts
--and benefitsubclass in ('60','61')

JOIN comp_plan_benefit_plan cpbp 
  on cpbp.compplanid = pbe.compplanid 
 and pbe.benefitsubclass = cpbp.benefitsubclass 
 AND current_date between cpbp.effectivedate AND cpbp.enddate 
 AND current_timestamp between cpbp.createts AND cpbp.endts

JOIN person_employment pe 
  ON pe.personid = pi.personid 
 AND current_date between pe.effectivedate AND pe.enddate 
 AND current_timestamp between pe.createts AND pe.endts
 and pe.effectivedate >= elu.lastupdatets
 and pe.emplstatus in ('T','R')

  

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
 and etd.empllasthiredate >= elu.lastupdatets
 
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


left JOIN person_employment pe_end
  ON pe_end.personid = pi.personid 
 and pe_end.enddate < '2199-12-31'

left join pers_pos pp on pp.personid = pi.personid
 and pp.enddate = pe_end.enddate

left join pos_org_rel por
  on por.positionid = pp.positionid

left join organization_code oc
  on oc.organizationid = por.organizationid  


WHERE pi.identitytype = 'SSN' 
  and cpbp.cobraplan = 'Y'
  --and oc.organizationtype = 'CCDept'
  and pi.personid = '1986'

--and pi.personid in ('1917', '1928','1966', '1982','1926')

order by 1,2

