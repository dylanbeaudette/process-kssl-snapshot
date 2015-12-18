# Generate a KSSL pedon database for SoilWeb from the USDA-NRCS-NCSS snapshot

I periodically "process" the NCSS-KSSL characterization data snapshot (usually quarterly) into a consolidated chunk of data that are used within [SoilWeb](casoilresource.lawr.ucdavis.edu/sde/?series=auburn) and by [`fetchKSSL()`](https://r-forge.r-project.org/scm/viewvc.php/*checkout*/docs/soilDB/KSSL-demo.html?root=aqp). This snapshot is typically delivered as an Access database and contains a mixture of: the latest "lab" data from LIMS, and the latest taxonomic and spatial data from NASIS. The resulting "processed" data include over 50 attributes, split into chunks that roughly approximate the "pedon/site" scale and "horizon" scale.

## News
* 2015-12-18: started processing new snapshot "December 2015" (62922 pedons, 401427 horizons) **why the decrease in records?**
* 2015-12-11: loaded snapshot "August 2015" (64071 pedons, 402199 horizons)

## Data Cleaning
As part of the "processing" of these data, a number of data cleaning operations are performed.

### Taxonname
A new field caled `taxonname` is added. This field is set to the `correlated_as` value when not null and not "unnamed". Otherwise, the `taxonname` field is set to the value in `sampled_as`. 


### Horizonation
1. Missing lower horizon depths are replaced with the corrosponding top depth + 1cm.
2. "O" horizons using the old-style notation, with top depths > bottom depths, are removed. Sorry.


### MLRA and State Data
State and MLRA codes are added to the data using spatial overlay with the most recent US states and NRCS MLRA maps.

### Estimated Properties
1. K saturation is computed via `ex_k / base_sum`
2. total C and N values of 0 are replaced by NA
3. organic C estimated via `c_tot - (ifelse(is.na(caco3), 0, caco3) * 0.12)`
4. organic matter estimated via `estimated_oc * 1.724`
5. C:N estimated via `h$estimated_oc / h$n_tot`
6. pH (1:1 H2O) estimated when missing via saturate paste pH (pedotransfer function)

![alt text](figures/ph-1-to-1-water-vs-sat-paste.png)
![alt text](figures/ph-1-to-1-water-vs-sat-paste-predictions.png)

7. base saturation (pH 8.2) calculated when missing: 
 + `h$bs82.computed <- with(h, (ex_ca + ex_mg + ex_na + ex_k) / (ex_ca + ex_mg + ex_na + ex_k + acid_tea)) * 100`

![alt text](figures/measured-vs-computed-bs82.png)

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
