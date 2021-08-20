
/*
The wip version when ran for client VGC produced +5 deduction codes
VGX-ER, VGW-ER, VGV, VGU, VGP-ER

*/
select 
'wip' as qsource
,etv_id 

,sum(v.amount) as amount

,coalesce(v31_amount,v39er_amount,v40_amount,v65_amount,v73_amount,v9a_amount,va3_amount,va4_amount,vaf_amount,vb1_amount,vb2_amount,vb3_amount,vb5_amount,vba_amount,vbb_amount,vbd_amount,vbder_amount,vbe_amount,vbeer_amount,vbler_amount,vbser_amount,
          vd0_amount,vda_amount,veh_amount,vek_amount,vgh_amount,vgher_amount,vgo_amount,vg0_amount,vgoer_amount,vgper_amount,vgu_amount,vgv_amount,vgwer_amount,vgxer_amount,V42ER_amount,V22_amount,V70_amount,V72_amount,VA5_amount,VA8_amount,VAG_amount
         ,VBC_amount,VCI_amount,VCP_amount,VD1_amount,VD2_amount,VD3_amount,VD4_amount,VD5_amount,VD6_amount,VDG_amount,VDI_amount,V28_amount,V39_amount,V42_amount,V43ER_amount,V66_amount,V75_amount,V77_amount,V78_amount,V79_amount,V80_amount,V81_amount
         ,V82_amount,V84_amount,V85_amount,V86_amount,V87_amount,V88_amount,V89_amount,V90_amount,VAE_amount,VAL_amount,VAQ_amount,VAR_amount,VAS_amount,VAT_amount,VAU_amount,VBCER_amount,VBP_amount,VBQ_amount,VBU_amount,VCC_amount,VCD_amount,VCE_amount
         ,VCG_amount,VCH_amount,VCJ_amount,VCM_amount,VCN_amount,VCO_amount,VCV_amount,VDB_amount,VDO_amount,VFP_amount,VB6_amount) as pd_amount
          
,sum(v.hours) as hours
,sum(v.net_pay) as net_pay

,coalesce(v31_net_pay,v40_net_pay,v65_net_pay,v73_net_pay,v9a_net_pay,va3_net_pay,va4_net_pay,vaf_net_pay,vb1_net_pay,vb2_net_pay,vb3_net_pay,vb5_net_pay,vba_net_pay,vbb_net_pay,vbd_net_pay,vbe_net_pay,vd0_net_pay,veh_net_pay,vek_net_pay,vda_net_pay
         ,vgh_net_pay,vgO_net_pay,vgu_net_pay,vgv_net_pay,vg0_net_pay,VBDER_net_pay,VBEER_net_pay,VBLER_net_pay,VBSER_net_pay,VGOER_net_pay,VGPER_net_pay,VGWER_net_pay,VGXER_net_pay,V39ER_net_pay,VGHER_net_pay,V42ER_net_pay,V22_net_pay,V70_net_pay,V72_net_pay
         ,VA5_net_pay,VA8_net_pay,VAG_net_pay,VBC_net_pay,VCI_net_pay,VCP_net_pay,VD1_net_pay,VD2_net_pay,VD3_net_pay,VD4_net_pay,VD5_net_pay,VD6_net_pay,VDG_net_pay,VDI_net_pay,V28_net_pay,V39_net_pay,V42_net_pay,V43ER_net_pay,V66_net_pay,V75_net_pay,V77_net_pay,V78_net_pay
         ,V79_net_pay,V80_net_pay,V81_net_pay,V82_net_pay,V84_net_pay,V85_net_pay,V86_net_pay,V87_net_pay,V88_net_pay,V89_net_pay,V90_net_pay,VAE_net_pay,VAL_net_pay,VAQ_net_pay,VAR_net_pay,VAS_net_pay,VAT_net_pay,VAU_net_pay,VBCER_net_pay,VBP_net_pay,VBQ_net_pay,VBU_net_pay
         ,VCC_net_pay,VCD_net_pay,VCE_net_pay,VCG_net_pay,VCH_net_pay,VCJ_net_pay,VCM_net_pay,VCN_net_pay,VCO_net_pay,VCV_net_pay,VDB_net_pay,VDO_net_pay,VFP_net_pay,VB6_net_pay) as pd_net_pay

,sum(v.gross_pay) as gross_pay


,coalesce(v31_gross_pay,v40_gross_pay,v65_gross_pay,v73_gross_pay,v9a_gross_pay,va3_gross_pay,va4_gross_pay,vaf_gross_pay,vb1_gross_pay,vb2_gross_pay,vb3_gross_pay,vb5_gross_pay,vba_gross_pay,vbb_gross_pay,vbd_gross_pay,vbe_gross_pay,vda_gross_pay
         ,vd0_gross_pay,veh_gross_pay,vek_gross_pay,vgh_gross_pay,vgO_gross_pay,vgu_gross_pay,vgv_gross_pay,vg0_gross_pay,VBDER_gross_pay,VBEER_gross_pay,VBLER_gross_pay,VBSER_gross_pay,VGOER_gross_pay,VGPER_gross_pay,VGWER_gross_pay,VGXER_gross_pay,V39ER_gross_pay,VGHER_gross_pay
         ,V42ER_gross_pay,V22_gross_pay,V70_gross_pay,V72_gross_pay,VA5_gross_pay,VA8_gross_pay,VAG_gross_pay,VBC_gross_pay,VCI_gross_pay,VCP_gross_pay,VD1_gross_pay,VD2_gross_pay,VD3_gross_pay,VD4_gross_pay,VD5_gross_pay,VD6_gross_pay,VDG_gross_pay,VDI_gross_pay,V28_gross_pay
         ,V39_gross_pay,V42_gross_pay,V43ER_gross_pay,V66_gross_pay,V75_gross_pay,V77_gross_pay,V78_gross_pay,V79_gross_pay,V80_gross_pay,V81_gross_pay,V82_gross_pay,V84_gross_pay,V85_gross_pay,V86_gross_pay,V87_gross_pay,V88_gross_pay,V89_gross_pay,V90_gross_pay,VAE_gross_pay
         ,VAL_gross_pay,VAQ_gross_pay,VAR_gross_pay,VAS_gross_pay,VAT_gross_pay,VAU_gross_pay,VBCER_gross_pay,VBP_gross_pay,VBQ_gross_pay,VBU_gross_pay,VCC_gross_pay,VCD_gross_pay,VCE_gross_pay,VCG_gross_pay,VCH_gross_pay,VCJ_gross_pay,VCM_gross_pay,VCN_gross_pay,VCO_gross_pay
         ,VCV_gross_pay,VDB_gross_pay,VDO_gross_pay,VFP_gross_pay,VB6_gross_pay) as pd_gross_pay

,sum(v.ytd_amount) as ytd_amount

