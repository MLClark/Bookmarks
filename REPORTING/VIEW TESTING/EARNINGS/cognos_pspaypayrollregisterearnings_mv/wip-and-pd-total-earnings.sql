select
 'wip' as qsource
,w.paycode as paycode
,sum(w.amount) as amount
,coalesce(E01_amount,E02_amount,E17_amount,E18_amount,E20_amount,E37_amount,E39_amount,E61_amount,E63_amount,E64_amount,E70_amount,ECG_amount,EDH_amount,EEC_amount,EG1_amount,EG2_amount,EG6_amount,EGC_amount,EGP_amount,EGZ_amount,EH1_amount,EHB_amount,EHC_amount,EHG_amount,E15_amount,E29_amount
         ,E30_amount,E31_amount,E48_amount,E62_amount,E71_amount,EC0_amount,EC1_amount,EC8_amount,ECH_amount,ECI_amount,ECU_amount,ECV_amount,EDI_amount,EEL_amount,EG0_amount,E16_amount,EAH_amount,EGS_amount,EGW_amount,E04_amount,E08_amount,E13_amount,E22_amount,E23_amount,E24_amount,E25_amount
         ,E28_amount,E40_amount,E44_amount,E72_amount,E90_amount,E96_amount,EA1_amount,EA2_amount,EA4_amount,EC5_amount,EDK_amount,EED_amount,EEJ_amount,EA0_amount,EBM_amount,E32_amount,EA3_amount,EBO_amount,EBS_amount,EBU_amount,EC3_amount,EGB_amount,E19_amount,EMR_amount,EXN_amount,EXT_amount
         ,E09_amount,E12_amount,E14_amount,E26_amount,E27_amount,E45_amount,E46_amount,E47_amount,E49_amount,E50_amount,E51_amount,E52_amount,E53_amount,E55_amount,E56_amount,E65_amount,E66_amount,E67_amount,E68_amount,E69_amount,EEI_amount,EGM_amount,EGR_amount,E03_amount,E05_amount,E06_amount
         ,E07_amount,E36_amount,E38_amount,E41_amount,E42_amount,E43_amount,E74_amount,EAA_amount,EAG_amount,EAZ_amount,EBQ_amount,EC4_amount,ECT_amount,EDB_amount,EEQ_amount,EBK_amount,ECJ_amount,E33_amount,ECX_amount,EEF_amount,EGV_amount,ECD_amount,ECE_amount,ECM_amount,ECN_amount,ECO_amount
         ,ECP_amount,ECS_amount) as pd_amount
,sum(w.hours) as hours
,coalesce(E01_hours,E02_hours,E17_hours,E18_hours,E20_hours,E37_hours,E39_hours,E61_hours,E63_hours,E64_hours,E70_hours,ECG_hours,EDH_hours,EEC_hours,EG1_hours,EG2_hours,EG6_hours,EGC_hours,EGP_hours,EGZ_hours,EH1_hours,EHB_hours,EHC_hours,EHG_hours,E15_hours,E29_hours,E30_hours,E31_hours,E48_hours
         ,E62_hours,E71_hours,EC0_hours,EC1_hours,EC8_hours,ECH_hours,ECI_hours,ECU_hours,ECV_hours,EDI_hours,EEL_hours,EG0_hours,E16_hours,EAH_hours,EGS_hours,EGW_hours,E04_hours,E08_hours,E13_hours,E22_hours,E23_hours,E24_hours,E25_hours,E28_hours,E40_hours,E44_hours,E72_hours,E90_hours,E96_hours
         ,EA1_hours,EA2_hours,EA4_hours,EC5_hours,EDK_hours,EED_hours,EEJ_hours,EA0_hours,EBM_hours,E32_hours,EA3_hours,EBO_hours,EBS_hours,EBU_hours,EC3_hours,EGB_hours,E19_hours,EMR_hours,EXN_hours,EXT_hours,E09_hours,E12_hours,E14_hours,E26_hours,E27_hours,E45_hours,E46_hours,E47_hours,E49_hours
         ,E50_hours,E51_hours,E52_hours,E53_hours,E55_hours,E56_hours,E65_hours,E66_hours,E67_hours,E68_hours,E69_hours,EEI_hours,EGM_hours,EGR_hours,E03_hours,E05_hours,E06_hours,E07_hours,E36_hours,E38_hours,E41_hours,E42_hours,E43_hours,E74_hours,EAA_hours,EAG_hours,EAZ_hours,EBQ_hours,EC4_hours
         ,ECT_hours,EDB_hours,EEQ_hours,EBK_hours,ECJ_hours,E33_hours,ECX_hours,EEF_hours,EGV_hours,ECD_hours,ECE_hours,ECM_hours,ECN_hours,ECO_hours,ECP_hours,ECS_hours) as pd_hours
,sum(w.rate) as rate
,coalesce(E01_rate,E02_rate,E17_rate,E18_rate,E20_rate,E37_rate,E39_rate,E61_rate,E63_rate,E64_rate,E70_rate,ECG_rate,EDH_rate,EEC_rate,EG1_rate,EG2_rate,EG6_rate,EGC_rate,EGP_rate,EGZ_rate,EH1_rate,EHB_rate,EHC_rate,EHG_rate,E15_rate,E29_rate,E30_rate,E31_rate,E48_rate,E62_rate,E71_rate,EC0_rate
         ,EC1_rate,EC8_rate,ECH_rate,ECI_rate,ECU_rate,ECV_rate,EDI_rate,EEL_rate,EG0_rate,E16_rate,EAH_rate,EGS_rate,EGW_rate,E04_rate,E08_rate,E13_rate,E22_rate,E23_rate,E24_rate,E28_rate,E40_rate,E44_rate,E72_rate,E90_rate,E96_rate,EA1_rate,EA2_rate,EA4_rate,EC5_rate,EDK_rate,EED_rate,E25_rate
         ,EEJ_rate,EA0_rate,EBM_rate,E32_rate,EA3_rate,EBO_rate,EBS_rate,EBU_rate,EC3_rate,EGB_rate,E19_rate,EMR_rate,EXN_rate,EXT_rate,E09_rate,E12_rate,E14_rate,E26_rate,E27_rate,E45_rate,E46_rate,E47_rate,E49_rate,E50_rate,E51_rate,E52_rate,E53_rate,E55_rate,E56_rate,E65_rate,E66_rate,E67_rate
         ,E68_rate,E69_rate,EEI_rate,EGM_rate,EGR_rate,E03_rate,E05_rate,E06_rate,E07_rate,E36_rate,E38_rate,E41_rate,E42_rate,E43_rate,E74_rate,EAA_rate,EAG_rate,EAZ_rate,EBQ_rate,EC4_rate,ECT_rate,EDB_rate,EEQ_rate,EBK_rate,ECJ_rate,E33_rate,ECX_rate,EEF_rate,EGV_rate,ECD_rate,ECE_rate,ECM_rate
         ,ECN_rate,ECO_rate,ECP_rate,ECS_rate) as pd_rate
,sum(w.net_pay) as net_pay
,coalesce(E01_net_pay,E02_net_pay,E17_net_pay,E18_net_pay,E20_net_pay,E37_net_pay,E39_net_pay,E61_net_pay,E63_net_pay,E64_net_pay,E70_net_pay,ECG_net_pay,EDH_net_pay,EEC_net_pay,EG1_net_pay,EG2_net_pay,EG6_net_pay,EGC_net_pay,EGP_net_pay,EGZ_net_pay,EH1_net_pay,EHB_net_pay
         ,E15_net_pay,E29_net_pay,E30_net_pay,E31_net_pay,E48_net_pay,E62_net_pay,E71_net_pay,EC0_net_pay,EC1_net_pay,EC8_net_pay,ECH_net_pay,ECI_net_pay,ECU_net_pay,ECV_net_pay,EDI_net_pay,EEL_net_pay,EG0_net_pay,E16_net_pay,EAH_net_pay,EGS_net_pay,EGW_net_pay,EHC_net_pay
         ,E04_net_pay,E08_net_pay,E13_net_pay,E22_net_pay,E23_net_pay,E25_net_pay,E28_net_pay,E40_net_pay,E44_net_pay,E72_net_pay,E90_net_pay,E96_net_pay,EA1_net_pay,EA2_net_pay,EA4_net_pay,EC5_net_pay,EDK_net_pay,EED_net_pay,E24_net_pay,EEJ_net_pay,EA0_net_pay,EBM_net_pay
         ,E32_net_pay,EA3_net_pay,EBO_net_pay,EBS_net_pay,EBU_net_pay,EC3_net_pay,EGB_net_pay,E19_net_pay,EMR_net_pay,EXN_net_pay,EXT_net_pay,E09_net_pay,E12_net_pay,E14_net_pay,E26_net_pay,E27_net_pay,E45_net_pay,E46_net_pay,E47_net_pay,E49_net_pay,E50_net_pay,E51_net_pay
         ,E52_net_pay,E53_net_pay,E55_net_pay,E56_net_pay,E65_net_pay,E66_net_pay,E67_net_pay,E68_net_pay,E69_net_pay,EEI_net_pay,EHG_net_pay,EGM_net_pay,EGR_net_pay,E03_net_pay,E05_net_pay,E06_net_pay,E07_net_pay,E36_net_pay,E38_net_pay,E41_net_pay,E42_net_pay,E43_net_pay
         ,E74_net_pay,EAA_net_pay,EAG_net_pay,EAZ_net_pay,EBQ_net_pay,EC4_net_pay,ECT_net_pay,EDB_net_pay,EEQ_net_pay,EBK_net_pay,ECJ_net_pay,E33_net_pay,ECX_net_pay,EEF_net_pay,EGV_net_pay,ECD_net_pay,ECE_net_pay,ECM_net_pay,ECN_net_pay,ECO_net_pay,ECP_net_pay,ECS_net_pay) as pd_net_pay
