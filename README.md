# Generate a KSSL pedon database for SoilWeb from the USDA-NRCS-NCSS snapshot

I periodically "process" the NCSS-KSSL characterization data snapshot (usually quarterly) into a consolidated chunk of data that are used within [SoilWeb](casoilresource.lawr.ucdavis.edu/sde/?series=auburn) and by [`fetchKSSL()`](https://r-forge.r-project.org/scm/viewvc.php/*checkout*/docs/soilDB/KSSL-demo.html?root=aqp). This snapshot is typically delivered as an Access database and contains a mixture of: the latest "lab" data from LIMS, and the latest taxonomic and spatial data from NASIS. The resulting "processed" data include over 50 attributes, split into chunks that roughly approximate the "pedon/site" scale and "horizon" scale.

Snapshots:
 * KSSL lab, taxonomic, and location data: 2015-12-07
 * NASIS morphologic data: 2016-04-20

## News
* 2016-04-22: added new code + web-service for basic NASIS morphologic data; data returned as JSON
* 2016-01-15: added a new column with fragments (percent by weight) > 2mm. **use these values with caution**
* 2015-12-18: started processing new snapshot "December 2015" (62922 pedons, 401427 horizons) **RaCA sites no longer included**
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
6. pH (1:1 H2O) estimated when missing via saturated paste pH (pedotransfer function)

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
  * frags (weight percentage > 2mm)
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
  * geomposhill
  * geomposmntn
  * geompostrce
  * geomposflats
  * hillslopeprof
  * geomslopeseg
  * bedrckkind
  * bedrckhardness
  * pmgroupname
  * drainagecl

Morphologic (field-described) attributes:

  * horizon colors (phcolor table)
  * rock fragments -- volume percent (phfrags table)
  * pores (phpores table)
  * structure (phstructure)


# TODO
* update fetchKSSL and associated web-service to use JSON for all transfers
* return snapshot dates in JSON data stream
* write manual on KSSL processing steps, assumptions, models, etc.
* locate water retention, Db, AWC, etc. from SoilVeg data in Access DB
* solve problem with multiple (rows) prep codes (most common: "S","GP","HM") in the water retention and Db tables--this will require multiple queries to the Db table and cleaning of the results:
 + S	air-dry	whole soil	The air-dried whole soil passing a 3 inch sieve
 + GP	air-dry	whole soil	The air-dried whole soil including all coarse fragments
 + M	moist	<2 mm	The moist soil passing a No. 10-mesh sieve kept in the moist state
 + HM	air-dry	whole soil	The air-dried whole soil including all coarse fragments handled with stainless-steel or non-metallic equipment to reduce the contamination with heavy metals


