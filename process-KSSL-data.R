## Get lab characterization data from LIMS snapshot; morphologic data are from NASIS
##
## D.E. Beaudette
##
## 2017-09-11: major re-write
##


# get hz data from KSSL snapshot
# 2014-09-18 adapted from the "Master Query"
# 2015-12-10 picking up new columns and replacing NULL CaCO3 will 0
# 2017-04-24 must solve prep code issues before t3 will contain anything useful
# 2017-09-11 now using SQLite version of LIMS snapshot
q.hz <- "SELECT
NCSS_Pedon_Taxonomy.pedon_key, NCSS_Layer.labsampnum,
hzn_top, hzn_bot, hzn_desgn, hzn_desgn_old,
tex_psda AS lab_texture_class, sand_tot_psa as sand, silt_tot_psa as silt, clay_tot_psa as clay, 
co3_cly, silt_f_psa, silt_c_psa, 
sand_vf_psa as vfs, sand_f_psa as fs, sand_m_psa as ms, sand_c_psa as cs, sand_vc_psa as vcs, 
acid_tea, base_sum, al_kcl, cec_nh4 as cec7, cec_sum as cec82, ecec, al_sat, bsecat AS bs82, bsesat AS bs7,
ca_nh4 as ex_ca, mg_nh4 as ex_mg, na_nh4 as ex_na, k_nh4 as ex_k,
ph_h2o, ph_cacl2, ph_kcl, ph_sp, gypl20, caco3, ec_12pre, sar, 
oc, c_tot, n_tot, fe_dith, fe_ox, al_dith, al_ox,
p_olsn, p_nz,
db_13b, db_od, COLEws,
db.wrd_ws13 as whc, db.w3cld, db.w15l2, db.w15cly, cec7_cly, wpg2 as frags,
t3.wrd_l2
FROM
NCSS_Pedon_Taxonomy 
LEFT OUTER JOIN NCSS_Layer ON NCSS_Pedon_Taxonomy.pedon_key = NCSS_Layer.pedon_key
LEFT OUTER JOIN CEC_and_Bases ON NCSS_Layer.labsampnum = CEC_and_Bases.labsampnum
LEFT OUTER JOIN PSDA_and_Rock_Fragments ON NCSS_Layer.labsampnum = PSDA_and_Rock_Fragments.labsampnum
LEFT OUTER JOIN Carbon_and_Extractions ON NCSS_Layer.labsampnum = Carbon_and_Extractions.labsampnum
LEFT OUTER JOIN ph_and_Carbonates ON NCSS_Layer.labsampnum = ph_and_Carbonates.labsampnum
LEFT OUTER JOIN (SELECT * FROM Bulk_Density_and_Moisture WHERE prep_code = 'S') AS db ON NCSS_Layer.labsampnum = db.labsampnum
LEFT OUTER JOIN (SELECT * FROM Supplementary_Tier_3 WHERE prep_code = 'S') AS t3 ON NCSS_Layer.labsampnum = t3.labsampnum
LEFT OUTER JOIN Salt ON NCSS_Layer.labsampnum = Salt.labsampnum
LEFT OUTER JOIN Phosphorus ON NCSS_Layer.labsampnum = Phosphorus.labsampnum
ORDER BY NCSS_Pedon_Taxonomy.pedon_key, hzn_top ASC;"

# get essential site level records: IDs and PCI
# site / morph data are later extracted from NASIS data sources
q.site <- "SELECT pedon_key, pedlabsampnum, pedon_completene AS pedon_completeness_index 
FROM NCSS_Pedon_Taxonomy 
ORDER BY pedon_key;"

# setup connection to SQLite DB from FGDB export
db <- dbConnect(RSQLite::SQLite(), "E:/working_copies/lab-data-delivery/code/text-file-to-sqlite/KSSL-data.sqlite")

# fetch records
h <- dbGetQuery(db, q.hz)
s <- dbGetQuery(db, q.site)

# save cached data
save(s, h, file='S:/NRCS/Lab_Data/cached-data/kssl-site-and-horizon-data.Rda')

dbDisconnect(db)