,sum(w.gross_pay) as gross_pay
,coalesce(E01_gross_pay,E02_gross_pay,E17_gross_pay,E18_gross_pay,E20_gross_pay,E37_gross_pay,E39_gross_pay,E61_gross_pay,E63_gross_pay,E64_gross_pay,E70_gross_pay,ECG_gross_pay,EDH_gross_pay,EEC_gross_pay,EG1_gross_pay,EG2_gross_pay,EG6_gross_pay,EGC_gross_pay,EGP_gross_pay,EGZ_gross_pay
         ,EHB_gross_pay,EHC_gross_pay,EHG_gross_pay,E15_gross_pay,E29_gross_pay,E30_gross_pay,E31_gross_pay,E48_gross_pay,E62_gross_pay,E71_gross_pay,EC0_gross_pay,EC1_gross_pay,EC8_gross_pay,ECH_gross_pay,ECI_gross_pay,ECU_gross_pay,EC8_gross_pay,ECH_gross_pay,ECI_gross_pay,ECU_gross_pay
         ,ECV_gross_pay,EDI_gross_pay,EEL_gross_pay,EG0_gross_pay,E16_gross_pay,EAH_gross_pay,EGS_gross_pay,EGW_gross_pay,E04_gross_pay,E08_gross_pay,E13_gross_pay,E22_gross_pay,E23_gross_pay,E25_gross_pay,E28_gross_pay,E40_gross_pay,E44_gross_pay,E72_gross_pay,e90_gross_pay,E96_gross_pay
         ,EA1_gross_pay,EA2_gross_pay,EA4_gross_pay,EC5_gross_pay,EDK_gross_pay,EED_gross_pay,E24_gross_pay,EEJ_gross_pay,EA0_gross_pay,EBM_gross_pay,E32_gross_pay,EA3_gross_pay,EBO_gross_pay,EBS_gross_pay,EBU_gross_pay,EC3_gross_pay,EGB_gross_pay,E19_gross_pay,EMR_gross_pay,EXN_gross_pay
         ,EXT_gross_pay,E09_gross_pay,E12_gross_pay,E14_gross_pay,E26_gross_pay,E27_gross_pay,E45_gross_pay,E46_gross_pay,E47_gross_pay,E49_gross_pay,E50_gross_pay,E51_gross_pay,E52_gross_pay,E53_gross_pay,E55_gross_pay,E56_gross_pay,E65_gross_pay,E66_gross_pay,E67_gross_pay,E68_gross_pay
         ,EH1_gross_pay,E69_gross_pay,EEI_gross_pay,EGM_gross_pay,EGR_gross_pay,E03_gross_pay,E05_gross_pay,E06_gross_pay,E07_gross_pay,E36_gross_pay,E38_gross_pay,E41_gross_pay,E42_gross_pay,E43_gross_pay,E74_gross_pay,EAA_gross_pay,EAG_gross_pay,EAZ_gross_pay,EBQ_gross_pay,EC4_gross_pay
         ,ECT_gross_pay,EDB_gross_pay,EEQ_gross_pay,EBK_gross_pay,ECJ_gross_pay,E33_gross_pay,ECX_gross_pay,EEF_gross_pay,EGV_gross_pay,ECD_gross_pay,ECE_gross_pay,ECM_gross_pay,ECN_gross_pay,ECO_gross_pay,ECP_gross_pay,ECS_gross_pay) as pd_gross_pay
,sum(w.ytd_hrs) as ytd_hrs
,coalesce(E01_ytd_hrs,E02_ytd_hrs,E17_ytd_hrs,E18_ytd_hrs,E20_ytd_hrs,E37_ytd_hrs,E39_ytd_hrs,E61_ytd_hrs,E63_ytd_hrs,E64_ytd_hrs,E70_ytd_hrs,ECG_ytd_hrs,EDH_ytd_hrs,EEC_ytd_hrs,EG1_ytd_hrs,EG2_ytd_hrs,EG6_ytd_hrs,EGC_ytd_hrs,EGP_ytd_hrs,EGZ_ytd_hrs,ECV_ytd_hrs,EDI_ytd_hrs
         ,EEL_ytd_hrs,EG0_ytd_hrs,E15_ytd_hrs,E29_ytd_hrs,E30_ytd_hrs,E31_ytd_hrs,E48_ytd_hrs,E62_ytd_hrs,E71_ytd_hrs,EC0_ytd_hrs,EC1_ytd_hrs,EC8_ytd_hrs,ECH_ytd_hrs,ECI_ytd_hrs,ECU_ytd_hrs,ECV_ytd_hrs,EDI_ytd_hrs,EEL_ytd_hrs,EG0_ytd_hrs,E16_ytd_hrs,EAH_ytd_hrs,EGS_ytd_hrs
         ,E04_ytd_hrs,E08_ytd_hrs,E13_ytd_hrs,E22_ytd_hrs,E23_ytd_hrs,E24_ytd_hrs,E25_ytd_hrs,E28_ytd_hrs,E40_ytd_hrs,E44_ytd_hrs,E72_ytd_hrs,E90_ytd_hrs,E96_ytd_hrs,EA1_ytd_hrs,EA2_ytd_hrs,EA4_ytd_hrs,EC5_ytd_hrs,EDK_ytd_hrs,EED_ytd_hrs,EEJ_ytd_hrs,EA0_ytd_hrs,EBM_ytd_hrs
         ,E32_ytd_hrs,EA3_ytd_hrs,EBO_ytd_hrs,EBS_ytd_hrs,EBU_ytd_hrs,EC3_ytd_hrs,EGB_ytd_hrs,E19_ytd_hrs,EMR_ytd_hrs,EXN_ytd_hrs,EXT_ytd_hrs,E09_ytd_hrs,E12_ytd_hrs,E14_ytd_hrs,E26_ytd_hrs,E27_ytd_hrs,E45_ytd_hrs,E46_ytd_hrs,E47_ytd_hrs,E49_ytd_hrs,E50_ytd_hrs,E51_ytd_hrs
         ,EGW_ytd_hrs,E52_ytd_hrs,E53_ytd_hrs,E55_ytd_hrs,E56_ytd_hrs,E65_ytd_hrs,E66_ytd_hrs,E67_ytd_hrs,E68_ytd_hrs,E69_ytd_hrs,EEI_ytd_hrs,EGM_ytd_hrs,EGR_ytd_hrs,E03_ytd_hrs,E05_ytd_hrs,E06_ytd_hrs,E07_ytd_hrs,E36_ytd_hrs,E38_ytd_hrs,E41_ytd_hrs,E42_ytd_hrs,E43_ytd_hrs
         ,E74_ytd_hrs,EAA_ytd_hrs,EAG_ytd_hrs,EAZ_ytd_hrs,EBQ_ytd_hrs,EC4_ytd_hrs,ECT_ytd_hrs,EDB_ytd_hrs,EEQ_ytd_hrs,EBK_ytd_hrs,ECJ_ytd_hrs,E33_ytd_hrs,ECX_ytd_hrs,EEF_ytd_hrs,EGV_ytd_hrs,ECD_ytd_hrs,ECE_ytd_hrs,ECM_ytd_hrs,ECN_ytd_hrs,ECO_ytd_hrs,ECP_ytd_hrs,ECS_ytd_hrs) as pd_ytd_hrs
,sum(w.ytd_wage) as ytd_wage
,coalesce(E01_ytd_wage,E02_ytd_wage,E17_ytd_wage,E18_ytd_wage,E20_ytd_wage,E37_ytd_wage,E39_ytd_wage,E61_ytd_wage,E63_ytd_wage,E64_ytd_wage,E70_ytd_wage,ECG_ytd_wage,EDH_ytd_wage,EEC_ytd_wage,EG1_ytd_wage,EG2_ytd_wage,EG6_ytd_wage,EGC_ytd_wage,EGP_ytd_wage,EGZ_ytd_wage,EH1_ytd_wage
         ,EHB_ytd_wage,EHC_ytd_wage,EHG_ytd_wage,E15_ytd_wage,E29_ytd_wage,E30_ytd_wage,E31_ytd_wage,E48_ytd_wage,E62_ytd_wage,E71_ytd_wage,EC0_ytd_wage,EC1_ytd_wage,EC8_ytd_wage,ECH_ytd_wage,ECI_ytd_wage,ECU_ytd_wage,ECV_ytd_wage,EDI_ytd_wage,EEL_ytd_wage,EG0_ytd_wage,E16_ytd_wage
         ,EAH_ytd_wage,EGS_ytd_wage,EGW_ytd_wage,E04_ytd_wage,E08_ytd_wage,E13_ytd_wage,E22_ytd_wage,E23_ytd_wage,E24_ytd_wage,E25_ytd_wage,E28_ytd_wage,E28_ytd_wage,E40_ytd_wage,E44_ytd_wage,E72_ytd_wage,E90_ytd_wage,E96_ytd_wage,EA1_ytd_wage,EA2_ytd_wage,EA4_ytd_wage,EC5_ytd_wage
         ,EDK_ytd_wage,EED_ytd_wage,EEJ_ytd_wage,EA0_ytd_wage,EBM_ytd_wage,E32_ytd_wage,EA3_ytd_wage,EA3_ytd_wage,EBS_ytd_wage,EBU_ytd_wage,EC3_ytd_wage,EGB_ytd_wage,E19_ytd_wage,EMR_ytd_wage,EXN_ytd_wage,EXT_ytd_wage,E09_ytd_wage,E12_ytd_wage,E14_ytd_wage,E26_ytd_wage,E27_ytd_wage
         ,E45_ytd_wage,E46_ytd_wage,E47_ytd_wage,E49_ytd_wage,E50_ytd_wage,E51_ytd_wage,E52_ytd_wage,E53_ytd_wage,E55_ytd_wage,E56_ytd_wage,E65_ytd_wage,E66_ytd_wage,E67_ytd_wage,E68_ytd_wage,E69_ytd_wage,EEI_ytd_wage,EGM_ytd_wage,EGR_ytd_wage,E03_ytd_wage,E05_ytd_wage,E06_ytd_wage
         ,E07_ytd_wage,E36_ytd_wage,E38_ytd_wage,E41_ytd_wage,E42_ytd_wage,E43_ytd_wage,E74_ytd_wage,EAA_ytd_wage,EAG_ytd_wage,EAZ_ytd_wage,EBQ_ytd_wage,EC4_ytd_wage,ECT_ytd_wage,EDB_ytd_wage,EEQ_ytd_wage,EBK_ytd_wage,ECJ_ytd_wage,E33_ytd_wage,ECX_ytd_wage,EEF_ytd_wage,EGV_ytd_wage
         ,ECD_ytd_wage,ECE_ytd_wage,ECM_ytd_wage,ECN_ytd_wage,ECO_ytd_wage,ECP_ytd_wage,ECS_ytd_wage) as pd_ytd_wage

