SELECT distinct
-- QB record type 2 Family members
 pi.personid
,pdrD.dependentid
--- starting column 40
,null as filler_040
,null AS e_addr2_041
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
,null as filler_058
,null as filler_059
--,replace(piD.identity,'-','') as t2_ind_id_060 - dependent ssn not needed twice
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

,null as filler_098
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
,null as filler_180
,null as filler_181
,null as filler_182
,null as filler_183
,null as filler_184
,null as filler_185
,null as filler_186
,null as filler_187
,null as filler_188
,null as filler_189




FROM person_identity pi
JOIN identity_types it 
  ON pi.identitytype = it.identitytype 
 AND current_timestamp between pi.createts AND pi.endts
LEFT JOIN person_identity piE 
  ON pi.personid = piE.personid 
 AND piE.identitytype = 'EmpNo' 
 AND current_timestamp between piE.createts AND piE.endts
 
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

left join 
   (select benefitplandesc, benefitsubclass, benefitplanid from benefit_plan_desc bpd
    where benefitsubclass in ('10','11','14','60','61')
      and current_date between effectivedate and enddate
      and current_timestamp between createts and endts) bpd
 on bpd.benefitplanid = pbe.benefitplanid


JOIN comp_plan_benefit_plan cpbp 
 on cpbp.compplanid = pbe.compplanid 
and pbe.benefitsubclass = cpbp.benefitsubclass 
AND current_date between cpbp.effectivedate AND cpbp.enddate 
AND current_timestamp between cpbp.createts AND cpbp.endts
JOIN person_employment pe 
 ON pe.personid = pi.personid 
AND current_date between pe.effectivedate AND pe.enddate 
AND current_timestamp between pe.createts AND pe.endts


---- Dependents Data

left JOIN person_dependent_relationship pdrD
 on pdrD.personid = pi.personid 
AND current_date between pdrD.effectivedate AND pdrD.enddate 
AND current_timestamp between pdrD.createts AND pdrD.endts 
AND pdrD.dependentrelationship in ('SP', 'C', 'D', 'S')

LEFT JOIN person_names pnD
 ON pnD.personid = pdrD.dependentid 
AND current_date between pnD.effectivedate AND pnD.enddate 
AND current_timestamp between pnD.createts AND pnD.endts

LEFT JOIN person_identity piD
  ON piD.personid = pdrD.dependentid 
 AND piD.identitytype = 'SSN'::bpchar 
 AND current_timestamp between piD.createts AND piD.endts

LEFT JOIN person_vitals pvD
  ON pvD.personid = pdrD.dependentid 
 AND current_date between pvD.effectivedate AND pvD.enddate 
 AND current_timestamp between pvD.createts AND pvD.endts

LEFT JOIN dependent_enrollment dpD 
  on dpD.dependentid = pdrD.dependentid 
 AND current_date between dpD.effectivedate AND dpD.enddate 
 AND current_timestamp between dpD.createts AND dpD.endts

LEFT JOIN person_address paD
 ON paD.personid = pdrD.dependentid 
AND paD.addresstype = 'Res'::bpchar 
AND current_date between paD.effectivedate AND paD.enddate 
AND current_timestamp between paD.createts AND paD.endts 
 
LEFT JOIN edi.edi_last_update lu on lu.feedid = 'AOL_COBRASimple_QB_Export'


WHERE pi.identitytype = 'SSN' 
  and cpbp.cobraplan = 'Y'

--and pi.personid in ('1917', '1928','1966', '1982','1926')

order by 1,2


-- 476

