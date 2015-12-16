# Generate a KSSL pedon database for SoilWeb from the USDA-NRCS-NCSS snapshot

I periodically "process" the NCSS-KSSL characterization data snapshot (usually quarterly) into a consolidated chunk of data that are used within SoilWeb and by `fetchKSSL()`. This snapshot is typically delivered as an Access database and contains a mixture of: the latest "lab" data from LIMS, and the latest taxonomic and spatial data from NASIS. The resulting "processed" data include over 50 attributes, split into chunks that roughly approximate the "pedon/site" scale and "horizon" scale.


## Data Cleaning

### Taxonname


### Horizonation


### MLRA and State Data


### Estimated Properties





## Data Elements
Horizon attributes:

  * pedon_key
  * labsampnum
  * hzn_top
  * hzn_bot
  * hzn_desgn
  * hzn_desgn_old
  * lab_texture_class
  * sand
  * silt
  * clay
  * co3_cly
  * silt_f_psa
  * silt_c_psa
  * vfs
  * fs
  * ms
  * cs
  * vcs
  * acid_tea
  * base_sum
  * al_kcl
  * cec7
  * cec82
  * ecec
  * al_sat
  * bs82
  * bs7
  * ex_ca
  * ex_mg
  * ex_na
  * ex_k
  * ph_h2o
  * ph_cacl2
  * ph_kcl
  * ph_sp
  * gypl20
  * caco3
  * ec_12pre
  * sar
  * oc
  * c_tot
  * n_tot
  * fe_dith
  * fe_ox
  * p_olsn
  * p_nz
  * db_13b
  * db_od
  * COLEws
  * whc
  * w3cld
  * w15l2
  * w15cly
  * cec7_cly
  * estimated_oc
  * estimated_om
  * estimated_c_to_n
  * ex_k_saturation
  * estimated_ph_h2o

Site attributes:

  * pedon_key
  * pedlabsampnum
  * pedon_id
  * x
  * y
  * sampled_as
  * correlated_as
  * correlated_taxon_kind
  * pscs_top
  * pscs_bottom
  * pedon_completeness_index
  * taxonname
  * state
  * mlra




# TODO
1. write manual on KSSL processing steps, assumptions, models, etc.
2. add HTML table below KSSL lab summary figures in SDE
3. locate water retention, Db, AWC, etc. from SoilVeg data in Access DB
4. solve problem with multiple prep codes ("S" and "G") in the water retention and Db tables