from 
( SELECT ph.personid,
    ph.paymentheaderid,
    pp.pspaypayrollid,
    pes.personearnsetuppid,
    pd.paycode,
    pd.paycode::text || COALESCE('-'::text || pdd.etvname::text, ''::text) AS etvname,
    pd.amount AS amount,
    E01.amount as E01_amount,
    E02.amount as E02_amount,
    E17.amount as E17_amount,
    E18.amount as E18_amount,
    E20.amount as E20_amount,
    E37.amount as E37_amount,
    E39.amount as E39_amount,
    E61.amount as E61_amount,
    E63.amount as E63_amount,
    E64.amount as E64_amount,
    E70.amount as E70_amount,
    ECG.amount as ECG_amount,
    EDH.amount as EDH_amount,
    EEC.amount as EEC_amount,
    EG1.amount as EG1_amount,
    EG2.amount as EG2_amount,
    EG6.amount as EG6_amount,
    EGC.amount as EGC_amount,
    EGP.amount as EGP_amount,
    EGZ.amount as EGZ_amount,
    EH1.amount as EH1_amount,
    EHB.amount as EHB_amount,
    EHC.amount as EHC_amount,
    EHG.amount as EHG_amount,
    E15.amount as E15_amount,
    E29.amount as E29_amount,
    E30.amount as E30_amount,
    E31.amount as E31_amount,
    E48.amount as E48_amount,
    E62.amount as E62_amount,
    E71.amount as E71_amount,
    EC0.amount as EC0_amount,
    EC1.amount as EC1_amount,
    EC8.amount as EC8_amount,
    ECH.amount as ECH_amount,
    ECI.amount as ECI_amount,
    ECU.amount as ECU_amount,
    ECV.amount as ECV_amount,
    EDI.amount as EDI_amount,
    EEL.amount as EEL_amount,
    EG0.amount as EG0_amount,    
    
    pd.units AS hours,
    E01.hours as E01_hours,
    E02.hours as E02_hours,
    E17.hours as E17_hours,
    E18.hours as E18_hours,
    E20.hours as E20_hours,
    E37.hours as E37_hours,
    E39.hours as E39_hours,
    E61.hours as E61_hours,
    E63.hours as E63_hours,
    E64.hours as E64_hours,
    E70.hours as E70_hours,
    ECG.hours as ECG_hours,
    EDH.hours as EDH_hours,
    EEC.hours as EEC_hours,
    EG1.hours as EG1_hours,
    EG2.hours as EG2_hours,
    EG6.hours as EG6_hours,
    EGC.hours as EGC_hours,
    EGP.hours as EGP_hours,
    EGZ.hours as EGZ_hours,
    EH1.hours as EH1_hours,
    EHB.hours as EHB_hours,
    EHC.hours as EHC_hours,
    EHG.hours as EHG_hours,
    E15.hours as E15_hours,
    E29.hours as E29_hours,
    E30.hours as E30_hours,
    E31.hours as E31_hours,
    E48.hours as E48_hours,
    E62.hours as E62_hours,
    E71.hours as E71_hours,
    EC0.hours as EC0_hours,
    EC1.hours as EC1_hours,
    EC8.hours as EC8_hours,
    ECH.hours as ECH_hours,
    ECI.hours as ECI_hours,
    ECU.hours as ECU_hours,
    ECV.hours as ECV_hours,
    EDI.hours as EDI_hours,
    EEL.hours as EEL_hours,
    EG0.hours as EG0_hours,
        
    pd.rate AS rate,
    E01.rate as E01_rate,
    E02.rate as E02_rate,
    E17.rate as E17_rate,
    E18.rate as E18_rate,
    E20.rate as E20_rate,
    E37.rate as E37_rate,
    E39.rate as E39_rate,
    E61.rate as E61_rate,
    E63.rate as E63_rate,
    E64.rate as E64_rate,
    E70.rate as E70_rate,
    ECG.rate as ECG_rate,
    EDH.rate as EDH_rate,
    EEC.rate as EEC_rate,
    EG1.rate as EG1_rate,
    EG2.rate as EG2_rate,
    EG6.rate as EG6_rate,
    EGC.rate as EGC_rate,
    EGP.rate as EGP_rate,
    EGZ.rate as EGZ_rate,
    EH1.rate as EH1_rate,
    EHB.rate as EHB_rate,
    EHC.rate as EHC_rate,
    EHG.rate as EHG_rate,
    E15.rate as E15_rate,
    E29.rate as E29_rate,
    E30.rate as E30_rate,
    E31.rate as E31_rate,
    E48.rate as E48_rate,
    E62.rate as E62_rate,
    E71.rate as E71_rate,
    EC0.rate as EC0_rate,
    EC1.rate as EC1_rate,
    EC8.rate as EC8_rate,
    ECH.rate as ECH_rate,
    ECI.rate as ECI_rate,
    ECU.rate as ECU_rate,
    ECV.rate as ECV_rate,
    EDI.rate as EDI_rate,
    EEL.rate as EEL_rate,
    EG0.rate as EG0_rate,    
    
    ph.net_pay,
    E01.net_pay as E01_net_pay,
    E02.net_pay as E02_net_pay,
    E17.net_pay as E17_net_pay,
    E18.net_pay as E18_net_pay,
    E20.net_pay as E20_net_pay,
    E37.net_pay as E37_net_pay,
    E39.net_pay as E39_net_pay,
    E61.net_pay as E61_net_pay,
    E63.net_pay as E63_net_pay,
    E64.net_pay as E64_net_pay,
    E70.net_pay as E70_net_pay,
    ECG.net_pay as ECG_net_pay,
    EDH.net_pay as EDH_net_pay,
    EEC.net_pay as EEC_net_pay,
    EG1.net_pay as EG1_net_pay,
    EG2.net_pay as EG2_net_pay,
    EG6.net_pay as EG6_net_pay,
    EGC.net_pay as EGC_net_pay,
    EGP.net_pay as EGP_net_pay,
    EGZ.net_pay as EGZ_net_pay,
    EH1.net_pay as EH1_net_pay,
    EHB.net_pay as EHB_net_pay,
    EHC.net_pay as EHC_net_pay,
    EHG.net_pay as EHG_net_pay,
    E15.net_pay as E15_net_pay,
    E29.net_pay as E29_net_pay,
    E30.net_pay as E30_net_pay,
    E31.net_pay as E31_net_pay,
    E48.net_pay as E48_net_pay,
    E62.net_pay as E62_net_pay,
    E71.net_pay as E71_net_pay,
    EC0.net_pay as EC0_net_pay,
    EC1.net_pay as EC1_net_pay,
    EC8.net_pay as EC8_net_pay,
    ECH.net_pay as ECH_net_pay,
    ECI.net_pay as ECI_net_pay,
    ECU.net_pay as ECU_net_pay,
    ECV.net_pay as ECV_net_pay,
    EDI.net_pay as EDI_net_pay,
    EEL.net_pay as EEL_net_pay,
    EG0.net_pay as EG0_net_pay,    
    
    ph.gross_pay,
    E01.gross_pay as E01_gross_pay,
    E02.gross_pay as E02_gross_pay,
    E17.gross_pay as E17_gross_pay,
    E18.gross_pay as E18_gross_pay,
    E20.gross_pay as E20_gross_pay,
    E37.gross_pay as E37_gross_pay,
    E39.gross_pay as E39_gross_pay,
    E61.gross_pay as E61_gross_pay,
    E63.gross_pay as E63_gross_pay,
    E64.gross_pay as E64_gross_pay,
    E70.gross_pay as E70_gross_pay,
    ECG.gross_pay as ECG_gross_pay,
    EDH.gross_pay as EDH_gross_pay,
    EEC.gross_pay as EEC_gross_pay,
    EG1.gross_pay as EG1_gross_pay,
    EG2.gross_pay as EG2_gross_pay,
    EG6.gross_pay as EG6_gross_pay,
    EGC.gross_pay as EGC_gross_pay,
    EGP.gross_pay as EGP_gross_pay,
    EGZ.gross_pay as EGZ_gross_pay,
    EH1.gross_pay as EH1_gross_pay,
    EHB.gross_pay as EHB_gross_pay,
    EHC.gross_pay as EHC_gross_pay,
    EHG.gross_pay as EHG_gross_pay,
    E15.gross_pay as E15_gross_pay,
    E29.gross_pay as E29_gross_pay,
    E30.gross_pay as E30_gross_pay,
    E31.gross_pay as E31_gross_pay,
    E48.gross_pay as E48_gross_pay,
    E62.gross_pay as E62_gross_pay,
    E71.gross_pay as E71_gross_pay,
    EC0.gross_pay as EC0_gross_pay,
    EC1.gross_pay as EC1_gross_pay,
    EC8.gross_pay as EC8_gross_pay,
    ECH.gross_pay as ECH_gross_pay,
    ECI.gross_pay as ECI_gross_pay,
    ECU.gross_pay as ECU_gross_pay,
    ECV.gross_pay as ECV_gross_pay,    
    EDI.gross_pay as EDI_gross_pay,
    EEL.gross_pay as EEL_gross_pay,
    EG0.gross_pay as EG0_gross_pay,    
    
    pd.units_ytd AS ytd_hrs,
    E01.ytd_hrs as E01_ytd_hrs,
    E02.ytd_hrs as E02_ytd_hrs,
    E17.ytd_hrs as E17_ytd_hrs,
    E18.ytd_hrs as E18_ytd_hrs,
    E20.ytd_hrs as E20_ytd_hrs,
    E37.ytd_hrs as E37_ytd_hrs,
    E39.ytd_hrs as E39_ytd_hrs,
    E61.ytd_hrs as E61_ytd_hrs,
    E63.ytd_hrs as E63_ytd_hrs,
    E64.ytd_hrs as E64_ytd_hrs,
    E70.ytd_hrs as E70_ytd_hrs,
    ECG.ytd_hrs as ECG_ytd_hrs,
    EDH.ytd_hrs as EDH_ytd_hrs,
    EEC.ytd_hrs as EEC_ytd_hrs,
    EG1.ytd_hrs as EG1_ytd_hrs,
    EG2.ytd_hrs as EG2_ytd_hrs,
    EG6.ytd_hrs as EG6_ytd_hrs,
    EGC.ytd_hrs as EGC_ytd_hrs,
    EGP.ytd_hrs as EGP_ytd_hrs,
    EGZ.ytd_hrs as EGZ_ytd_hrs,
    EH1.ytd_hrs as EH1_ytd_hrs,
    EHB.ytd_hrs as EHB_ytd_hrs,
    EHC.ytd_hrs as EHC_ytd_hrs,
    EHG.ytd_hrs as EHG_ytd_hrs,
    E15.ytd_hrs as E15_ytd_hrs,
    E29.ytd_hrs as E29_ytd_hrs,
    E30.ytd_hrs as E30_ytd_hrs,
    E31.ytd_hrs as E31_ytd_hrs,
    E48.ytd_hrs as E48_ytd_hrs,
    E62.ytd_hrs as E62_ytd_hrs,
    E71.ytd_hrs as E71_ytd_hrs,
    EC0.ytd_hrs as EC0_ytd_hrs,
    EC1.ytd_hrs as EC1_ytd_hrs,
    EC8.ytd_hrs as EC8_ytd_hrs,
    ECH.ytd_hrs as ECH_ytd_hrs,
    ECI.ytd_hrs as ECI_ytd_hrs,
    ECU.ytd_hrs as ECU_ytd_hrs,
    ECV.ytd_hrs as ECV_ytd_hrs,
    EDI.ytd_hrs as EDI_ytd_hrs,
    EEL.ytd_hrs as EEL_ytd_hrs,
    EG0.ytd_hrs as EG0_ytd_hrs,
    
    
    pd.amount_ytd AS ytd_amount,
    E01.ytd_amount as E01_ytd_amount, 
    E02.ytd_amount as E02_ytd_amount,
    E17.ytd_amount as E17_ytd_amount,
    E18.ytd_amount as E18_ytd_amount,
    E20.ytd_amount as E20_ytd_amount,
    E37.ytd_amount as E37_ytd_amount,
    E39.ytd_amount as E39_ytd_amount,
    E61.ytd_amount as E61_ytd_amount,
    E63.ytd_amount as E63_ytd_amount,
    E64.ytd_amount as E64_ytd_amount,
    E70.ytd_amount as E70_ytd_amount,
    ECG.ytd_amount as ECG_ytd_amount,
    EDH.ytd_amount as EDH_ytd_amount,
    EEC.ytd_amount as EEC_ytd_amount,
    EG1.ytd_amount as EG1_ytd_amount,
    EG2.ytd_amount as EG2_ytd_amount,
    EG6.ytd_amount as EG6_ytd_amount,
    EGC.ytd_amount as EGC_ytd_amount,
    EGP.ytd_amount as EGP_ytd_amount,
    EGZ.ytd_amount as EGZ_ytd_amount,
    EH1.ytd_amount as EH1_ytd_amount,
    EHB.ytd_amount as EHB_ytd_amount,
    EHC.ytd_amount as EHC_ytd_amount,
    EHG.ytd_amount as EHG_ytd_amount,
    E15.ytd_amount as E15_ytd_amount,
    E29.ytd_amount as E29_ytd_amount,
    E30.ytd_amount as E30_ytd_amount,
    E31.ytd_amount as E31_ytd_amount,
    E48.ytd_amount as E48_ytd_amount,
    E62.ytd_amount as E62_ytd_amount,
    E71.ytd_amount as E71_ytd_amount,
    EC0.ytd_amount as EC0_ytd_amount,
    EC1.ytd_amount as EC1_ytd_amount,
    EC8.ytd_amount as EC8_ytd_amount,
    ECH.ytd_amount as ECH_ytd_amount,
    ECI.ytd_amount as ECI_ytd_amount,
    ECU.ytd_amount as ECU_ytd_amount,
    ECV.ytd_amount as ECV_ytd_amount,    
    EDI.ytd_amount as EDI_ytd_amount,
    EEL.ytd_amount as EEL_ytd_amount,
    EG0.ytd_amount as EG0_ytd_amount,
    
    pd.subject_wages_ytd AS ytd_wage,
    E01.subject_wages_ytd as E01_ytd_wage,
    E02.subject_wages_ytd as E02_ytd_wage,
    E17.subject_wages_ytd as E17_ytd_wage,
    E18.subject_wages_ytd as E18_ytd_wage,
    E20.subject_wages_ytd as E20_ytd_wage,
    E37.subject_wages_ytd as E37_ytd_wage,
    E39.subject_wages_ytd as E39_ytd_wage,
    E61.subject_wages_ytd as E61_ytd_wage,
    E63.subject_wages_ytd as E63_ytd_wage,
    E64.subject_wages_ytd as E64_ytd_wage,
    E70.subject_wages_ytd as E70_ytd_wage,
    ECG.subject_wages_ytd as ECG_ytd_wage,
    EDH.subject_wages_ytd as EDH_ytd_wage,
    EEC.subject_wages_ytd as EEC_ytd_wage,
    EG1.subject_wages_ytd as EG1_ytd_wage,
    EG2.subject_wages_ytd as EG2_ytd_wage,
    EG6.subject_wages_ytd as EG6_ytd_wage,
    EGC.subject_wages_ytd as EGC_ytd_wage,
    EGP.subject_wages_ytd as EGP_ytd_wage,
    EGZ.subject_wages_ytd as EGZ_ytd_wage,
    EH1.subject_wages_ytd as EH1_ytd_wage,
    EHB.subject_wages_ytd as EHB_ytd_wage,
    EHC.subject_wages_ytd as EHC_ytd_wage,
    EHG.subject_wages_ytd as EHG_ytd_wage,
    E15.subject_wages_ytd as E15_ytd_wage,
    E29.subject_wages_ytd as E29_ytd_wage,
    E30.subject_wages_ytd as E30_ytd_wage,
    E31.subject_wages_ytd as E31_ytd_wage,
    E48.subject_wages_ytd as E48_ytd_wage,
    E62.subject_wages_ytd as E62_ytd_wage,
    E71.subject_wages_ytd as E71_ytd_wage,
    EC0.subject_wages_ytd as EC0_ytd_wage,
    EC1.subject_wages_ytd as EC1_ytd_wage,
    EC8.subject_wages_ytd as EC8_ytd_wage,
    ECH.subject_wages_ytd as ECH_ytd_wage,
    ECI.subject_wages_ytd as ECI_ytd_wage,
    ECU.subject_wages_ytd as ECU_ytd_wage,
    ECV.subject_wages_ytd as ECV_ytd_wage,
    EDI.subject_wages_ytd as EDI_ytd_wage,
    EEL.subject_wages_ytd as EEL_ytd_wage,
    EG0.subject_wages_ytd as EG0_ytd_wage,
    
E16.amount as E16_amount,
E16.hours as E16_hours,
E16.rate as E16_rate, 
E16.net_pay as E16_net_pay,
E16.gross_pay as E16_gross_pay,
E16.ytd_hrs as E16_ytd_hrs,
E16.ytd_amount as E16_ytd_amount,
E16.subject_wages_ytd as E16_ytd_wage,

EAH.amount as EAH_amount,
EAH.hours as EAH_hours,
EAH.rate as EAH_rate, 
EAH.net_pay as EAH_net_pay,
EAH.gross_pay as EAH_gross_pay,
EAH.ytd_hrs as EAH_ytd_hrs,
EAH.ytd_amount as EAH_ytd_amount,
EAH.subject_wages_ytd as EAH_ytd_wage,

EGS.amount as EGS_amount,
EGS.hours as EGS_hours,
EGS.rate as EGS_rate, 
EGS.net_pay as EGS_net_pay,
EGS.gross_pay as EGS_gross_pay,
EGS.ytd_hrs as EGS_ytd_hrs,
EGS.ytd_amount as EGS_ytd_amount,
EGS.subject_wages_ytd as EGS_ytd_wage,

EGW.amount as EGW_amount,
EGW.hours as EGW_hours,
EGW.rate as EGW_rate, 
EGW.net_pay as EGW_net_pay,
EGW.gross_pay as EGW_gross_pay,
EGW.ytd_hrs as EGW_ytd_hrs,
EGW.ytd_amount as EGW_ytd_amount,
EGW.subject_wages_ytd as EGW_ytd_wage,

E04.amount as E04_amount,
E04.hours as E04_hours,
E04.rate as E04_rate, 
E04.net_pay as E04_net_pay,
E04.gross_pay as E04_gross_pay,
E04.ytd_hrs as E04_ytd_hrs,
E04.ytd_amount as E04_ytd_amount,
E04.subject_wages_ytd as E04_ytd_wage,

E08.amount as E08_amount,
E08.hours as E08_hours,
E08.rate as E08_rate, 
E08.net_pay as E08_net_pay,
E08.gross_pay as E08_gross_pay,
E08.ytd_hrs as E08_ytd_hrs,
E08.ytd_amount as E08_ytd_amount,
E08.subject_wages_ytd as E08_ytd_wage,

E13.amount as E13_amount,
E13.hours as E13_hours,
E13.rate as E13_rate, 
E13.net_pay as E13_net_pay,
E13.gross_pay as E13_gross_pay,
E13.ytd_hrs as E13_ytd_hrs,
E13.ytd_amount as E13_ytd_amount,
E13.subject_wages_ytd as E13_ytd_wage,

E22.amount as E22_amount,
E22.hours as E22_hours,
E22.rate as E22_rate, 
E22.net_pay as E22_net_pay,
E22.gross_pay as E22_gross_pay,
E22.ytd_hrs as E22_ytd_hrs,
E22.ytd_amount as E22_ytd_amount,
E22.subject_wages_ytd as E22_ytd_wage,
E23.amount as E23_amount,
E23.hours as E23_hours,
E23.rate as E23_rate, 
E23.net_pay as E23_net_pay,
E23.gross_pay as E23_gross_pay,
E23.ytd_hrs as E23_ytd_hrs,
E23.ytd_amount as E23_ytd_amount,
E23.subject_wages_ytd as E23_ytd_wage,
E24.amount as E24_amount,
E24.hours as E24_hours,
E24.rate as E24_rate, 
E24.net_pay as E24_net_pay,
E24.gross_pay as E24_gross_pay,
E24.ytd_hrs as E24_ytd_hrs,
E24.ytd_amount as E24_ytd_amount,
E24.subject_wages_ytd as E24_ytd_wage,
E25.amount as E25_amount,
E25.hours as E25_hours,
E25.rate as E25_rate, 
E25.net_pay as E25_net_pay,
E25.gross_pay as E25_gross_pay,
E25.ytd_hrs as E25_ytd_hrs,
E25.ytd_amount as E25_ytd_amount,
E25.subject_wages_ytd as E25_ytd_wage,
E28.amount as E28_amount,
E28.hours as E28_hours,
E28.rate as E28_rate, 
E28.net_pay as E28_net_pay,
E28.gross_pay as E28_gross_pay,
E28.ytd_hrs as E28_ytd_hrs,
E28.ytd_amount as E28_ytd_amount,
E28.subject_wages_ytd as E28_ytd_wage,
E40.amount as E40_amount,
E40.hours as E40_hours,
E40.rate as E40_rate, 
E40.net_pay as E40_net_pay,
E40.gross_pay as E40_gross_pay,
E40.ytd_hrs as E40_ytd_hrs,
E40.ytd_amount as E40_ytd_amount,
E40.subject_wages_ytd as E40_ytd_wage,
E44.amount as E44_amount,
E44.hours as E44_hours,
E44.rate as E44_rate, 
E44.net_pay as E44_net_pay,
E44.gross_pay as E44_gross_pay,
E44.ytd_hrs as E44_ytd_hrs,
E44.ytd_amount as E44_ytd_amount,
E44.subject_wages_ytd as E44_ytd_wage,
E72.amount as E72_amount,
E72.hours as E72_hours,
E72.rate as E72_rate, 
E72.net_pay as E72_net_pay,
E72.gross_pay as E72_gross_pay,
E72.ytd_hrs as E72_ytd_hrs,
E72.ytd_amount as E72_ytd_amount,
E72.subject_wages_ytd as E72_ytd_wage,
E90.amount as E90_amount,
E90.hours as E90_hours,
E90.rate as E90_rate, 
E90.net_pay as E90_net_pay,
E90.gross_pay as E90_gross_pay,
E90.ytd_hrs as E90_ytd_hrs,
E90.ytd_amount as E90_ytd_amount,
E90.subject_wages_ytd as E90_ytd_wage,
E96.amount as E96_amount,
E96.hours as E96_hours,
E96.rate as E96_rate, 
E96.net_pay as E96_net_pay,
E96.gross_pay as E96_gross_pay,
E96.ytd_hrs as E96_ytd_hrs,
E96.ytd_amount as E96_ytd_amount,
E96.subject_wages_ytd as E96_ytd_wage,
EA1.amount as EA1_amount,
EA1.hours as EA1_hours,
EA1.rate as EA1_rate, 
EA1.net_pay as EA1_net_pay,
EA1.gross_pay as EA1_gross_pay,
EA1.ytd_hrs as EA1_ytd_hrs,
EA1.ytd_amount as EA1_ytd_amount,
EA1.subject_wages_ytd as EA1_ytd_wage,
EA2.amount as EA2_amount,
EA2.hours as EA2_hours,
EA2.rate as EA2_rate, 
EA2.net_pay as EA2_net_pay,
EA2.gross_pay as EA2_gross_pay,
EA2.ytd_hrs as EA2_ytd_hrs,
EA2.ytd_amount as EA2_ytd_amount,
EA2.subject_wages_ytd as EA2_ytd_wage,
EA4.amount as EA4_amount,
EA4.hours as EA4_hours,
EA4.rate as EA4_rate, 
EA4.net_pay as EA4_net_pay,
EA4.gross_pay as EA4_gross_pay,
EA4.ytd_hrs as EA4_ytd_hrs,
EA4.ytd_amount as EA4_ytd_amount,
EA4.subject_wages_ytd as EA4_ytd_wage,
EC5.amount as EC5_amount,
EC5.hours as EC5_hours,
EC5.rate as EC5_rate, 
EC5.net_pay as EC5_net_pay,
EC5.gross_pay as EC5_gross_pay,
EC5.ytd_hrs as EC5_ytd_hrs,
EC5.ytd_amount as EC5_ytd_amount,
EC5.subject_wages_ytd as EC5_ytd_wage,
EDK.amount as EDK_amount,
EDK.hours as EDK_hours,
EDK.rate as EDK_rate, 
EDK.net_pay as EDK_net_pay,
EDK.gross_pay as EDK_gross_pay,
EDK.ytd_hrs as EDK_ytd_hrs,
EDK.ytd_amount as EDK_ytd_amount,
EDK.subject_wages_ytd as EDK_ytd_wage,
EED.amount as EED_amount,
EED.hours as EED_hours,
EED.rate as EED_rate, 
EED.net_pay as EED_net_pay,
EED.gross_pay as EED_gross_pay,
EED.ytd_hrs as EED_ytd_hrs,
EED.ytd_amount as EED_ytd_amount,
EED.subject_wages_ytd as EED_ytd_wage,
EEJ.amount as EEJ_amount,
EEJ.hours as EEJ_hours,
EEJ.rate as EEJ_rate, 
EEJ.net_pay as EEJ_net_pay,
EEJ.gross_pay as EEJ_gross_pay,
EEJ.ytd_hrs as EEJ_ytd_hrs,
EEJ.ytd_amount as EEJ_ytd_amount,
EEJ.subject_wages_ytd as EEJ_ytd_wage,
EBM.amount as EBM_amount,
EBM.hours as EBM_hours,
EBM.rate as EBM_rate, 
EBM.net_pay as EBM_net_pay,
EBM.gross_pay as EBM_gross_pay,
EBM.ytd_hrs as EBM_ytd_hrs,
EBM.ytd_amount as EBM_ytd_amount,
EBM.subject_wages_ytd as EBM_ytd_wage,
EA0.amount as EA0_amount,
EA0.hours as EA0_hours,
EA0.rate as EA0_rate, 
EA0.net_pay as EA0_net_pay,
EA0.gross_pay as EA0_gross_pay,
EA0.ytd_hrs as EA0_ytd_hrs,
EA0.ytd_amount as EA0_ytd_amount,
EA0.subject_wages_ytd as EA0_ytd_wage,
E32.amount as E32_amount,
E32.hours as E32_hours,
E32.rate as E32_rate, 
E32.net_pay as E32_net_pay,
E32.gross_pay as E32_gross_pay,
E32.ytd_hrs as E32_ytd_hrs,
E32.ytd_amount as E32_ytd_amount,
E32.subject_wages_ytd as E32_ytd_wage,
EA3.amount as EA3_amount,
EA3.hours as EA3_hours,
EA3.rate as EA3_rate, 
EA3.net_pay as EA3_net_pay,
EA3.gross_pay as EA3_gross_pay,
EA3.ytd_hrs as EA3_ytd_hrs,
EA3.ytd_amount as EA3_ytd_amount,
EA3.subject_wages_ytd as EA3_ytd_wage,
EBO.amount as EBO_amount,
EBO.hours as EBO_hours,
EBO.rate as EBO_rate, 
EBO.net_pay as EBO_net_pay,
EBO.gross_pay as EBO_gross_pay,
EBO.ytd_hrs as EBO_ytd_hrs,
EBO.ytd_amount as EBO_ytd_amount,
EBO.subject_wages_ytd as EBO_ytd_wage,
EBS.amount as EBS_amount,
EBS.hours as EBS_hours,
EBS.rate as EBS_rate, 
EBS.net_pay as EBS_net_pay,
EBS.gross_pay as EBS_gross_pay,
EBS.ytd_hrs as EBS_ytd_hrs,
EBS.ytd_amount as EBS_ytd_amount,
EBS.subject_wages_ytd as EBS_ytd_wage,
EBU.amount as EBU_amount,
EBU.hours as EBU_hours,
EBU.rate as EBU_rate, 
EBU.net_pay as EBU_net_pay,
EBU.gross_pay as EBU_gross_pay,
EBU.ytd_hrs as EBU_ytd_hrs,
EBU.ytd_amount as EBU_ytd_amount,
EBU.subject_wages_ytd as EBU_ytd_wage,
EC3.amount as EC3_amount,
EC3.hours as EC3_hours,
EC3.rate as EC3_rate, 
EC3.net_pay as EC3_net_pay,
EC3.gross_pay as EC3_gross_pay,
EC3.ytd_hrs as EC3_ytd_hrs,
EC3.ytd_amount as EC3_ytd_amount,
EC3.subject_wages_ytd as EC3_ytd_wage,
EGB.amount as EGB_amount,
EGB.hours as EGB_hours,
EGB.rate as EGB_rate, 
EGB.net_pay as EGB_net_pay,
EGB.gross_pay as EGB_gross_pay,
EGB.ytd_hrs as EGB_ytd_hrs,
EGB.ytd_amount as EGB_ytd_amount,
EGB.subject_wages_ytd as EGB_ytd_wage,
E19.amount as E19_amount,
E19.hours as E19_hours,
E19.rate as E19_rate, 
E19.net_pay as E19_net_pay,
E19.gross_pay as E19_gross_pay,
E19.ytd_hrs as E19_ytd_hrs,
E19.ytd_amount as E19_ytd_amount,
E19.subject_wages_ytd as E19_ytd_wage,
EMR.amount as EMR_amount,
EMR.hours as EMR_hours,
EMR.rate as EMR_rate, 
EMR.net_pay as EMR_net_pay,
EMR.gross_pay as EMR_gross_pay,
EMR.ytd_hrs as EMR_ytd_hrs,
EMR.ytd_amount as EMR_ytd_amount,
EMR.subject_wages_ytd as EMR_ytd_wage,
EXN.amount as EXN_amount,
EXN.hours as EXN_hours,
EXN.rate as EXN_rate, 
EXN.net_pay as EXN_net_pay,
EXN.gross_pay as EXN_gross_pay,
EXN.ytd_hrs as EXN_ytd_hrs,
EXN.ytd_amount as EXN_ytd_amount,
EXN.subject_wages_ytd as EXN_ytd_wage,
EXT.amount as EXT_amount,
EXT.hours as EXT_hours,
EXT.rate as EXT_rate, 
EXT.net_pay as EXT_net_pay,
EXT.gross_pay as EXT_gross_pay,
EXT.ytd_hrs as EXT_ytd_hrs,
EXT.ytd_amount as EXT_ytd_amount,
EXT.subject_wages_ytd as EXT_ytd_wage,
E09.amount as E09_amount,
E09.hours as E09_hours,
E09.rate as E09_rate, 
E09.net_pay as E09_net_pay,
E09.gross_pay as E09_gross_pay,
E09.ytd_hrs as E09_ytd_hrs,
E09.ytd_amount as E09_ytd_amount,
E09.subject_wages_ytd as E09_ytd_wage,
E12.amount as E12_amount,
E12.hours as E12_hours,
E12.rate as E12_rate, 
E12.net_pay as E12_net_pay,
E12.gross_pay as E12_gross_pay,
E12.ytd_hrs as E12_ytd_hrs,
E12.ytd_amount as E12_ytd_amount,
E12.subject_wages_ytd as E12_ytd_wage,
E14.amount as E14_amount,
E14.hours as E14_hours,
E14.rate as E14_rate, 
E14.net_pay as E14_net_pay,
E14.gross_pay as E14_gross_pay,
E14.ytd_hrs as E14_ytd_hrs,
E14.ytd_amount as E14_ytd_amount,
E14.subject_wages_ytd as E14_ytd_wage,
E26.amount as E26_amount,
E26.hours as E26_hours,
E26.rate as E26_rate, 
E26.net_pay as E26_net_pay,
E26.gross_pay as E26_gross_pay,
E26.ytd_hrs as E26_ytd_hrs,
E26.ytd_amount as E26_ytd_amount,
E26.subject_wages_ytd as E26_ytd_wage,
E27.amount as E27_amount,
E27.hours as E27_hours,
E27.rate as E27_rate, 
E27.net_pay as E27_net_pay,
E27.gross_pay as E27_gross_pay,
E27.ytd_hrs as E27_ytd_hrs,
E27.ytd_amount as E27_ytd_amount,
E27.subject_wages_ytd as E27_ytd_wage,
E45.amount as E45_amount,
E45.hours as E45_hours,
E45.rate as E45_rate, 
E45.net_pay as E45_net_pay,
E45.gross_pay as E45_gross_pay,
E45.ytd_hrs as E45_ytd_hrs,
E45.ytd_amount as E45_ytd_amount,
E45.subject_wages_ytd as E45_ytd_wage,
E46.amount as E46_amount,
E46.hours as E46_hours,
E46.rate as E46_rate, 
E46.net_pay as E46_net_pay,
E46.gross_pay as E46_gross_pay,
E46.ytd_hrs as E46_ytd_hrs,
E46.ytd_amount as E46_ytd_amount,
E46.subject_wages_ytd as E46_ytd_wage,
E47.amount as E47_amount,
E47.hours as E47_hours,
E47.rate as E47_rate, 
E47.net_pay as E47_net_pay,
E47.gross_pay as E47_gross_pay,
E47.ytd_hrs as E47_ytd_hrs,
E47.ytd_amount as E47_ytd_amount,
E47.subject_wages_ytd as E47_ytd_wage,
E49.amount as E49_amount,
E49.hours as E49_hours,
E49.rate as E49_rate, 
E49.net_pay as E49_net_pay,
E49.gross_pay as E49_gross_pay,
E49.ytd_hrs as E49_ytd_hrs,
E49.ytd_amount as E49_ytd_amount,
E49.subject_wages_ytd as E49_ytd_wage,
E50.amount as E50_amount,
E50.hours as E50_hours,
E50.rate as E50_rate, 
E50.net_pay as E50_net_pay,
E50.gross_pay as E50_gross_pay,
E50.ytd_hrs as E50_ytd_hrs,
E50.ytd_amount as E50_ytd_amount,
E50.subject_wages_ytd as E50_ytd_wage,
E51.amount as E51_amount,
E51.hours as E51_hours,
E51.rate as E51_rate, 
E51.net_pay as E51_net_pay,
E51.gross_pay as E51_gross_pay,
E51.ytd_hrs as E51_ytd_hrs,
E51.ytd_amount as E51_ytd_amount,
E51.subject_wages_ytd as E51_ytd_wage,
E52.amount as E52_amount,
E52.hours as E52_hours,
E52.rate as E52_rate, 
E52.net_pay as E52_net_pay,
E52.gross_pay as E52_gross_pay,
E52.ytd_hrs as E52_ytd_hrs,
E52.ytd_amount as E52_ytd_amount,
E52.subject_wages_ytd as E52_ytd_wage,
E53.amount as E53_amount,
E53.hours as E53_hours,
E53.rate as E53_rate, 
E53.net_pay as E53_net_pay,
E53.gross_pay as E53_gross_pay,
E53.ytd_hrs as E53_ytd_hrs,
E53.ytd_amount as E53_ytd_amount,
E53.subject_wages_ytd as E53_ytd_wage,
E55.amount as E55_amount,
E55.hours as E55_hours,
E55.rate as E55_rate, 
E55.net_pay as E55_net_pay,
E55.gross_pay as E55_gross_pay,
E55.ytd_hrs as E55_ytd_hrs,
E55.ytd_amount as E55_ytd_amount,
E55.subject_wages_ytd as E55_ytd_wage,
E56.amount as E56_amount,
E56.hours as E56_hours,
E56.rate as E56_rate, 
E56.net_pay as E56_net_pay,
E56.gross_pay as E56_gross_pay,
E56.ytd_hrs as E56_ytd_hrs,
E56.ytd_amount as E56_ytd_amount,
E56.subject_wages_ytd as E56_ytd_wage,
E65.amount as E65_amount,
E65.hours as E65_hours,
E65.rate as E65_rate, 
E65.net_pay as E65_net_pay,
E65.gross_pay as E65_gross_pay,
E65.ytd_hrs as E65_ytd_hrs,
E65.ytd_amount as E65_ytd_amount,
E65.subject_wages_ytd as E65_ytd_wage,
E66.amount as E66_amount,
E66.hours as E66_hours,
E66.rate as E66_rate, 
E66.net_pay as E66_net_pay,
E66.gross_pay as E66_gross_pay,
E66.ytd_hrs as E66_ytd_hrs,
E66.ytd_amount as E66_ytd_amount,
E66.subject_wages_ytd as E66_ytd_wage,
E67.amount as E67_amount,
E67.hours as E67_hours,
E67.rate as E67_rate, 
E67.net_pay as E67_net_pay,
E67.gross_pay as E67_gross_pay,
E67.ytd_hrs as E67_ytd_hrs,
E67.ytd_amount as E67_ytd_amount,
E67.subject_wages_ytd as E67_ytd_wage,
E68.amount as E68_amount,
E68.hours as E68_hours,
E68.rate as E68_rate, 
E68.net_pay as E68_net_pay,
E68.gross_pay as E68_gross_pay,
E68.ytd_hrs as E68_ytd_hrs,
E68.ytd_amount as E68_ytd_amount,
E68.subject_wages_ytd as E68_ytd_wage,
E69.amount as E69_amount,
E69.hours as E69_hours,
E69.rate as E69_rate, 
E69.net_pay as E69_net_pay,
E69.gross_pay as E69_gross_pay,
E69.ytd_hrs as E69_ytd_hrs,
E69.ytd_amount as E69_ytd_amount,
E69.subject_wages_ytd as E69_ytd_wage,
EEI.amount as EEI_amount,
EEI.hours as EEI_hours,
EEI.rate as EEI_rate, 
EEI.net_pay as EEI_net_pay,
EEI.gross_pay as EEI_gross_pay,
EEI.ytd_hrs as EEI_ytd_hrs,
EEI.ytd_amount as EEI_ytd_amount,
EEI.subject_wages_ytd as EEI_ytd_wage,
EGM.amount as EGM_amount,
EGM.hours as EGM_hours,
EGM.rate as EGM_rate, 
EGM.net_pay as EGM_net_pay,
EGM.gross_pay as EGM_gross_pay,
EGM.ytd_hrs as EGM_ytd_hrs,
EGM.ytd_amount as EGM_ytd_amount,
EGM.subject_wages_ytd as EGM_ytd_wage,
EGR.amount as EGR_amount,
EGR.hours as EGR_hours,
EGR.rate as EGR_rate, 
EGR.net_pay as EGR_net_pay,
EGR.gross_pay as EGR_gross_pay,
EGR.ytd_hrs as EGR_ytd_hrs,
EGR.ytd_amount as EGR_ytd_amount,
EGR.subject_wages_ytd as EGR_ytd_wage,
E03.amount as E03_amount,
E03.hours as E03_hours,
E03.rate as E03_rate, 
E03.net_pay as E03_net_pay,
E03.gross_pay as E03_gross_pay,
E03.ytd_hrs as E03_ytd_hrs,
E03.ytd_amount as E03_ytd_amount,
E03.subject_wages_ytd as E03_ytd_wage,
E05.amount as E05_amount,
E05.hours as E05_hours,
E05.rate as E05_rate, 
E05.net_pay as E05_net_pay,
E05.gross_pay as E05_gross_pay,
E05.ytd_hrs as E05_ytd_hrs,
E05.ytd_amount as E05_ytd_amount,
E05.subject_wages_ytd as E05_ytd_wage,
E06.amount as E06_amount,
E06.hours as E06_hours,
E06.rate as E06_rate, 
E06.net_pay as E06_net_pay,
E06.gross_pay as E06_gross_pay,
E06.ytd_hrs as E06_ytd_hrs,
E06.ytd_amount as E06_ytd_amount,
E06.subject_wages_ytd as E06_ytd_wage,
E07.amount as E07_amount,
E07.hours as E07_hours,
E07.rate as E07_rate, 
E07.net_pay as E07_net_pay,
E07.gross_pay as E07_gross_pay,
E07.ytd_hrs as E07_ytd_hrs,
E07.ytd_amount as E07_ytd_amount,
E07.subject_wages_ytd as E07_ytd_wage,
E36.amount as E36_amount,
E36.hours as E36_hours,
E36.rate as E36_rate, 
E36.net_pay as E36_net_pay,
E36.gross_pay as E36_gross_pay,
E36.ytd_hrs as E36_ytd_hrs,
E36.ytd_amount as E36_ytd_amount,
E36.subject_wages_ytd as E36_ytd_wage,
E38.amount as E38_amount,
E38.hours as E38_hours,
E38.rate as E38_rate, 
E38.net_pay as E38_net_pay,
E38.gross_pay as E38_gross_pay,
E38.ytd_hrs as E38_ytd_hrs,
E38.ytd_amount as E38_ytd_amount,
E38.subject_wages_ytd as E38_ytd_wage,
E41.amount as E41_amount,
E41.hours as E41_hours,
E41.rate as E41_rate, 
E41.net_pay as E41_net_pay,
E41.gross_pay as E41_gross_pay,
E41.ytd_hrs as E41_ytd_hrs,
E41.ytd_amount as E41_ytd_amount,
E41.subject_wages_ytd as E41_ytd_wage,
E42.amount as E42_amount,
E42.hours as E42_hours,
E42.rate as E42_rate, 
E42.net_pay as E42_net_pay,
E42.gross_pay as E42_gross_pay,
E42.ytd_hrs as E42_ytd_hrs,
E42.ytd_amount as E42_ytd_amount,
E42.subject_wages_ytd as E42_ytd_wage,
E43.amount as E43_amount,
E43.hours as E43_hours,
E43.rate as E43_rate, 
E43.net_pay as E43_net_pay,
E43.gross_pay as E43_gross_pay,
E43.ytd_hrs as E43_ytd_hrs,
E43.ytd_amount as E43_ytd_amount,
E43.subject_wages_ytd as E43_ytd_wage,
E74.amount as E74_amount,
E74.hours as E74_hours,
E74.rate as E74_rate, 
E74.net_pay as E74_net_pay,
E74.gross_pay as E74_gross_pay,
E74.ytd_hrs as E74_ytd_hrs,
E74.ytd_amount as E74_ytd_amount,
E74.subject_wages_ytd as E74_ytd_wage,
EAA.amount as EAA_amount,
EAA.hours as EAA_hours,
EAA.rate as EAA_rate, 
EAA.net_pay as EAA_net_pay,
EAA.gross_pay as EAA_gross_pay,
EAA.ytd_hrs as EAA_ytd_hrs,
EAA.ytd_amount as EAA_ytd_amount,
EAA.subject_wages_ytd as EAA_ytd_wage,
EAG.amount as EAG_amount,
EAG.hours as EAG_hours,
EAG.rate as EAG_rate, 
EAG.net_pay as EAG_net_pay,
EAG.gross_pay as EAG_gross_pay,
EAG.ytd_hrs as EAG_ytd_hrs,
EAG.ytd_amount as EAG_ytd_amount,
EAG.subject_wages_ytd as EAG_ytd_wage,
EAZ.amount as EAZ_amount,
EAZ.hours as EAZ_hours,
EAZ.rate as EAZ_rate, 
EAZ.net_pay as EAZ_net_pay,
EAZ.gross_pay as EAZ_gross_pay,
EAZ.ytd_hrs as EAZ_ytd_hrs,
EAZ.ytd_amount as EAZ_ytd_amount,
EAZ.subject_wages_ytd as EAZ_ytd_wage,
EBQ.amount as EBQ_amount,
EBQ.hours as EBQ_hours,
EBQ.rate as EBQ_rate, 
EBQ.net_pay as EBQ_net_pay,
EBQ.gross_pay as EBQ_gross_pay,
EBQ.ytd_hrs as EBQ_ytd_hrs,
EBQ.ytd_amount as EBQ_ytd_amount,
EBQ.subject_wages_ytd as EBQ_ytd_wage,
EC4.amount as EC4_amount,
EC4.hours as EC4_hours,
EC4.rate as EC4_rate, 
EC4.net_pay as EC4_net_pay,
EC4.gross_pay as EC4_gross_pay,
EC4.ytd_hrs as EC4_ytd_hrs,
EC4.ytd_amount as EC4_ytd_amount,
EC4.subject_wages_ytd as EC4_ytd_wage,
ECT.amount as ECT_amount,
ECT.hours as ECT_hours,
ECT.rate as ECT_rate, 
ECT.net_pay as ECT_net_pay,
ECT.gross_pay as ECT_gross_pay,
ECT.ytd_hrs as ECT_ytd_hrs,
ECT.ytd_amount as ECT_ytd_amount,
ECT.subject_wages_ytd as ECT_ytd_wage,
EDB.amount as EDB_amount,
EDB.hours as EDB_hours,
EDB.rate as EDB_rate, 
EDB.net_pay as EDB_net_pay,
EDB.gross_pay as EDB_gross_pay,
EDB.ytd_hrs as EDB_ytd_hrs,
EDB.ytd_amount as EDB_ytd_amount,
EDB.subject_wages_ytd as EDB_ytd_wage,
EEQ.amount as EEQ_amount,
EEQ.hours as EEQ_hours,
EEQ.rate as EEQ_rate, 
EEQ.net_pay as EEQ_net_pay,
EEQ.gross_pay as EEQ_gross_pay,
EEQ.ytd_hrs as EEQ_ytd_hrs,
EEQ.ytd_amount as EEQ_ytd_amount,
EEQ.subject_wages_ytd as EEQ_ytd_wage,
ECJ.amount as ECJ_amount,
ECJ.hours as ECJ_hours,
ECJ.rate as ECJ_rate, 
ECJ.net_pay as ECJ_net_pay,
ECJ.gross_pay as ECJ_gross_pay,
ECJ.ytd_hrs as ECJ_ytd_hrs,
ECJ.ytd_amount as ECJ_ytd_amount,
ECJ.subject_wages_ytd as ECJ_ytd_wage,
EBK.amount as EBK_amount,
EBK.hours as EBK_hours,
EBK.rate as EBK_rate, 
EBK.net_pay as EBK_net_pay,
EBK.gross_pay as EBK_gross_pay,
EBK.ytd_hrs as EBK_ytd_hrs,
EBK.ytd_amount as EBK_ytd_amount,
EBK.subject_wages_ytd as EBK_ytd_wage,
ECX.amount as ECX_amount,
ECX.hours as ECX_hours,
ECX.rate as ECX_rate, 
ECX.net_pay as ECX_net_pay,
ECX.gross_pay as ECX_gross_pay,
ECX.ytd_hrs as ECX_ytd_hrs,
ECX.ytd_amount as ECX_ytd_amount,
ECX.subject_wages_ytd as ECX_ytd_wage,
E33.amount as E33_amount,
E33.hours as E33_hours,
E33.rate as E33_rate, 
E33.net_pay as E33_net_pay,
E33.gross_pay as E33_gross_pay,
E33.ytd_hrs as E33_ytd_hrs,
E33.ytd_amount as E33_ytd_amount,
E33.subject_wages_ytd as E33_ytd_wage,
EEF.amount as EEF_amount,
EEF.hours as EEF_hours,
EEF.rate as EEF_rate, 
EEF.net_pay as EEF_net_pay,
EEF.gross_pay as EEF_gross_pay,
EEF.ytd_hrs as EEF_ytd_hrs,
EEF.ytd_amount as EEF_ytd_amount,
EEF.subject_wages_ytd as EEF_ytd_wage,
EGV.amount as EGV_amount,
EGV.hours as EGV_hours,
EGV.rate as EGV_rate, 
EGV.net_pay as EGV_net_pay,
EGV.gross_pay as EGV_gross_pay,
EGV.ytd_hrs as EGV_ytd_hrs,
EGV.ytd_amount as EGV_ytd_amount,
EGV.subject_wages_ytd as EGV_ytd_wage,
ECD.amount as ECD_amount,
ECD.hours as ECD_hours,
ECD.rate as ECD_rate, 
ECD.net_pay as ECD_net_pay,
ECD.gross_pay as ECD_gross_pay,
ECD.ytd_hrs as ECD_ytd_hrs,
ECD.ytd_amount as ECD_ytd_amount,
ECD.subject_wages_ytd as ECD_ytd_wage,
ECE.amount as ECE_amount,
ECE.hours as ECE_hours,
ECE.rate as ECE_rate, 
ECE.net_pay as ECE_net_pay,
ECE.gross_pay as ECE_gross_pay,
ECE.ytd_hrs as ECE_ytd_hrs,
ECE.ytd_amount as ECE_ytd_amount,
ECE.subject_wages_ytd as ECE_ytd_wage,
ECM.amount as ECM_amount,
ECM.hours as ECM_hours,
ECM.rate as ECM_rate, 
ECM.net_pay as ECM_net_pay,
ECM.gross_pay as ECM_gross_pay,
ECM.ytd_hrs as ECM_ytd_hrs,
ECM.ytd_amount as ECM_ytd_amount,
ECM.subject_wages_ytd as ECM_ytd_wage,
ECN.amount as ECN_amount,
ECN.hours as ECN_hours,
ECN.rate as ECN_rate, 
ECN.net_pay as ECN_net_pay,
ECN.gross_pay as ECN_gross_pay,
ECN.ytd_hrs as ECN_ytd_hrs,
ECN.ytd_amount as ECN_ytd_amount,
ECN.subject_wages_ytd as ECN_ytd_wage,
ECO.amount as ECO_amount,
ECO.hours as ECO_hours,
ECO.rate as ECO_rate, 
ECO.net_pay as ECO_net_pay,
ECO.gross_pay as ECO_gross_pay,
ECO.ytd_hrs as ECO_ytd_hrs,
ECO.ytd_amount as ECO_ytd_amount,
ECO.subject_wages_ytd as ECO_ytd_wage,
ECP.amount as ECP_amount,
ECP.hours as ECP_hours,
ECP.rate as ECP_rate, 
ECP.net_pay as ECP_net_pay,
ECP.gross_pay as ECP_gross_pay,
ECP.ytd_hrs as ECP_ytd_hrs,
ECP.ytd_amount as ECP_ytd_amount,
ECP.subject_wages_ytd as ECP_ytd_wage,
ECS.amount as ECS_amount,
ECS.hours as ECS_hours,
ECS.rate as ECS_rate, 
ECS.net_pay as ECS_net_pay,
ECS.gross_pay as ECS_gross_pay,
ECS.ytd_hrs as ECS_ytd_hrs,
ECS.ytd_amount as ECS_ytd_amount,
ECS.subject_wages_ytd as ECS_ytd_wage

   FROM payroll.payment_header ph
     JOIN company_parameters cp ON cp.companyparametername = 'PInt'::bpchar and cp.companyparametervalue::text = 'P20'::text
     JOIN pay_schedule_period psp ON psp.payscheduleperiodid = ph.payscheduleperiodid
     JOIN pspay_payroll_pay_sch_periods ps ON ps.payscheduleperiodid = psp.payscheduleperiodid
     JOIN pspay_payroll pp ON ps.pspaypayrollid = pp.pspaypayrollid

     JOIN payroll.payment_detail pd ON pd.paymentheaderid = ph.paymentheaderid AND (pd.amount_ytd <> 0::numeric OR pd.units_ytd <> 0::numeric OR pd.amount <> 0::numeric OR pd.units <> 0::numeric) --AND pd.etv_code = 'EE'::bpchar not sure how to apply this 
      AND ((pd.paycode in (select distinct etvid as paycode from  person_earning_setup where current_date between effectivedate and enddate and current_timestamp between createts and endts))
       or  (pd.paycode in (select distinct paycode from payroll.pay_codes where paycodetypeid in (1,2,7) and current_date between effectivedate and enddate and current_timestamp between createts and endts)))
    
     JOIN pay_unit pu ON pu.payunitid = ph.payunitid AND current_timestamp between pu.createts and pu.endts  ----- added current_timestamp 
     
     LEFT JOIN pspaygroupearningdeductiondets pdd ON pu.payunitdesc = pdd.group_key AND pd.paycode::text = pdd.etv_id::text AND pdd.etorv = 'E'::text
     LEFT JOIN person_earning_setup pes ON ph.personid = pes.personid AND pes.etvid::text = pd.paycode::text AND psp.periodpaydate >= pes.effectivedate AND psp.periodpaydate <= pes.enddate AND now() >= pes.createts AND now() <= pes.endts
     
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'E01' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) E01 on E01.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'E02' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) E02 on E02.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'E17' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) E17 on E17.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'E18' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) E18 on E18.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'E20' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) E20 on E20.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'E37' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) E37 on E37.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'E39' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) E39 on E39.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'E61' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) E61 on E61.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'E63' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) E63 on E63.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'E64' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) E64 on E64.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'E70' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) E70 on E70.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'ECG' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) ECG on ECG.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'EDH' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) EDH on EDH.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'EEC' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) EEC on EEC.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'EG1' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) EG1 on EG1.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'EG2' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) EG2 on EG2.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'EG6' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) EG6 on EG6.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'EGC' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) EGC on EGC.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'EGP' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) EGP on EGP.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'EGZ' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) EGZ on EGZ.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'EH1' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) EH1 on EH1.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'EHB' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) EHB on EHB.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'EHC' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) EHC on EHC.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'EHG' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) EHG on EHG.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'E15' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) E15 on E15.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'E29' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) E29 on E29.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'E30' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) E30 on E30.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'E31' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) E31 on E31.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'E48' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) E48 on E48.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'E62' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) E62 on E62.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'E71' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) E71 on E71.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'EC0' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) EC0 on EC0.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'EC1' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) EC1 on EC1.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'EC8' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) EC8 on EC8.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'ECH' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) ECH on ECH.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'ECI' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) ECI on ECI.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'ECU' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) ECU on ECU.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'ECV' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) ECV on ECV.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'EDI' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) EDI on EDI.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'EEL' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) EEL on EEL.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'EG0' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) EG0 on EG0.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'E16' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) E16 on E16.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'EAH' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) EAH on EAH.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'EGS' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) EGS on EGS.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'EGW' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) EGW on EGW.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'E04' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) E04 on E04.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'E08' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) E08 on E08.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'E13' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) E13 on E13.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'E22' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) E22 on E22.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'E23' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) E23 on E23.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'E24' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) E24 on E24.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'E25' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) E25 on E25.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'E28' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) E28 on E28.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'E40' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) E40 on E40.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'E44' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) E44 on E44.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'E72' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) E72 on E72.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'E90' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) E90 on E90.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'E96' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) E96 on E96.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'EA1' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) EA1 on EA1.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'EA2' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) EA2 on EA2.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'EA4' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) EA4 on EA4.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'EC5' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) EC5 on EC5.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'EDK' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) EDK on EDK.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'EED' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) EED on EED.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'EEJ' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) EEJ on EEJ.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'EA0' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) EA0 on EA0.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'EBM' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) EBM on EBM.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'E32' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) E32 on E32.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'EA3' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) EA3 on EA3.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'EBO' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) EBO on EBO.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'EBS' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) EBS on EBS.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'EBU' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) EBU on EBU.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'EC3' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) EC3 on EC3.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'EGB' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) EGB on EGB.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'E19' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) E19 on E19.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'EMR' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) EMR on EMR.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'EXN' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) EXN on EXN.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'EXT' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) EXT on EXT.paycode = pd.paycode  

     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'E09' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) E09 on E09.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'E12' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) E12 on E12.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'E14' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) E14 on E14.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'E26' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) E26 on E26.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'E27' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) E27 on E27.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'E45' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) E45 on E45.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'E46' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) E46 on E46.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'E47' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) E47 on E47.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'E49' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) E49 on E49.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'E50' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) E50 on E50.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'E51' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) E51 on E51.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'E52' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) E52 on E52.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'E53' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) E53 on E53.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'E55' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) E55 on E55.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'E56' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) E56 on E56.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'E65' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) E65 on E65.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'E66' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) E66 on E66.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'E67' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) E67 on E67.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'E68' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) E68 on E68.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'E69' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) E69 on E69.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'EEI' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) EEI on EEI.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'EGM' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) EGM on EGM.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'EGR' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) EGR on EGR.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'E03' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) E03 on E03.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'E05' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) E05 on E05.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'E06' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) E06 on E06.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'E07' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) E07 on E07.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'E36' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) E36 on E36.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'E38' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) E38 on E38.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'E41' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) E41 on E41.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'E42' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) E42 on E42.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'E43' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) E43 on E43.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'E74' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) E74 on E74.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'EAA' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) EAA on EAA.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'EAG' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) EAG on EAG.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'EAZ' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) EAZ on EAZ.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'EBQ' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) EBQ on EBQ.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'EC4' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) EC4 on EC4.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'ECT' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) ECT on ECT.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'EDB' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) EDB on EDB.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'EEQ' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) EEQ on EEQ.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'EBK' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) EBK on EBK.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'ECJ' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) ECJ on ECJ.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'E33' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) E33 on E33.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'ECX' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) ECX on ECX.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'EEF' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) EEF on EEF.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'EGV' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) EGV on EGV.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'ECD' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) ECD on ECD.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'ECE' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) ECE on ECE.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'ECM' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) ECM on ECM.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'ECN' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) ECN on ECN.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'ECO' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) ECO on ECO.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'ECP' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) ECP on ECP.paycode = pd.paycode  
     left join (select d.paycode, sum(d.amount) as amount, sum(d.units) as hours, sum(d.rate) as rate, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay, sum(units_ytd) as ytd_hrs
                  from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'ECS' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) ECS on ECS.paycode = pd.paycode  

                   
     ) w group by qsource, paycode, pd_amount, pd_hours, pd_rate, pd_net_pay, pd_gross_pay, pd_ytd_hrs, pd_ytd_wage
     order by 2
     ;
