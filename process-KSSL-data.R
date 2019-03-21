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
# 2017-09-12 using DISTINCT to filter out some duplicate records
# 2018-04-25 more intelligent filtering of Tier_3 table, ignores prep code (https://github.com/dylanbeaudette/process-kssl-snapshot/issues/4)
q.hz <- "SELECT DISTINCT
NCSS_Pedon_Taxonomy.pedon_key AS pedon_key, NCSS_Layer.labsampnum AS labsampnum,
hzn_top, hzn_bot, hzn_desgn, hzn_desgn_old,
tex_psda AS lab_texture_class, sand_tot_psa as sand, silt_tot_psa as silt, clay_tot_psa as clay, 
co3_cly, silt_f_psa, silt_c_psa, 
sand_vf_psa as vfs, sand_f_psa as fs, sand_m_psa as ms, sand_c_psa as cs, sand_vc_psa as vcs, 
acid_tea, base_sum, al_kcl, cec_nh4 as cec7, cec_sum as cec82, ecec, al_sat, bsecat AS bs82, bsesat AS bs7,
ca_nh4 as ex_ca, mg_nh4 as ex_mg, na_nh4 as ex_na, k_nh4 as ex_k,
ph_h2o, ph_cacl2, ph_kcl, ph_sp, ph_ox, gypl20, caco3, ec_12pre, sar, 
oc, c_tot, n_tot, fe_dith, fe_ox, al_dith, al_ox,
p_olsn, p_nz,
db_13b, db_od, COLEws,
db.wrd_ws13 as whc, db.w3cld AS w3cld, db.w15l2 AS w15l2, db.w15cly AS w15cly, cec7_cly, wpg2 as frags,
t3.wrd_l2 as wrd_l2,
theta_r, theta_s, alpha, npar, Ks, Ko, Lpar
FROM
NCSS_Pedon_Taxonomy 
LEFT JOIN NCSS_Layer ON NCSS_Pedon_Taxonomy.pedon_key = NCSS_Layer.pedon_key
LEFT JOIN CEC_and_Bases ON NCSS_Layer.labsampnum = CEC_and_Bases.labsampnum
LEFT JOIN PSDA_and_Rock_Fragments ON NCSS_Layer.labsampnum = PSDA_and_Rock_Fragments.labsampnum
LEFT JOIN Carbon_and_Extractions ON NCSS_Layer.labsampnum = Carbon_and_Extractions.labsampnum
LEFT JOIN ph_and_Carbonates ON NCSS_Layer.labsampnum = ph_and_Carbonates.labsampnum
LEFT JOIN (SELECT * FROM Bulk_Density_and_Moisture WHERE prep_code = 'S') AS db ON NCSS_Layer.labsampnum = db.labsampnum
LEFT JOIN (SELECT DISTINCT labsampnum, wrd_l2 FROM Supplementary_Tier_3) AS t3 ON NCSS_Layer.labsampnum = t3.labsampnum
LEFT JOIN Salt ON NCSS_Layer.labsampnum = Salt.labsampnum
LEFT JOIN Phosphorus ON NCSS_Layer.labsampnum = Phosphorus.labsampnum
LEFT JOIN Rosetta_Parameters ON NCSS_Layer.labsampnum = Rosetta_Parameters.labsampnum
ORDER BY NCSS_Pedon_Taxonomy.pedon_key, hzn_top ASC;"

## TODO: there are several truncated fields in here... related to FGDB -> TXT export
# get essential site-level records: some of these will not be in NASIS
# current taxonomic / site data are cross-references with NASIS data
# 2017-09-12 using DISTINCT to filter out some duplicate records
q.site <- "SELECT DISTINCT
pedon_key, pedlabsampnum, upedonid AS pedon_id,
longitude_decima as x, latitude_decimal as y, 
samp_name AS sampled_as, corr_name AS correlated_as,
corr_class_type as correlated_taxon_kind,
cntrl_depth_to_t as pscs_top, cntrl_depth_to_b as pscs_bottom, pedon_completene AS pedon_completeness_index,
-- adding this until we get the NASIS side fixed
SSL_taxsubgrp as ssl_taxsubgroup
FROM NCSS_Pedon_Taxonomy
ORDER BY pedon_key;"


# setup connection to SQLite DB from FGDB export
db <- dbConnect(RSQLite::SQLite(), "E:/NASIS-KSSL-LDM/KSSL-data.sqlite")

# fetch records
h <- dbGetQuery(db, q.hz)
s <- dbGetQuery(db, q.site)

# save table description for QC
options(width=160)
sink(file='QC/horizon-descripton.txt')
Hmisc::describe(h)
sink()

sink(file='QC/site-descripton.txt')
Hmisc::describe(s)
sink()


# save cached data for next steps
save(s, h, file='S:/NRCS/430 SOI Soil Survey/430-13 Investigations/Lab_Data/cached-data/kssl-site-and-horizon-data.Rda')

dbDisconnect(db)