,coalesce(v31_ytd_amount,v39er_ytd_amount,v40_ytd_amount,v65_ytd_amount,v73_ytd_amount,v9a_ytd_amount,va3_ytd_amount,va4_ytd_amount,vaf_ytd_amount,vb1_ytd_amount,vb2_ytd_amount,vb3_ytd_amount,vb5_ytd_amount,vba_ytd_amount,vbb_ytd_amount,vbd_ytd_amount,vbder_ytd_amount,vbe_ytd_amount
         ,vbeer_ytd_amount,vbler_ytd_amount,vbser_ytd_amount,vd0_ytd_amount,vda_ytd_amount,veh_ytd_amount,vek_ytd_amount,vgh_ytd_amount,vgher_ytd_amount,vgo_ytd_amount,vgoer_ytd_amount,vg0_ytd_amount,vgper_ytd_amount,vgu_ytd_amount,vgv_ytd_amount,vgwer_ytd_amount,vgxer_ytd_amount
         ,V42ER_ytd_amount,V22_ytd_amount,V70_ytd_amount,V72_ytd_amount,VA5_ytd_amount,VA8_ytd_amount,VAG_ytd_amount,VBC_ytd_amount,VCI_ytd_amount,VCP_ytd_amount,VD1_ytd_amount,VD2_ytd_amount,VD3_ytd_amount,VD4_ytd_amount,VD5_ytd_amount,VD6_ytd_amount,VDG_ytd_amount,VDI_ytd_amount
         ,V28_ytd_amount,V39_ytd_amount,V42_ytd_amount,V43ER_ytd_amount,V66_ytd_amount,V75_ytd_amount,V77_ytd_amount,V78_ytd_amount,V79_ytd_amount,V80_ytd_amount,V81_ytd_amount,V82_ytd_amount,V84_ytd_amount,V85_ytd_amount,V86_ytd_amount,V87_ytd_amount,V88_ytd_amount,V89_ytd_amount
         ,V90_ytd_amount,VAE_ytd_amount,VAL_ytd_amount,VAQ_ytd_amount,VAR_ytd_amount,VAS_ytd_amount,VAT_ytd_amount,VAU_ytd_amount,VBCER_ytd_amount,VBP_ytd_amount,VBQ_ytd_amount,VBU_ytd_amount,VCC_ytd_amount,VCD_ytd_amount,VCE_ytd_amount,VCG_ytd_amount,VCH_ytd_amount,VCJ_ytd_amount
         ,VCM_ytd_amount,VCN_ytd_amount,VCO_ytd_amount,VCV_ytd_amount,VDB_ytd_amount,VDO_ytd_amount,VFP_ytd_amount,VB6_ytd_amount) as pd_ytd_amount


,sum(v.ytd_wage) as ytd_wage

,coalesce(v31_subject_wages_ytd,v39er_subject_wages_ytd,v40_subject_wages_ytd,v65_subject_wages_ytd,v73_subject_wages_ytd,v9a_subject_wages_ytd,va3_subject_wages_ytd,va4_subject_wages_ytd,vaf_subject_wages_ytd,vb1_subject_wages_ytd,vb2_subject_wages_ytd,vb3_subject_wages_ytd,vb5_subject_wages_ytd
         ,vba_subject_wages_ytd,vbb_subject_wages_ytd,vbd_subject_wages_ytd,vbder_subject_wages_ytd,vbe_subject_wages_ytd,vbeer_subject_wages_ytd,vbler_subject_wages_ytd,vbser_subject_wages_ytd,vd0_subject_wages_ytd,vda_subject_wages_ytd,veh_subject_wages_ytd,vek_subject_wages_ytd,vgh_subject_wages_ytd
         ,vgher_subject_wages_ytd,vgo_subject_wages_ytd,vgoer_subject_wages_ytd,vg0_subject_wages_ytd,vgper_subject_wages_ytd,vgu_subject_wages_ytd,vgv_subject_wages_ytd,vgwer_subject_wages_ytd,vgxer_subject_wages_ytd,V42ER_subject_wages_ytd,V22_subject_wages_ytd,V70_subject_wages_ytd
         ,V72_subject_wages_ytd,VA5_subject_wages_ytd,VA8_subject_wages_ytd,VAG_subject_wages_ytd,VBC_subject_wages_ytd,VCI_subject_wages_ytd,VCP_subject_wages_ytd,VD1_subject_wages_ytd,VD2_subject_wages_ytd,VD3_subject_wages_ytd,VD4_subject_wages_ytd,VD5_subject_wages_ytd,VD6_subject_wages_ytd
         ,VDG_subject_wages_ytd,VDI_subject_wages_ytd,V28_subject_wages_ytd,V39_subject_wages_ytd,V42_subject_wages_ytd,V43ER_subject_wages_ytd,V66_subject_wages_ytd,V75_subject_wages_ytd,V77_subject_wages_ytd,V78_subject_wages_ytd,V79_subject_wages_ytd,V80_subject_wages_ytd,V81_subject_wages_ytd
         ,V82_subject_wages_ytd,V84_subject_wages_ytd,V85_subject_wages_ytd,V86_subject_wages_ytd,V87_subject_wages_ytd,V88_subject_wages_ytd,V89_subject_wages_ytd,V90_subject_wages_ytd,VAE_subject_wages_ytd,VAL_subject_wages_ytd,VAQ_subject_wages_ytd,VAR_subject_wages_ytd,VAS_subject_wages_ytd
         ,VAT_subject_wages_ytd,VAU_subject_wages_ytd,VBCER_subject_wages_ytd,VBP_subject_wages_ytd,VBQ_subject_wages_ytd,VBU_subject_wages_ytd,VCC_subject_wages_ytd,VCD_subject_wages_ytd,VCE_subject_wages_ytd,VCG_subject_wages_ytd,VCH_subject_wages_ytd,VCJ_subject_wages_ytd,VCM_subject_wages_ytd
         ,VCN_subject_wages_ytd,VCO_subject_wages_ytd,VCV_subject_wages_ytd,VDB_subject_wages_ytd,VDO_subject_wages_ytd,VFP_subject_wages_ytd,VB6_subject_wages_ytd) as pd_subject_wages_ytd

