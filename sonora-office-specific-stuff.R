
# load cached data
load('cached-data/kssl-SPC.Rda')


#### subset Sonora Office stuff here:

# keep only those lab data that are within MLRA 17, 18, 22A
# by filtering on MLRA code derived from the spatial layer
lab <- lab[which(lab$mlra %in% c('17', '18', '22A')), ]
lab$mlra <- factor(lab$mlra)

# cleanup
gc(reset = TRUE)


## fill some missing data if possible


# reationship is almost linear
(p1 <- xyplot(bs82 ~ bs7, data=horizons(lab), col='black', type=c('p','smooth','g')))
(p2 <- xyplot(bs82 ~ ph_h2o, data=horizons(lab), col='black', type=c('p','smooth','g')))

# model bs82 from bs7, truncate to less than 100%
# can't use pH, as it is missing from too many samples
# (l.bs <- ols(bs82 ~ bs7 + rcs(ph_h2o), data=horizons(lab), subset=bs7 < 100 & bs82 < 100, x=TRUE, y=TRUE))
(l.bs <- ols(bs82 ~ rcs(bs7), data=horizons(lab), subset=bs7 < 100 & bs82 < 100, x=TRUE, y=TRUE))

# check predictions
plot(lab$bs82 ~ predict(l.bs, horizons(lab))) 
abline(0, 1, col='red', lwd=2)

# RMSE: ~ 12% base saturation
sqrt(mean((predict(l.bs, horizons(lab)) - lab$bs82)^2, na.rm = TRUE))

# save model for others... could probably use some work
save(l.bs, file='mlra-17-18-22A-BS82-model.Rda')

# re-index missing values, that CAN BE predicted from BS7
missing.bs82 <- which(is.na(lab$bs82) & !is.na(lab$bs7) & lab$bs7 < 100)

# predict bs82 from bs7 when missing:
lab$bs82[missing.bs82] <- predict(l.bs, data.frame(bs7=lab$bs7[missing.bs82]))

# make note of estimated bs82
lab$bs82.method <- rep('measured', times=nrow(lab))
lab$bs82.method[missing.bs82] <- 'estimated'

# check: ok
(p3 <- xyplot(bs82 ~ bs7 | bs82.method, data=horizons(lab), type=c('p','smooth','g')))





## save to CSV file for others
write.csv(as(lab, 'data.frame'), file='kssl-ca-june-2015.csv', row.names=FALSE)

# init coordinates
coordinates(lab) <- ~ x + y
proj4string(lab) <- '+proj=longlat +datum=NAD83 +no_defs +ellps=GRS80 +towgs84=0,0,0'

## save result to Rda object for later
save(lab, file='kssl-ca-june-2015.Rda')

## graphical check: OK
png(file='sample-locations.png', width=600, height=800, antialias = 'cleartype')
par(mar=c(0,0,3,0))
map('county', 'California')
plot(mlra[mlra$MLRARSYM %in% c('17', '18', '22A'), ], border='blue', add=TRUE)
plot(as(lab, 'SpatialPoints'), add=TRUE, col='red', cex=0.25)
title('June 2015')
dev.off()


## save select attributes to SHP
writeOGR(as(lab, 'SpatialPointsDataFrame')[, c('pedon_id', 'taxonname')], dsn='L:/Geodata/UCD_NCSS', layer='mlra_17_18_22-lab_data', driver='ESRI Shapefile', overwrite_layer=TRUE)

## aggregate some soil properties for all profiles by MLRA, along 1 cm slices
a <- slab(lab, mlra ~ clay + ex_k_saturation + ph_h2o + bs82)

# adjust factor labels for MLRA to include number of pedons
pedons.per.mlra <- tapply(site(lab)$mlra, site(lab)$mlra, length)
a$mlra <- factor(a$mlra, levels=names(pedons.per.mlra), labels=paste(names(pedons.per.mlra), ' (', pedons.per.mlra, ' profiles)', sep=''))

# re-name variables
a$variable <- factor(a$variable, labels=c('Clay %', 'Ex-K Saturation', 'pH 1:1 Water', 'Base Sat. pH 8.2'))

# make some nice colors
cols <- brewer.pal('Set1', n=3)

# plot: nice
png(file='properties_by_mlra.png', width=1400, height=700, antialias = 'cleartype')
xyplot(
  top ~ p.q50 | variable, groups=mlra, data=a, lower=a$p.q25, upper=a$p.q75, 
  ylim=c(170,-5), alpha=0.25, scales=list(y=list(tick.num=7, alternating=3), x=list(relation='free',alternating=1)),
  panel=panel.depth_function, prepanel=prepanel.depth_function, sync.colors=TRUE, asp=1.5,
  ylab='Depth (cm)', xlab='median bounded by 25th and 75th percentiles', strip=strip.custom(bg=grey(0.85)), cf=a$contributing_fraction,
  par.settings=list(superpose.line=list(col=cols, lty=c(1,2,3), lwd=2)),
  auto.key=list(columns=3, title='MLRA', points=FALSE, lines=TRUE),
  sub=paste(length(lab), 'profiles')
)
dev.off()




summary(horizons(lab)[, c('clay', 'ph_h2o', 'fe_dith', 'fe_ox')])
