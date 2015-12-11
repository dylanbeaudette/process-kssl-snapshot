
# load cached data
load('cached-data/kssl-site-and-horizon-data.Rda')


## QC

# dupe check:
tt <- table(s$pedlabsampnum)
if(any(tt > 1)) {
  dupes <- s[s$pedlabsampnum %in% names(which(tt > 1)), ]
  dupes <- dupes[order(dupes$pedlabsampnum), ]
  print(dupes)
  stop('duplicate records in site query')
}



## 1. get a single taxonname, rules:
# use correlated_as when possible
# use sampled_as when correlated_as == 'unnamed'

# fix taxonname
s$taxonname <- with(s, ifelse(is.na(correlated_as), sampled_as, correlated_as))

# when correlated is ~ 'unnamed', use sampled
unnamed.idx <- grep('unnamed', s$taxonname)
s$taxonname[unnamed.idx] <- s$sampled_as[unnamed.idx]



## 2. horizonation fixes

# fix missing lower hz boundaries with (top + 1)
idx <- which(!is.na(h$hzn_top) & is.na(h$hzn_bot))
h$hzn_bot[idx] <- h$hzn_top[idx] + 1

# remove O horizons where top > bottom
bad.O.hz.idx <- which(h$hzn_top > h$hzn_bot)
if(length(bad.O.hz.idx) > 0)
  h <- h[-bad.O.hz.idx, ]


## 3. add MLRA and other important overlap information via spatial intersection
# not all pedons have coordinates...

# national mlra boundary map, already GCS NAD83
mlra <- readOGR(dsn='L:/Geodata/Boundaries', layer='mlra_v42')
states <- readOGR(dsn='L:/Geodata/Boundaries', layer='statesp020')

# keep only those profiles with coordinates
s.sp <- subset(s, subset=!is.na(x))

# init coordinates
coordinates(s.sp) <- ~ x + y
proj4string(s.sp) <- '+proj=longlat +datum=NAD83 +no_defs +ellps=GRS80 +towgs84=0,0,0'

# overlay
s.sp$state <- over(s.sp, states)$STATE
s.sp$mlra <- over(s.sp, mlra)$MLRARSYM

# copy back to original site data
s <- join(s, s.sp@data[, c('pedon_key', 'state', 'mlra')])


## 4. Estimated values: prefix with "estimated"
# Double-check these !

# relace 0 C and N
h$c_tot[which(h$c_tot == 0)] <- NA
h$n_tot[which(h$n_tot == 0)] <- NA


# fill NA carbonate-C with 0
h$caco3 <- ifelse(is.na(h$caco3), 0, h$caco3)

# organic matter and organic carbon
h$estimated_oc <- with(h, c_tot - (caco3 * 0.12))
h$estimated_om <- with(h, Calc_OC * 1.724 )

# estimate C:N 
h$estimated_c_to_n <- h$estimated_oc / h$n_tot

# compute ex-K saturation
h$ex_k_saturation <- h$ex_k / h$base_sum


# fill pH 1:1 with saturated paste pH when missing
hexbinplot(ph_h2o ~ ph_sp, data=h, asp=1, xlim=c(1, 13), ylim=c(1, 13), trans=log, inv=exp) + latticeExtra::layer(panel.abline(0, 1, col='red', lwd=2, lty=2))

(l.ph <- ols(ph_h2o ~ rcs(ph_sp), data=h, x=TRUE, y=TRUE, subset=ph_h2o >= 0 & ph_h2o <= 14))
anova(l.ph)

h$estimated_ph_h2o <- h$ph_h2o 
idx <- which(is.na(h$ph_h2o))
h$estimated_ph_h2o[idx] <- predict(l.ph, h[idx, ])

h$estimated_ph_h2o[which(h$estimated_ph_h2o < 0)] <- NA
h$estimated_ph_h2o[which(h$estimated_ph_h2o > 14)] <- NA

hexbinplot(estimated_ph_h2o ~ ph_h2o, data=h, xlim=c(1, 13), ylim=c(1, 13), asp=1, trans=log, inv=exp) + latticeExtra::layer(panel.abline(0, 1, col='red', lwd=2, lty=2))



# re-calculate BS82 when missing, but ex-cations and ex-acid are available

# BS82 can be computed in some cases when missing but ex-cations and ex-acidity are present
# bs82 = sum(ex_ca ex_mg ex_na ex_k) / sum(ex_ca ex_mg ex_na ex_k acid_tea)
h$bs82.computed <- with(h, (ex_ca + ex_mg + ex_na + ex_k) / (ex_ca + ex_mg + ex_na + ex_k + acid_tea)) * 100
h$bs82.computed[which(h$bs82.computed < 0 | h$bs82.computed > 100)] <- NA

# check to make sure that this is correct: YES
hexbinplot(bs82 ~ bs82.computed, data=h, xlim=c(0,100), ylim=c(0,100), asp=1, trans=log, inv=exp) + latticeExtra::layer(panel.abline(0, 1, col='red', lwd=2, lty=2))

# replace missing BS82 with computed BS82
h$bs82 <- ifelse(is.na(h$bs82) & (! is.na(bs82.computed)), bs82.computed, h$bs82)

# remove negative values
h$bs82[which(h$bs82 < 0)] <- NA

# estimating BS82 from BS7 doesn't work at the national-scale


## export data for SoilWeb

# print table defs
cat(postgresqlBuildTableDefinition(PostgreSQL(), name='kssl.site', obj=s[1, ], row.names=FALSE), file='site.sql')
cat(postgresqlBuildTableDefinition(PostgreSQL(), name='kssl.horizon', obj=h[1, ], row.names=FALSE), file='hz.sql')

# save raw, minimally processed data
write.csv(s, file=gzfile('kssl-site.csv.gz'), row.names=FALSE)
write.csv(h, file=gzfile('kssl-horizon.csv.gz'), row.names=FALSE)

## upgrade to SoilProfilecollection
lab <- h
depths(lab) <- pedon_key ~ hzn_top + hzn_bot

# joing site-level data with new SPC
site(lab) <- s

# cache for later
save(lab, file='cached-data/kssl-SPC.Rda')