from
(
 SELECT ph.personid,
    ph.paymentheaderid,
    pp.pspaypayrollid,
    pgs.persongarnishmentsetuppid,
    pd.paycode AS etv_id,
    pd.paycode::text || COALESCE('-'::text ||
        CASE
            WHEN gt.garntypedesc IS NOT NULL THEN gt.garntypedesc
            ELSE NULL::character varying
        END::text, '-'::text || pc.paycodeshortdesc::text, ''::text) AS etvname,
    pd.amount,
    v31.amount as v31_amount,
    v40.amount as v40_amount,
    v65.amount as v65_amount,
    v73.amount as v73_amount,
    v9a.amount as v9a_amount,
    va3.amount as va3_amount,
    va4.amount as va4_amount,
    vaf.amount as vaf_amount,
    vb1.amount as vb1_amount,
    vb2.amount as vb2_amount,
    vb3.amount as vb3_amount,
    vb5.amount as vb5_amount,
    vba.amount as vba_amount,
    vbb.amount as vbb_amount,
    vbd.amount as vbd_amount,
    vbe.amount as vbe_amount,
    vd0.amount as vd0_amount,
    vda.amount as vda_amount,
    veh.amount as veh_amount,
    vek.amount as vek_amount,
    vgh.amount as vgh_amount,
    vgo.amount as vgo_amount,
    vg0.amount as vg0_amount,
    vgu.amount as vgu_amount,
    vgv.amount as vgv_amount,
    V22.amount as V22_amount,
    V70.amount as V70_amount,
    V72.amount as V72_amount,
    VA5.amount as VA5_amount,
    VA8.amount as VA8_amount,
    VAG.amount as VAG_amount,
    VBC.amount as VBC_amount,
    VCI.amount as VCI_amount,
    VCP.amount as VCP_amount,
    VD1.amount as VD1_amount,
    VD2.amount as VD2_amount,
    VD3.amount as VD3_amount,
    VD4.amount as VD4_amount,
    VD5.amount as VD5_amount,
    VD6.amount as VD6_amount,
    VDG.amount as VDG_amount,
    VDI.amount as VDI_amount,
    vgwer.amount as vgwer_amount,
    vgxer.amount as vgxer_amount,
    vbeer.amount as vbeer_amount,
    vbler.amount as vbler_amount,
    vbser.amount as vbser_amount,
    vgher.amount as vgher_amount,    
    vbder.amount as vbder_amount,
    vgoer.amount as vgoer_amount,
    vgper.amount as vgper_amount, 
    v39er.amount as v39er_amount,
    V42ER.amount as v42er_amount,           

    pd.units AS hours,
    ph.net_pay,
    v31.net_pay as v31_net_pay,
    v40.net_pay as v40_net_pay,
    v65.net_pay as v65_net_pay,
    v73.net_pay as v73_net_pay,
    v9a.net_pay as v9a_net_pay,
    va3.net_pay as va3_net_pay,
    va4.net_pay as va4_net_pay,
    vaf.net_pay as vaf_net_pay,
    vb1.net_pay as vb1_net_pay,
    vb2.net_pay as vb2_net_pay,
    vb3.net_pay as vb3_net_pay,
    vb5.net_pay as vb5_net_pay,
    vba.net_pay as vba_net_pay,
    vbb.net_pay as vbb_net_pay,
    vbd.net_pay as vbd_net_pay,
    vbe.net_pay as vbe_net_pay,
    vd0.net_pay as vd0_net_pay,
    vda.net_pay as vda_net_pay,
    veh.net_pay as veh_net_pay,
    vek.net_pay as vek_net_pay,
    vgh.net_pay as vgh_net_pay,
    vgO.net_pay as vgO_net_pay,
    vgu.net_pay as vgu_net_pay,
    vgv.net_pay as vgv_net_pay,
    vg0.net_pay as vg0_net_pay,
    V22.net_pay as V22_net_pay,
    V70.net_pay as V70_net_pay,
    V72.net_pay as V72_net_pay,
    VA5.net_pay as VA5_net_pay,
    VA8.net_pay as VA8_net_pay,
    VAG.net_pay as VAG_net_pay,
    VBC.net_pay as VBC_net_pay,
    VCI.net_pay as VCI_net_pay,
    VCP.net_pay as VCP_net_pay,
    VD1.net_pay as VD1_net_pay,
    VD2.net_pay as VD2_net_pay,
    VD3.net_pay as VD3_net_pay,
    VD4.net_pay as VD4_net_pay,
    VD5.net_pay as VD5_net_pay,
    VD6.net_pay as VD6_net_pay,
    VDG.net_pay as VDG_net_pay,
    VDI.net_pay as VDI_net_pay,
    VBDER.net_pay as VBDER_net_pay,
    VBEER.net_pay as VBEER_net_pay,
    VBLER.net_pay as VBLER_net_pay,
    VBSER.net_pay as VBSER_net_pay,
    VGOER.net_pay as VGOER_net_pay,
    VGPER.net_pay as VGPER_net_pay,
    VGWER.net_pay as VGWER_net_pay,
    VGXER.net_pay as VGXER_net_pay,
    V39ER.net_pay as V39ER_net_pay,
    VGHER.net_pay as VGHER_net_pay,
    V42ER.net_pay as V42ER_net_pay,
    
    ph.gross_pay,
    v31.gross_pay as v31_gross_pay,
    v40.gross_pay as v40_gross_pay,
    v65.gross_pay as v65_gross_pay,
    v73.gross_pay as v73_gross_pay,
    v9a.gross_pay as v9a_gross_pay,
    va3.gross_pay as va3_gross_pay,
    va4.gross_pay as va4_gross_pay,
    vaf.gross_pay as vaf_gross_pay,
    vb1.gross_pay as vb1_gross_pay,
    vb2.gross_pay as vb2_gross_pay,
    vb3.gross_pay as vb3_gross_pay,
    vb5.gross_pay as vb5_gross_pay,
    vba.gross_pay as vba_gross_pay,
    vbb.gross_pay as vbb_gross_pay,
    vbd.gross_pay as vbd_gross_pay,
    vbe.gross_pay as vbe_gross_pay,
    vd0.gross_pay as vd0_gross_pay,
    vda.gross_pay as vda_gross_pay,
    veh.gross_pay as veh_gross_pay,
    vek.gross_pay as vek_gross_pay,
    vgh.gross_pay as vgh_gross_pay,
    vgO.gross_pay as vgO_gross_pay,
    vgu.gross_pay as vgu_gross_pay,
    vgv.gross_pay as vgv_gross_pay,
    vg0.gross_pay as vg0_gross_pay,
    V22.gross_pay as V22_gross_pay,
    V70.gross_pay as V70_gross_pay,
    V72.gross_pay as V72_gross_pay,
    VA5.gross_pay as VA5_gross_pay,
    VA8.gross_pay as VA8_gross_pay,
    VAG.gross_pay as VAG_gross_pay,
    VBC.gross_pay as VBC_gross_pay,
    VCI.gross_pay as VCI_gross_pay,
    VCP.gross_pay as VCP_gross_pay,
    VD1.gross_pay as VD1_gross_pay,
    VD2.gross_pay as VD2_gross_pay,
    VD3.gross_pay as VD3_gross_pay,
    VD4.gross_pay as VD4_gross_pay,
    VD5.gross_pay as VD5_gross_pay,
    VD6.gross_pay as VD6_gross_pay,
    VDG.gross_pay as VDG_gross_pay,
    VDI.gross_pay as VDI_gross_pay,
    VBDER.gross_pay as VBDER_gross_pay,
    VBEER.gross_pay as VBEER_gross_pay,
    VBLER.gross_pay as VBLER_gross_pay,
    VBSER.gross_pay as VBSER_gross_pay,
    VGOER.gross_pay as VGOER_gross_pay,
    VGPER.gross_pay as VGPER_gross_pay,
    VGWER.gross_pay as VGWER_gross_pay,
    VGXER.gross_pay as VGXER_gross_pay,
    V39ER.gross_pay as V39ER_gross_pay,
    VGHER.gross_pay as VGHER_gross_pay,
    V42ER.gross_pay as V42ER_gross_pay,
    
    pd.amount_ytd AS ytd_amount,
        
    v31.ytd_amount as v31_ytd_amount,
    v40.ytd_amount as v40_ytd_amount,
    v65.ytd_amount as v65_ytd_amount,
    v73.ytd_amount as v73_ytd_amount,
    v9a.ytd_amount as v9a_ytd_amount,
    va3.ytd_amount as va3_ytd_amount,
    va4.ytd_amount as va4_ytd_amount,
    vaf.ytd_amount as vaf_ytd_amount,
    vb1.ytd_amount as vb1_ytd_amount,
    vb2.ytd_amount as vb2_ytd_amount,
    vb3.ytd_amount as vb3_ytd_amount,
    vb5.ytd_amount as vb5_ytd_amount,
    vba.ytd_amount as vba_ytd_amount,
    vbb.ytd_amount as vbb_ytd_amount,
    vbd.ytd_amount as vbd_ytd_amount,
    vbe.ytd_amount as vbe_ytd_amount,
    vd0.ytd_amount as vd0_ytd_amount,
    vda.ytd_amount as vda_ytd_amount,
    veh.ytd_amount as veh_ytd_amount,
    vek.ytd_amount as vek_ytd_amount,
    vgh.ytd_amount as vgh_ytd_amount,
    vgo.ytd_amount as vgo_ytd_amount,
    vg0.ytd_amount as vg0_ytd_amount,
    vgu.ytd_amount as vgu_ytd_amount,
    vgv.ytd_amount as vgv_ytd_amount,
    V22.ytd_amount as V22_ytd_amount,
    V70.ytd_amount as V70_ytd_amount,
    V72.ytd_amount as V72_ytd_amount,
    VA5.ytd_amount as VA5_ytd_amount,
    VA8.ytd_amount as VA8_ytd_amount,
    VAG.ytd_amount as VAG_ytd_amount,
    VBC.ytd_amount as VBC_ytd_amount,
    VCI.ytd_amount as VCI_ytd_amount,
    VCP.ytd_amount as VCP_ytd_amount,
    VD1.ytd_amount as VD1_ytd_amount,
    VD2.ytd_amount as VD2_ytd_amount,
    VD3.ytd_amount as VD3_ytd_amount,
    VD4.ytd_amount as VD4_ytd_amount,
    VD5.ytd_amount as VD5_ytd_amount,
    VD6.ytd_amount as VD6_ytd_amount,
    VDG.ytd_amount as VDG_ytd_amount,
    VDI.ytd_amount as VDI_ytd_amount,
    vgwer.ytd_amount as vgwer_ytd_amount,
    vgxer.ytd_amount as vgxer_ytd_amount,   
    v39er.ytd_amount as v39er_ytd_amount,    
    vbder.ytd_amount as vbder_ytd_amount,    
    vbeer.ytd_amount as vbeer_ytd_amount,
    vbler.ytd_amount as vbler_ytd_amount,
    vbser.ytd_amount as vbser_ytd_amount,   
    vgher.ytd_amount as vgher_ytd_amount, 
    vgoer.ytd_amount as vgoer_ytd_amount,
    vgper.ytd_amount as vgper_ytd_amount, 
    V42ER.ytd_amount as V42ER_ytd_amount,         
    
    pd.subject_wages_ytd AS ytd_wage,
    
    v31.subject_wages_ytd as v31_subject_wages_ytd,
    v40.subject_wages_ytd as v40_subject_wages_ytd,
    v65.subject_wages_ytd as v65_subject_wages_ytd,
    v73.subject_wages_ytd as v73_subject_wages_ytd,
    v9a.subject_wages_ytd as v9a_subject_wages_ytd,
    va3.subject_wages_ytd as va3_subject_wages_ytd,
    va4.subject_wages_ytd as va4_subject_wages_ytd,
    vaf.subject_wages_ytd as vaf_subject_wages_ytd,
    vb1.subject_wages_ytd as vb1_subject_wages_ytd,
    vb2.subject_wages_ytd as vb2_subject_wages_ytd,
    vb3.subject_wages_ytd as vb3_subject_wages_ytd,
    vb5.subject_wages_ytd as vb5_subject_wages_ytd,
    vba.subject_wages_ytd as vba_subject_wages_ytd,
    vbb.subject_wages_ytd as vbb_subject_wages_ytd,
    vbd.subject_wages_ytd as vbd_subject_wages_ytd,
    vbe.subject_wages_ytd as vbe_subject_wages_ytd,
    vd0.subject_wages_ytd as vd0_subject_wages_ytd,
    vda.subject_wages_ytd as vda_subject_wages_ytd,
    veh.subject_wages_ytd as veh_subject_wages_ytd,
    vek.subject_wages_ytd as vek_subject_wages_ytd,
    vgh.subject_wages_ytd as vgh_subject_wages_ytd,
    vgo.subject_wages_ytd as vgo_subject_wages_ytd,
    vg0.subject_wages_ytd as vg0_subject_wages_ytd,
    vgu.subject_wages_ytd as vgu_subject_wages_ytd,
    vgv.subject_wages_ytd as vgv_subject_wages_ytd,
    V22.subject_wages_ytd as V22_subject_wages_ytd,
    V70.subject_wages_ytd as V70_subject_wages_ytd,
    V72.subject_wages_ytd as V72_subject_wages_ytd,
    VA5.subject_wages_ytd as VA5_subject_wages_ytd,
    VA8.subject_wages_ytd as VA8_subject_wages_ytd,
    VAG.subject_wages_ytd as VAG_subject_wages_ytd,
    VBC.subject_wages_ytd as VBC_subject_wages_ytd,
    VCI.subject_wages_ytd as VCI_subject_wages_ytd,
    VCP.subject_wages_ytd as VCP_subject_wages_ytd,
    VD1.subject_wages_ytd as VD1_subject_wages_ytd,
    VD2.subject_wages_ytd as VD2_subject_wages_ytd,
    VD3.subject_wages_ytd as VD3_subject_wages_ytd,
    VD4.subject_wages_ytd as VD4_subject_wages_ytd,
    VD5.subject_wages_ytd as VD5_subject_wages_ytd,
    VD6.subject_wages_ytd as VD6_subject_wages_ytd,
    VDG.subject_wages_ytd as VDG_subject_wages_ytd,
    VDI.subject_wages_ytd as VDI_subject_wages_ytd,
    vgwer.subject_wages_ytd as vgwer_subject_wages_ytd,
    vgxer.subject_wages_ytd as vgxer_subject_wages_ytd, 
    v39er.subject_wages_ytd as v39er_subject_wages_ytd,
    vgoer.subject_wages_ytd as vgoer_subject_wages_ytd,
    vgper.subject_wages_ytd as vgper_subject_wages_ytd,  
    vgher.subject_wages_ytd as vgher_subject_wages_ytd,  
    vbeer.subject_wages_ytd as vbeer_subject_wages_ytd,
    vbler.subject_wages_ytd as vbler_subject_wages_ytd,
    vbser.subject_wages_ytd as vbser_subject_wages_ytd,      
    vbder.subject_wages_ytd as vbder_subject_wages_ytd,  
    V42ER.subject_wages_ytd as V42ER_subject_wages_ytd,  
     
V28.subject_wages_ytd as V28_subject_wages_ytd,
V28.ytd_amount as V28_ytd_amount,
V28.gross_pay as V28_gross_pay,
V28.net_pay as V28_net_pay,   
V28.amount as V28_amount, 
V39.subject_wages_ytd as V39_subject_wages_ytd,
V39.ytd_amount as V39_ytd_amount,
V39.gross_pay as V39_gross_pay,
V39.net_pay as V39_net_pay,   
V39.amount as V39_amount,    
V42.subject_wages_ytd as V42_subject_wages_ytd,
V42.ytd_amount as V42_ytd_amount,
V42.gross_pay as V42_gross_pay,
V42.net_pay as V42_net_pay,   
V42.amount as V42_amount,  
V66.subject_wages_ytd as V66_subject_wages_ytd,
V66.ytd_amount as V66_ytd_amount,
V66.gross_pay as V66_gross_pay,
V66.net_pay as V66_net_pay,   
V66.amount as V66_amount,    
V75.subject_wages_ytd as V75_subject_wages_ytd,
V75.ytd_amount as V75_ytd_amount,
V75.gross_pay as V75_gross_pay,
V75.net_pay as V75_net_pay,   
V75.amount as V75_amount,     
V77.subject_wages_ytd as V77_subject_wages_ytd,
V77.ytd_amount as V77_ytd_amount,
V77.gross_pay as V77_gross_pay,
V77.net_pay as V77_net_pay,   
V77.amount as V77_amount,       
V78.subject_wages_ytd as V78_subject_wages_ytd,
V78.ytd_amount as V78_ytd_amount,
V78.gross_pay as V78_gross_pay,
V78.net_pay as V78_net_pay,   
V78.amount as V78_amount,       
V79.subject_wages_ytd as V79_subject_wages_ytd,
V79.ytd_amount as V79_ytd_amount,
V79.gross_pay as V79_gross_pay,
V79.net_pay as V79_net_pay,   
V79.amount as V79_amount,   
V80.subject_wages_ytd as V80_subject_wages_ytd,
V80.ytd_amount as V80_ytd_amount,
V80.gross_pay as V80_gross_pay,
V80.net_pay as V80_net_pay,   
V80.amount as V80_amount,       
V81.subject_wages_ytd as V81_subject_wages_ytd,
V81.ytd_amount as V81_ytd_amount,
V81.gross_pay as V81_gross_pay,
V81.net_pay as V81_net_pay,   
V81.amount as V81_amount,       
V82.subject_wages_ytd as V82_subject_wages_ytd,
V82.ytd_amount as V82_ytd_amount,
V82.gross_pay as V82_gross_pay,
V82.net_pay as V82_net_pay,   
V82.amount as V82_amount,
V84.subject_wages_ytd as V84_subject_wages_ytd,
V84.ytd_amount as V84_ytd_amount,
V84.gross_pay as V84_gross_pay,
V84.net_pay as V84_net_pay,   
V84.amount as V84_amount,       
V85.subject_wages_ytd as V85_subject_wages_ytd,
V85.ytd_amount as V85_ytd_amount,
V85.gross_pay as V85_gross_pay,
V85.net_pay as V85_net_pay,   
V85.amount as V85_amount,       
V86.subject_wages_ytd as V86_subject_wages_ytd,
V86.ytd_amount as V86_ytd_amount,
V86.gross_pay as V86_gross_pay,
V86.net_pay as V86_net_pay,   
V86.amount as V86_amount,       
V87.subject_wages_ytd as V87_subject_wages_ytd,
V87.ytd_amount as V87_ytd_amount,
V87.gross_pay as V87_gross_pay,
V87.net_pay as V87_net_pay,   
V87.amount as V87_amount,       
V88.subject_wages_ytd as V88_subject_wages_ytd,
V88.ytd_amount as V88_ytd_amount,
V88.gross_pay as V88_gross_pay,
V88.net_pay as V88_net_pay,   
V88.amount as V88_amount,       
V89.subject_wages_ytd as V89_subject_wages_ytd,
V89.ytd_amount as V89_ytd_amount,
V89.gross_pay as V89_gross_pay,
V89.net_pay as V89_net_pay,   
V89.amount as V89_amount,       
V90.subject_wages_ytd as V90_subject_wages_ytd,
V90.ytd_amount as V90_ytd_amount,
V90.gross_pay as V90_gross_pay,
V90.net_pay as V90_net_pay,   
V90.amount as V90_amount,       
VAE.subject_wages_ytd as VAE_subject_wages_ytd,
VAE.ytd_amount as VAE_ytd_amount,
VAE.gross_pay as VAE_gross_pay,
VAE.net_pay as VAE_net_pay,   
VAE.amount as VAE_amount,       
VAL.subject_wages_ytd as VAL_subject_wages_ytd,
VAL.ytd_amount as VAL_ytd_amount,
VAL.gross_pay as VAL_gross_pay,
VAL.net_pay as VAL_net_pay,   
VAL.amount as VAL_amount,  
VAQ.subject_wages_ytd as VAQ_subject_wages_ytd,
VAQ.ytd_amount as VAQ_ytd_amount,
VAQ.gross_pay as VAQ_gross_pay,
VAQ.net_pay as VAQ_net_pay,   
VAQ.amount as VAQ_amount,       
VAR.subject_wages_ytd as VAR_subject_wages_ytd,
VAR.ytd_amount as VAR_ytd_amount,
VAR.gross_pay as VAR_gross_pay,
VAR.net_pay as VAR_net_pay,   
VAR.amount as VAR_amount,       
VAS.subject_wages_ytd as VAS_subject_wages_ytd,
VAS.ytd_amount as VAS_ytd_amount,
VAS.gross_pay as VAS_gross_pay,
VAS.net_pay as VAS_net_pay,   
VAS.amount as VAS_amount,      
VAT.subject_wages_ytd as VAT_subject_wages_ytd,
VAT.ytd_amount as VAT_ytd_amount,
VAT.gross_pay as VAT_gross_pay,
VAT.net_pay as VAT_net_pay,   
VAT.amount as VAT_amount,       
VAU.subject_wages_ytd as VAU_subject_wages_ytd,
VAU.ytd_amount as VAU_ytd_amount,
VAU.gross_pay as VAU_gross_pay,
VAU.net_pay as VAU_net_pay,   
VAU.amount as VAU_amount,       
VB6.subject_wages_ytd as VB6_subject_wages_ytd,
VB6.ytd_amount as VB6_ytd_amount,
VB6.gross_pay as VB6_gross_pay,
VB6.net_pay as VB6_net_pay,   
VB6.amount as VB6_amount,                                                        
VBP.subject_wages_ytd as VBP_subject_wages_ytd,
VBP.ytd_amount as VBP_ytd_amount,
VBP.gross_pay as VBP_gross_pay,
VBP.net_pay as VBP_net_pay,   
VBP.amount as VBP_amount,       
VBQ.subject_wages_ytd as VBQ_subject_wages_ytd,
VBQ.ytd_amount as VBQ_ytd_amount,
VBQ.gross_pay as VBQ_gross_pay,
VBQ.net_pay as VBQ_net_pay,   
VBQ.amount as VBQ_amount,    
VBU.subject_wages_ytd as VBU_subject_wages_ytd,
VBU.ytd_amount as VBU_ytd_amount,
VBU.gross_pay as VBU_gross_pay,
VBU.net_pay as VBU_net_pay,   
VBU.amount as VBU_amount,       
VCC.subject_wages_ytd as VCC_subject_wages_ytd,
VCC.ytd_amount as VCC_ytd_amount,
VCC.gross_pay as VCC_gross_pay,
VCC.net_pay as VCC_net_pay,   
VCC.amount as VCC_amount,                   
VCD.subject_wages_ytd as VCD_subject_wages_ytd,
VCD.ytd_amount as VCD_ytd_amount,
VCD.gross_pay as VCD_gross_pay,
VCD.net_pay as VCD_net_pay,   
VCD.amount as VCD_amount,       
VCE.subject_wages_ytd as VCE_subject_wages_ytd,
VCE.ytd_amount as VCE_ytd_amount,
VCE.gross_pay as VCE_gross_pay,
VCE.net_pay as VCE_net_pay,   
VCE.amount as VCE_amount,       
VCG.subject_wages_ytd as VCG_subject_wages_ytd,
VCG.ytd_amount as VCG_ytd_amount,
VCG.gross_pay as VCG_gross_pay,
VCG.net_pay as VCG_net_pay,   
VCG.amount as VCG_amount,       
VCH.subject_wages_ytd as VCH_subject_wages_ytd,
VCH.ytd_amount as VCH_ytd_amount,
VCH.gross_pay as VCH_gross_pay,
VCH.net_pay as VCH_net_pay,   
VCH.amount as VCH_amount,       
VCJ.subject_wages_ytd as VCJ_subject_wages_ytd,
VCJ.ytd_amount as VCJ_ytd_amount,
VCJ.gross_pay as VCJ_gross_pay,
VCJ.net_pay as VCJ_net_pay,   
VCJ.amount as VCJ_amount, 
VCM.subject_wages_ytd as VCM_subject_wages_ytd,
VCM.ytd_amount as VCM_ytd_amount,
VCM.gross_pay as VCM_gross_pay,
VCM.net_pay as VCM_net_pay,   
VCM.amount as VCM_amount,         
VCN.subject_wages_ytd as VCN_subject_wages_ytd,
VCN.ytd_amount as VCN_ytd_amount,
VCN.gross_pay as VCN_gross_pay,
VCN.net_pay as VCN_net_pay,   
VCN.amount as VCN_amount,       
VCO.subject_wages_ytd as VCO_subject_wages_ytd,
VCO.ytd_amount as VCO_ytd_amount,
VCO.gross_pay as VCO_gross_pay,
VCO.net_pay as VCO_net_pay,   
VCO.amount as VCO_amount,              
VCV.subject_wages_ytd as VCV_subject_wages_ytd,
VCV.ytd_amount as VCV_ytd_amount,
VCV.gross_pay as VCV_gross_pay,
VCV.net_pay as VCV_net_pay,   
VCV.amount as VCV_amount,  
VDB.subject_wages_ytd as VDB_subject_wages_ytd,
VDB.ytd_amount as VDB_ytd_amount,
VDB.gross_pay as VDB_gross_pay,
VDB.net_pay as VDB_net_pay,   
VDB.amount as VDB_amount,                            
VDO.subject_wages_ytd as VDO_subject_wages_ytd,
VDO.ytd_amount as VDO_ytd_amount,
VDO.gross_pay as VDO_gross_pay,
VDO.net_pay as VDO_net_pay,   
VDO.amount as VDO_amount,       
VFP.subject_wages_ytd as VFP_subject_wages_ytd,
VFP.ytd_amount as VFP_ytd_amount,
VFP.gross_pay as VFP_gross_pay,
VFP.net_pay as VFP_net_pay,   
VFP.amount as VFP_amount,       
VBCER.subject_wages_ytd as VBCER_subject_wages_ytd,   
VBCER.ytd_amount as VBCER_ytd_amount,
VBCER.gross_pay as VBCER_gross_pay,
VBCER.net_pay as VBCER_net_pay,
VBCER.amount as VBCER_amount,
V43ER.subject_wages_ytd as V43ER_subject_wages_ytd,   
V43ER.ytd_amount as V43ER_ytd_amount,
V43ER.gross_pay as V43ER_gross_pay,
V43ER.net_pay as V43ER_net_pay,
V43ER.amount as V43ER_amount,
            


        CASE
            WHEN pc.paycodetypeid = 6 THEN 'Y'::bpchar
            ELSE 'N'::bpchar
        END AS isemployer
   FROM payroll.payment_header ph
     JOIN payroll.payment_detail pd ON pd.paymentheaderid = ph.paymentheaderid AND (pd.amount_ytd <> 0::numeric OR pd.units_ytd <> 0::numeric OR pd.amount <> 0::numeric OR pd.units <> 0::numeric)
     JOIN company_parameters ON company_parameters.companyparametername = 'PInt'::bpchar AND company_parameters.companyparametervalue::text = 'P20'::text
     JOIN payroll.pay_codes pc ON pc.paycode::text = pd.paycode::text AND ph.check_date >= pc.effectivedate AND ph.check_date <= pc.enddate AND now() >= pc.createts AND now() <= pc.endts AND pc.paycodetypeid in (3,6) --AND pc.uidisplay = 'Y'::bpchar 
     JOIN pay_schedule_period psp ON psp.payscheduleperiodid = ph.payscheduleperiodid
     JOIN pspay_payroll_pay_sch_periods ps ON ps.payscheduleperiodid = psp.payscheduleperiodid
     JOIN pspay_payroll pp ON ps.pspaypayrollid = pp.pspaypayrollid
     LEFT JOIN person_garnishment_setup pgs ON ph.personid = pgs.personid AND pgs.etvid::text = pd.paycode::text AND psp.periodpaydate >= pgs.effectivedate AND psp.periodpaydate <= pgs.enddate AND now() >= pgs.createts AND now() <= pgs.endts
     LEFT JOIN garnishment_type gt ON pgs.garnishmenttype = gt.garntype

left join (select d.paycode, sum(d.amount) as amount, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'V31' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) V31 on V31.paycode = pd.paycode  
left join (select d.paycode, sum(d.amount) as amount, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'V40' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) V40 on V40.paycode = pd.paycode 
left join (select d.paycode, sum(d.amount) as amount, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'V65' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) V65 on V65.paycode = pd.paycode              
left join (select d.paycode, sum(d.amount) as amount, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'V73' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) V73 on V73.paycode = pd.paycode  
left join (select d.paycode, sum(d.amount) as amount, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'V9A' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) V9A on V9A.paycode = pd.paycode  
left join (select d.paycode, sum(d.amount) as amount, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'VA3' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) VA3 on VA3.paycode = pd.paycode  
left join (select d.paycode, sum(d.amount) as amount, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'VA4' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) VA4 on VA4.paycode = pd.paycode  
left join (select d.paycode, sum(d.amount) as amount, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'VAF' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) VAF on VAF.paycode = pd.paycode  
left join (select d.paycode, sum(d.amount) as amount, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'VB1' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) VB1 on VB1.paycode = pd.paycode  
left join (select d.paycode, sum(d.amount) as amount, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'VB2' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) VB2 on VB2.paycode = pd.paycode  
left join (select d.paycode, sum(d.amount) as amount, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'VB3' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) VB3 on VB3.paycode = pd.paycode  
left join (select d.paycode, sum(d.amount) as amount, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'VB5' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) VB5 on VB5.paycode = pd.paycode  
left join (select d.paycode, sum(d.amount) as amount, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'VBA' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) VBA on VBA.paycode = pd.paycode  
left join (select d.paycode, sum(d.amount) as amount, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'VBB' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) VBB on VBB.paycode = pd.paycode  
left join (select d.paycode, sum(d.amount) as amount, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'VBD' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) VBD on VBD.paycode = pd.paycode  
left join (select d.paycode, sum(d.amount) as amount, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'VBE' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) VBE on VBE.paycode = pd.paycode  
left join (select d.paycode, sum(d.amount) as amount, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'VD0' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) VD0 on VD0.paycode = pd.paycode  
left join (select d.paycode, sum(d.amount) as amount, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'VEH' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) VEH on VEH.paycode = pd.paycode  
left join (select d.paycode, sum(d.amount) as amount, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'VDA' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) VDA on VDA.paycode = pd.paycode  
left join (select d.paycode, sum(d.amount) as amount, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'VEK' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) VEK on VEK.paycode = pd.paycode  
left join (select d.paycode, sum(d.amount) as amount, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'VGH' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) VGH on VGH.paycode = pd.paycode  
left join (select d.paycode, sum(d.amount) as amount, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'VGO' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) VGO on VGO.paycode = pd.paycode  
left join (select d.paycode, sum(d.amount) as amount, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'VGU' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) VGU on VGU.paycode = pd.paycode  
left join (select d.paycode, sum(d.amount) as amount, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'VGV' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) VGV on VGV.paycode = pd.paycode  
left join (select d.paycode, sum(d.amount) as amount, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'VG0' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) VG0 on VG0.paycode = pd.paycode                                                
left join (select d.paycode, sum(d.amount) as amount, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'V22' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) V22 on V22.paycode = pd.paycode                                                
left join (select d.paycode, sum(d.amount) as amount, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'V70' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) V70 on V70.paycode = pd.paycode                                                
left join (select d.paycode, sum(d.amount) as amount, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'V72' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) V72 on V72.paycode = pd.paycode                                                
left join (select d.paycode, sum(d.amount) as amount, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'VA5' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) VA5 on VA5.paycode = pd.paycode                                                
left join (select d.paycode, sum(d.amount) as amount, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'VA8' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) VA8 on VA8.paycode = pd.paycode                                                
left join (select d.paycode, sum(d.amount) as amount, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'VAG' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) VAG on VAG.paycode = pd.paycode                                                
left join (select d.paycode, sum(d.amount) as amount, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'VBC' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) VBC on VBC.paycode = pd.paycode                                                
left join (select d.paycode, sum(d.amount) as amount, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'VCI' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) VCI on VCI.paycode = pd.paycode                                                
left join (select d.paycode, sum(d.amount) as amount, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'VCP' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) VCP on VCP.paycode = pd.paycode                                                
left join (select d.paycode, sum(d.amount) as amount, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'VD1' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) VD1 on VD1.paycode = pd.paycode                                                
left join (select d.paycode, sum(d.amount) as amount, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'VD2' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) VD2 on VD2.paycode = pd.paycode                                                
left join (select d.paycode, sum(d.amount) as amount, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'VD3' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) VD3 on VD3.paycode = pd.paycode                                                
left join (select d.paycode, sum(d.amount) as amount, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'VD4' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) VD4 on VD4.paycode = pd.paycode                                                
left join (select d.paycode, sum(d.amount) as amount, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'VD5' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) VD5 on VD5.paycode = pd.paycode                                                
left join (select d.paycode, sum(d.amount) as amount, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'VD6' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) VD6 on VD6.paycode = pd.paycode                                                
left join (select d.paycode, sum(d.amount) as amount, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'VDG' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) VDG on VDG.paycode = pd.paycode                                                
left join (select d.paycode, sum(d.amount) as amount, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'VDI' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) VDI on VDI.paycode = pd.paycode                                                
left join (select d.paycode, sum(d.amount) as amount, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'V28' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) V28 on V28.paycode = pd.paycode                                                
left join (select d.paycode, sum(d.amount) as amount, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'V39' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) V39 on V39.paycode = pd.paycode                                                
left join (select d.paycode, sum(d.amount) as amount, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'V42' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) V42 on V42.paycode = pd.paycode                                                
left join (select d.paycode, sum(d.amount) as amount, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'V66' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) V66 on V66.paycode = pd.paycode                                                
left join (select d.paycode, sum(d.amount) as amount, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'V75' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) V75 on V75.paycode = pd.paycode                                                
left join (select d.paycode, sum(d.amount) as amount, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'V77' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) V77 on V77.paycode = pd.paycode                                                
left join (select d.paycode, sum(d.amount) as amount, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'V78' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) V78 on V78.paycode = pd.paycode                                                
left join (select d.paycode, sum(d.amount) as amount, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'V79' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) V79 on V79.paycode = pd.paycode                                                
left join (select d.paycode, sum(d.amount) as amount, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'V80' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) V80 on V80.paycode = pd.paycode                                                
left join (select d.paycode, sum(d.amount) as amount, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'V81' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) V81 on V81.paycode = pd.paycode                                                
left join (select d.paycode, sum(d.amount) as amount, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'V82' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) V82 on V82.paycode = pd.paycode                                                
left join (select d.paycode, sum(d.amount) as amount, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'V84' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) V84 on V84.paycode = pd.paycode                                                
left join (select d.paycode, sum(d.amount) as amount, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'V85' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) V85 on V85.paycode = pd.paycode                                                
left join (select d.paycode, sum(d.amount) as amount, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'V86' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) V86 on V86.paycode = pd.paycode                                                
left join (select d.paycode, sum(d.amount) as amount, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'V87' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) V87 on V87.paycode = pd.paycode                                                
left join (select d.paycode, sum(d.amount) as amount, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'V88' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) V88 on V88.paycode = pd.paycode                                                
left join (select d.paycode, sum(d.amount) as amount, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'V89' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) V89 on V89.paycode = pd.paycode                                                
left join (select d.paycode, sum(d.amount) as amount, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'V90' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) V90 on V90.paycode = pd.paycode                                                
left join (select d.paycode, sum(d.amount) as amount, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'VAE' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) VAE on VAE.paycode = pd.paycode                                                
left join (select d.paycode, sum(d.amount) as amount, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'VAL' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) VAL on VAL.paycode = pd.paycode                                                
left join (select d.paycode, sum(d.amount) as amount, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'VAQ' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) VAQ on VAQ.paycode = pd.paycode                                                
left join (select d.paycode, sum(d.amount) as amount, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'VAR' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) VAR on VAR.paycode = pd.paycode                                                
left join (select d.paycode, sum(d.amount) as amount, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'VAS' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) VAS on VAS.paycode = pd.paycode                                                
left join (select d.paycode, sum(d.amount) as amount, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'VAT' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) VAT on VAT.paycode = pd.paycode                                                
left join (select d.paycode, sum(d.amount) as amount, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'VAU' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) VAU on VAU.paycode = pd.paycode                                                
left join (select d.paycode, sum(d.amount) as amount, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'VB6' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) VB6 on VB6.paycode = pd.paycode                                                
left join (select d.paycode, sum(d.amount) as amount, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'VBP' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) VBP on VBP.paycode = pd.paycode                                                
left join (select d.paycode, sum(d.amount) as amount, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'VBQ' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) VBQ on VBQ.paycode = pd.paycode                                                
left join (select d.paycode, sum(d.amount) as amount, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'VBU' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) VBU on VBU.paycode = pd.paycode                                                
left join (select d.paycode, sum(d.amount) as amount, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'VCC' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) VCC on VCC.paycode = pd.paycode                                                
left join (select d.paycode, sum(d.amount) as amount, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'VCD' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) VCD on VCD.paycode = pd.paycode                                                
left join (select d.paycode, sum(d.amount) as amount, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'VCE' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) VCE on VCE.paycode = pd.paycode                                                
left join (select d.paycode, sum(d.amount) as amount, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'VCG' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) VCG on VCG.paycode = pd.paycode                                                
left join (select d.paycode, sum(d.amount) as amount, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'VCH' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) VCH on VCH.paycode = pd.paycode                                                
left join (select d.paycode, sum(d.amount) as amount, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'VCJ' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) VCJ on VCJ.paycode = pd.paycode                                                
left join (select d.paycode, sum(d.amount) as amount, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'VCM' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) VCM on VCM.paycode = pd.paycode                                                
left join (select d.paycode, sum(d.amount) as amount, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'VCN' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) VCN on VCN.paycode = pd.paycode                                                
left join (select d.paycode, sum(d.amount) as amount, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'VCO' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) VCO on VCO.paycode = pd.paycode                                                
left join (select d.paycode, sum(d.amount) as amount, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'VCV' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) VCV on VCV.paycode = pd.paycode                                                
left join (select d.paycode, sum(d.amount) as amount, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'VDB' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) VDB on VDB.paycode = pd.paycode                                                
left join (select d.paycode, sum(d.amount) as amount, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'VDO' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) VDO on VDO.paycode = pd.paycode                                                
left join (select d.paycode, sum(d.amount) as amount, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'VFP' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) VFP on VFP.paycode = pd.paycode                                                

             

left join (select d.paycode, sum(d.amount) as amount, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'VBD-ER' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) VBDER on VBDER.paycode = pd.paycode                                                
left join (select d.paycode, sum(d.amount) as amount, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'VBE-ER' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) VBEER on VBEER.paycode = pd.paycode                                                
left join (select d.paycode, sum(d.amount) as amount, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'VBL-ER' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) VBLER on VBLER.paycode = pd.paycode                                                
left join (select d.paycode, sum(d.amount) as amount, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'VBS-ER' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) VBSER on VBSER.paycode = pd.paycode                                                
left join (select d.paycode, sum(d.amount) as amount, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'VGO-ER' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) VGOER on VGOER.paycode = pd.paycode                                                
left join (select d.paycode, sum(d.amount) as amount, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'VGP-ER' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) VGPER on VGPER.paycode = pd.paycode                                                
left join (select d.paycode, sum(d.amount) as amount, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'VGW-ER' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) VGWER on VGWER.paycode = pd.paycode                                                
left join (select d.paycode, sum(d.amount) as amount, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'VGX-ER' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) VGXER on VGXER.paycode = pd.paycode                                                
left join (select d.paycode, sum(d.amount) as amount, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'V39-ER' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) V39ER on V39ER.paycode = pd.paycode                                                
left join (select d.paycode, sum(d.amount) as amount, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'VGH-ER' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) VGHER on VGHER.paycode = pd.paycode                                                
left join (select d.paycode, sum(d.amount) as amount, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'V42-ER' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) V42ER on V42ER.paycode = pd.paycode                                                
left join (select d.paycode, sum(d.amount) as amount, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'V43-ER' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) V43ER on V43ER.paycode = pd.paycode                                                

left join (select d.paycode, sum(d.amount) as amount, sum(d.amount_ytd) as ytd_amount, sum(d.subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where d.paycode = 'VBC-ER' AND (d.amount_ytd <> 0::numeric OR d.units_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.units <> 0::numeric) group by paycode ) VBCER on VBCER.paycode = pd.paycode                                                


     
   )v 
   group by qsource,etv_id,pd_amount,pd_net_pay,pd_gross_pay,pd_ytd_amount,pd_subject_wages_ytd
   order by 2
   ;
   